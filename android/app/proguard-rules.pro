# -----------------------------------------------
# Flutter core
# -----------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# -----------------------------------------------
# WebView (webview_flutter)
# -----------------------------------------------
-keep class android.webkit.** { *; }
-keep class androidx.webkit.** { *; }
-keep class com.google.android.webkit.** { *; }

# -----------------------------------------------
# flutter_local_notifications
# -----------------------------------------------
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat { *; }
-keep class androidx.core.app.NotificationCompat$** { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }

# -----------------------------------------------
# permission_handler
# -----------------------------------------------
-keep class com.baseflow.permissionhandler.** { *; }

# -----------------------------------------------
# connectivity_plus
# -----------------------------------------------
-keep class dev.fluttercommunity.plus.connectivity.** { *; }
# old package name — keep both for safety
-keep class com.baseflow.connectivityplus.** { *; }

# -----------------------------------------------
# device_info_plus
# -----------------------------------------------
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-keep class io.flutter.plugins.deviceinfoplus.** { *; }

# -----------------------------------------------
# http package (Dart mirrors not used but keep OkHttp if present)
# -----------------------------------------------
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

# -----------------------------------------------
# Kotlin / Coroutines
# -----------------------------------------------
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.coroutines.**

# -----------------------------------------------
# Keep JSON model fields (prevents stripping data fields)
# -----------------------------------------------
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# -----------------------------------------------
# Prevent stripping of Gson/JSON-used classes
# -----------------------------------------------
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}