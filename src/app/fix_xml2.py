#!/usr/bin/env python3
"""Fix malformed XML in mainwindow.ui - only fix tags that are missing closing tags"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'r') as f:
    content = f.read()

import re

# Fix rect elements that are missing closing tags
# Pattern: <x>value (no closing tag)
content = re.sub(r'(<x>)(\d+)(?!</x>)', r'\1\2</x>', content)
content = re.sub(r'(<y>)(\d+)(?!</y>)', r'\1\2</y>', content)
content = re.sub(r'(<width>)(\d+)(?!</width>)', r'\1\2</width>', content)
content = re.sub(r'(<height>)(\d+)(?!</height>)', r'\1\2</height>', content)

# Fix font tags
content = re.sub(r'(<pointsize>)(\d+)(?!</pointsize>)', r'\1\2</pointsize>', content)
content = re.sub(r'(<bold>)(true|false)(?!</bold>)', r'\1\2</bold>', content)

# Fix text tags
content = re.sub(r'(<string>)([^<\n]+)(?!</string>)', r'\1\2</string>', content)

# Write fixed content
with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'w') as f:
    f.write(content)

print("Fixed XML tags")