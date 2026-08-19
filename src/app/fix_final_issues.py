#!/usr/bin/env python3
"""Fix remaining widget references"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

replacements = {
    # Remove Readers page - use correct UI names (without _addreaders)
    'ui->txtName_addreaders_remove': 'ui->txtName_reader_remove',
    'ui->txtSurname_addreaders_remove': 'ui->txtSurname_reader_remove',
    'ui->txtGrade_addreaders_remove': 'ui->txtGrade_reader_remove',
    'ui->txtClass_addreaders_remove': 'ui->txtClass_reader_remove',
    'ui->txtID_addreaders_remove': 'ui->txtId_reader_remove',
    
    # Undo Books page - fix function name
    'on_btnSearch_undoremovebooks_clicked': 'on_btnSearch_book_undo_clicked',
    
    # Remove Books page search
    'ui->txtSearch_removebooks': 'ui->txtSearch_book_remove',
    'ui->lstSearch_removebooks': 'ui->lstSearch_book_remove',
    
    # Login page
    'ui->txtUsr_register_3': 'ui->txtUsr_register',
    'ui->txtPwd1_register_3': 'ui->txtPwd1_register',
    'ui->txtPwd2_register': 'ui->txtPassword2_register',
    
    # Register page
    'ui->txtPwd2_register': 'ui->txtPassword2_register',
    
    # Undo Books page - fix function name
    'on_btnSearch_undoremovebooks_clicked': 'on_btnSearch_book_undo_clicked',
    
    # Reader remove page in undo section
    'ui->txtName_addreaders_remove': 'ui->txtName_reader_remove',
    'ui->txtSurname_addreaders_remove': 'ui->txtSurname_reader_remove',
    'ui->txtGrade_addreaders_remove': 'ui->txtGrade_reader_remove',
    'ui->txtClass_addreaders_remove': 'ui->txtClass_reader_remove',
    'ui->txtID_addreaders_remove': 'ui->txtId_reader_remove',
}

for old, new in replacements.items():
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        print(f"Fixed {count}x: {old} -> {new}")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")