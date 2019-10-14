#ifndef __KDataFormat_h__
#define __KDataFormat_h__

#include <vector>
#include <string>
#include <pthread.h>
#include "stdafx.h"
#include "CString.h"

//type:bit, byte, short, int, int64, string, binary
class KKeyFormat
{
public:
	KKeyFormat(LPCTSTR szName, LPCTSTR szType);

	LPCTSTR GetName(void);
	LPCTSTR GetType(void);

private:
	CString m_strName;
	CString m_strType;
};

//
//tablename:index name:type name:type name:type
//
class KTableFormat
{
public:
	KTableFormat();
	~KTableFormat();

	bool ParseFormat(LPCTSTR szFormat);
	
	unsigned short GetTableIndex(void);
	LPCTSTR GetTableName(void);
	int GetKeyCount(void);
	int GetBitCount(void);
	KKeyFormat* GetKeyFormat(int nKeyIndex);

protected:
	bool ParseKeyNameAndType(CString& strBuffer, CString& strName, CString& strType);

private:
	CString m_strTableName;
	unsigned short m_uTableIndex;
	std::vector<KKeyFormat*> m_vecKeys;
	std::vector<KKeyFormat*> m_vecBitKeys;
};

class KDataFormat
{
public:
	KDataFormat();
	~KDataFormat();

	bool Initialize(void);

	KTableFormat* GetTableFormat(unsigned short uTableIndex);
	KTableFormat* GetTableFormat(LPCTSTR szTableName);

protected:
	//only support ansi format file
	bool LoadFile(LPCTSTR szFileName);
	bool Parse(LPCTSTR szBuffer);
	LPCTSTR GetLine(LPCTSTR pBuffer, CString& strLine);

private:
	std::vector<KTableFormat*> m_vecTables;
    pthread_mutex_t m_cs;
    pthread_mutexattr_t m_attr;
};

#endif
