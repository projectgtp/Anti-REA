.class public final Lcom/antirea/runtime/ReaModBlock;
.super Ljava/lang/Object;
.source "ReaModBlock.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/antirea/runtime/ReaModBlock$Finding;
    }
.end annotation

.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nReaModBlock.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ReaModBlock.kt\ncom/antirea/runtime/ReaModBlock\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,199:1\n774#2:200\n865#2,2:201\n*S KotlinDebug\n*F\n+ 1 ReaModBlock.kt\ncom/antirea/runtime/ReaModBlock\n*L\n81#1:200\n81#1:201,2\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00004\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010 \n\u0002\u0010\u000e\n\u0002\u0008\u0003\n\u0002\u0010\u001e\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0006\u0008\u00c6\u0002\u0018\u00002\u00020\u0001:\u0001\u0017B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u000c\u0010\u0007\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005J\u001a\u0010\u0008\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u00052\u000c\u0010\t\u001a\u0008\u0012\u0004\u0012\u00020\u00060\nJ\u000e\u0010\u000b\u001a\u00020\u000c2\u0006\u0010\r\u001a\u00020\u0006J\u0014\u0010\u000e\u001a\u0008\u0012\u0004\u0012\u00020\u000f0\u00052\u0006\u0010\u0010\u001a\u00020\u0011J\u0014\u0010\u0012\u001a\u0008\u0012\u0004\u0012\u00020\u000f0\u00052\u0006\u0010\u0010\u001a\u00020\u0011J\u000c\u0010\u0013\u001a\u0008\u0012\u0004\u0012\u00020\u000f0\u0005J\u0014\u0010\u0014\u001a\u0008\u0012\u0004\u0012\u00020\u000f0\u00052\u0006\u0010\u0010\u001a\u00020\u0011J\u000e\u0010\u0015\u001a\u00020\u000c2\u0006\u0010\u0010\u001a\u00020\u0011J\u000e\u0010\u0016\u001a\u00020\u000c2\u0006\u0010\u0010\u001a\u00020\u0011R\u0014\u0010\u0004\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005X\u0082\u0004\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/antirea/runtime/ReaModBlock;",
        "",
        "<init>",
        "()V",
        "KNOWN_DIRS",
        "",
        "",
        "blockedPackages",
        "findBlocked",
        "installed",
        "",
        "isPackageBlocked",
        "",
        "packageName",
        "checkInstalled",
        "Lcom/antirea/runtime/ReaModBlock$Finding;",
        "context",
        "Landroid/content/Context;",
        "checkRunning",
        "checkKnownDirs",
        "checkAll",
        "isModToolPresent",
        "allowSensitiveAction",
        "Finding"
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
.field public static final INSTANCE:Lcom/antirea/runtime/ReaModBlock;

