package com.example.favorite_places

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "favorite_places/maps_config")
            .setMethodCallHandler { call, result ->
                if (call.method == "getApiKey") {
                    val info = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
                    result.success(info.metaData?.getString("com.google.android.geo.API_KEY"))
                } else {
                    result.notImplemented()
                }
            }
    }
}
