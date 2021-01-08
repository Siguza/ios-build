#ifndef UGH__SIMPLE_H
#define UGH__SIMPLE_H

#include <stdarg.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef void* _SIMPLE_STRING;

void*       _simple_salloc(void);
void        _simple_sfree(void*);
int         _simple_vsprintf(void*, const char*, va_list);
char*       _simple_string(void*);
const char* _simple_getenv(const char*[], const char*);

#ifdef __cplusplus
}
#endif

#endif
