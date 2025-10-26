# Aturan untuk menjaga Flutter Secure Storage dan platform-plugin terkait
# Mencegah obfuscation pada class yang diakses oleh Method Channels.

# Menjaga Shared Preferences (sering digunakan oleh secure_storage secara internal)
-keep class io.flutter.plugins.sharedpreferences.* { *; }

# Aturan umum untuk Method Channel
-keep class io.flutter.plugin.common.MethodChannel { *; }

# Aturan khusus untuk flutter_secure_storage (penting)
-keep class com.it_ss.flutter_secure_storage.* { *; } 
-keep class com.tekartik.sqflite.* { *; } # Jika menggunakan sqflite