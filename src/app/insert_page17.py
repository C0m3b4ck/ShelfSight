#!/usr/bin/env python3
"""Insert page_17 before the closing of QStackedWidget"""

from page17_content import page17

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'r') as f:
    content = f.read()

# Find the position to insert - before the closing of QStackedWidget
# The structure ends with: </widget>\n   </widget>\n  <widget class="QMenuBar"
# We want to insert before the first </widget> that closes the QStackedWidget

# Find the pattern: </widget>\n   </widget>\n  <widget class="QMenuBar"
insert_marker = '    </widget>\n   </widget>\n  <widget class="QMenuBar"'
pos = content.find(insert_marker)

if pos == -1:
    # Try with different spacing
    import re
    pattern = r'(    </widget>\s+</widget>\s+<widget class="QMenuBar")'
    match = re.search(pattern, content)
    if match:
        pos = match.start()
    else:
        print("Could not find insertion point!")
        exit(1)
else:
    pos = content.find(insert_marker)

if pos == -1:
    print("Could not find insertion point!")
    exit(1)

# Insert before the first </widget> in the marker (which closes the QStackedWidget)
# The marker starts with "    </widget>" which closes the QStackedWidget
# We want to insert before this </widget>
insert_pos = pos

# Read page17 content from file to avoid string escaping issues
with open('/home/sb3x/Code/ShelfSight/src/src/app/page17_content.py', 'r') as f:
    page17_content = f.read()

# Extract the page17 string from the python file
import re
match = re.search(r'page17 = """(.*?)"""', page17_content, re.DOTALL)
if match:
    page17 = match.group(1)
else:
    print("Could not extract page17 from file")
    exit(1)

# Insert the new page
new_content = content[:pos] + '\n' + page17 + '\n' + content[pos:]

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'w') as f:
    f.write(new_content)

print("Inserted page_17 successfully")