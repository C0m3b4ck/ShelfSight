#!/usr/bin/env python3
"""
Fix remaining issues
"""

replacements = {
    # Fix double replacement
    'spnLoanDays_loan_add_add': 'spnLoanDays_loan_add',
    'spnLoanDays_loan_add_add->': 'spnLoanDays_loan_add->',
    
    # Fix remaining old names
    'txtValue_undobooks': 'txtValue_book_undo',
    'txtValue_undoreaders': 'txtValue_reader_undo',
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
    
    # Update mainwindow.h to add missing slots
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.h', 'r') as f:
        content = f.read()
    
    # Add missing slot declarations
    # Find the right place to add them
    new_slots = [
        '    void on_lstSearch_book_undo_itemClicked(QListWidgetItem *item);',
        '    void on_lstSearch_reader_undo_itemClicked(QListWidgetItem *item);',
        '    void on_btnUndoAll_reader_undo_clicked();',
    ]
    
    for slot in new_slots:
        if slot.strip() not in content:
            # Add after similar slots
            if 'book_undo' in slot:
                target = 'on_lstSearch_book_undo'
            elif 'reader_undo' in slot and 'btnUndoAll' in slot:
                target = 'on_btnUndoAll_book_undo_clicked'
            else:
                target = 'on_lstSearch_reader_undo'
            
            idx = content.find(target)
            if idx > 0:
                end_idx = content.find('\n', idx)
                if end_idx > 0:
                    content = content[:end_idx+1] + slot + '\n' + content[end_idx+1:]
                    print(f"Added slot: {slot.strip()}")
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.h', 'w') as f:
        f.write(content)
    
    print("Done!")