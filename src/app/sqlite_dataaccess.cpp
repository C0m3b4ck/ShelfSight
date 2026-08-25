#include "sqlite_dataaccess.h"
#include "domain.h"
#include <SQLiteCpp/Database.h>
#include <SQLiteCpp/Statement.h>
#include <SQLiteCpp/Transaction.h>
#include <memory>
#include <mutex>
#include <stdexcept>
#include <algorithm>
#include <QDebug>

namespace DataAccess {

SQLiteDataAccess::SQLiteDataAccess()
    : m_connected(false)
{
}

SQLiteDataAccess::~SQLiteDataAccess()
{
    shutdown();
}

void SQLiteDataAccess::initialize(const std::string& booksDb, const std::string& readersDb, const std::string& loansDb, const std::string& usersDb)
{
    std::lock_guard<std::mutex> lock(m_mutex);

    try {
        if (!booksDb.empty()) {
            m_booksDb = std::make_unique<SQLite::Database>(booksDb, SQLite::OPEN_READWRITE | SQLite::OPEN_CREATE);
        }
        if (!readersDb.empty()) {
            m_readersDb = std::make_unique<SQLite::Database>(readersDb, SQLite::OPEN_READWRITE | SQLite::OPEN_CREATE);
        }
        if (!loansDb.empty()) {
            m_loansDb = std::make_unique<SQLite::Database>(loansDb, SQLite::OPEN_READWRITE | SQLite::OPEN_CREATE);
        }
        if (!usersDb.empty()) {
            m_usersDb = std::make_unique<SQLite::Database>(usersDb, SQLite::OPEN_READWRITE | SQLite::OPEN_CREATE);
        }

        if (m_booksDb || m_readersDb || m_loansDb || m_usersDb) createTables();
        if (m_booksDb || m_readersDb || m_loansDb || m_usersDb) createIndexes();

        m_connected = m_readersDb != nullptr;
    }
    catch (const std::exception& e) {
        shutdown();
        throw DataAccessException(std::string("Failed to initialize databases: ") + e.what());
    }
}

void SQLiteDataAccess::shutdown()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    m_booksDb.reset();
    m_readersDb.reset();
    m_loansDb.reset();
    m_usersDb.reset();
    m_connected = false;
}

bool SQLiteDataAccess::isConnected() const
{
    std::lock_guard<std::mutex> lock(m_mutex);
    return m_connected && m_readersDb;
}

void SQLiteDataAccess::createTables()
{
    // Books table
    if (m_booksDb) {
        m_booksDb->exec(
            "CREATE TABLE IF NOT EXISTS books ("
            "id TEXT PRIMARY KEY,"
            "title TEXT NOT NULL,"
            "author TEXT NOT NULL,"
            "location TEXT NOT NULL,"
            "category TEXT NOT NULL,"
            "status TEXT NOT NULL DEFAULT 'Available',"
            "createdAt TEXT NOT NULL,"
            "updatedAt TEXT NOT NULL,"
            "deleted INTEGER NOT NULL DEFAULT 0"
            ");"
        );

        // Removed books table (for undo functionality)
        m_booksDb->exec(
            "CREATE TABLE IF NOT EXISTS removed_books ("
            "id TEXT PRIMARY KEY,"
            "title TEXT NOT NULL,"
            "author TEXT NOT NULL,"
            "location TEXT NOT NULL,"
            "category TEXT NOT NULL,"
            "status TEXT NOT NULL,"
            "createdAt TEXT NOT NULL,"
            "updatedAt TEXT NOT NULL,"
            "deletedAt TEXT NOT NULL"
            ");"
        );
    }

    // Readers table
    if (m_readersDb) {
        m_readersDb->exec(
            "CREATE TABLE IF NOT EXISTS readers ("
            "id TEXT PRIMARY KEY,"
            "name TEXT NOT NULL,"
            "surname TEXT NOT NULL,"
            "grade INTEGER NOT NULL DEFAULT 0,"
            "classGroup TEXT NOT NULL DEFAULT 'A',"
            "studentId TEXT NOT NULL,"
            "createdAt TEXT NOT NULL,"
            "updatedAt TEXT NOT NULL,"
            "deleted INTEGER NOT NULL DEFAULT 0"
            ");"
        );

        // Removed readers table
        m_readersDb->exec(
            "CREATE TABLE IF NOT EXISTS removed_readers ("
            "id TEXT PRIMARY KEY,"
            "name TEXT NOT NULL,"
            "surname TEXT NOT NULL,"
            "grade INTEGER NOT NULL,"
            "classGroup TEXT NOT NULL,"
            "studentId TEXT NOT NULL,"
            "createdAt TEXT NOT NULL,"
            "updatedAt TEXT NOT NULL,"
            "deletedAt TEXT NOT NULL"
            ");"
        );
    }

    // Categories table
    if (m_booksDb) {
        m_booksDb->exec(
            "CREATE TABLE IF NOT EXISTS categories ("
            "id TEXT PRIMARY KEY,"
            "name TEXT NOT NULL UNIQUE"
            ");"
        );

        // Locations table
        m_booksDb->exec(
            "CREATE TABLE IF NOT EXISTS locations ("
            "id TEXT PRIMARY KEY,"
            "name TEXT NOT NULL UNIQUE"
            ");"
        );
    }

    // Loans table
    if (m_loansDb) {
        m_loansDb->exec(
            "CREATE TABLE IF NOT EXISTS loans ("
            "id TEXT PRIMARY KEY,"
            "bookId TEXT NOT NULL,"
            "readerId TEXT NOT NULL,"
            "loanDate TEXT NOT NULL,"
            "dueDate TEXT NOT NULL,"
            "returnDate TEXT,"
            "status TEXT NOT NULL DEFAULT 'active',"
            "FOREIGN KEY (bookId) REFERENCES books(id),"
            "FOREIGN KEY (readerId) REFERENCES readers(id)"
            ");"
        );
    }

    // Users table (in separate users DB)
    if (m_usersDb) {
        m_usersDb->exec(
            "CREATE TABLE IF NOT EXISTS users ("
            "id TEXT PRIMARY KEY,"
            "username TEXT NOT NULL UNIQUE,"
            "passwordHash TEXT NOT NULL,"
            "salt TEXT NOT NULL,"
            "role INTEGER NOT NULL DEFAULT 1,"
            "createdAt TEXT NOT NULL,"
            "lastLogin TEXT"
            ");"
        );
    }
}

