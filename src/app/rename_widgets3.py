#!/usr/bin/env python3
"""
Third pass: Fix remaining inconsistent widget names
"""

manual_map = {
    # Add Books page - missing _add suffix on fields
    'txtTitle_book': 'txtTitle_book_add',
    'txtAuthor_book': 'txtAuthor_book_add',
    'txtId_book': 'txtId_book_add',
    'cboCategory_book': 'cboCategory_book_add',
    'cboLocation_book': 'cboLocation_book_add',
    'cboStatus_book': 'cboStatus_book_add',
    'btnClear_title_book': 'btnClear_title_book_add',
    'btnClear_author_book': 'btnClear_author_book_add',
    'btnClear_id_book': 'btnClear_id_book_add',
    
    # Edit Books page - already have _edit
    # Remove Books page - already have _remove
    
    # Add Readers page - missing _add suffix on fields
    'txtName_reader': 'txtName_reader_add',
    'txtSurname_reader': 'txtSurname_reader_add',
    'txtGrade_reader': 'txtGrade_reader_add',
    'txtClass_reader': 'txtClass_reader_add',
    'txtId_reader': 'txtId_reader_add',  # already renamed to txtId_reader_add
    'btnClear_name_reader': 'btnClear_name_reader_add',
    'btnClear_surname_reader': 'btnClear_surname_reader_add',
    'btnClear_grade_reader': 'btnClear_grade_reader_add',
    'btnClear_class_reader': 'btnClear_class_reader_add',
    'btnClear_id_reader': 'btnClear_id_reader_add',  # already renamed
    
    # Edit Readers page - already have _edit
    # Remove Readers page - already have _remove
    
    # Category page - single page, no suffix needed
    # Location page - single page, no suffix needed
    
    # Loan Add page - missing _add suffix
    'btnAdd_loan': 'btnAdd_loan_add',
    'btnClear_loan': 'btnClear_loan_add',
    'txtSearch_book': 'txtSearch_book_add',
    'txtSearch_reader': 'txtSearch_reader_add',
    'txtSelected_book': 'txtSelected_book_add',
    'txtSelected_reader': 'txtSelected_reader_add',
    
    # Loan Edit page - check
    'txtSelected_loan_edit': 'txtSelected_loan_edit',  # good
    'txtDueDate_loan_edit': 'txtDueDate_loan_edit',  # good
    'txtReturnDate_loan_edit': 'txtReturnDate_loan_edit',  # good
    'cboStatus_loan_edit': 'cboStatus_loan_edit',  # good
    'cboSearchField_loan_edit': 'cboSearchField_loan_edit',  # good
    'lstSearch_loan_edit': 'lstSearch_loan_edit',  # good
    
    # Loan Status page
    'lstSearch_loan_status': 'lstSearch_loan_status',  # good
    
    # Search fields on add/edit pages
    'txtSearch_book_edit': 'txtSearch_book_edit',  # good
    'txtSearch_book_remove': 'txtSearch_book_remove',  # good
    'txtSearch_book_undo': 'txtSearch_book_undo',  # good
    'txtSearch_reader_edit': 'txtSearch_reader_edit',  # good
    'txtSearch_reader_remove': 'txtSearch_reader_remove',  # good
    'txtSearch_reader_undo': 'txtSearch_reader_undo',  # good
    
    # List widgets
    'lstSearch_book_edit': 'lstSearch_book_edit',  # good
    'lstSearch_book_remove': 'lstSearch_book_remove',  # good
    'lstSearch_book_undo': 'lstSearch_book_undo',  # good
    'lstSearch_reader_edit': 'lstSearch_reader_edit',  # good
    'lstSearch_reader_remove': 'lstSearch_reader_remove',  # good
    'lstSearch_reader_undo': 'lstSearch_reader_undo',  # good
    
    # Register page
    'txtUsername_register': 'txtUsername_register',  # good
    'txtPassword_register': 'txtPassword_register',  # good
    'txtPasswordConfirm_register': 'txtPasswordConfirm_register',  # good
    
    # Login page
    'txtUsername_login': 'txtUsername_login',  # good
    'txtPassword_login': 'txtPassword_login',  # good
}

if __name__ == '__main__':
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'r') as f:
        content = f.read()
    
    for old, new in manual_map.items():
        if f'name="{old}"' in content:
            content = content.replace(f'name="{old}"', f'name="{new}"')
            print(f"Renamed: {old} -> {new}")
        else:
            print(f"NOT FOUND: {old}")
    
    # Fix zorder
    for old, new in manual_map.items():
        if f'<zorder>{old}</zorder>' in content:
            content = content.replace(f'<zorder>{old}</zorder>', f'<zorder>{new}</zorder>')
            print(f"Fixed zorder: {old} -> {new}")
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'w') as f:
        f.write(content)
    
    print("Done!")