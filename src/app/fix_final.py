#!/usr/bin/env python3
"""
Fix final double-replacement issues
"""

replacements = {
    # Fix double replacements on reader list widgets
    'lstSearch_reader_loan_add_edit': 'lstSearch_reader_edit',
    'lstSearch_reader_loan_add_remove': 'lstSearch_reader_remove',
    'lstSearch_book_loan_add_edit': 'lstSearch_book_edit',
    'lstSearch_book_loan_add_remove': 'lstSearch_book_remove',
    
    # Fix action handlers
    'txtSearch_book->': 'txtSearch_book_add->',
    'txtSearch_reader->': 'txtSearch_reader_add->',
    'txtSearch_book->clear()': 'txtSearch_book_add->clear()',
    'txtSearch_reader->clear()': 'txtSearch_reader_add->clear()',
    
    # Any remaining bare references
    'lstSearch_editreaders': 'lstSearch_reader_edit',
    'lstSearch_removereaders': 'lstSearch_reader_remove',
    'lstSearch_editbooks': 'lstSearch_book_edit',
    'lstSearch_removebooks': 'lstSearch_book_remove',
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
    
    print("Done!")