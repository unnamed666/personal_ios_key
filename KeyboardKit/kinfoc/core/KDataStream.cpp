#include "stdafx.h"
#include "KDataStream.h"
#include <cstring>

#if 0
KStreamReader::KStreamReader()
{
	m_pBuffer = NULL;
	m_nSize = 0;
	m_nOffset = 0;
}

KStreamReader::~KStreamReader()
{

}

void KStreamReader::SetStream(const void* pBuffer, int nSize)
{
	m_pBuffer = (const byte*)pBuffer;
	m_nSize = nSize;
	m_nOffset = 0;
}

int KStreamReader::ReadBinary(void* pBuffer, int nSize)
{
	if (nSize > m_nSize - m_nOffset)
		return 0;

	memcpy(pBuffer, m_pBuffer + m_nOffset, nSize);
	m_nOffset += nSize;

	return nSize;
}

bool KStreamReader::IsEnd(void)
{
	return m_nOffset == m_nSize;
}
#endif

KStreamWriter::KStreamWriter()
{
	m_nSize = 1024;
	m_pBuffer = new byte[m_nSize];
	m_nOffset = 0;
	m_nCount = 0;
}

KStreamWriter::~KStreamWriter()
{
	if (m_pBuffer)
		delete[] m_pBuffer;
}

void KStreamWriter::WriteBinary(const void* pBuffer, int nSize)
{
	if (nSize + m_nOffset > m_nSize)
		ReallocMem(m_nSize + nSize + 1024);

	memcpy(m_pBuffer + m_nOffset, pBuffer, nSize);
	m_nOffset += nSize;
	m_nCount++;
}

void* KStreamWriter::GetStream(void)
{
	return m_pBuffer;
}

int KStreamWriter::GetSize(void)
{
	return m_nOffset;
}

void KStreamWriter::ReallocMem(int nSize)
{
	byte* pBuffer = new byte[nSize];

	if (m_pBuffer && m_nOffset)
		memcpy(pBuffer, m_pBuffer, m_nOffset);
	
	if (m_pBuffer)
		delete[] m_pBuffer;

	m_pBuffer = pBuffer;
	m_nSize = nSize;	
}

void KStreamWriter::Clear(void)
{
	m_nOffset = 0;
	m_nCount = 0;
}

int KStreamWriter::GetCount(void)
{
	return m_nCount;
}
