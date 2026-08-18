#pragma once

#include "domain.h"
#include <string>
#include <optional>
#include <vector>
#include <exception>

namespace DataAccess {

class DataAccessException : public std::exception {
public:
    explicit DataAccessException(const std::string& message) : m_message(message) {}
    const char* what() const noexcept override { return m_message.c_str(); }
    const std::string& message() const { return m_message; }
private:
    std::string m_message;
};

class IDataAccess {
public:
    virtual ~IDataAccess() = default;
    virtual void initialize(const std::string& booksDb, const std::string& readersDb, const std::string& loansDb) = 0;
    virtual void shutdown() = 0;
    virtual bool isConnected() const = 0;

    // Book operations
    virtual std::vector<Domain::Book> getAllBooks() = 0;
    virtual std::optional<Domain::Book> getBookById(int id) = 0;
    virtual std::vector<Domain::Book> searchBooks(const std::string& term, const std::string& field) = 0;
    virtual bool addBook(const Domain::Book& book) = 0;
    virtual bool updateBook(const Domain::Book& book) = 0;
    virtual bool removeBook(int id) = 0;
    virtual std::vector<Domain::Book> getRemovedBooks() = 0;
    virtual bool restoreBook(int id) = 0;

    // Reader operations
    virtual std::vector<Domain::Reader> getAllReaders() = 0;
    virtual std::optional<Domain::Reader> getReaderById(int id) = 0;
    virtual std::vector<Domain::Reader> searchReaders(const std::string& term, const std::string& field) = 0;
    virtual bool addReader(const Domain::Reader& reader) = 0;
    virtual bool updateReader(const Domain::Reader& reader) = 0;
    virtual bool removeReader(int id) = 0;
    virtual std::vector<Domain::Reader> getRemovedReaders() = 0;
    virtual bool restoreReader(int id) = 0;

    // Category operations
    virtual std::vector<Domain::Category> getAllCategories() = 0;
    virtual bool addCategory(const Domain::Category& category) = 0;
    virtual bool updateCategory(const Domain::Category& category) = 0;
    virtual bool removeCategory(int id) = 0;

    // Location operations
    virtual std::vector<Domain::Location> getAllLocations() = 0;
    virtual bool addLocation(const Domain::Location& location) = 0;
    virtual bool updateLocation(const Domain::Location& location) = 0;
    virtual bool removeLocation(int id) = 0;

    // Loan operations
    virtual bool loanBook(int bookId, int readerId, int days) = 0;
    virtual bool returnBook(int loanId) = 0;
    virtual std::vector<Domain::Loan> getActiveLoans() = 0;
    virtual std::vector<Domain::Loan> getOverdueLoans() = 0;
    virtual std::vector<Domain::Loan> getLoansForReader(int readerId) = 0;
    virtual std::vector<Domain::Loan> getLoansForBook(int bookId) = 0;

    // User operations
    virtual bool addUser(const Domain::User& user) = 0;
    virtual std::optional<Domain::User> getUserByUsername(const std::string& username) = 0;
    virtual bool updateUser(const Domain::User& user) = 0;
    virtual std::vector<Domain::User> getAllUsers() = 0;
};

} // namespace DataAccess