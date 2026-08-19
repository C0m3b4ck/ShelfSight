#!/usr/bin/env python3
"""Fix widget names in mainwindow.cpp"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

# Fix the loan database browse string
content = content.replace(
    'tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*")");',
    'tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*))");'
)

# Register page - use actual UI names
content = content.replace('ui->txtUsername_register', 'ui->txtUsr_register')
content = content.replace('ui->txtPassword_register', 'ui->txtPwd1_register')
content = content.replace('ui->txtPasswordConfirm_register', 'ui->txtPwd2_register')
content = content.replace('barPasswordStrength_register', 'barPasswordStrenght_register')

# Add Books page
content = content.replace('ui->txtTitle_addbooks', 'ui->txtTitle_book')
content = content.replace('ui->txtAuthor_addbooks', 'ui->txtAuthor_book')
content = content.replace('ui->txtID_addbooks', 'ui->txtId_book')
content = content.replace('ui->cboLocation_addbooks', 'ui->cboLocation_book')
content = content.replace('ui->cboCategory_addbooks', 'ui->cboCategory_book')
content = content.replace('ui->cboStatus_addbooks', 'ui->cboStatus_book')
content = content.replace('ui->btnAddBook_addbooks', 'ui->btnAdd_book')
content = content.replace('ui->btnUndoAdd_addbooks', 'ui->btnUndoAdd_book')
content = content.replace('ui->btnClear_title_addbooks', 'ui->btnClear_title_book')
content = content.replace('ui->btnClear_author_addbooks', 'ui->btnClear_author_book')
content = content.replace('ui->txtID_addbooks', 'ui->txtId_book')
content = content.replace('ui->lstSearch_editbooks', 'ui->lstSearch_book_edit')

# Edit Books page
content = content.replace('ui->txtTitle_editbooks', 'ui->txtTitle_book_edit')
content = content.replace('ui->txtAuthor_editbooks', 'ui->txtAuthor_book_edit')
content = content.replace('ui->txtID_editbooks', 'ui->txtId_book_edit')
content = content.replace('ui->cboLocation_editbooks', 'ui->cboLocation_book_edit')
content = content.replace('ui->cboCategory_editbooks', 'ui->cboCategory_book_edit')
content = content.replace('ui->cboStatus_editbooks', 'ui->cboStatus_book_edit')
content = content.replace('ui->btnEditBook_editbooks', 'ui->btnEdit_book')
content = content.replace('ui->btnUndoEdit_editbooks', 'ui->btnUndoEdit_book')
content = content.replace('ui->btnUndoAdd_editbooks', 'ui->btnUndoAdd_book')
content = content.replace('ui->btnClear_title_editbooks', 'ui->btnClear_title_book_edit')
content = content.replace('ui->btnClear_author_editbooks', 'ui->btnClear_author_book_edit')
content = content.replace('ui->btnClear_id_editbooks', 'ui->btnClear_id_book_edit')
content = content.replace('ui->txtSearch_editbooks', 'ui->txtSearch_book_edit')
content = content.replace('ui->btnSearch_editbooks', 'ui->btnSearch_book_edit')
content = content.replace('ui->lstSearch_editbooks', 'ui->lstSearch_book_edit')

# Remove Books page
content = content.replace('ui->txtTitle_removebooks', 'ui->txtTitle_book_remove')
content = content.replace('ui->txtAuthor_removebooks', 'ui->txtAuthor_book_remove')
content = content.replace('ui->txtID_removebooks', 'ui->txtId_book_remove')
content = content.replace('ui->cboCategory_removebooks', 'ui->cboCategory_book_remove')
content = content.replace('ui->cboLocation_removebooks', 'ui->cboLocation_book_remove')
content = content.replace('ui->cboStatus_removebooks', 'ui->cboStatus_book_remove')
content = content.replace('ui->btnRemove_removebooks', 'ui->btnRemove_book')
content = content.replace('ui->btnUndoRemoval_removebooks', 'ui->btnUndoRemoval_book')
content = content.replace('ui->btnUndoLast_removebooks', 'ui->btnUndoLast_book')
content = content.replace('ui->btnSearch_removebooks', 'ui->btnSearch_book_remove')
content = content.replace('ui->lstSearch_removebooks', 'ui->lstSearch_book_remove')

# Undo Books page
content = content.replace('ui->txtSearch_undoremovebooks', 'ui->txtSearch_book_undo')
content = content.replace('ui->btnSearch_undoremovebooks', 'ui->btnSearch_book_undo')
content = content.replace('ui->txtValue_undoremovebooks', 'ui->txtValue_book_undo')
content = content.replace('ui->cboValue_undoremovebooks', 'ui->cboValue_book_undo')
content = content.replace('ui->btnUndoAll_undoremovebooks', 'ui->btnUndoAll_book_undo')
content = content.replace('ui->btnUndoSelected_undoremovebooks', 'ui->btnUndoSelected_book_undo')
content = content.replace('ui->btnRedoRemove_undoremovebooks', 'ui->btnRedoRemove_book_undo')
content = content.replace('ui->btnRedoAllSelected_undoremovebooks', 'ui->btnRedoAllSelected_book_undo')
content = content.replace('ui->lstSearch_undoremovebooks', 'ui->lstSearch_book_undo')

# Manage Categories page
content = content.replace('ui->txtSearch_managecategories', 'ui->txtSearch_category')
content = content.replace('ui->btnSearch_managecategories', 'ui->btnSearch_category')
content = content.replace('ui->lstSearch_managecategories', 'ui->lstSearch_category')
content = content.replace('ui->txtName_managecategories', 'ui->txtName_category')
content = content.replace('ui->btnClear_name_managecategories', 'ui->btnClear_name_category')
content = content.replace('ui->btnAddCategory_managecategories', 'ui->btnAdd_category')
content = content.replace('ui->btnEditCategory_managecategories', 'ui->btnEdit_category')
content = content.replace('ui->btnRemoveCategory_managecategories', 'ui->btnRemove_category')
content = content.replace('ui->btnUndoRemove_managecategories', 'ui->btnUndoRemove_category')
content = content.replace('ui->btnUndoEdit_managecategories', 'ui->btnUndoEdit_category')
content = content.replace('ui->btnUndoAdd_managecategories', 'ui->btnUndoAdd_category')

# Manage Locations page
content = content.replace('ui->txtSearch_managelocations', 'ui->txtSearch_location')
content = content.replace('ui->btnSearch_managelocations', 'ui->btnSearch_location')
content = content.replace('ui->lstSearch_managelocations', 'ui->lstSearch_location')
content = content.replace('ui->txtName_managelocations', 'ui->txtName_location')
content = content.replace('ui->btnClear_name_managelocations', 'ui->btnClear_name_location')
content = content.replace('ui->btnAddLocation_managelocations', 'ui->btnAdd_location')
content = content.replace('ui->btnEditLocation_managelocations', 'ui->btnEdit_location')
content = content.replace('ui->btnRemoveLocation_managelocations', 'ui->btnRemove_location')
content = content.replace('ui->btnUndoRemove_managelocations', 'ui->btnUndoRemove_location')
content = content.replace('ui->btnUndoEdit_managelocations', 'ui->btnUndoEdit_location')
content = content.replace('ui->btnUndoAdd_managelocations', 'ui->btnUndoAdd_location')

# Add Readers page
content = content.replace('ui->txtName_addreaders', 'ui->txtName_reader')
content = content.replace('ui->txtSurname_addreaders', 'ui->txtSurname_reader')
content = content.replace('ui->txtGrade_addreaders', 'ui->txtGrade_reader')
content = content.replace('ui->txtClass_addreaders', 'ui->txtClass_reader')
content = content.replace('ui->txtID_addreaders', 'ui->txtId_reader')
content = content.replace('ui->btnClear_name_addreaders', 'ui->btnClear_name_reader')
content = content.replace('ui->btnClear_surname_addreaders', 'ui->btnClear_surname_reader')
content = content.replace('ui->btnClear_grade_addreaders', 'ui->btnClear_grade_reader')
content = content.replace('ui->btnClear_class_addreaders', 'ui->btnClear_class_reader')
content = content.replace('ui->btnClear_id_addreaders', 'ui->btnClear_id_reader')
content = content.replace('ui->btnAddBook_addreaders', 'ui->btnAdd_reader')
content = content.replace('ui->btnUndoAdd_addreaders', 'ui->btnUndoAdd_reader')

# Edit Readers page
content = content.replace('ui->txtSearch_editreaders', 'ui->txtSearch_reader_edit')
content = content.replace('ui->btnSearch_editreaders', 'ui->btnSearch_reader_edit')
content = content.replace('ui->lstSearch_editreaders', 'ui->lstSearch_reader_edit')
content = content.replace('ui->txtName_editreaders', 'ui->txtName_reader_edit')
content = content.replace('ui->txtSurname_editreaders', 'ui->txtSurname_reader_edit')
content = content.replace('ui->txtGrade_editreaders', 'ui->txtGrade_reader_edit')
content = content.replace('ui->txtClass_editreaders', 'ui->txtClass_reader_edit')
content = content.replace('ui->txtID_editreaders', 'ui->txtId_reader_edit')
content = content.replace('ui->btnEditBook_editreaders', 'ui->btnEdit_reader')
content = content.replace('ui->btnUndoEdit_editreaders', 'ui->btnUndoEdit_reader')
content = content.replace('ui->btnClear_name_editreaders', 'ui->btnClear_name_reader_edit')
content = content.replace('ui->btnClear_surname_editreaders', 'ui->btnClear_surname_reader_edit')
content = content.replace('ui->btnClear_grade_editreaders', 'ui->btnClear_grade_reader_edit')
content = content.replace('ui->btnClear_class_editreaders', 'ui->btnClear_class_reader_edit')
content = content.replace('ui->btnClear_id_editreaders', 'ui->btnClear_id_reader_edit')

# Remove Readers page
content = content.replace('ui->txtSearch_removereaders', 'ui->txtSearch_reader_remove')
content = content.replace('ui->btnSearch_removereaders', 'ui->btnSearch_reader_remove')
content = content.replace('ui->lstSearch_removereaders', 'ui->lstSearch_reader_remove')
content = content.replace('ui->txtName_removereaders', 'ui->txtName_reader_remove')
content = content.replace('ui->txtSurname_removereaders', 'ui->txtSurname_reader_remove')
content = content.replace('ui->txtGrade_removereaders', 'ui->txtGrade_reader_remove')
content = content.replace('ui->txtClass_removereaders', 'ui->txtClass_reader_remove')
content = content.replace('ui->txtID_removereaders', 'ui->txtId_reader_remove')
content = content.replace('ui->btnClear_name_removereaders', 'ui->btnClear_name_reader_remove')
content = content.replace('ui->btnClear_surname_removereaders', 'ui->btnClear_surname_reader_remove')
content = content.replace('ui->btnClear_grade_removereaders', 'ui->btnClear_grade_reader_remove')
content = content.replace('ui->btnClear_class_removereaders', 'ui->btnClear_class_reader_remove')
content = content.replace('ui->btnClear_id_removereaders', 'ui->btnClear_id_reader_remove')
content = content.replace('ui->btnRemove_removereaders', 'ui->btnRemove_reader')
content = content.replace('ui->btnUndoRemoval_removereaders', 'ui->btnUndoRemoval_reader')
content = content.replace('ui->btnUndoLast_removereaders', 'ui->btnUndoLast_reader')
content = content.replace('ui->cboFilter_removereaders', 'ui->cboFilter_reader_remove')

# Undo Readers page
content = content.replace('ui->txtSearch_undoremovereaders', 'ui->txtSearch_reader_undo')
content = content.replace('ui->btnSearch_undoremovereaders', 'ui->btnSearch_reader_undo')
content = content.replace('ui->txtValue_undoremovereaders', 'ui->txtValue_reader_undo')
content = content.replace('ui->cboValue_undoremovereaders', 'ui->cboValue_reader_undo')
content = content.replace('ui->btnUndoAll_undoremovereaders', 'ui->btnUndoAll_reader_undo')
content = content.replace('ui->btnUndoSelected_undoremovereaders', 'ui->btnUndoSelected_reader_undo')
content = content.replace('ui->btnRedoRemove_undoremovereaders', 'ui->btnRedoRemove_reader_undo')
content = content.replace('ui->btnRedoAllSelected_undoremovereaders', 'ui->btnRedoAllSelected_reader_undo')
content = content.replace('ui->lstSearch_undoremovereaders', 'ui->lstSearch_reader_undo')

# Add Loans page
content = content.replace('ui->txtBookSearch_AddLoans', 'ui->txtSearch_book_add')
content = content.replace('ui->txtReaderSearch_AddLoans', 'ui->txtSearch_reader_add')
content = content.replace('ui->txtBookSelected_AddLoans', 'ui->txtSelected_book_add')
content = content.replace('ui->txtReaderSelected_AddLoans', 'ui->txtSelected_reader_add')
content = content.replace('ui->spnLoanDays_AddLoans', 'ui->spnLoanDays_loan_add')
content = content.replace('ui->btnSearchBook_addloan', 'ui->btnSearch_book_add')
content = content.replace('ui->btnSearchReader_clicked', 'ui->btnSearch_reader_add')
content = content.replace('ui->btnAddLoan_addloan', 'ui->btnAdd_loan_add')
content = content.replace('ui->btnClear_addloan', 'ui->btnClear_loan_add')
content = content.replace('ui->cboReaderSearchField_AddLoans', 'ui->cboSearchField_reader_loan_add')
content = content.replace('ui->lstSearchReaders_AddLoans', 'ui->lstSearch_reader_loan_add')

# Edit Loans page
content = content.replace('ui->txtLoanSearch_EditLoans', 'ui->txtSearch_loan_edit')
content = content.replace('ui->txtLoanSelected_EditLoans', 'ui->txtSelected_loan_edit')
content = content.replace('ui->txtDueDate_EditLoans', 'ui->txtDueDate_loan_edit')
content = content.replace('ui->txtReturnDate_EditLoans', 'ui->txtReturnDate_loan_edit')
content = content.replace('ui->cboStatus_EditLoans', 'ui->cboStatus_loan_edit')
content = content.replace('ui->cboLoanSearchField_EditLoans', 'ui->cboSearchField_loan_edit')
content = content.replace('ui->lstSearch_EditLoans', 'ui->lstSearch_loan_edit')
content = content.replace('ui->btnSearchLoan_editloan', 'ui->btnSearch_loan_edit')
content = content.replace('ui->btnUpdateLoan_editloan', 'ui->btnUpdate_loan_edit')
content = content.replace('ui->btnReturnLoan_editloan', 'ui->btnReturn_loan_edit')
content = content.replace('ui->btnClear_editloan', 'ui->btnClear_loan_edit')

# Loan Statuses page
content = content.replace('ui->txtSearch_LoanStatuses', 'ui->txtSearch_loan_status')
content = content.replace('ui->cboStatusFilter_LoanStatuses', 'ui->cboStatusFilter_loan_status')
content = content.replace('ui->lstSearch_LoanStatuses', 'ui->lstSearch_loan_status')
content = content.replace('ui->btnSearch_loanstatus', 'ui->btnSearch_loan_status')
content = content.replace('ui->btnRefresh_loanstatus', 'ui->btnRefresh_loan_status')
content = content.replace('ui->btnOverdueReport_loanstatus', 'ui->btnOverdueReport_loan_status')
content = content.replace('ui->btnFilter_loanstatus', 'ui->btnFilter_loan_status')
content = content.replace('ui->cboStatusFilter_LoanStatuses', 'ui->cboStatusFilter_loan_status')
content = content.replace('ui->lstSearch_LoanStatuses', 'ui->lstSearch_loan_status')

# Manage Categories page
content = content.replace('ui->txtSearch_managecategories', 'ui->txtSearch_category')
content = content.replace('ui->btnSearch_managecategories', 'ui->btnSearch_category')
content = content.replace('ui->lstSearch_managecategories', 'ui->lstSearch_category')
content = content.replace('ui->txtName_managecategories', 'ui->txtName_category')
content = content.replace('ui->btnClear_name_managecategories', 'ui->btnClear_name_category')
content = content.replace('ui->btnAddCategory_managecategories', 'ui->btnAdd_category')
content = content.replace('ui->btnEditCategory_managecategories', 'ui->btnEdit_category')
content = content.replace('ui->btnRemoveCategory_managecategories', 'ui->btnRemove_category')
content = content.replace('ui->btnUndoRemove_managecategories', 'ui->btnUndoRemove_category')
content = content.replace('ui->btnUndoEdit_managecategories', 'ui->btnUndoEdit_category')
content = content.replace('ui->btnUndoAdd_managecategories', 'ui->btnUndoAdd_category')

# Manage Locations page
content = content.replace('ui->txtSearch_managelocations', 'ui->txtSearch_location')
content = content.replace('ui->btnSearch_managelocations', 'ui->btnSearch_location')
content = content.replace('ui->lstSearch_managelocations', 'ui->lstSearch_location')
content = content.replace('ui->txtName_managelocations', 'ui->txtName_location')
content = content.replace('ui->btnClear_name_managelocations', 'ui->btnClear_name_location')
content = content.replace('ui->btnAddLocation_managelocations', 'ui->btnAdd_location')
content = content.replace('ui->btnEditLocation_managelocations', 'ui->btnEdit_location')
content = content.replace('ui->btnRemoveLocation_managelocations', 'ui->btnRemove_location')
content = content.replace('ui->btnUndoRemove_managelocations', 'ui->btnUndoRemove_location')
content = content.replace('ui->btnUndoEdit_managelocations', 'ui->btnUndoEdit_location')
content = content.replace('ui->btnUndoAdd_managelocations', 'ui->btnUndoAdd_location')

# Login page
content = content.replace('ui->txtUsername_login', 'ui->txtUsername_login')
content = content.replace('ui->txtPassword_login', 'ui->txtPassword_login')
content = content.replace('ui->txtPwd2_register', 'ui->txtPwd2_register')
content = content.replace('ui->txtPwd1_register', 'ui->txtPwd1_register')
content = content.replace('ui->txtUsr_register', 'ui->txtUsr_register')

# Write the fixed content
with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")