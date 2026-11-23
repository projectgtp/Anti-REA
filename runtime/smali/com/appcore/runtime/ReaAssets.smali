.class public final Lcom/appcore/runtime/ReaAssets;
.super Ljava/lang/Object;
.source "ReaAssets.kt"


# annotations
.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u001c\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u0012\n\u0002\u0008\u0002\n\u0002\u0010\u000e\n\u0002\u0008\u0004\u0008\u00c6\u0002\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u001e\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u00052\u0006\u0010\u0007\u001a\u00020\u00082\u0006\u0010\t\u001a\u00020\u0008J\u001e\u0010\n\u001a\u00020\u00052\u0006\u0010\u000b\u001a\u00020\u00082\u0006\u0010\u0007\u001a\u00020\u00082\u0006\u0010\t\u001a\u00020\u0008J\u001e\u0010\u000c\u001a\u00020\u00082\u0006\u0010\u0006\u001a\u00020\u00052\u0006\u0010\u0007\u001a\u00020\u00082\u0006\u0010\t\u001a\u00020\u0008"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaAssets;",
        "",
        "<init>",
        "()V",
        "decryptAsset",
        "",
        "cipher",
        "keyPart1B64",
        "",
        "keyPart2B64",
        "decryptAssetBase64",
        "blobB64",
        "decryptAssetText"
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
.field public static final INSTANCE:Lcom/appcore/runtime/ReaAssets;


# direct methods
.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/appcore/runtime/ReaAssets;

    invoke-direct {v0}, Lcom/appcore/runtime/ReaAssets;-><init>()V

    sput-object v0, Lcom/appcore/runtime/ReaAssets;->INSTANCE:Lcom/appcore/runtime/ReaAssets;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 28
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final decryptAsset([BLjava/lang/String;Ljava/lang/String;)[B
    .registers 11
    .param p1, "cipher"    # [B
    .param p2, "keyPart1B64"    # Ljava/lang/String;
    .param p3, "keyPart2B64"    # Ljava/lang/String;

    const-string v0, "cipher"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart1B64"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart2B64"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 40
    sget-object v0, Lcom/appcore/runtime/ReaRuntime;->INSTANCE:Lcom/appcore/runtime/ReaRuntime;

    invoke-virtual {v0, p2, p3}, Lcom/appcore/runtime/ReaRuntime;->reconstructKey(Ljava/lang/String;Ljava/lang/String;)[B

    move-result-object v0

    .line 41
    .local v0, "key":[B
    array-length v1, p1

    new-array v2, v1, [B

    const/4 v3, 0x0

    move v4, v3

    :goto_1a
    if-ge v4, v1, :cond_2a

    .line 42
    aget-byte v5, p1, v4

    array-length v6, v0

    rem-int v6, v4, v6

    aget-byte v6, v0, v6

    xor-int/2addr v5, v6

    int-to-byte v5, v5

    aput-byte v5, v2, v4

    .line 41
    add-int/lit8 v4, v4, 0x1

    goto :goto_1a

    .line 44
    .local v2, "raw":[B
    :cond_2a
    array-length v1, v2

    const/16 v4, 0x20

    if-le v1, v4, :cond_52

    .line 47
    invoke-static {v2, v3, v4}, Lkotlin/collections/ArraysKt;->copyOfRange([BII)[B

    move-result-object v1

    .line 48
    .local v1, "expectedHash":[B
    array-length v3, v2

    invoke-static {v2, v4, v3}, Lkotlin/collections/ArraysKt;->copyOfRange([BII)[B

    move-result-object v3

    .line 49
    .local v3, "plain":[B
    const-string v4, "SHA-256"

    invoke-static {v4}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v4

    invoke-virtual {v4, v3}, Ljava/security/MessageDigest;->digest([B)[B

    move-result-object v4

    .line 50
    .local v4, "actualHash":[B
    invoke-static {v1, v4}, Ljava/util/Arrays;->equals([B[B)Z

    move-result v5

    if-eqz v5, :cond_49

    .line 55
    return-object v3

    .line 51
    :cond_49
    new-instance v5, Ljava/lang/IllegalStateException;

    .line 52
    nop

    .line 51
    const-string v6, "AppCore: asset payload integrity check failed"

    invoke-direct {v5, v6}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v5

    .line 45
    .end local v1    # "expectedHash":[B
    .end local v3    # "plain":[B
    .end local v4    # "actualHash":[B
    :cond_52
    new-instance v1, Ljava/lang/IllegalStateException;

    const-string v3, "AppCore: asset payload too short"

    invoke-direct {v1, v3}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;)V

    throw v1
.end method

.method public final decryptAssetBase64(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)[B
    .registers 8
    .param p1, "blobB64"    # Ljava/lang/String;
    .param p2, "keyPart1B64"    # Ljava/lang/String;
    .param p3, "keyPart2B64"    # Ljava/lang/String;

    const-string v0, "blobB64"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart1B64"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart2B64"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 64
    nop

    .line 65
    :try_start_10
    invoke-static {}, Ljava/util/Base64;->getDecoder()Ljava/util/Base64$Decoder;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/util/Base64$Decoder;->decode(Ljava/lang/String;)[B

    move-result-object v0
    :try_end_18
    .catch Ljava/lang/IllegalArgumentException; {:try_start_10 .. :try_end_18} :catch_21

    .line 64
    nop

    .line 69
    .local v0, "cipher":[B
    invoke-static {v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    invoke-virtual {p0, v0, p2, p3}, Lcom/appcore/runtime/ReaAssets;->decryptAsset([BLjava/lang/String;Ljava/lang/String;)[B

    move-result-object v1

    return-object v1

    .line 66
    .end local v0    # "cipher":[B
    :catch_21
    move-exception v0

    .line 67
    .local v0, "e":Ljava/lang/IllegalArgumentException;
    new-instance v1, Ljava/lang/IllegalStateException;

    const-string v2, "AppCore: asset blob is not valid base64"

    move-object v3, v0

    check-cast v3, Ljava/lang/Throwable;

    invoke-direct {v1, v2, v3}, Ljava/lang/IllegalStateException;-><init>(Ljava/lang/String;Ljava/lang/Throwable;)V

    throw v1
.end method

.method public final decryptAssetText([BLjava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 7
    .param p1, "cipher"    # [B
    .param p2, "keyPart1B64"    # Ljava/lang/String;
    .param p3, "keyPart2B64"    # Ljava/lang/String;

    const-string v0, "cipher"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart1B64"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart2B64"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    new-instance v0, Ljava/lang/String;

    .line 78
    invoke-virtual {p0, p1, p2, p3}, Lcom/appcore/runtime/ReaAssets;->decryptAsset([BLjava/lang/String;Ljava/lang/String;)[B

    move-result-object v1

    sget-object v2, Lkotlin/text/Charsets;->UTF_8:Ljava/nio/charset/Charset;

    invoke-direct {v0, v1, v2}, Ljava/lang/String;-><init>([BLjava/nio/charset/Charset;)V

    return-object v0
.end method
