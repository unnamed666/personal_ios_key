#include "stdafx.h"
#include <fcntl.h>
#include <unistd.h>
#include "KIniWrap.h"
#include "KFunction.h"

KIniWrap::KIniWrap()
{

}

KIniWrap::~KIniWrap()
{

}

K_BOOL KIniWrap::LoadFile(LPCTSTR szFileName, int emIniEncode /* = emIniEncodingUnicode */)
{
	K_BOOL bReturn = FALSE;
	K_BOOL bRetCode = FALSE;
	LPBYTE pBuffer = NULL;
//	DWORD dwSize = 0;
	int nSize = 0;
	CStringW strBuffer;

	this->Clear();

	bRetCode = KFunction::LoadFileToBuffer(szFileName, /*(LPVOID*)*/&pBuffer, &nSize);
	if (!bRetCode || !pBuffer || nSize < 3)
		goto Exit0;

	switch (emIniEncode)
	{
	case emIniEncodingAnsi:
		strBuffer = (LPCSTR)pBuffer;
		break;
		/*
	case emIniEncodingUnicode:
		strBuffer.Append((LPCWSTR)pBuffer);
		break;


	case emIniEncodingUtf8:
		USES_CONVERSION;
		strBuffer = A2W_CP((LPCSTR)(pBuffer), CP_UTF8);
		break;*/
	}

	if (strBuffer.IsEmpty())
		goto Exit0;

	bReturn = Parse(strBuffer);

Exit0:
	KFunction::ReleaseBuffer(pBuffer);
	return bReturn;
}

K_BOOL KIniWrap::Parse(LPCWSTR szString)
{
	K_BOOL bReturn = FALSE;
	K_BOOL bRetCode = FALSE;
//    K_BOOL bEnd = FALSE;
	CStringW strLine;
	LPCWSTR pOffset = szString;

	pOffset = _tcschr(szString, _T('['));
	if (!pOffset) goto Exit0;

	do 
	{
		pOffset = GetLine(pOffset, strLine);
		
		if (strLine.IsEmpty()) continue;

		bRetCode = ProcessLine(strLine);

		if (!bRetCode) goto Exit0;

	} while (pOffset);

	bReturn = TRUE;

Exit0:
	return bReturn;
}

LPCWSTR KIniWrap::GetLine(LPCWSTR szBuffer, CStringW& strLine)
{
	LPCWSTR pEnd = NULL;

	strLine.Empty();

	pEnd = _tcschr(szBuffer, _T('\n'));
	if (!pEnd)
	{
		strLine.Append(szBuffer);
        strLine.Trim();
	}
	else
	{
		strLine.Append(szBuffer, pEnd - szBuffer);
        strLine.Trim();

		pEnd++;
	}

	return pEnd;
}

K_BOOL KIniWrap::ProcessLine(CStringW& strLine)
{
	K_BOOL bReturn = TRUE;

	strLine.Trim();

	if (!strLine.IsEmpty())
	{
		CStringW strAppName;
		CStringW strKeyName;
		CStringW strValue;

		bReturn = ParseLine(strLine, strAppName, strKeyName, strValue);

		if (!bReturn) goto Exit0;

		if (strAppName.IsEmpty() && strKeyName.IsEmpty())
		{
			bReturn = FALSE;
			goto Exit0;
		}

		if (!strAppName.IsEmpty())
			m_strCurrentAppName = strAppName;

		if (!strKeyName.IsEmpty())
		{
			AddItem(m_strCurrentAppName, strKeyName, strValue);
		}
	}
	
Exit0:
	return bReturn;
}

K_BOOL KIniWrap::ParseLine(CStringW& strLine, CStringW& strAppName, CStringW& strKeyName, CStringW& strValue)
{
	K_BOOL bReturn = FALSE;

	strAppName.Empty();
	strKeyName.Empty();
	strValue.Empty();

//    int nStartPos = 0;
//    int nEndPos = 0;

	if (strLine.GetAt(0) == _T('[') &&
		strLine.GetAt(strLine.GetLength() - 1) == _T(']'))
	{
		strAppName = strLine.Mid(1, strLine.GetLength() - 2);
		strAppName.TrimLeft(_T(' '));
		strAppName.TrimRight(_T(' '));

		if (strAppName.IsEmpty())
			goto Exit0;

	}
	else
	{
		int nPos = strLine.Find(_T('='));
		if (nPos == -1) goto Exit0;

		strKeyName = strLine.Left(nPos);
		strValue = strLine.Right(strLine.GetLength() - nPos - 1);

		strKeyName.TrimRight(_T(' '));
		strValue.TrimLeft(_T(' '));

		if (strKeyName.IsEmpty())
			goto Exit0;
	}

	bReturn = TRUE;

Exit0:
	return bReturn;
}

