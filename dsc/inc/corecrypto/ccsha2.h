#ifndef FAKE_CORECRYPTO_CCSHA2_H
#define FAKE_CORECRYPTO_CCSHA2_H

#include <CommonCrypto/CommonDigest.h>

#define CCSHA256_OUTPUT_SIZE CC_SHA256_DIGEST_LENGTH
#define CCSHA384_OUTPUT_SIZE CC_SHA384_DIGEST_LENGTH

#define ccsha256_di() ((struct ccdigest_info*)0xaa0020)
#define ccsha384_di() ((struct ccdigest_info*)0xaa0030)

#endif