.field private static final KNOWN_DIRS:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method static constructor <clinit>()V
    .registers 3

    new-instance v0, Lcom/antirea/runtime/ReaModBlock;

    invoke-direct {v0}, Lcom/antirea/runtime/ReaModBlock;-><init>()V

    sput-object v0, Lcom/antirea/runtime/ReaModBlock;->INSTANCE:Lcom/antirea/runtime/ReaModBlock;

    .line 53
    nop

    .line 54
    nop

    .line 55
    nop

    .line 54
    nop

    .line 56
    const-string v0, "/storage/emulated/0/luckypatchers"

    const-string v1, "/storage/emulated/0/MT2"

    const-string v2, "/storage/emulated/0/LuckyPatcher"

    filled-new-array {v1, v2, v0}, [Ljava/lang/String;

    move-result-object v0

    .line 54
    nop

    .line 53
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    sput-object v0, Lcom/antirea/runtime/ReaModBlock;->KNOWN_DIRS:Ljava/util/List;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 40
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final allowSensitiveAction(Landroid/content/Context;)Z
    .registers 3
    .param p1, "context"    # Landroid/content/Context;

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 197
    invoke-virtual {p0, p1}, Lcom/antirea/runtime/ReaModBlock;->isModToolPresent(Landroid/content/Context;)Z

    move-result v0

    xor-int/lit8 v0, v0, 0x1

    return v0
.end method

.method public final blockedPackages()Ljava/util/List;
    .registers 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 65
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast v0, Ljava/util/List;

    .line 66
    .local v0, "out":Ljava/util/List;
    sget-object v1, Lcom/antirea/runtime/ModBlockData;->INSTANCE:Lcom/antirea/runtime/ModBlockData;

    invoke-virtual {v1}, Lcom/antirea/runtime/ModBlockData;->getBLOCKED()Ljava/util/List;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :goto_11
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_3c

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Lkotlin/Triple;

    invoke-virtual {v2}, Lkotlin/Triple;->component1()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    .local v3, "blob":Ljava/lang/String;
    invoke-virtual {v2}, Lkotlin/Triple;->component2()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    .local v4, "p1":Ljava/lang/String;
    invoke-virtual {v2}, Lkotlin/Triple;->component3()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    .line 67
    .local v2, "p2":Ljava/lang/String;
    nop

    .line 68
    :try_start_30
    sget-object v5, Lcom/antirea/runtime/ReaRuntime;->INSTANCE:Lcom/antirea/runtime/ReaRuntime;

    invoke-virtual {v5, v3, v4, v2}, Lcom/antirea/runtime/ReaRuntime;->decrypt(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v5

    invoke-interface {v0, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_39
    .catch Ljava/lang/Exception; {:try_start_30 .. :try_end_39} :catch_3a

    goto :goto_11

    .line 69
    :catch_3a
    move-exception v5

    .line 71
    .local v5, "e":Ljava/lang/Exception;
    goto :goto_11

    .line 74
    .end local v2    # "p2":Ljava/lang/String;
    .end local v3    # "blob":Ljava/lang/String;
    .end local v4    # "p1":Ljava/lang/String;
    .end local v5    # "e":Ljava/lang/Exception;
    :cond_3c
    return-object v0
.end method

.method public final checkAll(Landroid/content/Context;)Ljava/util/List;
    .registers 4
    .param p1, "context"    # Landroid/content/Context;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/Context;",
            ")",
            "Ljava/util/List<",
            "Lcom/antirea/runtime/ReaModBlock$Finding;",
            ">;"
        }
    .end annotation

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 165
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast v0, Ljava/util/List;

    .line 166
    .local v0, "all":Ljava/util/List;
    nop

    .line 167
    :try_start_d
    invoke-virtual {p0, p1}, Lcom/antirea/runtime/ReaModBlock;->checkInstalled(Landroid/content/Context;)Ljava/util/List;

    move-result-object v1

    check-cast v1, Ljava/util/Collection;

    invoke-interface {v0, v1}, Ljava/util/List;->addAll(Ljava/util/Collection;)Z
    :try_end_16
    .catch Ljava/lang/Exception; {:try_start_d .. :try_end_16} :catch_17

    goto :goto_18

    .line 168
    :catch_17
    move-exception v1

    .line 171
    :goto_18
    nop

    .line 172
    :try_start_19
    invoke-virtual {p0, p1}, Lcom/antirea/runtime/ReaModBlock;->checkRunning(Landroid/content/Context;)Ljava/util/List;

    move-result-object v1

    check-cast v1, Ljava/util/Collection;

    invoke-interface {v0, v1}, Ljava/util/List;->addAll(Ljava/util/Collection;)Z
    :try_end_22
    .catch Ljava/lang/Exception; {:try_start_19 .. :try_end_22} :catch_23

    goto :goto_24

    .line 173
    :catch_23
    move-exception v1

    .line 176
    :goto_24
    nop

    .line 177
    :try_start_25
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaModBlock;->checkKnownDirs()Ljava/util/List;

    move-result-object v1

    check-cast v1, Ljava/util/Collection;

    invoke-interface {v0, v1}, Ljava/util/List;->addAll(Ljava/util/Collection;)Z
    :try_end_2e
    .catch Ljava/lang/Exception; {:try_start_25 .. :try_end_2e} :catch_2f

    goto :goto_30

    .line 178
    :catch_2f
    move-exception v1

    .line 181
    :goto_30
    move-object v1, v0

    check-cast v1, Ljava/lang/Iterable;

    invoke-static {v1}, Lkotlin/collections/CollectionsKt;->distinct(Ljava/lang/Iterable;)Ljava/util/List;

    move-result-object v1

    return-object v1
.end method

.method public final checkInstalled(Landroid/content/Context;)Ljava/util/List;
    .registers 8
    .param p1, "context"    # Landroid/content/Context;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/Context;",
            ")",
            "Ljava/util/List<",
            "Lcom/antirea/runtime/ReaModBlock$Finding;",
            ">;"
        }
    .end annotation

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 93
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast v0, Ljava/util/List;

    .line 94
    .local v0, "out":Ljava/util/List;
    nop

    .line 95
    :try_start_d
    invoke-virtual {p1}, Landroid/content/Context;->getPackageManager()Landroid/content/pm/PackageManager;

    move-result-object v1
    :try_end_11
    .catch Ljava/lang/Exception; {:try_start_d .. :try_end_11} :catch_3b

    .line 94
    nop

    .line 99
    .local v1, "pm":Landroid/content/pm/PackageManager;
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaModBlock;->blockedPackages()Ljava/util/List;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :goto_1a
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_3a

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    .line 100
    .local v3, "pkg":Ljava/lang/String;
    nop

    .line 101
    const/4 v4, 0x0

    :try_start_28
    invoke-virtual {v1, v3, v4}, Landroid/content/pm/PackageManager;->getPackageInfo(Ljava/lang/String;I)Landroid/content/pm/PackageInfo;

    .line 102
    new-instance v4, Lcom/antirea/runtime/ReaModBlock$Finding;

    const-string v5, "installed"

    invoke-direct {v4, v3, v5}, Lcom/antirea/runtime/ReaModBlock$Finding;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    invoke-interface {v0, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_35
    .catch Landroid/content/pm/PackageManager$NameNotFoundException; {:try_start_28 .. :try_end_35} :catch_38
    .catch Ljava/lang/Exception; {:try_start_28 .. :try_end_35} :catch_36

    goto :goto_1a

    .line 105
    :catch_36
    move-exception v4

    .end local v3    # "pkg":Ljava/lang/String;
    goto :goto_1a

    .line 103
    .restart local v3    # "pkg":Ljava/lang/String;
    :catch_38
    move-exception v4

    goto :goto_1a

    .line 109
    .end local v3    # "pkg":Ljava/lang/String;
    :cond_3a
    return-object v0

    .line 96
    .end local v1    # "pm":Landroid/content/pm/PackageManager;
    :catch_3b
    move-exception v1

    .line 97
    .local v1, "e":Ljava/lang/Exception;
    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    return-object v2
.end method

.method public final checkKnownDirs()Ljava/util/List;
    .registers 7
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Lcom/antirea/runtime/ReaModBlock$Finding;",
            ">;"
        }
    .end annotation

    .line 140
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast v0, Ljava/util/List;

    .line 141
    .local v0, "out":Ljava/util/List;
    nop

    .line 142
    :try_start_8
    sget-object v1, Lcom/antirea/runtime/ReaModBlock;->KNOWN_DIRS:Ljava/util/List;

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_e
    :goto_e
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2
    :try_end_12
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_12} :catch_72

    const-string v3, "dir"

    if-eqz v2, :cond_33

    :try_start_16
    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;
    :try_end_1c
    .catch Ljava/lang/Exception; {:try_start_16 .. :try_end_1c} :catch_72

    .line 143
    .local v2, "dir":Ljava/lang/String;
    nop

    .line 144
    :try_start_1d
    new-instance v4, Ljava/io/File;

    invoke-direct {v4, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v4}, Ljava/io/File;->exists()Z

    move-result v4

    if-eqz v4, :cond_e

    new-instance v4, Lcom/antirea/runtime/ReaModBlock$Finding;

    invoke-direct {v4, v2, v3}, Lcom/antirea/runtime/ReaModBlock$Finding;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    invoke-interface {v0, v4}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_30
    .catch Ljava/lang/Exception; {:try_start_1d .. :try_end_30} :catch_31

    goto :goto_e

    .line 145
    :catch_31
    move-exception v3

    .line 146
    .local v3, "e":Ljava/lang/Exception;
    goto :goto_e

    .line 149
    .end local v2    # "dir":Ljava/lang/String;
    .end local v3    # "e":Ljava/lang/Exception;
    :cond_33
    :try_start_33
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaModBlock;->blockedPackages()Ljava/util/List;

    move-result-object v1

    invoke-interface {v1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_3b
    :goto_3b
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_71

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;
    :try_end_47
    .catch Ljava/lang/Exception; {:try_start_33 .. :try_end_47} :catch_72

    .line 150
    .local v2, "pkg":Ljava/lang/String;
    nop

    .line 151
    :try_start_48
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "/storage/emulated/0/Android/data/"

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    .line 152
    .local v4, "dir":Ljava/lang/String;
    new-instance v5, Ljava/io/File;

    invoke-direct {v5, v4}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v5}, Ljava/io/File;->exists()Z

    move-result v5

    if-eqz v5, :cond_3b

    new-instance v5, Lcom/antirea/runtime/ReaModBlock$Finding;

    invoke-direct {v5, v4, v3}, Lcom/antirea/runtime/ReaModBlock$Finding;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    invoke-interface {v0, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_6e
    .catch Ljava/lang/Exception; {:try_start_48 .. :try_end_6e} :catch_6f

    goto :goto_3b

    .line 153
    .end local v4    # "dir":Ljava/lang/String;
    :catch_6f
    move-exception v4

    .line 154
    .local v4, "e":Ljava/lang/Exception;
    goto :goto_3b

    .line 160
    .end local v2    # "pkg":Ljava/lang/String;
    .end local v4    # "e":Ljava/lang/Exception;
    :cond_71
    return-object v0

    .line 157
    :catch_72
    move-exception v1

    .line 158
    .local v1, "e":Ljava/lang/Exception;
    return-object v0
.end method

.method public final checkRunning(Landroid/content/Context;)Ljava/util/List;
    .registers 11
    .param p1, "context"    # Landroid/content/Context;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/Context;",
            ")",
            "Ljava/util/List<",
            "Lcom/antirea/runtime/ReaModBlock$Finding;",
            ">;"
        }
    .end annotation

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 116
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast v0, Ljava/util/List;

    .line 117
    .local v0, "out":Ljava/util/List;
    nop

    .line 118
    :try_start_d
    const-string v1, "activity"

    invoke-virtual {p1, v1}, Landroid/content/Context;->getSystemService(Ljava/lang/String;)Ljava/lang/Object;

    move-result-object v1

    instance-of v2, v1, Landroid/app/ActivityManager;

    const/4 v3, 0x0

    if-eqz v2, :cond_1b

    check-cast v1, Landroid/app/ActivityManager;

    goto :goto_1c

    :cond_1b
    move-object v1, v3

    :goto_1c
    if-nez v1, :cond_23

    .line 119
    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v1

    return-object v1

    .line 120
    .local v1, "am":Landroid/app/ActivityManager;
    :cond_23
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaModBlock;->blockedPackages()Ljava/util/List;

    move-result-object v2

    check-cast v2, Ljava/lang/Iterable;

    invoke-static {v2}, Lkotlin/collections/CollectionsKt;->toSet(Ljava/lang/Iterable;)Ljava/util/Set;

    move-result-object v2
    :try_end_2d
    .catch Ljava/lang/Exception; {:try_start_d .. :try_end_2d} :catch_6c

    .line 121
    .local v2, "blocked":Ljava/util/Set;
    nop

    .line 122
    :try_start_2e
    invoke-virtual {v1}, Landroid/app/ActivityManager;->getRunningAppProcesses()Ljava/util/List;

    move-result-object v3
    :try_end_32
    .catch Ljava/lang/Exception; {:try_start_2e .. :try_end_32} :catch_33

    goto :goto_35

    .line 123
    :catch_33
    move-exception v4

    .line 124
    .local v4, "e":Ljava/lang/Exception;
    nop

    .line 121
    .end local v4    # "e":Ljava/lang/Exception;
    :goto_35
    if-nez v3, :cond_3c

    .line 125
    :try_start_37
    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v3

    return-object v3

    .line 126
    .local v3, "procs":Ljava/util/List;
    :cond_3c
    invoke-interface {v3}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v4

    :cond_40
    :goto_40
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_64

    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Landroid/app/ActivityManager$RunningAppProcessInfo;

    .line 127
    .local v5, "proc":Landroid/app/ActivityManager$RunningAppProcessInfo;
    if-eqz v5, :cond_40

    iget-object v6, v5, Landroid/app/ActivityManager$RunningAppProcessInfo;->processName:Ljava/lang/String;

    if-nez v6, :cond_53

    goto :goto_40

    .line 128
    .local v6, "name":Ljava/lang/String;
    :cond_53
    invoke-interface {v2, v6}, Ljava/util/Set;->contains(Ljava/lang/Object;)Z

    move-result v7

    if-eqz v7, :cond_40

    new-instance v7, Lcom/antirea/runtime/ReaModBlock$Finding;

    const-string v8, "running"

    invoke-direct {v7, v6, v8}, Lcom/antirea/runtime/ReaModBlock$Finding;-><init>(Ljava/lang/String;Ljava/lang/String;)V

    invoke-interface {v0, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_63
    .catch Ljava/lang/Exception; {:try_start_37 .. :try_end_63} :catch_6c

    goto :goto_40

    .line 133
    .end local v1    # "am":Landroid/app/ActivityManager;
    .end local v2    # "blocked":Ljava/util/Set;
    .end local v3    # "procs":Ljava/util/List;
    .end local v5    # "proc":Landroid/app/ActivityManager$RunningAppProcessInfo;
    .end local v6    # "name":Ljava/lang/String;
    :cond_64
    move-object v1, v0

    check-cast v1, Ljava/lang/Iterable;

    invoke-static {v1}, Lkotlin/collections/CollectionsKt;->distinct(Ljava/lang/Iterable;)Ljava/util/List;

    move-result-object v1

    return-object v1

    .line 130
    :catch_6c
    move-exception v1

    .line 131
    .local v1, "e":Ljava/lang/Exception;
    return-object v0
.end method

.method public final findBlocked(Ljava/util/Collection;)Ljava/util/List;
    .registers 12
    .param p1, "installed"    # Ljava/util/Collection;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/Collection<",
            "Ljava/lang/String;",
            ">;)",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    const-string v0, "installed"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 80
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaModBlock;->blockedPackages()Ljava/util/List;

    move-result-object v0

    check-cast v0, Ljava/lang/Iterable;

    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->toSet(Ljava/lang/Iterable;)Ljava/util/Set;

    move-result-object v0

    .line 81
    .local v0, "blocked":Ljava/util/Set;
    move-object v1, p1

    check-cast v1, Ljava/lang/Iterable;

    .local v1, "$this$filter$iv":Ljava/lang/Iterable;
    const/4 v2, 0x0

    .line 200
    .local v2, "$i$f$filter":I
    new-instance v3, Ljava/util/ArrayList;

    invoke-direct {v3}, Ljava/util/ArrayList;-><init>()V

    check-cast v3, Ljava/util/Collection;

    .local v3, "destination$iv$iv":Ljava/util/Collection;
    move-object v4, v1

    .local v4, "$this$filterTo$iv$iv":Ljava/lang/Iterable;
    const/4 v5, 0x0

    .line 201
    .local v5, "$i$f$filterTo":I
    invoke-interface {v4}, Ljava/lang/Iterable;->iterator()Ljava/util/Iterator;

    move-result-object v6

    :cond_20
    :goto_20
    invoke-interface {v6}, Ljava/util/Iterator;->hasNext()Z

    move-result v7

    if-eqz v7, :cond_38

    invoke-interface {v6}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v7

    .local v7, "element$iv$iv":Ljava/lang/Object;
    move-object v8, v7

    check-cast v8, Ljava/lang/String;

    .local v8, "it":Ljava/lang/String;
    const/4 v9, 0x0

    .line 81
    .local v9, "$i$a$-filter-ReaModBlock$findBlocked$1":I
    invoke-interface {v0, v8}, Ljava/util/Set;->contains(Ljava/lang/Object;)Z

    move-result v8

    .line 201
    .end local v8    # "it":Ljava/lang/String;
    .end local v9    # "$i$a$-filter-ReaModBlock$findBlocked$1":I
    if-eqz v8, :cond_20

    invoke-interface {v3, v7}, Ljava/util/Collection;->add(Ljava/lang/Object;)Z

    goto :goto_20

    .line 202
    .end local v7    # "element$iv$iv":Ljava/lang/Object;
    :cond_38
    nop

    .end local v3    # "destination$iv$iv":Ljava/util/Collection;
    .end local v4    # "$this$filterTo$iv$iv":Ljava/lang/Iterable;
    .end local v5    # "$i$f$filterTo":I
    check-cast v3, Ljava/util/List;

    .line 200
    nop

    .end local v1    # "$this$filter$iv":Ljava/lang/Iterable;
    .end local v2    # "$i$f$filter":I
    check-cast v3, Ljava/lang/Iterable;

    .line 81
    invoke-static {v3}, Lkotlin/collections/CollectionsKt;->distinct(Ljava/lang/Iterable;)Ljava/util/List;

    move-result-object v1

    check-cast v1, Ljava/lang/Iterable;

    invoke-static {v1}, Lkotlin/collections/CollectionsKt;->sorted(Ljava/lang/Iterable;)Ljava/util/List;

    move-result-object v1

    return-object v1
.end method

.method public final isModToolPresent(Landroid/content/Context;)Z
    .registers 4
    .param p1, "context"    # Landroid/content/Context;

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 187
    nop

    .line 188
    :try_start_6
    invoke-virtual {p0, p1}, Lcom/antirea/runtime/ReaModBlock;->checkAll(Landroid/content/Context;)Ljava/util/List;

    move-result-object v0

    check-cast v0, Ljava/util/Collection;

    invoke-interface {v0}, Ljava/util/Collection;->isEmpty()Z

    move-result v0
    :try_end_10
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_10} :catch_13

    xor-int/lit8 v0, v0, 0x1

    goto :goto_16

    .line 189
    :catch_13
    move-exception v0

    .line 190
    .local v0, "e":Ljava/lang/Exception;
    const/4 v1, 0x0

    move v0, v1

    .line 191
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_16
    return v0
.end method

.method public final isPackageBlocked(Ljava/lang/String;)Z
    .registers 3
    .param p1, "packageName"    # Ljava/lang/String;

    const-string v0, "packageName"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 86
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaModBlock;->blockedPackages()Ljava/util/List;

    move-result-object v0

    check-cast v0, Ljava/lang/Iterable;

    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->toSet(Ljava/lang/Iterable;)Ljava/util/Set;

    move-result-object v0

    invoke-interface {v0, p1}, Ljava/util/Set;->contains(Ljava/lang/Object;)Z

    move-result v0

    return v0
.end method
