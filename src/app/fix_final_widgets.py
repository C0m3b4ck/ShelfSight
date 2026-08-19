#!/usr/bin/env python3
"""Fix widget names based on actual UI file"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'r') as f:
    ui_content = f.read()

import re
# Extract all widget names
widget_names = set(re.findall(r'name="([^"]+)"', ui_content))

# Read C++ content
with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

# Find all ui->widget references
cpp_widgets = set(re.findall(r'ui->(\w+)', content))

# Find which ones don't exist in UI
missing = [w for w in set(re.findall(r'ui->(\w+)', content)) if w not in widget_names and not w.startswith('action') and w not in ['setupUi', 'workspaces']]

print("Missing widgets:")
for w in sorted(missing):
    # Try to find similar widget
    matches = [w2 for w2 in widget_names if w2.startswith(w.rsplit('_', 1)[0]) or w.startswith(w.rsplit('_', 1)[0])]
    if matches:
        print(f"  {w} -> possible: {matches[:3]}")
    else:
        print(f"  {w} -> NO MATCH")

# Now fix the specific known issues
replacements = {
    # Register page - fix password confirm
    'ui->txtPwd2_register': 'ui->txtPassword2_register',
    
    # Add Readers page - use actual UI names
    'ui->txtName_reader': 'ui->txtName_addreaders',
    'ui->txtSurname_reader': 'ui->txtSurname_addreaders',
    'ui->txtGrade_reader': 'ui->txtGrade_addreaders',
    'ui->txtClass_reader': 'ui->txtClass_addreaders',
    'ui->txtId_reader': 'ui->txtID_addreaders',  # Note: ID is capitalized
    
    # Edit Readers page - already correct with _edit suffix
    
    # Remove Readers page
    'ui->txtName_reader_remove': 'ui->txtName_reader_remove',
    'ui->txtSurname_reader_remove': 'ui->txtSurname_reader_remove',
    'ui->txtGrade_reader_remove': 'ui->txtGrade_reader_remove',
    'ui->txtClass_reader_remove': 'ui->txtClass_reader_remove',
    'ui->txtId_reader_remove': 'ui->txtId_reader_remove',
    
    # Undo Books page
    'ui->txtSearch_undoremovebooks': 'ui->txtSearch_book_undo',
    'ui->cboValue_undoremovebooks': 'ui->cboValue_book_undo',
    'ui->lstSearch_undoremovebooks': 'ui->lstSearch_book_undo',
    
    # Remove Books page
    'ui->txtSearch_removebooks': 'ui->txtSearch_book_remove',
    'ui->lstSearch_removebooks': 'ui->lstSearch_book_remove',
    
    # Loan add page
    'ui->cboSearchField_reader_loan_add': 'ui->cboSearchField_reader',
    
    # Login page
    'ui->txtUsr_register_3': 'ui->txtUsr_register',
    'ui->txtPwd1_register_3': 'ui->txtPwd1_register',
    'ui->txtPwd2_register': 'ui->txtPassword2_register',
    
    # Register page
    'ui->txtPwd2_register': 'ui->txtPassword2_register',
}

for old, new in replacements.items():
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        print(f"Fixed {count}x: {old} -> {new}")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")