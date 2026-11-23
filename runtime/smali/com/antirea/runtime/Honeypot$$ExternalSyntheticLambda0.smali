.class public final synthetic Lcom/antirea/runtime/Honeypot$$ExternalSyntheticLambda0;
.super Ljava/lang/Object;
.source "D8$$SyntheticClass"

# interfaces
.implements Lkotlin/jvm/functions/Function1;


# direct methods
.method public synthetic constructor <init>()V
    .registers 1

    .line 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public final invoke(Ljava/lang/Object;)Ljava/lang/Object;
    .registers 2

    .line 0
    check-cast p1, Lcom/antirea/runtime/TripwireEvent;

    invoke-static {p1}, Lcom/antirea/runtime/Honeypot;->$r8$lambda$h7MHvMOo3G1vcz7vkyrNWe8IIvk(Lcom/antirea/runtime/TripwireEvent;)Lkotlin/Unit;

    move-result-object p1

    return-object p1
.end method
