# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Aturan Wajib untuk Firebase Core
-keep class com.google.firebase.** { *; }
-keepattributes Signature
-keep class com.google.android.gms.common.** { *; }

# Aturan Wajib untuk Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }

# (Jika Anda menggunakan Firebase Auth)
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }

# (Jika Anda menggunakan Firestore)
-keep class com.google.firebase.firestore.** { *; }

-keep class com.google.android.play.core.** { *; }


-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task