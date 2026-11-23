.class public final Lcom/appcore/runtime/Tripwire;
.super Ljava/lang/Object;
.source "ReaTraps.kt"


# annotations
.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00006\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0010\u0002\n\u0002\u0008\u0003\n\u0002\u0010%\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010!\n\u0002\u0008\u0005\n\u0002\u0010\u0008\n\u0002\u0010 \n\u0000\u0018\u00002\u00020\u0001B\u001d\u0012\u0014\u0008\u0002\u0010\u0002\u001a\u000e\u0012\u0004\u0012\u00020\u0004\u0012\u0004\u0012\u00020\u00050\u0003\u00a2\u0006\u0004\u0008\u0006\u0010\u0007J\u0016\u0010\r\u001a\u00020\u00052\u0006\u0010\u000e\u001a\u00020\n2\u0006\u0010\u000f\u001a\u00020\nJ\u0010\u0010\u0010\u001a\u0004\u0018\u00010\n2\u0006\u0010\u000e\u001a\u00020\nJ\u0006\u0010\u0011\u001a\u00020\u0012J\u000c\u0010\u000b\u001a\u0008\u0012\u0004\u0012\u00020\u00040\u0013J\u0006\u0010\u0014\u001a\u00020\u0005R\u001a\u0010\u0002\u001a\u000e\u0012\u0004\u0012\u00020\u0004\u0012\u0004\u0012\u00020\u00050\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u001a\u0010\u0008\u001a\u000e\u0012\u0004\u0012\u00020\n\u0012\u0004\u0012\u00020\n0\tX\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0014\u0010\u000b\u001a\u0008\u0012\u0004\u0012\u00020\u00040\u000cX\u0082\u0004\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/appcore/runtime/Tripwire;",
        "",
        "onTrip",
        "Lkotlin/Function1;",
        "Lcom/appcore/runtime/TripwireEvent;",
        "",
        "<init>",
        "(Lkotlin/jvm/functions/Function1;)V",
        "values",
        "",
        "",
        "trips",
        "",
        "registerTripwire",
        "id",
        "fakeValue",
        "useTripwire",
        "tripCount",
        "",
        "",
        "clear"
    }
    k = 0x1
    mv = {
        0x2,
        0x0,
        0x0
    }
    xi = 0x30
.end annotation


# instance fields
.field private final onTrip:Lkotlin/jvm/functions/Function1;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lkotlin/jvm/functions/Function1<",
            "Lcom/appcore/runtime/TripwireEvent;",
            "Lkotlin/Unit;",
            ">;"
        }
    .end annotation
.end field

.field private final trips:Ljava/util/List;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/List<",
            "Lcom/appcore/runtime/TripwireEvent;",
            ">;"
        }
    .end annotation
.end field

.field private final values:Ljava/util/Map;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Ljava/util/Map<",
            "Ljava/lang/String;",
            "Ljava/lang/String;",
            ">;"
        }
    .end annotation
.end field


# direct methods
.method public static synthetic $r8$lambda$WehJ6snFpPp9zIh3Y6ShKYO1IXM(Lcom/appcore/runtime/TripwireEvent;)Lkotlin/Unit;
    .registers 1

    invoke-static {p0}, Lcom/appcore/runtime/Tripwire;->_init_$lambda$0(Lcom/appcore/runtime/TripwireEvent;)Lkotlin/Unit;

    move-result-object p0

    return-object p0
.end method

.method public constructor <init>()V
    .registers 3

    const/4 v0, 0x0

    const/4 v1, 0x1

    invoke-direct {p0, v0, v1, v0}, Lcom/appcore/runtime/Tripwire;-><init>(Lkotlin/jvm/functions/Function1;ILkotlin/jvm/internal/DefaultConstructorMarker;)V

    return-void
.end method

