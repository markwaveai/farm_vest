import os
import re
import json
from pathlib import Path

# Paths
LIB_PATH = r'd:\work1\farm_vest\lib'
OUTPUT_DIR = r'd:\work1\farm_vest\assets\lang'

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Collect all .tr usage
translation_keys = set()

def extract_tr_from_file(file_path):
    """Extract all '.tr' translation keys from a Dart file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Pattern to match 'text'.tr or "text".tr
        patterns = [
            r"'([^']+)'\s*\.tr",  # Single quotes
            r'"([^"]+)"\s*\.tr',  # Double quotes  
        ]
        
        for pattern in patterns:
            matches = re.findall(pattern, content)
            translation_keys.update(matches)
            
    except Exception as e:
        print(f"Error reading {file_path}: {e}")

# Walk through lib directory
print("Scanning Dart files for translation keys...")
for root, dirs, files in os.walk(LIB_PATH):
    for file in files:
        if file.endswith('.dart'):
            file_path = os.path.join(root, file)
            extract_tr_from_file(file_path)

print(f"Found {len(translation_keys)} unique translation keys")

# Create English JSON (keys same as values for now - you can manually translate later)
en_translations = {key: key for key in sorted(translation_keys)}

# Save English translations
en_path = os.path.join(OUTPUT_DIR, 'en.json')
with open(en_path, 'w', encoding='utf-8') as f:
    json.dump(en_translations, f, indent=4, ensure_ascii=False)

print(f"Created {en_path}")

# Create Hindi and Telugu JSON files (placeholder - same as English for now)
for lang in ['hi', 'te']:
    lang_path = os.path.join(OUTPUT_DIR, f'{lang}.json')
    with open(lang_path, 'w', encoding='utf-8') as f:
        json.dump(en_translations, f, indent=4, ensure_ascii=False)
    print(f"Created {lang_path} (needs manual translation)")

print("\nDone! Run manual translation scripts for hi.json and te.json")
print(f"Total keys: {len(translation_keys)}")
