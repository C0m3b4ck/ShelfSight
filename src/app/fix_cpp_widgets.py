#!/usr/bin/env python3
"""Fix widget name references in mainwindow.cpp to match actual UI file"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

# Mapping of old (incorrect) widget names to correct UI widget names
replacements = {
    # Register page - already fixed
    
    # Add Books page (page_3) - remove _add suffix
    'txtTitle_book_add': 'txtTitle_book',
    'txtAuthor_book_add': 'txtAuthor_book',
    'txtId_book_add': 'txtId_book',
    'cboLocation_book_add': 'cboLocation_book',
    'cboCategory_book_add': 'cboCategory_book',
    'cboStatus_book_add': 'cboStatus_book',
    'btnAdd_book_add': 'btnAdd_book',
    'btnUndoAdd_book_add': 'btnUndoAdd_book',
    'btnClear_title_book_add': 'btnClear_title_book',
    'btnClear_author_book_add': 'btnClear_author_book',
    'btnClear_id_book_add': 'btnClear_id_book',
    
    # Edit Books page - already correct with _edit suffix
    
    # Book Remove page - remove _remove suffix where it was added incorrectly
    'txtTitle_book_remove': 'txtTitle_book_remove',
    'txtAuthor_book_remove': 'txtAuthor_book_remove',
    'txtId_book_remove': 'txtId_book_remove',
    
    # Add Readers page (page_10) - remove _add suffix
    'txtName_reader_add': 'txtName_reader',
    'txtSurname_reader_add': 'txtSurname_reader',
    'txtGrade_reader_add': 'txtGrade_reader',
    'txtClass_reader_add': 'txtClass_reader',
    'txtId_reader_add': 'txtId_reader',
    'btnAdd_reader_add': 'btnAdd_reader',
    'btnUndoAdd_reader_add': 'btnUndoAdd_reader',
    'btnClear_name_reader_add': 'btnClear_name_reader',
    'btnClear_surname_reader_add': 'btnClear_surname_reader',
    'btnClear_grade_reader_add': 'btnClear_grade_reader',
    'btnClear_class_reader_add': 'btnClear_class_reader',
    'btnClear_id_reader_add': 'btnClear_id_reader',
    
    # Edit Readers page - already correct with _edit suffix
    
    # Reader Remove page
    'txtName_reader_remove': 'txtName_reader_remove',
    'txtSurname_reader_remove': 'txtSurname_reader_remove',
    'txtGrade_reader_remove': 'txtGrade_reader_remove',
    'txtClass_reader_remove': 'txtClass_reader_remove',
    'txtId_reader_remove': 'txtId_reader_remove',
    
    # Add Loans page
    'txtSearch_book_add': 'txtSearch_book_add',
    'txtSearch_reader_add': 'txtSearch_reader_add',
    'txtSelected_book_add': 'txtSelected_book_add',
    'txtSelected_reader_add': 'txtSelected_reader_add',
    'spnLoanDays_loan_add': 'spnLoanDays_loan_add',
    'btnSearch_book_add': 'btnSearch_book_add',
    'btnSearch_reader_add': 'btnSearch_reader_add',
    'btnAdd_loan_add': 'btnAdd_loan_add',
    'btnClear_loan_add': 'btnClear_loan_add',
    
    # Loan Edit page - already correct with _edit suffix
    
    # Loan Status page - fix _loan_status to _loan_status
    'cboStatusFilter_loanstatus': 'cboStatusFilter_loan_status',
    'txtSearch_loanstatus': 'txtSearch_loan_status',
    'lstSearch_loanstatus': 'lstSearch_loan_status',
    'btnSearch_loanstatus': 'btnSearch_loan_status',
    'btnRefresh_loanstatus': 'btnRefresh_loan_status',
    'btnOverdueReport_loanstatus': 'btnOverdueReport_loan_status',
    'btnFilter_loanstatus': 'btnFilter_loan_status',
    
    # Manage Categories page
    'txtName_managecategories': 'txtName_category',
    'btnClear_name_managecategories': 'btnClear_name_category',
    
    # Manage Locations page
    'txtName_managelocations': 'txtName_location',
    'btnClear_name_managelocations': 'btnClear_name_location',
    
    # Login page
    'txtUsername_login': 'txtUsername_login',
    'txtPassword_login': 'txtPassword_login',
}

if __name__ == '__main__':
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
        content = f.read()
    
    for old, new in replacements.items():
        # Only replace ui->old patterns
        pattern = f'ui->{old}'
        replacement = f'ui->{new}'
        count = content.count(pattern)
        if count > 0:
            content = content.replace(pattern, replacement)
            print(f"Replaced {count}x: {pattern} -> {replacement}")
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
        f.write(content)
    
    print("Done!")