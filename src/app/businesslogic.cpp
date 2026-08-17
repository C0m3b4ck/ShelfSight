#include "businesslogic.h"
#include "domain.h"
#include <dataaccesslayer.h>
#include <QDateTime>

namespace BusinessLogic {

ValidationResult validateBookDTO_ID(const DTO::BookDTO& book)
{
    if (book.id.trimmed().isEmpty())
    {
        return ValidationResult::failure("ID cannot be empty");
    }
    else
    {
        if (does_id_exist())
        {
            return ValidationResult::success();
        }
        else
        {
            return ValidationResult::failure("Did not find ID in database!");
        }
    }
}

ValidationResult validateBookDTO(const DTO::BookDTO& book) {
    if (book.title.trimmed().isEmpty()) {
        return ValidationResult::failure("Book title cannot be empty");
    }
    if (book.author.trimmed().isEmpty()) {
        return ValidationResult::failure("Book author cannot be empty");
    }
    if (book.id.trimmed().isEmpty()) {
        return ValidationResult::failure("Book ID must be greater than 0");
    }
    if (book.location.trimmed().isEmpty()) {
        return ValidationResult::failure("Book location cannot be empty");
    }
    if (book.category.trimmed().isEmpty()) {
        return ValidationResult::failure("Book category cannot be empty");
    }
    if (book.status.trimmed().isEmpty()) {
        return ValidationResult::failure("Book status cannot be empty");
    }
    return ValidationResult::success();
}

ValidationResult validateReaderDTO(const DTO::ReaderDTO& reader) {
    if (reader.name.trimmed().isEmpty()) {
        return ValidationResult::failure("Reader name cannot be empty");
    }
    if (reader.surname.trimmed().isEmpty()) {
        return ValidationResult::failure("Reader surname cannot be empty");
    }
    if (reader.id.trimmed().isEmpty()) {
        return ValidationResult::failure("Reader ID must be greater than 0");
    }
    if (reader.grade < 0) {
        return ValidationResult::failure("Reader grade cannot be negative");
    }
    if (reader.classGroup.isNull()) {
        return ValidationResult::failure("Reader class group cannot be empty");
    }
    if (reader.studentId.trimmed().isEmpty()) {
        return ValidationResult::failure("Reader student ID cannot be empty");
    }
    return ValidationResult::success();
}

ValidationResult validateLoanDTO(const DTO::LoanDTO& loan) {
    if (loan.id.trimmed().isEmpty()) {
        return ValidationResult::failure("Loan ID must be greater than 0");
    }
    if (loan.bookId.trimmed().isEmpty()) {
        return ValidationResult::failure("Loan book ID must be greater than 0");
    }
    if (loan.readerId.trimmed().isEmpty()) {
        return ValidationResult::failure("Loan reader ID must be greater than 0");
    }
    if (loan.loanDate.trimmed().isEmpty()) {
        return ValidationResult::failure("Loan date cannot be empty");
    }
    if (loan.dueDate.trimmed().isEmpty()) {
        return ValidationResult::failure("Loan due date cannot be empty");
    }
    if (loan.status.trimmed().isEmpty()) {
        return ValidationResult::failure("Loan status cannot be empty");
    }
    if (loan.status != "active" && loan.status != "returned" && loan.status != "overdue") {
        return ValidationResult::failure("Loan status must be 'active', 'returned', or 'overdue'");
    }
    if (!loan.returnDate.trimmed().isEmpty() && loan.status == "active") {
        return ValidationResult::failure("Active loan cannot have a return date");
    }
    if (loan.returnDate.trimmed().isEmpty() && loan.status == "returned") {
        return ValidationResult::failure("Returned loan must have a return date");
    }
    return ValidationResult::success();
}

ValidationResult validateCategoryDTO(const DTO::CategoryDTO& category) {
    if (category.name.trimmed().isEmpty()) {
        return ValidationResult::failure("Category name cannot be empty");
    }
    return ValidationResult::success();
}

ValidationResult validateLocationDTO(const DTO::LocationDTO& location) {
    if (location.name.trimmed().isEmpty()) {
        return ValidationResult::failure("Location name cannot be empty");
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
    // For loans, we use the service's loanBook method which creates the loan
    //if (service.loanBook(loan.bookId, loan.readerId, loan.dueDate.toInt())) {
    //    return ValidationResult::success();
    //}
    return ValidationResult::failure("Failed to add loan to database");
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
    // For loans, update would need a new service method
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

} // namespace BusinessLogic