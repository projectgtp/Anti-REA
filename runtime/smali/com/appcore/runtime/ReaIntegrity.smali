.class public final Lcom/appcore/runtime/ReaIntegrity;
.super Ljava/lang/Object;
.source "ReaIntegrity.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/appcore/runtime/ReaIntegrity$IntegrityResult;
    }
.end annotation

.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nReaIntegrity.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ReaIntegrity.kt\ncom/appcore/runtime/ReaIntegrity\n+ 2 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,130:1\n1#2:131\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000H\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u0012\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0005\n\u0002\u0018\u0002\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0002\u0008\u0004\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010$\n\u0002\u0018\u0002\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0000\u0008\u00c6\u0002\u0018\u00002\u00020\u0001:\u0001\u001eB\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u000e\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u0007J\u0016\u0010\u0008\u001a\u00020\t2\u0006\u0010\u0006\u001a\u00020\u00072\u0006\u0010\n\u001a\u00020\u0005J\u0016\u0010\u000b\u001a\u00020\t2\u0006\u0010\u000c\u001a\u00020\u00072\u0006\u0010\n\u001a\u00020\u0005J\u000e\u0010\r\u001a\u00020\u00052\u0006\u0010\u000e\u001a\u00020\u000fJ\u0016\u0010\u0010\u001a\u00020\t2\u0006\u0010\u0011\u001a\u00020\u00122\u0006\u0010\n\u001a\u00020\u0005J\u0016\u0010\u0013\u001a\u00020\t2\u0006\u0010\u0014\u001a\u00020\u00052\u0006\u0010\u0015\u001a\u00020\u0005J&\u0010\u0016\u001a\u00020\u00172\u001e\u0010\u0018\u001a\u001a\u0012\u0004\u0012\u00020\u0005\u0012\u0010\u0012\u000e\u0012\u0004\u0012\u00020\u0005\u0012\u0004\u0012\u00020\u00050\u001a0\u0019J\u0016\u0010\u001b\u001a\u00020\t2\u0006\u0010\u001c\u001a\u00020\u001d2\u0006\u0010\n\u001a\u00020\u0005"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaIntegrity;",
        "",
        "<init>",
        "()V",
        "sha256Hex",
        "",
        "bytes",
        "",
        "verifyBytesSha256",
        "",
        "expectedHex",
        "verifyDexSha256",
        "dexBytes",
        "hashStreamSha256",
        "input",
        "Ljava/io/InputStream;",
        "verifyFileSha256",
        "file",
        "Ljava/io/File;",
        "verifyComponentBlob",
        "blobBase64",
        "expectedSha256",
        "verifyAllBlobs",
        "Lcom/appcore/runtime/ReaIntegrity$IntegrityResult;",
        "checks",
        "",
        "Lkotlin/Pair;",
        "verifyOwnApkSha256",
        "context",
        "Landroid/content/Context;",
        "IntegrityResult"
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
.field public static final INSTANCE:Lcom/appcore/runtime/ReaIntegrity;


# direct methods
.method public static synthetic $r8$lambda$9ml8cmcy6LVKIz4DAuKZ_wHxnMU(B)Ljava/lang/CharSequence;
    .registers 1

    invoke-static {p0}, Lcom/appcore/runtime/ReaIntegrity;->hashStreamSha256$lambda$2(B)Ljava/lang/CharSequence;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic $r8$lambda$QP_HuaHi2DvHa4xAszi48C9ifBQ(B)Ljava/lang/CharSequence;
    .registers 1

    invoke-static {p0}, Lcom/appcore/runtime/ReaIntegrity;->sha256Hex$lambda$0(B)Ljava/lang/CharSequence;

    move-result-object p0

    return-object p0
.end method

.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/appcore/runtime/ReaIntegrity;

    invoke-direct {v0}, Lcom/appcore/runtime/ReaIntegrity;-><init>()V

    sput-object v0, Lcom/appcore/runtime/ReaIntegrity;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 20
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static final hashStreamSha256$lambda$2(B)Ljava/lang/CharSequence;
    .registers 3
    .param p0, "it"    # B

    .line 68
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

