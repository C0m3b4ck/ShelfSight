#!/usr/bin/env python3
"""
Fix remaining widget references in function bodies
"""

# Additional replacements for function body references
replacements = {
    # Book add page clear functions
    'ui->txtTitle_book->': 'ui->txtTitle_book_add->',
    'ui->txtAuthor_book->': 'ui->txtAuthor_book_add->',
    'ui->txtId_book->': 'ui->txtId_book_add->',
    'ui->cboLocation_book->': 'ui->cboLocation_book_add->',
    'ui->cboCategory_book->': 'ui->cboCategory_book_add->',
    'ui->cboStatus_book->': 'ui->cboStatus_book_add->',
    
    # Book edit page
    'ui->txtTitle_book_edit->': 'ui->txtTitle_book_edit->',
    'ui->txtAuthor_book_edit->': 'ui->txtAuthor_book_edit->',
    'ui->txtId_book_edit->': 'ui->txtId_book_edit->',
    'ui->cboLocation_book_edit->': 'ui->cboLocation_book_edit->',
    'ui->cboCategory_book_edit->': 'ui->cboCategory_book_edit->',
    'ui->cboStatus_book_edit->': 'ui->cboStatus_book_edit->',
    'ui->lstSearch_book_edit->': 'ui->lstSearch_book_edit->',
    
    # Book remove page
    'ui->txtTitle_book_remove->': 'ui->txtTitle_book_remove->',
    'ui->txtAuthor_book_remove->': 'ui->txtAuthor_book_remove->',
    'ui->txtId_book_remove->': 'ui->txtId_book_remove->',
    'ui->cboCategory_book_remove->': 'ui->cboCategory_book_remove->',
    'ui->cboLocation_book_remove->': 'ui->cboLocation_book_remove->',
    'ui->cboStatus_book_remove->': 'ui->cboStatus_book_remove->',
    'ui->lstSearch_book_remove->': 'ui->lstSearch_book_remove->',
    
    # Book undo page
    'ui->txtValue_book_undo->': 'ui->txtValue_book_undo->',
    'ui->txtSearch_book_undo->': 'ui->txtSearch_book_undo->',
    'ui->cboValue_book_undo->': 'ui->cboValue_book_undo->',
    'ui->lstSearch_book_undo->': 'ui->lstSearch_book_undo->',
    
    # Reader add page
    'ui->txtName_reader_add->': 'ui->txtName_reader_add->',
    'ui->txtSurname_reader_add->': 'ui->txtSurname_reader_add->',
    'ui->txtGrade_reader_add->': 'ui->txtGrade_reader_add->',
    'ui->txtClass_reader_add->': 'ui->txtClass_reader_add->',
    'ui->txtId_reader_add->': 'ui->txtId_reader_add->',
    
    # Reader edit page
    'ui->txtName_reader_edit->': 'ui->txtName_reader_edit->',
    'ui->txtSurname_reader_edit->': 'ui->txtSurname_reader_edit->',
    'ui->txtGrade_reader_edit->': 'ui->txtGrade_reader_edit->',
    'ui->txtClass_reader_edit->': 'ui->txtClass_reader_edit->',
    'ui->txtId_reader_edit->': 'ui->txtId_reader_edit->',
    'ui->lstSearch_reader_edit->': 'ui->lstSearch_reader_edit->',
    
    # Reader remove page
    'ui->txtName_reader_remove->': 'ui->txtName_reader_remove->',
    'ui->txtSurname_reader_remove->': 'ui->txtSurname_reader_remove->',
    'ui->txtGrade_reader_remove->': 'ui->txtGrade_reader_remove->',
    'ui->txtClass_reader_remove->': 'ui->txtClass_reader_remove->',
    'ui->txtId_reader_remove->': 'ui->txtId_reader_remove->',
    'ui->lstSearch_reader_remove->': 'ui->lstSearch_reader_remove->',
    'ui->cboFilter_reader_remove->': 'ui->cboFilter_reader_remove->',
    
    # Reader undo page
    'ui->txtValue_reader_undo->': 'ui->txtValue_reader_undo->',
    'ui->txtSearch_reader_undo->': 'ui->txtSearch_reader_undo->',
    'ui->cboValue_reader_undo->': 'ui->cboValue_reader_undo->',
    'ui->lstSearch_reader_undo->': 'ui->lstSearch_reader_undo->',
    
    # Category page
    'ui->txtSearch_category->': 'ui->txtSearch_category->',
    'ui->lstSearch_category->': 'ui->lstSearch_category->',
    'ui->txtName_category->': 'ui->txtName_category->',
    
    # Location page
    'ui->txtSearch_location->': 'ui->txtSearch_location->',
    'ui->lstSearch_location->': 'ui->lstSearch_location->',
    'ui->txtName_location->': 'ui->txtName_location->',
    
    # Loan add page
    'ui->txtSearch_book_add->': 'ui->txtSearch_book_add->',
    'ui->txtSearch_reader_add->': 'ui->txtSearch_reader_add->',
    'ui->txtSelected_book_add->': 'ui->txtSelected_book_add->',
    'ui->txtSelected_reader_add->': 'ui->txtSelected_reader_add->',
    'ui->cboSearchField_book_loan_add->': 'ui->cboSearchField_book_loan_add->',
    'ui->cboSearchField_reader_loan_add->': 'ui->cboSearchField_reader_loan_add->',
    'ui->lstSearch_book_loan_add->': 'ui->lstSearch_book_loan_add->',
    'ui->lstSearch_reader_loan_add->': 'ui->lstSearch_reader_loan_add->',
    'ui->spnLoanDays_loan_add->': 'ui->spnLoanDays_loan_add->',
    'ui->chkCheckUnreturned_loan_add->': 'ui->chkCheckUnreturned_loan_add->',
    
    # Loan edit page
    'ui->txtSearch_loan_edit->': 'ui->txtSearch_loan_edit->',
    'ui->txtSelected_loan_edit->': 'ui->txtSelected_loan_edit->',
    'ui->txtDueDate_loan_edit->': 'ui->txtDueDate_loan_edit->',
    'ui->txtReturnDate_loan_edit->': 'ui->txtReturnDate_loan_edit->',
    'ui->cboStatus_loan_edit->': 'ui->cboStatus_loan_edit->',
    'ui->cboSearchField_loan_edit->': 'ui->cboSearchField_loan_edit->',
    'ui->lstSearch_loan_edit->': 'ui->lstSearch_loan_edit->',
    
    # Loan status page
    'ui->txtSearch_loan_status->': 'ui->txtSearch_loan_status->',
    'ui->cboStatusFilter_loan_status->': 'ui->cboStatusFilter_loan_status->',
    'ui->lstSearch_loan_status->': 'ui->lstSearch_loan_status->',
    
    # Fix double-replaced lstSearch_book_loan_add_edit
    'lstSearch_book_loan_add_edit': 'lstSearch_book_loan_add',
    'lstSearch_book_loan_addedit': 'lstSearch_book_loan_add',
    
    # Fix remaining old names
    'txtSearch_undobooks': 'txtSearch_book_undo',
    'cboValue_undobooks': 'cboValue_book_undo',
    'lstSearch_undobooks': 'lstSearch_book_undo',
    'txtSearch_undoreaders': 'txtSearch_reader_undo',
    'cboValue_undoreaders': 'cboValue_reader_undo',
    'lstSearch_undoreaders': 'lstSearch_reader_undo',
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