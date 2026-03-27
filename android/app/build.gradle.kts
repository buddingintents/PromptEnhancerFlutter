import java.io.File
import java.time.Duration
import java.time.Instant
import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use(keystoreProperties::load)
}

val releaseStoreFile =
    keystoreProperties.getProperty("storeFile")
        ?: System.getenv("ANDROID_STORE_FILE")
val releaseStorePassword =
    keystoreProperties.getProperty("storePassword")
        ?: System.getenv("ANDROID_STORE_PASSWORD")
val releaseKeyAlias =
    keystoreProperties.getProperty("keyAlias")
        ?: System.getenv("ANDROID_KEY_ALIAS")
val releaseKeyPassword =
    keystoreProperties.getProperty("keyPassword")
        ?: System.getenv("ANDROID_KEY_PASSWORD")
val releaseStoreFilePath =
    releaseStoreFile?.let { configuredPath ->
        val configuredFile = File(configuredPath)
        if (configuredFile.isAbsolute) {
            configuredFile
        } else {
            rootProject.file(configuredPath)
        }
    }
val hasReleaseSigning =
    releaseStoreFilePath != null &&
        !releaseStorePassword.isNullOrBlank() &&
        !releaseKeyAlias.isNullOrBlank() &&
        !releaseKeyPassword.isNullOrBlank()
val isReleaseTaskRequested =
    gradle.startParameter.taskNames.any {
        it.contains("Release", ignoreCase = true) ||
            it.contains("bundle", ignoreCase = true)
    }
val manualVersionCodeOverride = System.getenv("ANDROID_VERSION_CODE")?.toIntOrNull()
val generatedVersionCode =
    Duration.between(
        Instant.parse("2024-01-01T00:00:00Z"),
        Instant.now(),
    ).seconds.toInt()
val resolvedVersionCode =
    maxOf(
        flutter.versionCode,
        manualVersionCodeOverride ?: generatedVersionCode,
    )

if (!hasReleaseSigning && isReleaseTaskRequested) {
    throw GradleException(
        "Release signing is not configured. Add android/key.properties or set ANDROID_STORE_FILE, ANDROID_STORE_PASSWORD, ANDROID_KEY_ALIAS, and ANDROID_KEY_PASSWORD.",
    )
}

android {
    namespace = "com.buddingintents.promptenhancer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.buddingintents.promptenhancer"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = resolvedVersionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = releaseStoreFilePath
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

