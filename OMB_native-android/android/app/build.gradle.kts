plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ai.openmausbot.omb_native"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "ai.openmausbot.omb_native"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Stable release signing when CI provides OMB_KEYSTORE_B64 etc.
            // (so every CI APK has the same signature and updates in place);
            // falls back to debug keys for local builds.
            signingConfig = if (System.getenv("OMB_KEYSTORE_FILE") != null) {
                signingConfigs.create("ombRelease") {
                    storeFile = file(System.getenv("OMB_KEYSTORE_FILE"))
                    storePassword = System.getenv("OMB_KEYSTORE_PASS")
                    keyAlias = System.getenv("OMB_KEY_ALIAS")
                    keyPassword = System.getenv("OMB_KEY_PASS")
                }
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
