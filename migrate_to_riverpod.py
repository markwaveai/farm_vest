import os
import re
from pathlib import Path

LIB_PATH = r'd:\work1\farm_vest\lib'
STATS = {
    'files_modified': 0,
    'tr_calls_updated': 0,
    'imports_added': 0,
    'widgets_converted': 0,
}

def migrate_file(file_path):
    """Migrate a single Dart file from GetX .tr to Riverpod .tr(ref)"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        modified = False
        
        # Check if file uses .tr
        if '.tr' not in content:
            return False
        
        # Step 1: Replace .tr with .tr(ref)
        # Match '.tr' that's not already '.tr(ref)' and not part of a word
        tr_count = len(re.findall(r"\.tr\b(?!\(ref\))", content))
        if tr_count > 0:
            content = re.sub(r"\.tr\b(?!\(ref\))", ".tr(ref)", content)
            STATS['tr_calls_updated'] += tr_count
            modified = True
        
        # Step 2: Add translation_helpers import if needed
        if '.tr(ref)' in content and 'translation_helpers' not in content:
            # Find the last import statement
            import_pattern = r"(import\s+['\"]package:[^'\"]+['\"];?\s*\n)"
            imports = list(re.finditer(import_pattern, content))
            
            if imports:
                last_import = imports[-1]
                insert_pos = last_import.end()
                import_line = "import 'package:farm_vest/core/localization/translation_helpers.dart';\n"
                content = content[:insert_pos] + import_line + content[insert_pos:]
                STATS['imports_added'] += 1
                modified = True
        
        # Step 3: Convert StatelessWidget to ConsumerWidget if .tr(ref) is used
        if '.tr(ref)' in content:
            # Check if it's a StatelessWidget
            if 'extends StatelessWidget' in content:
                # Replace StatelessWidget with ConsumerWidget
                content = content.replace('extends StatelessWidget', 'extends ConsumerWidget')
                
                # Update build method signature to include WidgetRef
                # Pattern: Widget build(BuildContext context)
                build_pattern = r'Widget\s+build\s*\(\s*BuildContext\s+context\s*\)'
                if re.search(build_pattern, content):
                    content = re.sub(
                        build_pattern,
                        'Widget build(BuildContext context, WidgetRef ref)',
                        content
                    )
                    STATS['widgets_converted'] += 1
                    modified = True
                    
                # Add flutter_riverpod import if needed
                if 'flutter_riverpod' not in content:
                    import_pattern = r"(import\s+['\"]package:[^'\"]+['\"];?\s*\n)"
                    imports = list(re.finditer(import_pattern, content))
                    if imports:
                        last_import = imports[-1]
                        insert_pos = last_import.end()
                        riverpod_import = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
                        content = content[:insert_pos] + riverpod_import + content[insert_pos:]
                        modified = True
        
        # Write back if modified
        if modified and content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            STATS['files_modified'] += 1
            return True
        
        return False
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    print("=" * 60)
    print("GetX .tr → Riverpod .tr(ref) Migration Script")
    print("=" * 60)
    print()
    
    # Walk through lib directory
    dart_files = []
    for root, dirs, files in os.walk(LIB_PATH):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    print(f"Found {len(dart_files)} Dart files to process...\n")
    
    # Process each file
    for file_path in dart_files:
        rel_path = os.path.relpath(file_path, LIB_PATH)
        if migrate_file(file_path):
            print(f"✓ Modified: {rel_path}")
    
    # Print summary
    print()
    print("=" * 60)
    print("Migration Summary")
    print("=" * 60)
    print(f"Files modified:        {STATS['files_modified']}")
    print(f".tr calls updated:     {STATS['tr_calls_updated']}")
    print(f"Imports added:         {STATS['imports_added']}")
    print(f"Widgets converted:     {STATS['widgets_converted']}")
    print()
    print("✅ Migration complete!")
    print()
    print("Next steps:")
    print("1. Run 'flutter analyze' to check for any issues")
    print("2. Test language switching in the app")
    print("3. Fix any remaining manual conversions")

if __name__ == "__main__":
    main()
