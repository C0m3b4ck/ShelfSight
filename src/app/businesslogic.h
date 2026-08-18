#pragma once

#include "domain.h"
#include <string>
#include <optional>
#include <vector>
#include <memory>

namespace BusinessLogic {

struct ValidationResult {
    bool isValid = false;
    std::string errorMessage;

    static ValidationResult success() {
        return ValidationResult{true, ""};
    }

    static ValidationResult failure(const std::string& message) {
        return ValidationResult{false, message};
    }
};

// Service interfaces
class IBookService {
public:
    virtual ~IBookService() = default;
    virtual std::vector<Domain::Book> getAllBooks() = 0;
    virtual std::optional<Domain::Book> getBookById(int id) = 0;
    virtual std::vector<Domain::Book> searchBooks(const std::string& term, const std::string& field) = 0;
    virtual bool addBook(const Domain::Book& book) = 0;
    virtual bool updateBook(const Domain::Book& book) = 0;
    virtual bool removeBook(int id) = 0;
    virtual std::vector<Domain::Book> getRemovedBooks() = 0;
    virtual bool restoreBook(int id) = 0;
};

class IReaderService {
public:
    virtual ~IReaderService() = default;
    virtual std::vector<Domain::Reader> getAllReaders() = 0;
    virtual std::optional<Domain::Reader> getReaderById(int id) = 0;
    virtual std::vector<Domain::Reader> searchReaders(const std::string& term, const std::string& field) = 0;
    virtual bool addReader(const Domain::Reader& reader) = 0;
    virtual bool updateReader(const Domain::Reader& reader) = 0;
    virtual bool removeReader(int id) = 0;
    virtual std::vector<Domain::Reader> getRemovedReaders() = 0;
    virtual bool restoreReader(int id) = 0;
};

class ICategoryService {
public:
    virtual ~ICategoryService() = default;
    virtual std::vector<Domain::Category> getAllCategories() = 0;
    virtual bool addCategory(const Domain::Category& category) = 0;
    virtual bool updateCategory(const Domain::Category& category) = 0;
    virtual bool removeCategory(int id) = 0;
};

class ILocationService {
public:
    virtual ~ILocationService() = default;
    virtual std::vector<Domain::Location> getAllLocations() = 0;
    virtual bool addLocation(const Domain::Location& location) = 0;
    virtual bool updateLocation(const Domain::Location& location) = 0;
    virtual bool removeLocation(int id) = 0;
};

class ILoanService {
public:
    virtual ~ILoanService() = default;
    virtual bool loanBook(int bookId, int readerId, int days) = 0;
    virtual bool returnBook(int loanId) = 0;
    virtual std::vector<Domain::Loan> getActiveLoans() = 0;
    virtual std::vector<Domain::Loan> getOverdueLoans() = 0;
    virtual std::vector<Domain::Loan> getLoansForReader(int readerId) = 0;
    virtual std::vector<Domain::Loan> getLoansForBook(int bookId) = 0;
};

class IUserService {
public:
    virtual ~IUserService() = default;
    virtual bool registerUser(const DTO::UserDTO& user) = 0;
    virtual std::optional<Domain::User> login(const std::string& username, const std::string& password) = 0;
    virtual bool changePassword(int userId, const std::string& oldPassword, const std::string& newPassword) = 0;
    virtual std::vector<Domain::User> getAllUsers() = 0;
};

class IUndoService {
public:
    virtual ~IUndoService() = default;
    virtual void recordAdd(const std::string& entityType, const std::string& data) = 0;
    virtual void recordEdit(const std::string& entityType, const std::string& oldData, const std::string& newData) = 0;
    virtual void recordRemove(const std::string& entityType, const std::string& data) = 0;
    virtual bool canUndo() const = 0;
    virtual bool undo() = 0;
    virtual void clear() = 0;
};

class IDatabaseManager {
public:
    virtual ~IDatabaseManager() = default;
    virtual bool initialize(const std::string& booksDb, const std::string& readersDb, const std::string& loansDb) = 0;
    virtual void shutdown() = 0;
    virtual bool isConnected() const = 0;
    virtual bool isBooksDbSelected() const = 0;
    virtual bool isReadersDbSelected() const = 0;
    virtual bool isLoansDbSelected() const = 0;
};

// Database validation
struct DatabaseValidationResult {
    bool isValid = false;
    std::string errorMessage;
    bool booksDbOk = false;
    bool readersDbOk = false;
    bool loansDbOk = false;

