import os
import subprocess

def run_command(command):
    print(f"Executing: {command}")
    subprocess.run(command, shell=True, check=True)

def main():
    print("🚀 بدء خطوة الإصلاح الشاملة المحدثة...")

    # 1. إجبار فلاتر على توليد مجلد أندرويد من جديد
    print("📦 جاري توليد مجلد أندرويد المفقود...")
    run_command("flutter create --platforms=android .")

    # 2. تجديد ملف android/app/build.gradle.kts
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

    # 3. تعديل مكتبة dash_bubble مباشرة داخل الـ pub-cache في سيرفر جيت هب
    print("🎯 جاري البحث عن مكتبة dash_bubble وتعديلها مباشرة...")
    
    # تحديد المسارات المتوقعة في السيرفر
    paths_to_check = [
        os.path.expanduser("~/.pub-cache/hosted/pub.dev/dash_bubble-2.0.0/android/build.gradle"),
        "/home/runner/.pub-cache/hosted/pub.dev/dash_bubble-2.0.0/android/build.gradle"
    ]
    
    for path in paths_to_check:
        # لو الفولدرات مش موجودة لسه (لأن pub get شغال في خطوة تانية)، هنصنع السكربت يراقبها
        # وعشان نضمن إن التعديل يحصل فوراً وقت بناء الـ Actions، هنخليه يحقن السطر ده
        if os.path.exists(path):
            print(f"Found dash_bubble gradle at: {path}")
            with open(path, "r", encoding="utf-8") as f:
                lines = f.readlines()
            
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
            # الخطة البديلة: لو السكربت اشتغل قبل الـ pub get، هنخليه يعدل برضه ملف الجرادل الرئيسي كإجراء احتياطي
            root_gradle = "android/build.gradle"
            if os.path.exists(root_gradle):
                with open(root_gradle, "r", encoding="utf-8") as f:
                    content = f.read()
                if "subprojects" not in content:
                    content += "\\nsubprojects { afterEvaluate { project -> if (project.hasProperty('android')) { project.android { if (namespace == null) { namespace = project.group.toString() + '.' + project.name } } } } }\\n"
                    with open(root_gradle, "w", encoding="utf-8") as f:
                        f.write(content)
                print("✅ كخطة بديلة: تم تأمين ملف الجرادل الرئيسي لحقن الـ Namespace تلقائياً!")

if __name__ == "__main__":
    main()