K_BOOL KIniWrap::AddItem(CStringW& strAppName, CStringW& strKeyName, LPCWSTR szValue)
{
	std::map<CStringW, std::map< CStringW, CStringW> >::iterator iterApp;
	std::map<CStringW, CStringW>::iterator iterKey;

	strAppName.MakeLower();
	strKeyName.MakeLower();

	iterApp = m_mapIniData.find(strAppName);
	if (iterApp != m_mapIniData.end())
	{
		std::map<CStringW, CStringW>& mapKeys = iterApp->second;

		iterKey = mapKeys.find(strKeyName);
		if (iterKey != mapKeys.end())
		{
			iterKey->second = szValue;
		}
		else
		{
			mapKeys.insert(std::make_pair(strKeyName, szValue));
		}
	}
	else
	{
		std::map<CStringW, CStringW> mapKeys;
		mapKeys.insert(std::make_pair(strKeyName, szValue));
		m_mapIniData.insert(std::make_pair(strAppName, mapKeys));
	}

	return TRUE;
}

void KIniWrap::Clear()
{
	m_mapIniData.clear();
}

int KIniWrap::Read(LPCWSTR szAppName, LPCWSTR szKeyName, int nDefault)
{
	int nReturn = nDefault;
	CStringW strAppName(szAppName);
	CStringW strKeyName(szKeyName);
	std::map<CStringW, CStringW>::iterator iterKey;
	std::map<CStringW, std::map< CStringW, CStringW> >::iterator iterApp;
	
	strAppName.MakeLower();
	strKeyName.MakeLower();

	iterApp = m_mapIniData.find(strAppName);

	if (iterApp != m_mapIniData.end())
	{
		std::map<CStringW, CStringW>& mapKeys = iterApp->second;

		iterKey = mapKeys.find(strKeyName);

		if (iterKey != iterApp->second.end())
		{
			nReturn = _ttoi(iterKey->second.GetBuffer());
		}
	}

	return nReturn;	
}

K_BOOL KIniWrap::Write(LPCWSTR szAppName, LPCWSTR szKeyName, int nValue)
{
	CStringW strAppName(szAppName);
	CStringW strKeyName(szKeyName);
	CStringW strValue;

	strValue.Format(_T("%d"), nValue);

	return AddItem(strAppName, strKeyName, strValue);
}

LPCWSTR KIniWrap::Read(LPCWSTR szAppName, LPCWSTR szKeyName, LPCWSTR szDefault)
{
	LPCWSTR lpszReturn = szDefault;
	CStringW strAppName(szAppName);
	CStringW strKeyName(szKeyName);
	std::map<CStringW, CStringW>::iterator iterKey;
	std::map<CStringW, std::map< CStringW, CStringW> >::iterator iterApp;

	strAppName.MakeLower();
	strKeyName.MakeLower();

	iterApp = m_mapIniData.find(strAppName);
	if (iterApp != m_mapIniData.end())
	{
		std::map<CStringW, CStringW>& mapKeys = iterApp->second;

		iterKey = mapKeys.find(strKeyName);
		if (iterKey != mapKeys.end())
		{
			lpszReturn = (LPCWSTR)iterKey->second;
		}
	}

	return lpszReturn;
}

K_BOOL KIniWrap::Write(LPCWSTR szAppName, LPCWSTR szKeyName, LPCWSTR szValue)
{
	CStringW strAppName(szAppName);
	CStringW strKeyName(szKeyName);

	return AddItem(strAppName, strKeyName, szValue);
}

const std::map<CStringW, std::map< CStringW, CStringW> >& KIniWrap::ReadAll(void)
{
	return m_mapIniData;
}

K_BOOL KIniWrap::SaveFile(LPCTSTR szFileName, int emIniEncode)
{
	K_BOOL bReturn = FALSE;
//    K_BOOL bRetCode = FALSE;
	int fd = -1;
	DWORD dwWrited = 0;
	CStringW strBuffer;
	CStringA strBufferA;
	PBYTE pBuffer = NULL;
	DWORD dwBufferSize = 0;

	fd = open(szFileName, O_WRONLY | O_CREAT);
	if(fd == -1)
		goto Exit0;

	ToString(strBuffer);

	switch (emIniEncode)
	{

	case emIniEncodingAnsi:
		{
			//USES_CONVERSION;
			//strBufferA = W2A(strBuffer);
			strBufferA = strBuffer;
			pBuffer = (PBYTE)(LPCSTR)strBufferA;
			dwBufferSize = strBufferA.GetLength();
		}
		break;
		/*
	case emIniEncodingUtf8:
		{
			BYTE szUtf8Header[3] = {0xEF, 0xBB, 0xBF};
			bRetCode = WriteFile(hFile, szUtf8Header, 3, &dwWrited, NULL);
			if (!bRetCode || dwWrited != 3)
				goto Exit0;

			USES_CONVERSION;
			strBufferA = W2A_CP(strBuffer, CP_UTF8);
			pBuffer = (PBYTE)(LPCSTR)strBufferA;
			dwBufferSize = strBufferA.GetLength();
		}
		break;
	case emIniEncodingUnicode:
		{
			BYTE szUnicodeHeader[2] = {0xFF, 0xFE};
			bRetCode = WriteFile(hFile, szUnicodeHeader, 2, &dwWrited, NULL);
			if (!bRetCode || dwWrited != 2)
				goto Exit0;

			pBuffer = (PBYTE)(LPCWSTR)strBuffer;
			dwBufferSize = strBuffer.GetLength() * sizeof(WCHAR);
		}
		break;*/
	}

	//bRetCode = WriteFile(hFile, pBuffer, dwBufferSize, &dwWrited, NULL);
	dwWrited = write(fd, pBuffer, dwBufferSize);
	if (dwWrited != dwBufferSize)
		goto Exit0;
	
	bReturn = TRUE;
Exit0:
	if(fd == -1)
		close(fd);

	return bReturn;
}