    static DatabaseValidationResult success() {
        return DatabaseValidationResult{true, "", true, true, true};
    }

    static DatabaseValidationResult failure(const std::string& message, bool books = false, bool readers = false, bool loans = false) {
        return DatabaseValidationResult{false, message, books, readers, loans};
    }
};

DatabaseValidationResult validateDatabases(const IDatabaseManager& dbManager, bool requireBooks = true, bool requireReaders = true, bool requireLoans = false);

// Role-based access control
enum class RequiredRole { None = 0, Admin = 2, SuperAdmin = 3 };

struct RoleCheckResult {
    bool hasAccess = false;
    std::string errorMessage;
    static RoleCheckResult success() { return RoleCheckResult{true, ""}; }
    static RoleCheckResult failure(const std::string& msg) { return RoleCheckResult{false, msg}; }
};

RoleCheckResult checkUserRole(const std::optional<Domain::User>& currentUser, RequiredRole required);
RoleCheckResult checkUserRole(int userRoleInt, RequiredRole required);

// ID checking
ValidationResult checkIdExists(const std::string& dbType, int id);
ValidationResult checkIdNotExists(const std::string& dbType, int id);

// Listbox population
struct ListItem {
    int id = 0;
    std::string displayText;
    std::string searchField;
};

std::vector<ListItem> populateList(const std::string& entityType, const std::string& searchTerm = "", const std::string& filterField = "");
std::vector<ListItem> populateListWithDb(const std::string& dbName, const std::string& entityType, const std::string& searchTerm = "", const std::string& filterField = "");

// Facade for accessing all services
class BusinessLogicFacade {
public:
    std::unique_ptr<IDatabaseManager> db;
    std::unique_ptr<IBookService> books;
    std::unique_ptr<IReaderService> readers;
    std::unique_ptr<ICategoryService> categories;
    std::unique_ptr<ILocationService> locations;
    std::unique_ptr<IUserService> users;
    std::unique_ptr<ILoanService> loans;
    std::unique_ptr<IUndoService> undo;

    // Current logged in user
    std::optional<Domain::User> currentUser;

    static BusinessLogicFacade& instance() {
        static BusinessLogicFacade facade;
        return facade;
    }
};

ValidationResult validateBookDTO(const DTO::BookDTO& book);
ValidationResult validateReaderDTO(const DTO::ReaderDTO& reader);
ValidationResult validateLoanDTO(const DTO::LoanDTO& loan);
ValidationResult validateCategoryDTO(const DTO::CategoryDTO& category);
ValidationResult validateLocationDTO(const DTO::LocationDTO& location);
ValidationResult validateUserDTO(const DTO::UserDTO& user);

// Add functions that validate and then add to database
ValidationResult addBook(IBookService& service, const DTO::BookDTO& book);
ValidationResult addReader(IReaderService& service, const DTO::ReaderDTO& reader);
ValidationResult addCategory(ICategoryService& service, const DTO::CategoryDTO& category);
ValidationResult addLocation(ILocationService& service, const DTO::LocationDTO& location);
ValidationResult addLoan(ILoanService& service, const DTO::LoanDTO& loan);
ValidationResult addUser(IUserService& service, const DTO::UserDTO& user);

// Update functions that validate and then update in database
ValidationResult updateBook(IBookService& service, const DTO::BookDTO& book);
ValidationResult updateReader(IReaderService& service, const DTO::ReaderDTO& reader);
ValidationResult updateCategory(ICategoryService& service, const DTO::CategoryDTO& category);
ValidationResult updateLocation(ILocationService& service, const DTO::LocationDTO& location);
ValidationResult updateLoan(ILoanService& service, const DTO::LoanDTO& loan);

} // namespace BusinessLogic