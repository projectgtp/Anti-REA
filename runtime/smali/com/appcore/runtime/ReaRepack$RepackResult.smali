.class public final Lcom/appcore/runtime/ReaRepack$RepackResult;
.super Ljava/lang/Object;
.source "ReaRepack.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/appcore/runtime/ReaRepack;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "RepackResult"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000 \n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0002\n\u0002\u0010\u000e\n\u0002\u0008\u0014\n\u0002\u0010\u0008\n\u0000\u0008\u0086\u0008\u0018\u00002\u00020\u0001B)\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0008\u0010\u0004\u001a\u0004\u0018\u00010\u0003\u0012\u0006\u0010\u0005\u001a\u00020\u0006\u0012\u0006\u0010\u0007\u001a\u00020\u0003\u00a2\u0006\u0004\u0008\u0008\u0010\tJ\t\u0010\u0012\u001a\u00020\u0003H\u00c6\u0003J\u0010\u0010\u0013\u001a\u0004\u0018\u00010\u0003H\u00c6\u0003\u00a2\u0006\u0002\u0010\rJ\t\u0010\u0014\u001a\u00020\u0006H\u00c6\u0003J\t\u0010\u0015\u001a\u00020\u0003H\u00c6\u0003J8\u0010\u0016\u001a\u00020\u00002\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u00032\n\u0008\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u00032\u0008\u0008\u0002\u0010\u0005\u001a\u00020\u00062\u0008\u0008\u0002\u0010\u0007\u001a\u00020\u0003H\u00c6\u0001\u00a2\u0006\u0002\u0010\u0017J\u0013\u0010\u0018\u001a\u00020\u00032\u0008\u0010\u0019\u001a\u0004\u0018\u00010\u0001H\u00d6\u0003J\t\u0010\u001a\u001a\u00020\u001bH\u00d6\u0001J\t\u0010\u001c\u001a\u00020\u0006H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\n\u0010\u000bR\u0015\u0010\u0004\u001a\u0004\u0018\u00010\u0003\u00a2\u0006\n\n\u0002\u0010\u000e\u001a\u0004\u0008\u000c\u0010\rR\u0011\u0010\u0005\u001a\u00020\u0006\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000f\u0010\u0010R\u0011\u0010\u0007\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0011\u0010\u000b"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaRepack$RepackResult;",
        "",
        "packageOk",
        "",
        "signatureOk",
        "installer",
        "",
        "allowSensitiveAction",
        "<init>",
        "(ZLjava/lang/Boolean;Ljava/lang/String;Z)V",
        "getPackageOk",
        "()Z",
        "getSignatureOk",
        "()Ljava/lang/Boolean;",
        "Ljava/lang/Boolean;",
        "getInstaller",
        "()Ljava/lang/String;",
        "getAllowSensitiveAction",
        "component1",
        "component2",
        "component3",
        "component4",
        "copy",
        "(ZLjava/lang/Boolean;Ljava/lang/String;Z)Lcom/appcore/runtime/ReaRepack$RepackResult;",
        "equals",
        "other",
        "hashCode",
        "",
        "toString"
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
.field private final allowSensitiveAction:Z

.field private final installer:Ljava/lang/String;

.field private final packageOk:Z

.field private final signatureOk:Ljava/lang/Boolean;


# direct methods
.method public constructor <init>(ZLjava/lang/Boolean;Ljava/lang/String;Z)V
    .registers 6
    .param p1, "packageOk"    # Z
    .param p2, "signatureOk"    # Ljava/lang/Boolean;
    .param p3, "installer"    # Ljava/lang/String;
    .param p4, "allowSensitiveAction"    # Z

    const-string v0, "installer"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 63
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 64
    iput-boolean p1, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->packageOk:Z

    .line 65
    iput-object p2, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->signatureOk:Ljava/lang/Boolean;

    .line 66
    iput-object p3, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->installer:Ljava/lang/String;

    .line 67
    iput-boolean p4, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->allowSensitiveAction:Z

    .line 63
    return-void
.end method

.method public static synthetic copy$default(Lcom/appcore/runtime/ReaRepack$RepackResult;ZLjava/lang/Boolean;Ljava/lang/String;ZILjava/lang/Object;)Lcom/appcore/runtime/ReaRepack$RepackResult;
    .registers 7

    and-int/lit8 p6, p5, 0x1

    if-eqz p6, :cond_6

    iget-boolean p1, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->packageOk:Z

    :cond_6
    and-int/lit8 p6, p5, 0x2

    if-eqz p6, :cond_c

    iget-object p2, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->signatureOk:Ljava/lang/Boolean;

    :cond_c
    and-int/lit8 p6, p5, 0x4

    if-eqz p6, :cond_12

    iget-object p3, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->installer:Ljava/lang/String;

    :cond_12
    and-int/lit8 p5, p5, 0x8

    if-eqz p5, :cond_18

    iget-boolean p4, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->allowSensitiveAction:Z

    :cond_18
    invoke-virtual {p0, p1, p2, p3, p4}, Lcom/appcore/runtime/ReaRepack$RepackResult;->copy(ZLjava/lang/Boolean;Ljava/lang/String;Z)Lcom/appcore/runtime/ReaRepack$RepackResult;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()Z
    .registers 2

    iget-boolean v0, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->packageOk:Z

    return v0
