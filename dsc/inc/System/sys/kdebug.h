#ifndef UGH_SYS_KDEBUG_H
#define UGH_SYS_KDEBUG_H

#include <stdint.h>

#define KDBG_CLASS_MASK         (0xff000000)
#define KDBG_CLASS_OFFSET       (24)
#define KDBG_CLASS_MAX          (0xff)

#define KDBG_SUBCLASS_MASK      (0x00ff0000)
#define KDBG_SUBCLASS_OFFSET    (16)
#define KDBG_SUBCLASS_MAX       (0xff)

#define KDBG_CSC_MASK           (0xffff0000)
#define KDBG_CSC_OFFSET         (KDBG_SUBCLASS_OFFSET)
#define KDBG_CSC_MAX            (0xffff)

#define KDBG_CODE_MASK          (0x0000fffc)
#define KDBG_CODE_OFFSET        (2)
#define KDBG_CODE_MAX           (0x3fff)

#define KDBG_EVENTID_MASK       (0xfffffffc)
#define KDBG_FUNC_MASK          (0x00000003)

#define KDBG_EVENTID(Class, SubClass, Code) \
( \
    (((Class)    &   0xff) << KDBG_CLASS_OFFSET)    | \
    (((SubClass) &   0xff) << KDBG_SUBCLASS_OFFSET) | \
    (((Code)     & 0x3fff) << KDBG_CODE_OFFSET)       \
)

#define KDBG_CODE(Class, SubClass, Code) KDBG_EVENTID(Class, SubClass, Code)

#define DBG_DYLD 31

#ifdef __cplusplus
extern "C"
{
#endif
    extern uint64_t kdebug_trace_string(uint32_t debugid, uint64_t str_id, const char *str);
#ifdef __cplusplus
}
#endif

#endif
