#!/usr/bin/env python3
"""
Migrate sqlite_dataaccess.cpp from int IDs to string IDs
"""

replacements = {
    # Function signatures
    'getBookById(int id)': 'getBookById(const std::string& id)',
    'removeBook(int id)': 'removeBook(const std::string& id)',
    'restoreBook(int id)': 'restoreBook(const std::string& id)',
    'getReaderById(int id)': 'getReaderById(const std::string& id)',
    'removeReader(int id)': 'removeReader(const std::string& id)',
    'restoreReader(int id)': 'restoreReader(const std::string& id)',
    'removeCategory(int id)': 'removeCategory(const std::string& id)',
    'removeLocation(int id)': 'removeLocation(const std::string& id)',
    'loanBook(int bookId, int readerId, int days)': 'loanBook(const std::string& bookId, const std::string& readerId, int days)',
    'returnBook(int loanId)': 'returnBook(const std::string& loanId)',
    'getLoansForReader(int readerId)': 'getLoansForReader(const std::string& readerId)',
    'getLoansForBook(int bookId)': 'getLoansForBook(const std::string& bookId)',
    'checkIdExists(const std::string& entityType, int id)': 'checkIdExists(const std::string& entityType, const std::string& id)',
    
    # rowTo* functions - change getInt() to getText() for ID columns
    'book.id = stmt.getColumn(0).getInt();': 'book.id = stmt.getColumn(0).getText();',
    'reader.id = stmt.getColumn(0).getInt();': 'reader.id = stmt.getColumn(0).getText();',
    'cat.id = stmt.getColumn(0).getInt();': 'cat.id = stmt.getColumn(0).getText();',
    'loc.id = stmt.getColumn(0).getInt();': 'loc.id = stmt.getColumn(0).getText();',
    'loan.id = stmt.getColumn(0).getInt();': 'loan.id = stmt.getColumn(0).getText();',
    'loan.bookId = stmt.getColumn(1).getInt();': 'loan.bookId = stmt.getColumn(1).getText();',
    'loan.readerId = stmt.getColumn(2).getInt();': 'loan.readerId = stmt.getColumn(2).getText();',
    'user.id = stmt.getColumn(0).getInt();': 'user.id = stmt.getColumn(0).getText();',
    
    # Loan row - bookId and readerId
    # Note: loan bookId is column 1, readerId is column 2
    
    # Schema changes - INTEGER PRIMARY KEY -> TEXT PRIMARY KEY
    'id INTEGER PRIMARY KEY,': 'id TEXT PRIMARY KEY,',
    'id INTEGER PRIMARY KEY AUTOINCREMENT,': 'id TEXT PRIMARY KEY,',
    'bookId INTEGER NOT NULL,': 'bookId TEXT NOT NULL,',
    'readerId INTEGER NOT NULL,': 'readerId TEXT NOT NULL,',
    
    # Bind calls - id parameters
    'query.bind(1, id);': 'query.bind(1, id);',  # already string
    'selectQuery.bind(1, id);': 'selectQuery.bind(1, id);',
    'insertQuery.bind(1, book.id);': 'insertQuery.bind(1, book.id);',
    'updateQuery.bind(1, id);': 'updateQuery.bind(1, id);',
    'deleteQuery.bind(1, id);': 'deleteQuery.bind(1, id);',
    
    # Reader binds
    'selectQuery.bind(1, id);': 'selectQuery.bind(1, id);',
    'insertQuery.bind(1, reader.id);': 'insertQuery.bind(1, reader.id);',
    
    # Category/Location binds
    'query.bind(2, category.id);': 'query.bind(2, category.id);',
    'query.bind(2, location.id);': 'query.bind(2, location.id);',
    
    # Loan binds - bookId, readerId
    'query.bind(1, bookId);': 'query.bind(1, bookId);',
    'query.bind(2, readerId);': 'query.bind(2, readerId);',
    
    # User binds
    'query.bind(5, user.id);': 'query.bind(5, user.id);',
    
    # checkIdExists binds
    'query.bind(1, id);': 'query.bind(1, id);',
}

