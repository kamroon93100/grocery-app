import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.kohlistore.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.kohlistore.app"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        val storePass = System.getenv("STORE_PASSWORD")
        val keyPass = System.getenv("KEY_PASSWORD")
        val hasReleaseKey = !storePass.isNullOrEmpty() && !keyPass.isNullOrEmpty()

        if (hasReleaseKey) {
            create("release") {
                storeFile = file("upload-keystore.jks")
                storePassword = storePass
                keyAlias = System.getenv("KEY_ALIAS") ?: "upload"
                keyPassword = keyPass
            }
        }
    }

    buildTypes {
        release {
            // Use release signing if configured, otherwise fall back to debug signing
            val releaseConfig = try { signingConfigs.getByName("release") } catch (_: Exception) { null }
            signingConfig = releaseConfig ?: signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.multidex:multidex:2.0.1")
}
