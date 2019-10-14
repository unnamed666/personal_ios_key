#ifndef __IInfocClient_h__
#define __IInfocClient_h__

class IInfocClient
{
public:
	IInfocClient(){};
	virtual ~IInfocClient(){};

	virtual K_BOOL Initialize(void)=0;
	virtual void Release(void)=0;

	virtual void SetTableName(LPCTSTR szName)=0;
	virtual K_BOOL AddInfo(LPCTSTR szInfo)=0;
	virtual K_BOOL AddInt(LPCTSTR szName, int nValue)=0;
	virtual K_BOOL AddString(LPCTSTR szName, LPCTSTR szValue)=0;
	virtual K_BOOL AddBinary(LPCTSTR szName, LPVOID pBuffer, int nSize)=0;

	virtual K_BOOL Serialize(void)=0;
	virtual void* GetStream(void)=0;
	virtual int GetSize(void)=0;

	virtual void Clear(void)=0;
	virtual int GetError(void)=0;
};

class IInfocReporter
{
public:
	IInfocReporter(){};
	virtual ~IInfocReporter(){};

	virtual K_BOOL Initialize(void)=0;
	virtual void Release(void)=0;

	virtual K_BOOL SetPublicData(LPVOID pBuffer, int nSize)=0;
	virtual K_BOOL AddStream(LPVOID pBuffer, int nSize)=0;

	virtual int GetError(void)=0;
};

#endif
