#pragma once

#include "domain.h"
#include "dataaccess.h"
#include <string>
#include <optional>
#include <vector>

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

struct DatabaseValidationResult {
    bool isValid = false;
    std::string errorMessage;

    static DatabaseValidationResult success() {
        return DatabaseValidationResult{true, ""};
    }

    static DatabaseValidationResult failure(const std::string& message) {
        return DatabaseValidationResult{false, message};
    }
};

DatabaseValidationResult validateDatabases(DataAccess::IDataAccess& db);

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

// Validation functions
ValidationResult validateBookDTO(const DTO::BookDTO& book);
ValidationResult validateReaderDTO(const DTO::ReaderDTO& reader);
ValidationResult validateLoanDTO(const DTO::LoanDTO& loan);
ValidationResult validateCategoryDTO(const DTO::CategoryDTO& category);
ValidationResult validateLocationDTO(const DTO::LocationDTO& location);
ValidationResult validateUserDTO(const DTO::UserDTO& user);

// CRUD functions: validate then call data access
ValidationResult addBook(DataAccess::IDataAccess& db, const DTO::BookDTO& book);
ValidationResult addReader(DataAccess::IDataAccess& db, const DTO::ReaderDTO& reader);
ValidationResult addCategory(DataAccess::IDataAccess& db, const DTO::CategoryDTO& category);
ValidationResult addLocation(DataAccess::IDataAccess& db, const DTO::LocationDTO& location);
ValidationResult addLoan(DataAccess::IDataAccess& db, const DTO::LoanDTO& loan);
ValidationResult addUser(DataAccess::IDataAccess& db, const DTO::UserDTO& user);

ValidationResult updateBook(DataAccess::IDataAccess& db, const DTO::BookDTO& book);
ValidationResult updateReader(DataAccess::IDataAccess& db, const DTO::ReaderDTO& reader);
ValidationResult updateCategory(DataAccess::IDataAccess& db, const DTO::CategoryDTO& category);
ValidationResult updateLocation(DataAccess::IDataAccess& db, const DTO::LocationDTO& location);
ValidationResult updateLoan(DataAccess::IDataAccess& db, const DTO::LoanDTO& loan);

// Authentication
std::optional<Domain::User> login(DataAccess::IDataAccess& db, const std::string& username, const std::string& password);

// Crypto initialization
bool initializeCrypto();

// Database lifecycle
bool initializeDatabases(DataAccess::IDataAccess& db, const std::string& booksDb, const std::string& readersDb, const std::string& loansDb, const std::string& usersDb);
void shutdownDatabases(DataAccess::IDataAccess& db);
bool isDatabaseConnected(DataAccess::IDataAccess& db);

// List population
std::vector<DataAccess::ListItem> populateList(DataAccess::IDataAccess& db, const std::string& entityType, const std::string& searchTerm = "", const std::string& filterField = "");

} // namespace BusinessLogic
