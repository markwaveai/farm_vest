package com.markwave.farmvest

import android.view.WindowManager.LayoutParams
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        window.setFlags(LayoutParams.FLAG_SECURE, LayoutParams.FLAG_SECURE)
        super.configureFlutterEngine(flutterEngine)
    }
}
