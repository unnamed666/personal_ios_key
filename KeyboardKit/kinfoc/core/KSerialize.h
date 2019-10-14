#ifndef __KSerialize_h__
#define __KSerialize_h__

#include "stdafx.h"
#include "KDataValue.h"
#include "KDataFormat.h"
#include "KDataStream.h"
#include "CString.h"

class KSerialize
{
public:
	KSerialize();
	~KSerialize();

	void SetDataFormat(KDataFormat* pDataFormat);
	void SetTableName(LPCTSTR szName);
	void AddInt(LPCTSTR szName, __int64 nValue);
	void AddString(LPCTSTR szName, LPCTSTR szValue);
	void AddBinary(LPCTSTR szName, LPVOID pBuffer, int nSize);

	bool Serialize(void);
	void* GetBuffer(void);
	int GetSize(void);

	void Clear(void);

protected:
	bool WriteOneKey(KKeyFormat* pKeyFormat);
	bool WriteAllBits(byte* pBuffer, int nSize);
	void WriteOneBit(byte* pBuffer, int nOffset, byte value);
	void EncodeString(byte* pBuffer, int nSize);
	K_BOOL StringToBinary(CStringW& strBinStr, LPBYTE pBuffer, DWORD dwSize);

private:
	int m_nSerialized;
	KDataFormat* m_pDataFormat;
	KTableValue m_tableValue;
	KStreamWriter m_streamWriter;
	std::vector<byte> m_vecBits;
};

#endif