void SQLiteDataAccess::createIndexes()
{
    if (m_booksDb) {
        m_booksDb->exec("CREATE INDEX IF NOT EXISTS idx_books_title ON books(title);");
        m_booksDb->exec("CREATE INDEX IF NOT EXISTS idx_books_author ON books(author);");
        m_booksDb->exec("CREATE INDEX IF NOT EXISTS idx_books_category ON books(category);");
        m_booksDb->exec("CREATE INDEX IF NOT EXISTS idx_books_location ON books(location);");
        m_booksDb->exec("CREATE INDEX IF NOT EXISTS idx_books_status ON books(status);");
        m_booksDb->exec("CREATE INDEX IF NOT EXISTS idx_books_deleted ON books(deleted);");
    }

    if (m_readersDb) {
        m_readersDb->exec("CREATE INDEX IF NOT EXISTS idx_readers_name ON readers(name);");
        m_readersDb->exec("CREATE INDEX IF NOT EXISTS idx_readers_surname ON readers(surname);");
        m_readersDb->exec("CREATE INDEX IF NOT EXISTS idx_readers_studentId ON readers(studentId);");
        m_readersDb->exec("CREATE INDEX IF NOT EXISTS idx_readers_deleted ON readers(deleted);");
    }

    if (m_loansDb) {
        m_loansDb->exec("CREATE INDEX IF NOT EXISTS idx_loans_bookId ON loans(bookId);");
        m_loansDb->exec("CREATE INDEX IF NOT EXISTS idx_loans_readerId ON loans(readerId);");
        m_loansDb->exec("CREATE INDEX IF NOT EXISTS idx_loans_status ON loans(status);");
        m_loansDb->exec("CREATE INDEX IF NOT EXISTS idx_loans_dueDate ON loans(dueDate);");
    }
}

Domain::Book SQLiteDataAccess::rowToBook(const SQLite::Statement& stmt)
{
    Domain::Book book;
    book.id = stmt.getColumn(0).getText();
    book.title = stmt.getColumn(1).getText();
    book.author = stmt.getColumn(2).getText();
    book.location = stmt.getColumn(3).getText();
    book.category = stmt.getColumn(4).getText();
    book.status = stmt.getColumn(5).getText();
    book.createdAt = stringToDateTime(stmt.getColumn(6).getText());
    book.updatedAt = stringToDateTime(stmt.getColumn(7).getText());
    return book;
}

Domain::Reader SQLiteDataAccess::rowToReader(const SQLite::Statement& stmt)
{
    Domain::Reader reader;
    reader.id = stmt.getColumn(0).getText();
    reader.name = stmt.getColumn(1).getText();
    reader.surname = stmt.getColumn(2).getText();
    reader.grade = static_cast<short>(stmt.getColumn(3).getInt());
    reader.classGroup = stmt.getColumn(4).getText()[0];
    reader.studentId = stmt.getColumn(5).getText();
    reader.createdAt = stringToDateTime(stmt.getColumn(6).getText());
    reader.updatedAt = stringToDateTime(stmt.getColumn(7).getText());
    return reader;
}

Domain::Category SQLiteDataAccess::rowToCategory(const SQLite::Statement& stmt)
{
    Domain::Category cat;
    cat.id = stmt.getColumn(0).getText();
    cat.name = stmt.getColumn(1).getText();
    return cat;
}

Domain::Location SQLiteDataAccess::rowToLocation(const SQLite::Statement& stmt)
{
    Domain::Location loc;
    loc.id = stmt.getColumn(0).getText();
    loc.name = stmt.getColumn(1).getText();
    return loc;
}