.end method

.method public final component2()Ljava/lang/Boolean;
    .registers 2

    iget-object v0, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->signatureOk:Ljava/lang/Boolean;

    return-object v0
.end method

.method public final component3()Ljava/lang/String;
    .registers 2

    iget-object v0, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->installer:Ljava/lang/String;

    return-object v0
.end method

.method public final component4()Z
    .registers 2

    iget-boolean v0, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->allowSensitiveAction:Z

    return v0
.end method

.method public final copy(ZLjava/lang/Boolean;Ljava/lang/String;Z)Lcom/appcore/runtime/ReaRepack$RepackResult;
    .registers 6

    const-string v0, "installer"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    new-instance v0, Lcom/appcore/runtime/ReaRepack$RepackResult;

    invoke-direct {v0, p1, p2, p3, p4}, Lcom/appcore/runtime/ReaRepack$RepackResult;-><init>(ZLjava/lang/Boolean;Ljava/lang/String;Z)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .registers 7

    const/4 v0, 0x1

    if-ne p0, p1, :cond_4

    return v0

    :cond_4
    instance-of v1, p1, Lcom/appcore/runtime/ReaRepack$RepackResult;

    const/4 v2, 0x0

    if-nez v1, :cond_a

    return v2

    :cond_a
    move-object v1, p1

    check-cast v1, Lcom/appcore/runtime/ReaRepack$RepackResult;

    iget-boolean v3, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->packageOk:Z

    iget-boolean v4, v1, Lcom/appcore/runtime/ReaRepack$RepackResult;->packageOk:Z

    if-eq v3, v4, :cond_14

    return v2

    :cond_14
    iget-object v3, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->signatureOk:Ljava/lang/Boolean;

    iget-object v4, v1, Lcom/appcore/runtime/ReaRepack$RepackResult;->signatureOk:Ljava/lang/Boolean;

    invoke-static {v3, v4}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_1f

    return v2

    :cond_1f
    iget-object v3, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->installer:Ljava/lang/String;

    iget-object v4, v1, Lcom/appcore/runtime/ReaRepack$RepackResult;->installer:Ljava/lang/String;

    invoke-static {v3, v4}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_2a

    return v2

    :cond_2a
    iget-boolean v3, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->allowSensitiveAction:Z

    iget-boolean v1, v1, Lcom/appcore/runtime/ReaRepack$RepackResult;->allowSensitiveAction:Z

    if-eq v3, v1, :cond_31

    return v2

    :cond_31
    return v0
.end method

.method public final getAllowSensitiveAction()Z
    .registers 2

    .line 67
    iget-boolean v0, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->allowSensitiveAction:Z

    return v0
.end method

.method public final getInstaller()Ljava/lang/String;
    .registers 2

    .line 66
    iget-object v0, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->installer:Ljava/lang/String;

    return-object v0
.end method

.method public final getPackageOk()Z
    .registers 2

    .line 64
    iget-boolean v0, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->packageOk:Z

    return v0
.end method

.method public final getSignatureOk()Ljava/lang/Boolean;
    .registers 2

    .line 65
    iget-object v0, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->signatureOk:Ljava/lang/Boolean;

    return-object v0
.end method

.method public hashCode()I
    .registers 4

    iget-boolean v0, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->packageOk:Z

    invoke-static {v0}, Ljava/lang/Boolean;->hashCode(Z)I

    move-result v0

    mul-int/lit8 v1, v0, 0x1f

    iget-object v2, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->signatureOk:Ljava/lang/Boolean;

    if-nez v2, :cond_e

    const/4 v2, 0x0

    goto :goto_14

    :cond_e
    iget-object v2, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->signatureOk:Ljava/lang/Boolean;

    invoke-virtual {v2}, Ljava/lang/Object;->hashCode()I

    move-result v2

    :goto_14
    add-int/2addr v1, v2

    mul-int/lit8 v0, v1, 0x1f

    iget-object v2, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->installer:Ljava/lang/String;

    invoke-virtual {v2}, Ljava/lang/String;->hashCode()I

    move-result v2

    add-int/2addr v0, v2

    mul-int/lit8 v1, v0, 0x1f

    iget-boolean v2, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->allowSensitiveAction:Z

    invoke-static {v2}, Ljava/lang/Boolean;->hashCode(Z)I

    move-result v2

    add-int/2addr v1, v2

    return v1
.end method

.method public toString()Ljava/lang/String;
    .registers 3

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "RepackResult(packageOk="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-boolean v1, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->packageOk:Z

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", signatureOk="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->signatureOk:Ljava/lang/Boolean;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", installer="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->installer:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", allowSensitiveAction="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-boolean v1, p0, Lcom/appcore/runtime/ReaRepack$RepackResult;->allowSensitiveAction:Z

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const/16 v1, 0x29

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
