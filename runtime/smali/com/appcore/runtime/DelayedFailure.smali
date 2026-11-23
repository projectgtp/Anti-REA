.class public final Lcom/appcore/runtime/DelayedFailure;
.super Ljava/lang/Object;
.source "ReaTraps.kt"


# annotations
.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nReaTraps.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ReaTraps.kt\ncom/appcore/runtime/DelayedFailure\n+ 2 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,131:1\n1#2:132\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u001e\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0008\n\u0002\u0008\u0004\n\u0002\u0010\u0002\n\u0000\n\u0002\u0010\u000b\n\u0000\u0018\u00002\u00020\u0001B\u0011\u0012\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0004\u0010\u0005J\u0006\u0010\u0007\u001a\u00020\u0008J\u0006\u0010\t\u001a\u00020\nJ\u0006\u0010\u0006\u001a\u00020\u0003J\u0006\u0010\u000b\u001a\u00020\u0008R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/appcore/runtime/DelayedFailure;",
        "",
        "threshold",
        "",
        "<init>",
        "(I)V",
        "failureCount",
        "recordIntegrityFailure",
        "",
        "allowSensitiveAction",
        "",
        "reset"
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
.field private failureCount:I

.field private final threshold:I


# direct methods
.method public constructor <init>()V
    .registers 4

    const/4 v0, 0x1

    const/4 v1, 0x0

    const/4 v2, 0x0

    invoke-direct {p0, v2, v0, v1}, Lcom/appcore/runtime/DelayedFailure;-><init>(IILkotlin/jvm/internal/DefaultConstructorMarker;)V

    return-void
.end method

.method public constructor <init>(I)V
    .registers 4
    .param p1, "threshold"    # I

    .line 86
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput p1, p0, Lcom/appcore/runtime/DelayedFailure;->threshold:I

    .line 90
    nop

    .line 91
    iget v0, p0, Lcom/appcore/runtime/DelayedFailure;->threshold:I

    const/4 v1, 0x1

    if-lt v0, v1, :cond_c

    goto :goto_d

    :cond_c
    const/4 v1, 0x0

    :goto_d
    if-eqz v1, :cond_11

    .line 92
    nop

    .line 86
    return-void

    .line 132
    :cond_11
    const/4 v0, 0x0

    .line 91
    .local v0, "$i$a$-require-DelayedFailure$1":I
    nop

    .end local v0    # "$i$a$-require-DelayedFailure$1":I
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "AppCore: DelayedFailure threshold must be >= 1"

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public synthetic constructor <init>(IILkotlin/jvm/internal/DefaultConstructorMarker;)V
    .registers 4

    .line 86
    and-int/lit8 p2, p2, 0x1

    if-eqz p2, :cond_5

    const/4 p1, 0x3

    :cond_5
    invoke-direct {p0, p1}, Lcom/appcore/runtime/DelayedFailure;-><init>(I)V

    return-void
.end method


# virtual methods
.method public final declared-synchronized allowSensitiveAction()Z
    .registers 3

    monitor-enter p0

    .line 106
    :try_start_1
    iget v0, p0, Lcom/appcore/runtime/DelayedFailure;->failureCount:I

    iget v1, p0, Lcom/appcore/runtime/DelayedFailure;->threshold:I
    :try_end_5
    .catchall {:try_start_1 .. :try_end_5} :catchall_c

    if-ge v0, v1, :cond_9

    const/4 v0, 0x1

    goto :goto_a

    :cond_9
    const/4 v0, 0x0

    :goto_a
    monitor-exit p0

    return v0

    .line 106
    .end local p0    # "this":Lcom/appcore/runtime/DelayedFailure;
    :catchall_c
    move-exception v0

    :try_start_d
    monitor-exit p0
    :try_end_e
    .catchall {:try_start_d .. :try_end_e} :catchall_c

    throw v0
.end method

.method public final declared-synchronized failureCount()I
    .registers 2

    monitor-enter p0

    .line 110
    :try_start_1
    iget v0, p0, Lcom/appcore/runtime/DelayedFailure;->failureCount:I
    :try_end_3
    .catchall {:try_start_1 .. :try_end_3} :catchall_5

    monitor-exit p0

    return v0

    .line 110
    .end local p0    # "this":Lcom/appcore/runtime/DelayedFailure;
    :catchall_5
    move-exception v0

    :try_start_6
    monitor-exit p0
    :try_end_7
    .catchall {:try_start_6 .. :try_end_7} :catchall_5

    throw v0
.end method

.method public final declared-synchronized recordIntegrityFailure()V
    .registers 2

    monitor-enter p0

    .line 101
    :try_start_1
    iget v0, p0, Lcom/appcore/runtime/DelayedFailure;->failureCount:I

    add-int/lit8 v0, v0, 0x1

    iput v0, p0, Lcom/appcore/runtime/DelayedFailure;->failureCount:I
    :try_end_7
    .catchall {:try_start_1 .. :try_end_7} :catchall_9

    .line 102
    monitor-exit p0

    return-void

    .line 100
    .end local p0    # "this":Lcom/appcore/runtime/DelayedFailure;
    :catchall_9
    move-exception v0

    :try_start_a
    monitor-exit p0
    :try_end_b
    .catchall {:try_start_a .. :try_end_b} :catchall_9

    throw v0
.end method

.method public final declared-synchronized reset()V
    .registers 2

    monitor-enter p0

    .line 115
    const/4 v0, 0x0

    :try_start_2
    iput v0, p0, Lcom/appcore/runtime/DelayedFailure;->failureCount:I
    :try_end_4
    .catchall {:try_start_2 .. :try_end_4} :catchall_6

    .line 116
    monitor-exit p0

    return-void

    .line 114
    .end local p0    # "this":Lcom/appcore/runtime/DelayedFailure;
    :catchall_6
    move-exception v0

    :try_start_7
    monitor-exit p0
    :try_end_8
    .catchall {:try_start_7 .. :try_end_8} :catchall_6

    throw v0
.end method