Domain::Loan SQLiteDataAccess::rowToLoan(const SQLite::Statement& stmt)
{
    Domain::Loan loan;
    loan.id = stmt.getColumn(0).getText();
    loan.bookId = stmt.getColumn(1).getText();
    loan.readerId = stmt.getColumn(2).getText();
    loan.loanDate = stringToDateTime(stmt.getColumn(3).getText());
    loan.dueDate = stringToDateTime(stmt.getColumn(4).getText());
    loan.returnDate = stmt.getColumn(5).isNull() ? Domain::DateTime{} : stringToDateTime(stmt.getColumn(5).getText());
    loan.status = stmt.getColumn(6).getText();
    return loan;
}

Domain::User SQLiteDataAccess::rowToUser(const SQLite::Statement& stmt)
{
    Domain::User user;
    user.id = stmt.getColumn(0).getText();
    user.username = stmt.getColumn(1).getText();
    user.passwordHash = stmt.getColumn(2).getText();
    user.salt = stmt.getColumn(3).getText();
    user.role = static_cast<Domain::User::Role>(stmt.getColumn(4).getInt());
    user.createdAt = stringToDateTime(stmt.getColumn(5).getText());
    user.lastLogin = stmt.getColumn(6).isNull() ? Domain::DateTime{} : stringToDateTime(stmt.getColumn(6).getText());
    return user;
}

std::string SQLiteDataAccess::dateTimeToString(const Domain::DateTime& dt)
{
    return Domain::toISOString(dt);
}

Domain::DateTime SQLiteDataAccess::stringToDateTime(const std::string& str)
{
    return Domain::fromISOString(str);
}

// Book operations
std::vector<Domain::Book> SQLiteDataAccess::getAllBooks()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Book> books;
    if (!m_booksDb) return books;

    SQLite::Statement query(*m_booksDb, "SELECT id, title, author, location, category, status, createdAt, updatedAt FROM books WHERE deleted = 0 ORDER BY title");
    while (query.executeStep()) {
        books.push_back(rowToBook(query));
    }
    return books;
}

std::optional<Domain::Book> SQLiteDataAccess::getBookById(const std::string& id)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return std::nullopt;
    SQLite::Statement query(*m_booksDb, "SELECT id, title, author, location, category, status, createdAt, updatedAt FROM books WHERE id = ? AND deleted = 0");
    query.bind(1, id);
    if (query.executeStep()) {
        return rowToBook(query);
    }
    return std::nullopt;
}

std::vector<Domain::Book> SQLiteDataAccess::searchBooks(const std::string& term, const std::string& field)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Book> books;
    if (!m_booksDb) return books;

    std::string sql = "SELECT id, title, author, location, category, status, createdAt, updatedAt FROM books WHERE deleted = 0";
    if (field == "title") {
        sql += " AND title LIKE ?";
    } else if (field == "author") {
        sql += " AND author LIKE ?";
    } else if (field == "id") {
        sql += " AND CAST(id AS TEXT) LIKE ?";
    } else if (field == "location") {
        sql += " AND location LIKE ?";
    } else if (field == "category") {
        sql += " AND category LIKE ?";
    } else if (field == "status") {
        sql += " AND status LIKE ?";
    } else {
        sql += " AND (title LIKE ? OR author LIKE ? OR location LIKE ? OR category LIKE ? OR status LIKE ? OR CAST(id AS TEXT) LIKE ?)";
    }
    sql += " ORDER BY title";

    SQLite::Statement query(*m_booksDb, sql);
    std::string pattern = "%" + term + "%";

    if (field == "title" || field == "author" || field == "id" || field == "location" || field == "category" || field == "status") {
        query.bind(1, pattern);
    } else {
        for (int i = 1; i <= 6; ++i) {
            query.bind(i, pattern);
        }
    }

    while (query.executeStep()) {
        books.push_back(rowToBook(query));
    }
    return books;
}

bool SQLiteDataAccess::addBook(const Domain::Book& book)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return false;
    try {
        SQLite::Transaction transaction(*m_booksDb);
        SQLite::Statement query(*m_booksDb,
            "INSERT INTO books (id, title, author, location, category, status, createdAt, updatedAt, deleted) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)");
        query.bind(1, book.id);
        query.bind(2, book.title);
        query.bind(3, book.author);
        query.bind(4, book.location);
        query.bind(5, book.category);
        query.bind(6, book.status);
        query.bind(7, dateTimeToString(book.createdAt));
        query.bind(8, dateTimeToString(book.updatedAt));
        query.exec();
        transaction.commit();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}

bool SQLiteDataAccess::updateBook(const Domain::Book& book)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return false;
    try {
        SQLite::Transaction transaction(*m_booksDb);
        SQLite::Statement query(*m_booksDb,
            "UPDATE books SET title = ?, author = ?, location = ?, category = ?, status = ?, updatedAt = ? WHERE id = ? AND deleted = 0");
        query.bind(1, book.title);
        query.bind(2, book.author);
        query.bind(3, book.location);
        query.bind(4, book.category);
        query.bind(5, book.status);
        query.bind(6, dateTimeToString(book.updatedAt));
        query.bind(7, book.id);
        int rows = query.exec();
        transaction.commit();
        return rows > 0;
    }
    catch (const std::exception&) {
        return false;
    }
}

