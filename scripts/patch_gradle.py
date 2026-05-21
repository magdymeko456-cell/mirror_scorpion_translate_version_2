import sys

filepath = sys.argv[1] if len(sys.argv) > 1 else 'android/app/build.gradle.kts'

with open(filepath, 'r') as f:
    content = f.read()

content = content.replace('minSdk = flutter.minSdkVersion', 'minSdk = 21')
content = content.replace('isMinifyEnabled = true', 'isMinifyEnabled = false')

# Also ensure no shrinkResources
if 'shrinkResources' not in content:
    content = content.replace(
        'isMinifyEnabled = false',
        'isMinifyEnabled = false\n            shrinkResources = false'
    )

with open(filepath, 'w') as f:
    f.write(content)

print(f"Patched {filepath}")
