.class public final Lcom/antirea/runtime/DelayedFailure;
.super Ljava/lang/Object;
.source "ReaTraps.kt"


# annotations
.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nReaTraps.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ReaTraps.kt\ncom/antirea/runtime/DelayedFailure\n+ 2 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,115:1\n1#2:116\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u001e\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0008\n\u0002\u0008\u0004\n\u0002\u0010\u0002\n\u0000\n\u0002\u0010\u000b\n\u0000\u0018\u00002\u00020\u0001B\u0011\u0012\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0004\u0010\u0005J\u0006\u0010\u0007\u001a\u00020\u0008J\u0006\u0010\t\u001a\u00020\nJ\u0006\u0010\u0006\u001a\u00020\u0003J\u0006\u0010\u000b\u001a\u00020\u0008R\u000e\u0010\u0002\u001a\u00020\u0003X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/antirea/runtime/DelayedFailure;",
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

    invoke-direct {p0, v2, v0, v1}, Lcom/antirea/runtime/DelayedFailure;-><init>(IILkotlin/jvm/internal/DefaultConstructorMarker;)V

    return-void
.end method

.method public constructor <init>(I)V
    .registers 4
    .param p1, "threshold"    # I

    .line 78
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput p1, p0, Lcom/antirea/runtime/DelayedFailure;->threshold:I

    .line 82
    nop

    .line 83
    iget v0, p0, Lcom/antirea/runtime/DelayedFailure;->threshold:I

    const/4 v1, 0x1

    if-lt v0, v1, :cond_c

    goto :goto_d

    :cond_c
    const/4 v1, 0x0

    :goto_d
    if-eqz v1, :cond_11

    .line 84
    nop

    .line 78
    return-void

    .line 116
    :cond_11
    const/4 v0, 0x0

    .line 83
    .local v0, "$i$a$-require-DelayedFailure$1":I
    nop

    .end local v0    # "$i$a$-require-DelayedFailure$1":I
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "Anti-REA: DelayedFailure threshold must be >= 1"

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public synthetic constructor <init>(IILkotlin/jvm/internal/DefaultConstructorMarker;)V
    .registers 4

    .line 78
    and-int/lit8 p2, p2, 0x1

    if-eqz p2, :cond_5

    const/4 p1, 0x3

    :cond_5
    invoke-direct {p0, p1}, Lcom/antirea/runtime/DelayedFailure;-><init>(I)V

    return-void
.end method


# virtual methods
.method public final allowSensitiveAction()Z
    .registers 3

    .line 92
    iget v0, p0, Lcom/antirea/runtime/DelayedFailure;->failureCount:I

    iget v1, p0, Lcom/antirea/runtime/DelayedFailure;->threshold:I

    if-ge v0, v1, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public final failureCount()I
    .registers 2

    .line 95
    iget v0, p0, Lcom/antirea/runtime/DelayedFailure;->failureCount:I

    return v0
.end method

.method public final recordIntegrityFailure()V
    .registers 2

    .line 88
    iget v0, p0, Lcom/antirea/runtime/DelayedFailure;->failureCount:I

    add-int/lit8 v0, v0, 0x1

    iput v0, p0, Lcom/antirea/runtime/DelayedFailure;->failureCount:I

    .line 89
    return-void
.end method

.method public final reset()V
    .registers 2

    .line 99
    const/4 v0, 0x0

    iput v0, p0, Lcom/antirea/runtime/DelayedFailure;->failureCount:I

    .line 100
    return-void
.end method
