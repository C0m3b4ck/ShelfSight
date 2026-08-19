#!/usr/bin/env python3
"""Fix remaining widget references"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

replacements = {
    # Undo Books page (page_6)
    'ui->txtSearch_book_undo': 'ui->txtSearch_undobooks',
    'ui->cboValue_book_undo': 'ui->cboValue_undobooks',
    'ui->lstSearch_book_undo': 'ui->lstSearch_undobooks',
    'ui->txtValue_book_undo': 'ui->txtValue_undobooks',
    'ui->btnSearch_book_undo': 'ui->btnSearch_undobooks',
    'ui->btnUndoAll_book_undo': 'ui->btnUndoAll_undobooks',
    'ui->btnUndoSelected_book_undo': 'ui->btnUndoSelected_undobooks',
    'ui->btnRedoRemove_book_undo': 'ui->btnRedoRemove_undobooks',
    'ui->btnRedoAllSelected_book_undo': 'ui->btnRedoAllSelected_undobooks',
    
    # Remove Books page (page_4)
    'ui->txtSearch_removebooks': 'ui->txtSearch_book_remove',
    'ui->lstSearch_removebooks': 'ui->lstSearch_book_remove',
    
    # Remove Readers page (page_12)
    'ui->txtSearch_removereaders': 'ui->txtSearch_reader_remove',
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
    'ui->btnRemove_removereaders': 'ui->btnRemove_reader_remove',
    'ui->btnUndoRemoval_removereaders': 'ui->btnUndoRemoval_reader_remove',
    'ui->btnUndoLast_removereaders': 'ui->btnUndoLast_reader_remove',
    
    # Undo Readers page (page_13)
    'ui->txtSearch_undoreaders': 'ui->txtSearch_undoreaders',
    'ui->cboValue_undoreaders': 'ui->cboValue_undoreaders',
    'ui->lstSearch_undoreaders': 'ui->lstSearch_undoreaders',
    'ui->txtValue_undoreaders': 'ui->txtValue_undoreaders',
    'ui->btnSearch_undoreaders': 'ui->btnSearch_undoreaders',
    'ui->btnUndoAll_undoreaders': 'ui->btnUndoAll_undoreaders',
    'ui->btnUndoSelected_undoreaders': 'ui->btnUndoSelected_undoreaders',
    'ui->btnRedoRemove_undoreaders': 'ui->btnRedoRemove_undoreaders',
    'ui->btnRedoAllSelected_undoreaders': 'ui->btnRedoAllSelected_undoreaders',
    
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
    
    # Edit Loans page (page_15)
    'ui->txtSearch_loan_edit': 'ui->txtSearch_loan',
    'ui->txtSelected_loan_edit': 'ui->txtSelected_loan',
    'ui->txtDueDate_loan_edit': 'ui->txtDueDate_loan',
    'ui->txtReturnDate_loan_edit': 'ui->txtReturnDate_loan',
    'ui->cboStatus_loan_edit': 'ui->cboStatus_loan',
    'ui->cboSearchField_loan_edit': 'ui->cboSearchField_loan',
    'ui->lstSearch_loan_edit': 'ui->lstSearch_loan',
    
    # Loan Statuses page (page_16)
    'ui->txtSearch_loan_status': 'ui->txtSearch_loanstatus',
    'ui->cboStatusFilter_loan_status': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loan_status': 'ui->lstSearch_loanstatus',
    'ui->btnSearch_loan_status': 'ui->btnSearch_loanstatus',
    'ui->btnRefresh_loan_status': 'ui->btnRefresh_loanstatus',
    'ui->btnOverdueReport_loan_status': 'ui->btnOverdueReport_loanstatus',
    'ui->btnFilter_loan_status': 'ui->btnFilter_loanstatus',
    'ui->cboStatusFilter_loan_status': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loan_status': 'ui->lstSearch_loanstatus',
    
    # Undo Readers page
    'ui->txtSearch_reader_undo': 'ui->txtSearch_undoreaders',
    'ui->cboValue_reader_undo': 'ui->cboValue_undoreaders',
    'ui->lstSearch_reader_undo': 'ui->lstSearch_undoreaders',
    'ui->txtValue_reader_undo': 'ui->txtValue_undoreaders',
    'ui->btnSearch_reader_undo': 'ui->btnSearch_undoreaders',
    'ui->btnUndoAll_reader_undo': 'ui->btnUndoAll_undoreaders',
    'ui->btnUndoSelected_reader_undo': 'ui->btnUndoSelected_undoreaders',
    'ui->btnRedoRemove_reader_undo': 'ui->btnRedoRemove_undoreaders',
    'ui->btnRedoAllSelected_reader_undo': 'ui->btnRedoAllSelected_undoreaders',
    'ui->lstSearch_reader_undo': 'ui->lstSearch_undoreaders',
    
    # Remove Readers page
    'ui->btnRemove_reader_remove': 'ui->btnRemove_reader_remove',
    'ui->btnUndoRemoval_reader_remove': 'ui->btnUndoRemoval_reader_remove',
    'ui->btnUndoLast_reader_remove': 'ui->btnUndoLast_reader_remove',
    
    # Edit Loans page
    'ui->txtSearch_loan_edit': 'ui->txtSearch_loan',
    'ui->txtSelected_loan_edit': 'ui->txtSelected_loan',
    'ui->txtDueDate_loan_edit': 'ui->txtDueDate_loan',
    'ui->txtReturnDate_loan_edit': 'ui->txtReturnDate_loan',
    'ui->cboStatus_loan_edit': 'ui->cboStatus_loan',
    'ui->cboSearchField_loan_edit': 'ui->cboSearchField_loan',
    'ui->lstSearch_loan_edit': 'ui->lstSearch_loan',
    
    # Loan Statuses page
    'ui->txtSearch_loan_status': 'ui->txtSearch_loanstatus',
    'ui->cboStatusFilter_loan_status': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loan_status': 'ui->lstSearch_loanstatus',
    'ui->btnSearch_loanstatus': 'ui->btnSearch_loanstatus',
    'ui->btnRefresh_loanstatus': 'ui->btnRefresh_loanstatus',
    'ui->btnOverdueReport_loanstatus': 'ui->btnOverdueReport_loanstatus',
    'ui->btnFilter_loanstatus': 'ui->btnFilter_loanstatus',
    'ui->cboStatusFilter_loanstatus': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loanstatus': 'ui->lstSearch_loanstatus',
    
    # Undo Readers page
    'ui->txtSearch_reader_undo': 'ui->txtSearch_undoreaders',
    'ui->cboValue_reader_undo': 'ui->cboValue_undoreaders',
    'ui->lstSearch_reader_undo': 'ui->lstSearch_undoreaders',
    'ui->txtValue_reader_undo': 'ui->txtValue_undoreaders',
    
    # Undo Readers page buttons
    'ui->btnSearch_reader_undo': 'ui->btnSearch_undoreaders',
    'ui->btnUndoAll_reader_undo': 'ui->btnUndoAll_undoreaders',
    'ui->btnUndoSelected_reader_undo': 'ui->btnUndoSelected_undoreaders',
    'ui->btnRedoRemove_reader_undo': 'ui->btnRedoRemove_undoreaders',
    'ui->btnRedoAllSelected_reader_undo': 'ui->btnRedoAllSelected_undoreaders',
    'ui->lstSearch_reader_undo': 'ui->lstSearch_undoreaders',
    
    # Remove Readers page
    'ui->btnRemove_reader_remove': 'ui->btnRemove_reader_remove',
    'ui->btnUndoRemoval_reader_remove': 'ui->btnUndoRemoval_reader_remove',
    'ui->btnUndoLast_reader_remove': 'ui->btnUndoLast_reader_remove',
    
    # Edit Loans page
    'ui->txtSearch_loan_edit': 'ui->txtSearch_loan',
    'ui->txtSelected_loan_edit': 'ui->txtSelected_loan',
    'ui->txtDueDate_loan_edit': 'ui->txtDueDate_loan',
    'ui->txtReturnDate_loan_edit': 'ui->txtReturnDate_loan',
    'ui->cboStatus_loan_edit': 'ui->cboStatus_loan',
    'ui->cboSearchField_loan_edit': 'ui->cboSearchField_loan',
    'ui->lstSearch_loan_edit': 'ui->lstSearch_loan',
    
    # Loan Statuses page
    'ui->txtSearch_loanstatus': 'ui->txtSearch_loanstatus',
    'ui->cboStatusFilter_loanstatus': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loanstatus': 'ui->lstSearch_loanstatus',
    'ui->btnSearch_loanstatus': 'ui->btnSearch_loanstatus',
    'ui->btnRefresh_loanstatus': 'ui->btnRefresh_loanstatus',
    'ui->btnOverdueReport_loanstatus': 'ui->btnOverdueReport_loanstatus',
    'ui->btnFilter_loanstatus': 'ui->btnFilter_loanstatus',
    'ui->cboStatusFilter_loanstatus': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loanstatus': 'ui->lstSearch_loanstatus',
    
    # Undo Readers page
    'ui->txtSearch_reader_undo': 'ui->txtSearch_undoreaders',
    'ui->cboValue_reader_undo': 'ui->cboValue_undoreaders',
    'ui->lstSearch_reader_undo': 'ui->lstSearch_undoreaders',
    'ui->txtValue_reader_undo': 'ui->txtValue_undoreaders',
    
    # Undo Readers page buttons
    'ui->btnSearch_reader_undo': 'ui->btnSearch_undoreaders',
    'ui->btnUndoAll_reader_undo': 'ui->btnUndoAll_undoreaders',
    'ui->btnUndoSelected_reader_undo': 'ui->btnUndoSelected_undoreaders',
    'ui->btnRedoRemove_reader_undo': 'ui->btnRedoRemove_undoreaders',
    'ui->btnRedoAllSelected_reader_undo': 'ui->btnRedoAllSelected_undoreaders',
    'ui->lstSearch_reader_undo': 'ui->lstSearch_undoreaders',
    
    # Remove Readers page
    'ui->btnRemove_reader_remove': 'ui->btnRemove_reader_remove',
    'ui->btnUndoRemoval_reader_remove': 'ui->btnUndoRemoval_reader_remove',
    'ui->btnUndoLast_reader_remove': 'ui->btnUndoLast_reader_remove',
    
    # Edit Loans page
    'ui->txtSearch_loan_edit': 'ui->txtSearch_loan',
    'ui->txtSelected_loan_edit': 'ui->txtSelected_loan',
    'ui->txtDueDate_loan_edit': 'ui->txtDueDate_loan',
    'ui->txtReturnDate_loan_edit': 'ui->txtReturnDate_loan',
    'ui->cboStatus_loan_edit': 'ui->cboStatus_loan',
    'ui->cboSearchField_loan_edit': 'ui->cboSearchField_loan',
    'ui->lstSearch_loan_edit': 'ui->lstSearch_loan',
    
    # Loan Statuses page
    'ui->txtSearch_loanstatus': 'ui->txtSearch_loanstatus',
    'ui->cboStatusFilter_loanstatus': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loanstatus': 'ui->lstSearch_loanstatus',
    'ui->btnSearch_loanstatus': 'ui->btnSearch_loanstatus',
    'ui->btnRefresh_loanstatus': 'ui->btnRefresh_loanstatus',
    'ui->btnOverdueReport_loanstatus': 'ui->btnOverdueReport_loanstatus',
    'ui->btnFilter_loanstatus': 'ui->btnFilter_loanstatus',
    'ui->cboStatusFilter_loanstatus': 'ui->cboStatusFilter_loanstatus',
    'ui->lstSearch_loanstatus': 'ui->lstSearch_loanstatus',
    
    # Undo Readers page
    'ui->txtSearch_reader_undo': 'ui->txtSearch_undoreaders',
    'ui->cboValue_reader_undo': 'ui->cboValue_undoreaders',
    'ui->lstSearch_reader_undo': 'ui->lstSearch_undoreaders',
    'ui->txtValue_reader_undo': 'ui->txtValue_undoreaders',
    
    # Undo Readers page buttons
    'ui->btnSearch_reader_undo': 'ui->btnSearch_undoreaders',
    'ui->btnUndoAll_reader_undo': 'ui->btnUndoAll_undoreaders',
    'ui->btnUndoSelected_reader_undo': 'ui->btnUndoSelected_undoreaders',
    'ui->btnRedoRemove_reader_undo': 'ui->btnRedoRemove_undoreaders',
    'ui->btnRedoAllSelected_reader_undo': 'ui->btnRedoAllSelected_undoreaders',
    'ui->lstSearch_reader_undo': 'ui->lstSearch_undoreaders',
    
    # Remove Readers page
    'ui->btnRemove_reader_remove': 'ui->btnRemove_reader_remove',
    'ui->btnUndoRemoval_reader_remove': 'ui->btnUndoRemoval_reader_remove',
    'ui->btnUndoLast_reader_remove': 'ui->btnUndoLast_reader_remove',
}

for old, new in replacements.items():
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        print(f"Fixed {count}x: {old} -> {new}")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")