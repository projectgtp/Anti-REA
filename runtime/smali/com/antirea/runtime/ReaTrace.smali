.class public final Lcom/antirea/runtime/ReaTrace;
.super Ljava/lang/Object;
.source "ReaTrace.kt"


# annotations
.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000@\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010 \n\u0002\u0010\u000e\n\u0002\u0008\u0005\n\u0002\u0010\u0008\n\u0002\u0008\u0003\n\u0002\u0010\u000c\n\u0002\u0008\u0003\n\u0002\u0010\u000b\n\u0002\u0008\u0006\n\u0002\u0018\u0002\n\u0002\u0008\u0008\n\u0002\u0018\u0002\n\u0002\u0008\u0004\u0008\u00c6\u0002\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u0015\u0010\u000b\u001a\u0004\u0018\u00010\u000c2\u0006\u0010\r\u001a\u00020\u0006\u00a2\u0006\u0002\u0010\u000eJ\u0015\u0010\u000f\u001a\u0004\u0018\u00010\u00102\u0006\u0010\u0011\u001a\u00020\u0006\u00a2\u0006\u0002\u0010\u0012J\u001a\u0010\u0013\u001a\u00020\u00142\u0008\u0010\r\u001a\u0004\u0018\u00010\u00062\u0008\u0010\u0011\u001a\u0004\u0018\u00010\u0006J$\u0010\u0015\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u00052\u0006\u0010\u0016\u001a\u00020\u00062\u000e\u0008\u0002\u0010\u0017\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005J.\u0010\u0018\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u00052\u000c\u0010\u0019\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u00052\u0012\u0010\u001a\u001a\u000e\u0012\u0004\u0012\u00020\u0006\u0012\u0004\u0012\u00020\u00140\u001bJ\u0012\u0010\u001c\u001a\u0004\u0018\u00010\u00062\u0006\u0010\u001d\u001a\u00020\u0006H\u0002J\r\u0010\u001e\u001a\u0004\u0018\u00010\u000c\u00a2\u0006\u0002\u0010\u001fJ\u0006\u0010 \u001a\u00020\u0014J\u000c\u0010!\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005J\u000c\u0010\"\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005JD\u0010#\u001a\u0014\u0012\u0004\u0012\u00020\u0006\u0012\n\u0012\u0008\u0012\u0004\u0012\u00020\u00060\u00050$2\u0006\u0010%\u001a\u00020\u00142\u0006\u0010&\u001a\u00020\u00142\u000c\u0010\'\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u00052\u000c\u0010(\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005R\u0017\u0010\u0004\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0007\u0010\u0008R\u0017\u0010\t\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\n\u0010\u0008"
    }
    d2 = {
        "Lcom/antirea/runtime/ReaTrace;",
        "",
        "<init>",
        "()V",
        "GG_MAPS_MARKERS",
        "",
        "",
        "getGG_MAPS_MARKERS",
        "()Ljava/util/List;",
        "GG_DATA_DIRS",
        "getGG_DATA_DIRS",
        "parseTracerPid",
        "",
        "statusContent",
        "(Ljava/lang/String;)Ljava/lang/Integer;",
        "parseProcStatState",
        "",
        "statContent",
        "(Ljava/lang/String;)Ljava/lang/Character;",
        "isBeingTraced",
        "",
        "scanMapsForMarkers",
        "mapsContent",
        "markers",
        "findExistingDirs",
        "dirs",
        "exists",
        "Lkotlin/Function1;",
        "readFileOrNull",
        "path",
        "readTracerPid",
        "()Ljava/lang/Integer;",
        "isTraced",
        "gameGuardianMapsHits",
        "gameGuardianFilesHits",
        "memoryEditorRisk",
        "Lkotlin/Pair;",
        "rooted",
        "traced",
        "mapsHits",
        "filesHits"
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
.field private static final GG_DATA_DIRS:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field private static final GG_MAPS_MARKERS:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field

.field public static final INSTANCE:Lcom/antirea/runtime/ReaTrace;


# direct methods
.method public static synthetic $r8$lambda$hhAgvvrWJokVHJknDYjv8S-ImYg(Ljava/lang/String;)Z
    .registers 1

    invoke-static {p0}, Lcom/antirea/runtime/ReaTrace;->gameGuardianFilesHits$lambda$0(Ljava/lang/String;)Z

    move-result p0

    return p0
.end method

.method static constructor <clinit>()V
    .registers 4

    new-instance v0, Lcom/antirea/runtime/ReaTrace;

    invoke-direct {v0}, Lcom/antirea/runtime/ReaTrace;-><init>()V

    sput-object v0, Lcom/antirea/runtime/ReaTrace;->INSTANCE:Lcom/antirea/runtime/ReaTrace;

    .line 69
    nop

    .line 70
    nop

    .line 71
    nop

    .line 70
    nop

    .line 72
    nop

    .line 70
    nop

    .line 73
    const-string v0, "catch_.me_.if_.you_.can_"

    const-string v1, "gameguardian"

    const-string v2, "libgg"

    const-string v3, "bulldog-daemon"

    filled-new-array {v1, v2, v3, v0}, [Ljava/lang/String;

    move-result-object v0

    .line 70
    nop

    .line 69
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    sput-object v0, Lcom/antirea/runtime/ReaTrace;->GG_MAPS_MARKERS:Ljava/util/List;

    .line 93
    nop

    .line 94
    nop

    .line 95
    const-string v0, "/storage/emulated/0/Android/data/com.catch_.me_.if_.you_.can_"

    const-string v1, "/data/data/com.catch_.me_.if_.you_.can_"

    filled-new-array {v1, v0}, [Ljava/lang/String;

    move-result-object v0

    .line 94
    nop

    .line 93
    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->listOf([Ljava/lang/Object;)Ljava/util/List;

    move-result-object v0

    sput-object v0, Lcom/antirea/runtime/ReaTrace;->GG_DATA_DIRS:Ljava/util/List;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 63
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private static final gameGuardianFilesHits$lambda$0(Ljava/lang/String;)Z
    .registers 3
    .param p0, "p"    # Ljava/lang/String;

    const-string v0, "p"

    invoke-static {p0, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 212
    nop

    .line 213
    :try_start_6
    new-instance v0, Ljava/io/File;

    invoke-direct {v0, p0}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    invoke-virtual {v0}, Ljava/io/File;->exists()Z

    move-result v0
    :try_end_f
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_f} :catch_10

    goto :goto_13

    .line 214
    :catch_10
    move-exception v0

    .line 215
    .local v0, "e":Ljava/lang/Exception;
    const/4 v1, 0x0

    move v0, v1

    .line 216
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_13
    return v0
.end method

.method private final readFileOrNull(Ljava/lang/String;)Ljava/lang/String;
    .registers 5
    .param p1, "path"    # Ljava/lang/String;

    .line 176
    nop

    .line 177
    const/4 v0, 0x0

    :try_start_2
    new-instance v1, Ljava/io/File;

    invoke-direct {v1, p1}, Ljava/io/File;-><init>(Ljava/lang/String;)V

    .line 178
    .local v1, "f":Ljava/io/File;
    invoke-virtual {v1}, Ljava/io/File;->canRead()Z

    move-result v2

    if-nez v2, :cond_e

    goto :goto_16

    :cond_e
    const/4 v2, 0x1

    invoke-static {v1, v0, v2, v0}, Lkotlin/io/FilesKt;->readText$default(Ljava/io/File;Ljava/nio/charset/Charset;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v0
    :try_end_13
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_13} :catch_14

    goto :goto_16

    .line 179
    .end local v1    # "f":Ljava/io/File;
    :catch_14
    move-exception v1

    .line 180
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 176
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_16
    return-object v0
.end method

.method public static synthetic scanMapsForMarkers$default(Lcom/antirea/runtime/ReaTrace;Ljava/lang/String;Ljava/util/List;ILjava/lang/Object;)Ljava/util/List;
    .registers 5

    .line 150
    and-int/lit8 p3, p3, 0x2

    if-eqz p3, :cond_6

    sget-object p2, Lcom/antirea/runtime/ReaTrace;->GG_MAPS_MARKERS:Ljava/util/List;

    :cond_6
    invoke-virtual {p0, p1, p2}, Lcom/antirea/runtime/ReaTrace;->scanMapsForMarkers(Ljava/lang/String;Ljava/util/List;)Ljava/util/List;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final findExistingDirs(Ljava/util/List;Lkotlin/jvm/functions/Function1;)Ljava/util/List;
    .registers 7
    .param p1, "dirs"    # Ljava/util/List;
    .param p2, "exists"    # Lkotlin/jvm/functions/Function1;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;",
            "Lkotlin/jvm/functions/Function1<",
            "-",
            "Ljava/lang/String;",
            "Ljava/lang/Boolean;",
            ">;)",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    const-string v0, "dirs"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "exists"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 162
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast v0, Ljava/util/List;

    .line 163
    .local v0, "out":Ljava/util/List;
    invoke-interface {p1}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v1

    :cond_15
    :goto_15
    invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z

    move-result v2

    if-eqz v2, :cond_34

    invoke-interface {v1}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v2

    check-cast v2, Ljava/lang/String;

    .line 164
    .local v2, "d":Ljava/lang/String;
    nop

    .line 165
    :try_start_22
    invoke-interface {p2, v2}, Lkotlin/jvm/functions/Function1;->invoke(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/Boolean;

    invoke-virtual {v3}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v3

    if-eqz v3, :cond_15

    invoke-interface {v0, v2}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_31
    .catch Ljava/lang/Exception; {:try_start_22 .. :try_end_31} :catch_32

    goto :goto_15

    .line 166
    :catch_32
    move-exception v3

    .line 167
    .local v3, "e":Ljava/lang/Exception;
    goto :goto_15

    .line 170
    .end local v2    # "d":Ljava/lang/String;
    .end local v3    # "e":Ljava/lang/Exception;
    :cond_34
    return-object v0
.end method

.method public final gameGuardianFilesHits()Ljava/util/List;
    .registers 3
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 210
    nop

    .line 211
    :try_start_1
    sget-object v0, Lcom/antirea/runtime/ReaTrace;->GG_DATA_DIRS:Ljava/util/List;

    new-instance v1, Lcom/antirea/runtime/ReaTrace$$ExternalSyntheticLambda0;

    invoke-direct {v1}, Lcom/antirea/runtime/ReaTrace$$ExternalSyntheticLambda0;-><init>()V

    invoke-virtual {p0, v0, v1}, Lcom/antirea/runtime/ReaTrace;->findExistingDirs(Ljava/util/List;Lkotlin/jvm/functions/Function1;)Ljava/util/List;

    move-result-object v0
    :try_end_c
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_c} :catch_d

    goto :goto_13

    .line 218
    :catch_d
    move-exception v0

    .line 219
    .local v0, "e":Ljava/lang/Exception;
    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v1

    move-object v0, v1

    .line 220
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_13
    return-object v0
.end method

.method public final gameGuardianMapsHits()Ljava/util/List;
    .registers 4
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 202
    nop

    .line 203
    :try_start_1
    const-string v0, "/proc/self/maps"

    invoke-direct {p0, v0}, Lcom/antirea/runtime/ReaTrace;->readFileOrNull(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    if-nez v0, :cond_e

    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v0

    return-object v0

    .line 204
    .local v0, "maps":Ljava/lang/String;
    :cond_e
    const/4 v1, 0x2

    const/4 v2, 0x0

    invoke-static {p0, v0, v2, v1, v2}, Lcom/antirea/runtime/ReaTrace;->scanMapsForMarkers$default(Lcom/antirea/runtime/ReaTrace;Ljava/lang/String;Ljava/util/List;ILjava/lang/Object;)Ljava/util/List;

    move-result-object v1
    :try_end_14
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_14} :catch_15

    .end local v0    # "maps":Ljava/lang/String;
    goto :goto_1a

    .line 205
    :catch_15
    move-exception v0

    .line 206
    .local v0, "e":Ljava/lang/Exception;
    invoke-static {}, Lkotlin/collections/CollectionsKt;->emptyList()Ljava/util/List;

    move-result-object v1

    .line 207
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_1a
    return-object v1
.end method

.method public final getGG_DATA_DIRS()Ljava/util/List;
    .registers 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 93
    sget-object v0, Lcom/antirea/runtime/ReaTrace;->GG_DATA_DIRS:Ljava/util/List;

    return-object v0
.end method

.method public final getGG_MAPS_MARKERS()Ljava/util/List;
    .registers 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    .line 69
    sget-object v0, Lcom/antirea/runtime/ReaTrace;->GG_MAPS_MARKERS:Ljava/util/List;

    return-object v0
.end method

.method public final isBeingTraced(Ljava/lang/String;Ljava/lang/String;)Z
    .registers 8
    .param p1, "statusContent"    # Ljava/lang/String;
    .param p2, "statContent"    # Ljava/lang/String;

    .line 134
    nop

    .line 135
    const/4 v0, 0x0

    if-nez p1, :cond_6

    move-object v1, v0

    goto :goto_d

    :cond_6
    :try_start_6
    invoke-virtual {p0, p1}, Lcom/antirea/runtime/ReaTrace;->parseTracerPid(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v1
    :try_end_a
    .catch Ljava/lang/Exception; {:try_start_6 .. :try_end_a} :catch_b

    goto :goto_d

    .line 136
    :catch_b
    move-exception v1

    .line 137
    .local v1, "e":Ljava/lang/Exception;
    move-object v1, v0

    .line 134
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_d
    nop

    .line 139
    .local v1, "tracerPid":Ljava/lang/Integer;
    const/4 v2, 0x1

    if-eqz v1, :cond_18

    invoke-virtual {v1}, Ljava/lang/Integer;->intValue()I

    move-result v3

    if-eqz v3, :cond_18

    return v2

    .line 140
    :cond_18
    nop

    .line 141
    if-nez p2, :cond_1c

    goto :goto_23

    :cond_1c
    :try_start_1c
    invoke-virtual {p0, p2}, Lcom/antirea/runtime/ReaTrace;->parseProcStatState(Ljava/lang/String;)Ljava/lang/Character;

    move-result-object v0
    :try_end_20
    .catch Ljava/lang/Exception; {:try_start_1c .. :try_end_20} :catch_21

    goto :goto_23

    .line 142
    :catch_21
    move-exception v3

    .line 143
    .local v3, "e":Ljava/lang/Exception;
    nop

    .line 140
    .end local v3    # "e":Ljava/lang/Exception;
    :goto_23
    nop

    .line 145
    .local v0, "state":Ljava/lang/Character;
    if-nez v0, :cond_27

    goto :goto_30

    :cond_27
    invoke-virtual {v0}, Ljava/lang/Character;->charValue()C

    move-result v3

    const/16 v4, 0x74

    if-ne v3, v4, :cond_30

    goto :goto_31

    :cond_30
    :goto_30
    const/4 v2, 0x0

    :goto_31
    return v2
.end method

.method public final isTraced()Z
    .registers 3

    .line 195
    nop

    .line 196
    :try_start_1
    const-string v0, "/proc/self/status"

    invoke-direct {p0, v0}, Lcom/antirea/runtime/ReaTrace;->readFileOrNull(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v0

    const-string v1, "/proc/self/stat"

    invoke-direct {p0, v1}, Lcom/antirea/runtime/ReaTrace;->readFileOrNull(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    invoke-virtual {p0, v0, v1}, Lcom/antirea/runtime/ReaTrace;->isBeingTraced(Ljava/lang/String;Ljava/lang/String;)Z

    move-result v0
    :try_end_11
    .catch Ljava/lang/Exception; {:try_start_1 .. :try_end_11} :catch_12

    goto :goto_15

    .line 197
    :catch_12
    move-exception v0

    .line 198
    .local v0, "e":Ljava/lang/Exception;
    const/4 v1, 0x0

    move v0, v1

    .line 199
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_15
    return v0
.end method

.method public final memoryEditorRisk(ZZLjava/util/List;Ljava/util/List;)Lkotlin/Pair;
    .registers 19
    .param p1, "rooted"    # Z
    .param p2, "traced"    # Z
    .param p3, "mapsHits"    # Ljava/util/List;
    .param p4, "filesHits"    # Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(ZZ",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;)",
            "Lkotlin/Pair<",
            "Ljava/lang/String;",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;>;"
        }
    .end annotation

    move-object/from16 v0, p3

    move-object/from16 v1, p4

    const-string v2, "mapsHits"

    invoke-static {v0, v2}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v2, "filesHits"

    invoke-static {v1, v2}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 243
    new-instance v2, Ljava/util/ArrayList;

    invoke-direct {v2}, Ljava/util/ArrayList;-><init>()V

    check-cast v2, Ljava/util/List;

    .line 244
    .local v2, "signals":Ljava/util/List;
    if-eqz p2, :cond_21

    if-eqz p1, :cond_1c

    const-string v3, "root+traced"

    goto :goto_1e

    :cond_1c
    const-string v3, "traced"

    :goto_1e
    invoke-interface {v2, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 245
    :cond_21
    move-object v3, v0

    check-cast v3, Ljava/util/Collection;

    invoke-interface {v3}, Ljava/util/Collection;->isEmpty()Z

    move-result v3

    const-string v4, ","

    if-nez v3, :cond_7c

    .line 246
    if-eqz p1, :cond_54

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "root+maps:"

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    move-object v5, v0

    check-cast v5, Ljava/lang/Iterable;

    move-object v6, v4

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

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    goto :goto_79

    .line 247
    :cond_54
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "maps:"

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    move-object v5, v0

    check-cast v5, Ljava/lang/Iterable;

    move-object v6, v4

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

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 246
    :goto_79
    invoke-interface {v2, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 249
    :cond_7c
    move-object v3, v1

    check-cast v3, Ljava/util/Collection;

    invoke-interface {v3}, Ljava/util/Collection;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_d5

    .line 250
    if-eqz p1, :cond_ad

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "root+files:"

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    move-object v5, v1

    check-cast v5, Ljava/lang/Iterable;

    move-object v6, v4

    check-cast v6, Ljava/lang/CharSequence;

    const/16 v12, 0x3e

    const/4 v13, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    const/4 v11, 0x0

    invoke-static/range {v5 .. v13}, Lkotlin/collections/CollectionsKt;->joinToString$default(Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    goto :goto_d2

    .line 251
    :cond_ad
    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v5, "files:"

    invoke-virtual {v3, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    move-object v5, v1

    check-cast v5, Ljava/lang/Iterable;

    move-object v6, v4

    check-cast v6, Ljava/lang/CharSequence;

    const/16 v12, 0x3e

    const/4 v13, 0x0

    const/4 v7, 0x0

    const/4 v8, 0x0

    const/4 v9, 0x0

    const/4 v10, 0x0

    const/4 v11, 0x0

    invoke-static/range {v5 .. v13}, Lkotlin/collections/CollectionsKt;->joinToString$default(Ljava/lang/Iterable;Ljava/lang/CharSequence;Ljava/lang/CharSequence;Ljava/lang/CharSequence;ILjava/lang/CharSequence;Lkotlin/jvm/functions/Function1;ILjava/lang/Object;)Ljava/lang/String;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    .line 250
    :goto_d2
    invoke-interface {v2, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    .line 253
    :cond_d5
    move-object v3, v2

    check-cast v3, Ljava/util/Collection;

    invoke-interface {v3}, Ljava/util/Collection;->isEmpty()Z

    move-result v3

    if-nez v3, :cond_e1

    const-string v3, "high"

    goto :goto_e3

    :cond_e1
    const-string v3, "none"

    .line 254
    .local v3, "level":Ljava/lang/String;
    :goto_e3
    invoke-static {v3, v2}, Lkotlin/TuplesKt;->to(Ljava/lang/Object;Ljava/lang/Object;)Lkotlin/Pair;

    move-result-object v4

    return-object v4
.end method

.method public final parseProcStatState(Ljava/lang/String;)Ljava/lang/Character;
    .registers 9
    .param p1, "statContent"    # Ljava/lang/String;

    const-string v0, "statContent"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 123
    move-object v1, p1

    check-cast v1, Ljava/lang/CharSequence;

    const/4 v5, 0x6

    const/4 v6, 0x0

    const/16 v2, 0x29

    const/4 v3, 0x0

    const/4 v4, 0x0

    invoke-static/range {v1 .. v6}, Lkotlin/text/StringsKt;->lastIndexOf$default(Ljava/lang/CharSequence;CIZILjava/lang/Object;)I

    move-result v0

    .line 124
    .local v0, "close":I
    const/4 v1, 0x0

    if-gez v0, :cond_16

    return-object v1

    .line 125
    :cond_16
    add-int/lit8 v2, v0, 0x1

    invoke-virtual {p1, v2}, Ljava/lang/String;->substring(I)Ljava/lang/String;

    move-result-object v2

    const-string v3, "substring(...)"

    invoke-static {v2, v3}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    check-cast v2, Ljava/lang/CharSequence;

    invoke-static {v2}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v2

    .line 126
    .local v2, "rest":Ljava/lang/String;
    move-object v3, v2

    check-cast v3, Ljava/lang/CharSequence;

    invoke-interface {v3}, Ljava/lang/CharSequence;->length()I

    move-result v3

    const/4 v4, 0x0

    if-nez v3, :cond_37

    const/4 v3, 0x1

    goto :goto_38

    :cond_37
    move v3, v4

    :goto_38
    if-eqz v3, :cond_3b

    return-object v1

    .line 127
    :cond_3b
    invoke-virtual {v2, v4}, Ljava/lang/String;->charAt(I)C

    move-result v1

    invoke-static {v1}, Ljava/lang/Character;->valueOf(C)Ljava/lang/Character;

    move-result-object v1

    return-object v1
.end method

.method public final parseTracerPid(Ljava/lang/String;)Ljava/lang/Integer;
    .registers 9
    .param p1, "statusContent"    # Ljava/lang/String;

    const-string v0, "statusContent"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 106
    move-object v0, p1

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->lines(Ljava/lang/CharSequence;)Ljava/util/List;

    move-result-object v0

    invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v0

    :cond_10
    invoke-interface {v0}, Ljava/util/Iterator;->hasNext()Z

    move-result v1

    const/4 v2, 0x0

    if-eqz v1, :cond_47

    invoke-interface {v0}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/String;

    .line 107
    .local v1, "rawLine":Ljava/lang/String;
    move-object v3, v1

    check-cast v3, Ljava/lang/CharSequence;

    invoke-static {v3}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v3

    .line 108
    .local v3, "line":Ljava/lang/String;
    const/4 v4, 0x0

    const/4 v5, 0x2

    const-string v6, "TracerPid:"

    invoke-static {v3, v6, v4, v5, v2}, Lkotlin/text/StringsKt;->startsWith$default(Ljava/lang/String;Ljava/lang/String;ZILjava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_10

    .line 109
    check-cast v6, Ljava/lang/CharSequence;

    invoke-static {v3, v6}, Lkotlin/text/StringsKt;->removePrefix(Ljava/lang/String;Ljava/lang/CharSequence;)Ljava/lang/String;

    move-result-object v0

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->trim(Ljava/lang/CharSequence;)Ljava/lang/CharSequence;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v0

    .line 110
    .local v0, "value":Ljava/lang/String;
    invoke-static {v0}, Lkotlin/text/StringsKt;->toIntOrNull(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v2

    return-object v2

    .line 112
    .end local v0    # "value":Ljava/lang/String;
    .end local v1    # "rawLine":Ljava/lang/String;
    .end local v3    # "line":Ljava/lang/String;
    :cond_47
    return-object v2
.end method

.method public final readTracerPid()Ljava/lang/Integer;
    .registers 3

    .line 186
    nop

    .line 187
    const/4 v0, 0x0

    :try_start_2
    const-string v1, "/proc/self/status"

    invoke-direct {p0, v1}, Lcom/antirea/runtime/ReaTrace;->readFileOrNull(Ljava/lang/String;)Ljava/lang/String;

    move-result-object v1

    if-nez v1, :cond_b

    return-object v0

    .line 188
    .local v1, "content":Ljava/lang/String;
    :cond_b
    invoke-virtual {p0, v1}, Lcom/antirea/runtime/ReaTrace;->parseTracerPid(Ljava/lang/String;)Ljava/lang/Integer;

    move-result-object v0
    :try_end_f
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_f} :catch_10

    .end local v1    # "content":Ljava/lang/String;
    goto :goto_12

    .line 189
    :catch_10
    move-exception v1

    .line 190
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 186
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_12
    return-object v0
.end method

.method public final scanMapsForMarkers(Ljava/lang/String;Ljava/util/List;)Ljava/util/List;
    .registers 12
    .param p1, "mapsContent"    # Ljava/lang/String;
    .param p2, "markers"    # Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Ljava/lang/String;",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;)",
            "Ljava/util/List<",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation

    const-string v0, "mapsContent"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "markers"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 151
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast v0, Ljava/util/List;

    .line 152
    .local v0, "hits":Ljava/util/List;
    sget-object v1, Ljava/util/Locale;->ROOT:Ljava/util/Locale;

    invoke-virtual {p1, v1}, Ljava/lang/String;->toLowerCase(Ljava/util/Locale;)Ljava/lang/String;

    move-result-object v1

    const-string v2, "toLowerCase(...)"

    invoke-static {v1, v2}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    .line 153
    .local v1, "lower":Ljava/lang/String;
    invoke-interface {p2}, Ljava/util/List;->iterator()Ljava/util/Iterator;

    move-result-object v2

    :cond_20
    :goto_20
    invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

    move-result v3

    if-eqz v3, :cond_45

    invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v3

    check-cast v3, Ljava/lang/String;

    .line 154
    .local v3, "m":Ljava/lang/String;
    move-object v4, v1

    check-cast v4, Ljava/lang/CharSequence;

    move-object v5, v3

    check-cast v5, Ljava/lang/CharSequence;

    const/4 v6, 0x2

    const/4 v7, 0x0

    const/4 v8, 0x0

    invoke-static {v4, v5, v8, v6, v7}, Lkotlin/text/StringsKt;->contains$default(Ljava/lang/CharSequence;Ljava/lang/CharSequence;ZILjava/lang/Object;)Z

    move-result v4

    if-eqz v4, :cond_20

    invoke-interface {v0, v3}, Ljava/util/List;->contains(Ljava/lang/Object;)Z

    move-result v4

    if-nez v4, :cond_20

    invoke-interface {v0, v3}, Ljava/util/List;->add(Ljava/lang/Object;)Z

    goto :goto_20

    .line 156
    .end local v3    # "m":Ljava/lang/String;
    :cond_45
    return-object v0
.end method
