.class public final Lcom/antirea/runtime/ReaMemory;
.super Ljava/lang/Object;
.source "ReaMemory.kt"


# annotations
.annotation system Ldalvik/annotation/MemberClasses;
    value = {
        Lcom/antirea/runtime/ReaMemory$ObfuscatedInt;,
        Lcom/antirea/runtime/ReaMemory$ObfuscatedLong;
    }
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000&\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0018\u0002\n\u0000\n\u0002\u0010\t\n\u0000\n\u0002\u0010\u0008\n\u0000\n\u0002\u0010\u0012\n\u0002\u0008\u0008\u0008\u00c6\u0002\u0018\u00002\u00020\u0001:\u0002\u0012\u0013B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J\u0008\u0010\u0006\u001a\u00020\u0007H\u0002J\u0008\u0010\u0008\u001a\u00020\tH\u0002J\u0010\u0010\n\u001a\u00020\u000b2\u0006\u0010\u000c\u001a\u00020\u0007H\u0002J\u0010\u0010\r\u001a\u00020\u000b2\u0006\u0010\u000c\u001a\u00020\tH\u0002J\u0018\u0010\u000e\u001a\u00020\u00072\u0006\u0010\u000f\u001a\u00020\u00072\u0006\u0010\u0010\u001a\u00020\u0007H\u0002J\u0018\u0010\u0011\u001a\u00020\u00072\u0006\u0010\u000f\u001a\u00020\t2\u0006\u0010\u0010\u001a\u00020\u0007H\u0002R\u000e\u0010\u0004\u001a\u00020\u0005X\u0082\u0004\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/antirea/runtime/ReaMemory;",
        "",
        "<init>",
        "()V",
        "random",
        "Ljava/security/SecureRandom;",
        "randomLong",
        "",
        "randomInt",
        "",
        "longToBytes",
        "",
        "v",
        "intToBytes",
        "checksumLong",
        "value",
        "salt",
        "checksumInt",
        "ObfuscatedLong",
        "ObfuscatedInt"
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
.field public static final INSTANCE:Lcom/antirea/runtime/ReaMemory;

.field private static final random:Ljava/security/SecureRandom;


# direct methods
.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/antirea/runtime/ReaMemory;

    invoke-direct {v0}, Lcom/antirea/runtime/ReaMemory;-><init>()V

    sput-object v0, Lcom/antirea/runtime/ReaMemory;->INSTANCE:Lcom/antirea/runtime/ReaMemory;

    .line 58
    new-instance v0, Ljava/security/SecureRandom;

    invoke-direct {v0}, Ljava/security/SecureRandom;-><init>()V

    sput-object v0, Lcom/antirea/runtime/ReaMemory;->random:Ljava/security/SecureRandom;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 56
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method public static final synthetic access$checksumInt(Lcom/antirea/runtime/ReaMemory;IJ)J
    .registers 6
    .param p0, "$this"    # Lcom/antirea/runtime/ReaMemory;
    .param p1, "value"    # I
    .param p2, "salt"    # J

    .line 56
    invoke-direct {p0, p1, p2, p3}, Lcom/antirea/runtime/ReaMemory;->checksumInt(IJ)J

    move-result-wide v0

    return-wide v0
.end method

.method public static final synthetic access$checksumLong(Lcom/antirea/runtime/ReaMemory;JJ)J
    .registers 7
    .param p0, "$this"    # Lcom/antirea/runtime/ReaMemory;
    .param p1, "value"    # J
    .param p3, "salt"    # J

    .line 56
    invoke-direct {p0, p1, p2, p3, p4}, Lcom/antirea/runtime/ReaMemory;->checksumLong(JJ)J

    move-result-wide v0

    return-wide v0
.end method

.method public static final synthetic access$randomInt(Lcom/antirea/runtime/ReaMemory;)I
    .registers 2
    .param p0, "$this"    # Lcom/antirea/runtime/ReaMemory;

    .line 56
    invoke-direct {p0}, Lcom/antirea/runtime/ReaMemory;->randomInt()I

    move-result v0

    return v0
.end method

.method public static final synthetic access$randomLong(Lcom/antirea/runtime/ReaMemory;)J
    .registers 3
    .param p0, "$this"    # Lcom/antirea/runtime/ReaMemory;

    .line 56
    invoke-direct {p0}, Lcom/antirea/runtime/ReaMemory;->randomLong()J

    move-result-wide v0

    return-wide v0
.end method

