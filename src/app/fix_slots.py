#!/usr/bin/env python3
"""
Fix all slot implementation names in mainwindow.cpp to match mainwindow.h
"""

replacements = {
    # Register page
    'on_btnClear_password1_register_clicked': 'on_btnClear_password_register_clicked',
    'on_btnClear_password2_register_clicked': 'on_btnClear_passwordConfirm_register_clicked',
    'on_btnHelp_pwdStrenght_register_clicked': 'on_btnHelp_passwordStrength_register_clicked',
    'on_btnRegister_clicked': 'on_btnRegister_register_clicked',
    
    # Login page
    'on_btnLogin_clicked': 'on_btnLogin_login_clicked',
    'on_btnClear_username_login_clicked': 'on_btnClear_username_login_clicked',
    'on_btnClear_password_login_clicked': 'on_btnClear_password_login_clicked',
    'on_btnHelp_role_login_clicked': 'on_btnHelp_role_login_clicked',
    
    # Add Books
    'on_btnUndoAdd_book_clicked': 'on_btnUndoAdd_book_edit_clicked',
    
    # Book undo page
    'on_lstSearch_undobooks_itemClicked': 'on_lstSearch_book_undo_itemClicked',
    
    # Book remove page - already correct
    
    # Reader edit page
    'on_btnClear_name_reader_edit_clicked': 'on_btnClear_name_reader_edit_clicked',
    'on_btnClear_surname_reader_edit_clicked': 'on_btnClear_surname_reader_edit_clicked',
    'on_btnClear_grade_reader_edit_clicked': 'on_btnClear_grade_reader_edit_clicked',
    'on_btnClear_class_reader_edit_clicked': 'on_btnClear_class_reader_edit_clicked',
    'on_btnClear_id_reader_edit_clicked': 'on_btnClear_id_reader_edit_clicked',
    'on_btnUndoEdit_editreaders_clicked': 'on_btnUndoEdit_reader_edit_clicked',
    
    # Reader remove page
    'on_btnClear_name_reader_remove_clicked': 'on_btnClear_name_reader_remove_clicked',
    'on_btnClear_surname_reader_remove_clicked': 'on_btnClear_surname_reader_remove_clicked',
    'on_btnClear_grade_reader_remove_clicked': 'on_btnClear_grade_reader_remove_clicked',
    'on_btnClear_class_reader_remove_clicked': 'on_btnClear_class_reader_remove_clicked',
    'on_btnClear_id_reader_remove_clicked': 'on_btnClear_id_reader_remove_clicked',
    'on_btnUndoRemoval_reader_clicked': 'on_btnUndoRemoval_reader_remove_clicked',
    'on_btnUndoLast_reader_clicked': 'on_btnUndoLast_reader_remove_clicked',
    
    # Add loans page
    'on_btnSearch_book_clicked': 'on_btnSearch_book_add_clicked',
    'on_btnSearch_reader_clicked': 'on_btnSearch_reader_add_clicked',
    'on_btnAdd_loan_clicked': 'on_btnAdd_loan_add_clicked',
    'on_btnClear_loan_clicked': 'on_btnClear_loan_add_clicked',
    'on_lstSearch_book_itemClicked': 'on_lstSearch_book_loan_add_itemClicked',
    'on_lstSearch_reader_itemClicked': 'on_lstSearch_reader_loan_add_itemClicked',
    
    # Edit loans page
    'on_btnSearch_loan_edit_clicked': 'on_btnSearch_loan_edit_clicked',
    'on_lstSearch_loan_edit_itemClicked': 'on_lstSearch_loan_edit_itemClicked',
    'on_btnUpdate_loan_edit_clicked': 'on_btnUpdate_loan_edit_clicked',
    'on_btnReturn_loan_edit_clicked': 'on_btnReturn_loan_edit_clicked',
    'on_btnClear_loan_edit_clicked': 'on_btnClear_loan_edit_clicked',
    
    # Loan status page
    'on_btnFilter_loanstatus_clicked': 'on_btnFilter_loan_status_clicked',
    'on_btnSearch_loanstatus_clicked': 'on_btnSearch_loan_status_clicked',
    'on_btnRefresh_loanstatus_clicked': 'on_btnRefresh_loan_status_clicked',
    'on_btnOverdueReport_loanstatus_clicked': 'on_btnOverdueReport_loan_status_clicked',
    'on_lstSearch_loanstatus_itemDoubleClicked': 'on_lstSearch_loan_status_itemDoubleClicked',
}

if __name__ == '__main__':
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
        content = f.read()
    
    for old, new in replacements.items():
        count = content.count(f'void MainWindow::{old}(')
        if count > 0:
            content = content.replace(f'void MainWindow::{old}(', f'void MainWindow::{new}(')
            print(f"Updated: {old} -> {new} ({count}x)")
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
        f.write(content)
    
    print("Done!")