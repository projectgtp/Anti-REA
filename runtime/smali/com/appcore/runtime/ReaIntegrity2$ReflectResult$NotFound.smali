.class public final Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;
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
    name = "NotFound"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u000c\n\u0002\u0018\u0002\n\u0002\u0018\u0002\n\u0002\u0008\u0002\u0008\u00c6\u0002\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;",
        "Lcom/appcore/runtime/ReaIntegrity2$ReflectResult;",
        "<init>",
        "()V"
    }
    k = 0x1
    mv = {
        0x2,
        0x0,
        0x0
    }
    xi = 0x30
.end annotation


# static fields
.field public static final INSTANCE:Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;


# direct methods
.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;

    invoke-direct {v0}, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;-><init>()V

    sput-object v0, Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;->INSTANCE:Lcom/appcore/runtime/ReaIntegrity2$ReflectResult$NotFound;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 373
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
