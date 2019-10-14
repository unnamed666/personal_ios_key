#ifndef __KFunction_h__
#define __KFunction_h__

#include <string>
#include "stdafx.h"
#include "CString.h"

class KFunction
{
private:
	static CString m_strFilePath;
public:
	static K_BOOL LoadFileToBuffer(LPCTSTR szPath, LPBYTE* ppBuffer, int* pnSize);
	static K_BOOL LoadFileToBuffer(int &fd, LPBYTE* ppBuffer, int* pnSize);
	static void ReleaseBuffer(LPBYTE pBuffer);
	static K_BOOL WriteBufferToFile(LPCTSTR szFile, LPBYTE pBuffer, int nSize);
	static K_BOOL DeleteFile(LPCTSTR szPath);
	static LPCTSTR GetModulePath();
	static void SetModulePath(LPCTSTR szPath);


};

#endif
