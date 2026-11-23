.class public final Lcom/antirea/runtime/ReaEnv;
.super Ljava/lang/Object;
.source "ReaEnv.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/antirea/runtime/ReaEnv$Finding;
    }
.end annotation

.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nReaEnv.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ReaEnv.kt\ncom/antirea/runtime/ReaEnv\n+ 2 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,275:1\n1782#2,4:276\n*S KotlinDebug\n*F\n+ 1 ReaEnv.kt\ncom/antirea/runtime/ReaEnv\n*L\n255#1:276,4\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000(\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0018\u0002\n\u0002\u0008\n\n\u0002\u0010 \n\u0000\n\u0002\u0010\u0008\n\u0000\n\u0002\u0010\u000e\n\u0002\u0008\u0002\u0008\u00c6\u0002\u0018\u00002\u00020\u0001:\u0001\u0016B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u0006\u0010\u0004\u001a\u00020\u0005J\u0006\u0010\u0006\u001a\u00020\u0005J\u0006\u0010\u0007\u001a\u00020\u0005J\u0006\u0010\u0008\u001a\u00020\u0005J\u0006\u0010\t\u001a\u00020\u0005J\u0006\u0010\n\u001a\u00020\u0005J\u0006\u0010\u000b\u001a\u00020\u0005J\u0006\u0010\u000c\u001a\u00020\u0005J\u0006\u0010\r\u001a\u00020\u0005J\u0006\u0010\u000e\u001a\u00020\u0005J\u000c\u0010\u000f\u001a\u0008\u0012\u0004\u0012\u00020\u00050\u0010J\u0006\u0010\u0011\u001a\u00020\u0012J\u001c\u0010\u0013\u001a\u0008\u0012\u0004\u0012\u00020\u00140\u00102\u000c\u0010\u0015\u001a\u0008\u0012\u0004\u0012\u00020\u00140\u0010H\u0002"
    }
    d2 = {
        "Lcom/antirea/runtime/ReaEnv;",
        "",
        "<init>",
        "()V",
        "isDebuggerConnected",
        "Lcom/antirea/runtime/ReaEnv$Finding;",
        "isEmulator",
        "isRooted",
        "fridaMapsDetected",
        "fridaPortsDetected",
        "hookLibsDetected",
        "isBeingTraced",
        "gameGuardianMapsDetected",
        "gameGuardianFilesDetected",
        "memoryEditorDetected",
        "checkAll",
        "",
        "suspiciousCount",
        "",
        "readMapsHits",
        "",
        "needles",
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
.field public static final INSTANCE:Lcom/antirea/runtime/ReaEnv;


# direct methods
.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/antirea/runtime/ReaEnv;

    invoke-direct {v0}, Lcom/antirea/runtime/ReaEnv;-><init>()V

    sput-object v0, Lcom/antirea/runtime/ReaEnv;->INSTANCE:Lcom/antirea/runtime/ReaEnv;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 23
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private final readMapsHits(Ljava/util/List;)Ljava/util/List;
    .registers 14
    .param p1, "needles"    # Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;)",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 259
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast v0, Ljava/util/List;

    .line 260
    .local v0, "hits":Ljava/util/List;
    nop

    .line 261
    :try_start_8
    new-instance v1, Ljava/io/File;

    const-string v2, "/proc/self/maps"

    invoke-direct {v1, v2}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 262
    .local v1, "file":Ljava/io/File;
    invoke-virtual {v1}, Ljava/io/File;->canRead()Z

    move-result v2

    if-nez v2, :cond_1a

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    return-object v2

    .line 263
    :cond_1a
    const/4 v2, 0x1

    const/4 v3, 0x0

    invoke-static {v1, v3, v2, v3}, Lkotlin/io/FilesKt;->readLines$default(Ljava/io/File;Ljava/nio/charset/Charset;ILjava/lang/Object;)Ljava/util/List;

    move-result-object v2

    invoke-interface {v2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :cond_24
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_63

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    .line 264
    .local v4, "line":Ljava/lang/String;
    sget-object v5, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v4, v5}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v5

    const-string v6, "toLowerCase(...)"

    invoke-static {v5, v6}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    .line 265
    .local v5, "lower":Ljava/lang/String;
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v6

    :cond_3f
    :goto_3f
    invoke-interface {v6}, Ljava/util/Iterator;->hasNext()Z

    move-result v7

    if-eqz v7, :cond_24

    invoke-interface {v6}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v7

    check-cast v7, Ljava/lang/String;

    .line 266
    .local v7, "n":Ljava/lang/String;
    move-object v8, v5

    check-cast v8, Ljava/lang/CharSequence;

    move-object v9, v7

    check-cast v9, Ljava/lang/CharSequence;

    const/4 v10, 0x0

    const/4 v11, 0x2

    invoke-static {v8, v9, v10, v11, v3}, Lkotlin/text/StringsKt;->contains$default(Ljava/lang/CharSequence;Ljava/lang/CharSequence;ZILjava/lang/Object;)Z

    move-result v8

    if-eqz v8, :cond_3f

    invoke-interface {v0, v7}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v8

    if-nez v8, :cond_3f

    invoke-interface {v0, v7}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_62
    .catch Ljava/lang/Exception; {:try_start_8 .. :try_end_62} :catch_64

    goto :goto_3f

    .line 272
    .end local v1    # "file":Ljava/io/File;
    .end local v4    # "line":Ljava/lang/String;
    .end local v5    # "lower":Ljava/lang/String;
    .end local v7    # "n":Ljava/lang/String;
    :cond_63
    return-object v0

    .line 269
    :catch_64
    move-exception v1

    .line 270
    .local v1, "e":Ljava/lang/Exception;
    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v2

    return-object v2
.end method


# virtual methods
.method public final checkAll()Ljava/util/List;
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Lcom/antirea/runtime/ReaEnv$Finding;",
            ">;"
        }
    .end annotation

    .line 242
    const/16 v0, 0xa

    new-array v0, v0, [Lcom/antirea/runtime/ReaEnv$Finding;

    const/4 v1, 0x0

    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->isDebuggerConnected()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v2

    aput-object v2, v0, v1

    .line 243
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->isEmulator()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v1

    const/4 v2, 0x1

    aput-object v1, v0, v2

    .line 242
    nop

    .line 244
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->isRooted()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v1

    const/4 v2, 0x2

    aput-object v1, v0, v2

    .line 242
    nop

    .line 245
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->fridaMapsDetected()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v1

    const/4 v2, 0x3

    aput-object v1, v0, v2

    .line 242
    nop

    .line 246
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->fridaPortsDetected()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v1

    const/4 v2, 0x4

    aput-object v1, v0, v2

    .line 242
    nop

    .line 247
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->hookLibsDetected()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v1

    const/4 v2, 0x5

    aput-object v1, v0, v2

    .line 242
    nop

    .line 248
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->isBeingTraced()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v1

    const/4 v2, 0x6

    aput-object v1, v0, v2

    .line 242
    nop

    .line 249
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->gameGuardianMapsDetected()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v1

    const/4 v2, 0x7

    aput-object v1, v0, v2

    .line 242
    nop

    .line 250
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->gameGuardianFilesDetected()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v1

    const/16 v2, 0x8

    aput-object v1, v0, v2

    .line 242
    nop

    .line 251
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->memoryEditorDetected()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v1

    const/16 v2, 0x9

    aput-object v1, v0, v2

    .line 242
    nop

    .line 241
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    .line 252
    return-object v0
.end method

.method public final fridaMapsDetected()Lcom/antirea/runtime/ReaEnv$Finding;
    .registers 14

    .line 107
    const-string v0, "frida-gadget"

    const-string v1, "linjector"

    const-string v2, "frida-agent"

    filled-new-array {v2, v0, v1}, [Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    invoke-direct {p0, v0}, Lcom/antirea/runtime/ReaEnv;->readMapsHits(Ljava/util/List;)Ljava/util/List;

    move-result-object v0

    .line 108
    .local v0, "hits":Ljava/util/List;
    new-instance v1, Lcom/antirea/runtime/ReaEnv$Finding;

    .line 109
    nop

    .line 110
    move-object v2, v0

    check-cast v2, Ljava/util/Collection;

    invoke-interface {v2}, Ljava/util/Collection;->isEmpty()Z

    move-result v2

    .line 111
    xor-int/lit8 v2, v2, 0x1

    invoke-interface {v0}, Ljava/util/List;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_27

    const-string v3, "no frida strings in /proc/self/maps"

    goto :goto_4d

    .line 112
    :cond_27
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "frida strings in maps: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    move-object v4, v0

    check-cast v4, Ljava/lang/Iterable;

    const-string v5, ","

    check-cast v5, Ljava/lang/CharSequence;

    const/16 v11, 0x3e

    const/4 v12, 0x0

    const/4 v6, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    invoke-static/range {v4 .. v12}, Lkotlin/collections/CollectionsKt;->joinToString$default(Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 108
    :goto_4d
    const-string v4, "frida-maps"

    invoke-direct {v1, v4, v2, v3}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v1
.end method

.method public final fridaPortsDetected()Lcom/antirea/runtime/ReaEnv$Finding;
    .registers 16

    .line 123
    const-string v1, "frida-ports"

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    move-object v2, v0

    check-cast v2, Ljava/util/List;

    .line 124
    .local v2, "ports":Ljava/util/List;
    nop

    .line 125
    const/4 v3, 0x0

    :try_start_c
    const-string v0, "/proc/net/tcp"

    const-string v4, "/proc/net/tcp6"

    filled-new-array {v0, v4}, [Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :cond_1c
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    const/4 v5, 0x1

    if-eqz v4, :cond_ab

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    check-cast v4, Ljava/lang/String;

    .line 126
    .local v4, "path":Ljava/lang/String;
    new-instance v6, Ljava/io/File;

    invoke-direct {v6, v4}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 127
    .local v6, "file":Ljava/io/File;
    invoke-virtual {v6}, Ljava/io/File;->canRead()Z

    move-result v7

    if-eqz v7, :cond_1c

    .line 128
    const/4 v7, 0x0

    invoke-static {v6, v7, v5, v7}, Lkotlin/io/FilesKt;->readLines$default(Ljava/io/File;Ljava/nio/charset/Charset;ILjava/lang/Object;)Ljava/util/List;

    move-result-object v7

    invoke-interface {v7}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v7

    :cond_3d
    :goto_3d
    invoke-interface {v7}, Ljava/util/Iterator;->hasNext()Z

    move-result v8

    if-eqz v8, :cond_1c

    invoke-interface {v7}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v8

    check-cast v8, Ljava/lang/String;

    .line 129
    .local v8, "line":Ljava/lang/String;
    move-object v9, v8

    check-cast v9, Ljava/lang/CharSequence;

    invoke-static {v9}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v9

    check-cast v9, Ljava/lang/CharSequence;

    new-instance v10, Lkotlin/text/Regex;

    const-string v11, "\\s+"

    invoke-direct {v10, v11}, Lkotlin/text/Regex;-><init>(Ljava/lang/String;)V

    invoke-virtual {v10, v9, v3}, Lkotlin/text/Regex;->split(Ljava/lang/CharSequence;I)Ljava/util/List;

    move-result-object v9

    .line 130
    .local v9, "parts":Ljava/util/List;
    invoke-interface {v9}, Ljava/util/List;->size()I

    move-result v10

    const/4 v11, 0x4

    if-lt v10, v11, :cond_3d

    .line 131
    invoke-interface {v9, v5}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v10

    check-cast v10, Ljava/lang/String;

    .line 132
    .local v10, "local":Ljava/lang/String;
    const/4 v11, 0x3

    invoke-interface {v9, v11}, Ljava/util/List;->get(I)Ljava/lang/Object;

    move-result-object v11

    check-cast v11, Ljava/lang/String;

    .line 133
    .local v11, "state":Ljava/lang/String;
    const-string v12, "0A"

    invoke-static {v11, v12}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v12

    if-eqz v12, :cond_3d

    .line 134
    const-string v12, ":"

    const-string v13, ""

    invoke-static {v10, v12, v13}, Lkotlin/text/StringsKt;->substringAfter(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;

    move-result-object v12

    sget-object v13, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v12, v13}, Ljava/lang/String;->toUpperCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v12

    const-string v13, "toUpperCase(...)"

    invoke-static {v12, v13}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    .line 135
    .local v12, "hexPort":Ljava/lang/String;
    const-string v13, "699A"

    invoke-static {v12, v13}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v13

    if-eqz v13, :cond_9d

    const-string v13, "27042"

    invoke-interface {v2, v13}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 136
    :cond_9d
    const-string v13, "699B"

    invoke-static {v12, v13}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v13

    if-eqz v13, :cond_3d

    const-string v13, "27043"

    invoke-interface {v2, v13}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_aa
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_aa} :catch_f1

    goto :goto_3d

    .line 142
    .end local v4    # "path":Ljava/lang/String;
    .end local v6    # "file":Ljava/io/File;
    .end local v8    # "line":Ljava/lang/String;
    .end local v9    # "parts":Ljava/util/List;
    .end local v10    # "local":Ljava/lang/String;
    .end local v11    # "state":Ljava/lang/String;
    .end local v12    # "hexPort":Ljava/lang/String;
    :cond_ab
    new-instance v0, Lcom/antirea/runtime/ReaEnv$Finding;

    .line 143
    nop

    .line 144
    move-object v3, v2

    check-cast v3, Ljava/util/Collection;

    invoke-interface {v3}, Ljava/util/Collection;->isEmpty()Z

    move-result v3

    .line 145
    xor-int/2addr v3, v5

    invoke-interface {v2}, Ljava/util/List;->isEmpty()Z

    move-result v4

    if-eqz v4, :cond_bf

    const-string v4, "frida ports 27042/27043 not listening"

    goto :goto_ed

    .line 146
    :cond_bf
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "listening frida ports: "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    move-object v5, v2

    check-cast v5, Ljava/lang/Iterable;

    invoke-static {v5}, Lkotlin/collections/CollectionsKt;->distinct(Ljava/lang/Iterable;)Ljava/util/List;

    move-result-object v5

    move-object v6, v5

    check-cast v6, Ljava/lang/Iterable;

    const-string v5, ","

    move-object v7, v5

    check-cast v7, Ljava/lang/CharSequence;

    const/16 v13, 0x3e

    const/4 v14, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    const/4 v11, 0x0

    const/4 v12, 0x0

    invoke-static/range {v6 .. v14}, Lkotlin/collections/CollectionsKt;->joinToString$default(Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    .line 142
    :goto_ed
    invoke-direct {v0, v1, v3, v4}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v0

    .line 139
    :catch_f1
    move-exception v0

    .line 140
    .local v0, "e":Ljava/lang/Exception;
    new-instance v4, Lcom/antirea/runtime/ReaEnv$Finding;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "check failed: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-direct {v4, v1, v3, v5}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v4
.end method

.method public final gameGuardianFilesDetected()Lcom/antirea/runtime/ReaEnv$Finding;
    .registers 14

    .line 201
    nop

    .line 202
    :try_start_1
    sget-object v0, Lcom/antirea/runtime/ReaTrace;->INSTANCE:Lcom/antirea/runtime/ReaTrace;

    invoke-virtual {v0}, Lcom/antirea/runtime/ReaTrace;->gameGuardianFilesHits()Ljava/util/List;

    move-result-object v0
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_7} :catch_8

    goto :goto_e

    .line 203
    :catch_8
    move-exception v0

    .line 204
    .local v0, "e":Ljava/lang/Exception;
    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v1

    move-object v0, v1

    .line 201
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_e
    nop

    .line 206
    .local v0, "hits":Ljava/util/List;
    new-instance v1, Lcom/antirea/runtime/ReaEnv$Finding;

    .line 207
    nop

    .line 208
    move-object v2, v0

    check-cast v2, Ljava/util/Collection;

    invoke-interface {v2}, Ljava/util/Collection;->isEmpty()Z

    move-result v2

    .line 209
    xor-int/lit8 v2, v2, 0x1

    invoke-interface {v0}, Ljava/util/List;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_24

    const-string v3, "no gameguardian base data dirs present"

    goto :goto_4a

    .line 210
    :cond_24
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "gameguardian base data dirs: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    move-object v4, v0

    check-cast v4, Ljava/lang/Iterable;

    const-string v5, ","

    check-cast v5, Ljava/lang/CharSequence;

    const/16 v11, 0x3e

    const/4 v12, 0x0

    const/4 v6, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    invoke-static/range {v4 .. v12}, Lkotlin/collections/CollectionsKt;->joinToString$default(Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 206
    :goto_4a
    const-string v4, "gameguardian-files"

    invoke-direct {v1, v4, v2, v3}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v1
.end method

.method public final gameGuardianMapsDetected()Lcom/antirea/runtime/ReaEnv$Finding;
    .registers 14

    .line 186
    nop

    .line 187
    :try_start_1
    sget-object v0, Lcom/antirea/runtime/ReaTrace;->INSTANCE:Lcom/antirea/runtime/ReaTrace;

    invoke-virtual {v0}, Lcom/antirea/runtime/ReaTrace;->gameGuardianMapsHits()Ljava/util/List;

    move-result-object v0
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_7} :catch_8

    goto :goto_e

    .line 188
    :catch_8
    move-exception v0

    .line 189
    .local v0, "e":Ljava/lang/Exception;
    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v1

    move-object v0, v1

    .line 186
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_e
    nop

    .line 191
    .local v0, "hits":Ljava/util/List;
    new-instance v1, Lcom/antirea/runtime/ReaEnv$Finding;

    .line 192
    nop

    .line 193
    move-object v2, v0

    check-cast v2, Ljava/util/Collection;

    invoke-interface {v2}, Ljava/util/Collection;->isEmpty()Z

    move-result v2

    .line 194
    xor-int/lit8 v2, v2, 0x1

    invoke-interface {v0}, Ljava/util/List;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_24

    const-string v3, "no gameguardian markers in /proc/self/maps"

    goto :goto_4a

    .line 195
    :cond_24
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "gameguardian markers in maps: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    move-object v4, v0

    check-cast v4, Ljava/lang/Iterable;

    const-string v5, ","

    check-cast v5, Ljava/lang/CharSequence;

    const/16 v11, 0x3e

    const/4 v12, 0x0

    const/4 v6, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    invoke-static/range {v4 .. v12}, Lkotlin/collections/CollectionsKt;->joinToString$default(Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 191
    :goto_4a
    const-string v4, "gameguardian-maps"

    invoke-direct {v1, v4, v2, v3}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v1
.end method

.method public final hookLibsDetected()Lcom/antirea/runtime/ReaEnv$Finding;
    .registers 14

    .line 152
    const-string v0, "lsposed"

    const-string v1, "riru"

    const-string v2, "xposed"

    const-string v3, "substrate"

    const-string v4, "edxposed"

    filled-new-array {v2, v3, v4, v0, v1}, [Ljava/lang/String;

    move-result-object v0

    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    invoke-direct {p0, v0}, Lcom/antirea/runtime/ReaEnv;->readMapsHits(Ljava/util/List;)Ljava/util/List;

    move-result-object v0

    .line 153
    .local v0, "hits":Ljava/util/List;
    new-instance v1, Lcom/antirea/runtime/ReaEnv$Finding;

    .line 154
    nop

    .line 155
    move-object v2, v0

    check-cast v2, Ljava/util/Collection;

    invoke-interface {v2}, Ljava/util/Collection;->isEmpty()Z

    move-result v2

    .line 156
    xor-int/lit8 v2, v2, 0x1

    invoke-interface {v0}, Ljava/util/List;->isEmpty()Z

    move-result v3

    if-eqz v3, :cond_2b

    const-string v3, "no hook-framework libs in /proc/self/maps"

    goto :goto_51

    .line 157
    :cond_2b
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "hook libs in maps: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    move-object v4, v0

    check-cast v4, Ljava/lang/Iterable;

    const-string v5, ","

    check-cast v5, Ljava/lang/CharSequence;

    const/16 v11, 0x3e

    const/4 v12, 0x0

    const/4 v6, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    invoke-static/range {v4 .. v12}, Lkotlin/collections/CollectionsKt;->joinToString$default(Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 153
    :goto_51
    const-string v4, "hook-libs"

    invoke-direct {v1, v4, v2, v3}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v1
.end method

.method public final isBeingTraced()Lcom/antirea/runtime/ReaEnv$Finding;
    .registers 5

    .line 171
    nop

    .line 172
    :try_start_1
    sget-object v0, Lcom/antirea/runtime/ReaTrace;->INSTANCE:Lcom/antirea/runtime/ReaTrace;

    invoke-virtual {v0}, Lcom/antirea/runtime/ReaTrace;->isTraced()Z

    move-result v0
    :try_end_7
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_7} :catch_8

    goto :goto_b

    .line 173
    :catch_8
    move-exception v0

    .line 174
    .local v0, "e":Ljava/lang/Exception;
    const/4 v1, 0x0

    move v0, v1

    .line 171
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_b
    nop

    .line 176
    .local v0, "detected":Z
    new-instance v1, Lcom/antirea/runtime/ReaEnv$Finding;

    .line 177
    nop

    .line 178
    nop

    .line 179
    if-eqz v0, :cond_15

    const-string v2, "TracerPid != 0 or proc state \'t\' \u2014 a tracer is attached"

    goto :goto_17

    .line 180
    :cond_15
    const-string v2, "not traced (TracerPid 0, state not \'t\')"

    .line 176
    :goto_17
    const-string v3, "traced"

    invoke-direct {v1, v3, v0, v2}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v1
.end method

.method public final isDebuggerConnected()Lcom/antirea/runtime/ReaEnv$Finding;
    .registers 5

    .line 30
    nop

    .line 31
    const/4 v0, 0x0

    :try_start_2
    invoke-static {}, Landroid/os/Debug;->isDebuggerConnected()Z

    move-result v1

    if-nez v1, :cond_e

    invoke-static {}, Landroid/os/Debug;->waitingForDebugger()Z

    move-result v1
    :try_end_c
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_c} :catch_10

    if-eqz v1, :cond_12

    :cond_e
    const/4 v0, 0x1

    goto :goto_12

    .line 32
    :catch_10
    move-exception v1

    .line 33
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 30
    .end local v1    # "e":Ljava/lang/Exception;
    :cond_12
    :goto_12
    nop

    .line 35
    .local v0, "detected":Z
    new-instance v1, Lcom/antirea/runtime/ReaEnv$Finding;

    .line 36
    nop

    .line 37
    nop

    .line 38
    if-eqz v0, :cond_1c

    const-string v2, "android.os.Debug reports a debugger"

    goto :goto_1e

    :cond_1c
    const-string v2, "no debugger reported"

    .line 35
    :goto_1e
    const-string v3, "debugger"

    invoke-direct {v1, v3, v0, v2}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v1
.end method

.method public final isEmulator()Lcom/antirea/runtime/ReaEnv$Finding;
    .registers 19

    .line 44
    const-string v1, "emulator"

    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    move-object v2, v0

    check-cast v2, Ljava/util/List;

    .line 45
    .local v2, "markers":Ljava/util/List;
    nop

    .line 46
    :try_start_b
    sget-object v0, Landroid/os/Build;->FINGERPRINT:Ljava/lang/String;
    :try_end_d
    .catch Ljava/lang/Exception; {:try_start_b .. :try_end_d} :catch_115

    const-string v4, ""

    if-nez v0, :cond_12

    move-object v0, v4

    .line 47
    .local v0, "fingerprint":Ljava/lang/String;
    :cond_12
    :try_start_12
    sget-object v5, Landroid/os/Build;->MODEL:Ljava/lang/String;

    if-nez v5, :cond_17

    move-object v5, v4

    .line 48
    .local v5, "model":Ljava/lang/String;
    :cond_17
    sget-object v6, Landroid/os/Build;->HARDWARE:Ljava/lang/String;

    if-nez v6, :cond_1c

    move-object v6, v4

    .line 49
    .local v6, "hardware":Ljava/lang/String;
    :cond_1c
    sget-object v7, Landroid/os/Build;->PRODUCT:Ljava/lang/String;

    if-nez v7, :cond_21

    move-object v7, v4

    .line 50
    .local v7, "product":Ljava/lang/String;
    :cond_21
    sget-object v8, Landroid/os/Build;->BRAND:Ljava/lang/String;

    if-nez v8, :cond_26

    move-object v8, v4

    .line 51
    .local v8, "brand":Ljava/lang/String;
    :cond_26
    sget-object v9, Landroid/os/Build;->DEVICE:Ljava/lang/String;

    if-nez v9, :cond_2b

    goto :goto_2c

    :cond_2b
    move-object v4, v9

    .line 52
    .local v4, "device":Ljava/lang/String;
    :goto_2c
    new-instance v9, Ljava/lang/StringBuilder;

    invoke-direct {v9}, Ljava/lang/StringBuilder;-><init>()V

    invoke-virtual {v9, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    const/16 v10, 0x20

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v7}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v8}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v10}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v9

    invoke-virtual {v9}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v9

    sget-object v10, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {v9, v10}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v9

    const-string v10, "toLowerCase(...)"

    invoke-static {v9, v10}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    .line 55
    .local v9, "combined":Ljava/lang/String;
    const-string v10, "generic"

    const-string v11, "sdk"

    const-string v12, "emulator"

    const-string v13, "goldfish"

    const-string v14, "ranchu"

    .line 56
    const-string v15, "vbox86"

    .line 55
    nop

    .line 56
    const-string v16, "genymotion"

    .line 55
    nop

    .line 56
    const-string v17, "test-keys"

    filled-new-array/range {v10 .. v17}, [Ljava/lang/String;

    move-result-object v10

    .line 55
    nop

    .line 54
    invoke-static {v10}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v10

    .line 58
    .local v10, "known":Ljava/util/List;
    invoke-interface {v10}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v11

    :goto_8d
    invoke-interface {v11}, Ljava/util/Iterator;->hasNext()Z

    move-result v12

    const/4 v13, 0x0

    const/4 v14, 0x2

    if-eqz v12, :cond_b0

    invoke-interface {v11}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v12

    check-cast v12, Ljava/lang/String;

    .line 59
    .local v12, "m":Ljava/lang/String;
    move-object v15, v9

    check-cast v15, Ljava/lang/CharSequence;

    move-object v3, v12

    check-cast v3, Ljava/lang/CharSequence;

    move-object/from16 v17, v4

    const/4 v4, 0x0

    .end local v4    # "device":Ljava/lang/String;
    .local v17, "device":Ljava/lang/String;
    invoke-static {v15, v3, v4, v14, v13}, Lkotlin/text/StringsKt;->contains$default(Ljava/lang/CharSequence;Ljava/lang/CharSequence;ZILjava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_ad

    invoke-interface {v2, v12}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    :cond_ad
    move-object/from16 v4, v17

    goto :goto_8d

    .line 62
    .end local v12    # "m":Ljava/lang/String;
    .end local v17    # "device":Ljava/lang/String;
    .restart local v4    # "device":Ljava/lang/String;
    :cond_b0
    move-object/from16 v17, v4

    .end local v4    # "device":Ljava/lang/String;
    .restart local v17    # "device":Ljava/lang/String;
    const-string v3, "generic/"

    const/4 v4, 0x0

    invoke-static {v0, v3, v4, v14, v13}, Lkotlin/text/StringsKt;->startsWith$default(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_c9

    move-object v3, v0

    check-cast v3, Ljava/lang/CharSequence;

    const-string v4, "sdk_gphone"

    check-cast v4, Ljava/lang/CharSequence;

    const/4 v11, 0x0

    invoke-static {v3, v4, v11, v14, v13}, Lkotlin/text/StringsKt;->contains$default(Ljava/lang/CharSequence;Ljava/lang/CharSequence;ZILjava/lang/Object;)Z

    move-result v3

    if-eqz v3, :cond_d6

    .line 63
    :cond_c9
    const-string v3, "generic"

    invoke-interface {v2, v3}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_d6

    const-string v3, "generic-fingerprint"

    invoke-interface {v2, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_d6
    .catch Ljava/lang/Exception; {:try_start_12 .. :try_end_d6} :catch_115

    .line 68
    .end local v0    # "fingerprint":Ljava/lang/String;
    .end local v5    # "model":Ljava/lang/String;
    .end local v6    # "hardware":Ljava/lang/String;
    .end local v7    # "product":Ljava/lang/String;
    .end local v8    # "brand":Ljava/lang/String;
    .end local v9    # "combined":Ljava/lang/String;
    .end local v10    # "known":Ljava/util/List;
    .end local v17    # "device":Ljava/lang/String;
    :cond_d6
    new-instance v0, Lcom/antirea/runtime/ReaEnv$Finding;

    .line 69
    nop

    .line 70
    move-object v3, v2

    check-cast v3, Ljava/util/Collection;

    invoke-interface {v3}, Ljava/util/Collection;->isEmpty()Z

    move-result v3

    .line 71
    xor-int/lit8 v3, v3, 0x1

    invoke-interface {v2}, Ljava/util/List;->isEmpty()Z

    move-result v4

    if-eqz v4, :cond_eb

    const-string v4, "no emulator markers in Build fields"

    goto :goto_111

    .line 72
    :cond_eb
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "emulator markers: "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    move-object v5, v2

    check-cast v5, Ljava/lang/Iterable;

    const-string v6, ","

    check-cast v6, Ljava/lang/CharSequence;

    const/16 v12, 0x3e

    const/4 v13, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    const/4 v11, 0x0

    invoke-static/range {v5 .. v13}, Lkotlin/collections/CollectionsKt;->joinToString$default(Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    .line 68
    :goto_111
    invoke-direct {v0, v1, v3, v4}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v0

    .line 65
    :catch_115
    move-exception v0

    .line 66
    .local v0, "e":Ljava/lang/Exception;
    new-instance v3, Lcom/antirea/runtime/ReaEnv$Finding;

    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "check failed: "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    const/4 v11, 0x0

    invoke-direct {v3, v1, v11, v4}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v3
.end method

.method public final isRooted()Lcom/antirea/runtime/ReaEnv$Finding;
    .registers 15

    .line 82
    const-string v0, "test-keys"

    const-string v1, "root"

    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    check-cast v2, Ljava/util/List;

    .line 83
    .local v2, "hits":Ljava/util/List;
    nop

    .line 84
    const/4 v3, 0x0

    :try_start_d
    sget-object v4, Landroid/os/Build;->TAGS:Ljava/lang/String;

    if-nez v4, :cond_13

    const-string v4, ""

    :cond_13
    check-cast v4, Ljava/lang/CharSequence;

    move-object v5, v0

    check-cast v5, Ljava/lang/CharSequence;

    const/4 v6, 0x2

    const/4 v7, 0x0

    invoke-static {v4, v5, v3, v6, v7}, Lkotlin/text/StringsKt;->contains$default(Ljava/lang/CharSequence;Ljava/lang/CharSequence;ZILjava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_23

    invoke-interface {v2, v0}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 86
    :cond_23
    const-string v4, "/system/bin/su"

    const-string v5, "/system/xbin/su"

    const-string v6, "/sbin/su"

    .line 87
    const-string v7, "/system/sd/xbin/su"

    .line 86
    nop

    .line 87
    const-string v8, "/system/bin/failsafe/su"

    .line 86
    nop

    .line 88
    const-string v9, "/data/local/xbin/su"

    .line 86
    nop

    .line 88
    const-string v10, "/data/local/bin/su"

    .line 86
    nop

    .line 89
    const-string v11, "/data/local/su"

    .line 86
    nop

    .line 89
    const-string v12, "/su/bin/su"

    .line 86
    nop

    .line 89
    const-string v13, "/system/app/Superuser.apk"

    filled-new-array/range {v4 .. v13}, [Ljava/lang/String;

    move-result-object v0

    .line 86
    nop

    .line 85
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    .line 91
    .local v0, "suPaths":Ljava/util/List;
    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v4

    :cond_4a
    :goto_4a
    invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z

    move-result v5

    if-eqz v5, :cond_65

    invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v5

    check-cast v5, Ljava/lang/String;

    .line 92
    .local v5, "p":Ljava/lang/String;
    new-instance v6, Ljava/io/File;

    invoke-direct {v6, v5}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v6}, Ljava/io/File;->exists()Z

    move-result v6

    if-eqz v6, :cond_4a

    invoke-interface {v2, v5}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_64
    .catch Ljava/lang/Exception; {:try_start_d .. :try_end_64} :catch_a4

    goto :goto_4a

    .line 97
    .end local v0    # "suPaths":Ljava/util/List;
    .end local v5    # "p":Ljava/lang/String;
    :cond_65
    new-instance v0, Lcom/antirea/runtime/ReaEnv$Finding;

    .line 98
    nop

    .line 99
    move-object v3, v2

    check-cast v3, Ljava/util/Collection;

    invoke-interface {v3}, Ljava/util/Collection;->isEmpty()Z

    move-result v3

    .line 100
    xor-int/lit8 v3, v3, 0x1

    invoke-interface {v2}, Ljava/util/List;->isEmpty()Z

    move-result v4

    if-eqz v4, :cond_7a

    const-string v4, "no su binary or test-keys found"

    goto :goto_a0

    .line 101
    :cond_7a
    new-instance v4, Ljava/lang/StringBuilder;

    invoke-direct {v4}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "root indicators: "

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    move-object v5, v2

    check-cast v5, Ljava/lang/Iterable;

    const-string v6, ","

    check-cast v6, Ljava/lang/CharSequence;

    const/16 v12, 0x3e

    const/4 v13, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    const/4 v11, 0x0

    invoke-static/range {v5 .. v13}, Lkotlin/collections/CollectionsKt;->joinToString$default(Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v5

    invoke-virtual {v4, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v4

    .line 97
    :goto_a0
    invoke-direct {v0, v1, v3, v4}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v0

    .line 94
    :catch_a4
    move-exception v0

    .line 95
    .local v0, "e":Ljava/lang/Exception;
    new-instance v4, Lcom/antirea/runtime/ReaEnv$Finding;

    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "check failed: "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v6

    invoke-virtual {v6}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    invoke-direct {v4, v1, v3, v5}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v4
.end method

.method public final memoryEditorDetected()Lcom/antirea/runtime/ReaEnv$Finding;
    .registers 16

    .line 221
    const-string v1, "memory-editor"

    .line 222
    :try_start_2
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->isRooted()Lcom/antirea/runtime/ReaEnv$Finding;

    move-result-object v0

    invoke-virtual {v0}, Lcom/antirea/runtime/ReaEnv$Finding;->getDetected()Z

    move-result v0

    .line 223
    .local v0, "rooted":Z
    sget-object v2, Lcom/antirea/runtime/ReaTrace;->INSTANCE:Lcom/antirea/runtime/ReaTrace;

    invoke-virtual {v2}, Lcom/antirea/runtime/ReaTrace;->isTraced()Z

    move-result v2

    .line 224
    .local v2, "traced":Z
    sget-object v3, Lcom/antirea/runtime/ReaTrace;->INSTANCE:Lcom/antirea/runtime/ReaTrace;

    invoke-virtual {v3}, Lcom/antirea/runtime/ReaTrace;->gameGuardianMapsHits()Ljava/util/List;

    move-result-object v3

    .line 225
    .local v3, "maps":Ljava/util/List;
    sget-object v4, Lcom/antirea/runtime/ReaTrace;->INSTANCE:Lcom/antirea/runtime/ReaTrace;

    invoke-virtual {v4}, Lcom/antirea/runtime/ReaTrace;->gameGuardianFilesHits()Ljava/util/List;

    move-result-object v4

    .line 226
    .local v4, "files":Ljava/util/List;
    sget-object v5, Lcom/antirea/runtime/ReaTrace;->INSTANCE:Lcom/antirea/runtime/ReaTrace;

    invoke-virtual {v5, v0, v2, v3, v4}, Lcom/antirea/runtime/ReaTrace;->memoryEditorRisk(ZZLjava/util/List;Ljava/util/List;)Lkotlin/Pair;

    move-result-object v5
    :try_end_22
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_22} :catch_74

    .line 221
    .end local v0    # "rooted":Z
    .end local v2    # "traced":Z
    .end local v3    # "maps":Ljava/util/List;
    .end local v4    # "files":Ljava/util/List;
    invoke-virtual {v5}, Lkotlin/Pair;->component1()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;

    .local v0, "level":Ljava/lang/String;
    invoke-virtual {v5}, Lkotlin/Pair;->component2()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/util/List;

    .line 230
    .local v2, "signals":Ljava/util/List;
    new-instance v3, Lcom/antirea/runtime/ReaEnv$Finding;

    .line 231
    nop

    .line 232
    const-string v4, "high"

    invoke-static {v0, v4}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v4

    .line 233
    invoke-interface {v2}, Ljava/util/List;->isEmpty()Z

    move-result v5

    if-eqz v5, :cond_40

    const-string v5, "no memory-editor signals"

    goto :goto_70

    .line 234
    :cond_40
    new-instance v5, Ljava/lang/StringBuilder;

    invoke-direct {v5}, Ljava/lang/StringBuilder;-><init>()V

    const-string v6, "memory-editor risk="

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    const-string v6, ": "

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    move-object v6, v2

    check-cast v6, Ljava/lang/Iterable;

    const-string v7, "; "

    check-cast v7, Ljava/lang/CharSequence;

    const/16 v13, 0x3e

    const/4 v14, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    const/4 v11, 0x0

    const/4 v12, 0x0

    invoke-static/range {v6 .. v14}, Lkotlin/collections/CollectionsKt;->joinToString$default(Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v6

    invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v5

    invoke-virtual {v5}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v5

    .line 230
    :goto_70
    invoke-direct {v3, v1, v4, v5}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v3

    .line 227
    .end local v0    # "level":Ljava/lang/String;
    .end local v2    # "signals":Ljava/util/List;
    :catch_74
    move-exception v0

    .line 228
    .local v0, "e":Ljava/lang/Exception;
    new-instance v2, Lcom/antirea/runtime/ReaEnv$Finding;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "check failed: "

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v0}, Ljava/lang/Object;->getClass()Ljava/lang/Class;

    move-result-object v4

    invoke-virtual {v4}, Ljava/lang/Class;->getSimpleName()Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    const/4 v4, 0x0

    invoke-direct {v2, v1, v4, v3}, Lcom/antirea/runtime/ReaEnv$Finding;-><init>(Ljava/lang/String;ZLjava/lang/String;)V

    return-object v2
.end method

.method public final suspiciousCount()I
    .registers 8

    .line 255
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaEnv;->checkAll()Ljava/util/List;

    move-result-object v0

    check-cast v0, Ljava/lang/Iterable;

    .local v0, "$this$count$iv":Ljava/lang/Iterable;
    const/4 v1, 0x0

    .line 276
    .local v1, "$i$f$count":I
    instance-of v2, v0, Ljava/util/Collection;

    if-eqz v2, :cond_16

    move-object v2, v0

    check-cast v2, Ljava/util/Collection;

    invoke-interface {v2}, Ljava/util/Collection;->isEmpty()Z

    move-result v2

    if-eqz v2, :cond_16

    const/4 v2, 0x0

    goto :goto_38

    .line 277
    :cond_16
    const/4 v2, 0x0

    .line 278
    .local v2, "count$iv":I
    invoke-interface {v0}, Ljava/lang/Iterable;->iterator()Ljava/util/Iterator;

    move-result-object v3

    :cond_1b
    :goto_1b
    invoke-interface {v3}, Ljava/util/Iterator;->hasNext()Z

    move-result v4

    if-eqz v4, :cond_37

    invoke-interface {v3}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v4

    .local v4, "element$iv":Ljava/lang/Object;
    move-object v5, v4

    check-cast v5, Lcom/antirea/runtime/ReaEnv$Finding;

    .local v5, "it":Lcom/antirea/runtime/ReaEnv$Finding;
    const/4 v6, 0x0

    .line 255
    .local v6, "$i$a$-count-ReaEnv$suspiciousCount$1":I
    invoke-virtual {v5}, Lcom/antirea/runtime/ReaEnv$Finding;->getDetected()Z

    move-result v5

    .line 278
    .end local v5    # "it":Lcom/antirea/runtime/ReaEnv$Finding;
    .end local v6    # "$i$a$-count-ReaEnv$suspiciousCount$1":I
    if-eqz v5, :cond_1b

    add-int/lit8 v2, v2, 0x1

    if-gez v2, :cond_1b

    invoke-static {}, Lkotlin/collections/CollectionsKt;->throwCountOverflow()V

    goto :goto_1b

    .line 279
    .end local v4    # "element$iv":Ljava/lang/Object;
    :cond_37
    nop

    .line 255
    .end local v0    # "$this$count$iv":Ljava/lang/Iterable;
    .end local v1    # "$i$f$count":I
    .end local v2    # "count$iv":I
    :goto_38
    return v2
.end method
