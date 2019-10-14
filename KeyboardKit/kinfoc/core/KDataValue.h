#ifndef __KDataValue_h__
#define __KDataValue_h__

#include <vector>
#include "stdafx.h"
#include "CString.h"

//seperate to : KIntKeyValue, KStringKeyValue
class KKeyValue
{
public:
	KKeyValue(LPCTSTR szKeyName, LPBYTE pBuffer, int nSize, LPCTSTR szValueType);
	KKeyValue(LPCTSTR szKeyName, LPCTSTR szValue, LPCTSTR szValueType);
	
	LPCTSTR GetName();
	LPCTSTR GetType();
	LPCTSTR GetString();
	LPBYTE GetValue();
	int GetSize();
	
private:
	CString m_strName;
	std::vector<byte> m_vecValue;
	CString m_strType; //number, string, binary
};

class KTableValue
{
public:
	KTableValue();
	~KTableValue();

	void SetTableName(LPCTSTR szTableName);
	void SetTableIndex(unsigned short uTableIndex);
	void AddKeyValue(KKeyValue* pKeyValue);

	LPCTSTR GetTableName(void);
	int GetTableIndex(void);
	int GetKeyCount(void);
	KKeyValue* GetKeyValue(int nKeyIndex);
	KKeyValue* GetKeyValue(LPCTSTR szKeyName);

	void Clear(void);

private:
	CString m_strTableName;
	unsigned short m_uTableIndex;
	std::vector<KKeyValue*> m_vecKeys;
};

#endif
