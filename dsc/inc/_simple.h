#ifndef UGH__SIMPLE_H
#define UGH__SIMPLE_H

#include <stdarg.h>

#ifdef __cplusplus
#define UGH_EXT extern "C"
#else
#define UGH_EXT
#endif

typedef void* _SIMPLE_STRING;

UGH_EXT void* _simple_salloc(void);
UGH_EXT void  _simple_sfree(void*);
UGH_EXT int   _simple_vsprintf(void*, const char*, va_list);
UGH_EXT char* _simple_string(void*);

#endif
