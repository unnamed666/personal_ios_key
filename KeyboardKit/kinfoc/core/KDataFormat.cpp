//#include "stdafx.h"
#include "KFunction.h"
#include "KDataFormat.h"
#include "KDataStream.h"
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>

KKeyFormat::KKeyFormat(LPCTSTR szName, LPCTSTR szType)
{
	m_strName = szName;
	m_strType = szType;
}

LPCTSTR KKeyFormat::GetName()
{
	return m_strName;
}

LPCTSTR KKeyFormat::GetType()
{
	return m_strType;
}

KTableFormat::KTableFormat()
{
	m_uTableIndex = 0;
}

KTableFormat::~KTableFormat()
{
	for (size_t i = 0; i < m_vecKeys.size(); i++)
	{
		delete m_vecKeys[i];
	}

	m_vecKeys.clear();
}

bool KTableFormat::ParseFormat(LPCTSTR szFormat)
{
	bool bReturn = false;
	bool bRetCode = false;
	CString strBuffer;
	CString strKeyName;
	CString strKeyType;
	CString strFormat(szFormat);
	KKeyFormat* pKeyFormat = NULL;

	TCHAR* token = _tcstok((TCHAR*)(LPCTSTR)strFormat, _T(" "));
	if (token)
	{
		strBuffer = token;

		bRetCode = ParseKeyNameAndType(strBuffer, strKeyName, strKeyType);
		if (!bRetCode) goto Exit0;

		m_strTableName = strKeyName;
		m_uTableIndex = _ttoi(strKeyType);

		token = _tcstok(NULL, _T(" "));
		while (token)
		{
			strBuffer = token;
			bRetCode = ParseKeyNameAndType(strBuffer, strKeyName, strKeyType);
			if (!bRetCode) goto Exit0;

			pKeyFormat = new KKeyFormat(strKeyName, strKeyType);

			if (strKeyType.CompareNoCase(_T("bit")) == 0)
				m_vecBitKeys.push_back(pKeyFormat);
			else
				m_vecKeys.push_back(pKeyFormat);
			
			token = _tcstok(NULL, _T(" "));
		}
	}

	bReturn = true;
Exit0:
	return bReturn;
}

bool KTableFormat::ParseKeyNameAndType(CString& strBuffer, CString& strName, CString& strType)
{
	strBuffer.Trim(_T(' '));

	strName.Empty();
	strType.Empty();

	int nPos = strBuffer.Find(_T(':'));
	if (nPos != -1)
	{
		strName = strBuffer.Left(nPos);
		strType = strBuffer.Right(strBuffer.GetLength() - nPos - 1);
	}

	return !strName.IsEmpty() && !strType.IsEmpty();
}

unsigned short KTableFormat::GetTableIndex(void)
{
	return m_uTableIndex;
}

LPCTSTR KTableFormat::GetTableName(void)
{
	return m_strTableName;
}

int KTableFormat::GetKeyCount(void)
{
	return m_vecKeys.size() + m_vecBitKeys.size();
}

int KTableFormat::GetBitCount(void)
{
	return m_vecBitKeys.size();
}

KKeyFormat* KTableFormat::GetKeyFormat(int nKeyIndex)
{
	if (nKeyIndex < m_vecKeys.size())
	{
		return m_vecKeys[nKeyIndex];
	}

	return m_vecBitKeys[nKeyIndex - m_vecKeys.size()];
}


KDataFormat::KDataFormat()
{
    pthread_mutexattr_init(&m_attr);
    pthread_mutexattr_settype(&m_attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&m_cs, &m_attr);
}

KDataFormat::~KDataFormat()
{
    pthread_mutex_lock(&m_cs);
	for (size_t i = 0; i < m_vecTables.size(); i++)
	{
		delete m_vecTables[i];
	}

	m_vecTables.clear();
    pthread_mutex_unlock(&m_cs);
    
    pthread_mutex_destroy(&m_cs);
    pthread_mutexattr_destroy(&m_attr);
}

bool KDataFormat::Initialize(void)
{
	CString strPath;

	strPath = KFunction::GetModulePath();
	strPath += _T("kfmt.dat");
	
	LoadFile(strPath);

	return TRUE;
}

