import os
import subprocess

def run_command(command):
    print(f"Executing: {command}")
    subprocess.run(command, shell=True, check=True)

def main():
    print("🚀 بدء خطوة الإصلاح الشاملة المحدثة...")

    # 1. إجبار فلاتر على توليد مجلد أندرويد
    print("📦 جاري توليد مجلد أندرويد المفقود...")
    run_command("flutter create --platforms=android .")

    # 2. مسح وإعادة كتابة ملف android/app/build.gradle.kts
    app_gradle_path = "android/app/build.gradle.kts"
    if os.path.exists(app_gradle_path):
        print(f"🛠️ جاري تجديد: {app_gradle_path}")
        new_app_gradle = """plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.tetocollctionway.mirror"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.tetocollctionway.mirror"
        minSdk = 21
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            minifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
    
    buildFeatures {
        resValues = true
    }
}

flutter {
    source = "../.."
}
"""
        with open(app_gradle_path, "w", encoding="utf-8") as f:
            f.write(new_app_gradle)
        print("✅ تم تجديد ملف App Gradle بنجاح!")

    # 3. الحل الصاروخي: تعديل مكتبة dash_bubble مباشرة داخل الـ pub-cache في السيرفر
    print("🎯 جاري البحث عن مكتبة dash_bubble وتعديلها مباشرة...")
    pub_cache_path = os.path.expanduser("~/.pub-cache/hosted/pub.dev/dash_bubble-2.0.0/android/build.gradle")
    
    # لو المسار مختلف في الـ runner بتاع جيت هب
    github_runner_path = "/home/runner/.pub-cache/hosted/pub.dev/dash_bubble-2.0.0/android/build.gradle"
    
    paths_to_check = [pub_cache_path, github_runner_path]
    
    for path in paths_to_check:
        if os.path.exists(path):
            print(f"Found dash_bubble gradle at: {path}")
            with open(path, "r", encoding="utf-8") as f:
                lines = f.readlines()
            
            # فحص إذا كان الـ namespace موجود، لو مش موجود نحقنه
            has_namespace = any("namespace" in line for line in lines)
            if not has_namespace:
                new_lines = []
                for line in lines:
                    new_lines.append(line)
                    if "android {" in line:
                        new_lines.append('    namespace "dev.moaz.dash_bubble"\n')
                
                with open(path, "w", encoding="utf-8") as f:
                    f.writelines(new_lines)
                print(f"✅ تم حقن الـ namespace بنجاح جوه ملف المكتبة الأصلي!")
        else:
            print(f"Path not found yet (will check during build): {path}")

if __name__ == "__main__":
    main()
