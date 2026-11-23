.class public final Lcom/antirea/runtime/ReaDecoys;
.super Ljava/lang/Object;
.source "ReaTraps.kt"


# annotations
.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u0014\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u000e\n\u0002\u0008\u0003\u0008\u00c6\u0002\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003R\u000e\u0010\u0004\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0007\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0008\u001a\u00020\u0005X\u0086T\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/antirea/runtime/ReaDecoys;",
        "",
        "<init>",
        "()V",
        "FAKE_API_KEY_LABEL",
        "",
        "FAKE_ENDPOINT_LABEL",
        "FAKE_TOKEN_LABEL",
        "MARKER"
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
.field public static final FAKE_API_KEY_LABEL:Ljava/lang/String; = "antirea-decoy-api-key"

.field public static final FAKE_ENDPOINT_LABEL:Ljava/lang/String; = "antirea-decoy-endpoint"

.field public static final FAKE_TOKEN_LABEL:Ljava/lang/String; = "antirea-decoy-token"

.field public static final INSTANCE:Lcom/antirea/runtime/ReaDecoys;

.field public static final MARKER:Ljava/lang/String; = "antirea-decoy"


# direct methods
.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/antirea/runtime/ReaDecoys;

    invoke-direct {v0}, Lcom/antirea/runtime/ReaDecoys;-><init>()V

    sput-object v0, Lcom/antirea/runtime/ReaDecoys;->INSTANCE:Lcom/antirea/runtime/ReaDecoys;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 109
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method
