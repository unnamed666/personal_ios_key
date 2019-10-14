//////////////////////////////////////////////////////////////////////////////////////
//
//  FileName    :   CRC32.H
//  Creater     :   Freeway Chen
//  Date        :   2000-6-15 18:25:43
//  Comment     :   Get source code from Zlib Project
//
//////////////////////////////////////////////////////////////////////////////////////

#ifndef CRC32_H
#define CRC32_H

#include "stdafx.h"

// most CRC first value is 0
#ifdef __cplusplus
extern "C"
#else
extern
#endif

uint32_t CRC32(uint32_t CRC, const void *pvBuf, uint32_t uLen);

#ifdef  __cplusplus
inline unsigned CRC32_16BYTES(unsigned CRC, const void *pvBuf);
inline unsigned CRC32_48BYTES(unsigned CRC, const void *pvBuf);
#endif//__cplusplus

#endif  // CRC32_H


