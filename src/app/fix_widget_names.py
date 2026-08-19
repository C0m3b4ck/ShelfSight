#!/usr/bin/env python3
"""Fix all widget name references in mainwindow.cpp"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

# Comprehensive widget name mapping based on actual UI file
replacements = {
    # Register page
    'ui->txtPwd2_register': 'ui->txtPwd1_register',  # Only one password field in UI
    
    # Add Books page (page_3) - no suffix
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
    
    # Edit Books page (page_9) - _edit suffix
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
    
    # Remove Books page (page_4)
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
    
    # Undo Books page (page_6)
    'ui->txtSearch_undoremovebooks': 'ui->txtSearch_undobooks',
    'ui->cboValue_undoremovebooks': 'ui->cboValue_undobooks',
    'ui->btnUndoAll_undoremovebooks': 'ui->btnUndoAll_undobooks',
    'ui->btnUndoSelected_undoremovebooks': 'ui->btnUndoSelected_undobooks',
    'ui->btnRedoRemove_undoremovebooks': 'ui->btnRedoRemove_undobooks',
    'ui->btnRedoAllSelected_undoremovebooks': 'ui->btnRedoAllSelected_undobooks',
    'ui->lstSearch_undoremovebooks': 'ui->lstSearch_undobooks',
    
    # Manage Categories page (page_5)
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
    
    # Manage Locations page (page_8)
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
    'ui->lstSearch_managelocations': 'ui->lstSearch_location',
    
    # Add Readers page (page_10)
    'ui->txtName_addreaders': 'ui->txtName_reader',
    'ui->txtSurname_addreaders': 'ui->txtSurname_reader',
    'ui->txtGrade_addreaders': 'ui->txtGrade_reader',
    'ui->txtClass_addreaders': 'ui->txtClass_reader',
    'ui->txtID_addreaders': 'ui->txtID_reader',
    'ui->btnClear_name_addreaders': 'ui->btnClear_name_reader',
    'ui->btnClear_surname_addreaders': 'ui->btnClear_surname_reader',
    'ui->btnClear_grade_addreaders': 'ui->btnClear_grade_reader',
    'ui->btnClear_class_addreaders': 'ui->btnClear_class_reader',
    'ui->btnClear_id_addreaders': 'ui->btnClear_id_reader',
    'ui->btnAddBook_addreaders': 'ui->btnAdd_reader',
    'ui->btnUndoAdd_addreaders': 'ui->btnUndoAdd_reader',
    
    # Edit Readers page (page_11)
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
    
    # Remove Readers page (page_12)
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
    
    # Undo Readers page (page_13)
    'ui->txtSearch_undoremovereaders': 'ui->txtSearch_undoreaders',
    'ui->btnSearch_undoremovereaders': 'ui->btnSearch_undoreaders',
    'ui->txtValue_undoremovereaders': 'ui->txtValue_undoreaders',
    'ui->cboValue_undoremovereaders': 'ui->cboValue_undoreaders',
    'ui->btnUndoAll_undoremovereaders': 'ui->btnUndoAll_undoreaders',
    'ui->btnUndoSelected_undoremovereaders': 'ui->btnUndoSelected_undoreaders',
    'ui->btnRedoRemove_undoremovereaders': 'ui->btnRedoRemove_undoreaders',
    'ui->btnRedoAllSelected_undoremovereaders': 'ui->btnRedoAllSelected_undoreaders',
    'ui->lstSearch_undoremovereaders': 'ui->lstSearch_undoreaders',
    'ui->cboValue_undoremovereaders': 'ui->cboValue_undoreaders',
    'ui->txtValue_undoremovereaders': 'ui->txtValue_undoreaders',
    
    # Add Loans page (page_14)
    'ui->txtBookSearch_AddLoans': 'ui->txtSearch_book',
    'ui->txtReaderSearch_AddLoans': 'ui->txtSearch_reader',
    'ui->txtBookSelected_AddLoans': 'ui->txtSelected_book',
    'ui->txtReaderSelected_AddLoans': 'ui->txtSelected_reader',
    'ui->spnLoanDays_AddLoans': 'ui->spnLoanDays_loan',
    'ui->btnSearchBook_addloan': 'ui->btnSearch_book',
    'ui->btnSearchReader_clicked': 'ui->btnSearch_reader',
    'ui->btnAddLoan_addloan': 'ui->btnAdd_loan',
    'ui->btnClear_addloan': 'ui->btnClear_loan',
    'ui->cboReaderSearchField_AddLoans': 'ui->cboSearchField_reader',
    'ui->lstSearchReaders_AddLoans': 'ui->lstSearch_reader',
    
    # Edit Loans page (page_15)
    'ui->txtLoanSearch_EditLoans': 'ui->txtSearch_loan',
    'ui->txtLoanSelected_EditLoans': 'ui->txtSelected_loan',
    'ui->txtDueDate_EditLoans': 'ui->txtDueDate_loan',
    'ui->txtReturnDate_EditLoans': 'ui->txtReturnDate_loan',
    'ui->cboStatus_EditLoans': 'ui->cboStatus_loan',
    'ui->cboLoanSearchField_EditLoans': 'ui->cboSearchField_loan',
    'ui->lstSearch_EditLoans': 'ui->lstSearch_loan',
    'ui->btnSearchLoan_editloan': 'ui->btnSearch_loan',
    'ui->btnUpdateLoan_editloan': 'ui->btnUpdate_loan',
    'ui->btnReturnLoan_editloan': 'ui->btnReturn_loan',
    'ui->btnClear_editloan': 'ui->btnClear_loan',
    
    # Loan Statuses page (page_16)
    'ui->txtSearch_LoanStatuses': 'ui->txtSearch_loanstatus',
    'ui->cboStatusFilter_LoanStatuses': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_LoanStatuses': 'ui->lstSearch_loanstatus',
    'ui->btnSearch_loanstatus': 'ui->btnSearch_loanstatus',
    'ui->btnRefresh_loanstatus': 'ui->btnRefresh_loanstatus',
    'ui->btnOverdueReport_loanstatus': 'ui->btnOverdueReport_loanstatus',
    'ui->btnFilter_loanstatus': 'ui->btnFilter_loanstatus',
    'ui->cboStatusFilter_LoanStatuses': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_LoanStatuses': 'ui->lstSearch_loanstatus',
    
    # Undo Books page (fix incorrect names)
    'ui->txtSearch_book_undo': 'ui->txtSearch_undobooks',
    'ui->cboValue_book_undo': 'ui->cboValue_undobooks',
    'ui->lstSearch_book_undo': 'ui->lstSearch_undobooks',
    'ui->txtValue_book_undo': 'ui->txtValue_undobooks',
    
    # Undo Readers page
    'ui->txtSearch_reader_undo': 'ui->txtSearch_undoreaders',
    'ui->cboValue_reader_undo': 'ui->cboValue_undoreaders',
    'ui->lstSearch_reader_undo': 'ui->lstSearch_undoreaders',
    'ui->txtValue_reader_undo': 'ui->txtValue_undoreaders',
    
    # Undo Books page buttons
    'ui->btnSearch_book_undo': 'ui->btnSearch_undobooks',
    'ui->cboValue_book_undo': 'ui->cboValue_undobooks',
    'ui->lstSearch_book_undo': 'ui->lstSearch_undobooks',
    'ui->txtValue_book_undo': 'ui->txtValue_undobooks',
    
    # Register page
    'ui->txtUsername_register': 'ui->txtUsr_register',
    'ui->txtPassword_register': 'ui->txtPwd1_register',
    'ui->txtPassword2_register': 'ui->txtPwd1_register',
    'ui->barPasswordStrength_register': 'ui->barPasswordStrenght_register',
    
    # Login page
    'ui->txtUsr_register_3': 'ui->txtUsr_register',
    'ui->txtPwd1_register_3': 'ui->txtPwd1_register',
    'ui->txtPassword_login': 'ui->txtPassword_login',
    
    # Edit Readers page - fix edit page references
    'ui->txtName_addreaders_edit': 'ui->txtName_reader_edit',
    'ui->txtSurname_addreaders_edit': 'ui->txtSurname_reader_edit',
    'ui->txtGrade_addreaders_edit': 'ui->txtGrade_reader_edit',
    'ui->txtClass_addreaders_edit': 'ui->txtClass_reader_edit',
    'ui->txtID_addreaders_edit': 'ui->txtId_reader_edit',
    
    # Remove Readers page
    'ui->txtName_addreaders_remove': 'ui->txtName_reader_remove',
    'ui->txtSurname_addreaders_remove': 'ui->txtSurname_reader_remove',
    'ui->txtGrade_addreaders_remove': 'ui->txtGrade_reader_remove',
    'ui->txtClass_addreaders_remove': 'ui->txtClass_reader_remove',
    'ui->txtID_addreaders_remove': 'ui->txtId_reader_remove',
    
    # Loan add page
    'ui->cboReaderSearchField_AddLoans': 'ui->cboSearchField_reader',
    'ui->lstSearch_book': 'ui->lstSearch_book',
    'ui->lstSearch_reader': 'ui->lstSearch_reader',
    'ui->txtSearch_book': 'ui->txtSearch_book',
    'ui->txtSearch_reader': 'ui->txtSearch_reader',
    'ui->txtSelected_book': 'ui->txtSelected_book',
    'ui->txtSelected_reader': 'ui->txtSelected_reader',
    'ui->spnLoanDays_loan': 'ui->spnLoanDays_loan',
    'ui->btnSearch_book': 'ui->btnSearch_book',
    'ui->btnSearch_reader': 'ui->btnSearch_reader',
    'ui->btnAdd_loan': 'ui->btnAdd_loan',
    'ui->btnClear_loan': 'ui->btnClear_loan',
    
    # Loan edit page
    'ui->txtSearch_loan': 'ui->txtSearch_loan',
    'ui->txtSelected_loan': 'ui->txtSelected_loan',
    'ui->txtDueDate_loan': 'ui->txtDueDate_loan',
    'ui->txtReturnDate_loan': 'ui->txtReturnDate_loan',
    'ui->cboStatus_loan': 'ui->cboStatus_loan',
    'ui->cboSearchField_loan': 'ui->cboSearchField_loan',
    'ui->lstSearch_loan': 'ui->lstSearch_loan',
    'ui->btnSearch_loan': 'ui->btnSearch_loan',
    'ui->btnUpdate_loan': 'ui->btnUpdate_loan',
    'ui->btnReturn_loan': 'ui->btnReturn_loan',
    'ui->btnClear_loan': 'ui->btnClear_loan',
    
    # Loan status page
    'ui->txtSearch_loanstatus': 'ui->txtSearch_loanstatus',
    'ui->cboStatusFilter_loanstatus': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loanstatus': 'ui->lstSearch_loanstatus',
    'ui->btnSearch_loanstatus': 'ui->btnSearch_loanstatus',
    'ui->btnRefresh_loanstatus': 'ui->btnRefresh_loanstatus',
    'ui->btnOverdueReport_loanstatus': 'ui->btnOverdueReport_loanstatus',
    'ui->btnFilter_loanstatus': 'ui->btnFilter_loanstatus',
    'ui->cboStatusFilter_loanstatus': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loanstatus': 'ui->lstSearch_loanstatus',
    
    # Undo Books page
    'ui->txtSearch_undobooks': 'ui->txtSearch_undobooks',
    'ui->cboValue_undobooks': 'ui->cboValue_undobooks',
    'ui->lstSearch_undobooks': 'ui->lstSearch_undobooks',
    'ui->txtValue_undobooks': 'ui->txtValue_undobooks',
    
    # Undo Readers page
    'ui->txtSearch_undoreaders': 'ui->txtSearch_undoreaders',
    'ui->cboValue_undoreaders': 'ui->cboValue_undoreaders',
    'ui->lstSearch_undoreaders': 'ui->lstSearch_undoreaders',
    'ui->txtValue_undoreaders': 'ui->txtValue_undoreaders',
    
    # Login page
    'ui->txtUsr_register_3': 'ui->txtUsr_register',
    'ui->txtPwd1_register_3': 'ui->txtPwd1_register',
    'ui->txtPwd2_register': 'ui->txtPwd1_register',
    
    # Register page
    'ui->txtPwd2_register': 'ui->txtPwd1_register',
}

for old, new in replacements.items():
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        print(f"Fixed {count}x: {old} -> {new}")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")