bool KDataFormat::LoadFile(LPCTSTR szFileName)
{
	bool bReturn = false;
//    int nRetCode = 0;
	char* pBuffer = NULL;
	//HANDLE hFile = INVALID_HANDLE_VALUE;


	//DWORD dwFileSizeHigh = 0;
	DWORD dwFileSizeLow = 0;
	DWORD dwReaded = 0;
	int fd = -1;
    struct stat statbuff;

    if(stat(szFileName, &statbuff) < 0){
    	goto Exit0;
    }else{
    	dwFileSizeLow = statbuff.st_size;
    }

	fd = open(szFileName, O_RDONLY);
    if (fd == -1)
    	goto Exit0;

	pBuffer = new char[dwFileSizeLow + 2];

	dwReaded = read(fd, pBuffer, dwFileSizeLow);

	if (dwReaded != dwFileSizeLow)
		goto Exit0;


	pBuffer[dwFileSizeLow] = 0;
	pBuffer[dwFileSizeLow + 1] = 0;

	//USES_CONVERSION;
    pthread_mutex_lock(&m_cs);
	bReturn = Parse(pBuffer);
    pthread_mutex_unlock(&m_cs);

Exit0:
	if (pBuffer)
		delete[] pBuffer;

	if (fd != -1)
		close(fd);

	return bReturn;
}

bool KDataFormat::Parse(LPCTSTR szBuffer)
{
	bool bReturn = false;
	bool bRetCode = false;
	CString strLine;
	LPCTSTR pNextStart = szBuffer;

	do 
	{
		strLine.Empty();
		pNextStart = GetLine(pNextStart, strLine);

		if (!strLine.IsEmpty())
		{
			KTableFormat* pTableFormat = new KTableFormat;
			bRetCode = pTableFormat->ParseFormat(strLine);
			if (!bRetCode) 
			{
				if (pTableFormat != NULL)
				{
					delete pTableFormat;
					pTableFormat = NULL;
				}
				goto Exit0;
			}

			if (GetTableFormat(pTableFormat->GetTableIndex()) ||
				GetTableFormat(pTableFormat->GetTableName()))
			{
				if (pTableFormat != NULL)
				{
					delete pTableFormat;
					pTableFormat = NULL;
				}
				goto Exit0;
			}
			
			m_vecTables.push_back(pTableFormat);
		}

	} while (pNextStart);

	bReturn = true;
Exit0:
	return bReturn;
}

LPCTSTR KDataFormat::GetLine(LPCTSTR pBuffer, CString& strLine)
{
//    int nOffset = 0;
//    int nEnd = 0;
	LPCTSTR pEnd = NULL;

	uint32_t uEndIdx = _tcscspn(pBuffer, _T("\r\n"));
        if (_tcslen(pBuffer) > uEndIdx)
        {
            pEnd = pBuffer + uEndIdx;
        }

	if (pEnd)
	{
		strLine.Append(pBuffer, pEnd - pBuffer);
		pEnd++;

		if (pEnd[0] == '\n')
			pEnd++;
	}
	else
	{
		strLine.Append(pBuffer);
	}
	
	strLine.Trim();

	return pEnd;
}

KTableFormat* KDataFormat::GetTableFormat(unsigned short uTableIndex)
{
    KTableFormat* pRst = NULL;
    pthread_mutex_lock(&m_cs);
	for (int i = 0; i < m_vecTables.size(); i++)
	{
        if (m_vecTables[i]->GetTableIndex() == uTableIndex) {
			pRst = m_vecTables[i];
            break;
        }
	}
    pthread_mutex_unlock(&m_cs);

	return pRst;
}

KTableFormat* KDataFormat::GetTableFormat(LPCTSTR szTableName)
{
	CString strTableName;
	if (szTableName == NULL)
	{
		return NULL;
	}
    
    KTableFormat* pRst = NULL;
    pthread_mutex_lock(&m_cs);
	for (int i = 0; i < m_vecTables.size(); i++)
	{
		strTableName.Empty();
        KTableFormat* pTemp = m_vecTables[i];
        if (NULL == pTemp) {
            continue;
        }
        LPCTSTR szTemp = pTemp->GetTableName();
        if (NULL != szTemp) {
            strTableName = szTemp;
        }
		if (strTableName.IsEmpty())
		{
			continue;
		}

		if (strTableName.CompareNoCase(szTableName) == 0)
		{
			pRst = m_vecTables[i];
            break;
		}
	}
    pthread_mutex_unlock(&m_cs);

	return pRst;
}
