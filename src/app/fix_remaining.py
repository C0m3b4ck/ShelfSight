#!/usr/bin/env python3
"""
Fix remaining issues - direct text replacements
"""

replacements = {
    # Reader add page - fix remaining bare references
    'txtName_reader->': 'txtName_reader_add->',
    'txtSurname_reader->': 'txtSurname_reader_add->',
    'txtGrade_reader->': 'txtGrade_reader_add->',
    'txtClass_reader->': 'txtClass_reader_add->',
    'txtID_reader->': 'txtId_reader_add->',
    'txtId_reader->': 'txtId_reader_add->',
    
    # Book remove page - fix double replacement
    'lstSearch_book_loan_add_remove': 'lstSearch_book_remove',
    'lstSearch_book_loan_add_remove->': 'lstSearch_book_remove->',
    
    # Any remaining old names
    'lstSearch_removebooks': 'lstSearch_book_remove',
    'txtSearch_removebooks': 'txtSearch_book_remove',
    'txtTitle_removebooks': 'txtTitle_book_remove',
    'txtAuthor_removebooks': 'txtAuthor_book_remove',
    'txtID_removebooks': 'txtId_book_remove',
    'cboCategory_removebooks': 'cboCategory_book_remove',
    'cboLocation_removebooks': 'cboLocation_book_remove',
    'cboStatus_removebooks': 'cboStatus_book_remove',
    'btnRemove_removebooks': 'btnRemove_book_remove',
    'btnUndoRemoval_removebooks': 'btnUndoRemoval_book_remove',
    'btnUndoLast_removebooks': 'btnUndoLast_book_remove',
    'btnUndoAll_undoremovebooks': 'btnUndoAll_book_undo',
    'btnUndoSelected_undoremovebooks': 'btnUndoSelected_book_undo',
    'btnRedoRemove_undoremovebooks': 'btnRedoRemove_book_undo',
    'btnRedoAllSelected_undoremovebooks': 'btnRedoAllSelected_book_undo',
    
    'txtSearch_undoremovebooks': 'txtSearch_book_undo',
    'cboValue_undoremovebooks': 'cboValue_book_undo',
    'lstSearch_undoremovebooks': 'lstSearch_book_undo',
    
    'txtSearch_undoremovereaders': 'txtSearch_reader_undo',
    'cboValue_undoremovereaders': 'cboValue_reader_undo',
    'lstSearch_undoremovereaders': 'lstSearch_reader_undo',
    'btnUndoAll_undoremovereaders': 'btnUndoAll_reader_undo',
    'btnUndoSelected_undoremovereaders': 'btnUndoSelected_reader_undo',
    'btnRedoRemove_undoremovereaders': 'btnRedoRemove_reader_undo',
    'btnRedoAllSelected_undoremovereaders': 'btnRedoAllSelected_reader_undo',
    
    # Edit readers page - remaining
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
    
    # Remove readers page
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
    
    # Manage categories page
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
    
    # Manage locations page
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
    
    # Add books page (if any remaining)
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
    
    # Edit books page
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
    
    # Add readers page
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
    
    # Add loans page
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
    
    # Edit loans page
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
    
    # Loan status page
    'txtSearch_LoanStatuses': 'txtSearch_loan_status',
    'cboStatusFilter_LoanStatuses': 'cboStatusFilter_loan_status',
    'lstSearch_LoanStatuses': 'lstSearch_loan_status',
    'btnSearch_loanstatus': 'btnSearch_loan_status',
    'btnRefresh_loanstatus': 'btnRefresh_loan_status',
    'btnOverdueReport_loanstatus': 'btnOverdueReport_loan_status',
    'btnFilter_loanstatus': 'btnFilter_loan_status',
}

if __name__ == '__main__':
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
        content = f.read()
    
    for old, new in replacements.items():
        count = content.count(old)
        if count > 0:
            content = content.replace(old, new)
            print(f"Fixed {count}x: {old} -> {new}")
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
        f.write(content)
    
    print("Done!")