.class public final Lcom/appcore/runtime/ReaNative;
.super Ljava/lang/Object;
.source "ReaNative.kt"


# annotations
.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\"\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u000b\n\u0002\u0008\u0004\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u0012\n\u0002\u0008\u0004\u0008\u00c6\u0002\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u0019\u0010\u0008\u001a\u00020\u00052\u0006\u0010\t\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\u000cH\u0087 J\t\u0010\r\u001a\u00020\nH\u0087 J\u0008\u0010\u000e\u001a\u0004\u0018\u00010\nJ\u0016\u0010\u000f\u001a\u00020\u00052\u0006\u0010\t\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\u000cJ\u0016\u0010\u0010\u001a\u00020\u00052\u0006\u0010\t\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\u000cR\u0011\u0010\u0004\u001a\u00020\u0005\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0006\u0010\u0007"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaNative;",
        "",
        "<init>",
        "()V",
        "nativeLoaded",
        "",
        "getNativeLoaded",
        "()Z",
        "nativeGate",
        "expectedHex",
        "",
        "data",
        "",
        "nativeVersion",
        "nativeVersionSafe",
        "javaGate",
        "integrityGate"
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
.field public static final INSTANCE:Lcom/appcore/runtime/ReaNative;

.field private static final nativeLoaded:Z


# direct methods
.method static constructor <clinit>()V
    .registers 2

    new-instance v0, Lcom/appcore/runtime/ReaNative;

    invoke-direct {v0}, Lcom/appcore/runtime/ReaNative;-><init>()V

    sput-object v0, Lcom/appcore/runtime/ReaNative;->INSTANCE:Lcom/appcore/runtime/ReaNative;

    .line 34
    nop

    .line 35
    const/4 v0, 0x0

    .line 36
    .local v0, "loaded":Z
    nop

    .line 37
    :try_start_a
    const-string v1, "reagate"

    invoke-static {v1}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    :try_end_f
    .catchall {:try_start_a .. :try_end_f} :catchall_11

    .line 38
    const/4 v0, 0x1

    goto :goto_13

    .line 39
    :catchall_11
    move-exception v1

    .line 42
    .local v1, "e":Ljava/lang/Throwable;
    const/4 v0, 0x0

    .line 44
    .end local v1    # "e":Ljava/lang/Throwable;
    :goto_13
    sput-boolean v0, Lcom/appcore/runtime/ReaNative;->nativeLoaded:Z

    .line 45
    .end local v0    # "loaded":Z
    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 29
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static final native nativeGate(Ljava/lang/String;[B)Z
    .annotation runtime Lkotlin/jvm/JvmStatic;
    .end annotation
.end method

.method public static final native nativeVersion()Ljava/lang/String;
    .annotation runtime Lkotlin/jvm/JvmStatic;
    .end annotation
.end method


# virtual methods
.method public final getNativeLoaded()Z
    .registers 2

    .line 32
    sget-boolean v0, Lcom/appcore/runtime/ReaNative;->nativeLoaded:Z

    return v0
.end method

.method public final integrityGate(Ljava/lang/String;[B)Z
    .registers 4
    .param p1, "expectedHex"    # Ljava/lang/String;
    .param p2, "data"    # [B

    const-string v0, "expectedHex"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "data"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 100
    sget-boolean v0, Lcom/appcore/runtime/ReaNative;->nativeLoaded:Z

    if-eqz v0, :cond_15

    .line 101
    nop

    .line 102
    :try_start_f
    invoke-static {p1, p2}, Lcom/appcore/runtime/ReaNative;->nativeGate(Ljava/lang/String;[B)Z

    move-result v0
    :try_end_13
    .catchall {:try_start_f .. :try_end_13} :catchall_14

    return v0

    .line 103
    :catchall_14
    move-exception v0

    .line 107
    :cond_15
    invoke-virtual {p0, p1, p2}, Lcom/appcore/runtime/ReaNative;->javaGate(Ljava/lang/String;[B)Z

    move-result v0

    return v0
.end method

.method public final javaGate(Ljava/lang/String;[B)Z
    .registers 5
    .param p1, "expectedHex"    # Ljava/lang/String;
    .param p2, "data"    # [B

    const-string v0, "expectedHex"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "data"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 87
    nop

    .line 88
    :try_start_b
    sget-object v0, Lcom/appcore/runtime/ReaIntegrity2;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity2;

    sget-object v1, Lcom/appcore/runtime/ReaRuntime;->INSTANCE:Lcom/appcore/runtime/ReaRuntime;

    invoke-virtual {v1, p2}, Lcom/appcore/runtime/ReaRuntime;->sha256Hex([B)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {v0, v1, p1}, Lcom/appcore/runtime/ReaIntegrity2;->hexEqualsConstantTime(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v0
    :try_end_17
    .catch Ljava/lang/Exception; {:try_start_b .. :try_end_17} :catch_18

    goto :goto_1b

    .line 89
    :catch_18
    move-exception v0

    .line 90
    .local v0, "e":Ljava/lang/Exception;
    const/4 v1, 0x0

    move v0, v1

    .line 87
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1b
    return v0
.end method

.method public final nativeVersionSafe()Ljava/lang/String;
    .registers 3

    .line 69
    sget-boolean v0, Lcom/appcore/runtime/ReaNative;->nativeLoaded:Z

    const/4 v1, 0x0

    if-nez v0, :cond_6

    return-object v1

    .line 70
    :cond_6
    nop

    .line 71
    :try_start_7
    invoke-static {}, Lcom/appcore/runtime/ReaNative;->nativeVersion()Ljava/lang/String;

    move-result-object v1
    :try_end_b
    .catchall {:try_start_7 .. :try_end_b} :catchall_c

    goto :goto_e

    .line 72
    :catchall_c
    move-exception v0

    .line 73
    .local v0, "e":Ljava/lang/Throwable;
    nop

    .line 70
    .end local v0    # "e":Ljava/lang/Throwable;
    :goto_e
    return-object v1
.end method
