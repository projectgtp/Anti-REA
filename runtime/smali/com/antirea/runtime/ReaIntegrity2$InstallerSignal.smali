.class public final Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;
.super Ljava/lang/Object;
.source "ReaIntegrity2.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/antirea/runtime/ReaIntegrity2;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "InstallerSignal"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000$\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\u000e\n\u0000\n\u0002\u0010\u000b\n\u0002\u0008\u0011\n\u0002\u0010\u0008\n\u0000\u0008\u0086\u0008\u0018\u00002\u00020\u0001B+\u0012\u0006\u0010\u0002\u001a\u00020\u0003\u0012\u0008\u0010\u0004\u001a\u0004\u0018\u00010\u0005\u0012\u0006\u0010\u0006\u001a\u00020\u0007\u0012\u0008\u0008\u0002\u0010\u0008\u001a\u00020\u0007\u00a2\u0006\u0004\u0008\t\u0010\nJ\t\u0010\u0011\u001a\u00020\u0003H\u00c6\u0003J\u000b\u0010\u0012\u001a\u0004\u0018\u00010\u0005H\u00c6\u0003J\t\u0010\u0013\u001a\u00020\u0007H\u00c6\u0003J\t\u0010\u0014\u001a\u00020\u0007H\u00c6\u0003J3\u0010\u0015\u001a\u00020\u00002\u0008\u0008\u0002\u0010\u0002\u001a\u00020\u00032\n\u0008\u0002\u0010\u0004\u001a\u0004\u0018\u00010\u00052\u0008\u0008\u0002\u0010\u0006\u001a\u00020\u00072\u0008\u0008\u0002\u0010\u0008\u001a\u00020\u0007H\u00c6\u0001J\u0013\u0010\u0016\u001a\u00020\u00072\u0008\u0010\u0017\u001a\u0004\u0018\u00010\u0001H\u00d6\u0003J\t\u0010\u0018\u001a\u00020\u0019H\u00d6\u0001J\t\u0010\u001a\u001a\u00020\u0005H\u00d6\u0001R\u0011\u0010\u0002\u001a\u00020\u0003\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u000b\u0010\u000cR\u0013\u0010\u0004\u001a\u0004\u0018\u00010\u0005\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\r\u0010\u000eR\u0011\u0010\u0006\u001a\u00020\u0007\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0006\u0010\u000fR\u0011\u0010\u0008\u001a\u00020\u0007\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0010\u0010\u000f"
    }
    d2 = {
        "Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;",
        "",
        "origin",
        "Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;",
        "installerPackage",
        "",
        "isPlayStore",
        "",
        "signalOnly",
        "<init>",
        "(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZ)V",
        "getOrigin",
        "()Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;",
        "getInstallerPackage",
        "()Ljava/lang/String;",
        "()Z",
        "getSignalOnly",
        "component1",
        "component2",
        "component3",
        "component4",
        "copy",
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
.field private final installerPackage:Ljava/lang/String;

.field private final isPlayStore:Z

.field private final origin:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

.field private final signalOnly:Z


# direct methods
.method public constructor <init>(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZ)V
    .registers 6
    .param p1, "origin"    # Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;
    .param p2, "installerPackage"    # Ljava/lang/String;
    .param p3, "isPlayStore"    # Z
    .param p4, "signalOnly"    # Z

    const-string v0, "origin"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 89
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    .line 90
    iput-object p1, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->origin:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    .line 91
    iput-object p2, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->installerPackage:Ljava/lang/String;

    .line 92
    iput-boolean p3, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->isPlayStore:Z

    .line 94
    iput-boolean p4, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->signalOnly:Z

    .line 89
    return-void
.end method

.method public synthetic constructor <init>(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZILkotlin/jvm/internal/DefaultConstructorMarker;)V
    .registers 7

    .line 89
    and-int/lit8 p5, p5, 0x8

    if-eqz p5, :cond_5

    .line 94
    const/4 p4, 0x1

    .line 89
    :cond_5
    invoke-direct {p0, p1, p2, p3, p4}, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;-><init>(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZ)V

    .line 95
    return-void
.end method

.method public static synthetic copy$default(Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZILjava/lang/Object;)Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;
    .registers 7

    and-int/lit8 p6, p5, 0x1

    if-eqz p6, :cond_6

    iget-object p1, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->origin:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    :cond_6
    and-int/lit8 p6, p5, 0x2

    if-eqz p6, :cond_c

    iget-object p2, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->installerPackage:Ljava/lang/String;

    :cond_c
    and-int/lit8 p6, p5, 0x4

    if-eqz p6, :cond_12

    iget-boolean p3, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->isPlayStore:Z

    :cond_12
    and-int/lit8 p5, p5, 0x8

    if-eqz p5, :cond_18

    iget-boolean p4, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->signalOnly:Z

    :cond_18
    invoke-virtual {p0, p1, p2, p3, p4}, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->copy(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZ)Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;

    move-result-object p0

    return-object p0
.end method


# virtual methods
.method public final component1()Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;
    .registers 2

    iget-object v0, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->origin:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    return-object v0
.end method

.method public final component2()Ljava/lang/String;
    .registers 2

    iget-object v0, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->installerPackage:Ljava/lang/String;

    return-object v0
.end method

.method public final component3()Z
    .registers 2

    iget-boolean v0, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->isPlayStore:Z

    return v0
.end method

.method public final component4()Z
    .registers 2

    iget-boolean v0, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->signalOnly:Z

    return v0
.end method

.method public final copy(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZ)Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;
    .registers 6

    const-string v0, "origin"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    new-instance v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;

    invoke-direct {v0, p1, p2, p3, p4}, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;-><init>(Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;Ljava/lang/String;ZZ)V

    return-object v0
.end method

.method public equals(Ljava/lang/Object;)Z
    .registers 7

    const/4 v0, 0x1

    if-ne p0, p1, :cond_4

    return v0

    :cond_4
    instance-of v1, p1, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;

    const/4 v2, 0x0

    if-nez v1, :cond_a

    return v2

    :cond_a
    move-object v1, p1

    check-cast v1, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;

    iget-object v3, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->origin:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    iget-object v4, v1, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->origin:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    if-eq v3, v4, :cond_14

    return v2

    :cond_14
    iget-object v3, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->installerPackage:Ljava/lang/String;

    iget-object v4, v1, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->installerPackage:Ljava/lang/String;

    invoke-static {v3, v4}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v3

    if-nez v3, :cond_1f

    return v2

    :cond_1f
    iget-boolean v3, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->isPlayStore:Z

    iget-boolean v4, v1, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->isPlayStore:Z

    if-eq v3, v4, :cond_26

    return v2

    :cond_26
    iget-boolean v3, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->signalOnly:Z

    iget-boolean v1, v1, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->signalOnly:Z

    if-eq v3, v1, :cond_2d

    return v2

    :cond_2d
    return v0
.end method

.method public final getInstallerPackage()Ljava/lang/String;
    .registers 2

    .line 91
    iget-object v0, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->installerPackage:Ljava/lang/String;

    return-object v0
.end method

.method public final getOrigin()Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;
    .registers 2

    .line 90
    iget-object v0, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->origin:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    return-object v0
.end method

.method public final getSignalOnly()Z
    .registers 2

    .line 94
    iget-boolean v0, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->signalOnly:Z

    return v0
.end method

.method public hashCode()I
    .registers 4

    iget-object v0, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->origin:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    invoke-virtual {v0}, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->hashCode()I

    move-result v0

    mul-int/lit8 v1, v0, 0x1f

    iget-object v2, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->installerPackage:Ljava/lang/String;

    if-nez v2, :cond_e

    const/4 v2, 0x0

    goto :goto_14

    :cond_e
    iget-object v2, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->installerPackage:Ljava/lang/String;

    invoke-virtual {v2}, Ljava/lang/String;->hashCode()I

    move-result v2

    :goto_14
    add-int/2addr v1, v2

    mul-int/lit8 v0, v1, 0x1f

    iget-boolean v2, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->isPlayStore:Z

    invoke-static {v2}, Ljava/lang/Boolean;->hashCode(Z)I

    move-result v2

    add-int/2addr v0, v2

    mul-int/lit8 v1, v0, 0x1f

    iget-boolean v2, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->signalOnly:Z

    invoke-static {v2}, Ljava/lang/Boolean;->hashCode(Z)I

    move-result v2

    add-int/2addr v1, v2

    return v1
.end method

.method public final isPlayStore()Z
    .registers 2

    .line 92
    iget-boolean v0, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->isPlayStore:Z

    return v0
.end method

.method public toString()Ljava/lang/String;
    .registers 3

    new-instance v0, Ljava/lang/StringBuilder;

    invoke-direct {v0}, Ljava/lang/StringBuilder;-><init>()V

    const-string v1, "InstallerSignal(origin="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->origin:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", installerPackage="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-object v1, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->installerPackage:Ljava/lang/String;

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", isPlayStore="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-boolean v1, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->isPlayStore:Z

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const-string v1, ", signalOnly="

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v0

    iget-boolean v1, p0, Lcom/antirea/runtime/ReaIntegrity2$InstallerSignal;->signalOnly:Z

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(Z)Ljava/lang/StringBuilder;

    move-result-object v0

    const/16 v1, 0x29

    invoke-virtual {v0, v1}, Ljava/lang/StringBuilder;->append(C)Ljava/lang/StringBuilder;

    move-result-object v0

    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    return-object v0
.end method