if __name__ == '__main__':
    with open('/home/sb3x/Code/ShelfSight/src/src/app/sqlite_dataaccess.cpp', 'r') as f:
        content = f.read()
    
    # Apply schema changes first
    content = content.replace('id INTEGER PRIMARY KEY,', 'id TEXT PRIMARY KEY,')
    content = content.replace('id INTEGER PRIMARY KEY AUTOINCREMENT,', 'id TEXT PRIMARY KEY,')
    content = content.replace('bookId INTEGER NOT NULL,', 'bookId TEXT NOT NULL,')
    content = content.replace('readerId INTEGER NOT NULL,', 'readerId TEXT NOT NULL,')
    
    # Fix rowTo* functions
    content = content.replace('book.id = stmt.getColumn(0).getInt();', 'book.id = stmt.getColumn(0).getText();')
    content = content.replace('reader.id = stmt.getColumn(0).getInt();', 'reader.id = stmt.getColumn(0).getText();')
    content = content.replace('cat.id = stmt.getColumn(0).getInt();', 'cat.id = stmt.getColumn(0).getText();')
    content = content.replace('loc.id = stmt.getColumn(0).getInt();', 'loc.id = stmt.getColumn(0).getText();')
    content = content.replace('loan.id = stmt.getColumn(0).getInt();', 'loan.id = stmt.getColumn(0).getText();')
    content = content.replace('loan.bookId = stmt.getColumn(1).getInt();', 'loan.bookId = stmt.getColumn(1).getText();')
    content = content.replace('loan.readerId = stmt.getColumn(2).getInt();', 'loan.readerId = stmt.getColumn(2).getText();')
    content = content.replace('user.id = stmt.getColumn(0).getInt();', 'user.id = stmt.getColumn(0).getText();')
    
    # Update function signatures
    sigs = [
        ('getBookById(int id)', 'getBookById(const std::string& id)'),
        ('removeBook(int id)', 'removeBook(const std::string& id)'),
        ('restoreBook(int id)', 'restoreBook(const std::string& id)'),
        ('getReaderById(int id)', 'getReaderById(const std::string& id)'),
        ('removeReader(int id)', 'removeReader(const std::string& id)'),
        ('restoreReader(int id)', 'restoreReader(const std::string& id)'),
        ('removeCategory(int id)', 'removeCategory(const std::string& id)'),
        ('removeLocation(int id)', 'removeLocation(const std::string& id)'),
        ('loanBook(int bookId, int readerId, int days)', 'loanBook(const std::string& bookId, const std::string& readerId, int days)'),
        ('returnBook(int loanId)', 'returnBook(const std::string& loanId)'),
        ('getLoansForReader(int readerId)', 'getLoansForReader(const std::string& readerId)'),
        ('getLoansForBook(int bookId)', 'getLoansForBook(const std::string& bookId)'),
        ('checkIdExists(const std::string& entityType, int id)', 'checkIdExists(const std::string& entityType, const std::string& id)'),
    ]
    
    for old, new in sigs:
        content = content.replace(old, new)
    
    # Update bind calls in loanBook
    content = content.replace('query.bind(1, bookId);', 'query.bind(1, bookId);')
    content = content.replace('query.bind(2, readerId);', 'query.bind(2, readerId);')
    content = content.replace('bookQuery.bind(1, bookId);', 'bookQuery.bind(1, bookId);')
    content = content.replace('readerQuery.bind(1, readerId);', 'readerQuery.bind(1, readerId);')
    
    # returnBook
    content = content.replace('loanQuery.bind(1, loanId);', 'loanQuery.bind(1, loanId);')
    content = content.replace('updateLoan.bind(2, loanId);', 'updateLoan.bind(2, loanId);')
    
    # getLoansForReader/Book
    content = content.replace('query.bind(1, readerId);', 'query.bind(1, readerId);')
    content = content.replace('query.bind(1, bookId);', 'query.bind(1, bookId);')
    
    # checkIdExists
    content = content.replace('query.bind(1, id);', 'query.bind(1, id);')
    
    # rowToLoan - need to handle bookId and readerId columns
    # loan table: id, bookId, readerId, loanDate, dueDate, returnDate, status
    # columns: 0=id, 1=bookId, 2=readerId, 3=loanDate, 4=dueDate, 5=returnDate, 6=status
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/sqlite_dataaccess.cpp', 'w') as f:
        f.write(content)
    
    print("Done!")