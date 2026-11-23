.class public final Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;
.super Ljava/lang/Object;
.source "ReaMemory.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/antirea/runtime/ReaMemory;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "ObfuscatedInt"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000(\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u0008\n\u0002\u0008\u0005\n\u0002\u0010\t\n\u0002\u0008\u0002\n\u0002\u0010\u0002\n\u0002\u0008\u0004\n\u0002\u0010\u000b\n\u0000\u0018\u00002\u00020\u0001B\u000f\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0004\u0010\u0005J\u000e\u0010\u000b\u001a\u00020\u000c2\u0006\u0010\r\u001a\u00020\u0003J\r\u0010\u000e\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\u0002\u0010\u000fJ\u0006\u0010\u0010\u001a\u00020\u0011J\u0006\u0010\u0012\u001a\u00020\u000cR\u000e\u0010\u0006\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\u0003X\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0008\u001a\u00020\tX\u0082\u000e\u00a2\u0006\u0002\n\u0000R\u000e\u0010\n\u001a\u00020\tX\u0082\u000e\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;",
        "",
        "initial",
        "",
        "<init>",
        "(I)V",
        "partA",
        "partB",
        "salt",
        "",
        "check",
        "set",
        "",
        "value",
        "get",
        "()Ljava/lang/Integer;",
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

.field private partA:I

.field private partB:I

.field private salt:J


# direct methods
.method public constructor <init>(I)V
    .registers 2
    .param p1, "initial"    # I

    .line 158
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 164
    nop

    .line 165
    invoke-virtual {p0, p1}, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->set(I)V

    .line 166
    nop

    .line 158
    return-void
.end method


# virtual methods
.method public final corruptForTest()V
    .registers 2

    .line 187
    iget v0, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->partA:I

    xor-int/lit8 v0, v0, 0x1

    iput v0, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->partA:I

    .line 188
    return-void
.end method

.method public final get()Ljava/lang/Integer;
    .registers 6

    .line 178
    iget v0, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->partA:I

    iget v1, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->partB:I

    xor-int/2addr v0, v1

    .line 179
    .local v0, "value":I
    sget-object v1, Lcom/antirea/runtime/ReaMemory;->INSTANCE:Lcom/antirea/runtime/ReaMemory;

    iget-wide v2, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->salt:J

    # invokes: Lcom/antirea/runtime/ReaMemory;->checksumInt(IJ)J
    invoke-static {v1, v0, v2, v3}, Lcom/antirea/runtime/ReaMemory;->access$checksumInt(Lcom/antirea/runtime/ReaMemory;IJ)J

    move-result-wide v1

    iget-wide v3, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->check:J

    cmp-long v1, v1, v3

    if-nez v1, :cond_18

    invoke-static {v0}, Ljava/lang/Integer;->valueOf(I)Ljava/lang/Integer;

    move-result-object v1

    goto :goto_19

    :cond_18
    const/4 v1, 0x0

    :goto_19
    return-object v1
.end method

.method public final isIntact()Z
    .registers 2

    .line 183
    invoke-virtual {p0}, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->get()Ljava/lang/Integer;

    move-result-object v0

    if-eqz v0, :cond_8

    const/4 v0, 0x1

    goto :goto_9

    :cond_8
    const/4 v0, 0x0

    :goto_9
    return v0
.end method

.method public final set(I)V
    .registers 5
    .param p1, "value"    # I

    .line 170
    sget-object v0, Lcom/antirea/runtime/ReaMemory;->INSTANCE:Lcom/antirea/runtime/ReaMemory;

    # invokes: Lcom/antirea/runtime/ReaMemory;->randomLong()J
    invoke-static {v0}, Lcom/antirea/runtime/ReaMemory;->access$randomLong(Lcom/antirea/runtime/ReaMemory;)J

    move-result-wide v0

    iput-wide v0, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->salt:J

    .line 171
    sget-object v0, Lcom/antirea/runtime/ReaMemory;->INSTANCE:Lcom/antirea/runtime/ReaMemory;

    # invokes: Lcom/antirea/runtime/ReaMemory;->randomInt()I
    invoke-static {v0}, Lcom/antirea/runtime/ReaMemory;->access$randomInt(Lcom/antirea/runtime/ReaMemory;)I

    move-result v0

    iput v0, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->partA:I

    .line 172
    iget v0, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->partA:I

    xor-int/2addr v0, p1

    iput v0, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->partB:I

    .line 173
    sget-object v0, Lcom/antirea/runtime/ReaMemory;->INSTANCE:Lcom/antirea/runtime/ReaMemory;

    iget-wide v1, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->salt:J

    # invokes: Lcom/antirea/runtime/ReaMemory;->checksumInt(IJ)J
    invoke-static {v0, p1, v1, v2}, Lcom/antirea/runtime/ReaMemory;->access$checksumInt(Lcom/antirea/runtime/ReaMemory;IJ)J

    move-result-wide v0

    iput-wide v0, p0, Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;->check:J

    .line 174
    return-void
.end method
