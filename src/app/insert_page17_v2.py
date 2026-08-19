#!/usr/bin/env python3
"""Insert page_17 before the closing of QStackedWidget"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'r') as f:
    content = f.read()

# Find the exact insertion point - before the </widget> that closes QStackedWidget
# Line 5241 is the closing of QStackedWidget
# We need to insert before that line

# Read the page17 content
with open('/home/sb3x/Code/ShelfSight/src/src/app/page17_content.py', 'r') as f:
    page17_file = f.read()

import re
match = re.search(r'page17 = """(.*?)"""', page17_file, re.DOTALL)
if match:
    page17 = match.group(1)
else:
    print("Could not extract page17")
    exit(1)

# Split content into lines
lines = content.split('\n')

# Find line 5241 (index 5240) which is the closing of QStackedWidget
# We'll insert before this line (index 5240)
insert_line = 5240  # 0-indexed

lines = content.split('\n')
if len(lines) > 5240:
    # Insert before line 5241 (index 5240)
    new_lines = lines[:5240] + [page17.strip()] + lines[5240:]
    new_content = '\n'.join(new_lines)
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'w') as f:
        f.write(new_content)
    
    print("Inserted page_17 successfully")
else:
    print("File too short!")
    exit(1)