#!/usr/bin/env python3
"""Fix remaining slot implementations and widget references"""

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'r') as f:
    content = f.read()

# Fix function implementation names to match actual UI widget names
impl_replacements = {
    # Undo Books page - the list is lstSearch_undobooks, not lstSearch_book_undo
    'on_lstSearch_book_undo_itemClicked': 'on_lstSearch_undobooks_itemClicked',
    'on_btnUndoAll_book_undo_clicked': 'on_btnUndoAll_undobooks_clicked',
    'on_btnUndoSelected_book_undo_clicked': 'on_btnUndoSelected_undobooks_clicked',
    'on_btnRedoRemove_book_undo_clicked': 'on_btnRedoRemove_undobooks_clicked',
    'on_btnRedoAllSelected_book_undo_clicked': 'on_btnRedoAllSelected_undobooks_clicked',
    
    # Undo Readers page
    'on_btnSearch_reader_undo_clicked': 'on_btnSearch_undoreaders_clicked',
    'on_lstSearch_reader_undo_itemClicked': 'on_lstSearch_undoreaders_itemClicked',
    'on_btnUndoAll_reader_undo_clicked': 'on_btnUndoAll_undoreaders_clicked',
    'on_btnUndoSelected_reader_undo_clicked': 'on_btnUndoSelected_undoreaders_clicked',
    'on_btnRedoRemove_reader_undo_clicked': 'on_btnRedoRemove_undoreaders_clicked',
    'on_btnRedoAllSelected_reader_undo_clicked': 'on_btnRedoAllSelected_undoreaders_clicked',
    'on_lstSearch_reader_undo_itemClicked': 'on_lstSearch_undoreaders_itemClicked',
    
    # Edit Readers page - fix widget names (txtName_addreaders_edit -> txtName_reader_edit)
    'ui->txtName_addreaders_edit': 'ui->txtName_reader_edit',
    'ui->txtSurname_addreaders_edit': 'ui->txtSurname_reader_edit',
    'ui->txtGrade_addreaders_edit': 'ui->txtGrade_reader_edit',
    'ui->txtClass_addreaders_edit': 'ui->txtClass_reader_edit',
    'ui->txtID_addreaders_edit': 'ui->txtId_reader_edit',
    
    # Action handler for undo removed readers
    'on_actionUndo_Removed_2_triggered': 'on_actionUndo_Removed_2_triggered',
}

for old, new in replacements.items():
    if old.startswith('on_'):
        count = content.count(f'void MainWindow::{old}(')
        if count > 0:
            content = content.replace(f'void MainWindow::{old}(', f'void MainWindow::{new}(')
            print(f"Fixed impl {count}x: {old} -> {new}")
    else:
        count = content.count(old)
        if count > 0:
            content = content.replace(old, new)
            print(f"Fixed {count}x: {old} -> {new}")

with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.cpp', 'w') as f:
    f.write(content)

print("Done!")