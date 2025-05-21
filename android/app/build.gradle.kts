plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Plugin Google Services
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.absensi_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.absensi_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM (Bill of Materials) untuk mengelola versi dependency Firebase
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))

    // Tambahkan Firebase SDK yang kamu butuhkan, misalnya Firebase Analytics
    implementation("com.google.firebase:firebase-analytics")

    // Jika kamu juga menggunakan Firebase Auth atau Firestore, tambahkan ini:
    // implementation("com.google.firebase:firebase-auth")
    // implementation("com.google.firebase:firebase-firestore")
}