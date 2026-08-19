#!/usr/bin/env python3
"""Generate correct slot declarations and implementations from UI file"""

import re
import xml.etree.ElementTree as ET

# Parse the UI file
tree = ET.parse('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui')
root = tree.getroot()

# Extract all widgets with names
widgets = []
for widget in root.iter('widget'):
    name = widget.get('name')
    cls = widget.get('class')
    if name and name.startswith(('btn', 'txt', 'cbo', 'lst', 'chk', 'spn', 'bar')):
        widgets.append({'name': name, 'class': cls})

# Categorize widgets
buttons = [w for w in widgets if w['class'] == 'QPushButton']
text_edits = [w for w in widgets if w['class'] == 'QLineEdit']
combo_boxes = [w for w in widgets if w['class'] == 'QComboBox']
list_widgets = [w for w in widgets if w['class'] == 'QListWidget']
check_boxes = [w for w in widgets if w['class'] == 'QCheckBox']
spin_boxes = [w for w in widgets if w['class'] == 'QSpinBox']
progress_bars = [w for w in widgets if w['class'] == 'QProgressBar']

print("Buttons:", [w['name'] for w in buttons])
print("Text edits:", [w['name'] for w in text_edits])
print("Combo boxes:", [w['name'] for w in combo_boxes])
print("List widgets:", [w['name'] for w in list_widgets])
print("Check boxes:", [w['name'] for w in check_boxes])
print("Spin boxes:", [w['name'] for w in spin_boxes])
print("Progress bars:", [w['name'] for w in progress_bars])

# Generate slot declarations for buttons (clicked signal)
print("\n// Slot declarations for buttons (clicked)")
for btn in sorted(buttons, key=lambda x: x['name']):
    slot_name = f"void on_{btn['name']}_clicked();"
    print(slot_name)

# Generate slot declarations for list widgets (itemClicked signal)
print("\n// Slot declarations for list widgets (itemClicked)")
for lst in sorted(list_widgets, key=lambda x: x['name']):
    slot_name = f"void on_{lst['name']}_itemClicked(QListWidgetItem *item);"
    print(slot_name)

# Generate slot declarations for combo boxes (currentIndexChanged signal)
print("\n// Slot declarations for combo boxes (currentIndexChanged)")
for cbo in sorted(combo_boxes, key=lambda x: x['name']):
    slot_name = f"void on_{cbo['name']}_currentIndexChanged(int index);"
    print(slot_name)

# Generate slot declarations for check boxes (toggled signal)
print("\n// Slot declarations for check boxes (toggled)")
for chk in sorted(check_boxes, key=lambda x: x['name']):
    slot_name = f"void on_{chk['name']}_toggled(bool checked);"
    print(slot_name)

# Generate slot declarations for text edits (textChanged signal)
print("\n// Slot declarations for text edits (textChanged)")
for txt in sorted(text_edits, key=lambda x: x['name']):
    slot_name = f"void on_{txt['name']}_textChanged(const QString &text);"
    print(slot_name)

# Generate slot declarations for spin boxes (valueChanged signal)
print("\n// Slot declarations for spin boxes (valueChanged)")
for spn in sorted(spin_boxes, key=lambda x: x['name']):
    slot_name = f"void on_{spn['name']}_valueChanged(int value);"
    print(slot_name)

# Generate slot declarations for progress bars (valueChanged signal)
print("\n// Slot declarations for progress bars (valueChanged)")
for bar in sorted(progress_bars, key=lambda x: x['name']):
    slot_name = f"void on_{bar['name']}_valueChanged(int value);"
    print(slot_name)

# Also check for actions
actions = []
for action in root.iter('action'):
    name = action.get('name')
    if name:
        actions.append(name)

print("\n// Action slots (triggered)")
for act in sorted(actions):
    slot_name = f"void on_{act}_triggered();"
    print(slot_name)