#ifndef __KInfocClient_h__
#define __KInfocClient_h__

#include <list>
#include "KSerialize.h"
#include "KDataFormat.h"
#include "KIniWrap.h"
#include "IInfocInterface.h"

#pragma pack(push)
#pragma pack (1)
typedef struct tagInfocPackHeader
{
	unsigned short size;
	unsigned char version;
	unsigned char product;
	unsigned short count;
	unsigned int crc32;
}InfocPackHeader, *PInfocPackHeader;
#pragma pack(pop)

class KInfocClient : public IInfocClient
{
public:
	KInfocClient();
	virtual ~KInfocClient();

	virtual K_BOOL Initialize(void);
	virtual void Release(void);

	virtual void SetTableName(LPCTSTR szName);
	virtual K_BOOL AddInfo(LPCTSTR szInfo);
	virtual K_BOOL AddInt(LPCTSTR szName, int nValue);
	virtual K_BOOL AddString(LPCTSTR szName, LPCTSTR szValue);
	virtual K_BOOL AddBinary(LPCTSTR szName, LPVOID pBuffer, int nSize);
	
	virtual K_BOOL Serialize(void);
	virtual void* GetStream(void);
	virtual int GetSize(void);

	virtual void Clear(void);
	virtual int GetError(void);

	K_BOOL WriteHeadInfo(KStreamWriter& stream, int nInfoCount, int nProductId);

protected:
	K_BOOL ParseFormat(LPCTSTR szBuffer);
	K_BOOL ParseKeyAndValue(LPCTSTR szBuffer, CString& strKey, CString& strValue);

private:
	CString m_strTableName;
	KDataFormat* m_pDataFormat;
	KSerialize m_serialize;
};

#endif
