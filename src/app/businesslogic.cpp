#include "businesslogic.h"
#include "domain.h"
#include <algorithm>
#include <cctype>
#include <QDebug>

namespace BusinessLogic {

static std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(" \t\n\r");
    if (first == std::string::npos) return "";
    size_t last = str.find_last_not_of(" \t\n\r");
    return str.substr(first, last - first + 1);
}

// ============ Validation ============

ValidationResult validateBookDTO(const DTO::BookDTO& book) {
    if (trim(book.title).empty()) {
        return ValidationResult::failure("Book title cannot be empty");
    }
    if (trim(book.author).empty()) {
        return ValidationResult::failure("Book author cannot be empty");
    }
    if (!Domain::isValidId(book.id)) {
        return ValidationResult::failure("Book ID cannot be empty");
    }
    if (trim(book.location).empty()) {
        return ValidationResult::failure("Book location cannot be empty");
    }
    if (trim(book.category).empty()) {
        return ValidationResult::failure("Book category cannot be empty");
    }
    if (trim(book.status).empty()) {
        return ValidationResult::failure("Book status cannot be empty");
    }
    return ValidationResult::success();
}

ValidationResult validateReaderDTO(const DTO::ReaderDTO& reader) {
    if (trim(reader.name).empty()) {
        return ValidationResult::failure("Reader name cannot be empty");
    }
    if (trim(reader.surname).empty()) {
        return ValidationResult::failure("Reader surname cannot be empty");
    }
    if (!Domain::isValidId(reader.id)) {
        return ValidationResult::failure("Reader ID cannot be empty");
    }
    if (reader.grade < 0) {
        return ValidationResult::failure("Reader grade cannot be negative");
    }
    if (trim(reader.studentId).empty()) {
        return ValidationResult::failure("Reader student ID cannot be empty");
    }
    return ValidationResult::success();
}

ValidationResult validateLoanDTO(const DTO::LoanDTO& loan) {
    if (!Domain::isValidId(loan.id)) {
        return ValidationResult::failure("Loan ID cannot be empty");
    }
    if (!Domain::isValidId(loan.bookId)) {
        return ValidationResult::failure("Loan book ID cannot be empty");
    }
    if (!Domain::isValidId(loan.readerId)) {
        return ValidationResult::failure("Loan reader ID cannot be empty");
    }
    if (trim(loan.loanDate).empty()) {
        return ValidationResult::failure("Loan date cannot be empty");
    }
    if (trim(loan.dueDate).empty()) {
        return ValidationResult::failure("Loan due date cannot be empty");
    }
    if (trim(loan.status).empty()) {
        return ValidationResult::failure("Loan status cannot be empty");
    }
    if (loan.status != "active" && loan.status != "returned" && loan.status != "overdue") {
        return ValidationResult::failure("Loan status must be 'active', 'returned', or 'overdue'");
    }
    if (!trim(loan.returnDate).empty() && loan.status == "active") {
        return ValidationResult::failure("Active loan cannot have a return date");
    }
    if (trim(loan.returnDate).empty() && loan.status == "returned") {
        return ValidationResult::failure("Returned loan must have a return date");
    }
    return ValidationResult::success();
}

ValidationResult validateCategoryDTO(const DTO::CategoryDTO& category) {
    if (trim(category.name).empty()) {
        return ValidationResult::failure("Category name cannot be empty");
    }
    if (!Domain::isValidId(category.id)) {
        return ValidationResult::failure("Category ID cannot be empty");
    }
    return ValidationResult::success();
}

ValidationResult validateLocationDTO(const DTO::LocationDTO& location) {
    if (trim(location.name).empty()) {
        return ValidationResult::failure("Location name cannot be empty");
    }
    if (!Domain::isValidId(location.id)) {
        return ValidationResult::failure("Location ID cannot be empty");
    }
    return ValidationResult::success();
}

ValidationResult validateUserDTO(const DTO::UserDTO& user) {
    if (trim(user.username).empty()) {
        return ValidationResult::failure("Username cannot be empty");
    }
    if (trim(user.password).empty()) {
        return ValidationResult::failure("Password cannot be empty");
    }
    if (user.username.length() < 3) {
        return ValidationResult::failure("Username must be at least 3 characters");
    }
    if (user.password.length() < 8) {
        return ValidationResult::failure("Password must be at least 8 characters");
    }
    if (user.username == user.password) {
        return ValidationResult::failure("Username and password cannot be the same");
    }
    if (!user.role.has_value()) {
        return ValidationResult::failure("Role must be selected");
    }
    return ValidationResult::success();
}

// ============ CRUD: validate then persist ============

