#pragma once

#include "businesslogic.h"
#include "sqlite_dataaccess.h"
#include <memory>
#include <algorithm>

namespace BusinessLogic {

class BookService : public IBookService {
public:
    explicit BookService(std::shared_ptr<DataAccess::IDataAccess> dataAccess)
        : m_dataAccess(std::move(dataAccess)) {}

    std::vector<Domain::Book> getAllBooks() override {
        return m_dataAccess->getAllBooks();
    }

    std::optional<Domain::Book> getBookById(const std::string& id) override {
        return m_dataAccess->getBookById(id);
    }

    std::vector<Domain::Book> searchBooks(const std::string& term, const std::string& field) override {
        return m_dataAccess->searchBooks(term, field);
    }

    bool addBook(const Domain::Book& book) override {
        return m_dataAccess->addBook(book);
    }

    bool updateBook(const Domain::Book& book) override {
        return m_dataAccess->updateBook(book);
    }

    bool removeBook(const std::string& id) override {
        return m_dataAccess->removeBook(id);
    }

    std::vector<Domain::Book> getRemovedBooks() override {
        return m_dataAccess->getRemovedBooks();
    }

    bool restoreBook(const std::string& id) override {
        return m_dataAccess->restoreBook(id);
    }

private:
    std::shared_ptr<DataAccess::IDataAccess> m_dataAccess;
};

class ReaderService : public IReaderService {
public:
    explicit ReaderService(std::shared_ptr<DataAccess::IDataAccess> dataAccess)
        : m_dataAccess(std::move(dataAccess)) {}

    std::vector<Domain::Reader> getAllReaders() override {
        return m_dataAccess->getAllReaders();
    }

    std::optional<Domain::Reader> getReaderById(const std::string& id) override {
        return m_dataAccess->getReaderById(id);
    }

    std::vector<Domain::Reader> searchReaders(const std::string& term, const std::string& field) override {
        return m_dataAccess->searchReaders(term, field);
    }

    bool addReader(const Domain::Reader& reader) override {
        return m_dataAccess->addReader(reader);
    }

    bool updateReader(const Domain::Reader& reader) override {
        return m_dataAccess->updateReader(reader);
    }

    bool removeReader(const std::string& id) override {
        return m_dataAccess->removeReader(id);
    }

    std::vector<Domain::Reader> getRemovedReaders() override {
        return m_dataAccess->getRemovedReaders();
    }

    bool restoreReader(const std::string& id) override {
        return m_dataAccess->restoreReader(id);
    }

private:
    std::shared_ptr<DataAccess::IDataAccess> m_dataAccess;
};

class CategoryService : public ICategoryService {
public:
    explicit CategoryService(std::shared_ptr<DataAccess::IDataAccess> dataAccess)
        : m_dataAccess(std::move(dataAccess)) {}

    std::vector<Domain::Category> getAllCategories() override {
        return m_dataAccess->getAllCategories();
    }

    bool addCategory(const Domain::Category& category) override {
        return m_dataAccess->addCategory(category);
    }

    bool updateCategory(const Domain::Category& category) override {
        return m_dataAccess->updateCategory(category);
    }

    bool removeCategory(const std::string& id) override {
        return m_dataAccess->removeCategory(id);
    }

private:
    std::shared_ptr<DataAccess::IDataAccess> m_dataAccess;
};

class LocationService : public ILocationService {
public:
    explicit LocationService(std::shared_ptr<DataAccess::IDataAccess> dataAccess)
        : m_dataAccess(std::move(dataAccess)) {}

    std::vector<Domain::Location> getAllLocations() override {
        return m_dataAccess->getAllLocations();
    }

    bool addLocation(const Domain::Location& location) override {
        return m_dataAccess->addLocation(location);
    }

    bool updateLocation(const Domain::Location& location) override {
        return m_dataAccess->updateLocation(location);
    }

    bool removeLocation(const std::string& id) override {
        return m_dataAccess->removeLocation(id);
    }

private:
    std::shared_ptr<DataAccess::IDataAccess> m_dataAccess;
};

class LoanService : public ILoanService {
public:
    explicit LoanService(std::shared_ptr<DataAccess::IDataAccess> dataAccess)
        : m_dataAccess(std::move(dataAccess)) {}

    bool loanBook(const std::string& bookId, const std::string& readerId, int days) override {
        return m_dataAccess->loanBook(bookId, readerId, days);
    }

    bool returnBook(const std::string& loanId) override {
        return m_dataAccess->returnBook(loanId);
    }

    std::vector<Domain::Loan> getActiveLoans() override {
        return m_dataAccess->getActiveLoans();
    }

    std::vector<Domain::Loan> getOverdueLoans() override {
        return m_dataAccess->getOverdueLoans();
    }