.method private static final sha256Hex$lambda$0(B)Ljava/lang/CharSequence;
    .registers 3
    .param p0, "it"    # B

    .line 32
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
.method public final hashStreamSha256(Ljava/io/InputStream;)Ljava/lang/String;
    .registers 15
    .param p1, "input"    # Ljava/io/InputStream;

    const-string v0, "input"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 62
    const-string v0, "SHA-256"

    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v0

    .line 63
    .local v0, "digest":Ljava/security/MessageDigest;
    const/16 v1, 0x2000

    new-array v1, v1, [B

    .line 64
    .local v1, "buf":[B
    const/4 v2, 0x0

    .line 65
    .local v2, "n":I
    :goto_10
    invoke-virtual {p1, v1}, Ljava/io/InputStream;->read([B)I

    move-result v3

    move v4, v3

    .line 131
    .local v4, "r":I
    const/4 v5, 0x0

    .line 65
    .local v5, "$i$a$-also-ReaIntegrity$hashStreamSha256$1":I
    move v2, v4

    .end local v4    # "r":I
    .end local v5    # "$i$a$-also-ReaIntegrity$hashStreamSha256$1":I
    const/4 v4, -0x1

    if-eq v3, v4, :cond_1f

    .line 66
    const/4 v3, 0x0

    invoke-virtual {v0, v1, v3, v2}, Ljava/security/MessageDigest;->update([BII)V

    goto :goto_10

    .line 68
    :cond_1f
    invoke-virtual {v0}, Ljava/security/MessageDigest;->digest()[B

    move-result-object v4

    const-string v3, "digest(...)"

    invoke-static {v4, v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v3, ""

    move-object v5, v3

    check-cast v5, Ljava/lang/CharSequence;

    new-instance v10, Lcom/appcore/runtime/ReaIntegrity$$ExternalSyntheticLambda0;

    invoke-direct {v10}, Lcom/appcore/runtime/ReaIntegrity$$ExternalSyntheticLambda0;-><init>()V

    const/16 v11, 0x1e

    const/4 v12, 0x0

    const/4 v6, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    invoke-static/range {v4 .. v12}, Lkotlin/collections/ArraysKt;->joinToString$default([BLjava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v3

    return-object v3
.end method

.method public final sha256Hex([B)Ljava/lang/String;
    .registers 12
    .param p1, "bytes"    # [B

    const-string v0, "bytes"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 31
    const-string v0, "SHA-256"

    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/security/MessageDigest;->digest([B)[B

    move-result-object v1

    const-string v0, "digest(...)"

    invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    .line 32
    const-string v0, ""

    move-object v2, v0

    check-cast v2, Ljava/lang/CharSequence;

    new-instance v7, Lcom/appcore/runtime/ReaIntegrity$$ExternalSyntheticLambda1;

    invoke-direct {v7}, Lcom/appcore/runtime/ReaIntegrity$$ExternalSyntheticLambda1;-><init>()V

    const/16 v8, 0x1e

    const/4 v9, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    const/4 v6, 0x0

    invoke-static/range {v1 .. v9}, Lkotlin/collections/ArraysKt;->joinToString$default([BLjava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    .line 31
    return-object v0
.end method

.method public final verifyAllBlobs(Ljava/util/Map;)Lcom/appcore/runtime/ReaIntegrity$IntegrityResult;
    .registers 8
    .param p1, "checks"    # Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Lkotlin/Pair<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;>;)",
            "Lcom/appcore/runtime/ReaIntegrity$IntegrityResult;"
        }
    .end annotation

    const-string v0, "checks"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 102
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast v0, Ljava/util/List;

    .line 103
    .local v0, "failed":Ljava/util/List;
    invoke-interface {p1}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_14
    :goto_14
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_42

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/util/Map$Entry;

    invoke-interface {v2}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    .local v3, "name":Ljava/lang/String;
    invoke-interface {v2}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lkotlin/Pair;

    .line 104
    .local v2, "pair":Lkotlin/Pair;
    invoke-virtual {v2}, Lkotlin/Pair;->getFirst()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    invoke-virtual {v2}, Lkotlin/Pair;->getSecond()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/String;

    invoke-virtual {p0, v4, v5}, Lcom/appcore/runtime/ReaIntegrity;->verifyComponentBlob(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v4

    if-nez v4, :cond_14

    invoke-interface {v0, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_14

    .line 106
    .end local v2    # "pair":Lkotlin/Pair;
    .end local v3    # "name":Ljava/lang/String;
    :cond_42
    new-instance v1, Lcom/appcore/runtime/ReaIntegrity$IntegrityResult;

    invoke-interface {v0}, Ljava/util/List;->isEmpty()Z

    move-result v2

    invoke-direct {v1, v2, v0}, Lcom/appcore/runtime/ReaIntegrity$IntegrityResult;-><init>(ZLjava/util/List;)V

    return-object v1
.end method

.method public final verifyBytesSha256([BLjava/lang/String;)Z
    .registers 6
    .param p1, "bytes"    # [B
    .param p2, "expectedHex"    # Ljava/lang/String;

    const-string v0, "bytes"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 37
    nop

    .line 38
    :try_start_b
    invoke-virtual {p0, p1}, Lcom/appcore/runtime/ReaIntegrity;->sha256Hex([B)Ljava/lang/String;

    move-result-object v0

    sget-object v1, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {p2, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "toLowerCase(...)"

    invoke-static {v1, v2}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-static {v0, v1}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0
    :try_end_1e
    .catch Ljava/lang/Exception; {:try_start_b .. :try_end_1e} :catch_1f

    goto :goto_22

    .line 39
    :catch_1f
    move-exception v0

    .line 40
    .local v0, "e":Ljava/lang/Exception;
    const/4 v1, 0x0

    move v0, v1

    .line 37
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_22
    return v0
.end method

.method public final verifyComponentBlob(Ljava/lang/String;Ljava/lang/String;)Z
    .registers 4
    .param p1, "blobBase64"    # Ljava/lang/String;
    .param p2, "expectedSha256"    # Ljava/lang/String;

    const-string v0, "blobBase64"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedSha256"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 94
    sget-object v0, Lcom/appcore/runtime/ReaRuntime;->INSTANCE:Lcom/appcore/runtime/ReaRuntime;

    invoke-virtual {v0, p1, p2}, Lcom/appcore/runtime/ReaRuntime;->verifyIntegrity(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public final verifyDexSha256([BLjava/lang/String;)Z
    .registers 4
    .param p1, "dexBytes"    # [B
    .param p2, "expectedHex"    # Ljava/lang/String;

    const-string v0, "dexBytes"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 49
    invoke-virtual {p0, p1, p2}, Lcom/appcore/runtime/ReaIntegrity;->verifyBytesSha256([BLjava/lang/String;)Z

    move-result v0

    return v0
.end method

.method public final verifyFileSha256(Ljava/io/File;Ljava/lang/String;)Z
    .registers 9
    .param p1, "file"    # Ljava/io/File;
    .param p2, "expectedHex"    # Ljava/lang/String;

    const-string v0, "file"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 77
    nop

    .line 78
    const/4 v0, 0x0

    :try_start_c
    invoke-virtual {p1}, Ljava/io/File;->canRead()Z

    move-result v1

    if-nez v1, :cond_13

    return v0

    .line 79
    :cond_13
    new-instance v1, Ljava/io/FileInputStream;

    invoke-direct {v1, p1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    check-cast v1, Ljava/io/Closeable;
    :try_end_1a
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_1a} :catch_42

    :try_start_1a
    move-object v2, v1

    check-cast v2, Ljava/io/FileInputStream;

    .line 131
    .local v2, "it":Ljava/io/FileInputStream;
    const/4 v3, 0x0

    .line 79
    .local v3, "$i$a$-use-ReaIntegrity$verifyFileSha256$actual$1":I
    sget-object v4, Lcom/appcore/runtime/ReaIntegrity;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity;

    move-object v5, v2

    check-cast v5, Ljava/io/InputStream;

    invoke-virtual {v4, v5}, Lcom/appcore/runtime/ReaIntegrity;->hashStreamSha256(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v4
    :try_end_27
    .catchall {:try_start_1a .. :try_end_27} :catchall_3b

    .end local v2    # "it":Ljava/io/FileInputStream;
    .end local v3    # "$i$a$-use-ReaIntegrity$verifyFileSha256$actual$1":I
    const/4 v2, 0x0

    :try_start_28
    invoke-static {v1, v2}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    .line 80
    .local v4, "actual":Ljava/lang/String;
    sget-object v1, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {p2, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "toLowerCase(...)"

    invoke-static {v1, v2}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-static {v4, v1}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0
    :try_end_3a
    .catch Ljava/lang/Exception; {:try_start_28 .. :try_end_3a} :catch_42

    .end local v4    # "actual":Ljava/lang/String;
    goto :goto_44

    .line 79
    :catchall_3b
    move-exception v2

    .end local p1    # "file":Ljava/io/File;
    .end local p2    # "expectedHex":Ljava/lang/String;
    :try_start_3c
    throw v2
    :try_end_3d
    .catchall {:try_start_3c .. :try_end_3d} :catchall_3d

    .restart local p1    # "file":Ljava/io/File;
    .restart local p2    # "expectedHex":Ljava/lang/String;
    :catchall_3d
    move-exception v3

    :try_start_3e
    invoke-static {v1, v2}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    .end local p1    # "file":Ljava/io/File;
    .end local p2    # "expectedHex":Ljava/lang/String;
    throw v3
    :try_end_42
    .catch Ljava/lang/Exception; {:try_start_3e .. :try_end_42} :catch_42

    .line 81
    .restart local p1    # "file":Ljava/io/File;
    .restart local p2    # "expectedHex":Ljava/lang/String;
    :catch_42
    move-exception v1

    .line 82
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 77
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_44
    return v0
.end method

.method public final verifyOwnApkSha256(Landroid/content/Context;Ljava/lang/String;)Z
    .registers 6
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "expectedHex"    # Ljava/lang/String;

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 122
    nop

    .line 123
    const/4 v0, 0x0

    :try_start_c
    invoke-virtual {p1}, Landroid/content/Context;->getApplicationInfo()Landroid/content/pm/ApplicationInfo;

    move-result-object v1

    iget-object v1, v1, Landroid/content/pm/ApplicationInfo;->sourceDir:Ljava/lang/String;

    if-nez v1, :cond_15

    return v0

    .line 124
    .local v1, "apkPath":Ljava/lang/String;
    :cond_15
    new-instance v2, Ljava/io/File;

    invoke-direct {v2, v1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {p0, v2, p2}, Lcom/appcore/runtime/ReaIntegrity;->verifyFileSha256(Ljava/io/File;Ljava/lang/String;)Z

    move-result v0
    :try_end_1e
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_1e} :catch_1f

    .end local v1    # "apkPath":Ljava/lang/String;
    goto :goto_21

    .line 125
    :catch_1f
    move-exception v1

    .line 126
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 122
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_21
    return v0
.end method
