#pragma once

#include <string>
#include <vector>
#include <optional>
#include <sqlite3.h>

namespace shelfsight {

struct Book {
    int id = 0;
    std::string title;
    std::string author;
    std::string book_id;
    std::string category;
    std::string status;
};

struct Reader {
    int id = 0;
    std::string name;
    std::string surname;
    std::string grade;
    std::string class_name;
    std::string reader_id;
};

struct Loan {
    int id = 0;
    std::string book_id;
    std::string reader_id;
    std::string loan_id;
    std::string expiry_date;
    std::string status;
};

struct Credential {
    std::string username;
    std::string password_hash;
    int role;
};

class Database {
public:
    explicit Database(const std::string& db_path);
    ~Database();

    bool init();

    // (Re)open the connection against the given file.  Closes any existing
    // connection first.  Used to switch the session database after login.
    bool open(const std::string& path);

    // Books
    bool add_book(const Book& book);
    bool update_book(const Book& book);
    bool delete_book(const std::string& book_id);
    bool restore_book(const std::string& book_id);
    std::optional<Book> get_book(const std::string& book_id);
    std::vector<Book> search_books(const std::string& query, const std::string& field);
    std::vector<Book> get_deleted_books();
    
    // Readers
    bool add_reader(const Reader& reader);
    bool update_reader(const Reader& reader);
    bool delete_reader(const std::string& reader_id);
    bool restore_reader(const std::string& reader_id);
    std::optional<Reader> get_reader(const std::string& reader_id);
    std::vector<Reader> search_readers(const std::string& query, const std::string& field);
    std::vector<Reader> get_deleted_readers();
    
    // Loans
    bool add_loan(const Loan& loan);
    bool update_loan(const Loan& loan);
    bool delete_loan(const std::string& loan_id);
    std::optional<Loan> get_loan(const std::string& loan_id);
    std::vector<Loan> search_loans(const std::string& query, const std::string& field, const std::string& type);
    std::vector<Loan> get_expired_loans();
    
    // Credentials
    bool add_credential(const Credential& cred);
    std::optional<Credential> get_credential(const std::string& username);
    bool verify_credential(const std::string& username, const std::string& password_hash, int role);
    
    // Config (stored in the app database, keyed "session_db")
    bool save_session_db(const std::string& path);
    bool load_session_db(std::string& path);

private:
    sqlite3* db_ = nullptr;
    std::string db_path_;
    
    bool exec(const std::string& sql);
    bool create_tables();
};

} // namespace shelfsight