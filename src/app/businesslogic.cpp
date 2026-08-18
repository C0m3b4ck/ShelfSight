#include "businesslogic.h"
#include "domain.h"
#include <dataaccesslayer.h>
#include <algorithm>
#include <cctype>

namespace BusinessLogic {

static std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(" \t\n\r");
    if (first == std::string::npos) return "";
    size_t last = str.find_last_not_of(" \t\n\r");
    return str.substr(first, last - first + 1);
}

ValidationResult validateBookDTO(const DTO::BookDTO& book) {
    if (trim(book.title).empty()) {
        return ValidationResult::failure("Book title cannot be empty");
    }
    if (trim(book.author).empty()) {
        return ValidationResult::failure("Book author cannot be empty");
    }
    if (book.id <= 0) {
        return ValidationResult::failure("Book ID must be greater than 0");
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
    if (reader.id <= 0) {
        return ValidationResult::failure("Reader ID must be greater than 0");
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
    if (loan.id <= 0) {
        return ValidationResult::failure("Loan ID must be greater than 0");
    }
    if (loan.bookId <= 0) {
        return ValidationResult::failure("Loan book ID must be greater than 0");
    }
    if (loan.readerId <= 0) {
        return ValidationResult::failure("Loan reader ID must be greater than 0");
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
    return ValidationResult::success();
}

ValidationResult validateLocationDTO(const DTO::LocationDTO& location) {
    if (trim(location.name).empty()) {
        return ValidationResult::failure("Location name cannot be empty");
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
    if (!user.role.has_value()) {
        return ValidationResult::failure("Role must be selected");
    }
    return ValidationResult::success();
}

ValidationResult addBook(IBookService& service, const DTO::BookDTO& book) {
    auto validation = validateBookDTO(book);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Book domainBook = book.toDomain();
    if (service.addBook(domainBook)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to add book to database");
}

ValidationResult addReader(IReaderService& service, const DTO::ReaderDTO& reader) {
    auto validation = validateReaderDTO(reader);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Reader domainReader = reader.toDomain();
    if (service.addReader(domainReader)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to add reader to database");
}

ValidationResult addCategory(ICategoryService& service, const DTO::CategoryDTO& category) {
    auto validation = validateCategoryDTO(category);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Category domainCategory = category.toDomain();
    if (service.addCategory(domainCategory)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to add category to database");
}

ValidationResult addLocation(ILocationService& service, const DTO::LocationDTO& location) {
    auto validation = validateLocationDTO(location);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Location domainLocation = location.toDomain();
    if (service.addLocation(domainLocation)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to add location to database");
}

ValidationResult addLoan(ILoanService& service, const DTO::LoanDTO& loan) {
    auto validation = validateLoanDTO(loan);
    if (!validation.isValid) {
        return validation;
    }
    return ValidationResult::failure("Loan creation not implemented - use loanBook method");
}

ValidationResult addUser(IUserService& service, const DTO::UserDTO& user) {
    auto validation = validateUserDTO(user);
    if (!validation.isValid) {
        return validation;
    }
    if (service.registerUser(user)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to register user");
}

ValidationResult updateBook(IBookService& service, const DTO::BookDTO& book) {
    auto validation = validateBookDTO(book);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Book domainBook = book.toDomain();
    if (service.updateBook(domainBook)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to update book in database");
}

ValidationResult updateReader(IReaderService& service, const DTO::ReaderDTO& reader) {
    auto validation = validateReaderDTO(reader);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Reader domainReader = reader.toDomain();
    if (service.updateReader(domainReader)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to update reader in database");
}

ValidationResult updateCategory(ICategoryService& service, const DTO::CategoryDTO& category) {
    auto validation = validateCategoryDTO(category);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Category domainCategory = category.toDomain();
    if (service.updateCategory(domainCategory)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to update category in database");
}

ValidationResult updateLocation(ILocationService& service, const DTO::LocationDTO& location) {
    auto validation = validateLocationDTO(location);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Location domainLocation = location.toDomain();
    if (service.updateLocation(domainLocation)) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("Failed to update location in database");
}

ValidationResult updateLoan(ILoanService& service, const DTO::LoanDTO& loan) {
    auto validation = validateLoanDTO(loan);
    if (!validation.isValid) {
        return validation;
    }
    Domain::Loan domainLoan = loan.toDomain();
    return ValidationResult::failure("Loan update not implemented");
}

DatabaseValidationResult validateDatabases(const IDatabaseManager& dbManager, bool requireBooks, bool requireReaders, bool requireLoans) {
    if (!dbManager.isConnected()) {
        return DatabaseValidationResult::failure("No database connection established");
    }

    bool booksOk = !requireBooks || dbManager.isBooksDbSelected();
    bool readersOk = !requireReaders || dbManager.isReadersDbSelected();
    bool loansOk = !requireLoans || dbManager.isLoansDbSelected();

    if (!booksOk && requireBooks) {
        return DatabaseValidationResult::failure("Book database not selected", false, readersOk, loansOk);
    }
    if (!readersOk && requireReaders) {
        return DatabaseValidationResult::failure("Reader database not selected", booksOk, false, loansOk);
    }
    if (!loansOk && requireLoans) {
        return DatabaseValidationResult::failure("Loan database not selected", booksOk, readersOk, false);
    }

    return DatabaseValidationResult::success();
}

// Role-based access control
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

// ID checking
ValidationResult checkIdExists(const std::string& dbType, int id) {
    auto& facade = BusinessLogicFacade::instance();
    if (!facade.db || !facade.db->isConnected()) {
        return ValidationResult::failure("Database not connected");
    }

    bool exists = false;
    if (dbType == "books" && facade.books) {
        auto book = facade.books->getBookById(id);
        exists = book.has_value();
    } else if (dbType == "readers" && facade.readers) {
        auto reader = facade.readers->getReaderById(id);
        exists = reader.has_value();
    } else if (dbType == "categories" && facade.categories) {
        auto categories = facade.categories->getAllCategories();
        exists = std::any_of(categories.begin(), categories.end(), [id](const Domain::Category& c) { return c.id == id; });
    } else if (dbType == "locations" && facade.locations) {
        auto locations = facade.locations->getAllLocations();
        exists = std::any_of(locations.begin(), locations.end(), [id](const Domain::Location& l) { return l.id == id; });
    } else if (dbType == "users" && facade.users) {
        auto users = facade.users->getAllUsers();
        exists = std::any_of(users.begin(), users.end(), [id](const Domain::User& u) { return u.id == id; });
    } else if (dbType == "loans" && facade.loans) {
        // For loans, we'd need a getLoanById method
        exists = false;
    }

    if (exists) {
        return ValidationResult::success();
    }
    return ValidationResult::failure("ID " + std::to_string(id) + " not found in " + dbType);
}

ValidationResult checkIdNotExists(const std::string& dbType, int id) {
    auto result = checkIdExists(dbType, id);
    if (result.isValid) {
        return ValidationResult::failure("ID " + std::to_string(id) + " already exists in " + dbType);
    }
    return ValidationResult::success();
}

// Listbox population
std::vector<ListItem> populateList(const std::string& entityType, const std::string& searchTerm, const std::string& filterField) {
    auto& facade = BusinessLogicFacade::instance();
    if (!facade.db || !facade.db->isConnected()) {
        return {};
    }

    std::vector<ListItem> items;

    if (entityType == "books" && facade.books) {
        std::vector<Domain::Book> books;
        if (searchTerm.empty()) {
            books = facade.books->getAllBooks();
        } else {
            books = facade.books->searchBooks(searchTerm, filterField);
        }
        for (const auto& book : books) {
            items.push_back({book.id, book.toDisplayString(), ""});
        }
    } else if (entityType == "readers" && facade.readers) {
        std::vector<Domain::Reader> readers;
        if (searchTerm.empty()) {
            readers = facade.readers->getAllReaders();
        } else {
            readers = facade.readers->searchReaders(searchTerm, filterField);
        }
        for (const auto& reader : readers) {
            items.push_back({reader.id, reader.toDisplayString(), ""});
        }
    } else if (entityType == "categories" && facade.categories) {
        auto categories = facade.categories->getAllCategories();
        for (const auto& cat : categories) {
            items.push_back({cat.id, cat.name, ""});
        }
    } else if (entityType == "locations" && facade.locations) {
        auto locations = facade.locations->getAllLocations();
        for (const auto& loc : locations) {
            items.push_back({loc.id, loc.name, ""});
        }
    } else if (entityType == "users" && facade.users) {
        auto users = facade.users->getAllUsers();
        for (const auto& user : users) {
            items.push_back({user.id, user.username + " | " + std::to_string(static_cast<int>(user.role)), ""});
        }
    } else if (entityType == "loans" && facade.loans) {
        std::vector<Domain::Loan> loans;
        if (searchTerm.empty()) {
            loans = facade.loans->getActiveLoans();
        } else {
            // Use active loans as base, filter manually
            loans = facade.loans->getActiveLoans();
        }
        for (const auto& loan : loans) {
            items.push_back({loan.id, loan.toDisplayString(), ""});
        }
    }

    return items;
}

std::vector<ListItem> populateListWithDb(const std::string& dbName, const std::string& entityType, const std::string& searchTerm, const std::string& filterField) {
    // For now, ignore dbName and use facade
    (void)dbName; // suppress unused warning
    return populateList(entityType, searchTerm, filterField);
}

} // namespace BusinessLogic