bool SQLiteDataAccess::removeBook(const std::string& id)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return false;
    try {
        SQLite::Transaction transaction(*m_booksDb);

        // First, get the book data for undo
        SQLite::Statement selectQuery(*m_booksDb,
            "SELECT id, title, author, location, category, status, createdAt, updatedAt FROM books WHERE id = ? AND deleted = 0");
        selectQuery.bind(1, id);
        Domain::Book book;
        bool found = false;
        if (selectQuery.executeStep()) {
            book = rowToBook(selectQuery);
            found = true;
        }

        if (!found) return false;

        // Move to removed_books table
        SQLite::Statement insertQuery(*m_booksDb,
            "INSERT INTO removed_books (id, title, author, location, category, status, createdAt, updatedAt, deletedAt) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        insertQuery.bind(1, book.id);
        insertQuery.bind(2, book.title);
        insertQuery.bind(3, book.author);
        insertQuery.bind(4, book.location);
        insertQuery.bind(5, book.category);
        insertQuery.bind(6, book.status);
        insertQuery.bind(7, dateTimeToString(book.createdAt));
        insertQuery.bind(8, dateTimeToString(book.updatedAt));
        insertQuery.bind(9, dateTimeToString(Domain::now()));
        insertQuery.exec();

        // Mark as deleted in books table
        SQLite::Statement updateQuery(*m_booksDb, "UPDATE books SET deleted = 1 WHERE id = ?");
        updateQuery.bind(1, id);
        updateQuery.exec();

        transaction.commit();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}

std::vector<Domain::Book> SQLiteDataAccess::getRemovedBooks()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Book> books;
    if (!m_booksDb) return books;

    SQLite::Statement query(*m_booksDb, "SELECT id, title, author, location, category, status, createdAt, updatedAt FROM removed_books ORDER BY deletedAt DESC");
    while (query.executeStep()) {
        books.push_back(rowToBook(query));
    }
    return books;
}

bool SQLiteDataAccess::restoreBook(const std::string& id)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return false;
    try {
        SQLite::Transaction transaction(*m_booksDb);

        SQLite::Statement selectQuery(*m_booksDb,
            "SELECT id, title, author, location, category, status, createdAt, updatedAt FROM removed_books WHERE id = ?");
        selectQuery.bind(1, id);
        Domain::Book book;
        bool found = false;
        if (selectQuery.executeStep()) {
            book = rowToBook(selectQuery);
            found = true;
        }

        if (!found) return false;

        // Insert back into books table
        SQLite::Statement insertQuery(*m_booksDb,
            "INSERT OR REPLACE INTO books (id, title, author, location, category, status, createdAt, updatedAt, deleted) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)");
        insertQuery.bind(1, book.id);
        insertQuery.bind(2, book.title);
        insertQuery.bind(3, book.author);
        insertQuery.bind(4, book.location);
        insertQuery.bind(5, book.category);
        insertQuery.bind(6, book.status);
        insertQuery.bind(7, dateTimeToString(book.createdAt));
        insertQuery.bind(8, dateTimeToString(Domain::now()));
        insertQuery.exec();

        // Remove from removed_books
        SQLite::Statement deleteQuery(*m_booksDb, "DELETE FROM removed_books WHERE id = ?");
        deleteQuery.bind(1, id);
        deleteQuery.exec();

        transaction.commit();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}

// Reader operations
std::vector<Domain::Reader> SQLiteDataAccess::getAllReaders()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Reader> readers;
    if (!m_readersDb) return readers;

    SQLite::Statement query(*m_readersDb, "SELECT id, name, surname, grade, classGroup, studentId, createdAt, updatedAt FROM readers WHERE deleted = 0 ORDER BY surname, name");
    while (query.executeStep()) {
        readers.push_back(rowToReader(query));
    }
    return readers;
}

std::optional<Domain::Reader> SQLiteDataAccess::getReaderById(const std::string& id)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_readersDb) return std::nullopt;
    SQLite::Statement query(*m_readersDb, "SELECT id, name, surname, grade, classGroup, studentId, createdAt, updatedAt FROM readers WHERE id = ? AND deleted = 0");
    query.bind(1, id);
    if (query.executeStep()) {
        return rowToReader(query);
    }
    return std::nullopt;
}

