.class public final Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;
.super Ljava/lang/Object;
.source "ReaMemory.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/appcore/runtime/ReaMemory;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "ObfuscatedLong"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000 \n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\t\n\u0002\u0008\u0007\n\u0002\u0010\u0002\n\u0002\u0008\u0004\n\u0002\u0010\u000b\n\u0000\u0018\u00002\u00020\u0001B\u000f\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0004\u0010\u0005J\u000e\u0010\n\u001a\u00020\u000b2\u0006\u0010\u000c\u001a\u00020\u0003J\r\u0010\r\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\u0002\u0010\u000eJ\u0006\u0010\u000f\u001a\u00020\u0010J\u0006\u0010\u0011\u001a\u00020\u000bR\u000e\u0010\u0006\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0008\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\t\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;",
        "",
        "initial",
        "",
        "<init>",
        "(J)V",
        "partA",
        "partB",
        "salt",
        "check",
        "set",
        "",
        "value",
        "get",
        "()Ljava/lang/Long;",
        "isIntact",
        "",
        "corruptForTest"
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
.field private check:J

.field private partA:J

.field private partB:J

.field private salt:J


# direct methods
.method public constructor <init>(J)V
    .registers 3
    .param p1, "initial"    # J

    .line 115
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 121
    nop

    .line 122
    invoke-virtual {p0, p1, p2}, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->set(J)V

    .line 123
    nop

    .line 115
    return-void
.end method


# virtual methods
.method public final corruptForTest()V
    .registers 5

    .line 150
    iget-wide v0, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->partA:J

    const-wide/16 v2, 0x1

    xor-long/2addr v0, v2

    iput-wide v0, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->partA:J

    .line 151
    return-void
.end method

.method public final get()Ljava/lang/Long;
    .registers 7

    .line 136
    iget-wide v0, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->partA:J

    iget-wide v2, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->partB:J

    xor-long/2addr v0, v2

    .line 137
    .local v0, "value":J
    sget-object v2, Lcom/appcore/runtime/ReaMemory;->INSTANCE:Lcom/appcore/runtime/ReaMemory;

    iget-wide v3, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->salt:J

    # invokes: Lcom/appcore/runtime/ReaMemory;->checksumLong(JJ)J
    invoke-static {v2, v0, v1, v3, v4}, Lcom/appcore/runtime/ReaMemory;->access$checksumLong(Lcom/appcore/runtime/ReaMemory;JJ)J

    move-result-wide v2

    iget-wide v4, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->check:J

    cmp-long v2, v2, v4

    if-nez v2, :cond_18

    invoke-static {v0, v1}, Ljava/lang/Long;->valueOf(J)Ljava/lang/Long;

    move-result-object v2

    goto :goto_19

    :cond_18
    const/4 v2, 0x0

    :goto_19
    return-object v2
.end method

.method public final isIntact()Z
    .registers 2

    .line 141
    invoke-virtual {p0}, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->get()Ljava/lang/Long;

    move-result-object v0

    if-eqz v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public final set(J)V
    .registers 6
    .param p1, "value"    # J

    .line 127
    sget-object v0, Lcom/appcore/runtime/ReaMemory;->INSTANCE:Lcom/appcore/runtime/ReaMemory;

    # invokes: Lcom/appcore/runtime/ReaMemory;->randomLong()J
    invoke-static {v0}, Lcom/appcore/runtime/ReaMemory;->access$randomLong(Lcom/appcore/runtime/ReaMemory;)J

    move-result-wide v0

    iput-wide v0, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->salt:J

    .line 128
    sget-object v0, Lcom/appcore/runtime/ReaMemory;->INSTANCE:Lcom/appcore/runtime/ReaMemory;

    # invokes: Lcom/appcore/runtime/ReaMemory;->randomLong()J
    invoke-static {v0}, Lcom/appcore/runtime/ReaMemory;->access$randomLong(Lcom/appcore/runtime/ReaMemory;)J

    move-result-wide v0

    iput-wide v0, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->partA:J

    .line 129
    iget-wide v0, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->partA:J

    xor-long/2addr v0, p1

    iput-wide v0, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->partB:J

    .line 130
    sget-object v0, Lcom/appcore/runtime/ReaMemory;->INSTANCE:Lcom/appcore/runtime/ReaMemory;

    iget-wide v1, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->salt:J

    # invokes: Lcom/appcore/runtime/ReaMemory;->checksumLong(JJ)J
    invoke-static {v0, p1, p2, v1, v2}, Lcom/appcore/runtime/ReaMemory;->access$checksumLong(Lcom/appcore/runtime/ReaMemory;JJ)J

    move-result-wide v0

    iput-wide v0, p0, Lcom/appcore/runtime/ReaMemory$ObfuscatedLong;->check:J

    .line 131
    return-void
.end method