    std::vector<Domain::Loan> getLoansForReader(const std::string& readerId) override {
        return m_dataAccess->getLoansForReader(readerId);
    }

    std::vector<Domain::Loan> getLoansForBook(const std::string& bookId) override {
        return m_dataAccess->getLoansForBook(bookId);
    }

private:
    std::shared_ptr<DataAccess::IDataAccess> m_dataAccess;
};

class UserService : public IUserService {
public:
    explicit UserService(std::shared_ptr<DataAccess::IDataAccess> dataAccess)
        : m_dataAccess(std::move(dataAccess)) {}

    bool registerUser(const DTO::UserDTO& user) override {
        Domain::User domainUser = user.toDomain();
        return m_dataAccess->addUser(domainUser);
    }

    std::optional<Domain::User> login(const std::string& username, const std::string& password) override {
        auto userOpt = m_dataAccess->getUserByUsername(username);
        if (!userOpt.has_value()) {
            return std::nullopt;
        }

        // Verify password using crypto
        // For now, simple comparison (in real app, use proper password hashing)
        if (userOpt->passwordHash == password) {
            return userOpt;
        }
        return std::nullopt;
    }

    bool changePassword(const std::string& userId, const std::string& oldPassword, const std::string& newPassword) override {
        auto userOpt = getUserById(userId);
        if (!userOpt.has_value()) return false;
        if (userOpt->passwordHash != oldPassword) return false;

        userOpt->passwordHash = newPassword;
        return m_dataAccess->updateUser(*userOpt);
    }

    std::vector<Domain::User> getAllUsers() override {
        return m_dataAccess->getAllUsers();
    }

    std::optional<Domain::User> getUserById(const std::string& id) {
        auto users = m_dataAccess->getAllUsers();
        auto it = std::find_if(users.begin(), users.end(), [&id](const Domain::User& u) { return u.id == id; });
        if (it != users.end()) return *it;
        return std::nullopt;
    }

private:
    std::shared_ptr<DataAccess::IDataAccess> m_dataAccess;
};

class UndoService : public IUndoService {
public:
    void recordAdd(const std::string& entityType, const std::string& data) override {
        (void)entityType; (void)data;
        m_stack.emplace_back(Domain::UndoEntry{Domain::UndoEntry::Type::Add, stringToEntity(entityType), "", data, Domain::now()});
    }

    void recordEdit(const std::string& entityType, const std::string& oldData, const std::string& newData) override {
        (void)entityType; (void)oldData; (void)newData;
        m_stack.emplace_back(Domain::UndoEntry{Domain::UndoEntry::Type::Edit, stringToEntity(entityType), oldData, newData, Domain::now()});
    }

    void recordRemove(const std::string& entityType, const std::string& data) override {
        (void)entityType; (void)data;
        m_stack.emplace_back(Domain::UndoEntry{Domain::UndoEntry::Type::Remove, stringToEntity(entityType), data, "", Domain::now()});
    }

    bool canUndo() const override {
        return !m_stack.empty();
    }

    bool undo() override {
        if (m_stack.empty()) return false;
        // In a full implementation, this would apply the undo operation to the database
        m_stack.pop_back();
        return true;
    }

    void clear() override {
        m_stack.clear();
    }

private:
    std::vector<Domain::UndoEntry> m_stack;

    Domain::UndoEntry::Entity stringToEntity(const std::string& type) {
        if (type == "book") return Domain::UndoEntry::Entity::BookEntity;
        if (type == "reader") return Domain::UndoEntry::Entity::ReaderEntity;
        if (type == "category") return Domain::UndoEntry::Entity::CategoryEntity;
        if (type == "location") return Domain::UndoEntry::Entity::LocationEntity;
        return Domain::UndoEntry::Entity::BookEntity;
    }
};

class DatabaseManager : public IDatabaseManager {
public:
    explicit DatabaseManager(std::shared_ptr<DataAccess::SQLiteDataAccess> dataAccess)
        : m_dataAccess(std::move(dataAccess)) {}

    bool initialize(const std::string& booksDb, const std::string& readersDb, const std::string& loansDb) override {
        try {
            m_dataAccess->initialize(booksDb, readersDb, loansDb);
            return true;
        }
        catch (const std::exception&) {
            return false;
        }
    }

    void shutdown() override {
        m_dataAccess->shutdown();
    }

    bool isConnected() const override {
        return m_dataAccess->isConnected();
    }

    bool isBooksDbSelected() const override {
        return m_dataAccess->isConnected();
    }

    bool isReadersDbSelected() const override {
        return m_dataAccess->isConnected();
    }

    bool isLoansDbSelected() const override {
        return m_dataAccess->isConnected();
    }

private:
    std::shared_ptr<DataAccess::SQLiteDataAccess> m_dataAccess;
};

} // namespace BusinessLogic