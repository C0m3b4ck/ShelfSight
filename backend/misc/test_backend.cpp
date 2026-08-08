// Headless smoke test for the ShelfSight backend.
// Build: g++ -std=c++17 test_backend.cpp backend/*.cpp -lsqlite3 -lcrypto -o test_backend
#include "backend/database.h"
#include "backend/library.h"
#include "backend/credentials.h"
#include "backend/crypto.h"

#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

using namespace shelfsight;

static int failures = 0;

#define CHECK(cond)                                                           \
    do {                                                                      \
        if (!(cond)) {                                                        \
            std::printf("FAIL %s:%d  %s\n", __FILE__, __LINE__, #cond);       \
            ++failures;                                                       \
        }                                                                     \
    } while (0)

static void test_crypto() {
    const std::vector<unsigned char> key = random_bytes(32);
    const std::vector<unsigned char> iv = random_bytes(16);
    const std::string plain = "ShelfSight secret payload";
    const std::string enc = aes256_encrypt(plain, key, iv);
    CHECK(enc != plain);
    CHECK(aes256_decrypt(enc, key, iv) == plain);

    const std::string h1 = sha256_hex("hello");
    const std::string h2 = sha256_hex("hello");
    const std::string h3 = sha256_hex("world");
    CHECK(h1 == h2);
    CHECK(h1 != h3);
    CHECK(h1.size() == 64);

    const std::string ch1 = credential_hash("alice", "hunter2", 1);
    const std::string ch2 = credential_hash("alice", "hunter2", 1);
    CHECK(ch1 == ch2);
    CHECK(credential_hash("alice", "hunter2", 2) != ch1);
}

static void test_database_sql_injection() {
    Database db("test_injection.db");
    CHECK(db.init());

    Book b;
    b.title = "Injection";
    b.author = "Hacker";
    b.book_id = "B1' OR '1'='1";  // attempts injection via data
    b.category = "Fiction";
    b.status = "Available";
    CHECK(db.add_book(b));

    Book b2;
    b2.title = "Normal";
    b2.author = "Author";
    b2.book_id = "B2";
    b2.category = "History";
    b2.status = "Available";
    CHECK(db.add_book(b2));

    // The quote-in-ID must not break the query or drop the table.
    CHECK(db.get_book("B1' OR '1'='1").has_value());
    CHECK(db.get_book("B2").has_value());

    // Search with a malicious term must not change behaviour.
    const auto results = db.search_books("' OR '1'='1", "Title");
    CHECK(results.size() == 0);

    // A trailing injection attempt in the search must not return everything.
    const auto all = db.search_books("'; DROP TABLE books; --", "Title");
    CHECK(all.empty());
    CHECK(db.get_book("B2").has_value());  // table still exists
}

static void test_library() {
    Database db("test_library.db");
    CHECK(db.init());
    Library lib(db);

    CHECK(lib.add_book("Title A", "Author A", "ID1", "Fiction", "Available"));
    CHECK(!lib.add_book("Title A", "Author A", "ID1", "Fiction", "Available")); // dup
    CHECK(lib.find_book("ID1").has_value());
    CHECK(lib.search_books("Title A", "Title").size() == 1);

    CHECK(lib.edit_book("ID1", "Title A2", "Author A", "Fiction", "Borrowed"));
    CHECK(lib.find_book("ID1")->title == "Title A2");
    CHECK(lib.find_book("ID1")->status == "Borrowed");
    CHECK(lib.undo());
    CHECK(lib.find_book("ID1")->title == "Title A");  // undo edit
    CHECK(lib.undo());
    CHECK(!lib.find_book("ID1"));  // undo add

    CHECK(lib.add_reader("Jane", "Doe", "5", "B", "R1"));
    CHECK(lib.search_readers("Jane", "Name").size() == 1);
    CHECK(lib.edit_reader("R1", "Janet", "Doe", "5", "B"));
    CHECK(lib.find_reader("R1")->name == "Janet");
    CHECK(lib.undo());
    CHECK(lib.find_reader("R1")->name == "Jane");
    CHECK(lib.undo());
    CHECK(!lib.find_reader("R1"));

    CHECK(lib.add_loan("ID1", "R1", "LN-TEST1", "2099-01-01", "Active"));
    CHECK(lib.find_loan("LN-TEST1").has_value());
    CHECK(lib.delete_loan("LN-TEST1"));
    CHECK(lib.undo());
    CHECK(lib.find_loan("LN-TEST1").has_value());
    CHECK(lib.undo());
    CHECK(!lib.find_loan("LN-TEST1"));
}

static void test_credentials() {
    Database db("test_credentials.db");
    CHECK(db.init());
    CredentialManager creds(db);

    CHECK(creds.register_user("alice", "password123", "password123", 1) == AuthResult::Success);
    CHECK(creds.register_user("alice", "password123", "password123", 1) == AuthResult::UserExists);
    CHECK(creds.register_user("bob", "short", "short", 1) == AuthResult::PasswordsTooShort);
    CHECK(creds.register_user("bob", "password1", "password2", 1) == AuthResult::PasswordsMismatch);

    CHECK(creds.login("alice", "password123", 1) == AuthResult::Success);
    CHECK(creds.login("alice", "wrongpass", 1) == AuthResult::UserNotFound);
    CHECK(creds.login("nobody", "password123", 1) == AuthResult::UserNotFound);

    // Wrong role must not authenticate.
    CHECK(creds.login("alice", "password123", 3) == AuthResult::UserNotFound);
}

static void test_session_config() {
    std::remove("test_app.db");
    std::remove("test_session.db");

    Database app("test_app.db");
    CHECK(app.init());

    // Nothing saved yet.
    std::string path;
    CHECK(!app.load_session_db(path));
    CHECK(path.empty());

    CHECK(app.save_session_db("test_session.db"));

    // Reload from a fresh connection to prove it is persisted.
    Database app2("test_app.db");
    CHECK(app2.init());
    CHECK(app2.load_session_db(path));
    CHECK(path == "test_session.db");

    // The session database can be opened after the fact (as the GUI does at
    // login time via select_session_db).
    Database session("test_session.db");
    CHECK(session.open(path));
    Book b;
    b.title = "Book";
    b.author = "Author";
    b.book_id = "S1";
    CHECK(session.add_book(b));
    CHECK(session.get_book("S1").has_value());

    std::remove("test_app.db");
    std::remove("test_session.db");
}

int main() {
    std::remove("test_injection.db");
    std::remove("test_library.db");
    std::remove("test_credentials.db");

    test_crypto();
    test_database_sql_injection();
    test_library();
    test_credentials();
    test_session_config();

    if (failures == 0) {
        std::printf("ALL BACKEND TESTS PASSED\n");
        return 0;
    }
    std::printf("%d test(s) FAILED\n", failures);
    return 1;
}
