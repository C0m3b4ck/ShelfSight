#!/usr/bin/env python3
"""Fix malformed XML in mainwindow.ui"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'r') as f:
    content = f.read()

# Fix all malformed rect tags
import re

# Fix <x>value</x> -> <x>value</x> (already correct)
# Fix <y>value</y> -> <y>value</y> (already correct)
# Fix <width>value</width> -> <width>value</width> (already correct)
# Fix <height>value -> <height>value</height>

# Fix rect elements
content = re.sub(r'<x>(\d+)', r'<x>\1</x>', content)
content = re.sub(r'<y>(\d+)', r'<y>\1</y>', content)
content = re.sub(r'<width>(\d+)', r'<width>\1</width>', content)
content = re.sub(r'<height>(\d+)', r'<height>\1</height>', content)

# Fix font tags
content = re.sub(r'<pointsize>(\d+)', r'<pointsize>\1</pointsize>', content)
content = re.sub(r'<bold>(true|false)', r'<bold>\1</bold>', content)

# Fix text tags
content = re.sub(r'<string>([^<]+)$', r'<string>\1</string>', content, flags=re.MULTILINE)

# Write fixed content
with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'w') as f:
    f.write(content)

print("Fixed XML tags")

if __name__ == '__main__':
    pass