#ifndef FAKE_CORECRYPTO_CCSHA1_H
#define FAKE_CORECRYPTO_CCSHA1_H

#include <CommonCrypto/CommonDigest.h>

#define CCSHA1_OUTPUT_SIZE CC_SHA1_DIGEST_LENGTH

#define ccsha1_di() ((struct ccdigest_info*)0xaa0010)

#endif
