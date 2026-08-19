#!/usr/bin/env python3
"""Fix only the malformed XML tags in the DB selection page (page_17)"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'r') as f:
    content = f.read()

import re

# Find the page_17 section and fix only that
# The page_17 starts with <widget class="QWidget" name="page_17">
# and ends before the closing of QStackedWidget

# Find the page_17 section
page17_start = content.find('<widget class="QWidget" name="page_17">')
if page17_start == -1:
    print("page_17 not found!")
    exit(1)

# Find the end of page_17 (next </widget> that closes page_17)
# We need to find the matching closing tag
# Count nesting level
pos = page17_start
level = 0
page17_end = -1
while pos < len(content):
    # Find next <widget or </widget>
    widget_start = content.find('<widget', pos)
    widget_end = content.find('</widget>', pos)
    
    if widget_end == -1:
        break
    
    if widget_start != -1 and widget_start < widget_end:
        level += 1
        pos = widget_start + 7
    else:
        level -= 1
        if level == 0:
            page17_end = widget_end + 9  # length of '</widget>'
            break
        pos = widget_end + 9

if page17_end == -1:
    print("Could not find end of page_17")
    exit(1)

# Extract page_17 section
page17 = content[page17_start:page17_end]

# Fix only the page_17 section
def fix_section(section):
    import re
    # Fix rect elements that are missing closing tags
    section = re.sub(r'(<x>)(\d+)(?!</x>)', r'\1\2</x>', section)
    section = re.sub(r'(<y>)(\d+)(?!</y>)', r'\1\2</y>', section)
    section = re.sub(r'(<width>)(\d+)(?!</width>)', r'\1\2</width>', section)
    section = re.sub(r'(<height>)(\d+)(?!</height>)', r'\1\2</height>', section)
    # Fix font tags
    section = re.sub(r'(<pointsize>)(\d+)(?!</pointsize>)', r'\1\2</pointsize>', section)
    section = re.sub(r'(<bold>)(true|false)(?!</bold>)', r'\1\2</bold>', section)
    # Fix text tags
    section = re.sub(r'(<string>)([^<\n]+)(?!</string>)', r'\1\2</string>', section)
    return section

fixed_page17 = fix_section(page17)

# Replace the section in content
content = content[:page17_start] + fixed_page17 + content[page17_end:]

# Write fixed content
with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'w') as f:
    f.write(content)

print("Fixed XML tags in page_17 only")