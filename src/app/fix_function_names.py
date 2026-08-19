#!/usr/bin/env python3
"""Fix function implementation names to match UI widget names"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

# Map old function names to new function names based on actual UI widget names
impl_replacements = {
    # Undo Books page
    'on_btnSearch_undoremovebooks_clicked': 'on_btnSearch_undobooks_clicked',
    'on_btnSearch_undobooks_clicked': 'on_btnSearch_undobooks_clicked',  # already correct
    
    # Manage Locations
    'on_btnSearch_managelocations_clicked': 'on_btnSearch_location_clicked',
    
    # Remove Books page
    'on_btnSearch_removebooks_clicked': 'on_btnSearch_book_remove_clicked',
    'on_btnRemove_removebooks_clicked': 'on_btnRemove_book_clicked',
    'on_btnUndoRemoval_removebooks_clicked': 'on_btnUndoRemoval_book_clicked',
    'on_btnUndoLast_removebooks_clicked': 'on_btnUndoLast_book_clicked',
    'on_btnUndoAll_undoremovebooks_clicked': 'on_btnUndoAll_undobooks_clicked',
    'on_btnUndoSelected_undoremovebooks_clicked': 'on_btnUndoSelected_undobooks_clicked',
    'on_btnRedoRemove_undoremovebooks_clicked': 'on_btnRedoRemove_undobooks_clicked',
    'on_btnRedoAllSelected_undoremovebooks_clicked': 'on_btnRedoAllSelected_undobooks_clicked',
    'on_lstSearch_undoremovebooks_itemClicked': 'on_lstSearch_undobooks_itemClicked',
    
    # Manage Locations
    'on_btnSearch_managelocations_clicked': 'on_btnSearch_location_clicked',
    'on_lstSearch_managelocations_itemClicked': 'on_lstSearch_location_itemClicked',
    
    # Remove Books page
    'on_btnSearch_removebooks_clicked': 'on_btnSearch_book_remove_clicked',
    'on_lstSearch_removebooks_itemClicked': 'on_lstSearch_book_remove_itemClicked',
    'on_btnRemove_removebooks_clicked': 'on_btnRemove_book_clicked',
    'on_btnUndoRemoval_removebooks_clicked': 'on_btnUndoRemoval_book_clicked',
    'on_btnUndoLast_removebooks_clicked': 'on_btnUndoLast_book_clicked',
    
    # Edit Readers page
    'on_btnSearch_editreaders_clicked': 'on_btnSearch_reader_edit_clicked',
    'on_lstSearch_editreaders_itemClicked': 'on_lstSearch_reader_edit_itemClicked',
    
    # Remove Readers page
    'on_btnSearch_removereaders_clicked': 'on_btnSearch_reader_remove_clicked',
    'on_lstSearch_removereaders_itemClicked': 'on_lstSearch_reader_remove_itemClicked',
    'on_btnRemove_removereaders_clicked': 'on_btnRemove_reader_clicked',
    'on_btnUndoRemoval_removereaders_clicked': 'on_btnUndoRemoval_reader_clicked',
    'on_btnUndoLast_removereaders_clicked': 'on_btnUndoLast_reader_clicked',
    'on_lstSearch_removereaders_itemClicked': 'on_lstSearch_reader_remove_itemClicked',
    
    # Undo Readers page
    'on_btnSearch_undoremovereaders_clicked': 'on_btnSearch_undoreaders_clicked',
    'on_lstSearch_undoremovereaders_itemClicked': 'on_lstSearch_undoreaders_itemClicked',
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