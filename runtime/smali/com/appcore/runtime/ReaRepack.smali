.class public final Lcom/appcore/runtime/ReaRepack;
.super Ljava/lang/Object;
.source "ReaRepack.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/appcore/runtime/ReaRepack$RepackResult;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00008\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u000b\n\u0000\n\u0002\u0010\u000e\n\u0002\u0008\u0003\n\u0002\u0010\u0012\n\u0002\u0008\u000b\n\u0002\u0018\u0002\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0000\u0008\u00c6\u0002\u0018\u00002\u00020\u0001:\u0001\u001eB\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u0018\u0010\u0004\u001a\u00020\u00052\u0008\u0010\u0006\u001a\u0004\u0018\u00010\u00072\u0006\u0010\u0008\u001a\u00020\u0007J\u0016\u0010\t\u001a\u00020\u00052\u0006\u0010\n\u001a\u00020\u000b2\u0006\u0010\u000c\u001a\u00020\u0007J\u0018\u0010\r\u001a\u00020\u00052\u0008\u0010\u000e\u001a\u0004\u0018\u00010\u00072\u0006\u0010\u000c\u001a\u00020\u0007J&\u0010\u000f\u001a\u00020\u00052\u0006\u0010\u0010\u001a\u00020\u00072\u0006\u0010\u0011\u001a\u00020\u00072\u0006\u0010\u0012\u001a\u00020\u00072\u0006\u0010\n\u001a\u00020\u000bJ\u0010\u0010\u0013\u001a\u00020\u00072\u0008\u0010\u0014\u001a\u0004\u0018\u00010\u0007J\u0010\u0010\u0015\u001a\u0004\u0018\u00010\u00072\u0006\u0010\u0016\u001a\u00020\u0017J\u0010\u0010\u0018\u001a\u0004\u0018\u00010\u00072\u0006\u0010\u0016\u001a\u00020\u0017J4\u0010\u0019\u001a\u00020\u001a2\u0006\u0010\u0016\u001a\u00020\u00172\u0006\u0010\u001b\u001a\u00020\u00072\u001c\u0008\u0002\u0010\u001c\u001a\u0016\u0012\u0004\u0012\u00020\u0007\u0012\u0004\u0012\u00020\u0007\u0012\u0004\u0012\u00020\u0007\u0018\u00010\u001d"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaRepack;",
        "",
        "<init>",
        "()V",
        "verifyPackageName",
        "",
        "actual",
        "",
        "expected",
        "verifySigningCertSha256",
        "certBytes",
        "",
        "expectedHex",
        "verifySigningCertHex",
        "liveHex",
        "verifyExpectedHashBlob",
        "blobBase64",
        "keyPart1B64",
        "keyPart2B64",
        "classifyInstaller",
        "installerPackage",
        "getSigningCertSha256",
        "context",
        "Landroid/content/Context;",
        "getInstallerPackage",
        "checkRepack",
        "Lcom/appcore/runtime/ReaRepack$RepackResult;",
        "expectedPackage",
        "expectedCertBlob",
        "Lkotlin/Triple;",
        "RepackResult"
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
.field public static final INSTANCE:Lcom/appcore/runtime/ReaRepack;


