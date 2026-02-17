import os
import re
from pathlib import Path

LIB_PATH = r'd:\work1\farm_vest\lib'
STATS = {
    'files_modified': 0,
    'tr_calls_updated': 0,
    'imports_added': 0,
    'stateless_to_consumer': 0,
    'stateful_to_consumer': 0,
    'get_imports_removed': 0,
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
        
        # Step 1: Convert StatefulWidget to ConsumerStatefulWidget if needed
        if 'extends StatefulWidget' in content and '.tr(' in content:
            content = content.replace('extends StatefulWidget', 'extends ConsumerStatefulWidget')
            # Also update the State class
            content = re.sub(
                r'class\s+(\w+)\s+extends\s+State<(\w+)>',
                r'class \1 extends ConsumerState<\2>',
                content
            )
            STATS['stateful_to_consumer'] += 1
            modified = True
        
        # Step 2: Convert StatelessWidget to ConsumerWidget if needed
        if 'extends StatelessWidget' in content and '.tr(' in content:
            content = content.replace('extends StatelessWidget', 'extends ConsumerWidget')
            
            # Update build method signature
            build_pattern = r'Widget\s+build\s*\(\s*BuildContext\s+context\s*\)'
            if re.search(build_pattern, content):
                content = re.sub(
                    build_pattern,
                    'Widget build(BuildContext context, WidgetRef ref)',
                    content
                )
            STATS['stateless_to_consumer'] += 1
            modified = True
        
        # Step 3: Add flutter_riverpod import if widget was converted
        if ('ConsumerWidget' in content or 'ConsumerStatefulWidget' in content or 'ConsumerState' in content):
            if 'flutter_riverpod' not in content:
                # Find first import
                import_pattern = r"(import\s+['\"]package:[^'\"]+['\"];?\s*\n)"
                imports = list(re.finditer(import_pattern, content))
                if imports:
                    first_import = imports[0]
                    insert_pos = first_import.start()
                    riverpod_import = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
                    content = content[:insert_pos] + riverpod_import + content[insert_pos:]
                    modified = True
        
        # Step 4: Add translation_helpers import if .tr(ref) is used
        if '.tr(ref)' in content and 'translation_helpers' not in content:
            import_pattern = r"(import\s+['\"]package:[^'\"]+['\"];?\s*\n)"
            imports = list(re.finditer(import_pattern, content))
            if imports:
                # Insert after the last import
                last_import = imports[-1]
                insert_pos = last_import.end()
                import_line = "import 'package:farm_vest/core/localization/translation_helpers.dart';\n"
                content = content[:insert_pos] + import_line + content[insert_pos:]
                STATS['imports_added'] += 1
                modified = True
        
        # Step 5: Remove GetX import if it's only used for .tr
        if 'import \'package:get/get.dart\'' in content or 'import "package:get/get.dart"' in content:
            # Check if GetX is used for anything other than .tr
            get_usage_patterns = [
                r'\bGet\.',  # Get.to, Get.find, etc.
                r'\bGetX[<(]',  # GetX widget
                r'\bObx\(',  # Obx widget
                r'\bGetBuilder[<(]',  # GetBuilder widget
                r'\bGetController',  # GetController
            ]
            
            has_other_get_usage = any(re.search(pattern, content) for pattern in get_usage_patterns)
            
            if not has_other_get_usage:
                # Safe to remove Get import
                content = re.sub(r"import\s+['\"]package:get/get\.dart['\"];?\s*\n", "", content)
                STATS['get_imports_removed'] += 1
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
    print("=" * 70)
    print("Riverpod Migration Script - Phase 2: Widget Conversion")
    print("=" * 70)
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
    print("=" * 70)
    print("Migration Summary")
    print("=" * 70)
    print(f"Files modified:              {STATS['files_modified']}")
    print(f"StatelessWidget converted:   {STATS['stateless_to_consumer']}")
    print(f"StatefulWidget converted:    {STATS['stateful_to_consumer']}")
    print(f"Translation imports added:   {STATS['imports_added']}")
    print(f"GetX imports removed:        {STATS['get_imports_removed']}")
    print()
    print("✅ Migration complete!")

if __name__ == "__main__":
    main()
