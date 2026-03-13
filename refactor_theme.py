import os

lib_dir = '/home/dvcanache/Workspaces/notegym/lib'
skip_files = ['theme.dart', 'theme_extension.dart', 'theme_provider.dart']

for root, _, files in os.walk(lib_dir):
    for f in files:
        if not f.endswith('.dart'): continue
        if f in skip_files: continue
        
        path = os.path.join(root, f)
        with open(path, 'r') as file:
            content = file.read()
            
        if 'AppColors.' in content:
            # Replace AppColors. with context.colors.
            content = content.replace('AppColors.', 'context.colors.')
            
            # Need to insert import for theme_extension
            if 'theme_extension.dart' not in content:
                # Find last import
                lines = content.split('\n')
                idx = 0
                for i, line in enumerate(lines):
                    if line.startswith('import '):
                        idx = i
                lines.insert(idx + 1, "import 'package:notegym/core/theme_extension.dart';")
                content = '\n'.join(lines)
                
            # For specific widgets, we might have default constructor parameters like
            # backgroundColor = AppColors.glassWhite which become invalid when using context.colors.
            # We already changed them above if we did, but let's blanket-remove defaults if they got replaced:
            content = content.replace('this.backgroundColor = context.colors.glassWhite', 'this.backgroundColor')
            content = content.replace('this.borderColor = context.colors.glassBorder', 'this.borderColor')
            
            with open(path, 'w') as file:
                file.write(content)
            print(f"Refactored {path}")
