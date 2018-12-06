#ifndef UGH_COMMONDIGESTSPI_H
#define UGH_COMMONDIGESTSPI_H

#include <stdint.h>

enum
{
    kCCDigestNone   = 0,
    kCCDigestSHA1   = 8,
    kCCDigestSHA256 = 10,
};

#ifdef __cplusplus
extern "C"
#endif
int CCDigest(uint32_t algorithm, const uint8_t *data, size_t length, uint8_t *output);

#endif
