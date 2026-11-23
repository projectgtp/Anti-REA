.class public final Lcom/appcore/runtime/ReaMethodLoader;
.super Ljava/lang/Object;
.source "ReaMethodLoader.kt"


# annotations
.annotation system Ldalvik/annotation/SourceDebugExtension;
    value = "SMAP\nReaMethodLoader.kt\nKotlin\n*S Kotlin\n*F\n+ 1 ReaMethodLoader.kt\ncom/appcore/runtime/ReaMethodLoader\n+ 2 _Arrays.kt\nkotlin/collections/ArraysKt___ArraysKt\n+ 3 _Collections.kt\nkotlin/collections/CollectionsKt___CollectionsKt\n*L\n1#1,249:1\n3829#2:250\n4344#2,2:251\n295#3:253\n1734#3,3:254\n296#3:257\n*S KotlinDebug\n*F\n+ 1 ReaMethodLoader.kt\ncom/appcore/runtime/ReaMethodLoader\n*L\n143#1:250\n143#1:251,2\n144#1:253\n146#1:254,3\n144#1:257\n*E\n"
.end annotation

.annotation runtime Lkotlin/Metadata;
    d1 = {
        "\u0000H\n\u0002\u0018\u0002\n\u0002\u0010\u0000\n\u0002\u0008\u0003\n\u0002\u0010\u000e\n\u0002\u0008\u0002\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0004\n\u0002\u0010\u0011\n\u0002\u0008\u0003\n\u0002\u0010\u0012\n\u0000\n\u0002\u0010\u000b\n\u0000\n\u0002\u0018\u0002\n\u0002\u0008\u0005\n\u0002\u0010\u0002\u0008\u00c6\u0002\u0018\u00002\u00020\u0001B\t\u0008\u0002\u00a2\u0006\u0004\u0008\u0002\u0010\u0003J$\u0010\u0007\u001a\u0008\u0012\u0002\u0008\u0003\u0018\u00010\u00082\u0006\u0010\t\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\u000c2\u0006\u0010\r\u001a\u00020\u0005JE\u0010\u000e\u001a\u0004\u0018\u00010\u00012\u0006\u0010\t\u001a\u00020\n2\u0006\u0010\u000b\u001a\u00020\u000c2\u0006\u0010\r\u001a\u00020\u00052\u0006\u0010\u000f\u001a\u00020\u00052\u0016\u0010\u0010\u001a\u000c\u0012\u0008\u0008\u0001\u0012\u0004\u0018\u00010\u00010\u0011\"\u0004\u0018\u00010\u0001\u00a2\u0006\u0002\u0010\u0012J\u0018\u0010\u0013\u001a\u0004\u0018\u00010\u000c2\u0006\u0010\u000b\u001a\u00020\u000c2\u0006\u0010\u0014\u001a\u00020\u0015J\u001d\u0010\u0016\u001a\u00020\u00172\u0006\u0010\u0018\u001a\u00020\u00192\u0006\u0010\u001a\u001a\u00020\u0015H\u0000\u00a2\u0006\u0002\u0008\u001bJ\u001a\u0010\u001c\u001a\u0004\u0018\u00010\u00192\u0006\u0010\t\u001a\u00020\n2\u0006\u0010\u001a\u001a\u00020\u0015H\u0002J\u0012\u0010\u001d\u001a\u0004\u0018\u00010\u00192\u0006\u0010\t\u001a\u00020\nH\u0002J\u0012\u0010\u001e\u001a\u00020\u001f2\u0008\u0010\u0018\u001a\u0004\u0018\u00010\u0019H\u0002R\u000e\u0010\u0004\u001a\u00020\u0005X\u0082T\u00a2\u0006\u0002\n\u0000R\u000e\u0010\u0006\u001a\u00020\u0005X\u0082T\u00a2\u0006\u0002\n\u0000"
    }
    d2 = {
        "Lcom/appcore/runtime/ReaMethodLoader;",
        "",
        "<init>",
        "()V",
        "PLAINTEXT_DIR",
        "",
        "OPT_DIR",
        "loadClass",
        "Ljava/lang/Class;",
        "context",
        "Landroid/content/Context;",
        "sealed",
        "Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;",
        "className",
        "loadAndInvoke",
        "methodName",
        "args",
        "",
        "(Landroid/content/Context;Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;",
        "rotateStored",
        "newKey",
        "",
        "writePlaintextFile",
        "",
        "file",
        "Ljava/io/File;",
        "plain",
        "writePlaintextFile$main",
        "writePlaintextDex",
        "optimizedDir",
        "deleteQuietly",
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


# static fields
.field public static final INSTANCE:Lcom/appcore/runtime/ReaMethodLoader;

.field private static final OPT_DIR:Ljava/lang/String; = "rea-opt"

.field private static final PLAINTEXT_DIR:Ljava/lang/String; = "rea-methods"


# direct methods
.method static constructor <clinit>()V
    .registers 1

    new-instance v0, Lcom/appcore/runtime/ReaMethodLoader;

    invoke-direct {v0}, Lcom/appcore/runtime/ReaMethodLoader;-><init>()V

    sput-object v0, Lcom/appcore/runtime/ReaMethodLoader;->INSTANCE:Lcom/appcore/runtime/ReaMethodLoader;

    return-void
.end method

.method private constructor <init>()V
    .registers 1

    .line 69
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method

.method private final deleteQuietly(Ljava/io/File;)V
    .registers 3
    .param p1, "file"    # Ljava/io/File;

    .line 242
    nop

    .line 243
    if-eqz p1, :cond_8

    :try_start_3
    invoke-virtual {p1}, Ljava/io/File;->delete()Z
    :try_end_6
    .catch Ljava/lang/Exception; {:try_start_3 .. :try_end_6} :catch_7

    goto :goto_8

    .line 244
    :catch_7
    move-exception v0

    .line 247
    :cond_8
    :goto_8
    return-void
.end method

.method private final optimizedDir(Landroid/content/Context;)Ljava/io/File;
    .registers 6
    .param p1, "context"    # Landroid/content/Context;

    .line 230
    nop

    .line 231
    const/4 v0, 0x0

    :try_start_2
    invoke-virtual {p1}, Landroid/content/Context;->getCodeCacheDir()Ljava/io/File;

    move-result-object v1

    if-nez v1, :cond_13

    .line 232
    new-instance v1, Ljava/io/File;

    invoke-virtual {p1}, Landroid/content/Context;->getFilesDir()Ljava/io/File;

    move-result-object v2

    const-string v3, "rea-opt"

    invoke-direct {v1, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 231
    :cond_13
    nop

    .line 233
    .local v1, "dir":Ljava/io/File;
    invoke-virtual {v1}, Ljava/io/File;->isDirectory()Z

    move-result v2

    if-nez v2, :cond_21

    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    move-result v2
    :try_end_1e
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_1e} :catch_23

    if-nez v2, :cond_21

    return-object v0

    .line 234
    :cond_21
    move-object v0, v1

    .end local v1    # "dir":Ljava/io/File;
    goto :goto_25

    .line 235
    :catch_23
    move-exception v1

    .line 236
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 230
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_25
    return-object v0
.end method

.method private final writePlaintextDex(Landroid/content/Context;[B)Ljava/io/File;
    .registers 8
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "plain"    # [B

    .line 217
    nop

    .line 218
    const/4 v0, 0x0

    :try_start_2
    new-instance v1, Ljava/io/File;

    invoke-virtual {p1}, Landroid/content/Context;->getFilesDir()Ljava/io/File;

    move-result-object v2

    const-string v3, "rea-methods"

    invoke-direct {v1, v2, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 219
    .local v1, "dir":Ljava/io/File;
    invoke-virtual {v1}, Ljava/io/File;->isDirectory()Z

    move-result v2

    if-nez v2, :cond_1a

    invoke-virtual {v1}, Ljava/io/File;->mkdirs()Z

    move-result v2

    if-nez v2, :cond_1a

    return-object v0

    .line 220
    :cond_1a
    new-instance v2, Ljava/io/File;

    new-instance v3, Ljava/lang/StringBuilder;

    invoke-direct {v3}, Ljava/lang/StringBuilder;-><init>()V

    const-string v4, "rea-method-"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-static {}, Ljava/util/UUID;->randomUUID()Ljava/util/UUID;

    move-result-object v4

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

    move-result-object v3

    const-string v4, ".dex"

    invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v3

    invoke-direct {v2, v1, v3}, Ljava/io/File;-><init>(Ljava/io/File;Ljava/lang/String;)V

    .line 221
    .local v2, "file":Ljava/io/File;
    invoke-virtual {p0, v2, p2}, Lcom/appcore/runtime/ReaMethodLoader;->writePlaintextFile$main(Ljava/io/File;[B)Z

    move-result v3
    :try_end_40
    .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_40} :catch_45

    if-nez v3, :cond_43

    return-object v0

    .line 222
    :cond_43
    move-object v0, v2

    .end local v1    # "dir":Ljava/io/File;
    .end local v2    # "file":Ljava/io/File;
    goto :goto_47

    .line 223
    :catch_45
    move-exception v1

    .line 224
    .local v1, "e":Ljava/lang/Exception;
    nop

    .line 217
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_47
    return-object v0
.end method


# virtual methods
.method public final varargs loadAndInvoke(Landroid/content/Context;Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/Object;
    .registers 29
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "sealed"    # Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    .param p3, "className"    # Ljava/lang/String;
    .param p4, "methodName"    # Ljava/lang/String;
    .param p5, "args"    # [Ljava/lang/Object;

    move-object/from16 v1, p3

    move-object/from16 v2, p4

    move-object/from16 v3, p5

    const-string v0, "context"

    move-object/from16 v4, p1

    invoke-static {v4, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "sealed"

    move-object/from16 v5, p2

    invoke-static {v5, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "className"

    invoke-static {v1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "methodName"

    invoke-static {v2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "args"

    invoke-static {v3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 139
    move-object v0, v1

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v0

    const/4 v6, 0x0

    if-nez v0, :cond_178

    move-object v0, v2

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v0

    if-eqz v0, :cond_38

    goto/16 :goto_178

    .line 140
    :cond_38
    invoke-virtual/range {p0 .. p3}, Lcom/appcore/runtime/ReaMethodLoader;->loadClass(Landroid/content/Context;Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;Ljava/lang/String;)Ljava/lang/Class;

    move-result-object v0

    if-nez v0, :cond_3f

    return-object v6

    :cond_3f
    move-object v7, v0

    .line 141
    .local v7, "clazz":Ljava/lang/Class;
    nop

    .line 142
    :try_start_41
    invoke-virtual {v7}, Ljava/lang/Class;->getMethods()[Ljava/lang/reflect/Method;

    move-result-object v0

    const-string v8, "getMethods(...)"

    invoke-static {v0, v8}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    check-cast v0, [Ljava/lang/Object;

    invoke-virtual {v7}, Ljava/lang/Class;->getDeclaredMethods()[Ljava/lang/reflect/Method;

    move-result-object v8

    const-string v9, "getDeclaredMethods(...)"

    invoke-static {v8, v9}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullExpressionValue(Ljava/lang/Object;Ljava/lang/String;)V

    check-cast v8, [Ljava/lang/Object;

    invoke-static {v0, v8}, Lkotlin/collections/ArraysKt;->plus([Ljava/lang/Object;[Ljava/lang/Object;)[Ljava/lang/Object;

    move-result-object v0

    .line 143
    nop

    .local v0, "$this$filter$iv":[Ljava/lang/Object;
    const/4 v8, 0x0

    .line 250
    .local v8, "$i$f$filter":I
    new-instance v9, Ljava/util/ArrayList;

    invoke-direct {v9}, Ljava/util/ArrayList;-><init>()V

    check-cast v9, Ljava/util/Collection;

    .local v9, "destination$iv$iv":Ljava/util/Collection;
    move-object v10, v0

    .local v10, "$this$filterTo$iv$iv":[Ljava/lang/Object;
    const/4 v11, 0x0

    .line 251
    .local v11, "$i$f$filterTo":I
    array-length v12, v10
    :try_end_67
    .catch Ljava/lang/Exception; {:try_start_41 .. :try_end_67} :catch_175

    const/4 v14, 0x0

    :goto_68
    if-ge v14, v12, :cond_a0

    :try_start_6a
    aget-object v16, v10, v14

    move-object/from16 v17, v16

    .local v17, "element$iv$iv":Ljava/lang/Object;
    move-object/from16 v16, v17

    check-cast v16, Ljava/lang/reflect/Method;

    .local v16, "it":Ljava/lang/reflect/Method;
    const/16 v18, 0x0

    .line 143
    .local v18, "$i$a$-filter-ReaMethodLoader$loadAndInvoke$candidates$1":I
    invoke-virtual/range {v16 .. v16}, Ljava/lang/reflect/Method;->getName()Ljava/lang/String;

    move-result-object v13

    invoke-static {v13, v2}, Lkotlin/jvm/internal/Intrinsics;->areEqual(Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v13

    if-eqz v13, :cond_89

    invoke-virtual/range {v16 .. v16}, Ljava/lang/reflect/Method;->getParameterCount()I

    move-result v13
    :try_end_82
    .catch Ljava/lang/Exception; {:try_start_6a .. :try_end_82} :catch_9b

    move-object/from16 v19, v6

    :try_start_84
    array-length v6, v3

    if-ne v13, v6, :cond_8b

    const/4 v15, 0x1

    goto :goto_8c

    :cond_89
    move-object/from16 v19, v6

    :cond_8b
    const/4 v15, 0x0

    .line 251
    .end local v16    # "it":Ljava/lang/reflect/Method;
    .end local v18    # "$i$a$-filter-ReaMethodLoader$loadAndInvoke$candidates$1":I
    :goto_8c
    if-eqz v15, :cond_94

    move-object/from16 v6, v17

    .end local v17    # "element$iv$iv":Ljava/lang/Object;
    .local v6, "element$iv$iv":Ljava/lang/Object;
    invoke-interface {v9, v6}, Ljava/util/Collection;->add(Ljava/lang/Object;)Z

    goto :goto_96

    .end local v6    # "element$iv$iv":Ljava/lang/Object;
    .restart local v17    # "element$iv$iv":Ljava/lang/Object;
    :cond_94
    move-object/from16 v6, v17

    .end local v17    # "element$iv$iv":Ljava/lang/Object;
    :goto_96
    add-int/lit8 v14, v14, 0x1

    move-object/from16 v6, v19

    goto :goto_68

    .line 166
    .end local v0    # "$this$filter$iv":[Ljava/lang/Object;
    .end local v8    # "$i$f$filter":I
    .end local v9    # "destination$iv$iv":Ljava/util/Collection;
    .end local v10    # "$this$filterTo$iv$iv":[Ljava/lang/Object;
    .end local v11    # "$i$f$filterTo":I
    :catch_9b
    move-exception v0

    move-object/from16 v19, v6

    goto/16 :goto_176

    .line 252
    .restart local v0    # "$this$filter$iv":[Ljava/lang/Object;
    .restart local v8    # "$i$f$filter":I
    .restart local v9    # "destination$iv$iv":Ljava/util/Collection;
    .restart local v10    # "$this$filterTo$iv$iv":[Ljava/lang/Object;
    .restart local v11    # "$i$f$filterTo":I
    :cond_a0
    move-object/from16 v19, v6

    .end local v9    # "destination$iv$iv":Ljava/util/Collection;
    .end local v10    # "$this$filterTo$iv$iv":[Ljava/lang/Object;
    .end local v11    # "$i$f$filterTo":I
    move-object v6, v9

    check-cast v6, Ljava/util/List;

    .line 250
    nop

    .line 143
    .end local v0    # "$this$filter$iv":[Ljava/lang/Object;
    .end local v8    # "$i$f$filter":I
    nop

    .line 142
    nop

    .line 144
    .local v6, "candidates":Ljava/util/List;
    move-object v0, v6

    check-cast v0, Ljava/lang/Iterable;

    .local v0, "$this$firstOrNull$iv":Ljava/lang/Iterable;
    const/4 v8, 0x0

    .line 253
    .local v8, "$i$f$firstOrNull":I
    invoke-interface {v0}, Ljava/lang/Iterable;->iterator()Ljava/util/Iterator;

    move-result-object v9

    :goto_b0
    invoke-interface {v9}, Ljava/util/Iterator;->hasNext()Z

    move-result v10

    if-eqz v10, :cond_127

    invoke-interface {v9}, Ljava/util/Iterator;->next()Ljava/lang/Object;

    move-result-object v10

    .local v10, "element$iv":Ljava/lang/Object;
    move-object v11, v10

    check-cast v11, Ljava/lang/reflect/Method;

    .local v11, "m":Ljava/lang/reflect/Method;
    const/4 v12, 0x0

    .line 145
    .local v12, "$i$a$-firstOrNull-ReaMethodLoader$loadAndInvoke$method$1":I
    invoke-virtual {v11}, Ljava/lang/reflect/Method;->getParameterTypes()[Ljava/lang/Class;

    move-result-object v13

    .line 146
    .local v13, "params":[Ljava/lang/Class;
    invoke-static {v13}, Lkotlin/jvm/internal/Intrinsics;->checkNotNull(Ljava/lang/Object;)V

    invoke-static {v13}, Lkotlin/collections/ArraysKt;->getIndices([Ljava/lang/Object;)Lkotlin/ranges/IntRange;

    move-result-object v14

    check-cast v14, Ljava/lang/Iterable;

    .local v14, "$this$all$iv":Ljava/lang/Iterable;
    const/16 v16, 0x0

    .line 254
    .local v16, "$i$f$all":I
    instance-of v15, v14, Ljava/util/Collection;

    if-eqz v15, :cond_de

    move-object v15, v14

    check-cast v15, Ljava/util/Collection;

    invoke-interface {v15}, Ljava/util/Collection;->isEmpty()Z

    move-result v15

    if-eqz v15, :cond_de

    move-object/from16 v22, v0

    const/4 v0, 0x1

    goto :goto_11e

    .line 255
    :cond_de
    invoke-interface {v14}, Ljava/lang/Iterable;->iterator()Ljava/util/Iterator;

    move-result-object v15

    :goto_e2
    invoke-interface {v15}, Ljava/util/Iterator;->hasNext()Z

    move-result v18

    if-eqz v18, :cond_11b

    move-object/from16 v18, v15

    check-cast v18, Lkotlin/collections/IntIterator;

    invoke-virtual/range {v18 .. v18}, Lkotlin/collections/IntIterator;->nextInt()I

    move-result v18

    .local v18, "element$iv":I
    move/from16 v20, v18

    .local v20, "i":I
    const/16 v21, 0x0

    .line 147
    .local v21, "$i$a$-all-ReaMethodLoader$loadAndInvoke$method$1$1":I
    aget-object v22, v3, v20

    if-eqz v22, :cond_10f

    move-object/from16 v22, v0

    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .local v22, "$this$firstOrNull$iv":Ljava/lang/Iterable;
    aget-object v0, v13, v20

    aget-object v1, v3, v20

    invoke-virtual {v0, v1}, Ljava/lang/Class;->isInstance(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_111

    .line 148
    aget-object v0, v13, v20

    invoke-virtual {v0}, Ljava/lang/Class;->isPrimitive()Z

    move-result v0

    if-eqz v0, :cond_10d

    goto :goto_111

    :cond_10d
    const/4 v0, 0x0

    goto :goto_112

    .line 147
    .end local v22    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_10f
    move-object/from16 v22, v0

    .line 148
    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v22    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_111
    :goto_111
    const/4 v0, 0x1

    .line 255
    .end local v20    # "i":I
    .end local v21    # "$i$a$-all-ReaMethodLoader$loadAndInvoke$method$1$1":I
    :goto_112
    if-nez v0, :cond_116

    const/4 v0, 0x0

    goto :goto_11e

    :cond_116
    move-object/from16 v1, p3

    move-object/from16 v0, v22

    goto :goto_e2

    .line 256
    .end local v18    # "element$iv":I
    .end local v22    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_11b
    move-object/from16 v22, v0

    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v22    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    const/4 v0, 0x1

    .line 149
    .end local v14    # "$this$all$iv":Ljava/lang/Iterable;
    .end local v16    # "$i$f$all":I
    :goto_11e
    nop

    .line 253
    .end local v11    # "m":Ljava/lang/reflect/Method;
    .end local v12    # "$i$a$-firstOrNull-ReaMethodLoader$loadAndInvoke$method$1":I
    .end local v13    # "params":[Ljava/lang/Class;
    if-eqz v0, :cond_122

    goto :goto_12b

    :cond_122
    move-object/from16 v1, p3

    move-object/from16 v0, v22

    goto :goto_b0

    .line 257
    .end local v10    # "element$iv":Ljava/lang/Object;
    .end local v22    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :cond_127
    move-object/from16 v22, v0

    .end local v0    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    .restart local v22    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    move-object/from16 v10, v19

    .line 144
    .end local v8    # "$i$f$firstOrNull":I
    .end local v22    # "$this$firstOrNull$iv":Ljava/lang/Iterable;
    :goto_12b
    check-cast v10, Ljava/lang/reflect/Method;

    if-nez v10, :cond_139

    .line 150
    invoke-static {v6}, Lkotlin/collections/CollectionsKt;->firstOrNull(Ljava/util/List;)Ljava/lang/Object;

    move-result-object v0

    move-object v10, v0

    check-cast v10, Ljava/lang/reflect/Method;
    :try_end_136
    .catch Ljava/lang/Exception; {:try_start_84 .. :try_end_136} :catch_175

    .line 144
    if-nez v10, :cond_139

    .line 150
    return-object v19

    .line 151
    .local v10, "method":Ljava/lang/reflect/Method;
    :cond_139
    nop

    .line 152
    const/4 v0, 0x1

    :try_start_13b
    invoke-virtual {v10, v0}, Ljava/lang/reflect/Method;->setAccessible(Z)V
    :try_end_13e
    .catch Ljava/lang/Exception; {:try_start_13b .. :try_end_13e} :catch_13f

    goto :goto_140

    .line 153
    :catch_13f
    move-exception v0

    .line 156
    :goto_140
    :try_start_140
    invoke-virtual {v10}, Ljava/lang/reflect/Method;->getModifiers()I

    move-result v0

    invoke-static {v0}, Ljava/lang/reflect/Modifier;->isStatic(I)Z

    move-result v0

    if-eqz v0, :cond_157

    .line 157
    array-length v0, v3

    invoke-static {v3, v0}, Ljava/util/Arrays;->copyOf([Ljava/lang/Object;I)[Ljava/lang/Object;

    move-result-object v0

    move-object/from16 v1, v19

    invoke-virtual {v10, v1, v0}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0
    :try_end_155
    .catch Ljava/lang/Exception; {:try_start_140 .. :try_end_155} :catch_175

    move-object v6, v0

    goto :goto_170

    .line 159
    :cond_157
    nop

    .line 160
    const/4 v1, 0x0

    :try_start_159
    new-array v0, v1, [Ljava/lang/Class;

    invoke-virtual {v7, v0}, Ljava/lang/Class;->getDeclaredConstructor([Ljava/lang/Class;)Ljava/lang/reflect/Constructor;

    move-result-object v0

    new-array v1, v1, [Ljava/lang/Object;

    invoke-virtual {v0, v1}, Ljava/lang/reflect/Constructor;->newInstance([Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v0
    :try_end_165
    .catch Ljava/lang/Exception; {:try_start_159 .. :try_end_165} :catch_171

    .line 159
    nop

    .line 164
    .local v0, "instance":Ljava/lang/Object;
    :try_start_166
    array-length v1, v3

    invoke-static {v3, v1}, Ljava/util/Arrays;->copyOf([Ljava/lang/Object;I)[Ljava/lang/Object;

    move-result-object v1

    invoke-virtual {v10, v0, v1}, Ljava/lang/reflect/Method;->invoke(Ljava/lang/Object;[Ljava/lang/Object;)Ljava/lang/Object;

    move-result-object v1
    :try_end_16f
    .catch Ljava/lang/Exception; {:try_start_166 .. :try_end_16f} :catch_175

    move-object v6, v1

    .end local v0    # "instance":Ljava/lang/Object;
    .end local v6    # "candidates":Ljava/util/List;
    .end local v10    # "method":Ljava/lang/reflect/Method;
    :goto_170
    goto :goto_177

    .line 161
    .restart local v6    # "candidates":Ljava/util/List;
    .restart local v10    # "method":Ljava/lang/reflect/Method;
    :catch_171
    move-exception v0

    .line 162
    .local v0, "e":Ljava/lang/Exception;
    const/16 v19, 0x0

    return-object v19

    .line 166
    .end local v0    # "e":Ljava/lang/Exception;
    .end local v6    # "candidates":Ljava/util/List;
    .end local v10    # "method":Ljava/lang/reflect/Method;
    :catch_175
    move-exception v0

    .line 167
    .restart local v0    # "e":Ljava/lang/Exception;
    :goto_176
    const/4 v6, 0x0

    .line 141
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_177
    return-object v6

    .line 139
    .end local v7    # "clazz":Ljava/lang/Class;
    :cond_178
    :goto_178
    const/16 v19, 0x0

    return-object v19
.end method

.method public final loadClass(Landroid/content/Context;Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;Ljava/lang/String;)Ljava/lang/Class;
    .registers 14
    .param p1, "context"    # Landroid/content/Context;
    .param p2, "sealed"    # Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    .param p3, "className"    # Ljava/lang/String;
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Landroid/content/Context;",
            "Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;",
            "Ljava/lang/String;",
            ")",
            "Ljava/lang/Class<",
            "*>;"
        }
    .end annotation

    const-string v0, "context"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "sealed"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "className"

    invoke-static {p3, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 91
    move-object v0, p3

    check-cast v0, Ljava/lang/CharSequence;

    invoke-static {v0}, Lkotlin/text/StringsKt;->isBlank(Ljava/lang/CharSequence;)Z

    move-result v0

    const/4 v1, 0x0

    if-eqz v0, :cond_1a

    return-object v1

    .line 92
    :cond_1a
    sget-object v0, Lcom/appcore/runtime/ReaMethodDecrypt;->INSTANCE:Lcom/appcore/runtime/ReaMethodDecrypt;

    invoke-virtual {v0, p2}, Lcom/appcore/runtime/ReaMethodDecrypt;->open(Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;)[B

    move-result-object v0

    if-nez v0, :cond_23

    return-object v1

    :cond_23
    move-object v2, v0

    .line 93
    .local v2, "plain":[B
    invoke-direct {p0, p1, v2}, Lcom/appcore/runtime/ReaMethodLoader;->writePlaintextDex(Landroid/content/Context;[B)Ljava/io/File;

    move-result-object v0

    if-nez v0, :cond_37

    move-object v0, p0

    check-cast v0, Lcom/appcore/runtime/ReaMethodLoader;

    .local v0, "$this$loadClass_u24lambda_u240":Lcom/appcore/runtime/ReaMethodLoader;
    const/4 v8, 0x0

    .line 94
    .local v8, "$i$a$-run-ReaMethodLoader$loadClass$dexFile$1":I
    const/4 v6, 0x6

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-static/range {v2 .. v7}, Lkotlin/collections/ArraysKt;->fill$default([BBIIILjava/lang/Object;)V

    .line 95
    return-object v1

    .end local v0    # "$this$loadClass_u24lambda_u240":Lcom/appcore/runtime/ReaMethodLoader;
    .end local v8    # "$i$a$-run-ReaMethodLoader$loadClass$dexFile$1":I
    :cond_37
    move-object v8, v0

    .line 97
    .local v8, "dexFile":Ljava/io/File;
    nop

    .line 98
    :try_start_39
    invoke-direct {p0, p1}, Lcom/appcore/runtime/ReaMethodLoader;->optimizedDir(Landroid/content/Context;)Ljava/io/File;

    move-result-object v0

    if-nez v0, :cond_5b

    move-object v0, p0

    check-cast v0, Lcom/appcore/runtime/ReaMethodLoader;

    .local v0, "$this$loadClass_u24lambda_u241":Lcom/appcore/runtime/ReaMethodLoader;
    const/4 v9, 0x0

    .line 99
    .local v9, "$i$a$-run-ReaMethodLoader$loadClass$optDir$1":I
    invoke-direct {v0, v8}, Lcom/appcore/runtime/ReaMethodLoader;->deleteQuietly(Ljava/io/File;)V

    .line 100
    const/4 v6, 0x6

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-static/range {v2 .. v7}, Lkotlin/collections/ArraysKt;->fill$default([BBIIILjava/lang/Object;)V
    :try_end_4e
    .catch Ljava/lang/Exception; {:try_start_39 .. :try_end_4e} :catch_84
    .catchall {:try_start_39 .. :try_end_4e} :catchall_77

    .line 101
    nop

    .line 113
    .end local v0    # "$this$loadClass_u24lambda_u241":Lcom/appcore/runtime/ReaMethodLoader;
    .end local v9    # "$i$a$-run-ReaMethodLoader$loadClass$optDir$1":I
    invoke-direct {p0, v8}, Lcom/appcore/runtime/ReaMethodLoader;->deleteQuietly(Ljava/io/File;)V

    .line 114
    const/4 v6, 0x6

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-static/range {v2 .. v7}, Lkotlin/collections/ArraysKt;->fill$default([BBIIILjava/lang/Object;)V

    return-object v1

    :cond_5b
    nop

    .line 103
    .local v0, "optDir":Ljava/io/File;
    :try_start_5c
    new-instance v3, Ldalvik/system/DexClassLoader;

    .line 104
    invoke-virtual {v8}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v4

    .line 105
    invoke-virtual {v0}, Ljava/io/File;->getAbsolutePath()Ljava/lang/String;

    move-result-object v5

    .line 106
    nop

    .line 107
    invoke-virtual {p1}, Landroid/content/Context;->getClassLoader()Ljava/lang/ClassLoader;

    move-result-object v6

    .line 103
    invoke-direct {v3, v4, v5, v1, v6}, Ldalvik/system/DexClassLoader;-><init>(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/ClassLoader;)V

    .line 109
    .local v3, "loader":Ldalvik/system/DexClassLoader;
    move-object v4, v3

    check-cast v4, Ljava/lang/ClassLoader;

    const/4 v5, 0x1

    invoke-static {p3, v5, v4}, Ljava/lang/Class;->forName(Ljava/lang/String;ZLjava/lang/ClassLoader;)Ljava/lang/Class;

    move-result-object v1
    :try_end_76
    .catch Ljava/lang/Exception; {:try_start_5c .. :try_end_76} :catch_84
    .catchall {:try_start_5c .. :try_end_76} :catchall_77

    .end local v0    # "optDir":Ljava/io/File;
    .end local v3    # "loader":Ldalvik/system/DexClassLoader;
    goto :goto_86

    .line 113
    :catchall_77
    move-exception v0

    invoke-direct {p0, v8}, Lcom/appcore/runtime/ReaMethodLoader;->deleteQuietly(Ljava/io/File;)V

    .line 114
    const/4 v6, 0x6

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-static/range {v2 .. v7}, Lkotlin/collections/ArraysKt;->fill$default([BBIIILjava/lang/Object;)V

    throw v0

    .line 110
    :catch_84
    move-exception v0

    .line 111
    .local v0, "e":Ljava/lang/Exception;
    nop

    .line 113
    .end local v0    # "e":Ljava/lang/Exception;
    :goto_86
    invoke-direct {p0, v8}, Lcom/appcore/runtime/ReaMethodLoader;->deleteQuietly(Ljava/io/File;)V

    .line 114
    const/4 v6, 0x6

    const/4 v7, 0x0

    const/4 v3, 0x0

    const/4 v4, 0x0

    const/4 v5, 0x0

    invoke-static/range {v2 .. v7}, Lkotlin/collections/ArraysKt;->fill$default([BBIIILjava/lang/Object;)V

    .line 115
    nop

    .line 97
    return-object v1
.end method

.method public final rotateStored(Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;[B)Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    .registers 4
    .param p1, "sealed"    # Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;
    .param p2, "newKey"    # [B

    const-string v0, "sealed"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "newKey"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 182
    sget-object v0, Lcom/appcore/runtime/ReaMethodDecrypt;->INSTANCE:Lcom/appcore/runtime/ReaMethodDecrypt;

    invoke-virtual {v0, p1, p2}, Lcom/appcore/runtime/ReaMethodDecrypt;->rotate(Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;[B)Lcom/appcore/runtime/ReaMethodDecrypt$SealedMethod;

    move-result-object v0

    return-object v0
.end method

.method public final writePlaintextFile$main(Ljava/io/File;[B)Z
    .registers 5
    .param p1, "file"    # Ljava/io/File;
    .param p2, "plain"    # [B

    const-string v0, "file"

    invoke-static {p1, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    const-string v0, "plain"

    invoke-static {p2, v0}, Lkotlin/jvm/internal/Intrinsics;->checkNotNullParameter(Ljava/lang/Object;Ljava/lang/String;)V

    .line 197
    nop

    .line 198
    const/4 v0, 0x0

    :try_start_c
    invoke-static {p1, p2}, Lkotlin/io/FilesKt;->writeBytes(Ljava/io/File;[B)V

    .line 199
    invoke-virtual {p1}, Ljava/io/File;->canRead()Z

    move-result v1

    if-nez v1, :cond_19

    .line 200
    invoke-direct {p0, p1}, Lcom/appcore/runtime/ReaMethodLoader;->deleteQuietly(Ljava/io/File;)V
    :try_end_18
    .catch Ljava/lang/Exception; {:try_start_c .. :try_end_18} :catch_1b

    .line 201
    return v0

    .line 203
    :cond_19
    const/4 v0, 0x1

    goto :goto_20

    .line 204
    :catch_1b
    move-exception v1

    .line 205
    .local v1, "e":Ljava/lang/Exception;
    invoke-direct {p0, p1}, Lcom/appcore/runtime/ReaMethodLoader;->deleteQuietly(Ljava/io/File;)V

    .line 206
    nop

    .line 197
    .end local v1    # "e":Ljava/lang/Exception;
    :goto_20
    return v0
.end method
