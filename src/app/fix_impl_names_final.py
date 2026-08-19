#!/usr/bin/env python3
"""Fix function implementation names to match UI widget names"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

# Map old function names to new ones based on actual UI widget names
impl_replacements = {
    # Clear buttons - Add Books page
    'on_btnClear_title_addbooks_clicked': 'on_btnClear_title_book_clicked',
    'on_btnClear_author_addbooks_clicked': 'on_btnClear_author_book_clicked',
    'on_btnClear_id_addbooks_clicked': 'on_btnClear_id_book_clicked',
    
    # Clear buttons - Edit Books page
    'on_btnClear_title_editbooks_clicked': 'on_btnClear_title_book_edit_clicked',
    'on_btnClear_author_editbooks_clicked': 'on_btnClear_author_book_edit_clicked',
    'on_btnClear_id_editbooks_clicked': 'on_btnClear_id_book_edit_clicked',
    
    # Clear buttons - Manage Categories
    'on_btnClear_name_managecategories_clicked': 'on_btnClear_name_category_clicked',
    
    # Clear buttons - Manage Locations
    'on_btnClear_name_managelocations_clicked': 'on_btnClear_name_location_clicked',
    
    # Clear buttons - Add Readers page
    'on_btnClear_name_addreaders_clicked': 'on_btnClear_name_reader_clicked',
    'on_btnClear_surname_addreaders_clicked': 'on_btnClear_surname_reader_clicked',
    'on_btnClear_grade_addreaders_clicked': 'on_btnClear_grade_reader_clicked',
    'on_btnClear_class_addreaders_clicked': 'on_btnClear_class_reader_clicked',
    'on_btnClear_id_addreaders_clicked': 'on_btnClear_id_reader_clicked',
    
    # Clear buttons - Edit Readers page
    'on_btnClear_name_editreaders_clicked': 'on_btnClear_name_reader_edit_clicked',
    'on_btnClear_surname_editreaders_clicked': 'on_btnClear_surname_reader_edit_clicked',
    'on_btnClear_grade_editreaders_clicked': 'on_btnClear_grade_reader_edit_clicked',
    'on_btnClear_class_editreaders_clicked': 'on_btnClear_class_reader_edit_clicked',
    'on_btnClear_id_editreaders_clicked': 'on_btnClear_id_reader_edit_clicked',
    
    # Clear buttons - Remove Readers page
    'on_btnClear_name_removereaders_clicked': 'on_btnClear_name_reader_remove_clicked',
    'on_btnClear_surname_removereaders_clicked': 'on_btnClear_surname_reader_remove_clicked',
    'on_btnClear_grade_removereaders_clicked': 'on_btnClear_grade_reader_remove_clicked',
    'on_btnClear_class_removereaders_clicked': 'on_btnClear_class_reader_remove_clicked',
    'on_btnClear_id_removereaders_clicked': 'on_btnClear_id_reader_remove_clicked',
    
    # Undo buttons - Add Books
    'on_btnUndoAdd_addbooks_clicked': 'on_btnUndoAdd_book_clicked',
    
    # Undo buttons - Edit Books
    'on_btnUndoEdit_editbooks_clicked': 'on_btnUndoEdit_book_edit_clicked',
    'on_btnUndoAdd_editbooks_clicked': 'on_btnUndoAdd_book_edit_clicked',
    
    # Undo buttons - Manage Categories
    'on_btnUndoRemove_managecategories_clicked': 'on_btnUndoRemove_category_clicked',
    'on_btnUndoEdit_managecategories_clicked': 'on_btnUndoEdit_category_clicked',
    'on_btnUndoAdd_managecategories_clicked': 'on_btnUndoAdd_category_clicked',
    
    # Undo buttons - Manage Locations
    'on_btnUndoRemove_managelocations_clicked': 'on_btnUndoRemove_location_clicked',
    'on_btnUndoEdit_managelocations_clicked': 'on_btnUndoEdit_location_clicked',
    'on_btnUndoAdd_managelocations_clicked': 'on_btnUndoAdd_location_clicked',
    
    # Undo buttons - Add Readers
    'on_btnUndoAdd_addreaders_clicked': 'on_btnUndoAdd_reader_clicked',
    
    # Undo buttons - Edit Readers
    'on_btnUndoEdit_editreaders_clicked': 'on_btnUndoEdit_reader_edit_clicked',
    
    # Undo buttons - Remove Readers
    'on_btnUndoRemoval_removereaders_clicked': 'on_btnUndoRemoval_reader_remove_clicked',
    'on_btnUndoLast_removereaders_clicked': 'on_btnUndoLast_reader_remove_clicked',
    
    # Search buttons
    'on_btnSearch_editbooks_clicked': 'on_btnSearch_book_edit_clicked',
    'on_btnSearch_managecategories_clicked': 'on_btnSearch_category_clicked',
    'on_btnSearch_managelocations_clicked': 'on_btnSearch_location_clicked',
    'ui->btnSearch_managelocations': 'ui->btnSearch_location',
    'ui->btnSearch_editreaders': 'ui->btnSearch_reader_edit',
    'ui->btnSearch_removereaders': 'ui->btnSearch_reader_remove',
    
    # Add/Edit/Remove buttons
    'on_btnAddBook_addbooks_clicked': 'on_btnAdd_book_clicked',
    'on_btnEditBook_editbooks_clicked': 'on_btnEdit_book_edit_clicked',
    'on_btnRemove_removebooks_clicked': 'on_btnRemove_book_clicked',
    'on_btnUndoRemoval_removebooks_clicked': 'on_btnUndoRemoval_book_clicked',
    'on_btnUndoLast_removebooks_clicked': 'on_btnUndoLast_book_clicked',
    
    'on_btnAddBook_addreaders_clicked': 'on_btnAdd_reader_clicked',
    'on_btnEditBook_editreaders_clicked': 'on_btnEdit_reader_edit_clicked',
    'on_btnRemove_removereaders_clicked': 'on_btnRemove_reader_remove_clicked',
    'on_btnUndoRemoval_removereaders_clicked': 'on_btnUndoRemoval_reader_remove_clicked',
    'on_btnUndoLast_removereaders_clicked': 'on_btnUndoLast_reader_remove_clicked',
    
    # Search buttons
    'on_btnSearch_undoremovebooks_clicked': 'on_btnSearch_undobooks_clicked',
    'on_btnSearch_undoremovereaders_clicked': 'on_btnSearch_undoreaders_clicked',
    'ui->btnSearch_undoremovebooks': 'ui->btnSearch_undobooks',
    'ui->btnSearch_undoremovereaders': 'ui->btnSearch_undoreaders',
    
    # Undo/Redo buttons
    'on_btnUndoAll_undoremovebooks_clicked': 'on_btnUndoAll_undobooks_clicked',
    'on_btnUndoSelected_undoremovebooks_clicked': 'on_btnUndoSelected_undobooks_clicked',
    'on_btnRedoRemove_undoremovebooks_clicked': 'on_btnRedoRemove_undobooks_clicked',
    'on_btnRedoAllSelected_undoremovebooks_clicked': 'on_btnRedoAllSelected_undobooks_clicked',
    'on_lstSearch_undoremovebooks_itemClicked': 'on_lstSearch_undobooks_itemClicked',
    
    'on_btnUndoAll_undoremovereaders_clicked': 'on_btnUndoAll_undoreaders_clicked',
    'on_btnUndoSelected_undoremovereaders_clicked': 'on_btnUndoSelected_undoreaders_clicked',
    'on_btnRedoRemove_undoremovereaders_clicked': 'on_btnRedoRemove_undoreaders_clicked',
    'on_btnRedoAllSelected_undoremovereaders_clicked': 'on_btnRedoAllSelected_undoreaders_clicked',
    'on_lstSearch_undoremovereaders_itemClicked': 'on_lstSearch_undoreaders_itemClicked',
    
    # Add/Edit/Remove buttons
    'on_btnAddBook_addbooks_clicked': 'on_btnAdd_book_clicked',
    'on_btnEditBook_editbooks_clicked': 'on_btnEdit_book_edit_clicked',
    'on_btnUndoEdit_editbooks_clicked': 'on_btnUndoEdit_book_edit_clicked',
    'on_btnSearch_editbooks_clicked': 'on_btnSearch_book_edit_clicked',
    'on_lstSearch_editbooks_itemClicked': 'on_lstSearch_book_edit_itemClicked',
    
    'on_btnAddBook_addreaders_clicked': 'on_btnAdd_reader_clicked',
    'on_btnEditBook_editreaders_clicked': 'on_btnEdit_reader_edit_clicked',
    'on_btnUndoEdit_editreaders_clicked': 'on_btnUndoEdit_reader_edit_clicked',
    'on_btnSearch_editreaders_clicked': 'on_btnSearch_reader_edit_clicked',
    'on_lstSearch_editreaders_itemClicked': 'on_lstSearch_reader_edit_itemClicked',
    
    'on_btnRemove_removebooks_clicked': 'on_btnRemove_book_clicked',
    'on_btnUndoRemoval_removebooks_clicked': 'on_btnUndoRemoval_book_clicked',
    'on_btnUndoLast_removebooks_clicked': 'on_btnUndoLast_book_clicked',
    'on_btnSearch_removebooks_clicked': 'on_btnSearch_book_remove_clicked',
    'on_lstSearch_removebooks_itemClicked': 'on_lstSearch_book_remove_itemClicked',
    
    'on_btnAddBook_addreaders_clicked': 'on_btnAdd_reader_clicked',
    'on_btnEditBook_editreaders_clicked': 'on_btnEdit_reader_edit_clicked',
    'on_btnUndoEdit_editreaders_clicked': 'on_btnUndoEdit_reader_edit_clicked',
    'on_btnSearch_editreaders_clicked': 'on_btnSearch_reader_edit_clicked',
    'on_lstSearch_editreaders_itemClicked': 'on_lstSearch_reader_edit_itemClicked',
    
    'on_btnRemove_removereaders_clicked': 'on_btnRemove_reader_remove_clicked',
    'on_btnUndoRemoval_removereaders_clicked': 'on_btnUndoRemoval_reader_remove_clicked',
    'on_btnUndoLast_removereaders_clicked': 'on_btnUndoLast_reader_remove_clicked',
    'on_btnSearch_removereaders_clicked': 'on_btnSearch_reader_remove_clicked',
    'on_lstSearch_removereaders_itemClicked': 'on_lstSearch_reader_remove_itemClicked',
    
    # Add/Edit/Remove Category/Location
    'on_btnAddCategory_managecategories_clicked': 'on_btnAdd_category_clicked',
    'on_btnEditCategory_managecategories_clicked': 'on_btnEdit_category_clicked',
    'on_btnRemoveCategory_managecategories_clicked': 'on_btnRemove_category_clicked',
    'on_btnUndoRemove_managecategories_clicked': 'on_btnUndoRemove_category_clicked',
    'on_btnUndoEdit_managecategories_clicked': 'on_btnUndoEdit_category_clicked',
    'on_btnUndoAdd_managecategories_clicked': 'on_btnUndoAdd_category_clicked',
    'on_lstSearch_managecategories_itemClicked': 'on_lstSearch_category_itemClicked',
    
    'on_btnAddLocation_managelocations_clicked': 'on_btnAdd_location_clicked',
    'on_btnEditLocation_managelocations_clicked': 'on_btnEdit_location_clicked',
    'on_btnRemoveLocation_managelocations_clicked': 'on_btnRemove_location_clicked',
    'on_btnUndoRemove_managelocations_clicked': 'on_btnUndoRemove_location_clicked',
    'on_btnUndoEdit_managelocations_clicked': 'on_btnUndoEdit_location_clicked',
    'on_btnUndoAdd_managelocations_clicked': 'on_btnUndoAdd_location_clicked',
    'on_lstSearch_managelocations_itemClicked': 'on_lstSearch_location_itemClicked',
    
    # Add/Edit/Remove Readers
    'on_btnAddBook_addreaders_clicked': 'on_btnAdd_reader_clicked',
    'on_btnEditBook_editreaders_clicked': 'on_btnEdit_reader_edit_clicked',
    'on_btnUndoEdit_editreaders_clicked': 'on_btnUndoEdit_reader_edit_clicked',
    'on_btnSearch_editreaders_clicked': 'on_btnSearch_reader_edit_clicked',
    'on_lstSearch_editreaders_itemClicked': 'on_lstSearch_reader_edit_itemClicked',
    
    'on_btnRemove_removereaders_clicked': 'on_btnRemove_reader_remove_clicked',
    'on_btnUndoRemoval_removereaders_clicked': 'on_btnUndoRemoval_reader_remove_clicked',
    'on_btnUndoLast_removereaders_clicked': 'on_btnUndoLast_reader_remove_clicked',
    'on_btnSearch_removereaders_clicked': 'on_btnSearch_reader_remove_clicked',
    'on_lstSearch_removereaders_itemClicked': 'on_lstSearch_reader_remove_itemClicked',
    
    # Undo Readers
    'on_btnUndoRemoval_removereaders_clicked': 'on_btnUndoRemoval_reader_remove_clicked',
    'on_btnUndoLast_removereaders_clicked': 'on_btnUndoLast_reader_remove_clicked',
    'on_btnSearch_undoremovereaders_clicked': 'on_btnSearch_undoreaders_clicked',
    'on_lstSearch_undoremovereaders_itemClicked': 'on_lstSearch_undoreaders_itemClicked',
    'on_btnUndoAll_undoremovereaders_clicked': 'on_btnUndoAll_undoreaders_clicked',
    'on_btnUndoSelected_undoremovereaders_clicked': 'on_btnUndoSelected_undoreaders_clicked',
    'on_btnRedoRemove_undoremovereaders_clicked': 'on_btnRedoRemove_undoreaders_clicked',
    'on_btnRedoAllSelected_undoremovereaders_clicked': 'on_btnRedoAllSelected_undoreaders_clicked',
    'on_lstSearch_undoremovereaders_itemClicked': 'on_lstSearch_undoreaders_itemClicked',
    
    # Undo Books
    'on_btnUndoAll_undoremovebooks_clicked': 'on_btnUndoAll_undobooks_clicked',
    'on_btnUndoSelected_undoremovebooks_clicked': 'on_btnUndoSelected_undobooks_clicked',
    'on_btnRedoRemove_undoremovebooks_clicked': 'on_btnRedoRemove_undobooks_clicked',
    'on_btnRedoAllSelected_undoremovebooks_clicked': 'on_btnRedoAllSelected_undobooks_clicked',
    'on_lstSearch_undoremovebooks_itemClicked': 'on_lstSearch_undobooks_itemClicked',
    
    # Undo Readers - additional
    'on_btnUndoAll_undoremovereaders_clicked': 'on_btnUndoAll_undoreaders_clicked',
    'on_btnUndoSelected_undoremovereaders_clicked': 'on_btnUndoSelected_undoreaders_clicked',
    'on_btnRedoRemove_undoremovereaders_clicked': 'on_btnRedoRemove_undoreaders_clicked',
    'on_btnRedoAllSelected_undoremovereaders_clicked': 'on_btnRedoAllSelected_undoreaders_clicked',
    'on_lstSearch_undoremovereaders_itemClicked': 'on_lstSearch_undoreaders_itemClicked',
}

for old, new in impl_replacements.items():
    count = content.count(f'void MainWindow::{old}(')
    if count > 0:
        content = content.replace(f'void MainWindow::{old}(', f'void MainWindow::{new}(')
        print(f"Fixed impl {count}x: {old} -> {new}")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")