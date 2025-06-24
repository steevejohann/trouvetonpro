plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.trouvetonpro"
    compileSdk = 34  // Mise à jour ici (au lieu de flutter.compileSdkVersion)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.trouvetonpro"
        minSdk = 23
        targetSdk = 34  // Mise à jour ici (au lieu de flutter.targetSdkVersion)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders.putAll(
            mapOf(
                "facebookAppId" to "1236938457818163",
                "facebookClientToken" to "f6fe5136fa69b173196ac6a7f67ca82d"
            )
        )
        multiDexEnabled = true  // Ajout important pour les applications avec de nombreuses dépendances
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
    // Ajout des dépendances Kotlin nécessaires
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.22")
    implementation("androidx.core:core-ktx:1.12.0")
    
    // Ajout des dépendances Firebase (si vous utilisez FlutterFire)
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    
    // Dépendances existantes (ajustez selon vos besoins)
    implementation("com.facebook.android:facebook-android-sdk:16.2.0")
    implementation("com.google.android.gms:play-services-auth:20.7.0")
    implementation("androidx.multidex:multidex:2.0.1")  // Version moderne de multidex
}