.method public constructor <init>(Lkotlin/jvm/functions/Function1;)V
    .registers 3
    .param p1, "onTrip"    # Lkotlin/jvm/functions/Function1;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lkotlin/jvm/functions/Function1<",
            "-",
            "Lcom/appcore/runtime/TripwireEvent;",
            "Lkotlin/Unit;",
            ">;)V"
        }
    .end annotation

    const-string v0, "onTrip"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 26
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/appcore/runtime/Tripwire;->onTrip:Lkotlin/jvm/functions/Function1;

    .line 28
    new-instance v0, Ljava/util/LinkedHashMap;

    invoke-direct {v0}, Ljava/util/LinkedHashMap;-><init>()V

    check-cast v0, Ljava/util/Map;

    iput-object v0, p0, Lcom/appcore/runtime/Tripwire;->values:Ljava/util/Map;

    .line 29
    new-instance v0, Ljava/util/ArrayList;

    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V

    check-cast v0, Ljava/util/List;

    iput-object v0, p0, Lcom/appcore/runtime/Tripwire;->trips:Ljava/util/List;

    .line 26
    return-void
.end method

.method public synthetic constructor <init>(Lkotlin/jvm/functions/Function1;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
    .registers 4

    .line 26
    and-int/lit8 p2, p2, 0x1

    if-eqz p2, :cond_9

    new-instance p1, Lcom/appcore/runtime/Tripwire$$ExternalSyntheticLambda0;

    invoke-direct {p1}, Lcom/appcore/runtime/Tripwire$$ExternalSyntheticLambda0;-><init>()V

    :cond_9
    invoke-direct {p0, p1}, Lcom/appcore/runtime/Tripwire;-><init>(Lkotlin/jvm/functions/Function1;)V

    return-void
.end method

.method private static final _init_$lambda$0(Lcom/appcore/runtime/TripwireEvent;)Lkotlin/Unit;
    .registers 2
    .param p0, "it"    # Lcom/appcore/runtime/TripwireEvent;

    const-string v0, "it"

    invoke-static {p0, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 26
    sget-object v0, Lkotlin/Unit;->INSTANCE:Lkotlin/Unit;

    return-object v0
.end method


# virtual methods
.method public final declared-synchronized clear()V
    .registers 2

    monitor-enter p0

    .line 69
    :try_start_1
    iget-object v0, p0, Lcom/appcore/runtime/Tripwire;->values:Ljava/util/Map;

    invoke-interface {v0}, Ljava/util/Map;->clear()V

    .line 70
    iget-object v0, p0, Lcom/appcore/runtime/Tripwire;->trips:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->clear()V
    :try_end_b
    .catchall {:try_start_1 .. :try_end_b} :catchall_d

    .line 71
    monitor-exit p0

    return-void

    .line 68
    .end local p0    # "this":Lcom/appcore/runtime/Tripwire;
    :catchall_d
    move-exception v0

    :try_start_e
    monitor-exit p0
    :try_end_f
    .catchall {:try_start_e .. :try_end_f} :catchall_d

    throw v0
.end method

.method public final declared-synchronized registerTripwire(Ljava/lang/String;Ljava/lang/String;)V
    .registers 4
    .param p1, "id"    # Ljava/lang/String;
    .param p2, "fakeValue"    # Ljava/lang/String;

    monitor-enter p0

    :try_start_1
    const-string v0, "id"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "fakeValue"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 34
    iget-object v0, p0, Lcom/appcore/runtime/Tripwire;->values:Ljava/util/Map;

    invoke-interface {v0, p1, p2}, Ljava/util/Map;->put(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_10
    .catchall {:try_start_1 .. :try_end_10} :catchall_12

    .line 35
    monitor-exit p0

    return-void

    .line 33
    .end local p0    # "this":Lcom/appcore/runtime/Tripwire;
    .end local p1    # "id":Ljava/lang/String;
    .end local p2    # "fakeValue":Ljava/lang/String;
    :catchall_12
    move-exception p1

    :try_start_13
    monitor-exit p0
    :try_end_14
    .catchall {:try_start_13 .. :try_end_14} :catchall_12

    throw p1
.end method

.method public final declared-synchronized tripCount()I
    .registers 2

    monitor-enter p0

    .line 60
    :try_start_1
    iget-object v0, p0, Lcom/appcore/runtime/Tripwire;->trips:Ljava/util/List;

    invoke-interface {v0}, Ljava/util/List;->size()I

    move-result v0
    :try_end_7
    .catchall {:try_start_1 .. :try_end_7} :catchall_9

    monitor-exit p0

    return v0

    .line 60
    .end local p0    # "this":Lcom/appcore/runtime/Tripwire;
    :catchall_9
    move-exception v0

    :try_start_a
    monitor-exit p0
    :try_end_b
    .catchall {:try_start_a .. :try_end_b} :catchall_9

    throw v0
.end method

.method public final declared-synchronized trips()Ljava/util/List;
    .registers 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Lcom/appcore/runtime/TripwireEvent;",
            ">;"
        }
    .end annotation

    monitor-enter p0

    .line 64
    :try_start_1
    iget-object v0, p0, Lcom/appcore/runtime/Tripwire;->trips:Ljava/util/List;

    check-cast v0, Ljava/lang/Iterable;

    invoke-static {v0}, Lkotlin/collections/CollectionsKt;->toList(Ljava/lang/Iterable;)Ljava/util/List;

    move-result-object v0
    :try_end_9
    .catchall {:try_start_1 .. :try_end_9} :catchall_b

    monitor-exit p0

    return-object v0

    .line 64
    .end local p0    # "this":Lcom/appcore/runtime/Tripwire;
    :catchall_b
    move-exception v0

    :try_start_c
    monitor-exit p0
    :try_end_d
    .catchall {:try_start_c .. :try_end_d} :catchall_b

    throw v0
.end method

.method public final declared-synchronized useTripwire(Ljava/lang/String;)Ljava/lang/String;
    .registers 6
    .param p1, "id"    # Ljava/lang/String;

    monitor-enter p0

    :try_start_1
    const-string v0, "id"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 47
    iget-object v0, p0, Lcom/appcore/runtime/Tripwire;->values:Ljava/util/Map;

    invoke-interface {v0, p1}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/String;
    :try_end_e
    .catchall {:try_start_1 .. :try_end_e} :catchall_2b

    if-nez v0, :cond_13

    monitor-exit p0

    const/4 v0, 0x0

    return-object v0

    .line 48
    .local v0, "value":Ljava/lang/String;
    :cond_13
    :try_start_13
    new-instance v1, Lcom/appcore/runtime/TripwireEvent;

    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v2

    invoke-direct {v1, p1, v2, v3}, Lcom/appcore/runtime/TripwireEvent;-><init>(Ljava/lang/String;J)V

    .line 49
    .local v1, "event":Lcom/appcore/runtime/TripwireEvent;
    iget-object v2, p0, Lcom/appcore/runtime/Tripwire;->trips:Ljava/util/List;

    invoke-interface {v2, v1}, Ljava/util/List;->add(Ljava/lang/Object;)Z
    :try_end_21
    .catchall {:try_start_13 .. :try_end_21} :catchall_2b

    .line 50
    nop

    .line 51
    :try_start_22
    iget-object v2, p0, Lcom/appcore/runtime/Tripwire;->onTrip:Lkotlin/jvm/functions/Function1;

    invoke-interface {v2, v1}, Lkotlin/jvm/functions/Function1;->invoke(Ljava/lang/Object;)Ljava/lang/Object;
    :try_end_27
    .catch Ljava/lang/Exception; {:try_start_22 .. :try_end_27} :catch_28
    .catchall {:try_start_22 .. :try_end_27} :catchall_2b

    goto :goto_29

    .line 52
    .end local p0    # "this":Lcom/appcore/runtime/Tripwire;
    :catch_28
    move-exception v2

    .line 55
    :goto_29
    monitor-exit p0

    return-object v0

    .line 46
    .end local v0    # "value":Ljava/lang/String;
    .end local v1    # "event":Lcom/appcore/runtime/TripwireEvent;
    .end local p1    # "id":Ljava/lang/String;
    :catchall_2b
    move-exception p1

    :try_start_2c
    monitor-exit p0
    :try_end_2d
    .catchall {:try_start_2c .. :try_end_2d} :catchall_2b

    throw p1
.end method
