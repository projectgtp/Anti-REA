/* Anti-REA v1.0 — L49 native integrity gate (reagate).
 *
 * A tiny JNI library: SHA-256 over bytes given by the Java side,
 * constant-time compared with the expected hex. The comparison happens
 * in native code, so patching one Java boolean does not defeat it.
 * It is still a GATE, not a proof — a determined attacker with root
 * can patch the .so or hook the JNI call. Server checks remain the
 * real enforcement.
 *
 * Build (arm64-v8a, NDK clang — see runtime/NOTES.md for the L49 row):
 *   $NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/clang \
 *       --target=aarch64-linux-android21 -fPIC -shared -O2 \
 *       -I $NDK/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/include \
 *       reagate.c -o libreagate.so
 *
 * Host logic test (same file, no Android needed):
 *   gcc -DREA_GATE_TEST_MAIN reagate.c -o reagate-host-test
 *   ./reagate-host-test selftest            # SHA-256 known vectors
 *   ./reagate-host-test <file> <hex>       # gate over a file
 *
 * SHA-256 below is a from-scratch implementation of FIPS 180-4 (no
 * third-party code, no OpenSSL dependency — the NDK has no libcrypto
 * guarantee for app .so files).
 */
#include <stdint.h>
#include <string.h>

#ifdef __ANDROID__
#include <jni.h>
#endif

#define REAGATE_VERSION "reagate-1"

/* ------------------------------------------------------------------ */
/* SHA-256 (FIPS 180-4)                                               */
/* ------------------------------------------------------------------ */

static const uint32_t k256[64] = {
    0x428a2f98u, 0x71374491u, 0xb5c0fbcfu, 0xe9b5dba5u,
    0x3956c25bu, 0x59f111f1u, 0x923f82a4u, 0xab1c5ed5u,
    0xd807aa98u, 0x12835b01u, 0x243185beu, 0x550c7dc3u,
    0x72be5d74u, 0x80deb1feu, 0x9bdc06a7u, 0xc19bf174u,
    0xe49b69c1u, 0xefbe4786u, 0x0fc19dc6u, 0x240ca1ccu,
    0x2de92c6fu, 0x4a7484aau, 0x5cb0a9dcu, 0x76f988dau,
    0x983e5152u, 0xa831c66du, 0xb00327c8u, 0xbf597fc7u,
    0xc6e00bf3u, 0xd5a79147u, 0x06ca6351u, 0x14292967u,
    0x27b70a85u, 0x2e1b2138u, 0x4d2c6dfcu, 0x53380d13u,
    0x650a7354u, 0x766a0abbu, 0x81c2c92eu, 0x92722c85u,
    0xa2bfe8a1u, 0xa81a664bu, 0xc24b8b70u, 0xc76c51a3u,
    0xd192e819u, 0xd6990624u, 0xf40e3585u, 0x106aa070u,
    0x19a4c116u, 0x1e376c08u, 0x2748774cu, 0x34b0bcb5u,
    0x391c0cb3u, 0x4ed8aa4au, 0x5b9cca4fu, 0x682e6ff3u,
    0x748f82eeu, 0x78a5636fu, 0x84c87814u, 0x8cc70208u,
    0x90befffau, 0xa4506cebu, 0xbef9a3f7u, 0xc67178f2u
};

static uint32_t rotr32(uint32_t x, unsigned n) {
    return (x >> n) | (x << (32 - n));
}

typedef struct {
    uint32_t h[8];
    uint64_t len;          /* total bytes fed */
    uint8_t buf[64];
    size_t buflen;
} sha256_ctx;

