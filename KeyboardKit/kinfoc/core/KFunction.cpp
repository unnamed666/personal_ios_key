#include "stdafx.h"
#include "KFunction.h"
#include <sys/stat.h>
#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>

CString KFunction::m_strFilePath = "/mnt/sdcard/kinfoc/";

K_BOOL KFunction::LoadFileToBuffer(LPCTSTR szPath, LPBYTE* ppBuffer, int* pnSize)
{
	K_BOOL bReturn = FALSE;
//    K_BOOL bRetCode = FALSE;

	int fd = -1;
    struct stat statbuff;
	DWORD dwReadedSize = 0;
	DWORD dwFileSize = 0;
	LPBYTE pBuffer = NULL;

    if(stat(szPath, &statbuff) < 0)
    {
    	goto Exit0;
    }
    else
    {
    	dwFileSize = statbuff.st_size;
    }

	fd = open(szPath, O_RDONLY);

	if (fd == -1)
		goto Exit0;

	pBuffer = new byte[dwFileSize+1];

	dwReadedSize = read(fd, pBuffer, dwFileSize);

	if (dwReadedSize != dwFileSize)
		goto Exit0;

	pBuffer[dwFileSize] = 0;

	*ppBuffer = pBuffer;
	*pnSize = dwFileSize;

	bReturn = TRUE;
Exit0:
	if (fd != -1)
		close(fd);

	return bReturn;
}

K_BOOL KFunction::LoadFileToBuffer(int &fd, LPBYTE* ppBuffer, int* pnSize)
{
	K_BOOL bReturn = FALSE;
//    K_BOOL bRetCode = FALSE;


	DWORD dwReadedSize = 0;
	LPBYTE pBuffer = NULL;

    if (fd == -1)
    	goto Exit0;

    if (*pnSize <= 0)
    	goto Exit0;

	pBuffer = new byte[*pnSize];

	dwReadedSize = read(fd, pBuffer, *pnSize);

	if (dwReadedSize != *pnSize)
		goto Exit0;

	pBuffer[*pnSize] = 0;

	*ppBuffer = pBuffer;

	bReturn = TRUE;

Exit0:
	return bReturn;
}

void KFunction::ReleaseBuffer(LPBYTE pBuffer)
{
	if (pBuffer)
		delete[] pBuffer;
}

K_BOOL KFunction::WriteBufferToFile(LPCTSTR szFile, LPBYTE pBuffer, int nSize)
{
	K_BOOL bReturn = FALSE;
//    K_BOOL bRetCode = FALSE;
	int fd = -1;
//    struct stat statbuff;
	DWORD dwWrittenSize = 0;

	fd = open(szFile, O_WRONLY | O_CREAT);

	dwWrittenSize = write(fd, pBuffer, nSize);

	if (dwWrittenSize != (DWORD)nSize)
		goto Exit0;

	bReturn = TRUE;
Exit0:
	if (fd != -1)
		close(fd);

	return bReturn;
}

K_BOOL KFunction::DeleteFile(LPCTSTR szPath)
{
	return remove(szPath);
}

LPCTSTR KFunction::GetModulePath()
{
	return m_strFilePath;
}

void KFunction::SetModulePath(LPCTSTR szPath)
{
	CString strPath = szPath;
	if (strPath.Right(1) != "/")
		strPath += "/";
	m_strFilePath = strPath;
}

