#include "database.h"

#include <stdexcept>
#include <cstdio>
#include <cstring>

namespace shelfsight {

namespace {

// RAII wrapper for sqlite3_stmt to guarantee finalize even on early returns.
class Stmt {
public:
    Stmt() = default;
    Stmt(sqlite3* db, const char* sql) {
        if (sqlite3_prepare_v2(db, sql, -1, &stmt_, nullptr) != SQLITE_OK) {
            throw std::runtime_error(sqlite3_errmsg(db));
        }
    }
    ~Stmt() {
        if (stmt_) sqlite3_finalize(stmt_);
    }
    Stmt(const Stmt&) = delete;
    Stmt& operator=(const Stmt&) = delete;
    Stmt(Stmt&& other) noexcept : stmt_(other.stmt_) { other.stmt_ = nullptr; }
    Stmt& operator=(Stmt&& other) noexcept {
        if (this != &other) {
            if (stmt_) sqlite3_finalize(stmt_);
            stmt_ = other.stmt_;
            other.stmt_ = nullptr;
        }
        return *this;
    }

    sqlite3_stmt* get() const { return stmt_; }
    int step() const { return sqlite3_step(stmt_); }

    void bind(int idx, const std::string& v) const {
        sqlite3_bind_text(stmt_, idx, v.c_str(), -1, SQLITE_TRANSIENT);
    }
    void bind(int idx, int v) const { sqlite3_bind_int(stmt_, idx, v); }
    void bindNull(int idx) const { sqlite3_bind_null(stmt_, idx); }

