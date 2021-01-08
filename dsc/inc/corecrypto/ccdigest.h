#ifndef FAKE_CORECRYPTO_CCDIGEST_H
#define FAKE_CORECRYPTO_CCDIGEST_H

#include <stdlib.h>
#include <CommonCrypto/CommonDigest.h>
#include <corecrypto/ccsha1.h>
#include <corecrypto/ccsha2.h>

#define ccdigest_di_decl(di, ctx) \
union \
{ \
    CC_SHA1_CTX sha1; \
    CC_SHA256_CTX sha256; \
    CC_SHA512_CTX sha384; \
} ctx;

#define ccdigest_init(di, ctx) \
( \
    (di == ccsha1_di  ()) ? CC_SHA1_Init  (&ctx.sha1  ) : \
    (di == ccsha256_di()) ? CC_SHA256_Init(&ctx.sha256) : \
    (di == ccsha384_di()) ? CC_SHA384_Init(&ctx.sha384) : \
    (abort(), -1) \
)

#define ccdigest_update(di, ctx, length, data) \
( \
    (di == ccsha1_di  ()) ? CC_SHA1_Update  (&ctx.sha1  , data, length) : \
    (di == ccsha256_di()) ? CC_SHA256_Update(&ctx.sha256, data, length) : \
    (di == ccsha384_di()) ? CC_SHA384_Update(&ctx.sha384, data, length) : \
    (abort(), -1) \
)

#define ccdigest_final(di, ctx, digest) \
( \
    (di == ccsha1_di  ()) ? CC_SHA1_Final  (digest, &ctx.sha1  ) : \
    (di == ccsha256_di()) ? CC_SHA256_Final(digest, &ctx.sha256) : \
    (di == ccsha384_di()) ? CC_SHA384_Final(digest, &ctx.sha384) : \
    (abort(), -1) \
)

#define ccdigest_di_clear(di, ctx) \
do \
{ \
    if     (di == ccsha1_di  ()) ctx.sha1   = {}; \
    else if(di == ccsha256_di()) ctx.sha256 = {}; \
    else if(di == ccsha384_di()) ctx.sha384 = {}; \
    else abort(); \
} while(0)

#endif
