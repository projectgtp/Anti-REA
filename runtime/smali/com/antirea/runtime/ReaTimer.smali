.class public final Lcom/antirea/runtime/ReaTimer;
.super Ljava/lang/Object;
.source "ReaTimer.kt"


# annotations
.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nReaTimer.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ReaTimer.kt\ncom/antirea/runtime/ReaTimer\n+ 2 fake.kt\nkotlin/jvm/internal/FakeKt\n*L\n1#1,152:1\n1#2:153\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u00002\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\t\n\u0000\n\u0002\u0018\u0002\n\u0002\u0010\u000b\n\u0002\u0008\u0006\n\u0002\u0010\u0008\n\u0002\u0008\u000e\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002\n\u0002\u0008\u0006\u0018\u00002\u00020\u0001B-\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u000c\u0010\u0004\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005\u0012\u000e\u0008\u0002\u0010\u0007\u001a\u0008\u0012\u0004\u0012\u00020\u00030\u0005\u00a2\u0006\u0004\u0008\u0008\u0010\tJ\u0006\u0010\u001d\u001a\u00020\u001eJ\u000e\u0010\u001f\u001a\u00020\r2\u0006\u0010 \u001a\u00020\u0003J\u000e\u0010!\u001a\u00020\r2\u0006\u0010 \u001a\u00020\u0003J\u0006\u0010\"\u001a\u00020\u001eJ\u0006\u0010#\u001a\u00020\u001eJ\u0006\u0010$\u001a\u00020\u001eR\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\n\u0010\u000bR\u0014\u0010\u0004\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u0014\u0010\u0007\u001a\u0008\u0012\u0004\u0012\u00020\u00030\u0005X\u0082\u0004\u00a2\u0006\u0002\n\u0000R\u001e\u0010\u000e\u001a\u00020\r2\u0006\u0010\u000c\u001a\u00020\r@BX\u0086\u000e\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000f\u0010\u0010R\u001e\u0010\u0011\u001a\u00020\r2\u0006\u0010\u000c\u001a\u00020\r@BX\u0086\u000e\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0012\u0010\u0010R\u001e\u0010\u0013\u001a\u00020\u00062\u0006\u0010\u000c\u001a\u00020\u0006@BX\u0086\u000e\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0014\u0010\u0015R$\u0010\u0016\u001a\u0004\u0018\u00010\u00032\u0008\u0010\u000c\u001a\u0004\u0018\u00010\u0003@BX\u0086\u000e\u00a2\u0006\n\n\u0002\u0010\u0019\u001a\u0004\u0008\u0017\u0010\u0018R\u0012\u0010\u001a\u001a\u0004\u0018\u00010\u0003X\u0082\u000e\u00a2\u0006\u0004\n\u0002\u0010\u0019R\u0010\u0010\u001b\u001a\u0004\u0018\u00010\u001cX\u0082\u000e\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/antirea/runtime/ReaTimer;",
        "",
        "intervalMs",
        "",
        "check",
        "Lkotlin/Function0;",
        "",
        "clockMs",
        "<init>",
        "(JLkotlin/jvm/functions/Function0;Lkotlin/jvm/functions/Function0;)V",
        "getIntervalMs",
        "()J",
        "value",
        "",
        "fireCount",
        "getFireCount",
        "()I",
        "passCount",
        "getPassCount",
        "stopped",
        "getStopped",
        "()Z",
        "lastFireMs",
        "getLastFireMs",
        "()Ljava/lang/Long;",
        "Ljava/lang/Long;",
        "nextFireMs",
        "realTimer",
        "Ljava/util/Timer;",
        "arm",
        "",
        "tick",
        "nowMs",
        "runDue",
        "reset",
        "stop",
        "startRealTime"
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
.field private final check:Lkotlin/jvm/functions/Function0;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lkotlin/jvm/functions/Function0<",
            "Ljava/lang/Boolean;",
            ">;"
        }
    .end annotation
.end field

.field private final clockMs:Lkotlin/jvm/functions/Function0;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "Lkotlin/jvm/functions/Function0<",
            "Ljava/lang/Long;",
            ">;"
        }
    .end annotation
.end field

.field private fireCount:I

.field private final intervalMs:J

.field private lastFireMs:Ljava/lang/Long;

.field private nextFireMs:Ljava/lang/Long;

.field private passCount:I

.field private realTimer:Ljava/util/Timer;

.field private stopped:Z


