import re

with open('/tmp/analyze.log', 'r') as f:
    lines = f.readlines()

for line in lines:
    # Look for "error • Invalid constant value • lib/..."
    if 'Invalid constant value' in line:
        parts = line.split('•')
        if len(parts) >= 3:
            path_part = parts[-2].strip()
            # path_part is like: lib/features/auth/login_screen.dart:147:59
            path, line_num, col = path_part.split(':')
            line_num = int(line_num)
            
            # read file, replace const on that line
            full_path = f'/home/dvcanache/Workspaces/notegym/{path}'
            try:
                with open(full_path, 'r') as file:
                    content_lines = file.readlines()
                    
                target_line = content_lines[line_num - 1]
                # Replace the exact word "const " with ""
                # Use regex to replace \bconst\s+ with "" since it might be preceded by spaces
                new_line = re.sub(r'\bconst\s+', '', target_line)
                content_lines[line_num - 1] = new_line
                
                with open(full_path, 'w') as file:
                    file.writelines(content_lines)
                print(f"Fixed const in {path}:{line_num}")
            except Exception as e:
                print(f"Error processing {path}:{line_num}: {e}")
