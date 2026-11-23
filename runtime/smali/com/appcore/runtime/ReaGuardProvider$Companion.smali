.class public final Lcom/appcore/runtime/ReaGuardProvider$Companion;
.super Ljava/lang/Object;
.source "ReaGuardProvider.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/appcore/runtime/ReaGuardProvider;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x19
    name = "Companion"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000 \n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010 \n\u0002\u0018\u0002\n\u0002\u0008\u0003\n\u0002\u0010\u000b\n\u0002\u0008\u0007\u0008\u0086\u0003\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003R*\u0010\u0007\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u00052\u000c\u0010\u0004\u001a\u0008\u0012\u0004\u0012\u00020\u00060\u0005@BX\u0086\u000e\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0008\u0010\tR$\u0010\u000b\u001a\u0004\u0018\u00010\n2\u0008\u0010\u0004\u001a\u0004\u0018\u00010\n@BX\u0086\u000e\u00a2\u0006\n\n\u0002\u0010\u000e\u001a\u0004\u0008\u000c\u0010\rR\u001e\u0010\u000f\u001a\u00020\n2\u0006\u0010\u0004\u001a\u00020\n@BX\u0086\u000e\u00a2\u0006\u0008\n\u0000\u001a\u0004\u0008\u0010\u0010\u0011"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaGuardProvider$Companion;",
        "",
        "<init>",
        "()V",
        "value",
        "",
        "Lcom/appcore/runtime/ReaEnv$Finding;",
        "findings",
        "getFindings",
        "()Ljava/util/List;",
        "",
        "dexCheckPassed",
        "getDexCheckPassed",
        "()Ljava/lang/Boolean;",
        "Ljava/lang/Boolean;",
        "initialized",
        "getInitialized",
        "()Z"
    }
    k = 0x1
    mv = {
        0x2,
        0x0,
        0x0
    }
    xi = 0x30
.end annotation


# direct methods
.method private constructor <init>()V
    .registers 1

    .line 52
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public synthetic constructor <init>(Lkotlin/jvm/internal/DefaultConstructorMarker;)V
    .registers 2

    invoke-direct {p0}, Lcom/appcore/runtime/ReaGuardProvider$Companion;-><init>()V

    return-void
.end method


# virtual methods
.method public final getDexCheckPassed()Ljava/lang/Boolean;
    .registers 2

    .line 63
    # getter for: Lcom/appcore/runtime/ReaGuardProvider;->dexCheckPassed:Ljava/lang/Boolean;
    invoke-static {}, Lcom/appcore/runtime/ReaGuardProvider;->access$getDexCheckPassed$cp()Ljava/lang/Boolean;

    move-result-object v0

    return-object v0
.end method

.method public final getFindings()Ljava/util/List;
    .registers 2
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Ljava/util/List<",
            "Lcom/appcore/runtime/ReaEnv$Finding;",
            ">;"
        }
    .end annotation

    .line 54
    # getter for: Lcom/appcore/runtime/ReaGuardProvider;->findings:Ljava/util/List;
    invoke-static {}, Lcom/appcore/runtime/ReaGuardProvider;->access$getFindings$cp()Ljava/util/List;

    move-result-object v0

    return-object v0
.end method

.method public final getInitialized()Z
    .registers 2

    .line 68
    # getter for: Lcom/appcore/runtime/ReaGuardProvider;->initialized:Z
    invoke-static {}, Lcom/appcore/runtime/ReaGuardProvider;->access$getInitialized$cp()Z

    move-result v0

    return v0
.end method
