.class public final Lcom/appcore/runtime/ReaTimer$startRealTime$1;
.super Ljava/util/TimerTask;
.source "ReaTimer.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Lcom/appcore/runtime/ReaTimer;->startRealTime()V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = null
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u000f\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0002*\u0001\u0000\u0008\n\u0018\u00002\u00020\u0001J\u0008\u0010\u0002\u001a\u00020\u0003H\u0016"
    }
    d2 = {
        "com/appcore/runtime/ReaTimer$startRealTime$1",
        "Ljava/util/TimerTask;",
        "run",
        ""
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
.field final synthetic $timer:Ljava/util/Timer;

.field final synthetic this$0:Lcom/appcore/runtime/ReaTimer;


# direct methods
.method constructor <init>(Lcom/appcore/runtime/ReaTimer;Ljava/util/Timer;)V
    .registers 3
    .param p1, "$receiver"    # Lcom/appcore/runtime/ReaTimer;
    .param p2, "$timer"    # Ljava/util/Timer;

    iput-object p1, p0, Lcom/appcore/runtime/ReaTimer$startRealTime$1;->this$0:Lcom/appcore/runtime/ReaTimer;

    iput-object p2, p0, Lcom/appcore/runtime/ReaTimer$startRealTime$1;->$timer:Ljava/util/Timer;

    .line 160
    invoke-direct {p0}, Ljava/util/TimerTask;-><init>()V

    return-void
.end method


# virtual methods
.method public run()V
    .registers 4

    .line 162
    iget-object v0, p0, Lcom/appcore/runtime/ReaTimer$startRealTime$1;->this$0:Lcom/appcore/runtime/ReaTimer;

    iget-object v1, p0, Lcom/appcore/runtime/ReaTimer$startRealTime$1;->this$0:Lcom/appcore/runtime/ReaTimer;

    # getter for: Lcom/appcore/runtime/ReaTimer;->clockMs:Lkotlin/jvm/functions/Function0;
    invoke-static {v1}, Lcom/appcore/runtime/ReaTimer;->access$getClockMs$p(Lcom/appcore/runtime/ReaTimer;)Lkotlin/jvm/functions/Function0;

    move-result-object v1

    invoke-interface {v1}, Lkotlin/jvm/functions/Function0;->invoke()Ljava/lang/Object;

    move-result-object v1

    check-cast v1, Ljava/lang/Number;

    invoke-virtual {v1}, Ljava/lang/Number;->longValue()J

    move-result-wide v1

    invoke-virtual {v0, v1, v2}, Lcom/appcore/runtime/ReaTimer;->tick(J)I

    .line 163
    iget-object v0, p0, Lcom/appcore/runtime/ReaTimer$startRealTime$1;->this$0:Lcom/appcore/runtime/ReaTimer;

    invoke-virtual {v0}, Lcom/appcore/runtime/ReaTimer;->getStopped()Z

    move-result v0

    if-eqz v0, :cond_25

    .line 164
    nop

    .line 165
    :try_start_1e
    iget-object v0, p0, Lcom/appcore/runtime/ReaTimer$startRealTime$1;->$timer:Ljava/util/Timer;

    invoke-virtual {v0}, Ljava/util/Timer;->cancel()V
    :try_end_23
    .catch Ljava/lang/Exception; {:try_start_1e .. :try_end_23} :catch_24

    goto :goto_25

    .line 166
    :catch_24
    move-exception v0

    .line 170
    :cond_25
    :goto_25
    return-void
.end method