# direct methods
.method public static synthetic $r8$lambda$-sKtni2-MSLIJ4Z-_4u8fAUfPdU()J
    .registers 2

    invoke-static {}, Lcom/antirea/runtime/ReaTimer;->_init_$lambda$0()J

    move-result-wide v0

    return-wide v0
.end method

.method public constructor <init>(JLkotlin/jvm/functions/Function0;Lkotlin/jvm/functions/Function0;)V
    .registers 9
    .param p1, "intervalMs"    # J
    .param p3, "check"    # Lkotlin/jvm/functions/Function0;
    .param p4, "clockMs"    # Lkotlin/jvm/functions/Function0;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(J",
            "Lkotlin/jvm/functions/Function0<",
            "Ljava/lang/Boolean;",
            ">;",
            "Lkotlin/jvm/functions/Function0<",
            "Ljava/lang/Long;",
            ">;)V"
        }
    .end annotation

    const-string v0, "check"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "clockMs"

    invoke-static {p4, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 29
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 31
    iput-wide p1, p0, Lcom/antirea/runtime/ReaTimer;->intervalMs:J

    .line 33
    iput-object p3, p0, Lcom/antirea/runtime/ReaTimer;->check:Lkotlin/jvm/functions/Function0;

    .line 35
    iput-object p4, p0, Lcom/antirea/runtime/ReaTimer;->clockMs:Lkotlin/jvm/functions/Function0;

    .line 37
    nop

    .line 38
    iget-wide v0, p0, Lcom/antirea/runtime/ReaTimer;->intervalMs:J

    const-wide/16 v2, 0x0

    cmp-long v0, v0, v2

    if-lez v0, :cond_1e

    const/4 v0, 0x1

    goto :goto_1f

    :cond_1e
    const/4 v0, 0x0

    :goto_1f
    if-eqz v0, :cond_23

    .line 39
    nop

    .line 29
    return-void

    .line 153
    :cond_23
    const/4 v0, 0x0

    .line 38
    .local v0, "$i$a$-require-ReaTimer$2":I
    nop

    .end local v0    # "$i$a$-require-ReaTimer$2":I
    new-instance v0, Ljava/lang/IllegalArgumentException;

    const-string v1, "Anti-REA: ReaTimer intervalMs must be > 0"

    invoke-virtual {v1}, Ljava/lang/Object;->toString()Ljava/lang/String;

    move-result-object v1

    invoke-direct {v0, v1}, Ljava/lang/IllegalArgumentException;-><init>(Ljava/lang/String;)V

    throw v0
.end method

.method public synthetic constructor <init>(JLkotlin/jvm/functions/Function0;Lkotlin/jvm/functions/Function0;ILkotlin/jvm/internal/DefaultConstructorMarker;)V
    .registers 7

    .line 29
    and-int/lit8 p5, p5, 0x4

    if-eqz p5, :cond_9

    .line 35
    new-instance p4, Lcom/antirea/runtime/ReaTimer$$ExternalSyntheticLambda0;

    invoke-direct {p4}, Lcom/antirea/runtime/ReaTimer$$ExternalSyntheticLambda0;-><init>()V

    .line 29
    :cond_9
    invoke-direct {p0, p1, p2, p3, p4}, Lcom/antirea/runtime/ReaTimer;-><init>(JLkotlin/jvm/functions/Function0;Lkotlin/jvm/functions/Function0;)V

    .line 36
    return-void
.end method

.method private static final _init_$lambda$0()J
    .registers 2

    .line 35
    invoke-static {}, Ljava/lang/System;->currentTimeMillis()J

    move-result-wide v0

    return-wide v0
.end method

.method public static final synthetic access$getClockMs$p(Lcom/antirea/runtime/ReaTimer;)Lkotlin/jvm/functions/Function0;
    .registers 2
    .param p0, "$this"    # Lcom/antirea/runtime/ReaTimer;

    .line 29
    iget-object v0, p0, Lcom/antirea/runtime/ReaTimer;->clockMs:Lkotlin/jvm/functions/Function0;

    return-object v0
.end method


# virtual methods
.method public final arm()V
    .registers 5

    .line 62
    iget-object v0, p0, Lcom/antirea/runtime/ReaTimer;->clockMs:Lkotlin/jvm/functions/Function0;

    invoke-interface {v0}, Lkotlin/jvm/functions/Function0;->invoke()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Number;

    invoke-virtual {v0}, Ljava/lang/Number;->longValue()J

    move-result-wide v0

    iget-wide v2, p0, Lcom/antirea/runtime/ReaTimer;->intervalMs:J

    add-long/2addr v0, v2

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v0

    iput-object v0, p0, Lcom/antirea/runtime/ReaTimer;->nextFireMs:Ljava/lang/Long;

    .line 63
    return-void
.end method

.method public final getFireCount()I
    .registers 2

    .line 42
    iget v0, p0, Lcom/antirea/runtime/ReaTimer;->fireCount:I

    return v0
.end method

.method public final getIntervalMs()J
    .registers 3

    .line 31
    iget-wide v0, p0, Lcom/antirea/runtime/ReaTimer;->intervalMs:J

    return-wide v0
.end method

.method public final getLastFireMs()Ljava/lang/Long;
    .registers 2

    .line 54
    iget-object v0, p0, Lcom/antirea/runtime/ReaTimer;->lastFireMs:Ljava/lang/Long;

    return-object v0
.end method

.method public final getPassCount()I
    .registers 2

    .line 46
    iget v0, p0, Lcom/antirea/runtime/ReaTimer;->passCount:I

    return v0
.end method

.method public final getStopped()Z
    .registers 2

    .line 50
    iget-boolean v0, p0, Lcom/antirea/runtime/ReaTimer;->stopped:Z

    return v0
.end method

.method public final reset()V
    .registers 5

    .line 104
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/antirea/runtime/ReaTimer;->stopped:Z

    .line 105
    iput v0, p0, Lcom/antirea/runtime/ReaTimer;->fireCount:I

    .line 106
    iput v0, p0, Lcom/antirea/runtime/ReaTimer;->passCount:I

    .line 107
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/antirea/runtime/ReaTimer;->lastFireMs:Ljava/lang/Long;

    .line 108
    iget-object v0, p0, Lcom/antirea/runtime/ReaTimer;->clockMs:Lkotlin/jvm/functions/Function0;

    invoke-interface {v0}, Lkotlin/jvm/functions/Function0;->invoke()Ljava/lang/Object;

    move-result-object v0

    check-cast v0, Ljava/lang/Number;

    invoke-virtual {v0}, Ljava/lang/Number;->longValue()J

    move-result-wide v0

    iget-wide v2, p0, Lcom/antirea/runtime/ReaTimer;->intervalMs:J

    add-long/2addr v0, v2

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v0

    iput-object v0, p0, Lcom/antirea/runtime/ReaTimer;->nextFireMs:Ljava/lang/Long;

    .line 109
    return-void
.end method

.method public final runDue(J)I
    .registers 4
    .param p1, "nowMs"    # J

    .line 100
    invoke-virtual {p0, p1, p2}, Lcom/antirea/runtime/ReaTimer;->tick(J)I

    move-result v0

    return v0
.end method

.method public final startRealTime()V
    .registers 10

    .line 129
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaTimer;->stop()V

    .line 130
    const/4 v0, 0x0

    iput-boolean v0, p0, Lcom/antirea/runtime/ReaTimer;->stopped:Z

    .line 131
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaTimer;->arm()V

    .line 132
    new-instance v0, Ljava/util/Timer;

    const-string v1, "rea-integrity-timer"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2}, Ljava/util/Timer;-><init>(Ljava/lang/String;Z)V

    move-object v3, v0

    .line 133
    .local v3, "timer":Ljava/util/Timer;
    iput-object v3, p0, Lcom/antirea/runtime/ReaTimer;->realTimer:Ljava/util/Timer;

    .line 134
    nop

    .line 135
    new-instance v0, Lcom/antirea/runtime/ReaTimer$startRealTime$1;

    invoke-direct {v0, p0, v3}, Lcom/antirea/runtime/ReaTimer$startRealTime$1;-><init>(Lcom/antirea/runtime/ReaTimer;Ljava/util/Timer;)V

    move-object v4, v0

    check-cast v4, Ljava/util/TimerTask;

    .line 147
    iget-wide v5, p0, Lcom/antirea/runtime/ReaTimer;->intervalMs:J

    .line 148
    iget-wide v7, p0, Lcom/antirea/runtime/ReaTimer;->intervalMs:J

    .line 134
    invoke-virtual/range {v3 .. v8}, Ljava/util/Timer;->scheduleAtFixedRate(Ljava/util/TimerTask;JJ)V

    .line 150
    return-void
