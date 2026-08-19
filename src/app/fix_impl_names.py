#!/usr/bin/env python3
"""Fix function implementation names to match new slot names"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

# Map old function names to new ones based on widget name changes
replacements = {
    # Clear buttons - register page
    'on_btnClear_username_register_clicked': 'on_btnClear_username_register_clicked',
    'on_btnClear_password1_register_clicked': 'on_btnClear_password1_register_clicked',
    'on_btnClear_password2_register_clicked': 'on_btnClear_password2_register_clicked',
    
    # Add Books page
    'on_btnClear_title_addbooks_clicked': 'on_btnClear_title_book_clicked',
    'on_btnClear_author_addbooks_clicked': 'on_btnClear_author_book_clicked',
    'on_btnClear_id_addbooks_clicked': 'on_btnClear_id_book_clicked',
    'on_btnUndoAdd_addbooks_clicked': 'on_btnUndoAdd_book_clicked',
    'on_btnAddBook_addbooks_clicked': 'on_btnAdd_book_clicked',
    'on_btnSearch_editbooks_clicked': 'on_btnSearch_book_edit_clicked',
    'on_lstSearch_editbooks_itemClicked': 'on_lstSearch_book_edit_itemClicked',
    'on_btnClear_title_editbooks_clicked': 'on_btnClear_title_book_edit_clicked',
    'on_btnClear_author_editbooks_clicked': 'on_btnClear_author_book_edit_clicked',
    'on_btnClear_id_editbooks_clicked': 'on_btnClear_id_book_edit_clicked',
    'on_btnEditBook_editbooks_clicked': 'on_btnEdit_book_clicked',
    'on_btnUndoEdit_editbooks_clicked': 'on_btnUndoEdit_book_clicked',
    'on_btnUndoAdd_editbooks_clicked': 'on_btnUndoAdd_book_clicked',
    'on_btnSearch_editbooks_clicked': 'on_btnSearch_book_edit_clicked',
    
    # Remove Books page
    'on_btnClear_title_removebooks_clicked': 'on_btnClear_title_book_remove_clicked',
    'on_btnClear_author_removebooks_clicked': 'on_btnClear_author_book_remove_clicked',
    'on_btnClear_id_removebooks_clicked': 'on_btnClear_id_book_remove_clicked',
    'on_btnSearch_removebooks_clicked': 'on_btnSearch_book_remove_clicked',
    'on_lstSearch_removebooks_itemClicked': 'on_lstSearch_book_remove_itemClicked',
    'on_btnRemove_removebooks_clicked': 'on_btnRemove_book_clicked',
    'on_btnUndoRemoval_removebooks_clicked': 'on_btnUndoRemoval_book_clicked',
    'on_btnUndoLast_removebooks_clicked': 'on_btnUndoLast_book_clicked',
    'on_btnUndoAll_undoremovebooks_clicked': 'on_btnUndoAll_book_undo_clicked',
    'on_btnUndoSelected_undoremovebooks_clicked': 'on_btnUndoSelected_book_undo_clicked',
    'on_btnRedoRemove_undoremovebooks_clicked': 'on_btnRedoRemove_book_undo_clicked',
    'on_btnRedoAllSelected_undoremovebooks_clicked': 'on_btnRedoAllSelected_book_undo_clicked',
    'on_lstSearch_undoremovebooks_itemClicked': 'on_lstSearch_book_undo_itemClicked',
    
    # Manage Categories page
    'on_btnSearch_managecategories_clicked': 'on_btnSearch_category_clicked',
    'on_lstSearch_managecategories_itemClicked': 'on_lstSearch_category_itemClicked',
    'on_btnClear_name_managecategories_clicked': 'on_btnClear_name_category_clicked',
    'on_btnAddCategory_managecategories_clicked': 'on_btnAdd_category_clicked',
    'on_btnEditCategory_managecategories_clicked': 'on_btnEdit_category_clicked',
    'on_btnRemoveCategory_managecategories_clicked': 'on_btnRemove_category_clicked',
    'on_btnUndoRemove_managecategories_clicked': 'on_btnUndoRemove_category_clicked',
    'on_btnUndoEdit_managecategories_clicked': 'on_btnUndoEdit_category_clicked',
    'on_btnUndoAdd_managecategories_clicked': 'on_btnUndoAdd_category_clicked',
    
    # Manage Locations page
    'on_btnSearch_managelocations_clicked': 'on_btnSearch_location_clicked',
    'on_lstSearch_managelocations_itemClicked': 'on_lstSearch_location_itemClicked',
    'on_btnClear_name_managelocations_clicked': 'on_btnClear_name_location_clicked',
    'on_btnAddLocation_managelocations_clicked': 'on_btnAdd_location_clicked',
    'on_btnEditLocation_managelocations_clicked': 'on_btnEdit_location_clicked',
    'on_btnRemoveLocation_managelocations_clicked': 'ui->btnRemove_location_clicked',
    'on_btnUndoRemove_managelocations_clicked': 'on_btnUndoRemove_location_clicked',
    'on_btnUndoEdit_managelocations_clicked': 'on_btnUndoEdit_location_clicked',
    'on_btnUndoAdd_managelocations_clicked': 'on_btnUndoAdd_location_clicked',
    'on_lstSearch_managelocations_itemClicked': 'on_lstSearch_location_itemClicked',
    
    # Add Readers page
    'on_btnClear_name_addreaders_clicked': 'on_btnClear_name_reader_clicked',
    'on_btnClear_surname_addreaders_clicked': 'on_btnClear_surname_reader_clicked',
    'on_btnClear_grade_addreaders_clicked': 'on_btnClear_grade_reader_clicked',
    'on_btnClear_class_addreaders_clicked': 'on_btnClear_class_reader_clicked',
    'on_btnClear_id_addreaders_clicked': 'on_btnClear_id_reader_clicked',
    'on_btnAddBook_addreaders_clicked': 'on_btnAdd_reader_clicked',
    'on_btnUndoAdd_addreaders_clicked': 'on_btnUndoAdd_reader_clicked',
    
    # Edit Readers page
    'on_btnSearch_editreaders_clicked': 'on_btnSearch_reader_edit_clicked',
    'on_lstSearch_editreaders_itemClicked': 'on_lstSearch_reader_edit_itemClicked',
    'on_btnClear_name_editreaders_clicked': 'on_btnClear_name_reader_edit_clicked',
    'on_btnClear_surname_editreaders_clicked': 'on_btnClear_surname_reader_edit_clicked',
    'on_btnClear_grade_editreaders_clicked': 'on_btnClear_grade_reader_edit_clicked',
    'on_btnClear_class_editreaders_clicked': 'on_btnClear_class_reader_edit_clicked',
    'on_btnClear_id_editreaders_clicked': 'on_btnClear_id_reader_edit_clicked',
    'on_btnEditBook_editreaders_clicked': 'on_btnEdit_reader_clicked',
    'on_btnUndoEdit_editreaders_clicked': 'on_btnUndoEdit_reader_clicked',
    
    # Remove Readers page
    'on_btnSearch_removereaders_clicked': 'on_btnSearch_reader_remove_clicked',
    'on_lstSearch_removereaders_itemClicked': 'on_lstSearch_reader_remove_itemClicked',
    'on_btnClear_name_removereaders_clicked': 'on_btnClear_name_reader_remove_clicked',
    'on_btnClear_surname_removereaders_clicked': 'on_btnClear_surname_reader_remove_clicked',
    'on_btnClear_grade_removereaders_clicked': 'on_btnClear_grade_reader_remove_clicked',
    'on_btnClear_class_removereaders_clicked': 'on_btnClear_class_reader_remove_clicked',
    'on_btnClear_id_removereaders_clicked': 'on_btnClear_id_reader_remove_clicked',
    'on_btnRemove_removereaders_clicked': 'on_btnRemove_reader_clicked',
    'on_btnUndoRemoval_removereaders_clicked': 'on_btnUndoRemoval_reader_clicked',
    'on_btnUndoLast_removereaders_clicked': 'on_btnUndoLast_reader_clicked',
    
    # Undo Readers page
    'on_btnSearch_undoremovereaders_clicked': 'on_btnSearch_reader_undo_clicked',
    'on_lstSearch_undoremovereaders_itemClicked': 'on_lstSearch_reader_undo_itemClicked',
    'on_btnUndoAll_undoremovereaders_clicked': 'on_btnUndoAll_reader_undo_clicked',
    'on_btnUndoSelected_undoremovereaders_clicked': 'on_btnUndoSelected_reader_undo_clicked',
    'on_btnRedoRemove_undoremovereaders_clicked': 'on_btnRedoRemove_reader_undo_clicked',
    'on_btnRedoAllSelected_undoremovereaders_clicked': 'on_btnRedoAllSelected_reader_undo_clicked',
    'on_lstSearch_undoremovereaders_itemClicked': 'on_lstSearch_reader_undo_itemClicked',
    
    # Add Loans page
    'on_btnSearchBook_addloan_clicked': 'on_btnSearch_book_add_clicked',
    'on_btnSearchReader_clicked': 'on_btnSearch_reader_add_clicked',
    'on_btnAddLoan_addloan_clicked': 'on_btnAdd_loan_add_clicked',
    'on_btnClear_addloan_clicked': 'on_btnClear_loan_add_clicked',
    'on_lstSearch_book_itemClicked': 'on_lstSearch_book_loan_add_itemClicked',
    'on_lstSearch_reader_itemClicked': 'on_lstSearch_reader_loan_add_itemClicked',
    
    # Edit Loans page
    'on_btnSearchLoan_editloan_clicked': 'on_btnSearch_loan_edit_clicked',
    'on_lstSearch_editloan_itemClicked': 'on_lstSearch_loan_edit_itemClicked',
    'on_btnUpdateLoan_editloan_clicked': 'on_btnUpdate_loan_edit_clicked',
    'on_btnReturnLoan_editloan_clicked': 'on_btnReturn_loan_edit_clicked',
    'on_btnClear_editloan_clicked': 'on_btnClear_loan_edit_clicked',
    
    # Loan Statuses page
    'on_btnFilter_loanstatus_clicked': 'on_btnFilter_loan_status_clicked',
    'on_btnSearch_loanstatus_clicked': 'on_btnSearch_loan_status_clicked',
    'on_btnRefresh_loanstatus_clicked': 'on_btnRefresh_loan_status_clicked',
    'on_btnOverdueReport_loanstatus_clicked': 'on_btnOverdueReport_loan_status_clicked',
    'on_lstSearch_loanstatus_itemDoubleClicked': 'on_lstSearch_loan_status_itemDoubleClicked',
    
    # Manage Categories page (already mostly correct)
    'on_btnSearch_managecategories_clicked': 'on_btnSearch_category_clicked',
    'on_lstSearch_managecategories_itemClicked': 'on_lstSearch_category_itemClicked',
    'on_btnClear_name_managecategories_clicked': 'on_btnClear_name_category_clicked',
    'on_btnAddCategory_managecategories_clicked': 'on_btnAdd_category_clicked',
    'on_btnEditCategory_managecategories_clicked': 'on_btnEdit_category_clicked',
    'on_btnRemoveCategory_managecategories_clicked': 'on_btnRemove_category_clicked',
    'on_btnUndoRemove_managecategories_clicked': 'on_btnUndoRemove_category_clicked',
    'on_btnUndoEdit_managecategories_clicked': 'on_btnUndoEdit_category_clicked',
    'on_btnUndoAdd_managecategories_clicked': 'on_btnUndoAdd_category_clicked',
    'on_lstSearch_managecategories_itemClicked': 'on_lstSearch_category_itemClicked',
    
    # Manage Locations page
    'on_btnSearch_managelocations_clicked': 'on_btnSearch_location_clicked',
    'on_lstSearch_managelocations_itemClicked': 'on_lstSearch_location_itemClicked',
    'on_btnClear_name_managelocations_clicked': 'on_btnClear_name_location_clicked',
    'on_btnAddLocation_managelocations_clicked': 'on_btnAdd_location_clicked',
    'on_btnEditLocation_managelocations_clicked': 'on_btnEdit_location_clicked',
    'on_btnRemoveLocation_managelocations_clicked': 'on_btnRemove_location_clicked',
    'on_btnUndoRemove_managelocations_clicked': 'on_btnUndoRemove_location_clicked',
    'on_btnUndoEdit_managelocations_clicked': 'on_btnUndoEdit_location_clicked',
    'on_btnUndoAdd_managelocations_clicked': 'on_btnUndoAdd_location_clicked',
    'on_lstSearch_managelocations_itemClicked': 'on_lstSearch_location_itemClicked',
    
    # Add Readers page
    'on_btnClear_name_addreaders_clicked': 'on_btnClear_name_reader_clicked',
    'on_btnClear_surname_addreaders_clicked': 'on_btnClear_surname_reader_clicked',
    'on_btnClear_grade_addreaders_clicked': 'on_btnClear_grade_reader_clicked',
    'on_btnClear_class_addreaders_clicked': 'on_btnClear_class_reader_clicked',
    'on_btnClear_id_addreaders_clicked': 'on_btnClear_id_reader_clicked',
    'on_btnAddBook_addreaders_clicked': 'on_btnAdd_reader_clicked',
    'on_btnUndoAdd_addreaders_clicked': 'on_btnUndoAdd_reader_clicked',
    
    # Edit Readers page
    'on_btnSearch_editreaders_clicked': 'on_btnSearch_reader_edit_clicked',
    'on_lstSearch_editreaders_itemClicked': 'on_lstSearch_reader_edit_itemClicked',
    'on_btnClear_name_editreaders_clicked': 'on_btnClear_name_reader_edit_clicked',
    'on_btnClear_surname_editreaders_clicked': 'on_btnClear_surname_reader_edit_clicked',
    'on_btnClear_grade_editreaders_clicked': 'on_btnClear_grade_reader_edit_clicked',
    'on_btnClear_class_editreaders_clicked': 'on_btnClear_class_reader_edit_clicked',
    'on_btnClear_id_editreaders_clicked': 'on_btnClear_id_reader_edit_clicked',
    'on_btnEditBook_editreaders_clicked': 'on_btnEdit_reader_clicked',
    'on_btnUndoEdit_editreaders_clicked': 'on_btnUndoEdit_reader_clicked',
    
    # Remove Readers page
    'on_btnSearch_removereaders_clicked': 'on_btnSearch_reader_remove_clicked',
    'on_lstSearch_removereaders_itemClicked': 'on_lstSearch_reader_remove_itemClicked',
    'on_btnClear_name_removereaders_clicked': 'on_btnClear_name_reader_remove_clicked',
    'on_btnClear_surname_removereaders_clicked': 'on_btnClear_surname_reader_remove_clicked',
    'on_btnClear_grade_removereaders_clicked': 'on_btnClear_grade_reader_remove_clicked',
    'on_btnClear_class_removereaders_clicked': 'on_btnClear_class_reader_remove_clicked',
    'on_btnClear_id_removereaders_clicked': 'on_btnClear_id_reader_remove_clicked',
    'on_btnRemove_removereaders_clicked': 'on_btnRemove_reader_clicked',
    'on_btnUndoRemoval_removereaders_clicked': 'on_btnUndoRemoval_reader_clicked',
    'on_btnUndoLast_removereaders_clicked': 'on_btnUndoLast_reader_clicked',
    
    # Undo Readers page
    'on_btnSearch_undoremovereaders_clicked': 'on_btnSearch_reader_undo_clicked',
    'on_lstSearch_undoremovereaders_itemClicked': 'on_lstSearch_reader_undo_itemClicked',
    'on_btnUndoAll_undoremovereaders_clicked': 'on_btnUndoAll_reader_undo_clicked',
    'on_btnUndoSelected_undoremovereaders_clicked': 'on_btnUndoSelected_reader_undo_clicked',
    'on_btnRedoRemove_undoremovereaders_clicked': 'on_btnRedoRemove_reader_undo_clicked',
    'on_btnRedoAllSelected_undoremovereaders_clicked': 'on_btnRedoAllSelected_reader_undo_clicked',
    'on_lstSearch_undoremovereaders_itemClicked': 'on_lstSearch_reader_undo_itemClicked',
    
    # Add Loans page
    'on_btnSearchBook_addloan_clicked': 'on_btnSearch_book_add_clicked',
    'on_btnSearchReader_clicked': 'on_btnSearch_reader_add_clicked',
    'on_btnAddLoan_addloan_clicked': 'on_btnAdd_loan_add_clicked',
    'on_btnClear_addloan_clicked': 'on_btnClear_loan_add_clicked',
    'on_lstSearch_book_itemClicked': 'on_lstSearch_book_loan_add_itemClicked',
    'on_lstSearchReader_clicked': 'on_lstSearch_reader_loan_add_itemClicked',
    
    # Edit Loans page
    'on_btnSearchLoan_editloan_clicked': 'on_btnSearch_loan_edit_clicked',
    'on_lstSearch_editloan_itemClicked': 'on_lstSearch_loan_edit_itemClicked',
    'on_btnUpdateLoan_editloan_clicked': 'on_btnUpdate_loan_edit_clicked',
    'on_btnReturnLoan_editloan_clicked': 'on_btnReturn_loan_edit_clicked',
    'on_btnClear_editloan_clicked': 'on_btnClear_loan_edit_clicked',
    
    # Loan Statuses page
    'on_btnFilter_loanstatus_clicked': 'on_btnFilter_loan_status_clicked',
    'on_btnSearch_loanstatus_clicked': 'on_btnSearch_loan_status_clicked',
    'on_btnRefresh_loanstatus_clicked': 'on_btnRefresh_loan_status_clicked',
    'on_btnOverdueReport_loanstatus_clicked': 'on_btnOverdueReport_loan_status_clicked',
    'on_lstSearch_loanstatus_itemDoubleClicked': 'on_lstSearch_loan_status_itemDoubleClicked',
}

for old, new in replacements.items():
    count = content.count(f'void MainWindow::{old}(')
    if count > 0:
        content = content.replace(f'void MainWindow::{old}(', f'void MainWindow::{new}(')
        print(f"Updated {count}x: {old} -> {new}")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")