static void sha256_block(sha256_ctx *c, const uint8_t *p) {
    uint32_t w[64];
    int i;
    for (i = 0; i < 16; i++) {
        w[i] = ((uint32_t)p[i * 4] << 24) | ((uint32_t)p[i * 4 + 1] << 16) |
               ((uint32_t)p[i * 4 + 2] << 8) | (uint32_t)p[i * 4 + 3];
    }
    for (i = 16; i < 64; i++) {
        uint32_t s0 = rotr32(w[i - 15], 7) ^ rotr32(w[i - 15], 18) ^ (w[i - 15] >> 3);
        uint32_t s1 = rotr32(w[i - 2], 17) ^ rotr32(w[i - 2], 19) ^ (w[i - 2] >> 10);
        w[i] = w[i - 16] + s0 + w[i - 7] + s1;
    }
    uint32_t a = c->h[0], b = c->h[1], d = c->h[3], e = c->h[4];
    uint32_t f = c->h[5], g = c->h[6], h = c->h[7], cc = c->h[2];
    for (i = 0; i < 64; i++) {
        uint32_t s1 = rotr32(e, 6) ^ rotr32(e, 11) ^ rotr32(e, 25);
        uint32_t ch = (e & f) ^ ((~e) & g);
        uint32_t t1 = h + s1 + ch + k256[i] + w[i];
        uint32_t s0 = rotr32(a, 2) ^ rotr32(a, 13) ^ rotr32(a, 22);
        uint32_t mj = (a & b) ^ (a & cc) ^ (b & cc);
        uint32_t t2 = s0 + mj;
        h = g; g = f; f = e; e = d + t1;
        d = cc; cc = b; b = a; a = t1 + t2;
    }
    c->h[0] += a; c->h[1] += b; c->h[2] += cc; c->h[3] += d;
    c->h[4] += e; c->h[5] += f; c->h[6] += g; c->h[7] += h;
}

static void sha256_init(sha256_ctx *c) {
    static const uint32_t init[8] = {
        0x6a09e667u, 0xbb67ae85u, 0x3c6ef372u, 0xa54ff53au,
        0x510e527fu, 0x9b05688cu, 0x1f83d9abu, 0x5be0cd19u
    };
    memcpy(c->h, init, sizeof(init));
    c->len = 0;
    c->buflen = 0;
}

static void sha256_update(sha256_ctx *c, const uint8_t *data, size_t len) {
    c->len += len;
    while (len > 0) {
        size_t take = 64 - c->buflen;
        if (take > len) take = len;
        memcpy(c->buf + c->buflen, data, take);
        c->buflen += take;
        data += take;
        len -= take;
        if (c->buflen == 64) {
            sha256_block(c, c->buf);
            c->buflen = 0;
        }
    }
}

static void sha256_final(sha256_ctx *c, uint8_t out[32]) {
    uint64_t bits = c->len * 8;
    uint8_t pad = 0x80;
    uint8_t zero = 0x00;
    uint8_t lenbuf[8];
    int i;
    sha256_update(c, &pad, 1);
    while (c->buflen != 56) sha256_update(c, &zero, 1);
    for (i = 0; i < 8; i++) lenbuf[i] = (uint8_t)(bits >> (56 - 8 * i));
    /* Feed the length without counting it in c->len: update() adds to
     * len, but len is no longer used after this point. */
    sha256_update(c, lenbuf, 8);
    for (i = 0; i < 8; i++) {
        out[i * 4] = (uint8_t)(c->h[i] >> 24);
        out[i * 4 + 1] = (uint8_t)(c->h[i] >> 16);
        out[i * 4 + 2] = (uint8_t)(c->h[i] >> 8);
        out[i * 4 + 3] = (uint8_t)(c->h[i]);
    }
}

/* One-shot SHA-256. */
static void reagate_sha256(const uint8_t *data, size_t len, uint8_t out[32]) {
    sha256_ctx c;
    sha256_init(&c);
    sha256_update(&c, data, len);
    sha256_final(&c, out);
}

/* Hex-encode 32 digest bytes into 65 bytes (64 chars + NUL). */
static void to_hex(const uint8_t digest[32], char out[65]) {
    static const char hexd[] = "0123456789abcdef";
    int i;
    for (i = 0; i < 32; i++) {
        out[i * 2] = hexd[digest[i] >> 4];
        out[i * 2 + 1] = hexd[digest[i] & 0x0f];
    }
    out[64] = '\0';
}

