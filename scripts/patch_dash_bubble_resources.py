import os
import re
import sys

# Find and patch dash_bubble BubbleService.kt file
pub_cache = os.path.expanduser("~/.pub-cache/hosted/pub.dev")

if not os.path.exists(pub_cache):
    print(f"Pub cache not found: {pub_cache}")
    sys.exit(0)

# Find BubbleService.kt
for root, dirs, files in os.walk(pub_cache):
    if "dash_bubble" in root and "BubbleService.kt" in files:
        filepath = os.path.join(root, "BubbleService.kt")
        print(f"Patching: {filepath}")
        
        with open(filepath, 'r') as f:
            content = f.read()
        
        original_content = content
        
        # Replace ic_close_bubble with a drawable resource that exists
        # Use 0 (which is a valid drawable ID) or comment it out
        content = re.sub(
            r'R\.drawable\.ic_close_bubble',
            '0',  # Use 0 as a safe fallback for missing drawable
            content
        )
        
        # Alternative: Replace with a try-catch or null check
        # This is a simpler approach - just use 0 which is safe
        
        if content != original_content:
            with open(filepath, 'w') as f:
                f.write(content)
            print(f"✓ Fixed ic_close_bubble references in {filepath}")
        else:
            print(f"No changes needed for {filepath}")

print("dash_bubble resource patching complete")
