#!/usr/bin/env python3
"""Fix widget name references in mainwindow.cpp"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

replacements = {
    # Add Loans page (page_14)
    'ui->txtSearch_book_add': 'ui->txtSearch_book',
    'ui->txtSearch_reader_add': 'ui->txtSearch_reader',
    'ui->txtSelected_book_add': 'ui->txtSelected_book',
    'ui->txtSelected_reader_add': 'ui->txtSelected_reader',
    'ui->spnLoanDays_loan_add': 'ui->spnLoanDays_loan',
    'ui->cboSearchField_book_add': 'ui->cboSearchField_book',
    'ui->cboSearchField_reader_loan_add': 'ui->cboSearchField_reader',
    'ui->lstSearch_book_loan_add': 'ui->lstSearch_book',
    'ui->lstSearch_reader_loan_add': 'ui->lstSearch_reader',
    'ui->btnSearch_book_add': 'ui->btnSearch_book',
    'ui->btnSearch_reader_add': 'ui->btnSearch_reader',
    'ui->btnAdd_loan_add': 'ui->btnAdd_loan',
    'ui->btnClear_loan_add': 'ui->btnClear_loan',
    
    # Edit Loans page
    'ui->txtSearch_loan_edit': 'ui->txtSearch_loan',
    'ui->txtSelected_loan_edit': 'ui->txtSelected_loan',
    'ui->txtDueDate_loan_edit': 'ui->txtDueDate_loan',
    'ui->txtReturnDate_loan_edit': 'ui->txtReturnDate_loan',
    'ui->cboStatus_loan_edit': 'ui->cboStatus_loan',
    'ui->cboSearchField_loan_edit': 'ui->cboSearchField_loan',
    'ui->lstSearch_loan_edit': 'ui->lstSearch_loan',
    'ui->btnSearch_loan_edit': 'ui->btnSearch_loan',
    'ui->btnUpdate_loan_edit': 'ui->btnUpdate_loan',
    'ui->btnReturn_loan_edit': 'ui->btnReturn_loan',
    'ui->btnClear_loan_edit': 'ui->btnClear_loan',
    
    # Loan Statuses page
    'ui->txtSearch_loan_status': 'ui->txtSearch_loanstatus',
    'ui->cboStatusFilter_loan_status': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loan_status': 'ui->lstSearch_loanstatus',
    'ui->btnSearch_loan_status': 'ui->btnSearch_loanstatus',
    'ui->btnRefresh_loan_status': 'ui->btnRefresh_loanstatus',
    'ui->btnOverdueReport_loan_status': 'ui->btnOverdueReport_loanstatus',
    'ui->btnFilter_loan_status': 'ui->btnFilter_loanstatus',
    'ui->cboStatusFilter_loan_status': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loan_status': 'ui->lstSearch_loanstatus',
    
    # Undo Books page
    'ui->txtSearch_book_undo': 'ui->txtSearch_undobooks',
    'ui->cboValue_book_undo': 'ui->cboValue_undobooks',
    'ui->lstSearch_book_undo': 'ui->lstSearch_undobooks',
    'ui->txtValue_book_undo': 'ui->txtValue_undobooks',
    
    # Undo Readers page
    'ui->txtSearch_reader_undo': 'ui->txtSearch_undoreaders',
    'ui->cboValue_reader_undo': 'ui->cboValue_undoreaders',
    'ui->lstSearch_reader_undo': 'ui->lstSearch_undoreaders',
    'ui->txtValue_reader_undo': 'ui->txtValue_undoreaders',
    
    # Undo Books page button
    'ui->btnSearch_book_undo': 'ui->btnSearch_undobooks',
    'ui->cboValue_book_undo': 'ui->cboValue_undobooks',
    'ui->lstSearch_book_undo': 'ui->lstSearch_undobooks',
    'ui->txtValue_book_undo': 'ui->txtValue_undobooks',
}

for old, new in replacements.items():
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        print(f"Fixed {count}x: {old} -> {new}")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")