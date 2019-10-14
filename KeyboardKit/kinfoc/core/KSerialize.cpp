#include "stdafx.h"

//#include <android/log.h>

#include "KSerialize.h"

extern bool g_bInfocDebugFlag;

KSerialize::KSerialize()
{
	m_pDataFormat = NULL;
	m_nSerialized = -1;
}

KSerialize::~KSerialize()
{

}

void KSerialize::SetDataFormat(KDataFormat* pDataFormat)
{
	m_pDataFormat = pDataFormat;
}

void KSerialize::SetTableName(LPCTSTR szName)
{
	m_tableValue.SetTableName(szName);
}

void KSerialize::AddString(LPCTSTR szName, LPCTSTR szValue)
{
	KKeyValue* pKeyValue = new KKeyValue(szName, szValue, _T("string"));
	m_tableValue.AddKeyValue(pKeyValue);

	m_nSerialized = -1;
}

void KSerialize::AddBinary(LPCTSTR szName, LPVOID pBuffer, int nSize)
{
	KKeyValue* pKeyValue = new KKeyValue(szName, (LPBYTE)pBuffer, nSize, _T("binary"));
	m_tableValue.AddKeyValue(pKeyValue);

	m_nSerialized = -1;
}

void KSerialize::AddInt(LPCTSTR szName, __int64 nValue)
{
	CString strValue;
	strValue.Format(_T("%lld"), nValue);
	
	KKeyValue* pKeyValue = new KKeyValue(szName, strValue, _T("number"));
	m_tableValue.AddKeyValue(pKeyValue);

	m_nSerialized = -1;
}

void KSerialize::Clear(void)
{
	m_tableValue.Clear();
	m_streamWriter.Clear();
	m_vecBits.clear();
	m_nSerialized = -1;
}

bool KSerialize::Serialize(void)
{
	bool bReturn = false;
	bool bRetCode = false;
	KKeyFormat* pKeyFormat = NULL;
	KTableFormat* pTableFormat = NULL;
	std::vector<byte> vecBitBuffer;
	int nByteCount = 0;
	int nKeyCount = 0;
	unsigned short uTableIndex = 0;

	if (m_nSerialized != -1)
		return m_nSerialized;

	m_streamWriter.Clear();

	pTableFormat = m_pDataFormat->GetTableFormat(m_tableValue.GetTableName());
	if (!pTableFormat) goto Exit0;

	uTableIndex = pTableFormat->GetTableIndex();
	m_streamWriter.WriteBinary(&uTableIndex, sizeof(uTableIndex));

	nByteCount = (pTableFormat->GetBitCount() + 7) / 8;
	if (nByteCount)
	{
		vecBitBuffer.resize(nByteCount, 0);
		m_streamWriter.WriteBinary(&vecBitBuffer[0], nByteCount);
	}

	nKeyCount = pTableFormat->GetKeyCount();
        if (nKeyCount != m_tableValue.GetKeyCount())
        {
//            ::__android_log_print(ANDROID_LOG_WARN, "KInfoc", "The data section count is not equal! table:%s, count in format:%d, count in data:%d.", m_tableValue.GetTableName(), nKeyCount, m_tableValue.GetKeyCount());
            if (g_bInfocDebugFlag)
            {
                goto Exit0;
            }
        }

	for (int i = 0; i < nKeyCount; i++)
	{
		pKeyFormat = pTableFormat->GetKeyFormat(i);
		bRetCode = WriteOneKey(pKeyFormat);
		if (!bRetCode) goto Exit0;
	}

	if (nByteCount)
	{
		LPBYTE pBuffer = (LPBYTE)m_streamWriter.GetStream() + sizeof(uTableIndex);
		bRetCode = WriteAllBits(pBuffer, nByteCount);
		if (!bRetCode) goto Exit0;
	}

	bReturn = true;

Exit0:
	m_nSerialized = bReturn;
	return bReturn;
}

