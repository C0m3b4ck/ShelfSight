#!/usr/bin/env python3
"""Comprehensive fix for all widget name mismatches"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'r') as f:
    ui_content = f.read()

# Extract all widget names from UI file
import re
widget_names = re.findall(r'name="([^"]+)"', ui_content)
unique_widgets = set(widget_names)

# Filter for relevant widgets (txt, btn, cbo, lst, chk, spn, bar)
relevant_widgets = [w for w in unique_widgets if any(w.startswith(p) for p in ['txt', 'btn', 'cbo', 'lst', 'chk', 'spn', 'bar'])]

print(f"Found {len(relevant_widgets)} relevant widgets")

# Read C++ file
with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    cpp_content = f.read()

# Find all ui->widget references in C++
cpp_widgets = re.findall(r'ui->(\w+)', cpp_content)
unique_cpp_widgets = set(cpp_widgets)

print(f"Found {len(unique_cpp_widgets)} unique widget references in C++")

# Find which C++ widgets don't exist in UI
missing_in_ui = [w for w in unique_cpp_widgets if w not in unique_widgets and not w.startswith('action') and not w in ['setupUi', 'workspaces']]
print(f"Widgets in C++ but not in UI: {len(missing_in_ui)}")
for w in sorted(missing_in_ui):
    print(f"  MISSING: {w}")

# Find which UI widgets aren't referenced in C++
unreferenced = [w for w in relevant_widgets if w not in unique_cpp_widgets]
print(f"Widgets in UI but not in C++: {len(unreferenced)}")
for w in sorted(unreferenced)[:50]:
    print(f"  UNREFERENCED: {w}")

# Now create a mapping from C++ names to UI names
# For widgets that don't exist in UI, try to find the closest match
mapping = {}

for missing in missing_in_ui:
    # Try to find a similar widget in UI
    # Common patterns: _add vs _edit, _remove, etc.
    base = missing
    for suffix in ['_add', '_edit', '_remove', '_addbooks', '_editbooks', '_addreaders', '_editreaders', '_addloan', '_editloan', '_addcategory', '_editcategory', '_addlocation', '_editlocation', '_managelocations', '_managecategories', '_addloan', '_editloan']:
        if missing.endswith(suffix):
            base = missing[:-len(suffix)]
            break
    
    # Try to find widget with base name
    matches = [w for w in relevant_widgets if w.startswith(base) and (w == base or w[len(base)] in ['_', ' '])]
    if matches:
        mapping[missing] = matches[0]
        print(f"MAPPED: {missing} -> {matches[0]}")

# Apply mappings
for old, new in mapping.items():
    old_pattern = f'ui->{missing}'
    new_pattern = f'ui->{new}'
    count = cpp_content.count(old_pattern)
    if count > 0:
        cpp_content = cpp_content.replace(old_pattern, new_pattern)
        print(f"Fixed {count}x: ui->{missing} -> ui->{new}")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(cpp_content)

print("Done!")