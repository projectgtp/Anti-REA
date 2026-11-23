.class public final Lcom/appcore/runtime/ReaIntegrity2;
.super Ljava/lang/Object;
.source "ReaIntegrity2.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;,
        Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;,
        Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;,
        Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;,
        Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;,
        Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;
    }
.end annotation

.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nReaIntegrity2.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ReaIntegrity2.kt\ncom/appcore/runtime/ReaIntegrity2\n+ 2 _Strings.kt\nkotlin/text/StringsKt___StringsKt\n+ 3 fake.kt\nkotlin/jvm/internal/FakeKt\n+ 4 _Arrays.kt\nkotlin/collections/ArraysKt___ArraysKt\n+ 5 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,553:1\n1069#2,2:554\n1#3:556\n3829#4:557\n4344#4,2:558\n3829#4:560\n4344#4,2:561\n295#5:563\n1734#5,3:564\n296#5:567\n*S KotlinDebug\n*F\n+ 1 ReaIntegrity2.kt\ncom/appcore/runtime/ReaIntegrity2\n*L\n64#1:554,2\n401#1:557\n401#1:558,2\n403#1:560\n403#1:561,2\n404#1:563\n406#1:564,3\n404#1:567\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u0082\u0001\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u0012\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0005\n\u0002\u0018\u0002\n\u0002\u0008\u0004\n\u0002\u0018\u0002\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0003\n\u0002\u0018\u0002\n\u0002\u0008\u0004\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010$\n\u0002\u0008\u0006\n\u0002\u0018\u0002\n\u0002\u0008\n\n\u0002\u0010\u0011\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0002\u0008\u000e\n\u0002\u0018\u0002\n\u0002\u0008\u0004\n\u0002\u0018\u0002\n\u0002\u0008\u0006\u0008\u00c6\u0002\u0018\u00002\u00020\u0001:\u0006PQRSTUB\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u000e\u0010\u0004\u001a\u00020\u00052\u0006\u0010\u0006\u001a\u00020\u0007J\u001a\u0010\u0008\u001a\u00020\t2\u0008\u0010\n\u001a\u0004\u0018\u00010\u00052\u0008\u0010\u000b\u001a\u0004\u0018\u00010\u0005J\u0010\u0010\u000c\u001a\u0004\u0018\u00010\u00072\u0006\u0010\r\u001a\u00020\u0005J\u001a\u0010\u000e\u001a\u00020\u000f2\u0008\u0010\u0010\u001a\u0004\u0018\u00010\u00052\u0008\u0010\u0011\u001a\u0004\u0018\u00010\u0005J\u0012\u0010\u0012\u001a\u0004\u0018\u00010\u00052\u0008\u0010\u0013\u001a\u0004\u0018\u00010\u0014J\u0014\u0010\u0015\u001a\u0004\u0018\u00010\u00052\n\u0010\u0016\u001a\u0006\u0012\u0002\u0008\u00030\u0017J\u0018\u0010\u0018\u001a\u00020\u00192\u0008\u0010\u0013\u001a\u0004\u0018\u00010\u00142\u0006\u0010\u001a\u001a\u00020\u0005J\u001a\u0010\u001b\u001a\u00020\u00192\n\u0010\u0016\u001a\u0006\u0012\u0002\u0008\u00030\u00172\u0006\u0010\u001a\u001a\u00020\u0005J\u0018\u0010\u001c\u001a\u00020\u001d2\u0008\u0010\u001e\u001a\u0004\u0018\u00010\u00072\u0006\u0010\u001f\u001a\u00020\u0005J\u0016\u0010 \u001a\u00020\u001d2\u0006\u0010!\u001a\u00020\"2\u0006\u0010\u001f\u001a\u00020\u0005J.\u0010#\u001a\u00020$2\u0012\u0010%\u001a\u000e\u0012\u0004\u0012\u00020\u0005\u0012\u0004\u0012\u00020\u00070&2\u0012\u0010\'\u001a\u000e\u0012\u0004\u0012\u00020\u0005\u0012\u0004\u0012\u00020\u00050&J.\u0010(\u001a\u00020$2\u0012\u0010)\u001a\u000e\u0012\u0004\u0012\u00020\u0005\u0012\u0004\u0012\u00020\u00070&2\u0012\u0010\'\u001a\u000e\u0012\u0004\u0012\u00020\u0005\u0012\u0004\u0012\u00020\u00050&J/\u0010*\u001a\u0004\u0018\u0001H+\"\u0004\u0008\u0000\u0010+2\u000c\u0010,\u001a\u0008\u0012\u0004\u0012\u00020\t0-2\u000c\u0010.\u001a\u0008\u0012\u0004\u0012\u0002H+0-\u00a2\u0006\u0002\u0010/J.\u00100\u001a\u0004\u0018\u00010\u00052\u000c\u0010,\u001a\u0008\u0012\u0004\u0012\u00020\t0-2\u0006\u00101\u001a\u00020\u00052\u0006\u00102\u001a\u00020\u00052\u0006\u00103\u001a\u00020\u0005J5\u00104\u001a\u0004\u0018\u00010\u00012\u0006\u00105\u001a\u00020\u00012\u0006\u00106\u001a\u00020\u00052\u0016\u00107\u001a\u000c\u0012\u0008\u0008\u0001\u0012\u0004\u0018\u00010\u000108\"\u0004\u0018\u00010\u0001\u00a2\u0006\u0002\u00109J5\u0010:\u001a\u00020;2\u0006\u00105\u001a\u00020\u00012\u0006\u00106\u001a\u00020\u00052\u0016\u00107\u001a\u000c\u0012\u0008\u0008\u0001\u0012\u0004\u0018\u00010\u000108\"\u0004\u0018\u00010\u0001H\u0002\u00a2\u0006\u0002\u0010<JK\u0010=\u001a\u0004\u0018\u0001H+\"\u0004\u0008\u0000\u0010+2\u0006\u00105\u001a\u00020\u00012\u0006\u00106\u001a\u00020\u00052\u0012\u0008\u0002\u00107\u001a\u000c\u0012\u0008\u0008\u0001\u0012\u0004\u0018\u00010\u0001082\u0012\u0008\u0002\u0010>\u001a\u000c\u0012\u0006\u0012\u0004\u0018\u0001H+\u0018\u00010-\u00a2\u0006\u0002\u0010?J\u001c\u0010@\u001a\u0008\u0012\u0002\u0008\u0003\u0018\u00010\u00172\u0006\u0010A\u001a\u00020\u00052\u0006\u0010B\u001a\u00020\u0005J\u001c\u0010C\u001a\u0008\u0012\u0002\u0008\u0003\u0018\u00010\u00172\u0006\u0010D\u001a\u00020\"2\u0006\u0010B\u001a\u00020\u0005J$\u0010E\u001a\u0008\u0012\u0002\u0008\u0003\u0018\u00010\u00172\u0006\u0010F\u001a\u00020\u00072\u0006\u0010B\u001a\u00020\u00052\u0006\u0010G\u001a\u00020\"J\u000e\u0010H\u001a\u00020\u000f2\u0006\u0010I\u001a\u00020JJ,\u0010K\u001a\u0008\u0012\u0002\u0008\u0003\u0018\u00010\u00172\u0006\u0010L\u001a\u00020\u00052\u0006\u0010M\u001a\u00020\u00052\u0006\u0010B\u001a\u00020\u00052\u0006\u0010N\u001a\u00020O"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaIntegrity2;",
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
        "Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;",
        "packageName",
        "installerPackageName",
        "hashClassBytes",
        "stream",
        "Ljava/io/InputStream;",
        "hashOwnClassBytes",
        "clazz",
        "Ljava/lang/Class;",
        "verifySelfHash",
        "Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;",
        "expectedHex",
        "verifyOwnClassHash",
        "verifyConfigHash",
        "Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;",
        "configBytes",
        "pinnedHex",
        "verifyConfigFileHash",
        "file",
        "Ljava/io/File;",
        "verifyResourceHashes",
        "Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;",
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
        "invokeReflectivelyResult",
        "Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;",
        "(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;",
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
        "HashCheckResult",
        "ReflectResult"
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
.field public static final INSTANCE:Lcom/appcore/runtime/ReaIntegrity2;


