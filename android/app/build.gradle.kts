// Import untuk operasi file dan properti
import java.io.FileInputStream
import java.util.Properties

// ====================================================================
// A. PEMBACAAN FILE KREDENSIAL (key.properties) DENGAN KOTLIN SCRIPT
// ====================================================================

// Membaca local.properties (default Flutter)
val localProperties = Properties()
localProperties.load(FileInputStream(rootProject.file("local.properties")))

// Membaca key.properties (untuk kredensial signing release)
val signingProperties = Properties()
val signingPropertiesFile = rootProject.file("key.properties")

if (signingPropertiesFile.exists()) {
    signingProperties.load(FileInputStream(signingPropertiesFile))
}
// ====================================================================


plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.tirtha_app"
    compileSdk = flutter.compileSdkVersion
    
    // NOTE: ndkVersion harus berupa String, tambahkan quote ganda
    ndkVersion = "27.0.12077973" 

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
        // jvmTarget = "17"
    }

    // ====================================================================
    // B. BLOK SIGNING CONFIGS BARU (Kotlin Script)
    // ====================================================================
    signingConfigs {
        // Mendefinisikan konfigurasi signing 'release'
        create("release") {
            // Mengakses properti menggunakan getProperty()
            storeFile = file(signingProperties.getProperty("storeFile"))
            storePassword = signingProperties.getProperty("storePassword")
            keyAlias = signingProperties.getProperty("keyAlias")
            keyPassword = signingProperties.getProperty("keyPassword")
        }
    }
    // ====================================================================

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.tirtha_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 33
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    dependencies {
    // ...existing dependencies...
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // ...existing dependencies...
    }

    buildTypes {
        // Mengakses blok 'release'
        getByName("release") {
            // ⚠️ C. AKTIVASI PROGUARD DAN PENANDATANGANAN RELEASE (Kotlin Script)
            isMinifyEnabled = true // Perubahan dari minifyEnabled -> isMinifyEnabled
            
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // Menerapkan konfigurasi signing 'release' yang baru
            signingConfig = signingConfigs.getByName("release") 
        }
    }
}

flutter {
    source = "../.."
}