K_BOOL KIniWrap::ToString(CStringW& strBuffer)
{
	std::map< CStringW, std::map<CStringW, CStringW> >::const_iterator iterApp;
	std::map<CStringW, CStringW>::const_iterator iterKey;

	strBuffer.Empty();
	for (iterApp = m_mapIniData.begin(); iterApp != m_mapIniData.end(); iterApp++)
	{
		const std::map<CStringW, CStringW>& mapKeys = iterApp->second;

		strBuffer.AppendChar(_T('['));
		strBuffer += iterApp->first;
		strBuffer.AppendChar(_T(']'));
		strBuffer.AppendChar(_T('\r'));
		for (iterKey = mapKeys.begin(); iterKey != mapKeys.end(); iterKey++)
		{
			strBuffer += iterKey->first;
			strBuffer.AppendChar(_T('='));
			strBuffer += iterKey->second;
			strBuffer.AppendChar(_T('\r'));
		}
	}

	return TRUE;
}

DWORD KIniWrap::Read(LPCTSTR szAppName, LPCTSTR szKeyName, LPBYTE pBuffer, DWORD dwSize)
{
	DWORD dwRetSize = 0;
	CStringW strAppName(szAppName);
	CStringW strKeyName(szKeyName);
	std::map<CStringW, CStringW>::iterator iterKey;
	std::map<CStringW, std::map< CStringW, CStringW> >::iterator iterApp;

	strAppName.MakeLower();
	strKeyName.MakeLower();

	iterApp = m_mapIniData.find(strAppName);
	if (iterApp != m_mapIniData.end())
	{
		std::map<CStringW, CStringW>& mapKeys = iterApp->second;

		iterKey = mapKeys.find(strKeyName);
		if (iterKey != mapKeys.end())
		{
			CStringW& strBinStr = iterKey->second;
			dwRetSize = strBinStr.GetLength() / 2;
			if (dwRetSize <= dwSize)
			{
				if (!StringToBinary(strBinStr, pBuffer, dwRetSize))
					dwRetSize = 0;
			}
		}
	}

	return dwRetSize;
}

K_BOOL KIniWrap::Write(LPCTSTR szAppName, LPCTSTR szKeyName, LPBYTE pBuffer, DWORD dwSize)
{
	CStringW strAppName(szAppName);
	CStringW strKeyName(szKeyName);
	CStringW strValue;

	BinaryToString(pBuffer, dwSize, strValue);

	return AddItem(strAppName, strKeyName, strValue);
}

K_BOOL KIniWrap::BinaryToString(LPBYTE pBuffer, DWORD dwSize, CStringW& strBinStr)
{
	WCHAR szBuffer[5];

	strBinStr.Empty();

	for (DWORD i = 0; i < dwSize; i++)
	{
		_stprintf(szBuffer, _T("%02x"), pBuffer[i]);
		strBinStr += szBuffer;
	}

	return TRUE;
}

K_BOOL KIniWrap::StringToBinary(CStringW& strBinStr, LPBYTE pBuffer, DWORD dwSize)
{
	K_BOOL bReturn = FALSE;

	LPCTSTR pString = NULL;
	BYTE btTemp;

	if (strBinStr.GetLength() % 2 != 0 ||
		strBinStr.GetLength() / 2 > dwSize)
		goto Exit0;

	pString = strBinStr;

	for (int i = 0; i < strBinStr.GetLength(); i++)
	{
		if (pString[i] >= _T('0') && pString[i] <= _T('9'))
			btTemp = pString[i] - _T('0');
		else if (pString[i] >= _T('a') && pString[i] <= _T('f'))
			btTemp = pString[i] - _T('a') + 10;
		else if (pString[i] >= _T('A') && pString[i] <= _T('F'))
			btTemp = pString[i] - _T('A') + 10;
		else
			goto Exit0;

		pBuffer[i / 2] = btTemp << 4;

		i++;
		if (pString[i] >= _T('0') && pString[i] <= _T('9'))
			btTemp = pString[i] - _T('0');
		else if (pString[i] >= _T('a') && pString[i] <= _T('f'))
			btTemp = pString[i] - _T('a') + 10;
		else if (pString[i] >= _T('A') && pString[i] <= _T('F'))
			btTemp = pString[i] - _T('A') + 10;
		else
			goto Exit0;

		pBuffer[i / 2] += btTemp;
	}
	
	bReturn = TRUE;
Exit0:
	return bReturn;
}
