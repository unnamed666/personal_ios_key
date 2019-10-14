#ifndef __KDataStream_h__
#define __KDataStream_h__

#if 0
class KStreamReader
{
public:
	KStreamReader();
	~KStreamReader();

	void SetStream(const void* pBuffer, int nSize);
	int ReadBinary(void* pBuffer, int nSize);
	bool IsEnd(void);

private:
	const byte* m_pBuffer;
	int m_nSize;
	int m_nOffset;
};
#endif

class KStreamWriter
{
public:
	KStreamWriter();
	~KStreamWriter();

	void WriteBinary(const void* pBuffer, int nSize);
	void* GetStream(void);
	int GetSize(void);
	int GetCount(void);
	void Clear(void);

protected:
	void ReallocMem(int nSize);

private:
	byte* m_pBuffer;
	int m_nSize;
	int m_nOffset;
	int m_nCount;
};

#endif
