#include "businesslogic.h"
#include "sqlite_dataaccess.h"
#include <iostream>
#include <cassert>
#include <cstdlib>

static int passed = 0;
static int failed = 0;

#define TEST(name) std::cout << "\n=== " << name << " ===" << std::endl;
#define CHECK(cond, msg) do { \
    if (cond) { std::cout << "  PASS: " << msg << std::endl; passed++; } \
    else { std::cout << "  FAIL: " << msg << std::endl; failed++; } \
} while(0)

void cleanup_test_dbs() {
    std::remove("test_books.db");
    std::remove("test_readers.db");
    std::remove("test_loans.db");
    std::remove("test_users.db");
}

int main() {
    cleanup_test_dbs();

    auto& db = DataAccess::SQLiteDataAccess::instance();

    // Use separate DB files for testing
    // We need a fresh instance, but the singleton is already created.
    // So we re-initialize with test DB paths.
    db.initialize("test_books.db", "test_readers.db", "test_loans.db", "test_users.db");

    // =============================================
    TEST("1. USER REGISTRATION")
    // =============================================
    {
        DTO::UserDTO user;
        user.username = "admin";
        user.password = "secret123";
        user.role = Domain::User::Role::Admin;

        auto result = BusinessLogic::addUser(db, user);
        CHECK(result.isValid, "Register admin user");

        // Duplicate should fail (UNIQUE constraint)
        DTO::UserDTO dup;
        dup.username = "admin";
        dup.password = "other456";
        dup.role = Domain::User::Role::UserRole;

        auto dupResult = BusinessLogic::addUser(db, dup);
        CHECK(!dupResult.isValid, "Duplicate username rejected");

        // Register a normal user
        DTO::UserDTO normalUser;
        normalUser.username = "librarian";
        normalUser.password = "pass1234";
        normalUser.role = Domain::User::Role::UserRole;

        auto normalResult = BusinessLogic::addUser(db, normalUser);
        CHECK(normalResult.isValid, "Register normal user");
    }

    // =============================================
    TEST("2. USER LOGIN")
    // =============================================
    {
        auto user = BusinessLogic::login(db, "admin", "secret123");
        CHECK(user.has_value(), "Login with correct password");
        CHECK(user->username == "admin", "Correct username returned");
        CHECK(static_cast<int>(user->role) == 2, "Correct role (Admin=2)");

        auto badPass = BusinessLogic::login(db, "admin", "wrongpassword");
        CHECK(!badPass.has_value(), "Reject wrong password");

        auto noUser = BusinessLogic::login(db, "nonexistent", "anything");
        CHECK(!noUser.has_value(), "Reject nonexistent user");
    }

    // =============================================
    TEST("3. ADD CATEGORY")
    // =============================================
    {
        DTO::CategoryDTO cat;
        cat.id = "1";
        cat.name = "Fiction";

        auto result = BusinessLogic::addCategory(db, cat);
        CHECK(result.isValid, "Add category 'Fiction'");

        DTO::CategoryDTO cat2;
        cat2.id = "2";
        cat2.name = "Science";

        auto result2 = BusinessLogic::addCategory(db, cat2);
        CHECK(result2.isValid, "Add category 'Science'");

        // Verify categories exist
        auto allCats = db.getAllCategories();
        CHECK(allCats.size() == 2, "Two categories in database");
    }

    // =============================================
    TEST("4. ADD LOCATION")
    // =============================================
    {
        DTO::LocationDTO loc;
        loc.id = "1";
        loc.name = "Shelf A";

        auto result = BusinessLogic::addLocation(db, loc);
        CHECK(result.isValid, "Add location 'Shelf A'");

        DTO::LocationDTO loc2;
        loc2.id = "2";
        loc2.name = "Shelf B";

        auto result2 = BusinessLogic::addLocation(db, loc2);
        CHECK(result2.isValid, "Add location 'Shelf B'");
    }

    // =============================================
    TEST("5. ADD BOOK")
    // =============================================
    {
        DTO::BookDTO book;
        book.id = "1001";
        book.title = "The Great Gatsby";
        book.author = "F. Scott Fitzgerald";
        book.location = "Shelf A";
        book.category = "Fiction";
        book.status = "Available";
        book.createdAt = Domain::toISOString(Domain::now());
        book.updatedAt = Domain::toISOString(Domain::now());

        auto result = BusinessLogic::addBook(db, book);
        CHECK(result.isValid, "Add book 'The Great Gatsby'");

        // Add another book
        DTO::BookDTO book2;
        book2.id = "1002";
        book2.title = "A Brief History of Time";
        book2.author = "Stephen Hawking";
        book2.location = "Shelf B";
        book2.category = "Science";
        book2.status = "Available";
        book2.createdAt = Domain::toISOString(Domain::now());
        book2.updatedAt = Domain::toISOString(Domain::now());

        auto result2 = BusinessLogic::addBook(db, book2);
        CHECK(result2.isValid, "Add book 'A Brief History of Time'");

        // Verify books exist
        auto allBooks = db.getAllBooks();
        CHECK(allBooks.size() == 2, "Two books in database");

        auto foundBook = db.getBookById("1001");
        CHECK(foundBook.has_value(), "Find book by ID 1001");
        CHECK(foundBook->title == "The Great Gatsby", "Correct title");
        CHECK(foundBook->author == "F. Scott Fitzgerald", "Correct author");
    }

    // =============================================
    TEST("6. ADD READER")
    // =============================================
    {
        DTO::ReaderDTO reader;
        reader.id = "2001";
        reader.name = "John";
        reader.surname = "Doe";
        reader.grade = 10;
        reader.classGroup = 'A';
        reader.studentId = "STU001";
        reader.createdAt = Domain::toISOString(Domain::now());
        reader.updatedAt = Domain::toISOString(Domain::now());

        auto result = BusinessLogic::addReader(db, reader);
        CHECK(result.isValid, "Add reader 'John Doe'");

        // Add another reader
        DTO::ReaderDTO reader2;
        reader2.id = "2002";
        reader2.name = "Jane";
        reader2.surname = "Smith";
        reader2.grade = 11;
        reader2.classGroup = 'B';
        reader2.studentId = "STU002";
        reader2.createdAt = Domain::toISOString(Domain::now());
        reader2.updatedAt = Domain::toISOString(Domain::now());

        auto result2 = BusinessLogic::addReader(db, reader2);
        CHECK(result2.isValid, "Add reader 'Jane Smith'");

        // Verify readers exist
        auto allReaders = db.getAllReaders();
        CHECK(allReaders.size() == 2, "Two readers in database");

        auto foundReader = db.getReaderById("2001");
        CHECK(foundReader.has_value(), "Find reader by ID 2001");
        CHECK(foundReader->name == "John", "Correct name");
        CHECK(foundReader->surname == "Doe", "Correct surname");
    }

    // =============================================
    TEST("7. UPDATE BOOK")
    // =============================================
    {
        DTO::BookDTO updated;
        updated.id = "1001";
        updated.title = "The Great Gatsby (Updated)";
        updated.author = "F. Scott Fitzgerald";
        updated.location = "Shelf A";
        updated.category = "Fiction";
        updated.status = "Borrowed";
        updated.createdAt = Domain::toISOString(Domain::now());
        updated.updatedAt = Domain::toISOString(Domain::now());

        auto result = BusinessLogic::updateBook(db, updated);
        CHECK(result.isValid, "Update book 1001");

        auto foundBook = db.getBookById("1001");
        CHECK(foundBook.has_value(), "Book 1001 still exists");
        CHECK(foundBook->title == "The Great Gatsby (Updated)", "Title updated");
        CHECK(foundBook->status == "Borrowed", "Status updated");
    }

    // =============================================
    TEST("8. UPDATE READER")
    // =============================================
    {
        DTO::ReaderDTO updated;
        updated.id = "2001";
        updated.name = "John";
        updated.surname = "Doe";
        updated.grade = 11;
        updated.classGroup = 'B';
        updated.studentId = "STU001";
        updated.createdAt = Domain::toISOString(Domain::now());
        updated.updatedAt = Domain::toISOString(Domain::now());

        auto result = BusinessLogic::updateReader(db, updated);
        CHECK(result.isValid, "Update reader 2001");

        auto foundReader = db.getReaderById("2001");
        CHECK(foundReader.has_value(), "Reader 2001 still exists");
        CHECK(foundReader->grade == 11, "Grade updated to 11");
    }

    // =============================================
    TEST("9. LOAN BOOK")
    // =============================================
    {
        // Reset book status to Available first
        DTO::BookDTO bookReset;
        bookReset.id = "1001";
        bookReset.title = "The Great Gatsby (Updated)";
        bookReset.author = "F. Scott Fitzgerald";
        bookReset.location = "Shelf A";
        bookReset.category = "Fiction";
        bookReset.status = "Available";
        bookReset.createdAt = Domain::toISOString(Domain::now());
        bookReset.updatedAt = Domain::toISOString(Domain::now());
        db.updateBook(bookReset.toDomain());

        bool loanResult = db.loanBook("1001", "2001", 14);
        CHECK(loanResult, "Loan book 1001 to reader 2001 for 14 days");

        auto activeLoans = db.getActiveLoans();
        CHECK(activeLoans.size() == 1, "One active loan");
        CHECK(activeLoans[0].bookId == "1001", "Loan book ID correct");
        CHECK(activeLoans[0].readerId == "2001", "Loan reader ID correct");
        CHECK(activeLoans[0].status == "active", "Loan status is active");

        // Verify book status changed
        auto bookAfter = db.getBookById("1001");
        CHECK(bookAfter.has_value(), "Book still exists after loan");
    }

    // =============================================
    TEST("10. RETURN BOOK")
    // =============================================
    {
        auto activeLoans = db.getActiveLoans();
        CHECK(activeLoans.size() == 1, "Still one active loan before return");

        bool returnResult = db.returnBook(activeLoans[0].id);
        CHECK(returnResult, "Return the loan");

        auto activeLoansAfter = db.getActiveLoans();
        CHECK(activeLoansAfter.size() == 0, "No active loans after return");
    }

    // =============================================
    TEST("11. SEARCH BOOKS")
    // =============================================
    {
        auto results = db.searchBooks("Gatsby", "title");
        CHECK(results.size() >= 1, "Search for 'Gatsby' returns results");
        CHECK(results[0].title.find("Gatsby") != std::string::npos, "Result contains 'Gatsby'");

        auto authorResults = db.searchBooks("Hawking", "author");
        CHECK(authorResults.size() == 1, "Search for author 'Hawking' returns 1 result");
    }

    // =============================================
    TEST("12. SEARCH READERS")
    // =============================================
    {
        auto results = db.searchReaders("John", "name");
        CHECK(results.size() == 1, "Search for 'John' returns 1 result");
        CHECK(results[0].name == "John", "Correct reader found");

        auto surnameResults = db.searchReaders("Smith", "surname");
        CHECK(surnameResults.size() == 1, "Search for surname 'Smith' returns 1 result");
    }

    // =============================================
    TEST("13. VALIDATION - EMPTY BOOK TITLE")
    // =============================================
    {
        DTO::BookDTO badBook;
        badBook.id = "9999";
        badBook.title = "";
        badBook.author = "Someone";
        badBook.location = "Shelf A";
        badBook.category = "Fiction";
        badBook.status = "Available";

        auto result = BusinessLogic::addBook(db, badBook);
        CHECK(!result.isValid, "Reject book with empty title");
        CHECK(result.errorMessage.find("title") != std::string::npos, "Error mentions 'title'");
    }

    // =============================================
    TEST("14. VALIDATION - EMPTY READER NAME")
    // =============================================
    {
        DTO::ReaderDTO badReader;
        badReader.id = "9999";
        badReader.name = "";
        badReader.surname = "Doe";
        badReader.grade = 10;
        badReader.classGroup = 'A';
        badReader.studentId = "STU999";

        auto result = BusinessLogic::addReader(db, badReader);
        CHECK(!result.isValid, "Reject reader with empty name");
    }

    // =============================================
    TEST("15. VALIDATION - EMPTY CATEGORY NAME")
    // =============================================
    {
        DTO::CategoryDTO badCat;
        badCat.id = "99";
        badCat.name = "";

        auto result = BusinessLogic::addCategory(db, badCat);
        CHECK(!result.isValid, "Reject category with empty name");
    }

    // =============================================
    TEST("16. VALIDATION - EMPTY LOCATION NAME")
    // =============================================
    {
        DTO::LocationDTO badLoc;
        badLoc.id = "99";
        badLoc.name = "";

        auto result = BusinessLogic::addLocation(db, badLoc);
        CHECK(!result.isValid, "Reject location with empty name");
    }

    // =============================================
    TEST("17. ROLE CHECK")
    // =============================================
    {
        Domain::User normalUser;
        normalUser.username = "test";
        normalUser.role = Domain::User::Role::UserRole;

        auto adminCheck = BusinessLogic::checkUserRole(normalUser, BusinessLogic::RequiredRole::Admin);
        CHECK(!adminCheck.hasAccess, "Normal user denied Admin access");

        auto userCheck = BusinessLogic::checkUserRole(normalUser, BusinessLogic::RequiredRole::None);
        CHECK(userCheck.hasAccess, "Normal user allowed None access");

        Domain::User adminUser;
        adminUser.username = "admin";
        adminUser.role = Domain::User::Role::Admin;

        auto adminAccess = BusinessLogic::checkUserRole(adminUser, BusinessLogic::RequiredRole::Admin);
        CHECK(adminAccess.hasAccess, "Admin user allowed Admin access");

        auto superAdminCheck = BusinessLogic::checkUserRole(adminUser, BusinessLogic::RequiredRole::SuperAdmin);
        CHECK(!superAdminCheck.hasAccess, "Admin denied SuperAdmin access");
    }

    // =============================================
    TEST("18. DATABASE VALIDATION")
    // =============================================
    {
        auto result = BusinessLogic::validateDatabases(db);
        CHECK(result.isValid, "Connected database passes validation");
    }

    // =============================================
    TEST("19. REMOVE BOOK")
    // =============================================
    {
        bool removed = db.removeBook("1002");
        CHECK(removed, "Remove book 1002");

        auto allBooks = db.getAllBooks();
        CHECK(allBooks.size() == 1, "One book remaining after removal");

        auto removedBooks = db.getRemovedBooks();
        CHECK(removedBooks.size() >= 1, "Removed book appears in removed_books");
    }

    // =============================================
    TEST("20. RESTORE BOOK")
    // =============================================
    {
        bool restored = db.restoreBook("1002");
        CHECK(restored, "Restore book 1002");

        auto allBooks = db.getAllBooks();
        CHECK(allBooks.size() == 2, "Two books after restore");
    }

    // =============================================
    TEST("21. REMOVE READER")
    // =============================================
    {
        bool removed = db.removeReader("2002");
        CHECK(removed, "Remove reader 2002");

        auto allReaders = db.getAllReaders();
        CHECK(allReaders.size() == 1, "One reader remaining after removal");

        auto removedReaders = db.getRemovedReaders();
        CHECK(removedReaders.size() >= 1, "Removed reader appears in removed_readers");
    }

    // =============================================
    TEST("22. RESTORE READER")
    // =============================================
    {
        bool restored = db.restoreReader("2002");
        CHECK(restored, "Restore reader 2002");

        auto allReaders = db.getAllReaders();
        CHECK(allReaders.size() == 2, "Two readers after restore");
    }

    // =============================================
    TEST("23. POPULATE LIST")
    // =============================================
    {
        auto bookItems = db.populateList("books");
        CHECK(bookItems.size() == 2, "Populate books list shows 2 items");

        auto readerItems = db.populateList("readers");
        CHECK(readerItems.size() == 2, "Populate readers list shows 2 items");

        auto catItems = db.populateList("categories");
        CHECK(catItems.size() == 2, "Populate categories list shows 2 items");

        auto locItems = db.populateList("locations");
        CHECK(locItems.size() == 2, "Populate locations list shows 2 items");
    }

    // =============================================
    TEST("24. CHECK ID EXISTS")
    // =============================================
    {
        CHECK(db.checkIdExists("books", "1001"), "Book ID 1001 exists");
        CHECK(!db.checkIdExists("books", "9999"), "Book ID 9999 does not exist");
        CHECK(db.checkIdExists("readers", "2001"), "Reader ID 2001 exists");
        CHECK(!db.checkIdExists("readers", "9999"), "Reader ID 9999 does not exist");

        auto allCats = db.getAllCategories();
        CHECK(!allCats.empty() && db.checkIdExists("categories", allCats[0].id), "Category first ID exists");

        auto allLocs = db.getAllLocations();
        CHECK(!allLocs.empty() && db.checkIdExists("locations", allLocs[0].id), "Location first ID exists");

        auto allUsers = db.getAllUsers();
        CHECK(!allUsers.empty() && db.checkIdExists("users", allUsers[0].id), "User first ID exists");

        CHECK(!db.checkIdExists("categories", "9999"), "Category ID 9999 does not exist");
        CHECK(!db.checkIdExists("locations", "9999"), "Location ID 9999 does not exist");
        CHECK(!db.checkIdExists("users", "9999"), "User ID 9999 does not exist");
    }

    // =============================================
    // SUMMARY
    // =============================================
    std::cout << "\n========================================" << std::endl;
    std::cout << "RESULTS: " << passed << " passed, " << failed << " failed" << std::endl;
    std::cout << "========================================" << std::endl;

    db.shutdown();
    cleanup_test_dbs();

    return failed > 0 ? 1 : 0;
}
