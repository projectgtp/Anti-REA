.class public final enum Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;
.super Ljava/lang/Enum;
.source "ReaIntegrity2.kt"


# annotations
.annotation system Ldalvik/annotation/EnclosingClass;
    value = Lcom/antirea/runtime/ReaIntegrity2;
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x4019
    name = "InstallerOrigin"
.end annotation

.annotation system Ldalvik/annotation/Signature;
    value = {
        "Ljava/lang/Enum<",
        "Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;",
        ">;"
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000\u000c\n\u0002\u0018\u0002\n\u0002\u0010\u0010\n\u0002\u0008\u0005\u0008\u0086\u0081\u0002\u0018\u00002\u0008\u0012\u0004\u0012\u00020\u00000\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003j\u0002\u0008\u0004j\u0002\u0008\u0005j\u0002\u0008\u0006"
    }
    d2 = {
        "Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;",
        "",
        "<init>",
        "(Ljava/lang/String;I)V",
        "PLAY_STORE",
        "THIRD_PARTY",
        "UNKNOWN"
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
.field private static final synthetic $ENTRIES:Lkotlin/enums/EnumEntries;

.field private static final synthetic $VALUES:[Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

.field public static final enum PLAY_STORE:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

.field public static final enum THIRD_PARTY:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

.field public static final enum UNKNOWN:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;


# direct methods
.method private static final synthetic $values()[Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;
    .registers 3

    sget-object v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->PLAY_STORE:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    sget-object v1, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->THIRD_PARTY:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    sget-object v2, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->UNKNOWN:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    filled-new-array {v0, v1, v2}, [Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    move-result-object v0

    return-object v0
.end method

.method static constructor <clinit>()V
    .registers 3

    .line 78
    new-instance v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    const-string v1, "PLAY_STORE"

    const/4 v2, 0x0

    invoke-direct {v0, v1, v2}, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->PLAY_STORE:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    new-instance v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    const-string v1, "THIRD_PARTY"

    const/4 v2, 0x1

    invoke-direct {v0, v1, v2}, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->THIRD_PARTY:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    new-instance v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    const-string v1, "UNKNOWN"

    const/4 v2, 0x2

    invoke-direct {v0, v1, v2}, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;-><init>(Ljava/lang/String;I)V

    sput-object v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->UNKNOWN:Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    invoke-static {}, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->$values()[Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    move-result-object v0

    sput-object v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->$VALUES:[Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    sget-object v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->$VALUES:[Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    check-cast v0, [Ljava/lang/Enum;

    invoke-static {v0}, Lkotlin/enums/EnumEntriesKt;->enumEntries([Ljava/lang/Enum;)Lkotlin/enums/EnumEntries;

    move-result-object v0

    sput-object v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->$ENTRIES:Lkotlin/enums/EnumEntries;

    return-void
.end method

.method private constructor <init>(Ljava/lang/String;I)V
    .registers 3
    .param p1, "$enum$name"    # Ljava/lang/String;
    .param p2, "$enum$ordinal"    # I
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()V"
        }
    .end annotation

    .line 78
    invoke-direct {p0, p1, p2}, Ljava/lang/Enum;-><init>(Ljava/lang/String;I)V

    return-void
.end method

.method public static getEntries()Lkotlin/enums/EnumEntries;
    .registers 1
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "()",
            "Lkotlin/enums/EnumEntries<",
            "Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;",
            ">;"
        }
    .end annotation

    sget-object v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->$ENTRIES:Lkotlin/enums/EnumEntries;

    .line 78
    return-object v0
.end method

.method public static valueOf(Ljava/lang/String;)Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;
    .registers 2
    .param p0, "value"    # Ljava/lang/String;

    const-class v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    invoke-static {v0, p0}, Ljava/lang/Enum;->valueOf(Ljava/lang/Class;Ljava/lang/String;)Ljava/lang/Enum;

    move-result-object v0

    .line 78
    check-cast v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    return-object v0
.end method

.method public static values()[Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;
    .registers 1

    sget-object v0, Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;->$VALUES:[Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    invoke-virtual {v0}, Ljava/lang/Object;->clone()Ljava/lang/Object;

    move-result-object v0

    .line 78
    check-cast v0, [Lcom/antirea/runtime/ReaIntegrity2$InstallerOrigin;

    return-object v0
.end method
