import sys
import os

filepath = sys.argv[1] if len(sys.argv) > 1 else 'android/app/build.gradle.kts'

with open(filepath, 'r') as f:
    content = f.read()

# 1. Patch minSdk
content = content.replace('minSdk = flutter.minSdkVersion', 'minSdk = 21')

# 2. Force isMinifyEnabled to false wherever it appears
content = content.replace('isMinifyEnabled = true', 'isMinifyEnabled = false')

# 3. If no isMinifyEnabled found at all, add it
if 'isMinifyEnabled' not in content:
    content = content.replace(
        'signingConfig = signingConfigs.debug',
        'signingConfig = signingConfigs.debug\n            isMinifyEnabled = false'
    )

# 4. Add proguardFiles with ML Kit keep rules
if 'proguardFiles' not in content:
    content = content.replace(
        'isMinifyEnabled = false',
        'isMinifyEnabled = false\n            proguardFiles(\n                getDefaultProguardFile("proguard-android-optimize.txt"),\n                "proguard-rules.pro"\n            )'
    )

# 5. Add shrinkResources = false
content = content.replace('shrinkResources = true', 'shrinkResources = false')
if 'shrinkResources' not in content:
    content = content.replace(
        'isMinifyEnabled = false',
        'isMinifyEnabled = false\n            shrinkResources = false'
    )

with open(filepath, 'w') as f:
    f.write(content)

# تظبيط قواعد Proguard لـ ML Kit لحل مشكلة الكلاسات المفقودة تماماً
proguard_path = os.path.join(os.path.dirname(filepath), 'proguard-rules.pro')
with open(proguard_path, 'w') as f:
    f.write('''# ML Kit rules
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# تجاهل أخطاء الكلاسات المفقودة للغات الإضافية أثناء الـ Minification
-ignorewarnings
''')

print(f"Patched {filepath}")
print(f"Created {proguard_path}")
