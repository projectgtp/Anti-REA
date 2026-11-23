.class public final Lcom/appcore/runtime/ReaMethodDecrypt;
.super Ljava/lang/Object;
.source "ReaMethodDecrypt.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    }
.end annotation

.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nReaMethodDecrypt.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ReaMethodDecrypt.kt\ncom/appcore/runtime/ReaMethodDecrypt\n+ 2 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,292:1\n1#2:293\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00000\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u0008\n\u0000\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u0012\n\u0002\u0008\u0006\n\u0002\u0018\u0002\n\u0002\u0008\u000b\n\u0002\u0010\u000b\n\u0002\u0008\u0002\u0008\u00c6\u0002\u0018\u00002\u00020\u0001:\u0001\u001eB\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u0006\u0010\u0008\u001a\u00020\tJ\u000e\u0010\n\u001a\u00020\u00072\u0006\u0010\u000b\u001a\u00020\tJ\u0018\u0010\u000c\u001a\u0004\u0018\u00010\t2\u0006\u0010\r\u001a\u00020\u00072\u0006\u0010\u000e\u001a\u00020\u0007J\u0018\u0010\u000f\u001a\u0004\u0018\u00010\u00102\u0006\u0010\u0011\u001a\u00020\t2\u0006\u0010\u0012\u001a\u00020\tJ\u001a\u0010\u0013\u001a\u0004\u0018\u00010\t2\u0006\u0010\u0014\u001a\u00020\t2\u0006\u0010\u0012\u001a\u00020\tH\u0002J\u0018\u0010\u0015\u001a\u0004\u0018\u00010\t2\u0006\u0010\u0016\u001a\u00020\u00072\u0006\u0010\u0012\u001a\u00020\tJ \u0010\u0015\u001a\u0004\u0018\u00010\t2\u0006\u0010\u0016\u001a\u00020\u00072\u0006\u0010\r\u001a\u00020\u00072\u0006\u0010\u000e\u001a\u00020\u0007J\u0010\u0010\u0015\u001a\u0004\u0018\u00010\t2\u0006\u0010\u0017\u001a\u00020\u0010J \u0010\u0018\u001a\u0004\u0018\u00010\u00102\u0006\u0010\u0016\u001a\u00020\u00072\u0006\u0010\u0019\u001a\u00020\t2\u0006\u0010\u001a\u001a\u00020\tJ\u0018\u0010\u0018\u001a\u0004\u0018\u00010\u00102\u0006\u0010\u0017\u001a\u00020\u00102\u0006\u0010\u001a\u001a\u00020\tJ\u0016\u0010\u001b\u001a\u00020\u001c2\u0006\u0010\u0016\u001a\u00020\u00072\u0006\u0010\u001d\u001a\u00020\u0007R\u000e\u0010\u0004\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0007X\u0086T\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaMethodDecrypt;",
        "",
        "<init>",
        "()V",
        "KEY_LEN",
        "",
        "FORMAT",
        "",
        "generateKey",
        "",
        "sha256Hex",
        "bytes",
        "reconstructKey",
        "keyPart1B64",
        "keyPart2B64",
        "seal",
        "Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;",
        "payload",
        "key",
        "openCipher",
        "cipher",
        "open",
        "blobBase64",
        "sealed",
        "rotate",
        "oldKey",
        "newKey",
        "verifyBlob",
        "",
        "expectedSha256Hex",
        "SealedMethod"
    }
    k = 0x1
    mv = {
        0x2,
        0x0,
        0x0
    }
    xi = 0x30
.end annotation


# static fields
.field public static final FORMAT:Ljava/lang/String; = "anti-rea-method-blob-v1"

.field public static final INSTANCE:Lcom/appcore/runtime/ReaMethodDecrypt;

.field public static final KEY_LEN:I = 0x20


