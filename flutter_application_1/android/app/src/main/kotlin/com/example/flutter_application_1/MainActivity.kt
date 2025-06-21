package com.example.flutter_application_1

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Ensure Firebase Messaging plugin is registered
        flutterEngine.plugins.add(FlutterFirebaseMessagingPlugin())
    }
}
