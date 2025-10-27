# ====================================================================
# A. ATURAN WAJIB FLUTTER & METHOD CHANNELS
# ====================================================================

-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

-keep class io.flutter.plugin.common.MethodChannel { *; }
-keep class io.flutter.plugin.common.** { *; }

# ====================================================================
# B. ATURAN KHUSUS FIREBASE
# ====================================================================

-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }

# ====================================================================
# C. GOOGLE PLAY CORE (MENGATASI R8 ERROR)
# ====================================================================

-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Khusus untuk Split Install yang digunakan Flutter
-keep interface com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-keep class com.google.android.play.core.common.** { *; }

# ====================================================================
# D. SECURE STORAGE & SHARED PREFERENCES
# ====================================================================

-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class com.it_ss.flutter_secure_storage.** { *; } 
-keep class com.tekartik.sqflite.** { *; }

# ====================================================================
# E. ATURAN UMUM UNTUK MENCEGAH STRIP YANG BERLEBIHAN
# ====================================================================

# Menjaga semua kelas yang memiliki metode native
-keepclasseswithmembernames class * {
    native <methods>;
}

# Menjaga enum
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Menjaga Parcelable
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Menjaga Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ====================================================================
# F. ATURAN KHUSUS RESOURCE (DRAWABLES)
# ====================================================================

# Menjaga SEMUA resource drawable dan mipmap
-keep class **.R
-keep class **.R$* { *; }
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Khusus untuk drawable dan mipmap
-keep class **.R$drawable { *; }
-keep class **.R$mipmap { *; }

# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Android Notification Resources
-keep public class * extends android.app.Notification { *; }
-keep class * implements android.os.Parcelable { 
    public static final android.os.Parcelable$Creator *; 
}