ValidationResult addBook(DataAccess::IDataAccess& db, const DTO::BookDTO& book) {
    auto validation = validateBookDTO(book);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Book domainBook = book.toDomain();
    if (db.addBook(domainBook)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to add book to database");
}

ValidationResult addReader(DataAccess::IDataAccess& db, const DTO::ReaderDTO& reader) {
    auto validation = validateReaderDTO(reader);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Reader domainReader = reader.toDomain();
    if (db.addReader(domainReader)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to add reader to database");
}

ValidationResult addCategory(DataAccess::IDataAccess& db, const DTO::CategoryDTO& category) {
    auto validation = validateCategoryDTO(category);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Category domainCategory = category.toDomain();
    if (db.addCategory(domainCategory)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to add category to database");
}

ValidationResult addLocation(DataAccess::IDataAccess& db, const DTO::LocationDTO& location) {
    auto validation = validateLocationDTO(location);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Location domainLocation = location.toDomain();
    if (db.addLocation(domainLocation)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to add location to database");
}

ValidationResult addLoan(DataAccess::IDataAccess& /*db*/, const DTO::LoanDTO& loan) {
    auto validation = validateLoanDTO(loan);
    if (!validation.isValid) {
        return validation;
    }
    return ValidationResult::failure("Loan creation not implemented - use loanBook method");
}

ValidationResult addUser(DataAccess::IDataAccess& db, const DTO::UserDTO& user) {
    qDebug() << "[BL addUser] validating...";
    auto validation = validateUserDTO(user);
    if (!validation.isValid) {
        qDebug() << "[BL addUser] validation FAILED:" << QString::fromStdString(validation.errorMessage);
        return validation;
    }
    qDebug() << "[BL addUser] validation OK, converting to domain...";
    Domain::User domainUser = user.toDomain();
    qDebug() << "[BL addUser] calling db.addUser...";
    if (db.addUser(domainUser)) {
        qDebug() << "[BL addUser] SUCCESS";
        return ValidationResult::success();
    }
    qDebug() << "[BL addUser] db.addUser FAILED";
    return ValidationResult::failure("Failed to register user");
}

ValidationResult updateBook(DataAccess::IDataAccess& db, const DTO::BookDTO& book) {
    auto validation = validateBookDTO(book);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Book domainBook = book.toDomain();
    if (db.updateBook(domainBook)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to update book in database");
}

ValidationResult updateReader(DataAccess::IDataAccess& db, const DTO::ReaderDTO& reader) {
    auto validation = validateReaderDTO(reader);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Reader domainReader = reader.toDomain();
    if (db.updateReader(domainReader)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to update reader in database");
}

ValidationResult updateCategory(DataAccess::IDataAccess& db, const DTO::CategoryDTO& category) {
    auto validation = validateCategoryDTO(category);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Category domainCategory = category.toDomain();
    if (db.updateCategory(domainCategory)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to update category in database");
}

ValidationResult updateLocation(DataAccess::IDataAccess& db, const DTO::LocationDTO& location) {
    auto validation = validateLocationDTO(location);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Location domainLocation = location.toDomain();
    if (db.updateLocation(domainLocation)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to update location in database");
}

ValidationResult updateLoan(DataAccess::IDataAccess& /*db*/, const DTO::LoanDTO& loan) {
    auto validation = validateLoanDTO(loan);
    if (!validation.isValid) {
        return validation;
    }
    return ValidationResult::failure("Loan update not implemented");
}

// ============ Database ============

DatabaseValidationResult validateDatabases(DataAccess::IDataAccess& db) {
    if (!db.isConnected()) {
        return DatabaseValidationResult::failure("No database connection established");
    }
    return DatabaseValidationResult::success();
}

// ============ Role check ============

RoleCheckResult checkUserRole(const std::optional<Domain::User>& currentUser, RequiredRole required) {
    if (!currentUser.has_value()) {
        return RoleCheckResult::failure("No user logged in");
    }
    int userRole = static_cast<int>(currentUser->role);
    return checkUserRole(userRole, required);
}

RoleCheckResult checkUserRole(int userRoleInt, RequiredRole required) {
    int requiredRole = static_cast<int>(required);
    if (userRoleInt < requiredRole) {
        std::string roleName;
        switch (required) {
            case RequiredRole::Admin: roleName = "Admin"; break;
            case RequiredRole::SuperAdmin: roleName = "SuperAdmin"; break;
            default: roleName = "Unknown"; break;
        }
        return RoleCheckResult::failure("Access denied. Requires " + roleName + " role or higher.");
    }
    return RoleCheckResult::success();
}

// ============ Authentication ============

std::optional<Domain::User> login(DataAccess::IDataAccess& db, const std::string& username, const std::string& password) {
    qDebug() << "[BL login] looking up user:" << QString::fromStdString(username);
    auto userOpt = db.getUserByUsername(username);
    if (!userOpt.has_value()) {
        qDebug() << "[BL login] user not found";
        return std::nullopt;
    }
    qDebug() << "[BL login] user found, role:" << static_cast<int>(userOpt->role) << "comparing passwords...";
    if (userOpt->passwordHash == password) {
        qDebug() << "[BL login] password match - SUCCESS";
        return userOpt;
    }
    qDebug() << "[BL login] password mismatch - FAILED";
    return std::nullopt;
}

} // namespace BusinessLogic
