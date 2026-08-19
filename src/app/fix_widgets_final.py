#!/usr/bin/env python3
"""Apply minimal fixes to make the build pass"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

# Fixes based on actual UI widget names
fixes = {
    # Register page - use actual UI names
    'ui->txtUsername_register': 'ui->txtUsr_register',
    'ui->txtPassword_register': 'ui->txtPwd1_register',
    'ui->txtPasswordConfirm_register': 'ui->txtPwd2_register',
    'ui->barPasswordStrength_register': 'ui->barPasswordStrenght_register',
    
    # Login page
    'ui->txtUsername_login': 'ui->txtUsername_login',  # this one matches
    'ui->txtPassword_login': 'ui->txtPassword_login',  # this one matches
    
    # Loan database browse string fix
    'tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*")": 'tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*))',
    
    # Add Books page - actual UI names: txtTitle_book, txtAuthor_book, txtId_book
    'ui->txtTitle_addbooks': 'ui->txtTitle_book',
    'ui->txtAuthor_addbooks': 'ui->txtAuthor_book',
    'ui->txtID_addbooks': 'ui->txtId_book',
    'ui->cboLocation_addbooks': 'ui->cboLocation_book',
    'ui->cboCategory_addbooks': 'ui->cboCategory_book',
    'ui->cboStatus_addbooks': 'ui->cboStatus_book',
    'ui->btnAddBook_addbooks': 'ui->btnAdd_book',
    'ui->btnUndoAdd_addbooks': 'ui->btnUndoAdd_book',
    'ui->btnClear_title_addbooks': 'ui->btnClear_title_book',
    'ui->btnClear_author_addbooks': 'ui->btnClear_author_book',
    'ui->btnClear_id_addbooks': 'ui->btnClear_id_book',
    'ui->lstSearch_editbooks': 'ui->lstSearch_book_edit',
    
    # Edit Books page - already correct with _edit suffix
    'ui->txtTitle_editbooks': 'ui->txtTitle_book_edit',
    'ui->txtAuthor_editbooks': 'ui->txtAuthor_book_edit',
    'ui->txtID_editbooks': 'ui->txtId_book_edit',
    'ui->cboLocation_editbooks': 'ui->cboLocation_book_edit',
    'ui->cboCategory_editbooks': 'ui->cboCategory_book_edit',
    'ui->cboStatus_editbooks': 'ui->cboStatus_book_edit',
    'ui->btnEditBook_editbooks': 'ui->btnEdit_book',
    'ui->btnUndoEdit_editbooks': 'ui->btnUndoEdit_book',
    'ui->btnUndoAdd_editbooks': 'ui->btnUndoAdd_book',
    'ui->btnClear_title_editbooks': 'ui->btnClear_title_book_edit',
    'ui->btnClear_author_editbooks': 'ui->btnClear_author_book_edit',
    'ui->btnClear_id_editbooks': 'ui->btnClear_id_book_edit',
    'ui->txtSearch_editbooks': 'ui->txtSearch_book_edit',
    'ui->btnSearch_editbooks': 'ui->btnSearch_book_edit',
    'ui->lstSearch_editbooks': 'ui->lstSearch_book_edit',
    
    # Remove Books page
    'ui->txtTitle_removebooks': 'ui->txtTitle_book_remove',
    'ui->txtAuthor_removebooks': 'ui->txtAuthor_book_remove',
    'ui->txtID_removebooks': 'ui->txtId_book_remove',
    'ui->cboCategory_removebooks': 'ui->cboCategory_book_remove',
    'ui->cboLocation_removebooks': 'ui->cboLocation_book_remove',
    'ui->cboStatus_removebooks': 'ui->cboStatus_book_remove',
    'ui->btnRemove_removebooks': 'ui->btnRemove_book',
    'ui->btnUndoRemoval_removebooks': 'ui->btnUndoRemoval_book',
    'ui->btnUndoLast_removebooks': 'ui->btnUndoLast_book',
    'ui->btnSearch_removebooks': 'ui->btnSearch_book_remove',
    'ui->lstSearch_removebooks': 'ui->lstSearch_book_remove',
    
    # Undo Books page
    'ui->txtSearch_undoremovebooks': 'ui->txtSearch_book_undo',
    'ui->btnSearch_undoremovebooks': 'ui->btnSearch_book_undo',
    'ui->txtValue_undoremovebooks': 'ui->txtValue_book_undo',
    'ui->cboValue_undoremovebooks': 'ui->cboValue_book_undo',
    'ui->btnUndoAll_undoremovebooks': 'ui->btnUndoAll_book_undo',
    'ui->btnUndoSelected_undoremovebooks': 'ui->btnUndoSelected_book_undo',
    'ui->btnRedoRemove_undoremovebooks': 'ui->btnRedoRemove_book_undo',
    'ui->btnRedoAllSelected_undoremovebooks': 'ui->btnRedoAllSelected_book_undo',
    'ui->lstSearch_undoremovebooks': 'ui->lstSearch_book_undo',
    
    # Manage Categories page
    'ui->txtSearch_managecategories': 'ui->txtSearch_category',
    'ui->btnSearch_managecategories': 'ui->btnSearch_category',
    'ui->lstSearch_managecategories': 'ui->lstSearch_category',
    'ui->txtName_managecategories': 'ui->txtName_category',
    'ui->btnClear_name_managecategories': 'ui->btnClear_name_category',
    'ui->btnAddCategory_managecategories': 'ui->btnAdd_category',
    'ui->btnEditCategory_managecategories': 'ui->btnEdit_category',
    'ui->btnRemoveCategory_managecategories': 'ui->btnRemove_category',
    'ui->btnUndoRemove_managecategories': 'ui->btnUndoRemove_category',
    'ui->btnUndoEdit_managecategories': 'ui->btnUndoEdit_category',
    'ui->btnUndoAdd_managecategories': 'ui->btnUndoAdd_category',
    
    # Manage Locations page
    'ui->txtSearch_managelocations': 'ui->txtSearch_location',
    'ui->btnSearch_managelocations': 'ui->btnSearch_location',
    'ui->lstSearch_managelocations': 'ui->lstSearch_location',
    'ui->txtName_managelocations': 'ui->txtName_location',
    'ui->btnClear_name_managelocations': 'ui->btnClear_name_location',
    'ui->btnAddLocation_managelocations': 'ui->btnAdd_location',
    'ui->btnEditLocation_managelocations': 'ui->btnEdit_location',
    'ui->btnRemoveLocation_managelocations': 'ui->btnRemove_location',
    'ui->btnUndoRemove_managelocations': 'ui->btnUndoRemove_location',
    'ui->btnUndoEdit_managelocations': 'ui->btnUndoEdit_location',
    'ui->btnUndoAdd_managelocations': 'ui->btnUndoAdd_location',
    
    # Add Readers page
    'ui->txtName_addreaders': 'ui->txtName_reader',
    'ui->txtSurname_addreaders': 'ui->txtSurname_reader',
    'ui->txtGrade_addreaders': 'ui->txtGrade_reader',
    'ui->txtClass_addreaders': 'ui->txtClass_reader',
    'ui->txtID_addreaders': 'ui->txtId_reader',
    'ui->btnClear_name_addreaders': 'ui->btnClear_name_reader',
    'ui->btnClear_surname_addreaders': 'ui->btnClear_surname_reader',
    'ui->btnClear_grade_addreaders': 'ui->btnClear_grade_reader',
    'ui->btnClear_class_addreaders': 'ui->btnClear_class_reader',
    'ui->btnClear_id_addreaders': 'ui->btnClear_id_reader',
    'ui->btnAddBook_addreaders': 'ui->btnAdd_reader',
    'ui->btnUndoAdd_addreaders': 'ui->btnUndoAdd_reader',
    
    # Edit Readers page
    'ui->txtSearch_editreaders': 'ui->txtSearch_reader_edit',
    'ui->btnSearch_editreaders': 'ui->btnSearch_reader_edit',
    'ui->lstSearch_editreaders': 'ui->lstSearch_reader_edit',
    'ui->txtName_editreaders': 'ui->txtName_reader_edit',
    'ui->txtSurname_editreaders': 'ui->txtSurname_reader_edit',
    'ui->txtGrade_editreaders': 'ui->txtGrade_reader_edit',
    'ui->txtClass_editreaders': 'ui->txtClass_reader_edit',
    'ui->txtID_editreaders': 'ui->txtId_reader_edit',
    'ui->btnEditBook_editreaders': 'ui->btnEdit_reader',
    'ui->btnUndoEdit_editreaders': 'ui->btnUndoEdit_reader',
    'ui->btnClear_name_editreaders': 'ui->btnClear_name_reader_edit',
    'ui->btnClear_surname_editreaders': 'ui->btnClear_surname_reader_edit',
    'ui->btnClear_grade_editreaders': 'ui->btnClear_grade_reader_edit',
    'ui->btnClear_class_editreaders': 'ui->btnClear_class_reader_edit',
    'ui->btnClear_id_editreaders': 'ui->btnClear_id_reader_edit',
    
    # Remove Readers page
    'ui->txtSearch_removereaders': 'ui->txtSearch_reader_remove',
    'ui->btnSearch_removereaders': 'ui->btnSearch_reader_remove',
    'ui->lstSearch_removereaders': 'ui->lstSearch_reader_remove',
    'ui->txtName_removereaders': 'ui->txtName_reader_remove',
    'ui->txtSurname_removereaders': 'ui->txtSurname_reader_remove',
    'ui->txtGrade_removereaders': 'ui->txtGrade_reader_remove',
    'ui->txtClass_removereaders': 'ui->txtClass_reader_remove',
    'ui->txtID_removereaders': 'ui->txtId_reader_remove',
    'ui->btnClear_name_removereaders': 'ui->btnClear_name_reader_remove',
    'ui->btnClear_surname_removereaders': 'ui->btnClear_surname_reader_remove',
    'ui->btnClear_grade_removereaders': 'ui->btnClear_grade_reader_remove',
    'ui->btnClear_class_removereaders': 'ui->btnClear_class_reader_remove',
    'ui->btnClear_id_removereaders': 'ui->btnClear_id_reader_remove',
    'ui->btnRemove_removereaders': 'ui->btnRemove_reader',
    'ui->btnUndoRemoval_removereaders': 'ui->btnUndoRemoval_reader',
    'ui->btnUndoLast_removereaders': 'ui->btnUndoLast_reader',
    'ui->cboFilter_removereaders': 'ui->cboFilter_reader_remove',
    
    # Undo Readers page
    'ui->txtSearch_undoremovereaders': 'ui->txtSearch_reader_undo',
    'ui->btnSearch_undoremovereaders': 'ui->btnSearch_reader_undo',
    'ui->txtValue_undoremovereaders': 'ui->txtValue_reader_undo',
    'ui->cboValue_undoremovereaders': 'ui->cboValue_reader_undo',
    'ui->btnUndoAll_undoremovereaders': 'ui->btnUndoAll_reader_undo',
    'ui->btnUndoSelected_undoremovereaders': 'ui->btnUndoSelected_reader_undo',
    'ui->btnRedoRemove_undoremovereaders': 'ui->btnRedoRemove_reader_undo',
    'ui->btnRedoAllSelected_undoremovereaders': 'ui->btnRedoAllSelected_reader_undo',
    'ui->lstSearch_undoremovereaders': 'ui->lstSearch_reader_undo',
    
    # Add Loans page
    'ui->txtBookSearch_AddLoans': 'ui->txtSearch_book_add',
    'ui->txtReaderSearch_AddLoans': 'ui->txtSearch_reader_add',
    'ui->txtBookSelected_AddLoans': 'ui->txtSelected_book_add',
    'ui->txtReaderSelected_AddLoans': 'ui->txtSelected_reader_add',
    'ui->spnLoanDays_AddLoans': 'ui->spnLoanDays_loan_add',
    'ui->btnSearchBook_addloan': 'ui->btnSearch_book_add',
    'ui->btnSearchReader_clicked': 'ui->btnSearch_reader_add',
    'ui->btnAddLoan_addloan': 'ui->btnAdd_loan_add',
    'ui->btnClear_addloan': 'ui->btnClear_loan_add',
    'ui->cboReaderSearchField_AddLoans': 'ui->cboSearchField_reader_loan_add',
    'ui->lstSearchReaders_AddLoans': 'ui->lstSearch_reader_loan_add',
    
    # Edit Loans page
    'ui->txtLoanSearch_EditLoans': 'ui->txtSearch_loan_edit',
    'ui->txtLoanSelected_EditLoans': 'ui->txtSelected_loan_edit',
    'ui->txtDueDate_EditLoans': 'ui->txtDueDate_loan_edit',
    'ui->txtReturnDate_EditLoans': 'ui->txtReturnDate_loan_edit',
    'ui->cboStatus_EditLoans': 'ui->cboStatus_loan_edit',
    'ui->cboLoanSearchField_EditLoans': 'ui->cboSearchField_loan_edit',
    'ui->lstSearch_EditLoans': 'ui->lstSearch_loan_edit',
    'ui->btnSearchLoan_editloan': 'ui->btnSearch_loan_edit',
    'ui->btnUpdateLoan_editloan': 'ui->btnUpdate_loan_edit',
    'ui->btnReturnLoan_editloan': 'ui->btnReturn_loan_edit',
    'ui->btnClear_editloan': 'ui->btnClear_loan_edit',
    
    # Loan Statuses page
    'ui->txtSearch_LoanStatuses': 'ui->txtSearch_loan_status',
    'ui->cboStatusFilter_LoanStatuses': 'ui->cboStatusFilter_loan_status',
    'ui->lstSearch_LoanStatuses': 'ui->lstSearch_loan_status',
    'ui->btnSearch_loanstatus': 'ui->btnSearch_loan_status',
    'ui->btnRefresh_loanstatus': 'ui->btnRefresh_loan_status',
    'ui->btnOverdueReport_loanstatus': 'ui->btnOverdueReport_loan_status',
    'ui->btnFilter_loanstatus': 'ui->btnFilter_loan_status',
    'ui->cboStatusFilter_LoanStatuses': 'ui->cboStatusFilter_loan_status',
    'ui->lstSearch_LoanStatuses': 'ui->lstSearch_loan_status',
}

for old, new in replacements.items():
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        print(f"Fixed {count}x: {old} -> {new}")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")