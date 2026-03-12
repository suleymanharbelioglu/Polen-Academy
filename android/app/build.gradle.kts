import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties: Properties? = if (keystorePropertiesFile.exists()) {
    Properties().apply { load(FileInputStream(keystorePropertiesFile)) }
} else null

android {
    namespace = "com.example.polen_academy"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.polen_academy"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        ndk {
            // Flutter engine artifacts are not always packaged for every ABI on every setup.
            // Limit to arm64 to ensure consistent CI/local builds.
            abiFilters += setOf("arm64-v8a")
        }
    }

    signingConfigs {
        if (keystoreProperties != null) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storePassword = keystoreProperties.getProperty("storePassword")
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                storeFile = storeFilePath?.let { path -> rootProject.file(path) }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keystoreProperties != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
