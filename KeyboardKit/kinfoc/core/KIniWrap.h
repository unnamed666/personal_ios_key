#ifndef __KIniWrap_h__
#define __KIniWrap_h__

#include <map>
#include "CString.h"

enum emIniEncoding
{
	emIniEncodingAnsi = 1,
	//emIniEncodingUtf8,
	//emIniEncodingUnicode,
};

class KIniWrap
{
public:
	KIniWrap();
	~KIniWrap();

	K_BOOL LoadFile(LPCTSTR szFileName, int emIniEncode = emIniEncodingAnsi);
	K_BOOL SaveFile(LPCTSTR szFileName, int emIniEncode);
	K_BOOL Parse(LPCWSTR szString);
	void Clear(void);

	int Read(LPCWSTR szAppName, LPCWSTR szKeyName, int nDefault);
	K_BOOL Write(LPCWSTR szAppName, LPCWSTR szKeyName, int nValue);

	LPCWSTR Read(LPCWSTR szAppName, LPCWSTR szKeyName, LPCWSTR szDefault);
	K_BOOL Write(LPCWSTR szAppName, LPCWSTR szKeyName, LPCWSTR szValue);

	DWORD Read(LPCTSTR szAppName, LPCTSTR szKeyName, LPBYTE pBuffer, DWORD dwSize);
	K_BOOL Write(LPCTSTR szAppName, LPCTSTR szKeyName, LPBYTE pBuffer, DWORD dwSize);

	const std::map< CStringW, std::map<CStringW, CStringW> >& ReadAll(void);

	K_BOOL ToString(CStringW& strBuffer);

protected:
	LPCWSTR GetLine(LPCWSTR szBuffer, CStringW& strLine);
	K_BOOL ProcessLine(CStringW& strLine);
	K_BOOL ParseLine(CStringW& strLine, CStringW& strAppName, CStringW& strKeyName, CStringW& strValue);
	K_BOOL AddItem(CStringW& strAppName, CStringW& strKeyName, LPCWSTR szValue);
	K_BOOL BinaryToString(LPBYTE pBuffer, DWORD dwSize, CStringW& strBinStr);
	K_BOOL StringToBinary(CStringW& strBinStr, LPBYTE pBuffer, DWORD dwSize);

private:
	CStringW m_strCurrentAppName;
	std::map< CStringW, std::map<CStringW, CStringW> > m_mapIniData;
};

#endif
