#ifndef UGH_SANDBOX_PRIVATE_H
#define UGH_SANDBOX_PRIVATE_H

#include <string.h>
#include <mach/mach.h>

#ifdef __cplusplus
extern "C"
{
#endif
    enum sandbox_filter_type
    {
        SANDBOX_FILTER_NONE,
        SANDBOX_FILTER_PATH,
        SANDBOX_FILTER_GLOBAL_NAME,
        SANDBOX_FILTER_LOCAL_NAME,
        SANDBOX_FILTER_APPLEEVENT_DESTINATION,
        SANDBOX_FILTER_RIGHT_NAME,
        SANDBOX_FILTER_PREFERENCE_DOMAIN,
        SANDBOX_FILTER_KEXT_BUNDLE_ID,
        SANDBOX_FILTER_INFO_TYPE,
        SANDBOX_FILTER_NOTIFICATION,
    };
    extern const enum sandbox_filter_type SANDBOX_CHECK_NO_REPORT;
    extern const enum sandbox_filter_type SANDBOX_CHECK_CANONICAL;
    int sandbox_check(pid_t pid, const char *operation, enum sandbox_filter_type type, ...);
#ifdef __cplusplus
}
#endif

#endif
