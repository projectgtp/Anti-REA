package com.antirea.testapp

import android.app.Activity
import android.os.Bundle

/**
 * Generic Anti-REA test app — NOT Bridge, no Bridge code.
 *
 * Purpose: prove the v1.0 CLI + runtime protection is universal by
 * protecting a tiny app that has nothing to do with Bridge. The two
 * test strings below are INVENTED fakes, not real secrets:
 *  - TEST_SECRET is a fake secret constant.
 *  - TEST_ENDPOINT is a fake endpoint on the .invalid TLD, which
 *    can never resolve to a real host.
 * The attack verifier (verifier/attack.py) uses them as needles:
 * they must be found in the control APK and absent (0) in a
 * protected APK.
 */
class MainActivity : Activity() {

    companion object {
        const val TEST_SECRET = "TEST-SECRET-7f3a9-generic"
        const val TEST_ENDPOINT = "https://testapp.example.invalid/api"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }

    /** The one key method the protection is expected to hide. */
    fun getSecret(): String {
        return TEST_SECRET
    }

    fun getEndpoint(): String {
        return TEST_ENDPOINT
    }
}
