.class public final Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;
.super Ljava/lang/Object;
.source "ReaIntegrity2.kt"

# interfaces
.implements Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Found"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000$\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u0000\n\u0002\u0008\u0007\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u0008\n\u0000\n\u0002\u0010\u000e\u0008\u0086\u0008\u0018\u00002\u00020\u0001B\u0011\u0012\u0008\u0010\u0002\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\u0004\u0008\u0004\u0010\u0005J\u000b\u0010\u0008\u001a\u0004\u0018\u00010\u0003H\u00c6\u0003J\u0015\u0010\t\u001a\u00020\u00002\n\u0008\u0002\u0010\u0002\u001a\u0004\u0018\u00010\u0003H\u00c6\u0001J\u0013\u0010\n\u001a\u00020\u000b2\u0008\u0010\u000c\u001a\u0004\u0018\u00010\u0003H\u00d6\u0003J\t\u0010\r\u001a\u00020\u000eH\u00d6\u0001J\t\u0010\u000f\u001a\u00020\u0010H\u00d6\u0001R\u0013\u0010\u0002\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0006\u0010\u0007"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;",
        "Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;",
        "value",
        "",
        "<init>",
        "(Ljava/lang/Object;)V",
        "getValue",
        "()Ljava/lang/Object;",
        "component1",
        "copy",
        "equals",
        "",
        "other",
        "hashCode",
        "",
        "toString",
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
.field private final value:Ljava/lang/Object;


# direct methods
.method public constructor <init>(Ljava/lang/Object;)V
    .registers 2
    .param p1, "value"    # Ljava/lang/Object;

    .line 372
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    iput-object p1, p0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->value:Ljava/lang/Object;

    return-void
.end method

.method public static synthetic copy$default(Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;Ljava/lang/Object;ILjava/lang/Object;)Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;
    .registers 4

    and-int/lit8 p2, p2, 0x1

    if-eqz p2, :cond_6

    iget-object p1, p0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->value:Ljava/lang/Object;

    :cond_6
    invoke-virtual {p0, p1}, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->copy(Ljava/lang/Object;)Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()Ljava/lang/Object;
    .registers 2

    iget-object v0, p0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->value:Ljava/lang/Object;

    return-object v0
.end method

.method public final copy(Ljava/lang/Object;)Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;
    .registers 3

    new-instance v0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;

    invoke-direct {v0, p1}, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;-><init>(Ljava/lang/Object;)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .registers 6

    const/4 v0, 0x1

    if-ne p0, p1, :cond_4

    return v0

    :cond_4
    instance-of v1, p1, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;

    const/4 v2, 0x0

    if-nez v1, :cond_a

    return v2

    :cond_a
    move-object v1, p1

    check-cast v1, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;

    iget-object v3, p0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->value:Ljava/lang/Object;

    iget-object v1, v1, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->value:Ljava/lang/Object;

    invoke-static {v3, v1}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v1

    if-nez v1, :cond_18

    return v2

    :cond_18
    return v0
.end method

.method public final getValue()Ljava/lang/Object;
    .registers 2

    .line 372
    iget-object v0, p0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->value:Ljava/lang/Object;

    return-object v0
.end method

.method public hashCode()I
    .registers 2

    iget-object v0, p0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->value:Ljava/lang/Object;

    if-nez v0, :cond_6

    const/4 v0, 0x0

    goto :goto_c

    :cond_6
    iget-object v0, p0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->value:Ljava/lang/Object;

    invoke-virtual {v0}, Ljava/lang/Object;->hashCode()I

    move-result v0

    :goto_c
    return v0
.end method

.method public toString()Ljava/lang/String;
    .registers 3

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "Found(value="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$Found;->value:Ljava/lang/Object;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const/16 v1, 0x29

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
