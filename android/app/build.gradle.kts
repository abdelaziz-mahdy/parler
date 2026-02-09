plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.french"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        create("release") {
            val keystoreFile = file("${rootProject.projectDir}/french_keystore.jks")
            val keyPropsFile = file("${rootProject.projectDir}/key.properties")

            if (keystoreFile.exists()) {
                storeFile = keystoreFile

                // Read credentials from key.properties (local) or env vars (CI)
                if (keyPropsFile.exists()) {
                    val keyProps = java.util.Properties().apply { load(keyPropsFile.inputStream()) }
                    storePassword = keyProps.getProperty("storePassword")
                    keyAlias = keyProps.getProperty("keyAlias")
                    keyPassword = keyProps.getProperty("keyPassword")
                } else {
                    storePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
                    keyAlias = System.getenv("KEY_ALIAS") ?: ""
                    keyPassword = System.getenv("KEY_PASSWORD") ?: ""
                }
            } else {
                // Fallback to debug keystore when french_keystore.jks is not available
                val home = System.getenv("HOME") ?: ""
                storeFile = file("$home/.android/debug.keystore")
                storePassword = "android"
                keyAlias = "androiddebugkey"
                keyPassword = "android"
            }
        }
    }

    defaultConfig {
        applicationId = "com.example.french"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
