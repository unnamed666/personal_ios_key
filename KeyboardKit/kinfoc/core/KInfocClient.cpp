#include "stdafx.h"
#include <unistd.h>
#include "KFunction.h"
#include "KSerialize.h"
#include "KSingleton.h"
#include "KDataFormat.h"
#include "KInfocClient.h"
#include "crc32.h"

bool g_bInfocDebugFlag = false;

KInfocClient::KInfocClient()
{	
	m_pDataFormat = NULL;
}

KInfocClient::~KInfocClient()
{
	return;
}

K_BOOL KInfocClient::Initialize(void)
{
	K_BOOL bReturn = FALSE;

	KDataFormat s_dataFormat;

	m_pDataFormat = KSingleton<KDataFormat>::Instance();
	if (!m_pDataFormat) goto Exit0;

	m_serialize.SetDataFormat(m_pDataFormat);

        if (0 == ::access("/sdcard/__test_infoc__", F_OK))
        {
            g_bInfocDebugFlag = true;
        }

	bReturn = TRUE;
	
Exit0:

	return bReturn;
}

void KInfocClient::Release(void)
{
	delete this;
}

void KInfocClient::SetTableName(LPCTSTR szName)
{
	m_serialize.SetTableName(szName);
	m_strTableName = szName;
}

K_BOOL KInfocClient::AddInfo(LPCTSTR szInfo)
{
	K_BOOL bReturn = FALSE;

	bReturn = ParseFormat(szInfo);

	return bReturn;
}

K_BOOL KInfocClient::AddInt(LPCTSTR szName, int nValue)
{
	m_serialize.AddInt(szName, nValue);
	return TRUE;
}

K_BOOL KInfocClient::AddString(LPCTSTR szName, LPCTSTR szValue)
{
	m_serialize.AddString(szName, szValue);
	return TRUE;
}

K_BOOL KInfocClient::AddBinary(LPCTSTR szName, LPVOID pBuffer, int nSize)
{
	m_serialize.AddBinary(szName, pBuffer, nSize);
	return TRUE;
}

void KInfocClient::Clear(void)
{
	m_strTableName.Empty();
	m_serialize.Clear();
}

K_BOOL KInfocClient::ParseFormat(LPCTSTR szBuffer)
{
	K_BOOL bReturn = FALSE;
	K_BOOL bRetCode = FALSE;
	LPCTSTR pszStart = NULL;
	LPCTSTR pszEnd = NULL;
	CString strKeyAndValue;
	CString strKey;
	CString strValue;

	pszStart = szBuffer;
	
	do 
	{
		strKey.Empty();
		strValue.Empty();
		strKeyAndValue.Empty();

		pszEnd = _tcschr(pszStart, _T('&'));
		if (pszEnd)
		{
			strKeyAndValue.Append(pszStart, (int)(pszEnd - pszStart));
		}
		else
		{
			strKeyAndValue.Append(pszStart);
		}

		if (!strKeyAndValue.IsEmpty())
		{
			bRetCode = ParseKeyAndValue(strKeyAndValue, strKey, strValue);

			if (!bRetCode) goto Exit0;

			m_serialize.AddString(strKey, strValue);
		}
		
		if (pszEnd == NULL) break;

		pszStart = pszEnd + 1;

	} while (true);

	bReturn = TRUE;
	
Exit0:
	return bReturn;
}

K_BOOL KInfocClient::ParseKeyAndValue(LPCTSTR szBuffer, CString& strKey, CString& strValue)
{
	K_BOOL bReturn = FALSE;
	LPCTSTR pszEqualPos = NULL;

	strKey.Empty();
	strValue.Empty();

	pszEqualPos = _tcschr(szBuffer, _T('='));
	if (!pszEqualPos) goto Exit0;

	strKey.Append(szBuffer, (int)(pszEqualPos - szBuffer));
	strValue.Append(pszEqualPos + 1);

	strKey.Trim();
	strValue.Trim();

	bReturn = TRUE;
Exit0:
	return bReturn;
}

void* KInfocClient::GetStream(void)
{
	return m_serialize.GetBuffer();
}

int KInfocClient::GetSize(void)
{
	return m_serialize.GetSize();
}

int KInfocClient::GetError(void)
{
	return 0;
}

K_BOOL KInfocClient::Serialize(void)
{
	K_BOOL bRetCode = FALSE;

	bRetCode = m_serialize.Serialize();

	return bRetCode;
}

K_BOOL KInfocClient::WriteHeadInfo(KStreamWriter& stream, int nInfoCount, int nProductId)
{
	int nSize = 0;
	LPBYTE pBuffer = NULL;
	PInfocPackHeader pPackHead = NULL;

	nSize = stream.GetSize();
	pBuffer = (LPBYTE)stream.GetStream();
	pPackHead = (PInfocPackHeader)pBuffer;

	unsigned int uCrc32 = CRC32(0, pBuffer + sizeof(InfocPackHeader), nSize - sizeof(InfocPackHeader));
	pPackHead->size = nSize;
	pPackHead->version = 1;
	pPackHead->product = nProductId;
	pPackHead->count = nInfoCount;
	pPackHead->crc32 = uCrc32;

	return TRUE;
}
