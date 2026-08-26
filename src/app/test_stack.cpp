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

std::string nowStr() { return Domain::toISOString(Domain::now()); }

int main() {
    cleanup_test_dbs();

    auto& db = DataAccess::SQLiteDataAccess::instance();
    db.initialize("test_books.db", "test_readers.db", "test_loans.db", "test_users.db");

    std::optional<Domain::User> currentUser;

    // =============================================================
    //  DAY 1 — SUPERADMIN FIRST LOGIN
    // =============================================================

    TEST("1. REGISTRATION — Create superadmin account");
    {
        DTO::UserDTO sa;
        sa.username = "superadmin";
        sa.password = "MasterKey2026!";
        sa.role = Domain::User::Role::SuperAdmin;
        CHECK(BusinessLogic::addUser(db, sa).isValid, "Register superadmin");
        auto dup = BusinessLogic::addUser(db, sa);
        CHECK(!dup.isValid, "Duplicate superadmin rejected");
    }

    TEST("2. REGISTRATION — Create librarian account");
    {
        DTO::UserDTO lib;
        lib.username = "librarian";
        lib.password = "LibPass123!";
        lib.role = Domain::User::Role::UserRole;
        CHECK(BusinessLogic::addUser(db, lib).isValid, "Register librarian");
    }

    TEST("3. LOGIN — Superadmin logs in");
    {
        auto user = BusinessLogic::login(db, "superadmin", "MasterKey2026!");
        CHECK(user.has_value(), "Login succeeds");
        CHECK(user->username == "superadmin", "Username correct");
        CHECK(static_cast<int>(user->role) == 3, "Role is SuperAdmin");
        currentUser = user;
    }

    TEST("4. ROLE CHECK — Superadmin has full access");
    {
        CHECK(BusinessLogic::checkUserRole(currentUser, BusinessLogic::RequiredRole::SuperAdmin).hasAccess, "SuperAdmin role OK");
        CHECK(BusinessLogic::checkUserRole(currentUser, BusinessLogic::RequiredRole::Admin).hasAccess, "Admin role OK");
        CHECK(BusinessLogic::checkUserRole(currentUser, BusinessLogic::RequiredRole::None).hasAccess, "None role OK");
    }

    TEST("5. LOGIN — Wrong password rejected");
    {
        CHECK(!BusinessLogic::login(db, "superadmin", "wrong").has_value(), "Wrong password rejected");
        CHECK(!BusinessLogic::login(db, "nobody", "x").has_value(), "Nonexistent user rejected");
    }

    TEST("6. DB VALIDATION — Database connection live");
    {
        CHECK(BusinessLogic::validateDatabases(db).isValid, "Database validation passes");
    }

    // =============================================================
    //  DAY 2 — SETTING UP THE LIBRARY
    // =============================================================

    TEST("7. ADD CATEGORIES — Build catalog taxonomy");
    {
        DTO::CategoryDTO c1; c1.id = "cat_1"; c1.name = "Fiction";
        DTO::CategoryDTO c2; c2.id = "cat_2"; c2.name = "Science";
        DTO::CategoryDTO c3; c3.id = "cat_3"; c3.name = "History";
        DTO::CategoryDTO c4; c4.id = "cat_4"; c4.name = "Technology";
        DTO::CategoryDTO c5; c5.id = "cat_5"; c5.name = "Philosophy";

        CHECK(BusinessLogic::addCategory(db, c1).isValid, "Add 'Fiction'");
        CHECK(BusinessLogic::addCategory(db, c2).isValid, "Add 'Science'");
        CHECK(BusinessLogic::addCategory(db, c3).isValid, "Add 'History'");
        CHECK(BusinessLogic::addCategory(db, c4).isValid, "Add 'Technology'");
        CHECK(BusinessLogic::addCategory(db, c5).isValid, "Add 'Philosophy'");
        CHECK(db.getAllCategories().size() == 5, "5 categories exist");
    }

    TEST("8. EDIT CATEGORY — Rename 'Philosophy' to 'Arts & Philosophy'");
    {
        auto cats = db.getAllCategories();
        Domain::Category target;
        for (auto& c : cats) { if (c.name == "Philosophy") { target = c; break; } }

        DTO::CategoryDTO updated = DTO::CategoryDTO::fromDomain(target);
        updated.name = "Arts & Philosophy";
        CHECK(BusinessLogic::updateCategory(db, updated).isValid, "Rename succeeds");

        auto after = db.getAllCategories();
        bool found = false;
        for (auto& c : after) { if (c.name == "Arts & Philosophy") found = true; }
        CHECK(found, "New name 'Arts & Philosophy' found");
        bool oldGone = true;
        for (auto& c : after) { if (c.name == "Philosophy") oldGone = false; }
        CHECK(oldGone, "Old name 'Philosophy' gone");
    }

    TEST("9. REMOVE CATEGORY — Remove 'Arts & Philosophy'");
    {
        db.removeCategory("cat_5");
        auto cats = db.getAllCategories();
        CHECK(cats.size() == 4, "4 categories after removal");
        bool found = false;
        for (auto& c : cats) { if (c.name == "Arts & Philosophy") found = true; }
        CHECK(!found, "Removed category no longer listed");
    }

    TEST("10. ADD LOCATIONS — Set up shelf locations");
    {
        DTO::LocationDTO l1; l1.id = "loc_1"; l1.name = "Main Hall - Shelf A";
        DTO::LocationDTO l2; l2.id = "loc_2"; l2.name = "Main Hall - Shelf B";
        DTO::LocationDTO l3; l3.id = "loc_3"; l3.name = "Reference Section";
        DTO::LocationDTO l4; l4.id = "loc_4"; l4.name = "Digital Archive";

        CHECK(BusinessLogic::addLocation(db, l1).isValid, "Add 'Main Hall - Shelf A'");
        CHECK(BusinessLogic::addLocation(db, l2).isValid, "Add 'Main Hall - Shelf B'");
        CHECK(BusinessLogic::addLocation(db, l3).isValid, "Add 'Reference Section'");
        CHECK(BusinessLogic::addLocation(db, l4).isValid, "Add 'Digital Archive'");
        CHECK(db.getAllLocations().size() == 4, "4 locations exist");
    }

    TEST("11. EDIT LOCATION — Rename 'Digital Archive' to 'Online Collection'");
    {
        auto locs = db.getAllLocations();
        Domain::Location target;
        for (auto& l : locs) { if (l.name == "Digital Archive") { target = l; break; } }

        DTO::LocationDTO updated = DTO::LocationDTO::fromDomain(target);
        updated.name = "Online Collection";
        CHECK(BusinessLogic::updateLocation(db, updated).isValid, "Rename succeeds");

        auto after = db.getAllLocations();
        bool found = false;
        for (auto& l : after) { if (l.name == "Online Collection") found = true; }
        CHECK(found, "New name 'Online Collection' found");
    }

    TEST("12. REMOVE LOCATION — Remove 'Online Collection'");
    {
        db.removeLocation("loc_4");
        auto locs = db.getAllLocations();
        CHECK(locs.size() == 3, "3 locations after removal");
        bool found = false;
        for (auto& l : locs) { if (l.name == "Online Collection") found = true; }
        CHECK(!found, "Removed location no longer listed");
    }

    TEST("13. VALIDATION — Reject empty category/location names");
    {
        DTO::CategoryDTO badCat; badCat.id = "x"; badCat.name = "";
        CHECK(!BusinessLogic::addCategory(db, badCat).isValid, "Reject empty category name");
        DTO::LocationDTO badLoc; badLoc.id = "x"; badLoc.name = "";
        CHECK(!BusinessLogic::addLocation(db, badLoc).isValid, "Reject empty location name");
    }

    // =============================================================
    //  DAY 3 — POPULATING THE SHELVES
    // =============================================================

    TEST("14. ADD BOOKS — Stock the library");
    {
        auto mkBook = [](std::string id, std::string title, std::string author,
                         std::string loc, std::string cat) {
            DTO::BookDTO b;
            b.id = std::move(id); b.title = std::move(title); b.author = std::move(author);
            b.location = std::move(loc); b.category = std::move(cat); b.status = "Available";
            b.createdAt = nowStr(); b.updatedAt = nowStr();
            return b;
        };
        CHECK(BusinessLogic::addBook(db, mkBook("B001","The Great Gatsby","F. Scott Fitzgerald","Main Hall - Shelf A","Fiction")).isValid, "Add 'The Great Gatsby'");
        CHECK(BusinessLogic::addBook(db, mkBook("B002","A Brief History of Time","Stephen Hawking","Reference Section","Science")).isValid, "Add 'A Brief History of Time'");
        CHECK(BusinessLogic::addBook(db, mkBook("B003","Sapiens","Yuval Noah Harari","Main Hall - Shelf B","History")).isValid, "Add 'Sapiens'");
        CHECK(BusinessLogic::addBook(db, mkBook("B004","Clean Code","Robert C. Martin","Main Hall - Shelf A","Technology")).isValid, "Add 'Clean Code'");
        CHECK(BusinessLogic::addBook(db, mkBook("B005","1984","George Orwell","Main Hall - Shelf B","Fiction")).isValid, "Add '1984'");
        CHECK(BusinessLogic::addBook(db, mkBook("B006","The Art of War","Sun Tzu","Reference Section","History")).isValid, "Add 'The Art of War'");
        CHECK(BusinessLogic::addBook(db, mkBook("B007","Design Patterns","Gang of Four","Main Hall - Shelf A","Technology")).isValid, "Add 'Design Patterns'");
        CHECK(BusinessLogic::addBook(db, mkBook("B008","Cosmos","Carl Sagan","Reference Section","Science")).isValid, "Add 'Cosmos'");
        CHECK(db.getAllBooks().size() == 8, "8 books in catalog");
    }

    TEST("15. VALIDATION — Reject book with empty title or missing fields");
    {
        DTO::BookDTO b; b.id = "X"; b.title = ""; b.author = "Y"; b.location = "Main Hall - Shelf A"; b.category = "Fiction"; b.status = "Available";
        CHECK(!BusinessLogic::addBook(db, b).isValid, "Reject empty title");
        b.title = "Valid"; b.author = ""; b.category = "";
        CHECK(!BusinessLogic::addBook(db, b).isValid, "Reject empty author/category");
    }

    TEST("16. ADD READERS — Register library members");
    {
        auto mkReader = [](std::string id, std::string name, std::string surname, int grade, char cls, std::string sid) {
            DTO::ReaderDTO r;
            r.id = std::move(id); r.name = std::move(name); r.surname = std::move(surname);
            r.grade = grade; r.classGroup = cls; r.studentId = std::move(sid);
            r.createdAt = nowStr(); r.updatedAt = nowStr();
            return r;
        };
        CHECK(BusinessLogic::addReader(db, mkReader("R001","Alice","Johnson",10,'A',"STU001")).isValid, "Add 'Alice Johnson'");
        CHECK(BusinessLogic::addReader(db, mkReader("R002","Bob","Williams",11,'B',"STU002")).isValid, "Add 'Bob Williams'");
        CHECK(BusinessLogic::addReader(db, mkReader("R003","Carol","Martinez",9,'A',"STU003")).isValid, "Add 'Carol Martinez'");
        CHECK(BusinessLogic::addReader(db, mkReader("R004","David","Lee",12,'A',"STU004")).isValid, "Add 'David Lee'");
        CHECK(BusinessLogic::addReader(db, mkReader("R005","Eva","Nguyen",10,'B',"STU005")).isValid, "Add 'Eva Nguyen'");
        CHECK(db.getAllReaders().size() == 5, "5 readers registered");
    }

    TEST("17. VALIDATION — Reject reader with empty name");
    {
        DTO::ReaderDTO r; r.id = "X"; r.name = ""; r.surname = "Y"; r.grade = 10; r.classGroup = 'A'; r.studentId = "Z";
        CHECK(!BusinessLogic::addReader(db, r).isValid, "Reject empty name");
    }

    // =============================================================
    //  DAY 4 — SEARCHING
    // =============================================================

    TEST("18. SEARCH BOOKS — Find by title, author, category");
    {
        CHECK(db.searchBooks("Gatsby","title").size() == 1, "Search 'Gatsby' by title");
        CHECK(db.searchBooks("Hawking","author").size() == 1, "Search 'Hawking' by author");
        CHECK(db.searchBooks("Fiction","category").size() == 2, "Search 'Fiction' category (2 books)");
        CHECK(db.searchBooks("Technology","category").size() == 2, "Search 'Technology' category (2 books)");
        CHECK(db.searchBooks("ZZZZZ","title").empty(), "No match returns empty");
    }

    TEST("19. SEARCH READERS — Find by name and surname");
    {
        CHECK(db.searchReaders("Alice","name").size() == 1, "Search 'Alice' by name");
        CHECK(db.searchReaders("Williams","surname").size() == 1, "Search 'Williams' by surname");
        CHECK(db.searchReaders("ZZZZZ","name").empty(), "No match returns empty");
    }

    TEST("20. POPULATE LIST — Verify dropdown population");
    {
        CHECK(db.populateList("books").size() == 8, "8 books");
        CHECK(db.populateList("readers").size() == 5, "5 readers");
        CHECK(db.populateList("categories").size() == 4, "4 categories");
        CHECK(db.populateList("locations").size() == 3, "3 locations");
    }

    TEST("21. CHECK ID EXISTS — Verify ID lookups");
    {
        CHECK(db.checkIdExists("books","B001"), "Book B001 exists");
        CHECK(!db.checkIdExists("books","9999"), "Book 9999 missing");
        CHECK(db.checkIdExists("readers","R001"), "Reader R001 exists");
        CHECK(!db.checkIdExists("readers","9999"), "Reader 9999 missing");
    }

    // =============================================================
    //  DAY 5 — EDITING DATA
    // =============================================================

    TEST("22. EDIT BOOK — Update title and author of B002");
    {
        auto orig = db.getBookById("B002");
        CHECK(orig.has_value(), "B002 exists before edit");

        DTO::BookDTO updated = DTO::BookDTO::fromDomain(*orig);
        updated.title = "A Brief History of Time (Updated Edition)";
        updated.author = "Stephen Hawking (Revised)";
        updated.updatedAt = nowStr();
        CHECK(BusinessLogic::updateBook(db, updated).isValid, "Update B002 succeeds");

        auto after = db.getBookById("B002");
        CHECK(after->title == "A Brief History of Time (Updated Edition)", "Title updated");
        CHECK(after->author == "Stephen Hawking (Revised)", "Author updated");
    }

    TEST("23. EDIT BOOK — Change B004 location and status");
    {
        DTO::BookDTO updated = DTO::BookDTO::fromDomain(*db.getBookById("B004"));
        updated.location = "Reference Section";
        updated.status = "Borrowed";
        updated.updatedAt = nowStr();
        CHECK(BusinessLogic::updateBook(db, updated).isValid, "Update B004 location+status");

        auto after = db.getBookById("B004");
        CHECK(after->location == "Reference Section", "Location changed");
        CHECK(after->status == "Borrowed", "Status changed");
    }

    TEST("24. EDIT READER — Promote Bob to grade 12");
    {
        auto orig = db.getReaderById("R002");
        CHECK(orig.has_value(), "R002 exists before edit");
        CHECK(orig->grade == 11, "R002 original grade is 11");

        DTO::ReaderDTO updated = DTO::ReaderDTO::fromDomain(*orig);
        updated.grade = 12;
        updated.classGroup = 'A';
        updated.updatedAt = nowStr();
        CHECK(BusinessLogic::updateReader(db, updated).isValid, "Update R002 grade");

        auto after = db.getReaderById("R002");
        CHECK(after->grade == 12, "Grade updated to 12");
        CHECK(after->classGroup == 'A', "Class updated to A");
    }

    TEST("25. EDIT READER — Change Eva's surname");
    {
        DTO::ReaderDTO updated = DTO::ReaderDTO::fromDomain(*db.getReaderById("R005"));
        updated.surname = "Nguyen-Tran";
        updated.updatedAt = nowStr();
        CHECK(BusinessLogic::updateReader(db, updated).isValid, "Update R005 surname");

        auto after = db.getReaderById("R005");
        CHECK(after->surname == "Nguyen-Tran", "Surname updated");
    }

    // =============================================================
    //  DAY 6 — REMOVING DATA
    // =============================================================

    TEST("26. REMOVE BOOK — Soft delete '1984'");
    {
        CHECK(db.removeBook("B005"), "Remove B005 ('1984')");
        CHECK(db.getAllBooks().size() == 7, "7 active books after removal");
        CHECK(db.getRemovedBooks().size() >= 1, "B005 in removed_books");
        CHECK(!db.getBookById("B005").has_value(), "B005 no longer in active books");
    }

    TEST("27. RESTORE BOOK — Bring back '1984'");
    {
        CHECK(db.restoreBook("B005"), "Restore B005");
        CHECK(db.getAllBooks().size() == 8, "8 books after restore");
        auto book = db.getBookById("B005");
        CHECK(book.has_value(), "B005 accessible again");
        CHECK(book->title == "1984", "Title preserved");
    }

    TEST("28. REMOVE READER — Soft delete David");
    {
        CHECK(db.removeReader("R004"), "Remove R004 (David)");
        CHECK(db.getAllReaders().size() == 4, "4 active readers after removal");
        CHECK(db.getRemovedReaders().size() >= 1, "R004 in removed_readers");
    }

    TEST("29. RESTORE READER — Bring back David");
    {
        CHECK(db.restoreReader("R004"), "Restore R004");
        CHECK(db.getAllReaders().size() == 5, "5 readers after restore");
    }

    TEST("30. REMOVE BOOK — Remove 'Cosmos', then re-add with updated info");
    {
        CHECK(db.removeBook("B008"), "Remove B008 ('Cosmos')");
        CHECK(db.getAllBooks().size() == 7, "7 books after removal");

        DTO::BookDTO newBook;
        newBook.id = "B009"; newBook.title = "Cosmos (Revised)"; newBook.author = "Carl Sagan";
        newBook.location = "Main Hall - Shelf B"; newBook.category = "Science"; newBook.status = "Available";
        newBook.createdAt = nowStr(); newBook.updatedAt = nowStr();
        CHECK(BusinessLogic::addBook(db, newBook).isValid, "Add 'Cosmos (Revised)' as B009");
        CHECK(db.getAllBooks().size() == 8, "8 books again");
    }

    TEST("31. REMOVE READER — Remove Carol, verify she cannot be loaned to");
    {
        CHECK(db.removeReader("R003"), "Remove R003 (Carol)");
        CHECK(db.getAllReaders().size() == 4, "4 readers after removal");

        // Re-add Carol fresh
        DTO::ReaderDTO carol;
        carol.id = "R006"; carol.name = "Carol"; carol.surname = "Martinez"; carol.grade = 10;
        carol.classGroup = 'B'; carol.studentId = "STU006";
        carol.createdAt = nowStr(); carol.updatedAt = nowStr();
        CHECK(BusinessLogic::addReader(db, carol).isValid, "Re-add Carol as R006");
        CHECK(db.getAllReaders().size() == 5, "5 readers after re-add");
    }

    // =============================================================
    //  WEEK 2 — LOAN OPERATIONS
    // =============================================================

    TEST("32. LOAN — Alice borrows 'The Great Gatsby' for 14 days");
    {
        bool ok = db.loanBook("B001", "R001", 14);
        CHECK(ok, "Loan B001 to R001 for 14 days");

        auto book = db.getBookById("B001");
        CHECK(book->status == "Borrowed", "B001 status -> Borrowed");

        auto active = db.getActiveLoans();
        CHECK(active.size() == 1, "1 active loan");
        CHECK(active[0].bookId == "B001", "Loan for B001");
        CHECK(active[0].readerId == "R001", "Loan to R001");
    }

    TEST("33. LOAN — Cannot loan same book while borrowed");
    {
        CHECK(!db.loanBook("B001", "R002", 7), "Second loan of B001 rejected");
    }

    TEST("34. LOAN — Bob borrows 'Sapiens' for 7 days");
    {
        CHECK(db.loanBook("B003", "R002", 7), "Loan B003 to R002");
        CHECK(db.getActiveLoans().size() == 2, "2 active loans");
        CHECK(db.getBookById("B003")->status == "Borrowed", "B003 Borrowed");
    }

    TEST("35. LOAN — Carol borrows 'Design Patterns' for 21 days");
    {
        CHECK(db.loanBook("B007", "R006", 21), "Loan B007 to R006");
        CHECK(db.getActiveLoans().size() == 3, "3 active loans");
    }

    TEST("36. LOAN — Cannot loan to nonexistent reader");
    {
        CHECK(!db.loanBook("B002", "FAKE", 14), "Reject nonexistent reader");
    }

    TEST("37. LOAN — Cannot loan already-borrowed book");
    {
        CHECK(!db.loanBook("B007", "R001", 7), "B007 already borrowed by Carol");
    }

    // =============================================================
    //  WEEK 3 — RETURNS
    // =============================================================

    TEST("38. RETURN — Alice returns 'The Great Gatsby'");
    {
        auto active = db.getActiveLoans();
        std::string aliceLoanId;
        for (auto& l : active) { if (l.readerId == "R001") { aliceLoanId = l.id; break; } }
        CHECK(!aliceLoanId.empty(), "Found Alice's loan ID");

        CHECK(db.returnBook(aliceLoanId), "Return succeeds");
        CHECK(db.getBookById("B001")->status == "Available", "B001 back to Available");
        CHECK(db.getActiveLoans().size() == 2, "2 active loans remaining");
    }

    TEST("39. RETURN — Bob returns 'Sapiens'");
    {
        auto active = db.getActiveLoans();
        std::string bobLoanId;
        for (auto& l : active) { if (l.readerId == "R002") { bobLoanId = l.id; break; } }
        CHECK(!bobLoanId.empty(), "Found Bob's loan ID");

        CHECK(db.returnBook(bobLoanId), "Return succeeds");
        CHECK(db.getBookById("B003")->status == "Available", "B003 back to Available");
        CHECK(db.getActiveLoans().size() == 1, "1 active loan remaining (Carol's)");
    }

    TEST("40. RETURN — Carol returns 'Design Patterns'");
    {
        auto active = db.getActiveLoans();
        std::string carolLoanId;
        for (auto& l : active) { if (l.readerId == "R006") { carolLoanId = l.id; break; } }
        CHECK(!carolLoanId.empty(), "Found Carol's loan ID");

        CHECK(db.returnBook(carolLoanId), "Return succeeds");
        CHECK(db.getBookById("B007")->status == "Available", "B007 back to Available");
        CHECK(db.getActiveLoans().empty(), "0 active loans — all returned");
    }

    // =============================================================
    //  WEEK 4 — RE-LOANING & SEARCH
    // =============================================================

    TEST("41. LOAN — David borrows 'Clean Code' (previously marked Borrowed in edit)");
    {
        // B004 was manually set to Borrowed in edit test #23, reset it first
        DTO::BookDTO reset = DTO::BookDTO::fromDomain(*db.getBookById("B004"));
        reset.status = "Available";
        reset.updatedAt = nowStr();
        BusinessLogic::updateBook(db, reset);
        CHECK(db.getBookById("B004")->status == "Available", "B004 reset to Available");

        CHECK(db.loanBook("B004", "R004", 14), "Loan B004 to R004");
        CHECK(db.getBookById("B004")->status == "Borrowed", "B004 Borrowed again");
        CHECK(db.getActiveLoans().size() == 1, "1 active loan");
    }

    TEST("42. SEARCH LOANS — Find by book and reader");
    {
        auto allLoans = db.getAllLoans();
        CHECK(allLoans.size() >= 4, "Loan history has at least 4 entries");

        auto daveLoans = db.getLoansForReader("R004");
        CHECK(daveLoans.size() == 1, "David has 1 loan");

        auto b004Loans = db.getLoansForBook("B004");
        CHECK(b004Loans.size() == 1, "B004 has 1 loan");
    }

    TEST("43. FULL CYCLE — Return David, re-loan to Eva");
    {
        auto active = db.getActiveLoans();
        CHECK(active.size() == 1, "1 active loan (David's)");
        CHECK(db.returnBook(active[0].id), "Return David's loan");
        CHECK(db.getActiveLoans().empty(), "0 active loans");

        CHECK(db.loanBook("B004", "R005", 7), "Eva borrows B004");
        CHECK(db.getBookById("B004")->status == "Borrowed", "B004 Borrowed by Eva");
        CHECK(db.getActiveLoans().size() == 1, "1 active loan (Eva's)");
    }

    // =============================================================
    //  MONTH 2 — EDIT LOAN, OVERDUE CHECK
    // =============================================================

    TEST("44. EDIT LOAN — Extend Eva's due date via BusinessLogic");
    {
        auto active = db.getActiveLoans();
        CHECK(active.size() == 1, "1 active loan to edit");

        DTO::LoanDTO updated = DTO::LoanDTO::fromDomain(active[0]);
        updated.dueDate = Domain::toISOString(Domain::now() + std::chrono::hours(24 * 30));
        CHECK(BusinessLogic::updateLoan(db, updated).isValid, "Update loan due date succeeds");

        auto newActive = db.getActiveLoans();
        CHECK(newActive.size() == 1, "Still 1 active loan");
    }

    TEST("45. OVERDUE LOANS — Check detection");
    {
        auto overdue = db.getOverdueLoans();
        CHECK(overdue.empty(), "No overdue loans in simulation");
    }

    TEST("46. RETURN — Eva returns, all clean");
    {
        auto active = db.getActiveLoans();
        CHECK(db.returnBook(active[0].id), "Return Eva's loan");
        CHECK(db.getActiveLoans().empty(), "All loans returned");
        CHECK(db.getBookById("B004")->status == "Available", "B004 Available");
    }

    // =============================================================
    //  MONTH 3 — BULK OPERATIONS
    // =============================================================

    TEST("47. ADD BOOKS — Bulk add 5 more books");
    {
        auto mk = [](std::string id, std::string t, std::string a, std::string l, std::string c) {
            DTO::BookDTO b; b.id = std::move(id); b.title = std::move(t); b.author = std::move(a);
            b.location = std::move(l); b.category = std::move(c); b.status = "Available";
            b.createdAt = nowStr(); b.updatedAt = nowStr();
            return b;
        };
        CHECK(BusinessLogic::addBook(db, mk("B010","Dune","Frank Herbert","Main Hall - Shelf B","Fiction")).isValid, "Add 'Dune'");
        CHECK(BusinessLogic::addBook(db, mk("B011","The Origin of Species","Charles Darwin","Reference Section","Science")).isValid, "Add 'Origin'");
        CHECK(BusinessLogic::addBook(db, mk("B012","Meditations","Marcus Aurelius","Reference Section","History")).isValid, "Add 'Meditations'");
        CHECK(BusinessLogic::addBook(db, mk("B013","Neuromancer","William Gibson","Main Hall - Shelf A","Technology")).isValid, "Add 'Neuromancer'");
        CHECK(BusinessLogic::addBook(db, mk("B014","The Republic","Plato","Main Hall - Shelf B","History")).isValid, "Add 'The Republic'");
        CHECK(db.getAllBooks().size() == 13, "13 books total");
    }

    TEST("48. ADD READERS — Bulk add 5 more readers");
    {
        auto mk = [](std::string id, std::string n, std::string s, int g, char c, std::string sid) {
            DTO::ReaderDTO r; r.id = std::move(id); r.name = std::move(n); r.surname = std::move(s);
            r.grade = g; r.classGroup = c; r.studentId = std::move(sid);
            r.createdAt = nowStr(); r.updatedAt = nowStr();
            return r;
        };
        CHECK(BusinessLogic::addReader(db, mk("R007","Fiona","Garcia",11,'A',"STU007")).isValid, "Add 'Fiona Garcia'");
        CHECK(BusinessLogic::addReader(db, mk("R008","George","Kim",10,'B',"STU008")).isValid, "Add 'George Kim'");
        CHECK(BusinessLogic::addReader(db, mk("R009","Hannah","Patel",12,'A',"STU009")).isValid, "Add 'Hannah Patel'");
        CHECK(BusinessLogic::addReader(db, mk("R010","Ivan","Petrov",9,'B',"STU010")).isValid, "Add 'Ivan Petrov'");
        CHECK(BusinessLogic::addReader(db, mk("R011","Julia","Santos",11,'A',"STU011")).isValid, "Add 'Julia Santos'");
        CHECK(db.getAllReaders().size() == 10, "10 readers total");
    }

    // =============================================================
    //  MONTH 4 — STRESS: LOAN/RETURN CHURN
    // =============================================================

    TEST("49. LOAN STORM — 5 books out simultaneously");
    {
        CHECK(db.loanBook("B001", "R001", 7), "Alice -> B001");
        CHECK(db.loanBook("B003", "R002", 7), "Bob -> B003");
        CHECK(db.loanBook("B010", "R006", 14), "Carol -> B010");
        CHECK(db.loanBook("B013", "R004", 7), "David -> B013");
        CHECK(db.loanBook("B014", "R005", 14), "Eva -> B014");
        CHECK(db.getActiveLoans().size() == 5, "5 active loans");
    }

    TEST("50. RETURN STORM — All 5 return at once");
    {
        auto active = db.getActiveLoans();
        CHECK(active.size() == 5, "5 loans to return");
        int returned = 0;
        for (auto& l : active) { if (db.returnBook(l.id)) returned++; }
        CHECK(returned == 5, "All 5 returned");
        CHECK(db.getActiveLoans().empty(), "0 active loans");
        for (auto& id : {"B001","B003","B010","B013","B014"}) {
            CHECK(db.getBookById(id)->status == "Available", (std::string(id) + " back to Available").c_str());
        }
    }

    // =============================================================
    //  MONTH 5 — REMOVE/RESTORE CYCLES
    // =============================================================

    TEST("51. REMOVE BOOK — Bulk remove 3 books");
    {
        CHECK(db.removeBook("B012"), "Remove B012 ('Meditations')");
        CHECK(db.removeBook("B013"), "Remove B013 ('Neuromancer')");
        CHECK(db.removeBook("B014"), "Remove B014 ('The Republic')");
        CHECK(db.getAllBooks().size() == 10, "10 active books");
        CHECK(db.getRemovedBooks().size() >= 3, "3 in removed_books");
    }

    TEST("52. RESTORE BOOK — Restore 2 of them");
    {
        CHECK(db.restoreBook("B012"), "Restore B012");
        CHECK(db.restoreBook("B014"), "Restore B014");
        CHECK(db.getAllBooks().size() == 12, "12 active books");
        CHECK(db.getBookById("B012").has_value(), "B012 accessible");
        CHECK(db.getBookById("B014").has_value(), "B014 accessible");
    }

    TEST("53. REMOVE READER — Remove Ivan and Julia");
    {
        CHECK(db.removeReader("R010"), "Remove R010 (Ivan)");
        CHECK(db.removeReader("R011"), "Remove R011 (Julia)");
        CHECK(db.getAllReaders().size() == 8, "8 active readers");
    }

    TEST("54. RESTORE READER — Restore Julia only");
    {
        CHECK(db.restoreReader("R011"), "Restore R011 (Julia)");
        CHECK(db.getAllReaders().size() == 9, "9 active readers");
    }

    // =============================================================
    //  MONTH 6 — ROLE ENFORCEMENT
    // =============================================================

    TEST("55. ROLE CHECK — Librarian cannot do admin things");
    {
        auto libLogin = BusinessLogic::login(db, "librarian", "LibPass123!");
        CHECK(libLogin.has_value(), "Librarian login succeeds");
        CHECK(!BusinessLogic::checkUserRole(libLogin, BusinessLogic::RequiredRole::Admin).hasAccess, "Librarian denied Admin");
        CHECK(!BusinessLogic::checkUserRole(libLogin, BusinessLogic::RequiredRole::SuperAdmin).hasAccess, "Librarian denied SuperAdmin");
        CHECK(BusinessLogic::checkUserRole(libLogin, BusinessLogic::RequiredRole::None).hasAccess, "Librarian can access basic features");
    }

    // =============================================================
    //  MONTH 6 — FINAL DATA INTEGRITY
    // =============================================================

    TEST("56. FINAL INTEGRITY — All entity counts correct");
    {
        auto books = db.getAllBooks();
        auto readers = db.getAllReaders();
        auto cats = db.getAllCategories();
        auto locs = db.getAllLocations();
        auto users = db.getAllUsers();
        auto loans = db.getAllLoans();

        CHECK(books.size() == 12, "Final book count: 12");
        CHECK(readers.size() == 9, "Final reader count: 9 (Ivan still removed)");
        CHECK(cats.size() == 4, "Final category count: 4");
        CHECK(locs.size() == 3, "Final location count: 3");
        CHECK(users.size() == 2, "Final user count: 2 (superadmin + librarian)");
        CHECK(loans.size() >= 10, "Loan history has at least 10 entries");
    }

    // =============================================================
    //  SUMMARY
    // =============================================================
    std::cout << "\n========================================" << std::endl;
    std::cout << "RESULTS: " << passed << " passed, " << failed << " failed" << std::endl;
    std::cout << "========================================" << std::endl;

    db.shutdown();
    cleanup_test_dbs();

    return failed > 0 ? 1 : 0;
}