std::vector<Domain::Reader> SQLiteDataAccess::searchReaders(const std::string& term, const std::string& field)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Reader> readers;
    if (!m_readersDb) return readers;

    std::string sql = "SELECT id, name, surname, grade, classGroup, studentId, createdAt, updatedAt FROM readers WHERE deleted = 0";
    if (field == "name") {
        sql += " AND name LIKE ?";
    } else if (field == "surname") {
        sql += " AND surname LIKE ?";
    } else if (field == "id") {
        sql += " AND CAST(id AS TEXT) LIKE ?";
    } else if (field == "grade") {
        sql += " AND CAST(grade AS TEXT) LIKE ?";
    } else if (field == "class") {
        sql += " AND classGroup LIKE ?";
    } else {
        sql += " AND (name LIKE ? OR surname LIKE ? OR CAST(id AS TEXT) LIKE ? OR CAST(grade AS TEXT) LIKE ? OR classGroup LIKE ? OR studentId LIKE ?)";
    }
    sql += " ORDER BY surname, name";

    SQLite::Statement query(*m_readersDb, sql);
    std::string pattern = "%" + term + "%";

    if (field == "name" || field == "surname" || field == "id" || field == "grade" || field == "class") {
        query.bind(1, pattern);
    } else {
        for (int i = 1; i <= 6; ++i) {
            query.bind(i, pattern);
        }
    }

    while (query.executeStep()) {
        readers.push_back(rowToReader(query));
    }
    return readers;
}

bool SQLiteDataAccess::addReader(const Domain::Reader& reader)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_readersDb) return false;
    try {
        SQLite::Transaction transaction(*m_readersDb);
        SQLite::Statement query(*m_readersDb,
            "INSERT INTO readers (id, name, surname, grade, classGroup, studentId, createdAt, updatedAt, deleted) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)");
        query.bind(1, reader.id);
        query.bind(2, reader.name);
        query.bind(3, reader.surname);
        query.bind(4, reader.grade);
        query.bind(5, std::string(1, reader.classGroup));
        query.bind(6, reader.studentId);
        query.bind(7, dateTimeToString(reader.createdAt));
        query.bind(8, dateTimeToString(reader.updatedAt));
        query.exec();
        transaction.commit();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}

bool SQLiteDataAccess::updateReader(const Domain::Reader& reader)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_readersDb) return false;
    try {
        SQLite::Transaction transaction(*m_readersDb);
        SQLite::Statement query(*m_readersDb,
            "UPDATE readers SET name = ?, surname = ?, grade = ?, classGroup = ?, studentId = ?, updatedAt = ? WHERE id = ? AND deleted = 0");
        query.bind(1, reader.name);
        query.bind(2, reader.surname);
        query.bind(3, reader.grade);
        query.bind(4, std::string(1, reader.classGroup));
        query.bind(5, reader.studentId);
        query.bind(6, dateTimeToString(reader.updatedAt));
        query.bind(7, reader.id);
        int rows = query.exec();
        transaction.commit();
        return rows > 0;
    }
    catch (const std::exception&) {
        return false;
    }
}

bool SQLiteDataAccess::removeReader(const std::string& id)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_readersDb) return false;
    try {
        SQLite::Transaction transaction(*m_readersDb);

        SQLite::Statement selectQuery(*m_readersDb,
            "SELECT id, name, surname, grade, classGroup, studentId, createdAt, updatedAt FROM readers WHERE id = ? AND deleted = 0");
        selectQuery.bind(1, id);
        Domain::Reader reader;
        bool found = false;
        if (selectQuery.executeStep()) {
            reader = rowToReader(selectQuery);
            found = true;
        }

        if (!found) return false;

        SQLite::Statement insertQuery(*m_readersDb,
            "INSERT INTO removed_readers (id, name, surname, grade, classGroup, studentId, createdAt, updatedAt, deletedAt) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)");
        insertQuery.bind(1, reader.id);
        insertQuery.bind(2, reader.name);
        insertQuery.bind(3, reader.surname);
        insertQuery.bind(4, reader.grade);
        insertQuery.bind(5, std::string(1, reader.classGroup));
        insertQuery.bind(6, reader.studentId);
        insertQuery.bind(7, dateTimeToString(reader.createdAt));
        insertQuery.bind(8, dateTimeToString(reader.updatedAt));
        insertQuery.bind(9, dateTimeToString(Domain::now()));
        insertQuery.exec();

        SQLite::Statement updateQuery(*m_readersDb, "UPDATE readers SET deleted = 1 WHERE id = ?");
        updateQuery.bind(1, id);
        updateQuery.exec();

        transaction.commit();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}

std::vector<Domain::Reader> SQLiteDataAccess::getRemovedReaders()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Reader> readers;
    if (!m_readersDb) return readers;

    SQLite::Statement query(*m_readersDb, "SELECT id, name, surname, grade, classGroup, studentId, createdAt, updatedAt FROM removed_readers ORDER BY deletedAt DESC");
    while (query.executeStep()) {
        readers.push_back(rowToReader(query));
    }
    return readers;
}

