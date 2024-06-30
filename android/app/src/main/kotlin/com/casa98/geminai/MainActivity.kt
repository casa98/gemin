package com.casa98.geminai

import android.content.Intent
import android.content.pm.PackageManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

data class AppInfo(val packageName: String, val appName: String)

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.casa98/platform_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val installedApps = getInstalledLauncherApps()
                    val appsMap = installedApps.map { appInfo ->
                        mapOf("packageName" to appInfo.packageName, "appName" to appInfo.appName)
                    }
                    result.success(appsMap)
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("package")
                    if (packageName != null) {
                        val launchResult = launchApp(packageName)
                        result.success(launchResult)
                    } else {
                        result.error("INVALID_PACKAGE", "Invalid package name", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getInstalledLauncherApps(): List<AppInfo> {
        val pm: PackageManager = packageManager
        val intent = Intent(Intent.ACTION_MAIN, null)
        intent.addCategory(Intent.CATEGORY_LAUNCHER)
        val resolveInfos = pm.queryIntentActivities(intent, 0)
        val installedApps = mutableListOf<AppInfo>()
        for (resolveInfo in resolveInfos) {
            val packageName = resolveInfo.activityInfo.packageName
            val appName = resolveInfo.loadLabel(pm).toString()
            installedApps.add(AppInfo(packageName, appName))
        }
        return installedApps
    }

    private fun launchApp(packageName: String): String {
        return try {
            val launchIntent: Intent? = packageManager.getLaunchIntentForPackage(packageName)
            if (launchIntent != null) {
                startActivity(launchIntent)
                "Launched $packageName"
            } else {
                "App not found"
            }
        } catch (e: Exception) {
            "Failed to launch app: ${e.message}"
        }
    }
}