# direct methods
.method public static synthetic $r8$lambda$-L04J_AQw2CR0eELll3YcGljcIs(B)Ljava/lang/CharSequence;
    .registers 1

    invoke-static {p0}, Lcom/appcore/runtime/ReaIntegrity2;->sha256Hex$lambda$0(B)Ljava/lang/CharSequence;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic $r8$lambda$35dx6lLOO7-olzUQ_GVJZh8nA7s(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 3

    invoke-static {p0, p1, p2}, Lcom/appcore/runtime/ReaIntegrity2;->decryptBlobWithEnvCheck$lambda$6(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object p0

    return-object p0
.end method

.method public static synthetic $r8$lambda$MwPweuidbQLR1sx1xlpdcTgydFc(B)Ljava/lang/CharSequence;
    .registers 1

    invoke-static {p0}, Lcom/appcore/runtime/ReaIntegrity2;->hashClassBytes$lambda$4$lambda$3(B)Ljava/lang/CharSequence;

    move-result-object p0

    return-object p0
.end method

.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/appcore/runtime/ReaIntegrity2;

    invoke-direct {v0}, Lcom/appcore/runtime/ReaIntegrity2;-><init>()V

    sput-object v0, Lcom/appcore/runtime/ReaIntegrity2;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity2;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 29
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static synthetic callByReflectionOrDirect$default(Lcom/appcore/runtime/ReaIntegrity2;Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;Lkotlin/jvm/functions/Function0;ILjava/lang/Object;)Ljava/lang/Object;
    .registers 7

    .line 433
    and-int/lit8 p6, p5, 0x4

    if-eqz p6, :cond_7

    .line 436
    const/4 p3, 0x0

    new-array p3, p3, [Ljava/lang/Object;

    .line 433
    :cond_7
    and-int/lit8 p5, p5, 0x8

    if-eqz p5, :cond_c

    .line 437
    const/4 p4, 0x0

    .line 433
    :cond_c
    invoke-virtual {p0, p1, p2, p3, p4}, Lcom/appcore/runtime/ReaIntegrity2;->callByReflectionOrDirect(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;Lkotlin/jvm/functions/Function0;)Ljava/lang/Object;

    move-result-object p0

    return-object p0
.end method

.method private static final decryptBlobWithEnvCheck$lambda$6(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
    .registers 4
    .param p0, "$blobBase64"    # Ljava/lang/String;
    .param p1, "$keyPart1B64"    # Ljava/lang/String;
    .param p2, "$keyPart2B64"    # Ljava/lang/String;

    .line 352
    sget-object v0, Lcom/appcore/runtime/ReaRuntime;->INSTANCE:Lcom/appcore/runtime/ReaRuntime;

    invoke-virtual {v0, p0, p1, p2}, Lcom/appcore/runtime/ReaRuntime;->decrypt(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method

.method private static final hashClassBytes$lambda$4$lambda$3(B)Ljava/lang/CharSequence;
    .registers 3
    .param p0, "b"    # B

    .line 143
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

.method private final varargs invokeReflectivelyResult(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;
    .registers 23
    .param p1, "target"    # Ljava/lang/Object;
    .param p2, "methodName"    # Ljava/lang/String;
    .param p3, "args"    # [Ljava/lang/Object;

    .line 399
    move-object/from16 v1, p2

    move-object/from16 v2, p3

    .line 400
    :try_start_4
    invoke-virtual/range {p1 .. p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Class;->getMethods()[Ljava/lang/reflect/Method;

    move-result-object v0

    const-string v3, "getMethods(...)"

    invoke-static {v0, v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    check-cast v0, [Ljava/lang/Object;

    .line 401
    nop

    .local v0, "$this$filter$iv":[Ljava/lang/Object;
    const/4 v3, 0x0

    .line 557
    .local v3, "$i$f$filter":I
    new-instance v4, Ljava/util/ArrayList;

    invoke-direct {v4}, Ljava/util/ArrayList;-><init>()V

    check-cast v4, Ljava/util/Collection;

    .local v4, "destination$iv$iv":Ljava/util/Collection;
    move-object v5, v0

    .local v5, "$this$filterTo$iv$iv":[Ljava/lang/Object;
    const/4 v6, 0x0

    .line 558
    .local v6, "$i$f$filterTo":I
    array-length v7, v5

    const/4 v9, 0x0

    :goto_20
    if-ge v9, v7, :cond_44

    aget-object v11, v5, v9

    .local v11, "element$iv$iv":Ljava/lang/Object;
    move-object v12, v11

    check-cast v12, Ljava/lang/reflect/Method;

    .local v12, "it":Ljava/lang/reflect/Method;
    const/4 v13, 0x0

    .line 401
    .local v13, "$i$a$-filter-ReaIntegrity2$invokeReflectivelyResult$candidates$1":I
    invoke-virtual {v12}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;

    move-result-object v14

    invoke-static {v14, v1}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v14

    if-eqz v14, :cond_3b

    invoke-virtual {v12}, Ljava/lang/reflect/Method;->getParameterCount()I

    move-result v14

    array-length v15, v2

    if-ne v14, v15, :cond_3b

    const/4 v10, 0x1

    goto :goto_3c

    :cond_3b
    const/4 v10, 0x0

    .line 558
    .end local v12    # "it":Ljava/lang/reflect/Method;
    .end local v13    # "$i$a$-filter-ReaIntegrity2$invokeReflectivelyResult$candidates$1":I
    :goto_3c
    if-eqz v10, :cond_41

    invoke-interface {v4, v11}, Ljava/util/Collection;->add(Ljava/lang/Object;)Z

    .end local v11    # "element$iv$iv":Ljava/lang/Object;
    :cond_41
    add-int/lit8 v9, v9, 0x1

    goto :goto_20

    .line 559
    :cond_44
    nop

    .end local v4    # "destination$iv$iv":Ljava/util/Collection;
    .end local v5    # "$this$filterTo$iv$iv":[Ljava/lang/Object;
    .end local v6    # "$i$f$filterTo":I
    check-cast v4, Ljava/util/List;

    .line 557
    nop

    .end local v0    # "$this$filter$iv":[Ljava/lang/Object;
    .end local v3    # "$i$f$filter":I
    check-cast v4, Ljava/util/Collection;

    .line 402
    invoke-virtual/range {p1 .. p1}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Class;->getDeclaredMethods()[Ljava/lang/reflect/Method;

    move-result-object v0

    const-string v3, "getDeclaredMethods(...)"

    invoke-static {v0, v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    check-cast v0, [Ljava/lang/Object;

    .line 403
    nop

    .restart local v0    # "$this$filter$iv":[Ljava/lang/Object;
    const/4 v3, 0x0

    .line 560
    .restart local v3    # "$i$f$filter":I
    new-instance v5, Ljava/util/ArrayList;

    invoke-direct {v5}, Ljava/util/ArrayList;-><init>()V

    check-cast v5, Ljava/util/Collection;

    .local v5, "destination$iv$iv":Ljava/util/Collection;
    move-object v6, v0

    .local v6, "$this$filterTo$iv$iv":[Ljava/lang/Object;
    const/4 v7, 0x0

    .line 561
    .local v7, "$i$f$filterTo":I
    array-length v9, v6

    const/4 v11, 0x0

    :goto_66
    if-ge v11, v9, :cond_8a

    aget-object v12, v6, v11

    .local v12, "element$iv$iv":Ljava/lang/Object;
    move-object v13, v12

    check-cast v13, Ljava/lang/reflect/Method;

    .local v13, "it":Ljava/lang/reflect/Method;
    const/4 v14, 0x0

    .line 403
    .local v14, "$i$a$-filter-ReaIntegrity2$invokeReflectivelyResult$candidates$2":I
    invoke-virtual {v13}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;

    move-result-object v15

    invoke-static {v15, v1}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v15

    if-eqz v15, :cond_81

    invoke-virtual {v13}, Ljava/lang/reflect/Method;->getParameterCount()I

    move-result v15

    array-length v8, v2

    if-ne v15, v8, :cond_81

    const/4 v8, 0x1

    goto :goto_82

    :cond_81
    const/4 v8, 0x0

    .line 561
    .end local v13    # "it":Ljava/lang/reflect/Method;
    .end local v14    # "$i$a$-filter-ReaIntegrity2$invokeReflectivelyResult$candidates$2":I
    :goto_82
    if-eqz v8, :cond_87

    invoke-interface {v5, v12}, Ljava/util/Collection;->add(Ljava/lang/Object;)Z

    .end local v12    # "element$iv$iv":Ljava/lang/Object;
    :cond_87
    add-int/lit8 v11, v11, 0x1

    goto :goto_66

    .line 562
    :cond_8a
    nop

    .end local v5    # "destination$iv$iv":Ljava/util/Collection;
    .end local v6    # "$this$filterTo$iv$iv":[Ljava/lang/Object;
    .end local v7    # "$i$f$filterTo":I
    check-cast v5, Ljava/util/List;

    .line 560
    nop

    .end local v0    # "$this$filter$iv":[Ljava/lang/Object;
    .end local v3    # "$i$f$filter":I
    check-cast v5, Ljava/lang/Iterable;

    .line 400
    invoke-static {v4, v5}, Lkotlin/collections/CollectionsKt;->plus(Ljava/util/Collection;Ljava/lang/Iterable;)Ljava/util/List;

    move-result-object v0

    move-object v3, v0

    .line 404
    .local v3, "candidates":Ljava/util/List;
    move-object v0, v3

    check-cast v0, Ljava/lang/Iterable;

    .local v0, "$this$firstOrNull$iv":Ljava/lang/Iterable;
    const/4 v4, 0x0

    .line 563
    .local v4, "$i$f$firstOrNull":I
    invoke-interface {v0}, Ljava/lang/Iterable;->iterator()Ljava/util/Iterator;

    move-result-object v5

    :goto_9d
    invoke-interface {v5}, Ljava/util/Iterator;->hasNext()Z

    move-result v6

    if-eqz v6, :cond_10d

    invoke-interface {v5}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v6

    .local v6, "element$iv":Ljava/lang/Object;
    move-object v7, v6

    check-cast v7, Ljava/lang/reflect/Method;

    .local v7, "m":Ljava/lang/reflect/Method;
    const/4 v8, 0x0

    .line 405
    .local v8, "$i$a$-firstOrNull-ReaIntegrity2$invokeReflectivelyResult$method$1":I
    invoke-virtual {v7}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v9

    .line 406
    .local v9, "params":[Ljava/lang/Class;
    invoke-static {v9}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    invoke-static {v9}, Lkotlin/collections/ArraysKt;->getIndices([Ljava/lang/Object;)Lkotlin/ranges/IntRange;

    move-result-object v11

    check-cast v11, Ljava/lang/Iterable;

    .local v11, "$this$all$iv":Ljava/lang/Iterable;
    const/4 v12, 0x0

    .line 564
    .local v12, "$i$f$all":I
    instance-of v13, v11, Ljava/util/Collection;

    if-eqz v13, :cond_ca

    move-object v13, v11

    check-cast v13, Ljava/util/Collection;

    invoke-interface {v13}, Ljava/util/Collection;->isEmpty()Z

    move-result v13

    if-eqz v13, :cond_ca

    move-object/from16 v18, v0

    const/4 v10, 0x1

    goto :goto_106

    .line 565
    :cond_ca
    invoke-interface {v11}, Ljava/lang/Iterable;->iterator()Ljava/util/Iterator;

    move-result-object v13

    :goto_ce
    invoke-interface {v13}, Ljava/util/Iterator;->hasNext()Z

    move-result v14

    if-eqz v14, :cond_103

    move-object v14, v13

    check-cast v14, Lkotlin/collections/IntIterator;

    invoke-virtual {v14}, Lkotlin/collections/IntIterator;->nextInt()I

    move-result v14

    .local v14, "element$iv":I
    move v15, v14

    .local v15, "i":I
    const/16 v16, 0x0

    .line 407
    .local v16, "$i$a$-all-ReaIntegrity2$invokeReflectivelyResult$method$1$1":I
    aget-object v17, v2, v15

    if-eqz v17, :cond_f9

    aget-object v10, v9, v15

    move-object/from16 v18, v0

    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .local v18, "$this$firstOrNull$iv":Ljava/lang/Iterable;
    aget-object v0, v2, v15

    invoke-virtual {v10, v0}, Ljava/lang/Class;->isInstance(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_fb

    .line 408
    aget-object v0, v9, v15

    invoke-virtual {v0}, Ljava/lang/Class;->isPrimitive()Z

    move-result v0

    if-eqz v0, :cond_f7

    goto :goto_fb

    :cond_f7
    const/4 v0, 0x0

    goto :goto_fc

    .line 407
    .end local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_f9
    move-object/from16 v18, v0

    .line 408
    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_fb
    :goto_fb
    const/4 v0, 0x1

    .line 565
    .end local v15    # "i":I
    .end local v16    # "$i$a$-all-ReaIntegrity2$invokeReflectivelyResult$method$1$1":I
    :goto_fc
    if-nez v0, :cond_100

    const/4 v10, 0x0

    goto :goto_106

    :cond_100
    move-object/from16 v0, v18

    goto :goto_ce

    .line 566
    .end local v14    # "element$iv":I
    .end local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_103
    move-object/from16 v18, v0

    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    const/4 v10, 0x1

    .line 409
    .end local v11    # "$this$all$iv":Ljava/lang/Iterable;
    .end local v12    # "$i$f$all":I
    :goto_106
    nop

    .line 563
    .end local v7    # "m":Ljava/lang/reflect/Method;
    .end local v8    # "$i$a$-firstOrNull-ReaIntegrity2$invokeReflectivelyResult$method$1":I
    .end local v9    # "params":[Ljava/lang/Class;
    if-eqz v10, :cond_10a

    goto :goto_110

    :cond_10a
    move-object/from16 v0, v18

    goto :goto_9d

    .line 567
    .end local v6    # "element$iv":Ljava/lang/Object;
    .end local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_10d
    move-object/from16 v18, v0

    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    const/4 v6, 0x0

    .line 404
    .end local v4    # "$i$f$firstOrNull":I
    .end local v18    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :goto_110
    check-cast v6, Ljava/lang/reflect/Method;

    if-nez v6, :cond_122

    .line 410
    invoke-static {v3}, Lkotlin/collections/CollectionsKt;->firstOrNull(Ljava/util/List;)Ljava/lang/Object;

    move-result-object v0

    move-object v6, v0

    check-cast v6, Ljava/lang/reflect/Method;

    .line 404
    if-nez v6, :cond_122

    .line 410
    sget-object v0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;

    check-cast v0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;
    :try_end_121
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_121} :catch_13e

    return-object v0

    .line 411
    .local v6, "method":Ljava/lang/reflect/Method;
    :cond_122
    nop

    .line 412
    const/4 v0, 0x1

    :try_start_124
    invoke-virtual {v6, v0}, Ljava/lang/reflect/Method;->setAccessible(Z)V
    :try_end_127
    .catch Ljava/lang/Exception; {:try_start_124 .. :try_end_127} :catch_128

    goto :goto_129

    .line 413
    :catch_128
    move-exception v0

    .line 417
    :goto_129
    :try_start_129
    new-instance v0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;

    array-length v4, v2

    invoke-static {v2, v4}, Ljava/util/Arrays;->copyOf([Ljava/lang/Object;I)[Ljava/lang/Object;

    move-result-object v4
    :try_end_130
    .catch Ljava/lang/Exception; {:try_start_129 .. :try_end_130} :catch_13e

    move-object/from16 v5, p1

    :try_start_132
    invoke-virtual {v6, v5, v4}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v4

    invoke-direct {v0, v4}, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;-><init>(Ljava/lang/Object;)V

    .end local v3    # "candidates":Ljava/util/List;
    .end local v6    # "method":Ljava/lang/reflect/Method;
    check-cast v0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;
    :try_end_13b
    .catch Ljava/lang/Exception; {:try_start_132 .. :try_end_13b} :catch_13c

    goto :goto_146

    .line 418
    :catch_13c
    move-exception v0

    goto :goto_141

    :catch_13e
    move-exception v0

    move-object/from16 v5, p1

    .line 419
    .local v0, "e":Ljava/lang/Exception;
    :goto_141
    sget-object v3, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;

    check-cast v3, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;

    move-object v0, v3

    .line 399
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_146
    return-object v0
.end method

.method private static final sha256Hex$lambda$0(B)Ljava/lang/CharSequence;
    .registers 3
    .param p0, "it"    # B

    .line 38
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

    .line 440
    array-length v0, p3

    invoke-static {p3, v0}, Ljava/util/Arrays;->copyOf([Ljava/lang/Object;I)[Ljava/lang/Object;

    move-result-object v0

    invoke-direct {p0, p1, p2, v0}, Lcom/appcore/runtime/ReaIntegrity2;->invokeReflectivelyResult(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;

    move-result-object v0

    .line 441
    .local v0, "r":Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;
    instance-of v1, v0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;

    if-eqz v1, :cond_24

    move-object v1, v0

    check-cast v1, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;

    invoke-virtual {v1}, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->getValue()Ljava/lang/Object;

    move-result-object v1

    goto :goto_37

    .line 442
    :cond_24
    sget-object v1, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;

    invoke-static {v0, v1}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_38

    .line 443
    const/4 v1, 0x0

    if-eqz p4, :cond_36

    :try_start_2f
    invoke-interface {p4}, Lkotlin/jvm/functions/Function0;->invoke()Ljava/lang/Object;

    move-result-object v1
    :try_end_33
    .catch Ljava/lang/Exception; {:try_start_2f .. :try_end_33} :catch_34

    goto :goto_36

    .line 444
    :catch_34
    move-exception v2

    .line 445
    .local v2, "e":Ljava/lang/Exception;
    nop

    .end local v2    # "e":Ljava/lang/Exception;
    :cond_36
    :goto_36
    nop

    .line 440
    .end local v0    # "r":Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;
    :goto_37
    return-object v1

    .restart local v0    # "r":Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;
    :cond_38
    new-instance v1, Lkotlin/NoWhenBranchMatchedException;

    invoke-direct {v1}, Lkotlin/NoWhenBranchMatchedException;-><init>()V

    throw v1
.end method

.method public final checkInstallerOrigin(Ljava/lang/String;Ljava/lang/String;)Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;
    .registers 11
    .param p1, "packageName"    # Ljava/lang/String;
    .param p2, "installerPackageName"    # Ljava/lang/String;

    .line 110
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

    .line 111
    new-instance v1, Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;

    sget-object v2, Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;->UNKNOWN:Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;

    const/16 v6, 0x8

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-direct/range {v1 .. v7}, Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;-><init>(Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZILkotlin/jvm/internal/DefaultConstructorMarker;)V

    return-object v1

    .line 113
    :cond_1f
    move-object v0, p2

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v3

    .line 114
    .local v3, "installer":Ljava/lang/String;
    const-string v0, "com.android.vending"

    invoke-static {v3, v0}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_3f

    .line 115
    new-instance v1, Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;

    sget-object v2, Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;->PLAY_STORE:Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;

    const/16 v6, 0x8

    const/4 v7, 0x0

    const/4 v4, 0x1

    const/4 v5, 0x0

    invoke-direct/range {v1 .. v7}, Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;-><init>(Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZILkotlin/jvm/internal/DefaultConstructorMarker;)V

    goto :goto_4b

    .line 117
    :cond_3f
    new-instance v1, Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;

    sget-object v2, Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;->THIRD_PARTY:Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;

    const/16 v6, 0x8

    const/4 v7, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-direct/range {v1 .. v7}, Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;-><init>(Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZILkotlin/jvm/internal/DefaultConstructorMarker;)V

    .line 114
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

    .line 351
    new-instance v0, Lcom/appcore/runtime/ReaIntegrity2$$ExternalSyntheticLambda2;

    invoke-direct {v0, p2, p3, p4}, Lcom/appcore/runtime/ReaIntegrity2$$ExternalSyntheticLambda2;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V

    invoke-virtual {p0, p1, v0}, Lcom/appcore/runtime/ReaIntegrity2;->decryptWithEnvCheck(Lkotlin/jvm/functions/Function0;Lkotlin/jvm/functions/Function0;)Ljava/lang/Object;

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

    .line 327
    nop

    .line 328
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

    .line 329
    :cond_19
    nop

    .line 330
    :try_start_1a
    invoke-interface {p2}, Lkotlin/jvm/functions/Function0;->invoke()Ljava/lang/Object;

    move-result-object v0
    :try_end_1e
    .catch Ljava/lang/Exception; {:try_start_1a .. :try_end_1e} :catch_1f

    goto :goto_21

    .line 331
    :catch_1f
    move-exception v1

    .line 332
    .local v1, "e":Ljava/lang/Exception;
    nop

    .end local v1    # "e":Ljava/lang/Exception;
    :goto_21
    goto :goto_24

    .line 334
    :catch_22
    move-exception v1

    .line 335
    .restart local v1    # "e":Ljava/lang/Exception;
    nop

    .line 327
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_24
    return-object v0
.end method

.method public final getInstallerOrigin(Landroid/content/Context;)Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;
    .registers 10
    .param p1, "context"    # Landroid/content/Context;

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 514
    nop

    .line 515
    :try_start_6
    invoke-virtual {p1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    .line 516
    .local v0, "pm":Landroid/content/pm/PackageManager;
    invoke-virtual {p1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    .line 517
    .local v1, "pkg":Ljava/lang/String;
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1e

    if-lt v2, v3, :cond_1d

    .line 518
    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getInstallSourceInfo(Ljava/lang/String;)Landroid/content/pm/InstallSourceInfo;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/pm/InstallSourceInfo;->getInstallingPackageName()Ljava/lang/String;

    move-result-object v2

    goto :goto_21

    .line 521
    :cond_1d
    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getInstallerPackageName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2

    .line 517
    :goto_21
    nop

    .line 523
    .local v2, "installer":Ljava/lang/String;
    invoke-virtual {p0, v1, v2}, Lcom/appcore/runtime/ReaIntegrity2;->checkInstallerOrigin(Ljava/lang/String;Ljava/lang/String;)Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;

    move-result-object v3
    :try_end_26
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_26} :catch_27

    .end local v0    # "pm":Landroid/content/pm/PackageManager;
    .end local v1    # "pkg":Ljava/lang/String;
    .end local v2    # "installer":Ljava/lang/String;
    goto :goto_36

    .line 524
    :catch_27
    move-exception v0

    .line 525
    .local v0, "e":Ljava/lang/Exception;
    new-instance v1, Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;

    sget-object v2, Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;->UNKNOWN:Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;

    const/16 v6, 0x8

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-direct/range {v1 .. v7}, Lcom/appcore/runtime/ReaIntegrity2$InstallerSignal;-><init>(Lcom/appcore/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZILkotlin/jvm/internal/DefaultConstructorMarker;)V

    move-object v3, v1

    .line 514
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_36
    return-object v3
.end method

.method public final hashClassBytes(Ljava/io/InputStream;)Ljava/lang/String;
    .registers 18
    .param p1, "stream"    # Ljava/io/InputStream;

    .line 134
    const/4 v1, 0x0

    if-nez p1, :cond_4

    return-object v1

    .line 135
    :cond_4
    nop

    .line 136
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

    .line 137
    .local v3, "$i$a$-use-ReaIntegrity2$hashClassBytes$1":I
    const-string v4, "SHA-256"

    invoke-static {v4}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v4

    .line 138
    .local v4, "digest":Ljava/security/MessageDigest;
    const/16 v5, 0x2000

    new-array v5, v5, [B

    .line 139
    .local v5, "buf":[B
    const/4 v6, 0x0

    .line 140
    .local v6, "n":I
    :goto_18
    invoke-virtual {v0, v5}, Ljava/io/InputStream;->read([B)I

    move-result v7

    move v8, v7

    .line 556
    .local v8, "r":I
    const/4 v9, 0x0

    .line 140
    .local v9, "$i$a$-also-ReaIntegrity2$hashClassBytes$1$1":I
    move v6, v8

    .end local v8    # "r":I
    .end local v9    # "$i$a$-also-ReaIntegrity2$hashClassBytes$1$1":I
    const/4 v8, -0x1

    if-eq v7, v8, :cond_27

    .line 141
    const/4 v7, 0x0

    invoke-virtual {v4, v5, v7, v6}, Ljava/security/MessageDigest;->update([BII)V

    goto :goto_18

    .line 143
    :cond_27
    invoke-virtual {v4}, Ljava/security/MessageDigest;->digest()[B

    move-result-object v7

    const-string v8, "digest(...)"

    invoke-static {v7, v8}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v8, ""

    check-cast v8, Ljava/lang/CharSequence;

    new-instance v13, Lcom/appcore/runtime/ReaIntegrity2$$ExternalSyntheticLambda0;

    invoke-direct {v13}, Lcom/appcore/runtime/ReaIntegrity2$$ExternalSyntheticLambda0;-><init>()V

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

    .line 136
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

    .line 145
    .restart local p1    # "stream":Ljava/io/InputStream;
    :catch_51
    move-exception v0

    .line 146
    .local v0, "e":Ljava/lang/Exception;
    nop

    .line 135
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

    .line 152
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

    .line 153
    .local v0, "name":Ljava/lang/String;
    invoke-virtual {p1, v0}, Ljava/lang/Class;->getResourceAsStream(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v1

    invoke-virtual {p0, v1}, Lcom/appcore/runtime/ReaIntegrity2;->hashClassBytes(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v1

    return-object v1
.end method

.method public final hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z
    .registers 8
    .param p1, "a"    # Ljava/lang/String;
    .param p2, "b"    # Ljava/lang/String;

    .line 48
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

    .line 49
    :cond_25
    nop

    .line 50
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

    invoke-virtual {p0, v1}, Lcom/appcore/runtime/ReaIntegrity2;->hexToBytes(Ljava/lang/String;)[B

    move-result-object v1

    .line 51
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

    invoke-virtual {p0, v2}, Lcom/appcore/runtime/ReaIntegrity2;->hexToBytes(Ljava/lang/String;)[B

    move-result-object v0

    .line 52
    .local v0, "bb":[B
    if-eqz v1, :cond_65

    if-nez v0, :cond_5b

    goto :goto_65

    .line 53
    :cond_5b
    array-length v2, v1

    array-length v4, v0

    if-eq v2, v4, :cond_60

    return v3

    .line 54
    :cond_60
    invoke-static {v1, v0}, Ljava/security/MessageDigest;->isEqual([B[B)Z

    move-result v3
    :try_end_64
    .catch Ljava/lang/Exception; {:try_start_26 .. :try_end_64} :catch_66

    .end local v0    # "bb":[B
    .end local v1    # "ba":[B
    goto :goto_68

    .line 52
    .restart local v0    # "bb":[B
    .restart local v1    # "ba":[B
    :cond_65
    :goto_65
    return v3

    .line 55
    .end local v0    # "bb":[B
    .end local v1    # "ba":[B
    :catch_66
    move-exception v0

    .line 56
    .local v0, "e":Ljava/lang/Exception;
    nop

    .line 49
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_68
    return v3

    .line 48
    :cond_69
    :goto_69
    return v3
.end method

.method public final hexToBytes(Ljava/lang/String;)[B
    .registers 13
    .param p1, "hex"    # Ljava/lang/String;

    const-string v0, "hex"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 62
    move-object v0, p1

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 63
    .local v0, "clean":Ljava/lang/String;
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    rem-int/lit8 v1, v1, 0x2

    const/4 v2, 0x0

    if-eqz v1, :cond_1a

    return-object v2

    .line 64
    :cond_1a
    move-object v1, v0

    check-cast v1, Ljava/lang/CharSequence;

    .local v1, "$this$all$iv":Ljava/lang/CharSequence;
    const/4 v3, 0x0

    .line 554
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

    .line 64
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

    .line 554
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

    .line 555
    :cond_5d
    nop

    .line 64
    .end local v1    # "$this$all$iv":Ljava/lang/CharSequence;
    .end local v3    # "$i$f$all":I
    :goto_5e
    if-nez v7, :cond_61

    return-object v2

    .line 65
    :cond_61
    nop

    .line 66
    :try_start_62
    invoke-virtual {v0}, Ljava/lang/String;->length()I

    move-result v1

    div-int/lit8 v1, v1, 0x2

    new-array v3, v1, [B

    :goto_6a
    if-ge v4, v1, :cond_89

    .line 67
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

    .line 66
    add-int/lit8 v4, v4, 0x1

    goto :goto_6a

    :cond_89
    move-object v2, v3

    goto :goto_8d

    .line 69
    :catch_8b
    move-exception v1

    .line 70
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 65
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_8d
    return-object v2
.end method

.method public final varargs invokeReflectively(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;
    .registers 6
    .param p1, "target"    # Ljava/lang/Object;
    .param p2, "methodName"    # Ljava/lang/String;
    .param p3, "args"    # [Ljava/lang/Object;

    const-string v0, "target"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "methodName"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "args"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 387
    array-length v0, p3

    invoke-static {p3, v0}, Ljava/util/Arrays;->copyOf([Ljava/lang/Object;I)[Ljava/lang/Object;

    move-result-object v0

    invoke-direct {p0, p1, p2, v0}, Lcom/appcore/runtime/ReaIntegrity2;->invokeReflectivelyResult(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Object;)Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;

    move-result-object v0

    .line 388
    .local v0, "r":Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;
    instance-of v1, v0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;

    if-eqz v1, :cond_24

    move-object v1, v0

    check-cast v1, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;

    invoke-virtual {v1}, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->getValue()Ljava/lang/Object;

    move-result-object v1

    goto :goto_2d

    .line 389
    :cond_24
    sget-object v1, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;

    invoke-static {v0, v1}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-eqz v1, :cond_2e

    const/4 v1, 0x0

    .line 387
    .end local v0    # "r":Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;
    :goto_2d
    return-object v1

    .restart local v0    # "r":Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;
    :cond_2e
    new-instance v1, Lkotlin/NoWhenBranchMatchedException;

    invoke-direct {v1}, Lkotlin/NoWhenBranchMatchedException;-><init>()V

    throw v1
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

    .line 545
    nop

    .line 546
    const/4 v0, 0x0

    :try_start_16
    new-instance v1, Ldalvik/system/DexClassLoader;

    invoke-direct {v1, p1, p2, v0, p4}, Ldalvik/system/DexClassLoader;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/ClassLoader;)V

    .line 547
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

    .line 548
    :catch_24
    move-exception v1

    .line 549
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 545
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

    .line 462
    nop

    .line 463
    const/4 v0, 0x0

    :try_start_c
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 464
    .local v1, "file":Ljava/io/File;
    invoke-virtual {v1}, Ljava/io/File;->canRead()Z

    move-result v2

    if-nez v2, :cond_18

    return-object v0

    .line 465
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

    .line 466
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

    .line 467
    :catch_3a
    move-exception v1

    .line 468
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 462
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

    .line 490
    nop

    .line 491
    const/4 v0, 0x0

    :try_start_11
    invoke-virtual {p3}, Ljava/io/File;->isDirectory()Z

    move-result v1

    if-nez v1, :cond_18

    return-object v0

    .line 492
    :cond_18
    const-string v1, "rea-dyn-"

    const-string v2, ".jar"

    invoke-static {v1, v2, p3}, Ljava/io/File;->createTempFile(Ljava/lang/String;Ljava/lang/String;Ljava/io/File;)Ljava/io/File;

    move-result-object v1

    .line 493
    .local v1, "tmp":Ljava/io/File;
    invoke-static {v1}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    invoke-static {v1, p1}, Lkotlin/io/FilesKt;->writeBytes(Ljava/io/File;[B)V

    .line 494
    invoke-virtual {v1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v2

    const-string v3, "getAbsolutePath(...)"

    invoke-static {v2, v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p0, v2, p2}, Lcom/appcore/runtime/ReaIntegrity2;->loadClassFromJar(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0
    :try_end_33
    .catch Ljava/lang/Exception; {:try_start_11 .. :try_end_33} :catch_34

    .end local v1    # "tmp":Ljava/io/File;
    goto :goto_36

    .line 495
    :catch_34
    move-exception v1

    .line 496
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 490
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

    .line 479
    invoke-virtual {p1}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v0

    const-string v1, "getAbsolutePath(...)"

    invoke-static {v0, v1}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {p0, v0, p2}, Lcom/appcore/runtime/ReaIntegrity2;->loadClassFromJar(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    return-object v0
.end method

.method public final sha256Hex([B)Ljava/lang/String;
    .registers 12
    .param p1, "bytes"    # [B

    const-string v0, "bytes"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 37
    const-string v0, "SHA-256"

    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v0

    invoke-virtual {v0, p1}, Ljava/security/MessageDigest;->digest([B)[B

    move-result-object v1

    const-string v0, "digest(...)"

    invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    .line 38
    const-string v0, ""

    move-object v2, v0

    check-cast v2, Ljava/lang/CharSequence;

    new-instance v7, Lcom/appcore/runtime/ReaIntegrity2$$ExternalSyntheticLambda1;

    invoke-direct {v7}, Lcom/appcore/runtime/ReaIntegrity2$$ExternalSyntheticLambda1;-><init>()V

    const/16 v8, 0x1e

    const/4 v9, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    const/4 v6, 0x0

    invoke-static/range {v1 .. v9}, Lkotlin/collections/ArraysKt;->joinToString$default([BLjava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v0

    .line 37
    return-object v0
.end method

.method public final verifyConfigFileHash(Ljava/io/File;Ljava/lang/String;)Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;
    .registers 10
    .param p1, "file"    # Ljava/io/File;
    .param p2, "pinnedHex"    # Ljava/lang/String;

    const-string v0, "file"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "pinnedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 213
    move-object v0, p2

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v0

    const/4 v1, 0x0

    const/4 v2, 0x0

    if-eqz v0, :cond_1b

    new-instance v0, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v0, v1, v2}, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    return-object v0

    .line 214
    :cond_1b
    nop

    .line 215
    :try_start_1c
    invoke-virtual {p1}, Ljava/io/File;->canRead()Z

    move-result v0

    if-nez v0, :cond_28

    new-instance v0, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v0, v1, v2}, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    return-object v0

    .line 216
    :cond_28
    invoke-virtual {p1}, Ljava/io/File;->length()J

    move-result-wide v3

    const-wide/16 v5, 0x0

    cmp-long v0, v3, v5

    if-nez v0, :cond_38

    new-instance v0, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v0, v1, v2}, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    return-object v0

    .line 217
    :cond_38
    new-instance v0, Ljava/io/FileInputStream;

    invoke-direct {v0, p1}, Ljava/io/FileInputStream;-><init>(Ljava/io/File;)V

    check-cast v0, Ljava/io/Closeable;
    :try_end_3f
    .catch Ljava/lang/Exception; {:try_start_1c .. :try_end_3f} :catch_60

    :try_start_3f
    move-object v3, v0

    check-cast v3, Ljava/io/FileInputStream;

    .line 556
    .local v3, "it":Ljava/io/FileInputStream;
    const/4 v4, 0x0

    .line 217
    .local v4, "$i$a$-use-ReaIntegrity2$verifyConfigFileHash$actual$1":I
    sget-object v5, Lcom/appcore/runtime/ReaIntegrity;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity;

    move-object v6, v3

    check-cast v6, Ljava/io/InputStream;

    invoke-virtual {v5, v6}, Lcom/appcore/runtime/ReaIntegrity;->hashStreamSha256(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v5
    :try_end_4c
    .catchall {:try_start_3f .. :try_end_4c} :catchall_59

    .end local v3    # "it":Ljava/io/FileInputStream;
    .end local v4    # "$i$a$-use-ReaIntegrity2$verifyConfigFileHash$actual$1":I
    :try_start_4c
    invoke-static {v0, v2}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    .line 218
    .local v5, "actual":Ljava/lang/String;
    new-instance v0, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-virtual {p0, v5, p2}, Lcom/appcore/runtime/ReaIntegrity2;->hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v3

    invoke-direct {v0, v3, v5}, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V
    :try_end_58
    .catch Ljava/lang/Exception; {:try_start_4c .. :try_end_58} :catch_60

    .end local v5    # "actual":Ljava/lang/String;
    goto :goto_67

    .line 217
    :catchall_59
    move-exception v3

    .end local p1    # "file":Ljava/io/File;
    .end local p2    # "pinnedHex":Ljava/lang/String;
    :try_start_5a
    throw v3
    :try_end_5b
    .catchall {:try_start_5a .. :try_end_5b} :catchall_5b

    .restart local p1    # "file":Ljava/io/File;
    .restart local p2    # "pinnedHex":Ljava/lang/String;
    :catchall_5b
    move-exception v4

    :try_start_5c
    invoke-static {v0, v3}, Lkotlin/io/CloseableKt;->closeFinally(Ljava/io/Closeable;Ljava/lang/Throwable;)V

    .end local p1    # "file":Ljava/io/File;
    .end local p2    # "pinnedHex":Ljava/lang/String;
    throw v4
    :try_end_60
    .catch Ljava/lang/Exception; {:try_start_5c .. :try_end_60} :catch_60

    .line 219
    .restart local p1    # "file":Ljava/io/File;
    .restart local p2    # "pinnedHex":Ljava/lang/String;
    :catch_60
    move-exception v0

    .line 220
    .local v0, "e":Ljava/lang/Exception;
    new-instance v3, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v3, v1, v2}, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    move-object v0, v3

    .line 214
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_67
    return-object v0
.end method

.method public final verifyConfigHash([BLjava/lang/String;)Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;
    .registers 8
    .param p1, "configBytes"    # [B
    .param p2, "pinnedHex"    # Ljava/lang/String;

    const-string v0, "pinnedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 193
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

    .line 194
    :cond_12
    move-object v2, p2

    check-cast v2, Ljava/lang/CharSequence;

    invoke-static {v2}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v2

    if-eqz v2, :cond_21

    new-instance v2, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v2, v1, v0}, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    return-object v2

    .line 195
    :cond_21
    nop

    .line 196
    :try_start_22
    invoke-virtual {p0, p1}, Lcom/appcore/runtime/ReaIntegrity2;->sha256Hex([B)Ljava/lang/String;

    move-result-object v2

    .line 197
    .local v2, "actual":Ljava/lang/String;
    new-instance v3, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-virtual {p0, v2, p2}, Lcom/appcore/runtime/ReaIntegrity2;->hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v4

    invoke-direct {v3, v4, v2}, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V
    :try_end_2f
    .catch Ljava/lang/Exception; {:try_start_22 .. :try_end_2f} :catch_30

    .end local v2    # "actual":Ljava/lang/String;
    goto :goto_36

    .line 198
    :catch_30
    move-exception v2

    .line 199
    .local v2, "e":Ljava/lang/Exception;
    new-instance v3, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v3, v1, v0}, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    .line 195
    .end local v2    # "e":Ljava/lang/Exception;
    :goto_36
    return-object v3

    .line 193
    :cond_37
    :goto_37
    new-instance v2, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;

    invoke-direct {v2, v1, v0}, Lcom/appcore/runtime/ReaIntegrity2$ConfigHashResult;-><init>(ZLjava/lang/String;)V

    return-object v2
.end method

.method public final verifyNativeLibHashes(Ljava/util/Map;Ljava/util/Map;)Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;
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
            "Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;"
        }
    .end annotation

    const-string v0, "libs"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHashes"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 286
    nop

    .line 287
    const/4 v0, 0x0

    :try_start_c
    invoke-interface {p2}, Ljava/util/Map;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_20

    .line 288
    new-instance v1, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v3

    invoke-direct {v1, v0, v2, v3, v0}, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V

    return-object v1

    .line 290
    :cond_20
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    check-cast v1, Ljava/util/List;

    .line 291
    .local v1, "failed":Ljava/util/List;
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    check-cast v2, Ljava/util/List;

    .line 292
    .local v2, "missing":Ljava/util/List;
    const/4 v3, 0x0

    .line 293
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

    .line 294
    .local v5, "expectedHex":Ljava/lang/String;
    invoke-interface {p1, v6}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v7

    check-cast v7, [B

    .line 295
    .local v7, "bytes":[B
    if-nez v7, :cond_5b

    .line 296
    invoke-interface {v2, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 297
    goto :goto_37

    .line 299
    :cond_5b
    const-string v8, ".so"

    const/4 v9, 0x2

    const/4 v10, 0x0

    invoke-static {v6, v8, v0, v9, v10}, Lkotlin/text/StringsKt;->endsWith$default(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result v8

    if-nez v8, :cond_69

    .line 300
    invoke-interface {v1, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 301
    goto :goto_37

    .line 303
    :cond_69
    add-int/lit8 v3, v3, 0x1

    .line 304
    invoke-virtual {p0, v7}, Lcom/appcore/runtime/ReaIntegrity2;->sha256Hex([B)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {p0, v8, v5}, Lcom/appcore/runtime/ReaIntegrity2;->hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v8

    if-nez v8, :cond_37

    invoke-interface {v1, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_37

    .line 306
    .end local v5    # "expectedHex":Ljava/lang/String;
    .end local v6    # "name":Ljava/lang/String;
    .end local v7    # "bytes":[B
    :cond_79
    new-instance v4, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;

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
    invoke-direct {v4, v5, v1, v2, v3}, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V
    :try_end_8d
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_8d} :catch_8e

    .end local v1    # "failed":Ljava/util/List;
    .end local v2    # "missing":Ljava/util/List;
    .end local v3    # "checked":I
    goto :goto_9c

    .line 307
    :catch_8e
    move-exception v1

    .line 308
    .local v1, "e":Ljava/lang/Exception;
    new-instance v4, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v3

    invoke-direct {v4, v0, v2, v3, v0}, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V

    .line 286
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_9c
    return-object v4
.end method

.method public final verifyOwnClassHash(Ljava/lang/Class;Ljava/lang/String;)Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;
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
            "Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;"
        }
    .end annotation

    const-string v0, "clazz"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 173
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

    .line 174
    .local v0, "name":Ljava/lang/String;
    invoke-virtual {p1, v0}, Ljava/lang/Class;->getResourceAsStream(Ljava/lang/String;)Ljava/io/InputStream;

    move-result-object v1

    invoke-virtual {p0, v1, p2}, Lcom/appcore/runtime/ReaIntegrity2;->verifySelfHash(Ljava/io/InputStream;Ljava/lang/String;)Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;

    move-result-object v1

    return-object v1
.end method

.method public final verifyResourceHashes(Ljava/util/Map;Ljava/util/Map;)Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;
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
            "Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;"
        }
    .end annotation

    const-string v0, "entries"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHashes"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 249
    nop

    .line 250
    const/4 v0, 0x0

    :try_start_c
    invoke-interface {p2}, Ljava/util/Map;->isEmpty()Z

    move-result v1

    if-eqz v1, :cond_20

    .line 251
    new-instance v1, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v3

    invoke-direct {v1, v0, v2, v3, v0}, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V

    return-object v1

    .line 253
    :cond_20
    new-instance v1, Ljava/util/ArrayList;

    invoke-direct {v1}, Ljava/util/ArrayList;-><init>()V

    check-cast v1, Ljava/util/List;

    .line 254
    .local v1, "failed":Ljava/util/List;
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    check-cast v2, Ljava/util/List;

    .line 255
    .local v2, "missing":Ljava/util/List;
    const/4 v3, 0x0

    .line 256
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

    .line 257
    .local v5, "expectedHex":Ljava/lang/String;
    invoke-interface {p1, v6}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v7

    check-cast v7, [B

    .line 258
    .local v7, "bytes":[B
    if-nez v7, :cond_5b

    .line 259
    invoke-interface {v2, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 260
    goto :goto_37

    .line 262
    :cond_5b
    add-int/lit8 v3, v3, 0x1

    .line 263
    invoke-virtual {p0, v7}, Lcom/appcore/runtime/ReaIntegrity2;->sha256Hex([B)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {p0, v8, v5}, Lcom/appcore/runtime/ReaIntegrity2;->hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v8

    if-nez v8, :cond_37

    invoke-interface {v1, v6}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_37

    .line 265
    .end local v5    # "expectedHex":Ljava/lang/String;
    .end local v6    # "name":Ljava/lang/String;
    .end local v7    # "bytes":[B
    :cond_6b
    new-instance v4, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;

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
    invoke-direct {v4, v5, v1, v2, v3}, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V
    :try_end_7f
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_7f} :catch_80

    .end local v1    # "failed":Ljava/util/List;
    .end local v2    # "missing":Ljava/util/List;
    .end local v3    # "checked":I
    goto :goto_8e

    .line 266
    :catch_80
    move-exception v1

    .line 267
    .local v1, "e":Ljava/lang/Exception;
    new-instance v4, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v3

    invoke-direct {v4, v0, v2, v3, v0}, Lcom/appcore/runtime/ReaIntegrity2$HashCheckResult;-><init>(ZLjava/util/List;Ljava/util/List;I)V

    .line 249
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_8e
    return-object v4
.end method

.method public final verifySelfHash(Ljava/io/InputStream;Ljava/lang/String;)Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;
    .registers 8
    .param p1, "stream"    # Ljava/io/InputStream;
    .param p2, "expectedHex"    # Ljava/lang/String;

    const-string v0, "expectedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 163
    nop

    .line 164
    const/4 v0, 0x0

    const/4 v1, 0x0

    :try_start_8
    invoke-virtual {p0, p1}, Lcom/appcore/runtime/ReaIntegrity2;->hashClassBytes(Ljava/io/InputStream;)Ljava/lang/String;

    move-result-object v2

    if-nez v2, :cond_14

    new-instance v2, Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;

    invoke-direct {v2, v1, v0}, Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;-><init>(ZLjava/lang/String;)V

    return-object v2

    .line 165
    .local v2, "actual":Ljava/lang/String;
    :cond_14
    new-instance v3, Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;

    invoke-virtual {p0, v2, p2}, Lcom/appcore/runtime/ReaIntegrity2;->hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v4

    invoke-direct {v3, v4, v2}, Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;-><init>(ZLjava/lang/String;)V
    :try_end_1d
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_1d} :catch_1e

    .end local v2    # "actual":Ljava/lang/String;
    goto :goto_24

    .line 166
    :catch_1e
    move-exception v2

    .line 167
    .local v2, "e":Ljava/lang/Exception;
    new-instance v3, Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;

    invoke-direct {v3, v1, v0}, Lcom/appcore/runtime/ReaIntegrity2$SelfHashResult;-><init>(ZLjava/lang/String;)V

    .line 163
    .end local v2    # "e":Ljava/lang/Exception;
    :goto_24
    return-object v3
.end method