bool SQLiteDataAccess::restoreReader(const std::string& id)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_readersDb) return false;
    try {
        SQLite::Transaction transaction(*m_readersDb);

        SQLite::Statement selectQuery(*m_readersDb,
            "SELECT id, name, surname, grade, classGroup, studentId, createdAt, updatedAt FROM removed_readers WHERE id = ?");
        selectQuery.bind(1, id);
        Domain::Reader reader;
        bool found = false;
        if (selectQuery.executeStep()) {
            reader = rowToReader(selectQuery);
            found = true;
        }

        if (!found) return false;

        SQLite::Statement insertQuery(*m_readersDb,
            "INSERT OR REPLACE INTO readers (id, name, surname, grade, classGroup, studentId, createdAt, updatedAt, deleted) "
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)");
        insertQuery.bind(1, reader.id);
        insertQuery.bind(2, reader.name);
        insertQuery.bind(3, reader.surname);
        insertQuery.bind(4, reader.grade);
        insertQuery.bind(5, std::string(1, reader.classGroup));
        insertQuery.bind(6, reader.studentId);
        insertQuery.bind(7, dateTimeToString(reader.createdAt));
        insertQuery.bind(8, dateTimeToString(Domain::now()));
        insertQuery.exec();

        SQLite::Statement deleteQuery(*m_readersDb, "DELETE FROM removed_readers WHERE id = ?");
        deleteQuery.bind(1, id);
        deleteQuery.exec();

        transaction.commit();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}

// Category operations
std::vector<Domain::Category> SQLiteDataAccess::getAllCategories()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Category> categories;
    if (!m_booksDb) return categories;

    SQLite::Statement query(*m_booksDb, "SELECT id, name FROM categories ORDER BY name");
    while (query.executeStep()) {
        categories.push_back(rowToCategory(query));
    }
    return categories;
}

bool SQLiteDataAccess::addCategory(const Domain::Category& category)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return false;
    try {
        std::string catId = category.id.empty()
            ? std::to_string(std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()).count())
            : category.id;
        SQLite::Statement query(*m_booksDb, "INSERT INTO categories (id, name) VALUES (?, ?)");
        query.bind(1, catId);
        query.bind(2, category.name);
        query.exec();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}

bool SQLiteDataAccess::updateCategory(const Domain::Category& category)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return false;
    try {
        SQLite::Statement query(*m_booksDb, "UPDATE categories SET name = ? WHERE id = ?");
        query.bind(1, category.name);
        query.bind(2, category.id);
        int rows = query.exec();
        return rows > 0;
    }
    catch (const std::exception&) {
        return false;
    }
}

bool SQLiteDataAccess::removeCategory(const std::string& id)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return false;
    try {
        SQLite::Statement query(*m_booksDb, "DELETE FROM categories WHERE id = ?");
        query.bind(1, id);
        int rows = query.exec();
        return rows > 0;
    }
    catch (const std::exception&) {
        return false;
    }
}

// Location operations
std::vector<Domain::Location> SQLiteDataAccess::getAllLocations()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Location> locations;
    if (!m_booksDb) return locations;

    SQLite::Statement query(*m_booksDb, "SELECT id, name FROM locations ORDER BY name");
    while (query.executeStep()) {
        locations.push_back(rowToLocation(query));
    }
    return locations;
}

bool SQLiteDataAccess::addLocation(const Domain::Location& location)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return false;
    try {
        std::string locId = location.id.empty()
            ? std::to_string(std::chrono::duration_cast<std::chrono::milliseconds>(
                std::chrono::system_clock::now().time_since_epoch()).count())
            : location.id;
        SQLite::Statement query(*m_booksDb, "INSERT INTO locations (id, name) VALUES (?, ?)");
        query.bind(1, locId);
        query.bind(2, location.name);
        query.exec();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}

bool SQLiteDataAccess::updateLocation(const Domain::Location& location)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return false;
    try {
        SQLite::Statement query(*m_booksDb, "UPDATE locations SET name = ? WHERE id = ?");
        query.bind(1, location.name);
        query.bind(2, location.id);
        int rows = query.exec();
        return rows > 0;
    }
    catch (const std::exception&) {
        return false;
    }
}

bool SQLiteDataAccess::removeLocation(const std::string& id)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb) return false;
    try {
        SQLite::Statement query(*m_booksDb, "DELETE FROM locations WHERE id = ?");
        query.bind(1, id);
        int rows = query.exec();
        return rows > 0;
    }
    catch (const std::exception&) {
        return false;
    }
}

// Loan operations
bool SQLiteDataAccess::loanBook(const std::string& bookId, const std::string& readerId, int days)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb || !m_readersDb || !m_loansDb) return false;
    try {
        SQLite::Transaction transaction(*m_loansDb);

        // Check if book is available
        SQLite::Statement bookQuery(*m_booksDb, "SELECT status FROM books WHERE id = ? AND deleted = 0");
        bookQuery.bind(1, bookId);
        if (!bookQuery.executeStep()) return false;
        if (bookQuery.getColumn(0).getText() != std::string("Available")) return false;

        // Check if reader exists
        SQLite::Statement readerQuery(*m_readersDb, "SELECT id FROM readers WHERE id = ? AND deleted = 0");
        readerQuery.bind(1, readerId);
        if (!readerQuery.executeStep()) return false;

        Domain::DateTime now = Domain::now();
        Domain::DateTime dueDate = now + std::chrono::hours(24 * days);

        std::string loanId = std::to_string(std::chrono::duration_cast<std::chrono::milliseconds>(
            now.time_since_epoch()).count());

        SQLite::Statement query(*m_loansDb,
            "INSERT INTO loans (id, bookId, readerId, loanDate, dueDate, status) VALUES (?, ?, ?, ?, ?, 'active')");
        query.bind(1, loanId);
        query.bind(2, bookId);
        query.bind(3, readerId);
        query.bind(4, dateTimeToString(now));
        query.bind(5, dateTimeToString(dueDate));
        query.exec();

        // Update book status to Borrowed
        SQLite::Statement updateBook(*m_booksDb, "UPDATE books SET status = 'Borrowed', updatedAt = ? WHERE id = ?");
        updateBook.bind(1, dateTimeToString(now));
        updateBook.bind(2, bookId);
        updateBook.exec();

        transaction.commit();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}

