#ifndef CORESYMBOL_SHIT
#define CORESYMBOL_SHIT

#include <mach/mach.h>

#define kCSNow 0x8000000000000000

typedef struct _CSSymbolicatorRef_s *CSSymbolicatorRef;
typedef struct _CSSymbolRef_s *CSSymbolRef;
typedef struct _CSSourceInfoRef_s *CSSourceInfoRef;

CSSymbolicatorRef CSSymbolicatorCreateWithMachKernel(void);
CSSymbolRef CSSymbolicatorGetSymbolWithAddressAtTime(CSSymbolicatorRef, mach_vm_address_t, uint64_t flags);
CSSourceInfoRef CSSymbolicatorGetSourceInfoWithAddressAtTime(CSSymbolicatorRef, mach_vm_address_t, uint64_t flags);
const char* CSSymbolGetName(CSSymbolRef);
const char* CSSourceInfoGetPath(CSSourceInfoRef);
unsigned int CSSourceInfoGetLineNumber(CSSourceInfoRef);

#endif
