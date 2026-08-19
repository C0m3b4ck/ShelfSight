#!/usr/bin/env python3
"""
Fix remaining issues
"""

replacements = {
    # Loan add page
    'txtSelected_book->': 'txtSelected_book_add->',
    'txtSelected_reader->': 'txtSelected_reader_add->',
    'spnLoanDays_loan->': 'spnLoanDays_loan_add->',
    'spnLoanDays_loan': 'spnLoanDays_loan_add',
    
    # Loan status page
    'txtSearch_loanstatus->': 'txtSearch_loan_status->',
    'cboStatusFilter_loanstatus->': 'cboStatusFilter_loan_status->',
    'lstSearch_loanstatus->': 'lstSearch_loan_status->',
    'txtSearch_loanstatus': 'txtSearch_loan_status',
    'cboStatusFilter_loanstatus': 'cboStatusFilter_loan_status',
    'lstSearch_loanstatus': 'lstSearch_loan_status',
    
    # Fix lstSearch_book_undo_itemClicked declaration
    'on_lstSearch_book_undo_itemClicked': 'on_lstSearch_book_undo_itemClicked',  # keep same
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
    
    print("Done fixing cpp!")
    
    # Also update mainwindow.h to add missing slot
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.h', 'r') as f:
        content = f.read()
    
    # Add missing slot for lstSearch_book_undo_itemClicked
    if 'on_lstSearch_book_undo_itemClicked' not in content:
        # Find a good place to add it (after lstSearch_book_undo)
        if 'on_lstSearch_book_undo' in content:
            # Actually we need to add the slot declaration
            pass
    
    # Add missing slot declarations
    slot_additions = [
        '    void on_lstSearch_book_undo_itemClicked(QListWidgetItem *item);',
        '    void on_lstSearch_reader_undo_itemClicked(QListWidgetItem *item);',
    ]
    
    for slot in slot_additions:
        if slot not in content:
            # Add after lstSearch_book_undo or lstSearch_reader_undo
            target = 'on_lstSearch_book_undo' if 'book' in slot else 'on_lstSearch_reader_undo'
            idx = content.find(target)
            if idx > 0:
                # Find end of line
                end_idx = content.find('\n', idx)
                content = content[:end_idx+1] + slot + '\n' + content[end_idx+1:]
                print(f"Added slot: {slot}")
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.h', 'w') as f:
        f.write(content)
    
    print("Done!")