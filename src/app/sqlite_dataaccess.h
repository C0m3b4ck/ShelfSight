#pragma once

#include "dataaccess.h"
#include <SQLiteCpp/Database.h>
#include <SQLiteCpp/Statement.h>
#include <memory>
#include <mutex>

namespace DataAccess {

class SQLiteDataAccess : public IDataAccess {
public:
    SQLiteDataAccess();
    ~SQLiteDataAccess() override;

    void initialize(const QString& booksDb, const QString& readersDb, const QString& loansDb) override;
    void shutdown() override;
    bool isConnected() const override;

    // Book operations
    std::vector<Domain::Book> getAllBooks() override;
    std::optional<Domain::Book> getBookById(int id) override;
    std::vector<Domain::Book> searchBooks(const QString& term, const QString& field) override;
    bool addBook(const Domain::Book& book) override;
    bool updateBook(const Domain::Book& book) override;
    bool removeBook(int id) override;
    std::vector<Domain::Book> getRemovedBooks() override;
    bool restoreBook(int id) override;

    // Reader operations
    std::vector<Domain::Reader> getAllReaders() override;
    std::optional<Domain::Reader> getReaderById(int id) override;
    std::vector<Domain::Reader> searchReaders(const QString& term, const QString& field) override;
    bool addReader(const Domain::Reader& reader) override;
    bool updateReader(const Domain::Reader& reader) override;
    bool removeReader(int id) override;
    std::vector<Domain::Reader> getRemovedReaders() override;
    bool restoreReader(int id) override;

    // Category operations
    std::vector<Domain::Category> getAllCategories() override;
    bool addCategory(const Domain::Category& category) override;
    bool updateCategory(const Domain::Category& category) override;
    bool removeCategory(int id) override;

    // Location operations
    std::vector<Domain::Location> getAllLocations() override;
    bool addLocation(const Domain::Location& location) override;
    bool updateLocation(const Domain::Location& location) override;
    bool removeLocation(int id) override;

    // Loan operations
    bool loanBook(int bookId, int readerId, int days) override;
    bool returnBook(int loanId) override;
    std::vector<Domain::Loan> getActiveLoans() override;
    std::vector<Domain::Loan> getOverdueLoans() override;
    std::vector<Domain::Loan> getLoansForReader(int readerId) override;
    std::vector<Domain::Loan> getLoansForBook(int bookId) override;

private:
    void createTables();
    void createIndexes();
    Domain::Book rowToBook(const SQLite::Statement& stmt);
    Domain::Reader rowToReader(const SQLite::Statement& stmt);
    Domain::Category rowToCategory(const SQLite::Statement& stmt);
    Domain::Location rowToLocation(const SQLite::Statement& stmt);
    Domain::Loan rowToLoan(const SQLite::Statement& stmt);
    QString dateTimeToString(const QDateTime& dt);
    QDateTime stringToDateTime(const QString& str);

    std::unique_ptr<SQLite::Database> m_booksDb;
    std::unique_ptr<SQLite::Database> m_readersDb;
    std::unique_ptr<SQLite::Database> m_loansDb;
    mutable std::mutex m_mutex;
    bool m_connected = false;
};

} // namespace DataAccess