package com.appcore.runtime

/**
 * Fixture class for the L57 dynamic-loading test (Integrity2Test).
 * Compiled on its own into tests/dynamic-test.jar so the test can
 * load it from a jar file at runtime — it is NOT on the test's own
 * classpath. Never shipped in the runtime jar.
 */
class DynamicHello {
    fun hello(): String = "dynamic-hello"
    fun add(a: Int, b: Int): Int = a + b
}