bool KSerialize::WriteOneKey(KKeyFormat* pKeyFormat)
{
	bool bReturn = false;
	LPCTSTR pszType = pKeyFormat->GetType();
	KKeyValue* pKeyValue = m_tableValue.GetKeyValue(pKeyFormat->GetName());

	if (!pKeyValue) goto Exit0;

	if (_tcscmp(pszType, _T("bit")) == 0)
	{
		byte value = _ttoi(pKeyValue->GetString());

		m_vecBits.push_back(value);
	}
	else if (_tcscmp(pszType, _T("byte")) == 0)
	{
		byte value = _ttoi(pKeyValue->GetString());

		m_streamWriter.WriteBinary(&value, sizeof(value));
	}
	else if (_tcscmp(pszType, _T("short")) == 0)
	{
		short value = _ttoi(pKeyValue->GetString());

		m_streamWriter.WriteBinary(&value, sizeof(value));
	}
	else if (_tcscmp(pszType, _T("int")) == 0)
	{
		int value = _ttoi(pKeyValue->GetString());

		m_streamWriter.WriteBinary(&value, sizeof(value));
	}
	else if (_tcscmp(pszType, _T("int64")) == 0)
	{
		__int64 value = _ttoi64(pKeyValue->GetString());

		m_streamWriter.WriteBinary(&value, sizeof(value));
	}
	else if (_tcscmp(pszType, _T("string")) == 0)
	{
		unsigned short uSize = 0;

		const char *szTmp = pKeyValue->GetString();

		uSize = strlen(szTmp);

		LPBYTE pBuffer = (LPBYTE)szTmp;
		EncodeString(pBuffer, uSize);
		m_streamWriter.WriteBinary(&uSize, sizeof(uSize));
		m_streamWriter.WriteBinary(pBuffer, uSize);
	}
	else if (_tcscmp(pszType, _T("binary")) == 0)
	{
		if (_tcscmp(pKeyValue->GetType(), _T("binary")) == 0)
		{
			unsigned short uSize = 0;
			LPBYTE pBuffer = NULL;

			pBuffer = pKeyValue->GetValue();
			uSize = pKeyValue->GetSize();

			m_streamWriter.WriteBinary(&uSize, sizeof(uSize));
			if (uSize)
				m_streamWriter.WriteBinary(pBuffer, uSize);
		}
		else if (_tcscmp(pKeyValue->GetType(), _T("string")) == 0)
		{
			unsigned short uSize = 0;
			CStringW strData = pKeyValue->GetString();
			LPBYTE lpBinayData = NULL;
			
			uSize = strData.GetLength()/2;

			lpBinayData = new BYTE[uSize];
			if (lpBinayData == NULL) goto Exit0;

			memset(lpBinayData, 0, uSize);
			StringToBinary(strData, lpBinayData, uSize);

			m_streamWriter.WriteBinary(&uSize, sizeof(uSize));
			if (uSize)
				m_streamWriter.WriteBinary(lpBinayData, uSize);

			delete []lpBinayData;
		}
	}
	else
	{
		goto Exit0;
	}
	
	bReturn = true;
Exit0:
	return bReturn;
}

void KSerialize::WriteOneBit(byte* pBuffer, int nOffset, byte value)
{
	int nByteOffset = nOffset / 8;
	int nBitOffset = nOffset % 8;

	if (value)
	{
		pBuffer[nByteOffset] |= (1 << nBitOffset);
	}
	else
	{
		pBuffer[nByteOffset] &= ~(1 << nBitOffset);;
	}
}

bool KSerialize::WriteAllBits(byte* pBuffer, int nSize)
{
	ZeroMemory(pBuffer, nSize);

	for (size_t i = 0; i < m_vecBits.size(); i++)
	{
		WriteOneBit(pBuffer, i, m_vecBits[i]);
	}
	
Exit0:
	return true;
}

void* KSerialize::GetBuffer(void)
{
	return m_streamWriter.GetStream();
}

int KSerialize::GetSize(void)
{
	return m_streamWriter.GetSize();
}

void KSerialize::EncodeString(byte* pBuffer, int nSize)
{
	byte Mask = 0x88;
	for (int i = 0; i < nSize; i++)
	{
		pBuffer[i] ^= Mask;
	}
}

K_BOOL KSerialize::StringToBinary(CStringW& strBinStr, LPBYTE pBuffer, DWORD dwSize)
{
	K_BOOL bReturn = FALSE;
	LPCTSTR pString = strBinStr;
	BYTE btTemp;

	if (strBinStr.GetLength() % 2 != 0 ||
		strBinStr.GetLength() / 2 > dwSize)
		goto Exit0;

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