bool SQLiteDataAccess::returnBook(const std::string& loanId)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_booksDb || !m_loansDb) return false;
    try {
        SQLite::Transaction transaction(*m_loansDb);

        // Get loan details
        SQLite::Statement loanQuery(*m_loansDb, "SELECT bookId FROM loans WHERE id = ? AND status = 'active'");
        loanQuery.bind(1, loanId);
        if (!loanQuery.executeStep()) return false;
        std::string bookId = loanQuery.getColumn(0).getText();

        Domain::DateTime now = Domain::now();

        // Update loan
        SQLite::Statement updateLoan(*m_loansDb,
            "UPDATE loans SET status = 'returned', returnDate = ? WHERE id = ?");
        updateLoan.bind(1, dateTimeToString(now));
        updateLoan.bind(2, loanId);
        updateLoan.exec();

        // Update book status to Available
        SQLite::Statement updateBook(*m_booksDb, "UPDATE books SET status = 'Available', updatedAt = ? WHERE id = ?");
        updateBook.bind(1, dateTimeToString(now));
        updateBook.bind(2, bookId);
        updateBook.exec();

        transaction.commit();
        return true;
    }
    catch (const std::exception&) {
        return false;
    }
}

std::vector<Domain::Loan> SQLiteDataAccess::getAllLoans()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Loan> loans;
    if (!m_loansDb) return loans;

    SQLite::Statement query(*m_loansDb, "SELECT id, bookId, readerId, loanDate, dueDate, returnDate, status FROM loans ORDER BY loanDate DESC");
    while (query.executeStep()) {
        loans.push_back(rowToLoan(query));
    }
    return loans;
}

std::vector<Domain::Loan> SQLiteDataAccess::getActiveLoans()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Loan> loans;
    if (!m_loansDb) return loans;

    SQLite::Statement query(*m_loansDb, "SELECT id, bookId, readerId, loanDate, dueDate, returnDate, status FROM loans WHERE status = 'active' ORDER BY dueDate");
    while (query.executeStep()) {
        loans.push_back(rowToLoan(query));
    }
    return loans;
}

std::vector<Domain::Loan> SQLiteDataAccess::getOverdueLoans()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Loan> loans;
    if (!m_loansDb) return loans;

    std::string nowStr = dateTimeToString(Domain::now());
    SQLite::Statement query(*m_loansDb, "SELECT id, bookId, readerId, loanDate, dueDate, returnDate, status FROM loans WHERE status = 'active' AND dueDate < ? ORDER BY dueDate");
    query.bind(1, nowStr);
    while (query.executeStep()) {
        loans.push_back(rowToLoan(query));
    }
    return loans;
}

std::vector<Domain::Loan> SQLiteDataAccess::getLoansForReader(const std::string& readerId)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Loan> loans;
    if (!m_loansDb) return loans;

    SQLite::Statement query(*m_loansDb, "SELECT id, bookId, readerId, loanDate, dueDate, returnDate, status FROM loans WHERE readerId = ? ORDER BY loanDate DESC");
    query.bind(1, readerId);
    while (query.executeStep()) {
        loans.push_back(rowToLoan(query));
    }
    return loans;
}

std::vector<Domain::Loan> SQLiteDataAccess::getLoansForBook(const std::string& bookId)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::Loan> loans;
    if (!m_loansDb) return loans;

    SQLite::Statement query(*m_loansDb, "SELECT id, bookId, readerId, loanDate, dueDate, returnDate, status FROM loans WHERE bookId = ? ORDER BY loanDate DESC");
    query.bind(1, bookId);
    while (query.executeStep()) {
        loans.push_back(rowToLoan(query));
    }
    return loans;
}

// User operations
bool SQLiteDataAccess::addUser(const Domain::User& user)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_usersDb) return false;
    try {
        qDebug() << "[DB addUser] username:" << QString::fromStdString(user.username) << "id empty:" << user.id.empty();
        SQLite::Statement query(*m_usersDb,
            "INSERT INTO users (id, username, passwordHash, salt, role, createdAt) VALUES (?, ?, ?, ?, ?, ?)");
        query.bind(1, user.id);
        query.bind(2, user.username);
        query.bind(3, user.passwordHash);
        query.bind(4, user.salt);
        query.bind(5, static_cast<int>(user.role));
        query.bind(6, dateTimeToString(user.createdAt));
        query.exec();
        qDebug() << "[DB addUser] SUCCESS";
        return true;
    }
    catch (const std::exception& e) {
        qDebug() << "[DB addUser] FAILED:" << e.what();
        return false;
    }
}

