#!/usr/bin/env python3
"""
Update C++ code to match new widget names
"""

# Mapping from old widget references to new ones
replacements = {
    # Register page
    'txtUsr_register': 'txtUsername_register',
    'txtPwd1_register': 'txtPassword_register',
    'txtPwd2_register': 'txtPasswordConfirm_register',
    'txtPassword2_register': 'txtPasswordConfirm_register',
    
    # Login page
    'txtUsr_register_3': 'txtUsername_login',
    'txtPwd1_register_3': 'txtPassword_login',
    
    # Add Books page
    'txtTitle_addbooks': 'txtTitle_book_add',
    'txtAuthor_addbooks': 'txtAuthor_book_add',
    'txtID_addbooks': 'txtId_book_add',
    'cboLocation_addbooks': 'cboLocation_book_add',
    'cboCategory_addbooks': 'cboCategory_book_add',
    'cboStatus_addbooks': 'cboStatus_book_add',
    'btnAddBook_addbooks': 'btnAdd_book_add',
    'btnUndoAdd_addbooks': 'btnUndoAdd_book_add',
    'btnClear_title_addbooks': 'btnClear_title_book_add',
    'btnClear_author_addbooks': 'btnClear_author_book_add',
    'btnClear_id_addbooks': 'btnClear_id_book_add',
    'lstSearch_editbooks': 'lstSearch_book_edit',  # this was on edit page, but referenced in add books
    
    # Edit Books page
    'txtTitle_editbooks': 'txtTitle_book_edit',
    'txtAuthor_editbooks': 'txtAuthor_book_edit',
    'txtID_editbooks': 'txtId_book_edit',
    'cboLocation_editbooks': 'cboLocation_book_edit',
    'cboCategory_editbooks': 'cboCategory_book_edit',
    'cboStatus_editbooks': 'cboStatus_book_edit',
    'btnEditBook_editbooks': 'btnEdit_book_edit',
    'btnUndoEdit_editbooks': 'btnUndoEdit_book_edit',
    'btnClear_title_editbooks': 'btnClear_title_book_edit',
    'btnClear_author_editbooks': 'btnClear_author_book_edit',
    'btnClear_id_editbooks': 'btnClear_id_book_edit',
    'txtSearch_editbooks': 'txtSearch_book_edit',
    'btnSearch_editbooks': 'btnSearch_book_edit',
    'lstSearch_editbooks': 'lstSearch_book_edit',
    
    # Remove Books page
    'txtSearch_removebooks': 'txtSearch_book_remove',
    'btnSearch_removebooks': 'btnSearch_book_remove',
    'btnClear_title_removebooks': 'btnClear_title_book_remove',
    'btnClear_author_removebooks': 'btnClear_author_book_remove',
    'btnClear_id_removebooks': 'btnClear_id_book_remove',
    'txtTitle_removebooks': 'txtTitle_book_remove',
    'txtAuthor_removebooks': 'txtAuthor_book_remove',
    'txtID_removebooks': 'txtId_book_remove',
    'cboCategory_removebooks': 'cboCategory_book_remove',
    'cboLocation_removebooks': 'cboLocation_book_remove',
    'cboStatus_removebooks': 'cboStatus_book_remove',
    'btnRemove_removebooks': 'btnRemove_book_remove',
    'btnUndoRemoval_removebooks': 'btnUndoRemoval_book_remove',
    'btnUndoLast_removebooks': 'btnUndoLast_book_remove',
    'lstSearch_removebooks': 'lstSearch_book_remove',
    
    # Undo Removed Books page
    'txtValue_undoremovebooks': 'txtValue_book_undo',
    'txtSearch_undoremovebooks': 'txtSearch_book_undo',
    'btnSearch_undoremovebooks': 'btnSearch_book_undo',
    'btnUndoAll_undoremovebooks': 'btnUndoAll_book_undo',
    'btnUndoSelected_undoremovebooks': 'btnUndoSelected_book_undo',
    'btnRedoRemove_undoremovebooks': 'btnRedoRemove_book_undo',
    'btnRedoAllSelected_undoremovebooks': 'btnRedoAllSelected_book_undo',
    'lstSearch_undoremovebooks': 'lstSearch_book_undo',
    'cboValue_undoremovebooks': 'cboValue_book_undo',
    
    # Manage Categories page
    'txtSearch_managecategories': 'txtSearch_category',
    'btnSearch_managecategories': 'btnSearch_category',
    'lstSearch_managecategories': 'lstSearch_category',
    'txtName_managecategories': 'txtName_category',
    'btnClear_name_managecategories': 'btnClear_name_category',
    'btnAddCategory_managecategories': 'btnAdd_category',
    'btnEditCategory_managecategories': 'btnEdit_category',
    'btnRemoveCategory_managecategories': 'btnRemove_category',
    'btnUndoRemove_managecategories': 'btnUndoRemove_category',
    'btnUndoEdit_managecategories': 'btnUndoEdit_category',
    'btnUndoAdd_managecategories': 'btnUndoAdd_category',
    
    # Manage Locations page
    'txtSearch_managelocations': 'txtSearch_location',
    'btnSearch_managelocations': 'btnSearch_location',
    'lstSearch_managelocations': 'lstSearch_location',
    'txtName_managelocations': 'txtName_location',
    'btnClear_name_managelocations': 'btnClear_name_location',
    'btnAddLocation_managelocations': 'btnAdd_location',
    'btnEditLocation_managelocations': 'btnEdit_location',
    'btnRemoveLocation_managelocations': 'btnRemove_location',
    'btnUndoRemove_managelocations': 'btnUndoRemove_location',
    'btnUndoEdit_managelocations': 'btnUndoEdit_location',
    'btnUndoAdd_managelocations': 'btnUndoAdd_location',
    
    # Add Readers page
    'txtName_addreaders': 'txtName_reader_add',
    'txtSurname_addreaders': 'txtSurname_reader_add',
    'txtGrade_addreaders': 'txtGrade_reader_add',
    'txtClass_addreaders': 'txtClass_reader_add',
    'txtID_addreaders': 'txtId_reader_add',
    'btnClear_name_addreaders': 'btnClear_name_reader_add',
    'btnClear_surname_addreaders': 'btnClear_surname_reader_add',
    'btnClear_grade_addreaders': 'btnClear_grade_reader_add',
    'btnClear_class_addreaders': 'btnClear_class_reader_add',
    'btnClear_id_addreaders': 'btnClear_id_reader_add',
    'btnAddBook_addreaders': 'btnAdd_reader_add',
    'btnUndoAdd_addreaders': 'btnUndoAdd_reader_add',
    'chkAutogenerateID_addreaders': 'chkAutogenerateId_reader_add',
    'cboIDtypes_addreaders': 'cboIdType_reader_add',
    'txtIDlength_addreaders': 'txtIdLength_reader_add',
    'chkUniqueID_addreaders': 'chkUniqueId_reader_add',
    
    # Edit Readers page
    'txtSearch_editreaders': 'txtSearch_reader_edit',
    'btnSearch_editreaders': 'btnSearch_reader_edit',
    'lstSearch_editreaders': 'lstSearch_reader_edit',
    'txtName_editreaders': 'txtName_reader_edit',
    'txtSurname_editreaders': 'txtSurname_reader_edit',
    'txtGrade_editreaders': 'txtGrade_reader_edit',
    'txtClass_editreaders': 'txtClass_reader_edit',
    'txtID_editreaders': 'txtId_reader_edit',
    'btnClear_name_editreaders': 'btnClear_name_reader_edit',
    'btnClear_surname_editreaders': 'btnClear_surname_reader_edit',
    'btnClear_grade_editreaders': 'btnClear_grade_reader_edit',
    'btnClear_class_editreaders': 'btnClear_class_reader_edit',
    'btnClear_id_editreaders': 'btnClear_id_reader_edit',
    'btnEditBook_editreaders': 'btnEdit_reader_edit',
    'btnUndoEdit_editreaders': 'btnUndoEdit_reader_edit',
    
    # Remove Readers page
    'txtSearch_removereaders': 'txtSearch_reader_remove',
    'btnSearch_removereaders': 'btnSearch_reader_remove',
    'lstSearch_removereaders': 'lstSearch_reader_remove',
    'txtName_removereaders': 'txtName_reader_remove',
    'txtSurname_removereaders': 'txtSurname_reader_remove',
    'txtGrade_removereaders': 'txtGrade_reader_remove',
    'txtClass_removereaders': 'txtClass_reader_remove',
    'txtID_removereaders': 'txtId_reader_remove',
    'btnClear_name_removereaders': 'btnClear_name_reader_remove',
    'btnClear_surname_removereaders': 'btnClear_surname_reader_remove',
    'btnClear_grade_removereaders': 'btnClear_grade_reader_remove',
    'btnClear_class_removereaders': 'btnClear_class_reader_remove',
    'btnClear_id_removereaders': 'btnClear_id_reader_remove',
    'btnRemove_removereaders': 'btnRemove_reader_remove',
    'btnUndoRemoval_removereaders': 'btnUndoRemoval_reader_remove',
    'btnUndoLast_removereaders': 'btnUndoLast_reader_remove',
    'cboFilter_removereaders': 'cboFilter_reader_remove',
    
    # Undo Removed Readers page
    'txtValue_undoremovereaders': 'txtValue_reader_undo',
    'txtSearch_undoremovereaders': 'txtSearch_reader_undo',
    'btnSearch_undoremovereaders': 'btnSearch_reader_undo',
    'btnUndoAll_undoremovereaders': 'btnUndoAll_reader_undo',
    'btnUndoSelected_undoremovereaders': 'btnUndoSelected_reader_undo',
    'btnRedoRemove_undoremovereaders': 'btnRedoRemove_reader_undo',
    'btnRedoAllSelected_undoremovereaders': 'btnRedoAllSelected_reader_undo',
    'lstSearch_undoremovereaders': 'lstSearch_reader_undo',
    'cboValue_undoremovereaders': 'cboValue_reader_undo',
    
    # Add Loans page
    'txtBookSearch_AddLoans': 'txtSearch_book_add',
    'txtReaderSearch_AddLoans': 'txtSearch_reader_add',
    'txtBookSelected_AddLoans': 'txtSelected_book_add',
    'txtReaderSelected_AddLoans': 'txtSelected_reader_add',
    'btnSearchBook_addloan': 'btnSearch_book_add',
    'btnSearchReader_clicked': 'btnSearch_reader_add',
    'btnAddLoan_addloan': 'btnAdd_loan_add',
    'btnClear_addloan': 'btnClear_loan_add',
    'spnLoanDays_AddLoans': 'spnLoanDays_loan_add',
    'cboReaderSearchField_AddLoans': 'cboSearchField_reader_loan_add',
    'lstSearchReaders_AddLoans': 'lstSearch_reader_loan_add',
    'lstSearch_book': 'lstSearch_book_loan_add',  # on loan add page
    'lstSearch_reader': 'lstSearch_reader_loan_add',  # on loan add page
    'cboSearchField_book': 'cboSearchField_book_loan_add',
    'cboSearchField_reader': 'cboSearchField_reader_loan_add',
    'chkCheckUnreturned_loan': 'chkCheckUnreturned_loan_add',
    
    # Edit Loans page
    'txtLoanSearch_EditLoans': 'txtSearch_loan_edit',
    'txtLoanSelected_EditLoans': 'txtSelected_loan_edit',
    'txtDueDate_EditLoans': 'txtDueDate_loan_edit',
    'txtReturnDate_EditLoans': 'txtReturnDate_loan_edit',
    'btnUpdateLoan_editloan': 'btnUpdate_loan_edit',
    'btnReturnLoan_editloan': 'btnReturn_loan_edit',
    'btnClear_editloan': 'btnClear_loan_edit',
    'cboLoanSearchField_EditLoans': 'cboSearchField_loan_edit',
    'cboStatus_EditLoans': 'cboStatus_loan_edit',
    'lstSearch_EditLoans': 'lstSearch_loan_edit',
    
    # Loan Statuses page
    'txtSearch_LoanStatuses': 'txtSearch_loan_status',
    'cboStatusFilter_LoanStatuses': 'cboStatusFilter_loan_status',
    'lstSearch_LoanStatuses': 'lstSearch_loan_status',
    
    # Other
    'database_books': 'database_books',  # variable, keep
    'database_readers': 'database_readers',
    'database_loans': 'database_loans',
}