.method private final checksumInt(IJ)J
    .registers 15
    .param p1, "value"    # I
    .param p2, "salt"    # J

    .line 101
    const-string v0, "SHA-256"

    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v0

    .line 102
    .local v0, "digest":Ljava/security/MessageDigest;
    invoke-direct {p0, p2, p3}, Lcom/antirea/runtime/ReaMemory;->longToBytes(J)[B

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/security/MessageDigest;->update([B)V

    .line 103
    invoke-direct {p0, p1}, Lcom/antirea/runtime/ReaMemory;->intToBytes(I)[B

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/security/MessageDigest;->update([B)V

    .line 104
    invoke-virtual {v0}, Ljava/security/MessageDigest;->digest()[B

    move-result-object v1

    .line 105
    .local v1, "hash":[B
    const-wide/16 v2, 0x0

    .line 106
    .local v2, "v":J
    const/4 v4, 0x0

    .local v4, "i":I
    :goto_1b
    const/16 v5, 0x8

    if-ge v4, v5, :cond_2c

    shl-long v5, v2, v5

    aget-byte v7, v1, v4

    int-to-long v7, v7

    const-wide/16 v9, 0xff

    and-long/2addr v7, v9

    or-long v2, v5, v7

    add-int/lit8 v4, v4, 0x1

    goto :goto_1b

    .line 107
    .end local v4    # "i":I
    :cond_2c
    return-wide v2
.end method

.method private final checksumLong(JJ)J
    .registers 16
    .param p1, "value"    # J
    .param p3, "salt"    # J

    .line 90
    const-string v0, "SHA-256"

    invoke-static {v0}, Ljava/security/MessageDigest;->getInstance(Ljava/lang/String;)Ljava/security/MessageDigest;

    move-result-object v0

    .line 91
    .local v0, "digest":Ljava/security/MessageDigest;
    invoke-direct {p0, p3, p4}, Lcom/antirea/runtime/ReaMemory;->longToBytes(J)[B

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/security/MessageDigest;->update([B)V

    .line 92
    invoke-direct {p0, p1, p2}, Lcom/antirea/runtime/ReaMemory;->longToBytes(J)[B

    move-result-object v1

    invoke-virtual {v0, v1}, Ljava/security/MessageDigest;->update([B)V

    .line 93
    invoke-virtual {v0}, Ljava/security/MessageDigest;->digest()[B

    move-result-object v1

    .line 94
    .local v1, "hash":[B
    const-wide/16 v2, 0x0

    .line 95
    .local v2, "v":J
    const/4 v4, 0x0

    .local v4, "i":I
    :goto_1b
    const/16 v5, 0x8

    if-ge v4, v5, :cond_2c

    shl-long v5, v2, v5

    aget-byte v7, v1, v4

    int-to-long v7, v7

    const-wide/16 v9, 0xff

    and-long/2addr v7, v9

    or-long v2, v5, v7

    add-int/lit8 v4, v4, 0x1

    goto :goto_1b

    .line 96
    .end local v4    # "i":I
    :cond_2c
    return-wide v2
.end method

.method private final intToBytes(I)[B
    .registers 6
    .param p1, "v"    # I

    .line 83
    const/4 v0, 0x4

    new-array v1, v0, [B

    .line 84
    .local v1, "out":[B
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_4
    if-ge v2, v0, :cond_14

    mul-int/lit8 v3, v2, 0x8

    rsub-int/lit8 v3, v3, 0x18

    ushr-int v3, p1, v3

    and-int/lit16 v3, v3, 0xff

    int-to-byte v3, v3

    aput-byte v3, v1, v2

    add-int/lit8 v2, v2, 0x1

    goto :goto_4

    .line 85
    .end local v2    # "i":I
    :cond_14
    return-object v1
.end method

.method private final longToBytes(J)[B
    .registers 10
    .param p1, "v"    # J

    .line 77
    const/16 v0, 0x8

    new-array v1, v0, [B

    .line 78
    .local v1, "out":[B
    const/4 v2, 0x0

    .local v2, "i":I
    :goto_5
    if-ge v2, v0, :cond_17

    mul-int/lit8 v3, v2, 0x8

    rsub-int/lit8 v3, v3, 0x38

    ushr-long v3, p1, v3

    const-wide/16 v5, 0xff

    and-long/2addr v3, v5

    long-to-int v3, v3

    int-to-byte v3, v3

    aput-byte v3, v1, v2

    add-int/lit8 v2, v2, 0x1

    goto :goto_5

    .line 79
    .end local v2    # "i":I
    :cond_17
    return-object v1
.end method

.method private final randomInt()I
    .registers 8

    .line 69
    const/4 v0, 0x4

    new-array v0, v0, [B

    .line 70
    .local v0, "b":[B
    sget-object v1, Lcom/antirea/runtime/ReaMemory;->random:Ljava/security/SecureRandom;

    invoke-virtual {v1, v0}, Ljava/security/SecureRandom;->nextBytes([B)V

    .line 71
    const/4 v1, 0x0

    .line 72
    .local v1, "v":I
    array-length v2, v0

    const/4 v3, 0x0

    :goto_b
    if-ge v3, v2, :cond_18

    aget-byte v4, v0, v3

    .local v4, "x":B
    shl-int/lit8 v5, v1, 0x8

    and-int/lit16 v6, v4, 0xff

    or-int v1, v5, v6

    .end local v4    # "x":B
    add-int/lit8 v3, v3, 0x1

    goto :goto_b

    .line 73
    :cond_18
    return v1
.end method

.method private final randomLong()J
    .registers 14

    .line 61
    const/16 v0, 0x8

    new-array v1, v0, [B

    .line 62
    .local v1, "b":[B
    sget-object v2, Lcom/antirea/runtime/ReaMemory;->random:Ljava/security/SecureRandom;

    invoke-virtual {v2, v1}, Ljava/security/SecureRandom;->nextBytes([B)V

    .line 63
    const-wide/16 v2, 0x0

    .line 64
    .local v2, "v":J
    array-length v4, v1

    const/4 v5, 0x0

    :goto_d
    if-ge v5, v4, :cond_1c

    aget-byte v6, v1, v5

    .local v6, "x":B
    shl-long v7, v2, v0

    int-to-long v9, v6

    const-wide/16 v11, 0xff

    and-long/2addr v9, v11

    or-long v2, v7, v9

    .end local v6    # "x":B
    add-int/lit8 v5, v5, 0x1

    goto :goto_d

    .line 65
    :cond_1c
    return-wide v2
.end method
