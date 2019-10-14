/**
 * 预定义头文件
 * 为了方便起见文件名使用VC预编译头文件名称
 * @author singun
 */

/**
 * 类型定义
 * 统一使用ANSI编码
 */

#define TRUE			1
#define FALSE			0

#define __T(x)			x
#define _T(x)			__T(x)
#define _tcstok			strtok
#define _ttoi			atoi
#define _ttoi64			atoll
#define _tcstoul		strtoul
#define _tcschr			strchr
#define _tcslen			strlen
#define _tcsicmp		strcasecmp
#define _tcscmp			strcmp
#define _tcschr			strchr
#define _taccess		access
#define _tcsncpy		strncpy
#define _stprintf		sprintf
#define _tcscspn		strcspn

#define far
#define near

typedef const char* 	LPCTSTR;
typedef char* 			LPTSTR;
typedef const char* 	LPCSTR;
typedef char* 			LPSTR;
typedef int 			K_BOOL;
typedef char 			TCHAR;
typedef unsigned int 	UINT;
typedef void*			LPVOID;
typedef unsigned int	DWORD;
typedef unsigned short	WORD;
typedef unsigned char	byte;
typedef unsigned char	BYTE;
typedef BYTE far*		LPBYTE;
typedef BYTE*			PBYTE;
typedef LPTSTR			LPWSTR;
typedef LPCTSTR			LPCWSTR;
typedef LPSTR			PCHAR;
typedef char			WCHAR;

typedef long long		__int64;
typedef int             int32_t;
typedef unsigned int    uint32_t;

#define ZeroMemory(Destination,Length)		memset((Destination), 0, (Length))

