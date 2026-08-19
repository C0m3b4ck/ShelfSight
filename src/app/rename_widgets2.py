#!/usr/bin/env python3
"""
Second pass: Fix remaining inconsistent widget names
"""

manual_map = {
    # Book Add page - missing _add suffix
    'btnAdd_book': 'btnAdd_book_add',
    'btnSearch_book': 'btnSearch_book_add',
    'cboSearchField_book': 'cboSearchField_book_add',  # actually on loan add page
    'cboSearchField_reader': 'cboSearchField_reader_add',  # actually on loan add page
    'lstSearch_book': 'lstSearch_book_add',  # actually on loan add page
    'lstSearch_reader': 'lstSearch_reader_add',  # actually on loan add page
    'spnLoanDays_loan': 'spnLoanDays_loan_add',
    'chkCheckUnreturned_loan': 'chkCheckUnreturned_loan_add',
    
    # Book Edit page - missing _edit suffix
    'btnEdit_book': 'btnEdit_book_edit',
    'btnUndoAdd_book': 'btnUndoAdd_book_edit',
    'btnUndoEdit_book': 'btnUndoEdit_book_edit',
    
    # Book Remove page - missing _remove suffix
    'btnRemove_book': 'btnRemove_book_remove',
    'btnUndoRemoval_book': 'btnUndoRemoval_book_remove',
    'btnUndoLast_book': 'btnUndoLast_book_remove',
    
    # Book Undo page
    'btnSearch_undobooks': 'btnSearch_book_undo',
    'btnUndoAll_undobooks': 'btnUndoAll_book_undo',
    'btnUndoSelected_undobooks': 'btnUndoSelected_book_undo',
    'btnRedoRemove_undobooks': 'btnRedoRemove_book_undo',
    'btnRedoAllSelected_undobooks': 'btnRedoAllSelected_book_undo',
    'lstSearch_undobooks': 'lstSearch_book_undo',
    'txtValue_undobooks': 'txtValue_book_undo',
    'txtSearch_undobooks': 'txtSearch_book_undo',
    'cboValue_undobooks': 'cboValue_book_undo',
    
    # Reader Add page - missing _add suffix
    'btnAdd_reader': 'btnAdd_reader_add',
    'btnSearch_reader': 'btnSearch_reader_add',
    'btnUndoAdd_reader': 'btnUndoAdd_reader_add',
    
    # Reader Edit page - missing _edit suffix
    'btnEdit_reader': 'btnEdit_reader_edit',
    'btnUndoEdit_reader': 'btnUndoEdit_reader_edit',
    
    # Reader Remove page - missing _remove suffix
    'btnRemove_reader': 'btnRemove_reader_remove',
    'btnUndoRemoval_reader': 'btnUndoRemoval_reader_remove',
    'btnUndoLast_reader': 'btnUndoLast_reader_remove',
    
    # Reader Undo page
    'btnSearch_undoreaders': 'btnSearch_reader_undo',
    'btnUndoAll_undoreaders': 'btnUndoAll_reader_undo',
    'btnUndoSelected_undoreaders': 'btnUndoSelected_reader_undo',
    'btnRedoRemove_undoreaders': 'btnRedoRemove_reader_undo',
    'btnRedoAllSelected_undoreaders': 'btnRedoAllSelected_reader_undo',
    'lstSearch_undoreaders': 'lstSearch_reader_undo',
    'txtValue_undoreaders': 'txtValue_reader_undo',
    'txtSearch_undoreaders': 'txtSearch_reader_undo',
    'cboValue_undoreaders': 'cboValue_reader_undo',
    
    # Loan Edit page - check suffix
    'btnReturn_loan_edit': 'btnReturn_loan_edit',  # good
    'btnUpdate_loan_edit': 'btnUpdate_loan_edit',  # good
    'btnClear_loan_edit': 'btnClear_loan_edit',  # good
    
    # Loan Status page - fix _loanstatus -> _loan_status
    'cboStatusFilter_loanstatus': 'cboStatusFilter_loan_status',
    'lstSearch_loanstatus': 'lstSearch_loan_status',
    'txtSearch_loanstatus': 'txtSearch_loan_status',
    
    # Reader ID fields - fix ID -> Id
    'cboIDtypes_reader': 'cboIdType_reader_add',
    'txtIDlength_reader': 'txtIdLength_reader_add',
    'chkAutogenerateID_reader': 'chkAutogenerateId_reader_add',
    'chkUniqueID_reader': 'chkUniqueId_reader_add',
    'txtID_reader': 'txtId_reader_add',
    'txtId_reader_edit': 'txtId_reader_edit',
    'txtId_reader_remove': 'txtId_reader_remove',
    
    # Category page - already good (single page)
    # Location page - already good (single page)
}

if __name__ == '__main__':
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'r') as f:
        content = f.read()
    
    for old, new in manual_map.items():
        if f'name="{old}"' in content:
            content = content.replace(f'name="{old}"', f'name="{new}"')
            print(f"Renamed: {old} -> {new}")
        else:
            print(f"NOT FOUND: {old}")
    
    # Fix zorder
    for old, new in manual_map.items():
        if f'<zorder>{old}</zorder>' in content:
            content = content.replace(f'<zorder>{old}</zorder>', f'<zorder>{new}</zorder>')
            print(f"Fixed zorder: {old} -> {new}")
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'w') as f:
        f.write(content)
    
    print("Done!")