    std::string text(int col) const {
        const unsigned char* t = sqlite3_column_text(stmt_, col);
        return t ? reinterpret_cast<const char*>(t) : std::string();
    }
    int integer(int col) const { return sqlite3_column_int(stmt_, col); }
    bool isNull(int col) const { return sqlite3_column_type(stmt_, col) == SQLITE_NULL; }

private:
    sqlite3_stmt* stmt_ = nullptr;
};

const char* kSchema = R"(
CREATE TABLE IF NOT EXISTS books (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    book_id TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL DEFAULT '',
    status TEXT NOT NULL DEFAULT 'Available',
    deleted INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS readers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    surname TEXT NOT NULL DEFAULT '',
    grade TEXT NOT NULL DEFAULT '',
    class_name TEXT NOT NULL DEFAULT '',
    reader_id TEXT NOT NULL UNIQUE,
    deleted INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS loans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id TEXT NOT NULL,
    reader_id TEXT NOT NULL,
    loan_id TEXT NOT NULL UNIQUE,
    expiry_date TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Active'
);
CREATE TABLE IF NOT EXISTS credentials (
    username TEXT PRIMARY KEY,
    password_hash TEXT NOT NULL,
    role INTEGER NOT NULL DEFAULT 0
);
CREATE TABLE IF NOT EXISTS config (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
)";

} // namespace

Database::Database(const std::string& db_path) : db_path_(db_path) {}

Database::~Database() {
    if (db_) sqlite3_close(db_);
}

bool Database::exec(const std::string& sql) {
    if (sqlite3_exec(db_, sql.c_str(), nullptr, nullptr, nullptr) != SQLITE_OK) {
        return false;
    }
    return true;
}

bool Database::init() {
    return open(db_path_);
}

bool Database::open(const std::string& path) {
    if (db_) {
        sqlite3_close(db_);
        db_ = nullptr;
    }
    if (sqlite3_open(path.c_str(), &db_) != SQLITE_OK) {
        return false;
    }
    return create_tables();
}

bool Database::create_tables() {
    return exec(kSchema);
}

/* ------------------------- Books ------------------------- */

bool Database::add_book(const Book& book) {
    Stmt s(db_, "INSERT INTO books (title, author, book_id, category, status) "
               "VALUES (?, ?, ?, ?, ?)");
    s.bind(1, book.title);
    s.bind(2, book.author);
    s.bind(3, book.book_id);
    s.bind(4, book.category);
    s.bind(5, book.status);
    return s.step() == SQLITE_DONE;
}

bool Database::update_book(const Book& book) {
    Stmt s(db_, "UPDATE books SET title = ?, author = ?, category = ?, status = ? "
               "WHERE book_id = ? AND deleted = 0");
    s.bind(1, book.title);
    s.bind(2, book.author);
    s.bind(3, book.category);
    s.bind(4, book.status);
    s.bind(5, book.book_id);
    return s.step() == SQLITE_DONE;
}

bool Database::delete_book(const std::string& book_id) {
    // Soft delete: move to the deleted list so it can be restored.
    Stmt s(db_, "UPDATE books SET deleted = 1 WHERE book_id = ? AND deleted = 0");
    s.bind(1, book_id);
    return s.step() == SQLITE_DONE;
}

bool Database::restore_book(const std::string& book_id) {
    Stmt s(db_, "UPDATE books SET deleted = 0 WHERE book_id = ? AND deleted = 1");
    s.bind(1, book_id);
    return s.step() == SQLITE_DONE;
}

std::optional<Book> Database::get_book(const std::string& book_id) {
    Stmt s(db_, "SELECT id, title, author, book_id, category, status "
               "FROM books WHERE book_id = ? AND deleted = 0");
    s.bind(1, book_id);
    if (s.step() != SQLITE_ROW) return std::nullopt;
    Book b;
    b.id = s.integer(0);
    b.title = s.text(1);
    b.author = s.text(2);
    b.book_id = s.text(3);
    b.category = s.text(4);
    b.status = s.text(5);
    return b;
}

std::vector<Book> Database::search_books(const std::string& query, const std::string& field) {
    std::vector<Book> out;
    std::string sql = "SELECT id, title, author, book_id, category, status "
                      "FROM books WHERE deleted = 0";
    // field is only matched against a fixed allowlist, never user input.
    if (field == "Title") {
        sql += " AND title LIKE ?";
    } else if (field == "Author") {
        sql += " AND author LIKE ?";
    } else if (field == "ID") {
        sql += " AND book_id LIKE ?";
    }
    Stmt s(db_, sql.c_str());
    if (field == "Title" || field == "Author" || field == "ID") {
        s.bind(1, "%" + query + "%");
    }
    while (s.step() == SQLITE_ROW) {
        Book b;
        b.id = s.integer(0);
        b.title = s.text(1);
        b.author = s.text(2);
        b.book_id = s.text(3);
        b.category = s.text(4);
        b.status = s.text(5);
        out.push_back(std::move(b));
    }
    return out;
}

std::vector<Book> Database::get_deleted_books() {
    std::vector<Book> out;
    Stmt s(db_, "SELECT id, title, author, book_id, category, status "
                "FROM books WHERE deleted = 1");
    while (s.step() == SQLITE_ROW) {
        Book b;
        b.id = s.integer(0);
        b.title = s.text(1);
        b.author = s.text(2);
        b.book_id = s.text(3);
        b.category = s.text(4);
        b.status = s.text(5);
        out.push_back(std::move(b));
    }
    return out;
}

/* ------------------------- Readers ------------------------- */

bool Database::add_reader(const Reader& reader) {
    Stmt s(db_, "INSERT INTO readers (name, surname, grade, class_name, reader_id) "
               "VALUES (?, ?, ?, ?, ?)");
    s.bind(1, reader.name);
    s.bind(2, reader.surname);
    s.bind(3, reader.grade);
    s.bind(4, reader.class_name);
    s.bind(5, reader.reader_id);
    return s.step() == SQLITE_DONE;
}

bool Database::update_reader(const Reader& reader) {
    Stmt s(db_, "UPDATE readers SET name = ?, surname = ?, grade = ?, class_name = ? "
               "WHERE reader_id = ? AND deleted = 0");
    s.bind(1, reader.name);
    s.bind(2, reader.surname);
    s.bind(3, reader.grade);
    s.bind(4, reader.class_name);
    s.bind(5, reader.reader_id);
    return s.step() == SQLITE_DONE;
}

bool Database::delete_reader(const std::string& reader_id) {
    Stmt s(db_, "UPDATE readers SET deleted = 1 WHERE reader_id = ? AND deleted = 0");
    s.bind(1, reader_id);
    return s.step() == SQLITE_DONE;
}

bool Database::restore_reader(const std::string& reader_id) {
    Stmt s(db_, "UPDATE readers SET deleted = 0 WHERE reader_id = ? AND deleted = 1");
    s.bind(1, reader_id);
    return s.step() == SQLITE_DONE;
}

std::optional<Reader> Database::get_reader(const std::string& reader_id) {
    Stmt s(db_, "SELECT id, name, surname, grade, class_name, reader_id "
               "FROM readers WHERE reader_id = ? AND deleted = 0");
    s.bind(1, reader_id);
    if (s.step() != SQLITE_ROW) return std::nullopt;
    Reader r;
    r.id = s.integer(0);
    r.name = s.text(1);
    r.surname = s.text(2);
    r.grade = s.text(3);
    r.class_name = s.text(4);
    r.reader_id = s.text(5);
    return r;
}

std::vector<Reader> Database::search_readers(const std::string& query, const std::string& field) {
    std::vector<Reader> out;
    std::string sql = "SELECT id, name, surname, grade, class_name, reader_id "
                      "FROM readers WHERE deleted = 0";
    if (field == "Name") {
        sql += " AND name LIKE ?";
    } else if (field == "Surname") {
        sql += " AND surname LIKE ?";
    } else if (field == "ID") {
        sql += " AND reader_id LIKE ?";
    }
    Stmt s(db_, sql.c_str());
    if (field == "Name" || field == "Surname" || field == "ID") {
        s.bind(1, "%" + query + "%");
    }
    while (s.step() == SQLITE_ROW) {
        Reader r;
        r.id = s.integer(0);
        r.name = s.text(1);
        r.surname = s.text(2);
        r.grade = s.text(3);
        r.class_name = s.text(4);
        r.reader_id = s.text(5);
        out.push_back(std::move(r));
    }
    return out;
}

std::vector<Reader> Database::get_deleted_readers() {
    std::vector<Reader> out;
    Stmt s(db_, "SELECT id, name, surname, grade, class_name, reader_id "
                "FROM readers WHERE deleted = 1");
    while (s.step() == SQLITE_ROW) {
        Reader r;
        r.id = s.integer(0);
        r.name = s.text(1);
        r.surname = s.text(2);
        r.grade = s.text(3);
        r.class_name = s.text(4);
        r.reader_id = s.text(5);
        out.push_back(std::move(r));
    }
    return out;
}

/* ------------------------- Loans ------------------------- */

bool Database::add_loan(const Loan& loan) {
    Stmt s(db_, "INSERT INTO loans (book_id, reader_id, loan_id, expiry_date, status) "
               "VALUES (?, ?, ?, ?, ?)");
    s.bind(1, loan.book_id);
    s.bind(2, loan.reader_id);
    s.bind(3, loan.loan_id);
    s.bind(4, loan.expiry_date);
    s.bind(5, loan.status);
    return s.step() == SQLITE_DONE;
}

bool Database::update_loan(const Loan& loan) {
    Stmt s(db_, "UPDATE loans SET book_id = ?, reader_id = ?, expiry_date = ?, status = ? "
               "WHERE loan_id = ?");
    s.bind(1, loan.book_id);
    s.bind(2, loan.reader_id);
    s.bind(3, loan.expiry_date);
    s.bind(4, loan.status);
    s.bind(5, loan.loan_id);
    return s.step() == SQLITE_DONE;
}

bool Database::delete_loan(const std::string& loan_id) {
    Stmt s(db_, "DELETE FROM loans WHERE loan_id = ?");
    s.bind(1, loan_id);
    return s.step() == SQLITE_DONE;
}

std::optional<Loan> Database::get_loan(const std::string& loan_id) {
    Stmt s(db_, "SELECT id, book_id, reader_id, loan_id, expiry_date, status "
               "FROM loans WHERE loan_id = ?");
    s.bind(1, loan_id);
    if (s.step() != SQLITE_ROW) return std::nullopt;
    Loan l;
    l.id = s.integer(0);
    l.book_id = s.text(1);
    l.reader_id = s.text(2);
    l.loan_id = s.text(3);
    l.expiry_date = s.text(4);
    l.status = s.text(5);
    return l;
}

std::vector<Loan> Database::search_loans(const std::string& query, const std::string& field,
                                         const std::string& type) {
    std::vector<Loan> out;
    std::string sql = "SELECT id, book_id, reader_id, loan_id, expiry_date, status "
                      "FROM loans WHERE 1 = 1";
    // type is matched against a fixed allowlist.
    if (type == "Books") {
        sql += " AND book_id LIKE ?";
    } else if (type == "Readers") {
        sql += " AND reader_id LIKE ?";
    } else if (type == "Loans") {
        sql += " AND loan_id LIKE ?";
    }
    if (field == "Active") {
        sql += " AND status = 'Active'";
    } else if (field == "Expired") {
        sql += " AND status = 'Expired'";
    } else if (field == "Returned") {
        sql += " AND status = 'Returned'";
    } else if (field == "Lost") {
        sql += " AND status = 'Lost'";
    }
    Stmt s(db_, sql.c_str());
    if (type == "Books" || type == "Readers" || type == "Loans") {
        s.bind(1, "%" + query + "%");
    }
    while (s.step() == SQLITE_ROW) {
        Loan l;
        l.id = s.integer(0);
        l.book_id = s.text(1);
        l.reader_id = s.text(2);
        l.loan_id = s.text(3);
        l.expiry_date = s.text(4);
        l.status = s.text(5);
        out.push_back(std::move(l));
    }
    return out;
}

std::vector<Loan> Database::get_expired_loans() {
    std::vector<Loan> out;
    Stmt s(db_, "SELECT id, book_id, reader_id, loan_id, expiry_date, status "
                "FROM loans WHERE status = 'Active' AND expiry_date < date('now')");
    while (s.step() == SQLITE_ROW) {
        Loan l;
        l.id = s.integer(0);
        l.book_id = s.text(1);
        l.reader_id = s.text(2);
        l.loan_id = s.text(3);
        l.expiry_date = s.text(4);
        l.status = s.text(5);
        out.push_back(std::move(l));
    }
    return out;
}

/* ------------------------- Credentials ------------------------- */

bool Database::add_credential(const Credential& cred) {
    Stmt s(db_, "INSERT INTO credentials (username, password_hash, role) VALUES (?, ?, ?)");
    s.bind(1, cred.username);
    s.bind(2, cred.password_hash);
    s.bind(3, cred.role);
    return s.step() == SQLITE_DONE;
}

std::optional<Credential> Database::get_credential(const std::string& username) {
    Stmt s(db_, "SELECT username, password_hash, role FROM credentials WHERE username = ?");
    s.bind(1, username);
    if (s.step() != SQLITE_ROW) return std::nullopt;
    Credential c;
    c.username = s.text(0);
    c.password_hash = s.text(1);
    c.role = s.integer(2);
    return c;
}

bool Database::verify_credential(const std::string& username, const std::string& password_hash,
                                 int role) {
    Stmt s(db_, "SELECT 1 FROM credentials WHERE username = ? AND password_hash = ? AND role = ?");
    s.bind(1, username);
    s.bind(2, password_hash);
    s.bind(3, role);
    return s.step() == SQLITE_ROW;
}

/* ------------------------- Config ------------------------- */

bool Database::save_session_db(const std::string& path) {
    Stmt s(db_, "INSERT OR REPLACE INTO config (key, value) VALUES ('session_db', ?)");
    s.bind(1, path);
    return s.step() == SQLITE_DONE;
}

bool Database::load_session_db(std::string& path) {
    Stmt s(db_, "SELECT value FROM config WHERE key = 'session_db'");
    if (s.step() != SQLITE_ROW) return false;
    path = s.text(0);
    return true;
}

} // namespace shelfsight