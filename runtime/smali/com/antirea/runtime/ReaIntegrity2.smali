.class public final Lcom/antirea/runtime/ReaIntegrity2;
.super Ljava/lang/Object;
.source "ReaIntegrity2.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;,
        Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;,
        Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;,
        Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;,
        Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;
    }
.end annotation

.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nReaIntegrity2.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ReaIntegrity2.kt\ncom/antirea/runtime/ReaIntegrity2\n+ 2 _Strings.kt\nkotlin/text/StringsKt___StringsKt\n+ 3 fake.kt\nkotlin/jvm/internal/FakeKt\n+ 4 _Arrays.kt\nkotlin/collections/ArraysKt___ArraysKt\n+ 5 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,510:1\n1069#2,2:511\n1#3:513\n3829#4:514\n4344#4,2:515\n3829#4:517\n4344#4,2:518\n295#5:520\n1734#5,3:521\n296#5:524\n*S KotlinDebug\n*F\n+ 1 ReaIntegrity2.kt\ncom/antirea/runtime/ReaIntegrity2\n*L\n63#1:511,2\n361#1:514\n361#1:515,2\n363#1:517\n363#1:518,2\n364#1:520\n366#1:521,3\n364#1:524\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000z\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u0012\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0005\n\u0002\u0018\u0002\n\u0002\u0008\u0004\n\u0002\u0018\u0002\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0003\n\u0002\u0018\u0002\n\u0002\u0008\u0004\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010$\n\u0002\u0008\u0006\n\u0002\u0018\u0002\n\u0002\u0008\n\n\u0002\u0010\u0011\n\u0002\u0008\u000e\n\u0002\u0018\u0002\n\u0002\u0008\u0004\n\u0002\u0018\u0002\n\u0002\u0008\u0005\u0008\u00c6\u0002\u0018\u00002\u00020\u0001:\u0005MNOPQB\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u000e\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u0007J\u001a\u0010\u0008\u001a\u00020\t2\u0008\u0010\n\u001a\u0004\u0018\u00010\u00052\u0008\u0010\u000b\u001a\u0004\u0018\u00010\u0005J\u0010\u0010\u000c\u001a\u0004\u0018\u00010\u00072\u0006\u0010\r\u001a\u00020\u0005J\u001a\u0010\u000e\u001a\u00020\u000f2\u0008\u0010\u0010\u001a\u0004\u0018\u00010\u00052\u0008\u0010\u0011\u001a\u0004\u0018\u00010\u0005J\u0012\u0010\u0012\u001a\u0004\u0018\u00010\u00052\u0008\u0010\u0013\u001a\u0004\u0018\u00010\u0014J\u0014\u0010\u0015\u001a\u0004\u0018\u00010\u00052\n\u0010\u0016\u001a\u0006\u0012\u0002\u0008\u00030\u0017J\u0018\u0010\u0018\u001a\u00020\u00192\u0008\u0010\u0013\u001a\u0004\u0018\u00010\u00142\u0006\u0010\u001a\u001a\u00020\u0005J\u001a\u0010\u001b\u001a\u00020\u00192\n\u0010\u0016\u001a\u0006\u0012\u0002\u0008\u00030\u00172\u0006\u0010\u001a\u001a\u00020\u0005J\u0018\u0010\u001c\u001a\u00020\u001d2\u0008\u0010\u001e\u001a\u0004\u0018\u00010\u00072\u0006\u0010\u001f\u001a\u00020\u0005J\u0016\u0010 \u001a\u00020\u001d2\u0006\u0010!\u001a\u00020\"2\u0006\u0010\u001f\u001a\u00020\u0005J.\u0010#\u001a\u00020$2\u0012\u0010%\u001a\u000e\u0012\u0004\u0012\u00020\u0005\u0012\u0004\u0012\u00020\u00070&2\u0012\u0010\'\u001a\u000e\u0012\u0004\u0012\u00020\u0005\u0012\u0004\u0012\u00020\u00050&J.\u0010(\u001a\u00020$2\u0012\u0010)\u001a\u000e\u0012\u0004\u0012\u00020\u0005\u0012\u0004\u0012\u00020\u00070&2\u0012\u0010\'\u001a\u000e\u0012\u0004\u0012\u00020\u0005\u0012\u0004\u0012\u00020\u00050&J/\u0010*\u001a\u0004\u0018\u0001H+\"\u0004\u0008\u0000\u0010+2\u000c\u0010,\u001a\u0008\u0012\u0004\u0012\u00020\t0-2\u000c\u0010.\u001a\u0008\u0012\u0004\u0012\u0002H+0-\u00a2\u0006\u0002\u0010/J.\u00100\u001a\u0004\u0018\u00010\u00052\u000c\u0010,\u001a\u0008\u0012\u0004\u0012\u00020\t0-2\u0006\u00101\u001a\u00020\u00052\u0006\u00102\u001a\u00020\u00052\u0006\u00103\u001a\u00020\u0005J5\u00104\u001a\u0004\u0018\u00010\u00012\u0006\u00105\u001a\u00020\u00012\u0006\u00106\u001a\u00020\u00052\u0016\u00107\u001a\u000c\u0012\u0008\u0008\u0001\u0012\u0004\u0018\u00010\u000108\"\u0004\u0018\u00010\u0001\u00a2\u0006\u0002\u00109JK\u0010:\u001a\u0004\u0018\u0001H+\"\u0004\u0008\u0000\u0010+2\u0006\u00105\u001a\u00020\u00012\u0006\u00106\u001a\u00020\u00052\u0012\u0008\u0002\u00107\u001a\u000c\u0012\u0008\u0008\u0001\u0012\u0004\u0018\u00010\u0001082\u0012\u0008\u0002\u0010;\u001a\u000c\u0012\u0006\u0012\u0004\u0018\u0001H+\u0018\u00010-\u00a2\u0006\u0002\u0010<J\u001c\u0010=\u001a\u0008\u0012\u0002\u0008\u0003\u0018\u00010\u00172\u0006\u0010>\u001a\u00020\u00052\u0006\u0010?\u001a\u00020\u0005J\u001c\u0010@\u001a\u0008\u0012\u0002\u0008\u0003\u0018\u00010\u00172\u0006\u0010A\u001a\u00020\"2\u0006\u0010?\u001a\u00020\u0005J$\u0010B\u001a\u0008\u0012\u0002\u0008\u0003\u0018\u00010\u00172\u0006\u0010C\u001a\u00020\u00072\u0006\u0010?\u001a\u00020\u00052\u0006\u0010D\u001a\u00020\"J\u000e\u0010E\u001a\u00020\u000f2\u0006\u0010F\u001a\u00020GJ,\u0010H\u001a\u0008\u0012\u0002\u0008\u0003\u0018\u00010\u00172\u0006\u0010I\u001a\u00020\u00052\u0006\u0010J\u001a\u00020\u00052\u0006\u0010?\u001a\u00020\u00052\u0006\u0010K\u001a\u00020L"
    }
    d2 = {
        "Lcom/antirea/runtime/ReaIntegrity2;",
        "",
        "<init>",
        "()V",
        "sha256Hex",
        "",
        "bytes",
        "",
        "hexEqualsConstantTime",
        "",
        "a",
        "b",
        "hexToBytes",
        "hex",
        "checkInstallerOrigin",
        "Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;",
        "packageName",
        "installerPackageName",
        "hashClassBytes",
        "stream",
        "Ljava/io/InputStream;",
        "hashOwnClassBytes",
        "clazz",
        "Ljava/lang/Class;",
        "verifySelfHash",
        "Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;",
        "expectedHex",
        "verifyOwnClassHash",
        "verifyConfigHash",
        "Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;",
        "configBytes",
        "pinnedHex",
        "verifyConfigFileHash",
        "file",
        "Ljava/io/File;",
        "verifyResourceHashes",
        "Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;",
        "entries",
        "",
        "expectedHashes",
        "verifyNativeLibHashes",
        "libs",
        "decryptWithEnvCheck",
        "T",
        "envCheck",
        "Lkotlin/Function0;",
        "decrypt",
        "(Lkotlin/jvm/functions/Function0;Lkotlin/jvm/functions/Function0;)Ljava/lang/Object;",
        "decryptBlobWithEnvCheck",
        "blobBase64",
        "keyPart1B64",
        "keyPart2B64",
        "invokeReflectively",
        "target",
        "methodName",
        "args",
        "",
        "(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;",
        "callByReflectionOrDirect",
        "direct",
        "(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;Lkotlin/jvm/functions/Function0;)Ljava/lang/Object;",
        "loadClassFromJar",
        "jarPath",
        "className",
        "loadClassFromJarFile",
        "jarFile",
        "loadClassFromJarBytes",
        "jarBytes",
        "tempDir",
        "getInstallerOrigin",
        "context",
        "Landroid/content/Context;",
        "loadClassFromDex",
        "dexPath",
        "optimizedDir",
        "parent",
        "Ljava/lang/ClassLoader;",
        "InstallerOrigin",
        "InstallerSignal",
        "SelfHashResult",
        "ConfigHashResult",
        "HashCheckResult"
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
.field public static final INSTANCE:Lcom/antirea/runtime/ReaIntegrity2;


# direct methods
.method public static synthetic $r8$lambda$0bpNiR5K0K_9DS2iTcBbHiZWOBg(B)Ljava/lang/CharSequence;
    .registers 1

    invoke-static {p0}, Lcom/antirea/runtime/ReaIntegrity2;->sha256Hex$lambda$0(B)Ljava/lang/CharSequence;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic $r8$lambda$XhVQc_Z4x_rrCc7qcmokdemsuVc(B)Ljava/lang/CharSequence;
    .registers 1

    invoke-static {p0}, Lcom/antirea/runtime/ReaIntegrity2;->hashClassBytes$lambda$4$lambda$3(B)Ljava/lang/CharSequence;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic $r8$lambda$iGDx9RXTaVC7IEgTWOxqjqz_MbY(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 3

    invoke-static {p0, p1, p2}, Lcom/antirea/runtime/ReaIntegrity2;->decryptBlobWithEnvCheck$lambda$5(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/antirea/runtime/ReaIntegrity2;

    invoke-direct {v0}, Lcom/antirea/runtime/ReaIntegrity2;-><init>()V

    sput-object v0, Lcom/antirea/runtime/ReaIntegrity2;->INSTANCE:Lcom/antirea/runtime/ReaIntegrity2;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 28
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static synthetic callByReflectionOrDirect$default(Lcom/antirea/runtime/ReaIntegrity2;Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;Lkotlin/jvm/functions/Function0;ILjava/lang/Object;)Ljava/lang/Object;
    .registers 7

    .line 391
    and-int/lit8 p6, p5, 0x4

    if-eqz p6, :cond_7

    .line 394
    const/4 p3, 0x0

    new-array p3, p3, [Ljava/lang/Object;

    .line 391
    :cond_7
    and-int/lit8 p5, p5, 0x8

    if-eqz p5, :cond_c

    .line 395
    const/4 p4, 0x0

    .line 391
    :cond_c
    invoke-virtual {p0, p1, p2, p3, p4}, Lcom/antirea/runtime/ReaIntegrity2;->callByReflectionOrDirect(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;Lkotlin/jvm/functions/Function0;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method private static final decryptBlobWithEnvCheck$lambda$5(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 4
    .param p0, "$blobBase64"    # Ljava/lang/String;
    .param p1, "$keyPart1B64"    # Ljava/lang/String;
    .param p2, "$keyPart2B64"    # Ljava/lang/String;

    .line 340
    sget-object v0, Lcom/antirea/runtime/ReaRuntime;->INSTANCE:Lcom/antirea/runtime/ReaRuntime;

    invoke-virtual {v0, p0, p1, p2}, Lcom/antirea/runtime/ReaRuntime;->decrypt(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private static final hashClassBytes$lambda$4$lambda$3(B)Ljava/lang/CharSequence;
    .registers 3
    .param p0, "b"    # B

    .line 142
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

    .line 37
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
.method public final callByReflectionOrDirect(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;Lkotlin/jvm/functions/Function0;)Ljava/lang/Object;
    .registers 8
    .param p1, "target"    # Ljava/lang/Object;
    .param p2, "methodName"    # Ljava/lang/String;
    .param p3, "args"    # [Ljava/lang/Object;
    .param p4, "direct"    # Lkotlin/jvm/functions/Function0;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Ljava/lang/Object;",
            "Ljava/lang/String;",
            "[",
            "Ljava/lang/Object;",
            "Lkotlin/jvm/functions/Function0<",
            "+TT;>;)TT;"
        }
    .end annotation

    const-string v0, "target"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "methodName"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "args"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 398
    array-length v0, p3

    invoke-static {p3, v0}, Ljava/util/Arrays;->copyOf([Ljava/lang/Object;I)[Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {p0, p1, p2, v0}, Lcom/antirea/runtime/ReaIntegrity2;->invokeReflectively(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    .line 397
    nop

    .line 399
    .local v0, "reflected":Ljava/lang/Object;
    if-eqz v0, :cond_1c

    return-object v0

    .line 400
    :cond_1c
    nop

    .line 401
    const/4 v1, 0x0

    if-eqz p4, :cond_27

    :try_start_20
    invoke-interface {p4}, Lkotlin/jvm/functions/Function0;->invoke()Ljava/lang/Object;

    move-result-object v1
    :try_end_24
    .catch Ljava/lang/Exception; {:try_start_20 .. :try_end_24} :catch_25

    goto :goto_27

    .line 402
    :catch_25
    move-exception v2

    .line 403
    .local v2, "e":Ljava/lang/Exception;
    nop

    .line 400
    .end local v2    # "e":Ljava/lang/Exception;
    :cond_27
    :goto_27
    return-object v1
.end method

.method public final checkInstallerOrigin(Ljava/lang/String;Ljava/lang/String;)Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;
    .registers 11
    .param p1, "packageName"    # Ljava/lang/String;
    .param p2, "installerPackageName"    # Ljava/lang/String;

    .line 109
    move-object v0, p2

    check-cast v0, Ljava/lang/CharSequence;

    if-eqz v0, :cond_e

    invoke-static {v0}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_c

    goto :goto_e

    :cond_c
    const/4 v0, 0x0

    goto :goto_f

    :cond_e
    :goto_e
    const/4 v0, 0x1

    :goto_f
    if-eqz v0, :cond_1f

    .line 110
    new-instance v1, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;

    sget-object v2, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->UNKNOWN:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    const/16 v6, 0x8

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-direct/range {v1 .. v7}, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;-><init>(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZILkotlin/jvm/internal/DefaultConstructorMarker;)V

    return-object v1

    .line 112
    :cond_1f
    move-object v0, p2

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v3

    .line 113
    .local v3, "installer":Ljava/lang/String;
    const-string v0, "com.android.vending"

    invoke-static {v3, v0}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_3f

    .line 114
    new-instance v1, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;

    sget-object v2, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->PLAY_STORE:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    const/16 v6, 0x8

    const/4 v7, 0x0

    const/4 v4, 0x1

    const/4 v5, 0x0

    invoke-direct/range {v1 .. v7}, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;-><init>(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZILkotlin/jvm/internal/DefaultConstructorMarker;)V

    goto :goto_4b

    .line 116
    :cond_3f
    new-instance v1, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;

    sget-object v2, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->THIRD_PARTY:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    const/16 v6, 0x8

    const/4 v7, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-direct/range {v1 .. v7}, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;-><init>(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZILkotlin/jvm/internal/DefaultConstructorMarker;)V

    .line 113
    :goto_4b
    return-object v1
.end method

.method public final decryptBlobWithEnvCheck(Lkotlin/jvm/functions/Function0;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 6
    .param p1, "envCheck"    # Lkotlin/jvm/functions/Function0;
    .param p2, "blobBase64"    # Ljava/lang/String;
    .param p3, "keyPart1B64"    # Ljava/lang/String;
    .param p4, "keyPart2B64"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lkotlin/jvm/functions/Function0<",
            "Ljava/lang/Boolean;",
            ">;",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ")",
            "Ljava/lang/String;"
        }
    .end annotation

    const-string v0, "envCheck"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "blobBase64"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart1B64"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart2B64"

    invoke-static {p4, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 339
    new-instance v0, Lcom/antirea/runtime/ReaIntegrity2$$ExternalSyntheticLambda0;

    invoke-direct {v0, p2, p3, p4}, Lcom/antirea/runtime/ReaIntegrity2$$ExternalSyntheticLambda0;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {p0, p1, v0}, Lcom/antirea/runtime/ReaIntegrity2;->decryptWithEnvCheck(Lkotlin/jvm/functions/Function0;Lkotlin/jvm/functions/Function0;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    return-object v0
.end method

.method public final decryptWithEnvCheck(Lkotlin/jvm/functions/Function0;Lkotlin/jvm/functions/Function0;)Ljava/lang/Object;
    .registers 5
    .param p1, "envCheck"    # Lkotlin/jvm/functions/Function0;
    .param p2, "decrypt"    # Lkotlin/jvm/functions/Function0;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "<T:",
            "Ljava/lang/Object;",
            ">(",
            "Lkotlin/jvm/functions/Function0<",
            "Ljava/lang/Boolean;",
            ">;",
            "Lkotlin/jvm/functions/Function0<",
            "+TT;>;)TT;"
        }
    .end annotation

    const-string v0, "envCheck"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "decrypt"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 315
    nop

    .line 316
    const/4 v0, 0x0

    :try_start_c
    invoke-interface {p1}, Lkotlin/jvm/functions/Function0;->invoke()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Boolean;

    invoke-virtual {v1}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v1
    :try_end_16
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_16} :catch_22

    if-eqz v1, :cond_19

    return-object v0

    .line 317
    :cond_19
    nop

    .line 318
    :try_start_1a
    invoke-interface {p2}, Lkotlin/jvm/functions/Function0;->invoke()Ljava/lang/Object;

    move-result-object v0
    :try_end_1e
    .catch Ljava/lang/Exception; {:try_start_1a .. :try_end_1e} :catch_1f

    goto :goto_21

    .line 319
    :catch_1f
    move-exception v1

    .line 320
    .local v1, "e":Ljava/lang/Exception;
    nop

    .end local v1    # "e":Ljava/lang/Exception;
    :goto_21
    goto :goto_24

    .line 322
    :catch_22
    move-exception v1

    .line 323
    .restart local v1    # "e":Ljava/lang/Exception;
    nop

    .line 315
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_24
    return-object v0
.end method

.method public final getInstallerOrigin(Landroid/content/Context;)Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;
    .registers 10
    .param p1, "context"    # Landroid/content/Context;

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 471
    nop

    .line 472
    :try_start_6
    invoke-virtual {p1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    .line 473
    .local v0, "pm":Landroid/content/pm/PackageManager;
    invoke-virtual {p1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    .line 474
    .local v1, "pkg":Ljava/lang/String;
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1e

    if-lt v2, v3, :cond_1d

    .line 475
    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getInstallSourceInfo(Ljava/lang/String;)Landroid/content/pm/InstallSourceInfo;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/pm/InstallSourceInfo;->getInstallingPackageName()Ljava/lang/String;

    move-result-object v2

    goto :goto_21

    .line 478
    :cond_1d
    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getInstallerPackageName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 474
    :goto_21
    nop

    .line 480
    .local v2, "installer":Ljava/lang/String;
    invoke-virtual {p0, v1, v2}, Lcom/antirea/runtime/ReaIntegrity2;->checkInstallerOrigin(Ljava/lang/String;Ljava/lang/String;)Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;

    move-result-object v3
    :try_end_26
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_26} :catch_27

    .end local v0    # "pm":Landroid/content/pm/PackageManager;
    .end local v1    # "pkg":Ljava/lang/String;
    .end local v2    # "installer":Ljava/lang/String;
    goto :goto_36

    .line 481
    :catch_27
    move-exception v0

    .line 482
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;

    sget-object v2, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->UNKNOWN:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    const/16 v6, 0x8

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-direct/range {v1 .. v7}, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;-><init>(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZILkotlin/jvm/internal/DefaultConstructorMarker;)V

    move-object v3, v1

    .line 471
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_36
    return-object v3
.end method

.method public final hashClassBytes(Ljava/io/InputStream;)Ljava/lang/String;
    .registers 18
    .param p1, "stream"    # Ljava/io/InputStream;

    .line 133
    const/4 v1, 0x0

    if-nez p1, :cond_4

    return-object v1

    .line 134
    :cond_4
    nop

    .line 135
    :try_start_5
    move-object/from16 v2, p1

    check-cast v2, Ljava/io/Closeable;
    :try_end_9
    .catch Ljava/lang/Exception; {:try_start_5 .. :try_end_9} :catch_51

    :try_start_9
    move-object v0, v2

    check-cast v0, Ljava/io/InputStream;

    .local v0, "it":Ljava/io/InputStream;
    const/4 v3, 0x0

    .line 136
    .local v3, "$i$a$-use-ReaIntegrity2$hashClassBytes$1":I
    const-string v4, "SHA-256"

    invoke-static {v4}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v4

    .line 137
    .local v4, "digest":Ljava/security/MessageDigest;
    const/16 v5, 0x2000

    new-array v5, v5, [B

    .line 138
    .local v5, "buf":[B
    const/4 v6, 0x0

    .line 139
    .local v6, "n":I
    :goto_18
    invoke-virtual {v0, v5}, Ljava/io/InputStream;->read([B)I

    move-result v7

    move v8, v7

    .line 513
    .local v8, "r":I
    const/4 v9, 0x0

    .line 139
    .local v9, "$i$a$-also-ReaIntegrity2$hashClassBytes$1$1":I
    move v6, v8

    .end local v8    # "r":I
    .end local v9    # "$i$a$-also-ReaIntegrity2$hashClassBytes$1$1":I
    const/4 v8, -0x1

    if-eq v7, v8, :cond_27

    .line 140
    const/4 v7, 0x0

    invoke-virtual {v4, v5, v7, v6}, Ljava/security/MessageDigest;->update([BII)V

    goto :goto_18

    .line 142
    :cond_27
    invoke-virtual {v4}, Ljava/security/MessageDigest;->digest()[B

    move-result-object v7

    const-string v8, "digest(...)"

    invoke-static {v7, v8}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v8, ""

    check-cast v8, Ljava/lang/CharSequence;

    new-instance v13, Lcom/antirea/runtime/ReaIntegrity2$$ExternalSyntheticLambda2;

    invoke-direct {v13}, Lcom/antirea/runtime/ReaIntegrity2$$ExternalSyntheticLambda2;-><init>()V

    const/16 v14, 0x1e

    const/4 v15, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    const/4 v11, 0x0

    const/4 v12, 0x0

    invoke-static/range {v7 .. v15}, Lkotlin/collections/ArraysKt;->joinToString$default([BLjava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v7
    :try_end_44
    .catchall {:try_start_9 .. :try_end_44} :catchall_49

    .line 135
    .end local v0    # "it":Ljava/io/InputStream;
    .end local v3    # "$i$a$-use-ReaIntegrity2$hashClassBytes$1":I
    .end local v4    # "digest":Ljava/security/MessageDigest;
    .end local v5    # "buf":[B
    .end local v6    # "n":I
    :try_start_44
    invoke-static {v2, v1}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V
    :try_end_47
    .catch Ljava/lang/Exception; {:try_start_44 .. :try_end_47} :catch_51

    move-object v1, v7

    goto :goto_53

    :catchall_49
    move-exception v0

    move-object v3, v0

    .end local p1    # "stream":Ljava/io/InputStream;
    :try_start_4b
    throw v3
    :try_end_4c
    .catchall {:try_start_4b .. :try_end_4c} :catchall_4c

    .restart local p1    # "stream":Ljava/io/InputStream;
    :catchall_4c
    move-exception v0

    :try_start_4d
    invoke-static {v2, v3}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    .end local p1    # "stream":Ljava/io/InputStream;
    throw v0
    :try_end_51
    .catch Ljava/lang/Exception; {:try_start_4d .. :try_end_51} :catch_51

    .line 144
    .restart local p1    # "stream":Ljava/io/InputStream;
    :catch_51
    move-exception v0

    .line 145
    .local v0, "e":Ljava/lang/Exception;
    nop

    .line 134
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_53
    return-object v1
.end method

.method public final hashOwnClassBytes(Ljava/lang/Class;)Ljava/lang/String;
    .registers 9
    .param p1, "clazz"    # Ljava/lang/Class;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Class<",
            "*>;)",
            "Ljava/lang/String;"
        }
    .end annotation

    const-string v0, "clazz"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 151
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const/16 v1, 0x2f

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {p1}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "getName(...)"

    invoke-static {v1, v2}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    const/4 v5, 0x4

    const/4 v6, 0x0

    const/16 v2, 0x2e

    const/16 v3, 0x2f

    const/4 v4, 0x0

    invoke-static/range {v1 .. v6}, Lkotlin/text/StringsKt;->replace$default(Ljava/lang/String;CCZILjava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ".class"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 152
    .local v0, "name":Ljava/lang/String;
    invoke-virtual {p1, v0}, Ljava/lang/Class;->getResourceAsStream(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/antirea/runtime/ReaIntegrity2;->hashClassBytes(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v1

    return-object v1
.end method

.method public final hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z
    .registers 8
    .param p1, "a"    # Ljava/lang/String;
    .param p2, "b"    # Ljava/lang/String;

    .line 47
    const-string v0, "toLowerCase(...)"

    move-object v1, p1

    check-cast v1, Ljava/lang/CharSequence;

    const/4 v2, 0x1

    const/4 v3, 0x0

    if-eqz v1, :cond_12

    invoke-static {v1}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_10

    goto :goto_12

    :cond_10
    move v1, v3

    goto :goto_13

    :cond_12
    :goto_12
    move v1, v2

    :goto_13
    if-nez v1, :cond_69

    move-object v1, p2

    check-cast v1, Ljava/lang/CharSequence;

    if-eqz v1, :cond_22

    invoke-static {v1}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_21

    goto :goto_22

    :cond_21
    move v2, v3

    :cond_22
    :goto_22
    if-eqz v2, :cond_25

    goto :goto_69

    .line 48
    :cond_25
    nop

    .line 49
    :try_start_26
    move-object v1, p1

    check-cast v1, Ljava/lang/CharSequence;

    invoke-static {v1}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    sget-object v2, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v1, v2}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v1

    invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p0, v1}, Lcom/antirea/runtime/ReaIntegrity2;->hexToBytes(Ljava/lang/String;)[B

    move-result-object v1

    .line 50
    .local v1, "ba":[B
    move-object v2, p2

    check-cast v2, Ljava/lang/CharSequence;

    invoke-static {v2}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v2

    sget-object v4, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v2, v4}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p0, v2}, Lcom/antirea/runtime/ReaIntegrity2;->hexToBytes(Ljava/lang/String;)[B

    move-result-object v0

    .line 51
    .local v0, "bb":[B
    if-eqz v1, :cond_65

    if-nez v0, :cond_5b

    goto :goto_65

    .line 52
    :cond_5b
    array-length v2, v1

    array-length v4, v0

    if-eq v2, v4, :cond_60

    return v3

    .line 53
    :cond_60
    invoke-static {v1, v0}, Ljava/security/MessageDigest;->isEqual([B[B)Z

    move-result v3
    :try_end_64
    .catch Ljava/lang/Exception; {:try_start_26 .. :try_end_64} :catch_66

    .end local v0    # "bb":[B
    .end local v1    # "ba":[B
    goto :goto_68

    .line 51
    .restart local v0    # "bb":[B
    .restart local v1    # "ba":[B
    :cond_65
    :goto_65
    return v3

    .line 54
    .end local v0    # "bb":[B
    .end local v1    # "ba":[B
    :catch_66
    move-exception v0

    .line 55
    .local v0, "e":Ljava/lang/Exception;
    nop

    .line 48
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_68
    return v3

    .line 47
    :cond_69
    :goto_69
    return v3
.end method

.method public final hexToBytes(Ljava/lang/String;)[B
    .registers 13
    .param p1, "hex"    # Ljava/lang/String;

    const-string v0, "hex"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 61
    move-object v0, p1

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 62
    .local v0, "clean":Ljava/lang/String;
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    rem-int/lit8 v1, v1, 0x2

    const/4 v2, 0x0

    if-eqz v1, :cond_1a

    return-object v2

    .line 63
    :cond_1a
    move-object v1, v0

    check-cast v1, Ljava/lang/CharSequence;

    .local v1, "$this$all$iv":Ljava/lang/CharSequence;
    const/4 v3, 0x0

    .line 511
    .local v3, "$i$f$all":I
    const/4 v4, 0x0

    move v5, v4

    :goto_20
    invoke-interface {v1}, Ljava/lang/CharSequence;->length()I

    move-result v6

    const/4 v7, 0x1

    if-ge v5, v6, :cond_5d

    invoke-interface {v1, v5}, Ljava/lang/CharSequence;->charAt(I)C

    move-result v6

    .local v6, "element$iv":C
    move v8, v6

    .local v8, "it":C
    const/4 v9, 0x0

    .line 63
    .local v9, "$i$a$-all-ReaIntegrity2$hexToBytes$1":I
    const/16 v10, 0x30

    if-gt v10, v8, :cond_37

    const/16 v10, 0x3a

    if-ge v8, v10, :cond_37

    move v10, v7

    goto :goto_38

    :cond_37
    move v10, v4

    :goto_38
    if-nez v10, :cond_56

    const/16 v10, 0x61

    if-gt v10, v8, :cond_44

    const/16 v10, 0x67

    if-ge v8, v10, :cond_44

    move v10, v7

    goto :goto_45

    :cond_44
    move v10, v4

    :goto_45
    if-nez v10, :cond_56

    const/16 v10, 0x41

    if-gt v10, v8, :cond_51

    const/16 v10, 0x47

    if-ge v8, v10, :cond_51

    move v10, v7

    goto :goto_52

    :cond_51
    move v10, v4

    :goto_52
    if-eqz v10, :cond_55

    goto :goto_56

    :cond_55
    move v7, v4

    .line 511
    .end local v8    # "it":C
    .end local v9    # "$i$a$-all-ReaIntegrity2$hexToBytes$1":I
    :cond_56
    :goto_56
    if-nez v7, :cond_5a

    move v7, v4

    goto :goto_5e

    .end local v6    # "element$iv":C
    :cond_5a
    add-int/lit8 v5, v5, 0x1

    goto :goto_20

    .line 512
    :cond_5d
    nop

    .line 63
    .end local v1    # "$this$all$iv":Ljava/lang/CharSequence;
    .end local v3    # "$i$f$all":I
    :goto_5e
    if-nez v7, :cond_61

    return-object v2

    .line 64
    :cond_61
    nop

    .line 65
    :try_start_62
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    div-int/lit8 v1, v1, 0x2

    new-array v3, v1, [B

    :goto_6a
    if-ge v4, v1, :cond_89

    .line 66
    mul-int/lit8 v5, v4, 0x2

    add-int/lit8 v6, v5, 0x2

    invoke-virtual {v0, v5, v6}, Ljava/lang/String;->substring(II)Ljava/lang/String;

    move-result-object v5

    const-string v6, "substring(...)"

    invoke-static {v5, v6}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    const/16 v6, 0x10

    invoke-static {v6}, Lkotlin/text/CharsKt;->checkRadix(I)I

    move-result v6

    invoke-static {v5, v6}, Ljava/lang/Integer;->parseInt(Ljava/lang/String;I)I

    move-result v5

    int-to-byte v5, v5

    aput-byte v5, v3, v4
    :try_end_86
    .catch Ljava/lang/Exception; {:try_start_62 .. :try_end_86} :catch_8b

    .line 65
    add-int/lit8 v4, v4, 0x1

    goto :goto_6a

    :cond_89
    move-object v2, v3

    goto :goto_8d

    .line 68
    :catch_8b
    move-exception v1

    .line 69
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 64
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_8d
    return-object v2
.end method

.method public final varargs invokeReflectively(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;
    .registers 23
    .param p1, "target"    # Ljava/lang/Object;
    .param p2, "methodName"    # Ljava/lang/String;
    .param p3, "args"    # [Ljava/lang/Object;

    move-object/from16 v1, p1

    move-object/from16 v2, p2

    move-object/from16 v3, p3

    const-string v0, "target"

    invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "methodName"

    invoke-static {v2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "args"

    invoke-static {v3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 359
    nop

    .line 360
    :try_start_16
    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Class;->getMethods()[Ljava/lang/reflect/Method;

    move-result-object v0

    const-string v5, "getMethods(...)"

    invoke-static {v0, v5}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    check-cast v0, [Ljava/lang/Object;

    .line 361
    nop

    .local v0, "$this$filter$iv":[Ljava/lang/Object;
    const/4 v5, 0x0

    .line 514
    .local v5, "$i$f$filter":I
    new-instance v6, Ljava/util/ArrayList;

    invoke-direct {v6}, Ljava/util/ArrayList;-><init>()V

    check-cast v6, Ljava/util/Collection;

    .local v6, "destination$iv$iv":Ljava/util/Collection;
    move-object v7, v0

    .local v7, "$this$filterTo$iv$iv":[Ljava/lang/Object;
    const/4 v8, 0x0

    .line 515
    .local v8, "$i$f$filterTo":I
    array-length v9, v7

    const/4 v11, 0x0

    :goto_32
    if-ge v11, v9, :cond_58

    aget-object v13, v7, v11

    .local v13, "element$iv$iv":Ljava/lang/Object;
    move-object v14, v13

    check-cast v14, Ljava/lang/reflect/Method;
    :try_end_39
    .catch Ljava/lang/Exception; {:try_start_16 .. :try_end_39} :catch_14d

    .local v14, "it":Ljava/lang/reflect/Method;
    const/4 v15, 0x0

    .line 361
    .local v15, "$i$a$-filter-ReaIntegrity2$invokeReflectively$candidates$1":I
    const/16 v16, 0x0

    :try_start_3c
    invoke-virtual {v14}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;

    move-result-object v4

    invoke-static {v4, v2}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_4f

    invoke-virtual {v14}, Ljava/lang/reflect/Method;->getParameterCount()I

    move-result v4

    array-length v10, v3

    if-ne v4, v10, :cond_4f

    const/4 v12, 0x1

    goto :goto_50

    :cond_4f
    const/4 v12, 0x0

    .line 515
    .end local v14    # "it":Ljava/lang/reflect/Method;
    .end local v15    # "$i$a$-filter-ReaIntegrity2$invokeReflectively$candidates$1":I
    :goto_50
    if-eqz v12, :cond_55

    invoke-interface {v6, v13}, Ljava/util/Collection;->add(Ljava/lang/Object;)Z

    .end local v13    # "element$iv$iv":Ljava/lang/Object;
    :cond_55
    add-int/lit8 v11, v11, 0x1

    goto :goto_32

    .line 516
    :cond_58
    const/16 v16, 0x0

    .end local v6    # "destination$iv$iv":Ljava/util/Collection;
    .end local v7    # "$this$filterTo$iv$iv":[Ljava/lang/Object;
    .end local v8    # "$i$f$filterTo":I
    move-object v4, v6

    check-cast v4, Ljava/util/List;

    .line 514
    nop

    .end local v0    # "$this$filter$iv":[Ljava/lang/Object;
    .end local v5    # "$i$f$filter":I
    check-cast v4, Ljava/util/Collection;

    .line 362
    invoke-virtual {v1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Class;->getDeclaredMethods()[Ljava/lang/reflect/Method;

    move-result-object v0

    const-string v5, "getDeclaredMethods(...)"

    invoke-static {v0, v5}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    check-cast v0, [Ljava/lang/Object;

    .line 363
    nop

    .restart local v0    # "$this$filter$iv":[Ljava/lang/Object;
    const/4 v5, 0x0

    .line 517
    .restart local v5    # "$i$f$filter":I
    new-instance v6, Ljava/util/ArrayList;

    invoke-direct {v6}, Ljava/util/ArrayList;-><init>()V

    check-cast v6, Ljava/util/Collection;

    .restart local v6    # "destination$iv$iv":Ljava/util/Collection;
    move-object v7, v0

    .restart local v7    # "$this$filterTo$iv$iv":[Ljava/lang/Object;
    const/4 v8, 0x0

    .line 518
    .restart local v8    # "$i$f$filterTo":I
    array-length v9, v7

    const/4 v10, 0x0

    :goto_7c
    if-ge v10, v9, :cond_a0

    aget-object v11, v7, v10

    .local v11, "element$iv$iv":Ljava/lang/Object;
    move-object v13, v11

    check-cast v13, Ljava/lang/reflect/Method;

    .local v13, "it":Ljava/lang/reflect/Method;
    const/4 v14, 0x0

    .line 363
    .local v14, "$i$a$-filter-ReaIntegrity2$invokeReflectively$candidates$2":I
    invoke-virtual {v13}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;

    move-result-object v15

    invoke-static {v15, v2}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v15

    if-eqz v15, :cond_97

    invoke-virtual {v13}, Ljava/lang/reflect/Method;->getParameterCount()I

    move-result v15

    array-length v12, v3

    if-ne v15, v12, :cond_97

    const/4 v12, 0x1

    goto :goto_98

    :cond_97
    const/4 v12, 0x0

    .line 518
    .end local v13    # "it":Ljava/lang/reflect/Method;
    .end local v14    # "$i$a$-filter-ReaIntegrity2$invokeReflectively$candidates$2":I
    :goto_98
    if-eqz v12, :cond_9d

    invoke-interface {v6, v11}, Ljava/util/Collection;->add(Ljava/lang/Object;)Z

    .end local v11    # "element$iv$iv":Ljava/lang/Object;
    :cond_9d
    add-int/lit8 v10, v10, 0x1

    goto :goto_7c

    .line 519
    :cond_a0
    nop

    .end local v6    # "destination$iv$iv":Ljava/util/Collection;
    .end local v7    # "$this$filterTo$iv$iv":[Ljava/lang/Object;
    .end local v8    # "$i$f$filterTo":I
    check-cast v6, Ljava/util/List;

    .line 517
    nop

    .end local v0    # "$this$filter$iv":[Ljava/lang/Object;
    .end local v5    # "$i$f$filter":I
    check-cast v6, Ljava/lang/Iterable;

    .line 360
    invoke-static {v4, v6}, Lkotlin/collections/CollectionsKt;->plus(Ljava/util/Collection;Ljava/lang/Iterable;)Ljava/util/List;

    move-result-object v0

    move-object v4, v0

    .line 364
    .local v4, "candidates":Ljava/util/List;
    move-object v0, v4

    check-cast v0, Ljava/lang/Iterable;

    .local v0, "$this$firstOrNull$iv":Ljava/lang/Iterable;
    const/4 v5, 0x0

    .line 520
    .local v5, "$i$f$firstOrNull":I
    invoke-interface {v0}, Ljava/lang/Iterable;->iterator()Ljava/util/Iterator;

    move-result-object v6

    :goto_b3
    invoke-interface {v6}, Ljava/util/Iterator;->hasNext()Z

    move-result v7

    if-eqz v7, :cond_127

    invoke-interface {v6}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v7

    .local v7, "element$iv":Ljava/lang/Object;
    move-object v8, v7

    check-cast v8, Ljava/lang/reflect/Method;

    .local v8, "m":Ljava/lang/reflect/Method;
    const/4 v9, 0x0

    .line 365
    .local v9, "$i$a$-firstOrNull-ReaIntegrity2$invokeReflectively$method$1":I
    invoke-virtual {v8}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v10

    .line 366
    .local v10, "params":[Ljava/lang/Class;
    invoke-static {v10}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    invoke-static {v10}, Lkotlin/collections/ArraysKt;->getIndices([Ljava/lang/Object;)Lkotlin/ranges/IntRange;

    move-result-object v11

    check-cast v11, Ljava/lang/Iterable;

    .local v11, "$this$all$iv":Ljava/lang/Iterable;
    const/4 v12, 0x0

    .line 521
    .local v12, "$i$f$all":I
    instance-of v13, v11, Ljava/util/Collection;

    if-eqz v13, :cond_e0

    move-object v13, v11

    check-cast v13, Ljava/util/Collection;

    invoke-interface {v13}, Ljava/util/Collection;->isEmpty()Z

    move-result v13

    if-eqz v13, :cond_e0

    move-object/from16 v18, v0

    const/4 v0, 0x1

    goto :goto_11e

    .line 522
    :cond_e0
    invoke-interface {v11}, Ljava/lang/Iterable;->iterator()Ljava/util/Iterator;

    move-result-object v13

    :goto_e4
    invoke-interface {v13}, Ljava/util/Iterator;->hasNext()Z

    move-result v14

    if-eqz v14, :cond_11b

    move-object v14, v13

    check-cast v14, Lkotlin/collections/IntIterator;

    invoke-virtual {v14}, Lkotlin/collections/IntIterator;->nextInt()I

    move-result v14

    .local v14, "element$iv":I
    move v15, v14

    .local v15, "i":I
    const/16 v17, 0x0

    .line 367
    .local v17, "$i$a$-all-ReaIntegrity2$invokeReflectively$method$1$1":I
    aget-object v18, v3, v15

    if-eqz v18, :cond_10f

    move-object/from16 v18, v0

    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .local v18, "$this$firstOrNull$iv":Ljava/lang/Iterable;
    aget-object v0, v10, v15

    aget-object v2, v3, v15

    invoke-virtual {v0, v2}, Ljava/lang/Class;->isInstance(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_111

    .line 368
    aget-object v0, v10, v15

    invoke-virtual {v0}, Ljava/lang/Class;->isPrimitive()Z

    move-result v0

    if-eqz v0, :cond_10d

    goto :goto_111

    :cond_10d
    const/4 v0, 0x0

    goto :goto_112

    .line 367
    .end local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_10f
    move-object/from16 v18, v0

    .line 368
    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_111
    :goto_111
    const/4 v0, 0x1

    .line 522
    .end local v15    # "i":I
    .end local v17    # "$i$a$-all-ReaIntegrity2$invokeReflectively$method$1$1":I
    :goto_112
    if-nez v0, :cond_116

    const/4 v0, 0x0

    goto :goto_11e

    :cond_116
    move-object/from16 v2, p2

    move-object/from16 v0, v18

    goto :goto_e4

    .line 523
    .end local v14    # "element$iv":I
    .end local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_11b
    move-object/from16 v18, v0

    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    const/4 v0, 0x1

    .line 369
    .end local v11    # "$this$all$iv":Ljava/lang/Iterable;
    .end local v12    # "$i$f$all":I
    :goto_11e
    nop

    .line 520
    .end local v8    # "m":Ljava/lang/reflect/Method;
    .end local v9    # "$i$a$-firstOrNull-ReaIntegrity2$invokeReflectively$method$1":I
    .end local v10    # "params":[Ljava/lang/Class;
    if-eqz v0, :cond_122

    goto :goto_12b

    :cond_122
    move-object/from16 v2, p2

    move-object/from16 v0, v18

    goto :goto_b3

    .line 524
    .end local v7    # "element$iv":Ljava/lang/Object;
    .end local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_127
    move-object/from16 v18, v0

    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    move-object/from16 v7, v16

    .line 364
    .end local v5    # "$i$f$firstOrNull":I
    .end local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :goto_12b
    check-cast v7, Ljava/lang/reflect/Method;

    if-nez v7, :cond_139

    .line 370
    invoke-static {v4}, Lkotlin/collections/CollectionsKt;->firstOrNull(Ljava/util/List;)Ljava/lang/Object;

    move-result-object v0

    move-object v7, v0

    check-cast v7, Ljava/lang/reflect/Method;
    :try_end_136
    .catch Ljava/lang/Exception; {:try_start_3c .. :try_end_136} :catch_14b

    .line 364
    if-nez v7, :cond_139

    .line 370
    return-object v16

    .line 371
    .local v7, "method":Ljava/lang/reflect/Method;
    :cond_139
    nop

    .line 372
    const/4 v0, 0x1

    :try_start_13b
    invoke-virtual {v7, v0}, Ljava/lang/reflect/Method;->setAccessible(Z)V
    :try_end_13e
    .catch Ljava/lang/Exception; {:try_start_13b .. :try_end_13e} :catch_13f

    goto :goto_140

    .line 373
    :catch_13f
    move-exception v0

    .line 377
    :goto_140
    :try_start_140
    array-length v0, v3

    invoke-static {v3, v0}, Ljava/util/Arrays;->copyOf([Ljava/lang/Object;I)[Ljava/lang/Object;

    move-result-object v0

    invoke-virtual {v7, v1, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0
    :try_end_149
    .catch Ljava/lang/Exception; {:try_start_140 .. :try_end_149} :catch_14b

    move-object v4, v0

    .end local v4    # "candidates":Ljava/util/List;
    .end local v7    # "method":Ljava/lang/reflect/Method;
    goto :goto_152

    .line 378
    :catch_14b
    move-exception v0

    goto :goto_150

    :catch_14d
    move-exception v0

    const/16 v16, 0x0

    .line 379
    .local v0, "e":Ljava/lang/Exception;
    :goto_150
    move-object/from16 v4, v16

    .line 359
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_152
    return-object v4
.end method

.method public final loadClassFromDex(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/ClassLoader;)Ljava/lang/Class;
    .registers 9
    .param p1, "dexPath"    # Ljava/lang/String;
    .param p2, "optimizedDir"    # Ljava/lang/String;
    .param p3, "className"    # Ljava/lang/String;
    .param p4, "parent"    # Ljava/lang/ClassLoader;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            "Ljava/lang/ClassLoader;",
            ")",
            "Ljava/lang/Class<",
            "*>;"
        }
    .end annotation

    const-string v0, "dexPath"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "optimizedDir"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "className"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "parent"

    invoke-static {p4, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 502
    nop

    .line 503
    const/4 v0, 0x0

    :try_start_16
    new-instance v1, Ldalvik/system/DexClassLoader;

    invoke-direct {v1, p1, p2, v0, p4}, Ldalvik/system/DexClassLoader;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/ClassLoader;)V

    .line 504
    .local v1, "loader":Ldalvik/system/DexClassLoader;
    move-object v2, v1

    check-cast v2, Ljava/lang/ClassLoader;

    const/4 v3, 0x1

    invoke-static {p3, v3, v2}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v0
    :try_end_23
    .catch Ljava/lang/Exception; {:try_start_16 .. :try_end_23} :catch_24

    .end local v1    # "loader":Ldalvik/system/DexClassLoader;
    goto :goto_26

    .line 505
    :catch_24
    move-exception v1

    .line 506
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 502
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_26
    return-object v0
.end method

.method public final loadClassFromJar(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Class;
    .registers 8
    .param p1, "jarPath"    # Ljava/lang/String;
    .param p2, "className"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ")",
            "Ljava/lang/Class<",
            "*>;"
        }
    .end annotation

    const-string v0, "jarPath"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "className"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 419
    nop

    .line 420
    const/4 v0, 0x0

    :try_start_c
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 421
    .local v1, "file":Ljava/io/File;
    invoke-virtual {v1}, Ljava/io/File;->canRead()Z

    move-result v2

    if-nez v2, :cond_18

    return-object v0

    .line 422
    :cond_18
    new-instance v2, Ljava/net/URLClassLoader;

    invoke-virtual {v1}, Ljava/io/File;->toURI()Ljava/net/URI;

    move-result-object v3

    invoke-virtual {v3}, Ljava/net/URI;->toURL()Ljava/net/URL;

    move-result-object v3

    filled-new-array {v3}, [Ljava/net/URL;

    move-result-object v3

    invoke-virtual {p0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/Class;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v4

    invoke-direct {v2, v3, v4}, Ljava/net/URLClassLoader;-><init>([Ljava/net/URL;Ljava/lang/ClassLoader;)V

    .line 423
    .local v2, "loader":Ljava/net/URLClassLoader;
    move-object v3, v2

    check-cast v3, Ljava/lang/ClassLoader;

    const/4 v4, 0x1

    invoke-static {p2, v4, v3}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v0
    :try_end_39
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_39} :catch_3a

    .end local v1    # "file":Ljava/io/File;
    .end local v2    # "loader":Ljava/net/URLClassLoader;
    goto :goto_3c

    .line 424
    :catch_3a
    move-exception v1

    .line 425
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 419
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_3c
    return-object v0
.end method

.method public final loadClassFromJarBytes([BLjava/lang/String;Ljava/io/File;)Ljava/lang/Class;
    .registers 8
    .param p1, "jarBytes"    # [B
    .param p2, "className"    # Ljava/lang/String;
    .param p3, "tempDir"    # Ljava/io/File;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "([B",
            "Ljava/lang/String;",
            "Ljava/io/File;",
            ")",
            "Ljava/lang/Class<",
            "*>;"
        }
    .end annotation

    const-string v0, "jarBytes"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "className"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "tempDir"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 447
    nop

    .line 448
    const/4 v0, 0x0

    :try_start_11
    invoke-virtual {p3}, Ljava/io/File;->isDirectory()Z

    move-result v1

    if-nez v1, :cond_18

    return-object v0

    .line 449
    :cond_18
    const-string v1, "rea-dyn-"

    const-string v2, ".jar"

    invoke-static {v1, v2, p3}, Ljava/io/File;->createTempFile(Ljava/lang/String;Ljava/lang/String;Ljava/io/File;)Ljava/io/File;

    move-result-object v1

    .line 450
    .local v1, "tmp":Ljava/io/File;
    invoke-static {v1}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    invoke-static {v1, p1}, Lkotlin/io/FilesKt;->writeBytes(Ljava/io/File;[B)V

    .line 451
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v2

    const-string v3, "getAbsolutePath(...)"

    invoke-static {v2, v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p0, v2, p2}, Lcom/antirea/runtime/ReaIntegrity2;->loadClassFromJar(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0
    :try_end_33
    .catch Ljava/lang/Exception; {:try_start_11 .. :try_end_33} :catch_34

    .end local v1    # "tmp":Ljava/io/File;
    goto :goto_36

    .line 452
    :catch_34
    move-exception v1

    .line 453
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 447
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_36
    return-object v0
.end method

.method public final loadClassFromJarFile(Ljava/io/File;Ljava/lang/String;)Ljava/lang/Class;
    .registers 5
    .param p1, "jarFile"    # Ljava/io/File;
    .param p2, "className"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/io/File;",
            "Ljava/lang/String;",
            ")",
            "Ljava/lang/Class<",
            "*>;"
        }
    .end annotation

    const-string v0, "jarFile"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "className"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 436
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v0

    const-string v1, "getAbsolutePath(...)"

    invoke-static {v0, v1}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p0, v0, p2}, Lcom/antirea/runtime/ReaIntegrity2;->loadClassFromJar(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    return-object v0
.end method

.method public final sha256Hex([B)Ljava/lang/String;
    .registers 12
    .param p1, "bytes"    # [B

    const-string v0, "bytes"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 36
    const-string v0, "SHA-256"

    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/security/MessageDigest;->digest([B)[B

    move-result-object v1

    const-string v0, "digest(...)"

    invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    .line 37
    const-string v0, ""

    move-object v2, v0

    check-cast v2, Ljava/lang/CharSequence;

    new-instance v7, Lcom/antirea/runtime/ReaIntegrity2$$ExternalSyntheticLambda1;

    invoke-direct {v7}, Lcom/antirea/runtime/ReaIntegrity2$$ExternalSyntheticLambda1;-><init>()V

    const/16 v8, 0x1e

    const/4 v9, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    const/4 v6, 0x0

    invoke-static/range {v1 .. v9}, Lkotlin/collections/ArraysKt;->joinToString$default([BLjava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    .line 36
    return-object v0
.end method

.method public final verifyConfigFileHash(Ljava/io/File;Ljava/lang/String;)Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;
    .registers 7
    .param p1, "file"    # Ljava/io/File;
    .param p2, "pinnedHex"    # Ljava/lang/String;

    const-string v0, "file"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "pinnedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 204
    nop

    .line 205
    const/4 v0, 0x0

    const/4 v1, 0x0

    :try_start_d
    invoke-virtual {p1}, Ljava/io/File;->canRead()Z

    move-result v2

    if-nez v2, :cond_19

    new-instance v2, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v2, v1, v0}, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    return-object v2

    .line 206
    :cond_19
    invoke-static {p1}, Lkotlin/io/FilesKt;->readBytes(Ljava/io/File;)[B

    move-result-object v2

    invoke-virtual {p0, v2, p2}, Lcom/antirea/runtime/ReaIntegrity2;->verifyConfigHash([BLjava/lang/String;)Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;

    move-result-object v0
    :try_end_21
    .catch Ljava/lang/Exception; {:try_start_d .. :try_end_21} :catch_22

    goto :goto_29

    .line 207
    :catch_22
    move-exception v2

    .line 208
    .local v2, "e":Ljava/lang/Exception;
    new-instance v3, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v3, v1, v0}, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    move-object v0, v3

    .line 204
    .end local v2    # "e":Ljava/lang/Exception;
    :goto_29
    return-object v0
.end method

.method public final verifyConfigHash([BLjava/lang/String;)Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;
    .registers 8
    .param p1, "configBytes"    # [B
    .param p2, "pinnedHex"    # Ljava/lang/String;

    const-string v0, "pinnedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 192
    const/4 v0, 0x0

    const/4 v1, 0x0

    if-eqz p1, :cond_37

    array-length v2, p1

    if-nez v2, :cond_e

    const/4 v2, 0x1

    goto :goto_f

    :cond_e
    move v2, v1

    :goto_f
    if-eqz v2, :cond_12

    goto :goto_37

    .line 193
    :cond_12
    move-object v2, p2

    check-cast v2, Ljava/lang/CharSequence;

    invoke-static {v2}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v2

    if-eqz v2, :cond_21

    new-instance v2, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v2, v1, v0}, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    return-object v2

    .line 194
    :cond_21
    nop

    .line 195
    :try_start_22
    invoke-virtual {p0, p1}, Lcom/antirea/runtime/ReaIntegrity2;->sha256Hex([B)Ljava/lang/String;

    move-result-object v2

    .line 196
    .local v2, "actual":Ljava/lang/String;
    new-instance v3, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-virtual {p0, v2, p2}, Lcom/antirea/runtime/ReaIntegrity2;->hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v4

    invoke-direct {v3, v4, v2}, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V
    :try_end_2f
    .catch Ljava/lang/Exception; {:try_start_22 .. :try_end_2f} :catch_30

    .end local v2    # "actual":Ljava/lang/String;
    goto :goto_36

    .line 197
    :catch_30
    move-exception v2

    .line 198
    .local v2, "e":Ljava/lang/Exception;
    new-instance v3, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v3, v1, v0}, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    .line 194
    .end local v2    # "e":Ljava/lang/Exception;
    :goto_36
    return-object v3

    .line 192
    :cond_37
    :goto_37
    new-instance v2, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v2, v1, v0}, Lcom/antirea/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    return-object v2
.end method

.method public final verifyNativeLibHashes(Ljava/util/Map;Ljava/util/Map;)Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;
    .registers 14
    .param p1, "libs"    # Ljava/util/Map;
    .param p2, "expectedHashes"    # Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "[B>;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;)",
            "Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;"
        }
    .end annotation

    const-string v0, "libs"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHashes"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 274
    nop

    .line 275
    const/4 v0, 0x0

    :try_start_c
    invoke-interface {p2}, Ljava/util/Map;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_20

    .line 276
    new-instance v1, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v3

    invoke-direct {v1, v0, v2, v3, v0}, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V

    return-object v1

    .line 278
    :cond_20
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    check-cast v1, Ljava/util/List;

    .line 279
    .local v1, "failed":Ljava/util/List;
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    check-cast v2, Ljava/util/List;

    .line 280
    .local v2, "missing":Ljava/util/List;
    const/4 v3, 0x0

    .line 281
    .local v3, "checked":I
    invoke-interface {p2}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v4

    invoke-interface {v4}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v4

    :cond_37
    :goto_37
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_79

    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/Map$Entry;

    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/lang/String;

    .local v6, "name":Ljava/lang/String;
    invoke-interface {v5}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/String;

    .line 282
    .local v5, "expectedHex":Ljava/lang/String;
    invoke-interface {p1, v6}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v7

    check-cast v7, [B

    .line 283
    .local v7, "bytes":[B
    if-nez v7, :cond_5b

    .line 284
    invoke-interface {v2, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 285
    goto :goto_37

    .line 287
    :cond_5b
    const-string v8, ".so"

    const/4 v9, 0x2

    const/4 v10, 0x0

    invoke-static {v6, v8, v0, v9, v10}, Lkotlin/text/StringsKt;->endsWith$default(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result v8

    if-nez v8, :cond_69

    .line 288
    invoke-interface {v1, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 289
    goto :goto_37

    .line 291
    :cond_69
    add-int/lit8 v3, v3, 0x1

    .line 292
    invoke-virtual {p0, v7}, Lcom/antirea/runtime/ReaIntegrity2;->sha256Hex([B)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {p0, v8, v5}, Lcom/antirea/runtime/ReaIntegrity2;->hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v8

    if-nez v8, :cond_37

    invoke-interface {v1, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_37

    .line 294
    .end local v5    # "expectedHex":Ljava/lang/String;
    .end local v6    # "name":Ljava/lang/String;
    .end local v7    # "bytes":[B
    :cond_79
    new-instance v4, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;

    invoke-interface {v1}, Ljava/util/List;->isEmpty()Z

    move-result v5

    if-eqz v5, :cond_89

    invoke-interface {v2}, Ljava/util/List;->isEmpty()Z

    move-result v5

    if-eqz v5, :cond_89

    const/4 v5, 0x1

    goto :goto_8a

    :cond_89
    move v5, v0

    :goto_8a
    invoke-direct {v4, v5, v1, v2, v3}, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V
    :try_end_8d
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_8d} :catch_8e

    .end local v1    # "failed":Ljava/util/List;
    .end local v2    # "missing":Ljava/util/List;
    .end local v3    # "checked":I
    goto :goto_9c

    .line 295
    :catch_8e
    move-exception v1

    .line 296
    .local v1, "e":Ljava/lang/Exception;
    new-instance v4, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v3

    invoke-direct {v4, v0, v2, v3, v0}, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V

    .line 274
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_9c
    return-object v4
.end method

.method public final verifyOwnClassHash(Ljava/lang/Class;Ljava/lang/String;)Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;
    .registers 10
    .param p1, "clazz"    # Ljava/lang/Class;
    .param p2, "expectedHex"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/Class<",
            "*>;",
            "Ljava/lang/String;",
            ")",
            "Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;"
        }
    .end annotation

    const-string v0, "clazz"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 172
    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const/16 v1, 0x2f

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {p1}, Ljava/lang/Class;->getName()Ljava/lang/String;

    move-result-object v1

    const-string v2, "getName(...)"

    invoke-static {v1, v2}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    const/4 v5, 0x4

    const/4 v6, 0x0

    const/16 v2, 0x2e

    const/16 v3, 0x2f

    const/4 v4, 0x0

    invoke-static/range {v1 .. v6}, Lkotlin/text/StringsKt;->replace$default(Ljava/lang/String;CCZILjava/lang/Object;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ".class"

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    .line 173
    .local v0, "name":Ljava/lang/String;
    invoke-virtual {p1, v0}, Ljava/lang/Class;->getResourceAsStream(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v1

    invoke-virtual {p0, v1, p2}, Lcom/antirea/runtime/ReaIntegrity2;->verifySelfHash(Ljava/io/InputStream;Ljava/lang/String;)Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;

    move-result-object v1

    return-object v1
.end method

.method public final verifyResourceHashes(Ljava/util/Map;Ljava/util/Map;)Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;
    .registers 12
    .param p1, "entries"    # Ljava/util/Map;
    .param p2, "expectedHashes"    # Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "[B>;",
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;)",
            "Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;"
        }
    .end annotation

    const-string v0, "entries"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHashes"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 237
    nop

    .line 238
    const/4 v0, 0x0

    :try_start_c
    invoke-interface {p2}, Ljava/util/Map;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_20

    .line 239
    new-instance v1, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v3

    invoke-direct {v1, v0, v2, v3, v0}, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V

    return-object v1

    .line 241
    :cond_20
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    check-cast v1, Ljava/util/List;

    .line 242
    .local v1, "failed":Ljava/util/List;
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    check-cast v2, Ljava/util/List;

    .line 243
    .local v2, "missing":Ljava/util/List;
    const/4 v3, 0x0

    .line 244
    .local v3, "checked":I
    invoke-interface {p2}, Ljava/util/Map;->entrySet()Ljava/util/Set;

    move-result-object v4

    invoke-interface {v4}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

    move-result-object v4

    :cond_37
    :goto_37
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_6b

    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/util/Map$Entry;

    invoke-interface {v5}, Ljava/util/Map$Entry;->getKey()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/lang/String;

    .local v6, "name":Ljava/lang/String;
    invoke-interface {v5}, Ljava/util/Map$Entry;->getValue()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/String;

    .line 245
    .local v5, "expectedHex":Ljava/lang/String;
    invoke-interface {p1, v6}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v7

    check-cast v7, [B

    .line 246
    .local v7, "bytes":[B
    if-nez v7, :cond_5b

    .line 247
    invoke-interface {v2, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 248
    goto :goto_37

    .line 250
    :cond_5b
    add-int/lit8 v3, v3, 0x1

    .line 251
    invoke-virtual {p0, v7}, Lcom/antirea/runtime/ReaIntegrity2;->sha256Hex([B)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {p0, v8, v5}, Lcom/antirea/runtime/ReaIntegrity2;->hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v8

    if-nez v8, :cond_37

    invoke-interface {v1, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_37

    .line 253
    .end local v5    # "expectedHex":Ljava/lang/String;
    .end local v6    # "name":Ljava/lang/String;
    .end local v7    # "bytes":[B
    :cond_6b
    new-instance v4, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;

    invoke-interface {v1}, Ljava/util/List;->isEmpty()Z

    move-result v5

    if-eqz v5, :cond_7b

    invoke-interface {v2}, Ljava/util/List;->isEmpty()Z

    move-result v5

    if-eqz v5, :cond_7b

    const/4 v5, 0x1

    goto :goto_7c

    :cond_7b
    move v5, v0

    :goto_7c
    invoke-direct {v4, v5, v1, v2, v3}, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V
    :try_end_7f
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_7f} :catch_80

    .end local v1    # "failed":Ljava/util/List;
    .end local v2    # "missing":Ljava/util/List;
    .end local v3    # "checked":I
    goto :goto_8e

    .line 254
    :catch_80
    move-exception v1

    .line 255
    .local v1, "e":Ljava/lang/Exception;
    new-instance v4, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v3

    invoke-direct {v4, v0, v2, v3, v0}, Lcom/antirea/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V

    .line 237
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_8e
    return-object v4
.end method

.method public final verifySelfHash(Ljava/io/InputStream;Ljava/lang/String;)Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;
    .registers 8
    .param p1, "stream"    # Ljava/io/InputStream;
    .param p2, "expectedHex"    # Ljava/lang/String;

    const-string v0, "expectedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 162
    nop

    .line 163
    const/4 v0, 0x0

    const/4 v1, 0x0

    :try_start_8
    invoke-virtual {p0, p1}, Lcom/antirea/runtime/ReaIntegrity2;->hashClassBytes(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v2

    if-nez v2, :cond_14

    new-instance v2, Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;

    invoke-direct {v2, v1, v0}, Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;-><init>(ZLjava/lang/String;)V

    return-object v2

    .line 164
    .local v2, "actual":Ljava/lang/String;
    :cond_14
    new-instance v3, Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;

    invoke-virtual {p0, v2, p2}, Lcom/antirea/runtime/ReaIntegrity2;->hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v4

    invoke-direct {v3, v4, v2}, Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;-><init>(ZLjava/lang/String;)V
    :try_end_1d
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_1d} :catch_1e

    .end local v2    # "actual":Ljava/lang/String;
    goto :goto_24

    .line 165
    :catch_1e
    move-exception v2

    .line 166
    .local v2, "e":Ljava/lang/Exception;
    new-instance v3, Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;

    invoke-direct {v3, v1, v0}, Lcom/antirea/runtime/ReaIntegrity2$SelfHashResult;-><init>(ZLjava/lang/String;)V

    .line 162
    .end local v2    # "e":Ljava/lang/Exception;
    :goto_24
    return-object v3
.end method