.end method

.method public final stop()V
    .registers 2

    .line 113
    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/antirea/runtime/ReaTimer;->stopped:Z

    .line 114
    nop

    .line 115
    :try_start_4
    iget-object v0, p0, Lcom/antirea/runtime/ReaTimer;->realTimer:Ljava/util/Timer;

    if-eqz v0, :cond_d

    invoke-virtual {v0}, Ljava/util/Timer;->cancel()V
    :try_end_b
    .catch Ljava/lang/Exception; {:try_start_4 .. :try_end_b} :catch_c

    goto :goto_d

    .line 116
    :catch_c
    move-exception v0

    .line 119
    :cond_d
    :goto_d
    const/4 v0, 0x0

    iput-object v0, p0, Lcom/antirea/runtime/ReaTimer;->realTimer:Ljava/util/Timer;

    .line 120
    return-void
.end method

.method public final tick(J)I
    .registers 12
    .param p1, "nowMs"    # J

    .line 72
    iget-boolean v0, p0, Lcom/antirea/runtime/ReaTimer;->stopped:Z

    const/4 v1, 0x0

    if-eqz v0, :cond_6

    return v1

    .line 73
    :cond_6
    iget-object v0, p0, Lcom/antirea/runtime/ReaTimer;->nextFireMs:Ljava/lang/Long;

    if-eqz v0, :cond_50

    invoke-virtual {v0}, Ljava/lang/Long;->longValue()J

    move-result-wide v2

    .line 74
    .local v2, "next":J
    const/4 v0, 0x0

    .line 75
    .local v0, "fired":I
    move-wide v4, v2

    .line 76
    .local v4, "due":J
    :goto_10
    cmp-long v6, p1, v4

    if-ltz v6, :cond_45

    iget-boolean v6, p0, Lcom/antirea/runtime/ReaTimer;->stopped:Z

    if-nez v6, :cond_45

    .line 77
    nop

    .line 78
    :try_start_19
    iget-object v6, p0, Lcom/antirea/runtime/ReaTimer;->check:Lkotlin/jvm/functions/Function0;

    invoke-interface {v6}, Lkotlin/jvm/functions/Function0;->invoke()Ljava/lang/Object;

    move-result-object v6

    check-cast v6, Ljava/lang/Boolean;

    invoke-virtual {v6}, Ljava/lang/Boolean;->booleanValue()Z

    move-result v6
    :try_end_25
    .catch Ljava/lang/Exception; {:try_start_19 .. :try_end_25} :catch_26

    goto :goto_28

    .line 79
    :catch_26
    move-exception v6

    .line 80
    .local v6, "e":Ljava/lang/Exception;
    move v6, v1

    .line 77
    .end local v6    # "e":Ljava/lang/Exception;
    :goto_28
    nop

    .line 82
    .local v6, "ok":Z
    iget v7, p0, Lcom/antirea/runtime/ReaTimer;->fireCount:I

    const/4 v8, 0x1

    add-int/2addr v7, v8

    iput v7, p0, Lcom/antirea/runtime/ReaTimer;->fireCount:I

    .line 83
    add-int/lit8 v0, v0, 0x1

    .line 84
    invoke-static {v4, v5}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v7

    iput-object v7, p0, Lcom/antirea/runtime/ReaTimer;->lastFireMs:Ljava/lang/Long;

    .line 85
    if-eqz v6, :cond_42

    .line 86
    iget v7, p0, Lcom/antirea/runtime/ReaTimer;->passCount:I

    add-int/2addr v7, v8

    iput v7, p0, Lcom/antirea/runtime/ReaTimer;->passCount:I

    .line 87
    iget-wide v7, p0, Lcom/antirea/runtime/ReaTimer;->intervalMs:J

    add-long/2addr v4, v7

    goto :goto_10

    .line 89
    :cond_42
    iput-boolean v8, p0, Lcom/antirea/runtime/ReaTimer;->stopped:Z

    .end local v6    # "ok":Z
    goto :goto_10

    .line 92
    :cond_45
    iget-boolean v1, p0, Lcom/antirea/runtime/ReaTimer;->stopped:Z

    if-nez v1, :cond_4f

    invoke-static {v4, v5}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v1

    iput-object v1, p0, Lcom/antirea/runtime/ReaTimer;->nextFireMs:Ljava/lang/Long;

    .line 93
    :cond_4f
    return v0

    .line 73
    .end local v0    # "fired":I
    .end local v2    # "next":J
    .end local v4    # "due":J
    :cond_50
    return v1
.end method