# direct methods
.method public static synthetic $r8$lambda$bt9b-j7PlIg1dQkrUGBKC6H5q-A(B)Ljava/lang/CharSequence;
    .registers 1

    invoke-static {p0}, Lcom/appcore/runtime/ReaMethodDecrypt;->sha256Hex$lambda$1(B)Ljava/lang/CharSequence;

    move-result-object p0

    return-object p0
.end method

.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/appcore/runtime/ReaMethodDecrypt;

    invoke-direct {v0}, Lcom/appcore/runtime/ReaMethodDecrypt;-><init>()V

    sput-object v0, Lcom/appcore/runtime/ReaMethodDecrypt;->INSTANCE:Lcom/appcore/runtime/ReaMethodDecrypt;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 79
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private final openCipher([B[B)[B
    .registers 11
    .param p1, "cipher"    # [B
    .param p2, "key"    # [B

    .line 166
    nop

    .line 167
    const/4 v0, 0x0

    :try_start_2
    array-length v1, p2

    const/16 v2, 0x20

    if-eq v1, v2, :cond_8

    return-object v0

    .line 168
    :cond_8
    array-length v1, p1

    new-array v3, v1, [B

    const/4 v4, 0x0

    move v5, v4

    :goto_d
    if-ge v5, v1, :cond_1c

    .line 169
    aget-byte v6, p1, v5

    rem-int/lit8 v7, v5, 0x20

    aget-byte v7, p2, v7

    xor-int/2addr v6, v7

    int-to-byte v6, v6

    aput-byte v6, v3, v5

    .line 168
    add-int/lit8 v5, v5, 0x1

    goto :goto_d

    .line 171
    .local v3, "raw":[B
    :cond_1c
    array-length v1, v3

    if-gt v1, v2, :cond_20

    return-object v0

    .line 172
    :cond_20
    invoke-static {v3, v4, v2}, Lkotlin/collections/ArraysKt;->copyOfRange([BII)[B

    move-result-object v1

    .line 173
    .local v1, "expectedHash":[B
    array-length v4, v3

    invoke-static {v3, v2, v4}, Lkotlin/collections/ArraysKt;->copyOfRange([BII)[B

    move-result-object v2

    .line 174
    .local v2, "plain":[B
    const-string v4, "SHA-256"

    invoke-static {v4}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/security/MessageDigest;->digest([B)[B

    move-result-object v4

    .line 175
    .local v4, "actualHash":[B
    invoke-static {v1, v4}, Ljava/util/Arrays;->equals([B[B)Z

    move-result v5
    :try_end_37
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_37} :catch_3c

    if-nez v5, :cond_3a

    return-object v0

    .line 176
    :cond_3a
    move-object v0, v2

    .end local v1    # "expectedHash":[B
    .end local v2    # "plain":[B
    .end local v3    # "raw":[B
    .end local v4    # "actualHash":[B
    goto :goto_3e

    .line 177
    :catch_3c
    move-exception v1

    .line 178
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 166
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_3e
    return-object v0
.end method

.method private static final sha256Hex$lambda$1(B)Ljava/lang/CharSequence;
    .registers 3
    .param p0, "it"    # B

    .line 111
    invoke-static {p0}, Ljava/lang/Byte;->valueOf(B)Ljava/lang/Byte;

    move-result-object v0

    filled-new-array {v0}, [Ljava/lang/Object;

    move-result-object v0

    const/4 v1, 0x1

    invoke-static {v0, v1}, Ljava/util/Arrays;->copyOf([Ljava/lang/Object;I)[Ljava/lang/Object;

    move-result-object v0

    const-string v1, "%02x"

    invoke-static {v1, v0}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "format(...)"

    invoke-static {v0, v1}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    check-cast v0, Ljava/lang/CharSequence;

    return-object v0
.end method


# virtual methods
.method public final generateKey()[B
    .registers 5

    .line 104
    const/16 v0, 0x20

    new-array v0, v0, [B

    move-object v1, v0

    .line 293
    .local v1, "it":[B
    const/4 v2, 0x0

    .line 104
    .local v2, "$i$a$-also-ReaMethodDecrypt$generateKey$1":I
    new-instance v3, Ljava/security/SecureRandom;

    invoke-direct {v3}, Ljava/security/SecureRandom;-><init>()V

    invoke-virtual {v3, v1}, Ljava/security/SecureRandom;->nextBytes([B)V

    .end local v1    # "it":[B
    .end local v2    # "$i$a$-also-ReaMethodDecrypt$generateKey$1":I
    return-object v0
.end method

.method public final open(Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;)[B
    .registers 7
    .param p1, "sealed"    # Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;

    const-string v0, "sealed"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 220
    nop

    .line 221
    const/4 v0, 0x0

    :try_start_7
    invoke-virtual {p1}, Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;->getBlobBase64()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1}, Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;->getBlobSha256Hex()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p0, v1, v2}, Lcom/appcore/runtime/ReaMethodDecrypt;->verifyBlob(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v1

    if-nez v1, :cond_16

    return-object v0

    .line 222
    :cond_16
    invoke-virtual {p1}, Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;->getBlobBase64()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p1}, Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;->getKeyPart1B64()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1}, Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;->getKeyPart2B64()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {p0, v1, v2, v3}, Lcom/appcore/runtime/ReaMethodDecrypt;->open(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)[B

    move-result-object v1

    if-nez v1, :cond_29

    .line 223
    return-object v0

    .line 224
    .local v1, "plain":[B
    :cond_29
    invoke-virtual {p1}, Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;->getPlainSha256Hex()Ljava/lang/String;

    move-result-object v2

    check-cast v2, Ljava/lang/CharSequence;

    invoke-static {v2}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v2

    if-nez v2, :cond_51

    .line 225
    invoke-virtual {p0, v1}, Lcom/appcore/runtime/ReaMethodDecrypt;->sha256Hex([B)Ljava/lang/String;

    move-result-object v2

    invoke-virtual {p1}, Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;->getPlainSha256Hex()Ljava/lang/String;

    move-result-object v3

    sget-object v4, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v3, v4}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v3

    const-string v4, "toLowerCase(...)"

    invoke-static {v3, v4}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-static {v2, v3}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2
    :try_end_4c
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_4c} :catch_52

    if-nez v2, :cond_4f

    goto :goto_51

    .line 227
    :cond_4f
    move-object v0, v1

    .end local v1    # "plain":[B
    goto :goto_54

    .line 226
    .restart local v1    # "plain":[B
    :cond_51
    :goto_51
    return-object v0

    .line 228
    .end local v1    # "plain":[B
    :catch_52
    move-exception v1

    .line 229
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 220
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_54
    return-object v0
.end method

.method public final open(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)[B
    .registers 6
    .param p1, "blobBase64"    # Ljava/lang/String;
    .param p2, "keyPart1B64"    # Ljava/lang/String;
    .param p3, "keyPart2B64"    # Ljava/lang/String;

    const-string v0, "blobBase64"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart1B64"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart2B64"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 203
    invoke-virtual {p0, p2, p3}, Lcom/appcore/runtime/ReaMethodDecrypt;->reconstructKey(Ljava/lang/String;Ljava/lang/String;)[B

    move-result-object v0

    if-nez v0, :cond_17

    const/4 v0, 0x0

    return-object v0

    .line 204
    .local v0, "key":[B
    :cond_17
    invoke-virtual {p0, p1, v0}, Lcom/appcore/runtime/ReaMethodDecrypt;->open(Ljava/lang/String;[B)[B

    move-result-object v1

    return-object v1
.end method

.method public final open(Ljava/lang/String;[B)[B
    .registers 5
    .param p1, "blobBase64"    # Ljava/lang/String;
    .param p2, "key"    # [B

    const-string v0, "blobBase64"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "key"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 188
    nop

    .line 189
    :try_start_b
    invoke-static {}, Ljava/util/Base64;->getDecoder()Ljava/util/Base64$Decoder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/util/Base64$Decoder;->decode(Ljava/lang/String;)[B

    move-result-object v0

    .line 190
    .local v0, "cipher":[B
    invoke-static {v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    invoke-direct {p0, v0, p2}, Lcom/appcore/runtime/ReaMethodDecrypt;->openCipher([B[B)[B

    move-result-object v1
    :try_end_1a
    .catch Ljava/lang/Exception; {:try_start_b .. :try_end_1a} :catch_1b

    .end local v0    # "cipher":[B
    goto :goto_1d

    .line 191
    :catch_1b
    move-exception v0

    .line 192
    .local v0, "e":Ljava/lang/Exception;
    const/4 v1, 0x0

    .line 188
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1d
    return-object v1
.end method

.method public final reconstructKey(Ljava/lang/String;Ljava/lang/String;)[B
    .registers 11
    .param p1, "keyPart1B64"    # Ljava/lang/String;
    .param p2, "keyPart2B64"    # Ljava/lang/String;

    const-string v0, "keyPart1B64"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart2B64"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 123
    nop

    .line 124
    const/4 v0, 0x0

    :try_start_c
    invoke-static {}, Ljava/util/Base64;->getDecoder()Ljava/util/Base64$Decoder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/util/Base64$Decoder;->decode(Ljava/lang/String;)[B

    move-result-object v1

    .line 125
    .local v1, "p1":[B
    invoke-static {}, Ljava/util/Base64;->getDecoder()Ljava/util/Base64$Decoder;

    move-result-object v2

    invoke-virtual {v2, p2}, Ljava/util/Base64$Decoder;->decode(Ljava/lang/String;)[B

    move-result-object v2

    .line 126
    .local v2, "p2":[B
    array-length v3, v1

    array-length v4, v2

    if-ne v3, v4, :cond_3f

    invoke-static {v1}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    array-length v3, v1

    const/4 v4, 0x0

    if-nez v3, :cond_29

    const/4 v3, 0x1

    goto :goto_2a

    :cond_29
    move v3, v4

    :goto_2a
    if-eqz v3, :cond_2d

    goto :goto_3f

    .line 127
    :cond_2d
    array-length v3, v1

    new-array v5, v3, [B

    :goto_30
    if-ge v4, v3, :cond_3d

    aget-byte v6, v1, v4

    aget-byte v7, v2, v4

    xor-int/2addr v6, v7

    int-to-byte v6, v6

    aput-byte v6, v5, v4
    :try_end_3a
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_3a} :catch_40

    add-int/lit8 v4, v4, 0x1

    goto :goto_30

    :cond_3d
    move-object v0, v5

    .end local v1    # "p1":[B
    .end local v2    # "p2":[B
    goto :goto_42

    .line 126
    .restart local v1    # "p1":[B
    .restart local v2    # "p2":[B
    :cond_3f
    :goto_3f
    return-object v0

    .line 128
    .end local v1    # "p1":[B
    .end local v2    # "p2":[B
    :catch_40
    move-exception v1

    .line 129
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 123
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_42
    return-object v0
.end method

.method public final rotate(Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;[B)Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    .registers 11
    .param p1, "sealed"    # Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    .param p2, "newKey"    # [B

    const-string v0, "sealed"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "newKey"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 263
    nop

    .line 264
    const/4 v1, 0x0

    :try_start_c
    array-length v0, p2

    const/16 v2, 0x20

    if-eq v0, v2, :cond_12

    return-object v1

    .line 265
    :cond_12
    invoke-virtual {p0, p1}, Lcom/appcore/runtime/ReaMethodDecrypt;->open(Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;)[B

    move-result-object v0
    :try_end_16
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_16} :catch_34

    if-nez v0, :cond_19

    return-object v1

    :cond_19
    move-object v2, v0

    .line 266
    .local v2, "plain":[B
    nop

    .line 267
    :try_start_1b
    invoke-virtual {p0, v2, p2}, Lcom/appcore/runtime/ReaMethodDecrypt;->seal([B[B)Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;

    move-result-object v0
    :try_end_1f
    .catchall {:try_start_1b .. :try_end_1f} :catchall_2a

    .line 269
    const/4 v6, 0x6

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    :try_start_24
    invoke-static/range {v2 .. v7}, Lkotlin/collections/ArraysKt;->fill$default([BBIIILjava/lang/Object;)V

    .line 270
    nop

    .line 269
    move-object v1, v0

    .end local v2    # "plain":[B
    goto :goto_36

    .restart local v2    # "plain":[B
    :catchall_2a
    move-exception v0

    const/4 v6, 0x6

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-static/range {v2 .. v7}, Lkotlin/collections/ArraysKt;->fill$default([BBIIILjava/lang/Object;)V

    .end local p1    # "sealed":Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    .end local p2    # "newKey":[B
    throw v0
    :try_end_34
    .catch Ljava/lang/Exception; {:try_start_24 .. :try_end_34} :catch_34

    .line 271
    .end local v2    # "plain":[B
    .restart local p1    # "sealed":Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    .restart local p2    # "newKey":[B
    :catch_34
    move-exception v0

    .line 272
    .local v0, "e":Ljava/lang/Exception;
    nop

    .line 263
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_36
    return-object v1
.end method

.method public final rotate(Ljava/lang/String;[B[B)Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    .registers 12
    .param p1, "blobBase64"    # Ljava/lang/String;
    .param p2, "oldKey"    # [B
    .param p3, "newKey"    # [B

    const-string v0, "blobBase64"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "oldKey"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "newKey"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 247
    nop

    .line 248
    const/4 v1, 0x0

    :try_start_11
    array-length v0, p3

    const/16 v2, 0x20

    if-eq v0, v2, :cond_17

    return-object v1

    .line 249
    :cond_17
    invoke-virtual {p0, p1, p2}, Lcom/appcore/runtime/ReaMethodDecrypt;->open(Ljava/lang/String;[B)[B

    move-result-object v0
    :try_end_1b
    .catch Ljava/lang/Exception; {:try_start_11 .. :try_end_1b} :catch_39

    if-nez v0, :cond_1e

    return-object v1

    :cond_1e
    move-object v2, v0

    .line 250
    .local v2, "plain":[B
    nop

    .line 251
    :try_start_20
    invoke-virtual {p0, v2, p3}, Lcom/appcore/runtime/ReaMethodDecrypt;->seal([B[B)Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;

    move-result-object v0
    :try_end_24
    .catchall {:try_start_20 .. :try_end_24} :catchall_2f

    .line 254
    const/4 v6, 0x6

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    :try_start_29
    invoke-static/range {v2 .. v7}, Lkotlin/collections/ArraysKt;->fill$default([BBIIILjava/lang/Object;)V

    .line 255
    nop

    .line 254
    move-object v1, v0

    .end local v2    # "plain":[B
    goto :goto_3b

    .restart local v2    # "plain":[B
    :catchall_2f
    move-exception v0

    const/4 v6, 0x6

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-static/range {v2 .. v7}, Lkotlin/collections/ArraysKt;->fill$default([BBIIILjava/lang/Object;)V

    .end local p1    # "blobBase64":Ljava/lang/String;
    .end local p2    # "oldKey":[B
    .end local p3    # "newKey":[B
    throw v0
    :try_end_39
    .catch Ljava/lang/Exception; {:try_start_29 .. :try_end_39} :catch_39

    .line 256
    .end local v2    # "plain":[B
    .restart local p1    # "blobBase64":Ljava/lang/String;
    .restart local p2    # "oldKey":[B
    .restart local p3    # "newKey":[B
    :catch_39
    move-exception v0

    .line 257
    .local v0, "e":Ljava/lang/Exception;
    nop

    .line 247
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_3b
    return-object v1
.end method

.method public final seal([B[B)Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    .registers 19
    .param p1, "payload"    # [B
    .param p2, "key"    # [B

    move-object/from16 v1, p1

    move-object/from16 v2, p2

    const-string v0, "encodeToString(...)"

    const-string v3, "payload"

    invoke-static {v1, v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v3, "key"

    invoke-static {v2, v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 142
    nop

    .line 143
    const/4 v3, 0x0

    :try_start_12
    array-length v4, v1

    const/4 v5, 0x0

    if-nez v4, :cond_18

    const/4 v4, 0x1

    goto :goto_19

    :cond_18
    move v4, v5

    :goto_19
    if-nez v4, :cond_91

    array-length v4, v2

    const/16 v6, 0x20

    if-eq v4, v6, :cond_24

    move-object/from16 v5, p0

    goto/16 :goto_93

    .line 144
    :cond_24
    invoke-virtual/range {p0 .. p0}, Lcom/appcore/runtime/ReaMethodDecrypt;->generateKey()[B

    move-result-object v4

    .line 145
    .local v4, "part1":[B
    new-array v7, v6, [B

    move v8, v5

    :goto_2b
    if-ge v8, v6, :cond_38

    .line 146
    aget-byte v9, v2, v8

    aget-byte v10, v4, v8

    xor-int/2addr v9, v10

    int-to-byte v9, v9

    aput-byte v9, v7, v8

    .line 145
    add-int/lit8 v8, v8, 0x1

    goto :goto_2b

    .line 148
    .local v7, "part2":[B
    :cond_38
    const-string v6, "SHA-256"

    invoke-static {v6}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v6

    invoke-virtual {v6, v1}, Ljava/security/MessageDigest;->digest([B)[B

    move-result-object v6

    const-string v8, "digest(...)"

    invoke-static {v6, v8}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-static {v6, v1}, Lkotlin/collections/ArraysKt;->plus([B[B)[B

    move-result-object v6

    .line 149
    .local v6, "raw":[B
    array-length v8, v6

    new-array v9, v8, [B

    :goto_4e
    if-ge v5, v8, :cond_5d

    .line 150
    aget-byte v10, v6, v5

    rem-int/lit8 v11, v5, 0x20

    aget-byte v11, v2, v11

    xor-int/2addr v10, v11

    int-to-byte v10, v10

    aput-byte v10, v9, v5

    .line 149
    add-int/lit8 v5, v5, 0x1

    goto :goto_4e

    .line 152
    .local v9, "cipher":[B
    :cond_5d
    new-instance v10, Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;

    .line 153
    invoke-static {}, Ljava/util/Base64;->getEncoder()Ljava/util/Base64$Encoder;

    move-result-object v5

    invoke-virtual {v5, v9}, Ljava/util/Base64$Encoder;->encodeToString([B)Ljava/lang/String;

    move-result-object v11

    invoke-static {v11, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    .line 154
    invoke-static {}, Ljava/util/Base64;->getEncoder()Ljava/util/Base64$Encoder;

    move-result-object v5

    invoke-virtual {v5, v4}, Ljava/util/Base64$Encoder;->encodeToString([B)Ljava/lang/String;

    move-result-object v12

    invoke-static {v12, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    .line 155
    invoke-static {}, Ljava/util/Base64;->getEncoder()Ljava/util/Base64$Encoder;

    move-result-object v5

    invoke-virtual {v5, v7}, Ljava/util/Base64$Encoder;->encodeToString([B)Ljava/lang/String;

    move-result-object v13

    invoke-static {v13, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V
    :try_end_80
    .catch Ljava/lang/Exception; {:try_start_12 .. :try_end_80} :catch_94

    .line 156
    move-object/from16 v5, p0

    :try_start_82
    invoke-virtual {v5, v9}, Lcom/appcore/runtime/ReaMethodDecrypt;->sha256Hex([B)Ljava/lang/String;

    move-result-object v14

    .line 157
    invoke-virtual/range {p0 .. p1}, Lcom/appcore/runtime/ReaMethodDecrypt;->sha256Hex([B)Ljava/lang/String;

    move-result-object v15

    .line 152
    invoke-direct/range {v10 .. v15}, Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V
    :try_end_8d
    .catch Ljava/lang/Exception; {:try_start_82 .. :try_end_8d} :catch_8f

    move-object v3, v10

    .end local v4    # "part1":[B
    .end local v6    # "raw":[B
    .end local v7    # "part2":[B
    .end local v9    # "cipher":[B
    goto :goto_98

    .line 159
    :catch_8f
    move-exception v0

    goto :goto_97

    .line 143
    :cond_91
    move-object/from16 v5, p0

    :goto_93
    return-object v3

    .line 159
    :catch_94
    move-exception v0

    move-object/from16 v5, p0

    .line 160
    .local v0, "e":Ljava/lang/Exception;
    :goto_97
    nop

    .line 142
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_98
    return-object v3
.end method

.method public final sha256Hex([B)Ljava/lang/String;
    .registers 13
    .param p1, "bytes"    # [B

    const-string v1, ""

    const-string v0, "bytes"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 109
    nop

    .line 110
    :try_start_8
    const-string v0, "SHA-256"

    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/security/MessageDigest;->digest([B)[B

    move-result-object v2

    const-string v0, "digest(...)"

    invoke-static {v2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    .line 111
    move-object v3, v1

    check-cast v3, Ljava/lang/CharSequence;

    new-instance v8, Lcom/appcore/runtime/ReaMethodDecrypt$$ExternalSyntheticLambda0;

    invoke-direct {v8}, Lcom/appcore/runtime/ReaMethodDecrypt$$ExternalSyntheticLambda0;-><init>()V

    const/16 v9, 0x1e

    const/4 v10, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    const/4 v6, 0x0

    const/4 v7, 0x0

    invoke-static/range {v2 .. v10}, Lkotlin/collections/ArraysKt;->joinToString$default([BLjava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v1
    :try_end_2a
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_2a} :catch_2b

    goto :goto_2d

    .line 112
    :catch_2b
    move-exception v0

    .line 113
    .local v0, "e":Ljava/lang/Exception;
    nop

    .line 109
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_2d
    return-object v1
.end method

.method public final verifyBlob(Ljava/lang/String;Ljava/lang/String;)Z
    .registers 8
    .param p1, "blobBase64"    # Ljava/lang/String;
    .param p2, "expectedSha256Hex"    # Ljava/lang/String;

    const-string v0, "blobBase64"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedSha256Hex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 283
    nop

    .line 284
    const/4 v0, 0x0

    :try_start_c
    move-object v1, p2

    check-cast v1, Ljava/lang/CharSequence;

    invoke-static {v1}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_16

    return v0

    .line 285
    :cond_16
    invoke-static {}, Ljava/util/Base64;->getDecoder()Ljava/util/Base64$Decoder;

    move-result-object v1

    invoke-virtual {v1, p1}, Ljava/util/Base64$Decoder;->decode(Ljava/lang/String;)[B

    move-result-object v1

    .line 286
    .local v1, "cipher":[B
    invoke-static {v1}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    invoke-virtual {p0, v1}, Lcom/appcore/runtime/ReaMethodDecrypt;->sha256Hex([B)Ljava/lang/String;

    move-result-object v2

    sget-object v3, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {p2, v3}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v3

    const-string v4, "toLowerCase(...)"

    invoke-static {v3, v4}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-static {v2, v3}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0
    :try_end_34
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_34} :catch_35

    .end local v1    # "cipher":[B
    goto :goto_37

    .line 287
    :catch_35
    move-exception v1

    .line 288
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 283
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_37
    return v0
.end method
