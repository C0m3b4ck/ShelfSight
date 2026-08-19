#!/usr/bin/env python3
"""
Update function implementation names in mainwindow.cpp
"""

# Mapping from old function names to new ones
impl_replacements = {
    # Clear buttons
    'on_btnClear_title_book_clicked': 'on_btnClear_title_book_add_clicked',
    'on_btnClear_author_book_clicked': 'on_btnClear_author_book_add_clicked',
    'on_btnClear_id_book_clicked': 'on_btnClear_id_book_add_clicked',
    'on_btnClear_title_book_edit_clicked': 'on_btnClear_title_book_edit_clicked',
    'on_btnClear_author_book_edit_clicked': 'on_btnClear_author_book_edit_clicked',
    'on_btnClear_id_book_edit_clicked': 'on_btnClear_id_book_edit_clicked',
    'on_btnClear_name_category_clicked': 'on_btnClear_name_category_clicked',
    'on_btnClear_name_location_clicked': 'on_btnClear_name_location_clicked',
    'on_btnClear_name_reader_clicked': 'on_btnClear_name_reader_add_clicked',
    'on_btnClear_surname_reader_clicked': 'on_btnClear_surname_reader_add_clicked',
    'on_btnClear_grade_reader_clicked': 'on_btnClear_grade_reader_add_clicked',
    'on_btnClear_class_reader_clicked': 'on_btnClear_class_reader_add_clicked',
    'on_btnClear_id_reader_clicked': 'on_btnClear_id_reader_add_clicked',
    'on_btnClear_name_reader_edit_clicked': 'on_btnClear_name_reader_edit_clicked',
    'on_btnClear_surname_reader_edit_clicked': 'on_btnClear_surname_reader_edit_clicked',
    'on_btnClear_grade_reader_edit_clicked': 'on_btnClear_grade_reader_edit_clicked',
    'on_btnClear_class_reader_edit_clicked': 'on_btnClear_class_reader_edit_clicked',
    'on_btnClear_id_reader_edit_clicked': 'on_btnClear_id_reader_edit_clicked',
    'on_btnClear_name_reader_remove_clicked': 'on_btnClear_name_reader_remove_clicked',
    'on_btnClear_surname_reader_remove_clicked': 'on_btnClear_surname_reader_remove_clicked',
    'on_btnClear_grade_reader_remove_clicked': 'on_btnClear_grade_reader_remove_clicked',
    'on_btnClear_class_reader_remove_clicked': 'on_btnClear_class_reader_remove_clicked',
    'on_btnClear_id_reader_remove_clicked': 'on_btnClear_id_reader_remove_clicked',
    
    # Undo buttons
    'on_btnUndoAdd_book_clicked': 'on_btnUndoAdd_book_add_clicked',
    'on_btnUndoEdit_book_clicked': 'on_btnUndoEdit_book_edit_clicked',
    'on_btnEdit_book_clicked': 'on_btnEdit_book_edit_clicked',
    'on_btnSearch_book_edit_clicked': 'on_btnSearch_book_edit_clicked',
    'on_btnUndoAdd_category_clicked': 'on_btnUndoAdd_category_clicked',
    'on_btnUndoRemove_category_clicked': 'on_btnUndoRemove_category_clicked',
    'on_btnUndoEdit_category_clicked': 'on_btnUndoEdit_category_clicked',
    'on_btnUndoAdd_category_clicked': 'on_btnUndoAdd_category_clicked',
    'on_btnAdd_category_clicked': 'on_btnAdd_category_clicked',
    'on_btnEdit_category_clicked': 'on_btnEdit_category_clicked',
    'on_btnRemove_category_clicked': 'on_btnRemove_category_clicked',
    'on_btnSearch_undobooks_clicked': 'on_btnSearch_book_undo_clicked',
    'on_btnSearch_book_remove_clicked': 'on_btnSearch_book_remove_clicked',
    'on_btnUndoAll_undobooks_clicked': 'on_btnUndoAll_book_undo_clicked',
    'on_btnUndoSelected_undobooks_clicked': 'on_btnUndoSelected_book_undo_clicked',
    'on_btnRedoRemove_undobooks_clicked': 'on_btnRedoRemove_book_undo_clicked',
    'on_btnRedoAllSelected_undobooks_clicked': 'on_btnRedoAllSelected_book_undo_clicked',
    
    'on_btnSearch_undoreaders_clicked': 'on_btnSearch_reader_undo_clicked',
    'on_btnUndoAll_undoreaders_clicked': 'on_btnUndoAll_reader_undo_clicked',
    'on_btnUndoSelected_undoreaders_clicked': 'on_btnUndoSelected_reader_undo_clicked',
    'on_btnRedoRemove_undoreaders_clicked': 'on_btnRedoRemove_reader_undo_clicked',
    'on_btnRedoAllSelected_undoreaders_clicked': 'on_btnRedoAllSelected_reader_undo_clicked',
    
    # Reader clear buttons
    'on_btnClear_name_reader_clicked': 'on_btnClear_name_reader_add_clicked',
    'on_btnClear_surname_reader_clicked': 'on_btnClear_surname_reader_add_clicked',
    'on_btnClear_grade_reader_clicked': 'on_btnClear_grade_reader_add_clicked',
    'on_btnClear_class_reader_clicked': 'on_btnClear_class_reader_add_clicked',
    'on_btnClear_id_reader_clicked': 'on_btnClear_id_reader_add_clicked',
    
    # Reader edit page clear buttons
    'on_btnClear_name_reader_edit_clicked': 'on_btnClear_name_reader_edit_clicked',
    'on_btnClear_surname_reader_edit_clicked': 'on_btnClear_surname_reader_edit_clicked',
    'on_btnClear_grade_reader_edit_clicked': 'on_btnClear_grade_reader_edit_clicked',
    'on_btnClear_class_reader_edit_clicked': 'on_btnClear_class_reader_edit_clicked',
    'on_btnClear_id_reader_edit_clicked': 'on_btnClear_id_reader_edit_clicked',
    
    # Reader remove page clear buttons
    'on_btnClear_name_reader_remove_clicked': 'on_btnClear_name_reader_remove_clicked',
    'on_btnClear_surname_reader_remove_clicked': 'on_btnClear_surname_reader_remove_clicked',
    'on_btnClear_grade_reader_remove_clicked': 'on_btnClear_grade_reader_remove_clicked',
    'on_btnClear_class_reader_remove_clicked': 'on_btnClear_class_reader_remove_clicked',
    'on_btnClear_id_reader_remove_clicked': 'on_btnClear_id_reader_remove_clicked',
    
    # Add reader
    'on_btnAdd_reader_clicked': 'on_btnAdd_reader_add_clicked',
    'on_btnEdit_reader_clicked': 'on_btnEdit_reader_edit_clicked',
    'on_btnUndoEdit_reader_clicked': 'on_btnUndoEdit_reader_edit_clicked',
    
    # Remove book
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
    
    # Loans
    'on_btnSearch_book_clicked': 'on_btnSearch_book_add_clicked',
    'on_btnSearch_reader_clicked': 'on_btnSearch_reader_add_clicked',
    'on_btnAdd_loan_clicked': 'on_btnAdd_loan_add_clicked',
    'on_btnClear_loan_clicked': 'on_btnClear_loan_add_clicked',
    'on_btnSearch_loan_edit_clicked': 'on_btnSearch_loan_edit_clicked',
    'on_lstSearch_loan_edit_itemClicked': 'on_lstSearch_loan_edit_itemClicked',
    'on_btnUpdate_loan_edit_clicked': 'on_btnUpdate_loan_edit_clicked',
    'on_btnReturn_loan_edit_clicked': 'on_btnReturn_loan_edit_clicked',
    'on_btnClear_loan_edit_clicked': 'on_btnClear_loan_edit_clicked',
    'on_btnFilter_loanstatus_clicked': 'on_btnFilter_loan_status_clicked',
    'on_btnSearch_loanstatus_clicked': 'on_btnSearch_loan_status_clicked',
    'on_btnRefresh_loanstatus_clicked': 'on_btnRefresh_loan_status_clicked',
    'on_btnOverdueReport_loanstatus_clicked': 'on_btnOverdueReport_loan_status_clicked',
    'on_lstSearch_loanstatus_itemDoubleClicked': 'on_lstSearch_loan_status_itemDoubleClicked',
    
    # Action handlers
    'on_actionAddLoans_triggered': 'on_actionAddLoans_triggered',
    'on_actionEditLoans_triggered': 'on_actionEditLoans_triggered',
    'on_actionSearchLoans_triggered': 'on_actionSearchLoans_triggered',
}

if __name__ == '__main__':
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
        content = f.read()
    
    for old, new in impl_replacements.items():
        # Replace function definitions
        count = content.count(f'void MainWindow::{old}(')
        if count > 0:
            content = content.replace(f'void MainWindow::{old}(', f'void MainWindow::{new}(')
            print(f"Updated impl: {old} -> {new} ({count}x)")
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
        f.write(content)
    
    print("Done updating implementations!")