/* Constant-time equality for two NUL-terminated hex strings. */
static int ct_equal(const char *a, const char *b) {
    size_t la = strlen(a), lb = strlen(b);
    size_t i;
    unsigned diff = (unsigned)(la ^ lb);
    size_t n = la < lb ? la : lb;
    for (i = 0; i < n; i++) diff |= (unsigned)(a[i] ^ b[i]);
    return diff == 0;
}

/* The gate itself: true only when hex(sha256(data)) == expectedHex. */
static int reagate_gate(const char *expected_hex,
                        const uint8_t *data, size_t len) {
    uint8_t digest[32];
    char actual[65];
    if (!expected_hex || !data) return 0;
    reagate_sha256(data, len, digest);
    to_hex(digest, actual);
    return ct_equal(expected_hex, actual);
}

#ifdef __ANDROID__
/* ------------------------------------------------------------------ */
/* JNI                                                                */
/* ------------------------------------------------------------------ */

JNIEXPORT jboolean JNICALL
Java_com_appcore_runtime_ReaNative_nativeGate(JNIEnv *env, jclass clazz,
                                              jstring expectedHex,
                                              jbyteArray data) {
    (void)clazz;
    if (expectedHex == NULL || data == NULL) return JNI_FALSE;
    const char *hex = (*env)->GetStringUTFChars(env, expectedHex, NULL);
    if (hex == NULL) return JNI_FALSE;
    jsize len = (*env)->GetArrayLength(env, data);
    jbyte *bytes = (*env)->GetByteArrayElements(env, data, NULL);
    if (bytes == NULL) {
        (*env)->ReleaseStringUTFChars(env, expectedHex, hex);
        return JNI_FALSE;
    }
    int ok = reagate_gate(hex, (const uint8_t *)bytes, (size_t)len);
    (*env)->ReleaseByteArrayElements(env, data, bytes, JNI_ABORT);
    (*env)->ReleaseStringUTFChars(env, expectedHex, hex);
    return ok ? JNI_TRUE : JNI_FALSE;
}

JNIEXPORT jstring JNICALL
Java_com_appcore_runtime_ReaNative_nativeVersion(JNIEnv *env, jclass clazz) {
    (void)clazz;
    return (*env)->NewStringUTF(env, REAGATE_VERSION);
}

#endif /* __ANDROID__ */

#ifdef REA_GATE_TEST_MAIN
/* Host test main: no JNI, no Android. */
#include <stdio.h>
#include <stdlib.h>

static int hex_is(const uint8_t *data, size_t len, const char *want) {
    uint8_t digest[32];
    char actual[65];
    reagate_sha256(data, len, digest);
    to_hex(digest, actual);
    return ct_equal(want, actual);
}

int main(int argc, char **argv) {
    if (argc == 2 && strcmp(argv[1], "selftest") == 0) {
        /* FIPS 180-4 vectors: "" and "abc". */
        int ok = 1;
        ok &= hex_is((const uint8_t *)"", 0,
                     "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
        ok &= hex_is((const uint8_t *)"abc", 3,
                     "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
        ok &= hex_is((const uint8_t *)"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq", 56,
                     "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1");
        printf(ok ? "SELFTEST-PASS\n" : "SELFTEST-FAIL\n");
        return ok ? 0 : 1;
    }
    if (argc == 3) {
        FILE *f = fopen(argv[1], "rb");
        if (!f) { printf("GATE-FAIL: cannot open %s\n", argv[1]); return 2; }
        fseek(f, 0, SEEK_END);
        long n = ftell(f);
        fseek(f, 0, SEEK_SET);
        uint8_t *buf = (uint8_t *)malloc(n > 0 ? (size_t)n : 1);
        if (n > 0 && fread(buf, 1, (size_t)n, f) != (size_t)n) {
            printf("GATE-FAIL: short read\n");
            return 2;
        }
        fclose(f);
        int ok = reagate_gate(argv[2], buf, (size_t)(n > 0 ? n : 0));
        free(buf);
        printf(ok ? "GATE-PASS\n" : "GATE-FAIL\n");
        return ok ? 0 : 1;
    }
    fprintf(stderr, "usage: %s selftest | %s <file> <expected-sha256-hex>\n",
            argv[0], argv[0]);
    return 2;
}
#endif /* REA_GATE_TEST_MAIN */