if __name__ == '__main__':
    # Update mainwindow.cpp
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
        content = f.read()
    
    for old, new in replacements.items():
        # Replace ui->old with ui->new
        count = content.count(f'ui->{old}')
        if count > 0:
            content = content.replace(f'ui->{old}', f'ui->{new}')
            print(f"Replaced {count}x: ui->{old} -> ui->{new}")
        
        # Also replace bare references (less likely but possible)
        count2 = content.count(f' {old}')
        if count2 > 0 and old != new:
            # Be more careful with bare replacements
            pass
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
        f.write(content)
    
    print("Updated mainwindow.cpp")
    
    # Update mainwindow.h - slot declarations
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.h', 'r') as f:
        content = f.read()
    
    # Slot name mappings
    slot_replacements = {
        'on_btnClear_title_book_clicked': 'on_btnClear_title_book_add_clicked',
        'on_btnClear_author_book_clicked': 'on_btnClear_author_book_add_clicked',
        'on_btnClear_id_book_clicked': 'on_btnClear_id_book_add_clicked',
        'on_btnUndoAdd_book_clicked': 'on_btnUndoAdd_book_add_clicked',
        'on_btnClear_title_book_edit_clicked': 'on_btnClear_title_book_edit_clicked',
        'on_btnClear_author_book_edit_clicked': 'on_btnClear_author_book_edit_clicked',
        'on_btnClear_id_book_edit_clicked': 'on_btnClear_id_book_edit_clicked',
        'on_btnUndoEdit_book_clicked': 'on_btnUndoEdit_book_edit_clicked',
        'on_btnEdit_book_clicked': 'on_btnEdit_book_edit_clicked',
        'on_btnSearch_book_edit_clicked': 'on_btnSearch_book_edit_clicked',
        'on_btnClear_name_category_clicked': 'on_btnClear_name_category_clicked',
        'on_btnUndoAdd_book_clicked': 'on_btnUndoAdd_book_add_clicked',
        'on_btnUndoRemove_category_clicked': 'on_btnUndoRemove_category_clicked',
        'on_btnUndoEdit_category_clicked': 'on_btnUndoEdit_category_clicked',
        'on_btnUndoAdd_category_clicked': 'on_btnUndoAdd_category_clicked',
        'on_btnAdd_category_clicked': 'on_btnAdd_category_clicked',
        'on_btnEdit_category_clicked': 'on_btnEdit_category_clicked',
        'on_btnRemove_category_clicked': 'on_btnRemove_category_clicked',
        'on_btnSearch_undobooks_clicked': 'on_btnSearch_book_undo_clicked',
        'on_btnSearch_book_remove_clicked': 'on_btnSearch_book_remove_clicked',
        'on_btnUndoAll_undobooks_clicked': 'on_btnUndoAll_book_undo_clicked',
        'on_btnSearch_location_clicked': 'on_btnSearch_location_clicked',
        'on_btnClear_name_location_clicked': 'on_btnClear_name_location_clicked',
        'on_btnRemove_location_clicked': 'on_btnRemove_location_clicked',
        'on_btnEdit_location_clicked': 'on_btnEdit_location_clicked',
        'on_btnAdd_location_clicked': 'on_btnAdd_location_clicked',
        'on_btnUndoRemove_location_clicked': 'on_btnUndoRemove_location_clicked',
        'on_btnUndoAdd_location_clicked': 'on_btnUndoAdd_location_clicked',
        'on_btnUndoEdit_location_clicked': 'on_btnUndoEdit_location_clicked',
        'on_btnUndoSelected_undobooks_clicked': 'on_btnUndoSelected_book_undo_clicked',
        'on_btnRedoRemove_undobooks_clicked': 'on_btnRedoRemove_book_undo_clicked',
        'on_btnRedoAllSelected_undobooks_clicked': 'on_btnRedoAllSelected_book_undo_clicked',
        'on_btnSearch_undoreaders_clicked': 'on_btnSearch_reader_undo_clicked',
        'on_btnClear_name_reader_clicked': 'on_btnClear_name_reader_add_clicked',
        'on_btnClear_surname_reader_clicked': 'on_btnClear_surname_reader_add_clicked',
        'on_btnClear_grade_reader_clicked': 'on_btnClear_grade_reader_add_clicked',
        'on_btnClear_class_reader_clicked': 'on_btnClear_class_reader_add_clicked',
        'on_btnClear_id_reader_clicked': 'on_btnClear_id_reader_add_clicked',
        'on_btnAdd_reader_clicked': 'on_btnAdd_reader_add_clicked',
        'on_btnEdit_reader_clicked': 'on_btnEdit_reader_edit_clicked',
        'on_btnUndoEdit_reader_clicked': 'on_btnUndoEdit_reader_edit_clicked',
        'on_btnRemove_book_clicked': 'on_btnRemove_book_remove_clicked',
        'on_btnSearch_reader_edit_clicked': 'on_btnSearch_reader_edit_clicked',
        'on_btnSearch_reader_remove_clicked': 'on_btnSearch_reader_remove_clicked',
        'on_btnRemove_reader_clicked': 'on_btnRemove_reader_remove_clicked',
        'on_btnUndoRemoval_reader_clicked': 'on_btnUndoRemoval_reader_remove_clicked',
        'on_btnUndoLast_reader_clicked': 'on_btnUndoLast_reader_remove_clicked',
        'on_btnClear_name_reader_remove_clicked': 'on_btnClear_name_reader_remove_clicked',
        'on_btnClear_surname_reader_remove_clicked': 'on_btnClear_surname_reader_remove_clicked',
        'on_btnClear_grade_reader_remove_clicked': 'on_btnClear_grade_reader_remove_clicked',
        'on_btnClear_class_reader_remove_clicked': 'on_btnClear_class_reader_remove_clicked',
        'on_btnClear_id_reader_remove_clicked': 'on_btnClear_id_reader_remove_clicked',
        'on_actionAddLoans_triggered': 'on_actionAddLoans_triggered',
        'on_btnSearch_book_clicked': 'on_btnSearch_book_add_clicked',
        'on_btnSearch_reader_clicked': 'on_btnSearch_reader_add_clicked',
        'on_btnAdd_loan_clicked': 'on_btnAdd_loan_add_clicked',
        'on_btnClear_loan_clicked': 'on_btnClear_loan_add_clicked',
        'on_actionEditLoans_triggered': 'on_actionEditLoans_triggered',
        'on_actionSearchLoans_triggered': 'on_actionSearchLoans_triggered',
        'on_btnSearch_loan_clicked': 'on_btnSearch_loan_edit_clicked',
        'on_lstSearch_loan_itemClicked': 'on_lstSearch_loan_edit_itemClicked',
        'on_btnUpdate_loan_clicked': 'on_btnUpdate_loan_edit_clicked',
        'on_btnReturn_loan_clicked': 'on_btnReturn_loan_edit_clicked',
        'on_btnClear_loan_edit_clicked': 'on_btnClear_loan_edit_clicked',
        'on_btnFilter_loanstatus_clicked': 'on_btnFilter_loan_status_clicked',
        'on_btnSearch_loanstatus_clicked': 'on_btnSearch_loan_status_clicked',
        'on_btnRefresh_loanstatus_clicked': 'on_btnRefresh_loan_status_clicked',
        'on_btnOverdueReport_loanstatus_clicked': 'on_btnOverdueReport_loan_status_clicked',
        'on_lstSearch_loanstatus_itemDoubleClicked': 'on_lstSearch_loan_status_itemDoubleClicked',
    }
    
    for old, new in slot_replacements.items():
        if old in content:
            content = content.replace(old, new)
            print(f"Slot renamed: {old} -> {new}")
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.h', 'w') as f:
        f.write(content)
    
    print("Updated mainwindow.h")
    print("Done!")