std::optional<Domain::User> SQLiteDataAccess::getUserByUsername(const std::string& username)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_usersDb) return std::nullopt;
    SQLite::Statement query(*m_usersDb, "SELECT id, username, passwordHash, salt, role, createdAt, lastLogin FROM users WHERE username = ?");
    query.bind(1, username);
    if (query.executeStep()) {
        return rowToUser(query);
    }
    return std::nullopt;
}

bool SQLiteDataAccess::updateUser(const Domain::User& user)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    if (!m_usersDb) return false;
    try {
        SQLite::Statement query(*m_usersDb,
            "UPDATE users SET passwordHash = ?, salt = ?, role = ?, lastLogin = ? WHERE id = ?");
        query.bind(1, user.passwordHash);
        query.bind(2, user.salt);
        query.bind(3, static_cast<int>(user.role));
        query.bind(4, user.lastLogin == Domain::DateTime{} ? "" : dateTimeToString(user.lastLogin));
        query.bind(5, user.id);
        int rows = query.exec();
        return rows > 0;
    }
    catch (const std::exception&) {
        return false;
    }
}

std::vector<Domain::User> SQLiteDataAccess::getAllUsers()
{
    std::lock_guard<std::mutex> lock(m_mutex);
    std::vector<Domain::User> users;
    if (!m_usersDb) return users;

    SQLite::Statement query(*m_usersDb, "SELECT id, username, passwordHash, salt, role, createdAt, lastLogin FROM users ORDER BY username");
    while (query.executeStep()) {
        users.push_back(rowToUser(query));
    }
    return users;
}

// ID checking
bool SQLiteDataAccess::checkIdExists(const std::string& entityType, const std::string& id)
{
    std::lock_guard<std::mutex> lock(m_mutex);
    try {
        if (entityType == "books") {
            SQLite::Statement query(*m_booksDb, "SELECT 1 FROM books WHERE id = ? AND deleted = 0");
            query.bind(1, id);
            return query.executeStep();
        } else if (entityType == "readers") {
            SQLite::Statement query(*m_readersDb, "SELECT 1 FROM readers WHERE id = ? AND deleted = 0");
            query.bind(1, id);
            return query.executeStep();
        } else if (entityType == "categories") {
            SQLite::Statement query(*m_booksDb, "SELECT 1 FROM categories WHERE id = ?");
            query.bind(1, id);
            return query.executeStep();
        } else if (entityType == "locations") {
            SQLite::Statement query(*m_booksDb, "SELECT 1 FROM locations WHERE id = ?");
            query.bind(1, id);
            return query.executeStep();
        } else if (entityType == "users") {
            SQLite::Statement query(*m_usersDb, "SELECT 1 FROM users WHERE id = ?");
            query.bind(1, id);
            return query.executeStep();
        } else if (entityType == "loans") {
            SQLite::Statement query(*m_loansDb, "SELECT 1 FROM loans WHERE id = ?");
            query.bind(1, id);
            return query.executeStep();
        }
    }
    catch (const std::exception&) {
        return false;
    }
    return false;
}

// Listbox population
std::vector<ListItem> SQLiteDataAccess::populateList(const std::string& entityType, const std::string& searchTerm, const std::string& filterField)
{
    std::vector<ListItem> items;

    try {
        if (entityType == "books") {
            std::vector<Domain::Book> books;
            if (searchTerm.empty()) {
                books = getAllBooks();
            } else {
                books = searchBooks(searchTerm, filterField);
            }
            for (const auto& book : books) {
                items.push_back({book.id, book.toDisplayString(), filterField});
            }
        } else if (entityType == "readers") {
            std::vector<Domain::Reader> readers;
            if (searchTerm.empty()) {
                readers = getAllReaders();
            } else {
                readers = searchReaders(searchTerm, filterField);
            }
            for (const auto& reader : readers) {
                items.push_back({reader.id, reader.toDisplayString(), filterField});
            }
        } else if (entityType == "categories") {
            auto categories = getAllCategories();
            for (const auto& cat : categories) {
                items.push_back({cat.id, cat.name, ""});
            }
        } else if (entityType == "locations") {
            auto locations = getAllLocations();
            for (const auto& loc : locations) {
                items.push_back({loc.id, loc.name, ""});
            }
        } else if (entityType == "users") {
            auto users = getAllUsers();
            for (const auto& user : users) {
                items.push_back({user.id, user.username + " | " + std::to_string(static_cast<int>(user.role)), ""});
            }
        } else if (entityType == "loans") {
            auto loans = getActiveLoans();
            for (const auto& loan : loans) {
                items.push_back({loan.id, loan.toDisplayString(), ""});
            }
        }
    }
    catch (const std::exception&) {
        // Return empty on error
    }

    return items;
}

} // namespace DataAccess