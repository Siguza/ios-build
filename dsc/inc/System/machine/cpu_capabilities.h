#ifndef UGH_CPU_CAPABILITIES_H
#define UGH_CPU_CAPABILITIES_H

#include <stdint.h>

static uint64_t __siguza_commpage_fake = 0;

#define _COMM_PAGE_BOOTTIME_USEC (&__siguza_commpage_fake)

#endif