# direct methods
.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/appcore/runtime/ReaRepack;

    invoke-direct {v0}, Lcom/appcore/runtime/ReaRepack;-><init>()V

    sput-object v0, Lcom/appcore/runtime/ReaRepack;->INSTANCE:Lcom/appcore/runtime/ReaRepack;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 59
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static synthetic checkRepack$default(Lcom/appcore/runtime/ReaRepack;Landroid/content/Context;Ljava/lang/String;Lkotlin/Triple;ILjava/lang/Object;)Lcom/appcore/runtime/ReaRepack$RepackResult;
    .registers 6

    .line 186
    and-int/lit8 p4, p4, 0x4

    if-eqz p4, :cond_5

    .line 189
    const/4 p3, 0x0

    .line 186
    :cond_5
    invoke-virtual {p0, p1, p2, p3}, Lcom/appcore/runtime/ReaRepack;->checkRepack(Landroid/content/Context;Ljava/lang/String;Lkotlin/Triple;)Lcom/appcore/runtime/ReaRepack$RepackResult;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final checkRepack(Landroid/content/Context;Ljava/lang/String;Lkotlin/Triple;)Lcom/appcore/runtime/ReaRepack$RepackResult;
    .registers 13
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "expectedPackage"    # Ljava/lang/String;
    .param p3, "expectedCertBlob"    # Lkotlin/Triple;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/Context;",
            "Ljava/lang/String;",
            "Lkotlin/Triple<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;)",
            "Lcom/appcore/runtime/ReaRepack$RepackResult;"
        }
    .end annotation

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedPackage"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 191
    nop

    .line 192
    const/4 v0, 0x0

    :try_start_c
    invoke-virtual {p1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1
    :try_end_10
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_10} :catch_11

    goto :goto_13

    .line 193
    :catch_11
    move-exception v1

    .line 194
    .local v1, "e":Ljava/lang/Exception;
    move-object v1, v0

    .line 191
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_13
    nop

    .line 196
    .local v1, "actualPackage":Ljava/lang/String;
    invoke-virtual {p0, v1, p2}, Lcom/appcore/runtime/ReaRepack;->verifyPackageName(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v2

    .line 197
    .local v2, "packageOk":Z
    const/4 v3, 0x0

    if-nez p3, :cond_1d

    .line 198
    move-object v4, v0

    goto :goto_6b

    .line 200
    :cond_1d
    nop

    .line 201
    :try_start_1e
    invoke-virtual {p0, p1}, Lcom/appcore/runtime/ReaRepack;->getSigningCertSha256(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v4
    :try_end_22
    .catch Ljava/lang/Exception; {:try_start_1e .. :try_end_22} :catch_65

    .line 202
    .local v4, "certHex":Ljava/lang/String;
    if-nez v4, :cond_26

    .line 203
    move v6, v3

    goto :goto_4f

    .line 205
    :cond_26
    nop

    .line 210
    nop

    .line 206
    :try_start_28
    sget-object v5, Lcom/appcore/runtime/ReaRuntime;->INSTANCE:Lcom/appcore/runtime/ReaRuntime;

    .line 207
    invoke-virtual {p3}, Lkotlin/Triple;->getFirst()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/lang/String;

    .line 208
    invoke-virtual {p3}, Lkotlin/Triple;->getSecond()Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Ljava/lang/String;

    .line 209
    invoke-virtual {p3}, Lkotlin/Triple;->getThird()Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/lang/String;

    .line 206
    invoke-virtual {v5, v6, v7, v8}, Lcom/appcore/runtime/ReaRuntime;->decrypt(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    check-cast v5, Ljava/lang/CharSequence;

    invoke-static {v5}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v5
    :try_end_4a
    .catch Ljava/lang/Exception; {:try_start_28 .. :try_end_4a} :catch_50

    .line 205
    nop

    .line 221
    .local v5, "expectedHex":Ljava/lang/String;
    :try_start_4b
    invoke-virtual {p0, v4, v5}, Lcom/appcore/runtime/ReaRepack;->verifySigningCertHex(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v6

    .end local v4    # "certHex":Ljava/lang/String;
    .end local v5    # "expectedHex":Ljava/lang/String;
    :goto_4f
    goto :goto_67

    .line 211
    .restart local v4    # "certHex":Ljava/lang/String;
    :catch_50
    move-exception v5

    .line 212
    .local v5, "e":Ljava/lang/Exception;
    new-instance v6, Lcom/appcore/runtime/ReaRepack$RepackResult;

    .line 213
    nop

    .line 214
    invoke-static {v3}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v7

    .line 215
    invoke-virtual {p0, p1}, Lcom/appcore/runtime/ReaRepack;->getInstallerPackage(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v8

    invoke-virtual {p0, v8}, Lcom/appcore/runtime/ReaRepack;->classifyInstaller(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v8

    .line 216
    nop

    .line 212
    invoke-direct {v6, v2, v7, v8, v3}, Lcom/appcore/runtime/ReaRepack$RepackResult;-><init>(ZLjava/lang/Boolean;Ljava/lang/String;Z)V
    :try_end_64
    .catch Ljava/lang/Exception; {:try_start_4b .. :try_end_64} :catch_65

    return-object v6

    .line 223
    .end local v4    # "certHex":Ljava/lang/String;
    .end local v5    # "e":Ljava/lang/Exception;
    :catch_65
    move-exception v4

    .line 224
    .local v4, "e":Ljava/lang/Exception;
    move v6, v3

    .end local v4    # "e":Ljava/lang/Exception;
    :goto_67
    invoke-static {v6}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v4

    .line 197
    :goto_6b
    nop

    .line 227
    .local v4, "signatureOk":Ljava/lang/Boolean;
    nop

    .line 228
    nop

    .line 229
    :try_start_6e
    invoke-virtual {p0, p1}, Lcom/appcore/runtime/ReaRepack;->getInstallerPackage(Landroid/content/Context;)Ljava/lang/String;

    move-result-object v0
    :try_end_72
    .catch Ljava/lang/Exception; {:try_start_6e .. :try_end_72} :catch_73

    goto :goto_75

    .line 230
    :catch_73
    move-exception v5

    .line 231
    .restart local v5    # "e":Ljava/lang/Exception;
    nop

    .line 227
    .end local v5    # "e":Ljava/lang/Exception;
    :goto_75
    invoke-virtual {p0, v0}, Lcom/appcore/runtime/ReaRepack;->classifyInstaller(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 234
    .local v0, "installer":Ljava/lang/String;
    if-eqz v2, :cond_86

    invoke-static {v3}, Ljava/lang/Boolean;->valueOf(Z)Ljava/lang/Boolean;

    move-result-object v5

    invoke-static {v4, v5}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v5

    if-nez v5, :cond_86

    const/4 v3, 0x1

    .line 235
    .local v3, "allow":Z
    :cond_86
    new-instance v5, Lcom/appcore/runtime/ReaRepack$RepackResult;

    invoke-direct {v5, v2, v4, v0, v3}, Lcom/appcore/runtime/ReaRepack$RepackResult;-><init>(ZLjava/lang/Boolean;Ljava/lang/String;Z)V

    return-object v5
.end method

.method public final classifyInstaller(Ljava/lang/String;)Ljava/lang/String;
    .registers 3
    .param p1, "installerPackage"    # Ljava/lang/String;

    .line 130
    move-object v0, p1

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
    if-eqz v0, :cond_14

    const-string v0, "unknown"

    return-object v0

    .line 131
    :cond_14
    const-string v0, "com.android.vending"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_1f

    const-string v0, "play-store"

    goto :goto_21

    .line 132
    :cond_1f
    const-string v0, "third-party-or-sideload"

    .line 131
    :goto_21
    return-object v0
.end method

.method public final getInstallerPackage(Landroid/content/Context;)Ljava/lang/String;
    .registers 6
    .param p1, "context"    # Landroid/content/Context;

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 165
    nop

    .line 166
    :try_start_6
    invoke-virtual {p1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v0

    .line 167
    .local v0, "pm":Landroid/content/pm/PackageManager;
    invoke-virtual {p1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v1

    .line 168
    .local v1, "pkg":Ljava/lang/String;
    sget v2, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v3, 0x1e

    if-lt v2, v3, :cond_1d

    .line 169
    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getInstallSourceInfo(Ljava/lang/String;)Landroid/content/pm/InstallSourceInfo;

    move-result-object v2

    invoke-virtual {v2}, Landroid/content/pm/InstallSourceInfo;->getInstallingPackageName()Ljava/lang/String;

    move-result-object v2

    goto :goto_21

    .line 172
    :cond_1d
    invoke-virtual {v0, v1}, Landroid/content/pm/PackageManager;->getInstallerPackageName(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v2
    :try_end_21
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_21} :catch_22

    .end local v0    # "pm":Landroid/content/pm/PackageManager;
    .end local v1    # "pkg":Ljava/lang/String;
    :goto_21
    goto :goto_24

    .line 174
    :catch_22
    move-exception v0

    .line 175
    .local v0, "e":Ljava/lang/Exception;
    const/4 v2, 0x0

    .line 165
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_24
    return-object v2
.end method

.method public final getSigningCertSha256(Landroid/content/Context;)Ljava/lang/String;
    .registers 11
    .param p1, "context"    # Landroid/content/Context;

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 143
    nop

    .line 144
    const/4 v0, 0x0

    :try_start_7
    invoke-virtual {p1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v1

    .line 145
    .local v1, "pm":Landroid/content/pm/PackageManager;
    invoke-virtual {p1}, Landroid/content/Context;->getPackageName()Ljava/lang/String;

    move-result-object v2

    .line 146
    .local v2, "pkg":Ljava/lang/String;
    sget v3, Landroid/os/Build$VERSION;->SDK_INT:I

    const/16 v4, 0x1c

    if-lt v3, v4, :cond_1f

    .line 147
    const/high16 v3, 0x8000000

    invoke-virtual {v1, v2, v3}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v3

    .line 146
    invoke-static {v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    goto :goto_28

    .line 149
    :cond_1f
    const/16 v3, 0x40

    invoke-virtual {v1, v2, v3}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    move-result-object v3

    .line 148
    invoke-static {v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    .line 146
    :goto_28
    nop

    .line 151
    .local v3, "info":Landroid/content/pm/PackageInfo;
    sget v5, Landroid/os/Build$VERSION;->SDK_INT:I

    if-lt v5, v4, :cond_38

    .line 152
    iget-object v4, v3, Landroid/content/pm/PackageInfo;->signingInfo:Landroid/content/pm/SigningInfo;

    if-eqz v4, :cond_36

    invoke-virtual {v4}, Landroid/content/pm/SigningInfo;->getApkContentsSigners()[Landroid/content/pm/Signature;

    move-result-object v4

    goto :goto_3a

    :cond_36
    move-object v4, v0

    goto :goto_3a

    .line 154
    :cond_38
    iget-object v4, v3, Landroid/content/pm/PackageInfo;->signatures:[Landroid/content/pm/Signature;

    .line 151
    :goto_3a
    nop

    .line 156
    .local v4, "certs":[Landroid/content/pm/Signature;
    if-eqz v4, :cond_56

    invoke-static {v4}, Lkotlin/collections/ArraysKt;->firstOrNull([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Landroid/content/pm/Signature;

    if-nez v5, :cond_46

    goto :goto_56

    .line 157
    .local v5, "first":Landroid/content/pm/Signature;
    :cond_46
    sget-object v6, Lcom/appcore/runtime/ReaIntegrity;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity;

    invoke-virtual {v5}, Landroid/content/pm/Signature;->toByteArray()[B

    move-result-object v7

    const-string v8, "toByteArray(...)"

    invoke-static {v7, v8}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-virtual {v6, v7}, Lcom/appcore/runtime/ReaIntegrity;->sha256Hex([B)Ljava/lang/String;

    move-result-object v0
    :try_end_55
    .catch Ljava/lang/Exception; {:try_start_7 .. :try_end_55} :catch_57

    .end local v1    # "pm":Landroid/content/pm/PackageManager;
    .end local v2    # "pkg":Ljava/lang/String;
    .end local v3    # "info":Landroid/content/pm/PackageInfo;
    .end local v4    # "certs":[Landroid/content/pm/Signature;
    .end local v5    # "first":Landroid/content/pm/Signature;
    goto :goto_59

    .line 156
    .restart local v1    # "pm":Landroid/content/pm/PackageManager;
    .restart local v2    # "pkg":Ljava/lang/String;
    .restart local v3    # "info":Landroid/content/pm/PackageInfo;
    .restart local v4    # "certs":[Landroid/content/pm/Signature;
    :cond_56
    :goto_56
    return-object v0

    .line 158
    .end local v1    # "pm":Landroid/content/pm/PackageManager;
    .end local v2    # "pkg":Ljava/lang/String;
    .end local v3    # "info":Landroid/content/pm/PackageInfo;
    .end local v4    # "certs":[Landroid/content/pm/Signature;
    :catch_57
    move-exception v1

    .line 159
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 143
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_59
    return-object v0
.end method

.method public final verifyExpectedHashBlob(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;[B)Z
    .registers 7
    .param p1, "blobBase64"    # Ljava/lang/String;
    .param p2, "keyPart1B64"    # Ljava/lang/String;
    .param p3, "keyPart2B64"    # Ljava/lang/String;
    .param p4, "certBytes"    # [B

    const-string v0, "blobBase64"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart1B64"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "keyPart2B64"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "certBytes"

    invoke-static {p4, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 115
    nop

    .line 116
    :try_start_15
    sget-object v0, Lcom/appcore/runtime/ReaRuntime;->INSTANCE:Lcom/appcore/runtime/ReaRuntime;

    invoke-virtual {v0, p1, p2, p3}, Lcom/appcore/runtime/ReaRuntime;->decrypt(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    .line 117
    .local v0, "expectedHex":Ljava/lang/String;
    move-object v1, v0

    check-cast v1, Ljava/lang/CharSequence;

    invoke-static {v1}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v1

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, p4, v1}, Lcom/appcore/runtime/ReaRepack;->verifySigningCertSha256([BLjava/lang/String;)Z

    move-result v1
    :try_end_2a
    .catch Ljava/lang/Exception; {:try_start_15 .. :try_end_2a} :catch_2b

    .end local v0    # "expectedHex":Ljava/lang/String;
    goto :goto_2d

    .line 118
    :catch_2b
    move-exception v0

    .line 119
    .local v0, "e":Ljava/lang/Exception;
    const/4 v1, 0x0

    .line 115
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_2d
    return v1
.end method

.method public final verifyPackageName(Ljava/lang/String;Ljava/lang/String;)Z
    .registers 4
    .param p1, "actual"    # Ljava/lang/String;
    .param p2, "expected"    # Ljava/lang/String;

    const-string v0, "expected"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 75
    if-nez p1, :cond_9

    const/4 v0, 0x0

    return v0

    .line 76
    :cond_9
    invoke-static {p1, p2}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    return v0
.end method

.method public final verifySigningCertHex(Ljava/lang/String;Ljava/lang/String;)Z
    .registers 7
    .param p1, "liveHex"    # Ljava/lang/String;
    .param p2, "expectedHex"    # Ljava/lang/String;

    const-string v0, "expectedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 97
    move-object v0, p1

    check-cast v0, Ljava/lang/CharSequence;

    const/4 v1, 0x0

    if-eqz v0, :cond_14

    invoke-static {v0}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_12

    goto :goto_14

    :cond_12
    move v0, v1

    goto :goto_15

    :cond_14
    :goto_14
    const/4 v0, 0x1

    :goto_15
    if-eqz v0, :cond_18

    return v1

    .line 98
    :cond_18
    move-object v0, p2

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_22

    return v1

    .line 99
    :cond_22
    move-object v0, p1

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    sget-object v1, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v0, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "toLowerCase(...)"

    invoke-static {v0, v1}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    move-object v2, p2

    check-cast v2, Ljava/lang/CharSequence;

    invoke-static {v2}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v2

    sget-object v3, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v2, v3}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v2

    invoke-static {v2, v1}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-static {v0, v2}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    return v0
.end method

.method public final verifySigningCertSha256([BLjava/lang/String;)Z
    .registers 7
    .param p1, "certBytes"    # [B
    .param p2, "expectedHex"    # Ljava/lang/String;

    const-string v0, "certBytes"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "expectedHex"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 82
    nop

    .line 83
    const/4 v0, 0x0

    :try_start_c
    array-length v1, p1

    if-nez v1, :cond_11

    const/4 v1, 0x1

    goto :goto_12

    :cond_11
    move v1, v0

    :goto_12
    if-eqz v1, :cond_15

    return v0

    .line 84
    :cond_15
    move-object v1, p2

    check-cast v1, Ljava/lang/CharSequence;

    invoke-static {v1}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v1

    if-eqz v1, :cond_1f

    return v0

    .line 85
    :cond_1f
    sget-object v1, Lcom/appcore/runtime/ReaIntegrity;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity;

    invoke-virtual {v1, p1}, Lcom/appcore/runtime/ReaIntegrity;->sha256Hex([B)Ljava/lang/String;

    move-result-object v1

    sget-object v2, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {p2, v2}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v2

    const-string v3, "toLowerCase(...)"

    invoke-static {v2, v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    invoke-static {v1, v2}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0
    :try_end_34
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_34} :catch_35

    goto :goto_37

    .line 86
    :catch_35
    move-exception v1

    .line 87
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 82
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_37
    return v0
.end method
