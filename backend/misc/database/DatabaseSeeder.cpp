/**
 * DatabaseSeeder.cpp
 *
 * Tutorial note — what you will learn from this file:
 *   • How to write an idempotent DB seeder in Qt/C++.
 *   • How to use QSqlDatabase transactions to keep inserts atomic.
 *   • How to hash multiple passwords with libsodium's Argon2id.
 *   • How to create realistic linked sample data (users → rentals → books).
 */
#include "database/DatabaseSeeder.h"
#include "security/PasswordHasher.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDateTime>
#include <QDebug>

namespace Librarian {

// ── Public entry point ────────────────────────────────────────────────────────

bool DatabaseSeeder::seedIfEmpty(QSqlDatabase db) {
    // Check for existing data — one row in books means we already seeded.
    QSqlQuery check(db);
    check.exec("SELECT COUNT(*) FROM books");
    if (check.next() && check.value(0).toInt() > 0) {
        return false; // already seeded
    }

    qInfo() << "[Seeder] First run detected — inserting sample data.";
    qInfo() << "[Seeder] Hashing demo passwords (Argon2id) — this takes a few seconds…";

    // Wrap everything in a transaction: either all rows land or none do.
    // Tutorial note: QSqlDatabase::transaction() / commit() / rollback() maps
    // directly to BEGIN / COMMIT / ROLLBACK in SQLite.
    if (!db.transaction()) {
        qWarning() << "[Seeder] Could not begin transaction:" << db.lastError().text();
        return false;
    }

    const auto userIds = seedUsers(db);
    const auto bookIds = seedBooks(db);
    seedRentals(db, userIds, bookIds);

    if (!db.commit()) {
        qWarning() << "[Seeder] Commit failed:" << db.lastError().text();
        db.rollback();
        return false;
    }

    qInfo() << "[Seeder] Sample data inserted successfully.";
    qInfo() << "[Seeder] Demo accounts (all use password: password123):";
    qInfo() << "           jan.kowalski  — teacher";
    qInfo() << "           anna.nowak    — student";
    qInfo() << "           piotr.wisn    — student";
    qInfo() << "           marta.wojcik  — blocked student (for testing)";
    return true;
}

// ── Private helpers ───────────────────────────────────────────────────────────

/**
 * Inserts four sample library users and returns their auto-generated IDs.
 *
 * Tutorial note:
 *   We call PasswordHasher::hash() for each user individually.  In a real
 *   seeder you might hash them all in parallel via QtConcurrent::mapped(),
 *   but sequential is simpler to read and only runs once on first startup.
 *
 *   All demo users share the same plaintext password ("password123") to keep
 *   the demo simple.  In the real app each user sets their own.
 */
QList<qint64> DatabaseSeeder::seedUsers(QSqlDatabase db) {
    // Hash once and reuse — Argon2id is intentionally slow (memory-hard).
    // For four different users we still call it four times so that each stored
    // hash has a different random salt (that is how Argon2 works: same password
    // → different ciphertext each time because the salt is random).
    const QString demoPassword = "password123";

    struct UserData {
        QString login, fullName, email, phone;
        bool    isAdmin{false};
        bool    isBlocked{false};
    };

    const QList<UserData> users = {
        { "jan.kowalski",  "Jan Kowalski",       "jan@school.edu",    "+48 600 111 222", false, false },
        { "anna.nowak",    "Anna Nowak",          "anna@school.edu",   "+48 601 333 444", false, false },
        { "piotr.wisn",    "Piotr Wiśniewski",   "piotr@school.edu",  "+48 602 555 666", false, false },
        { "marta.wojcik",  "Marta Wójcik",       "marta@school.edu",  "",                false, true  },
    };

    QList<qint64> ids;
    ids.reserve(users.size());

    QSqlQuery q(db);
    q.prepare(
        "INSERT INTO users (login, full_name, email, phone, password_hash, is_blocked, is_admin) "
        "VALUES (:login, :name, :email, :phone, :hash, :blocked, :admin)"
    );

    for (const auto& u : users) {
        // Hash password — each call generates a unique random salt internally.
        const QString hash = PasswordHasher::hash(demoPassword);

        q.bindValue(":login",   u.login);
        q.bindValue(":name",    u.fullName);
        q.bindValue(":email",   u.email);
        q.bindValue(":phone",   u.phone.isEmpty()
                                    ? QVariant(QMetaType(QMetaType::QString)) : u.phone);
        q.bindValue(":hash",    hash);
        q.bindValue(":blocked", u.isBlocked ? 1 : 0);
        q.bindValue(":admin",   u.isAdmin   ? 1 : 0);

        if (!q.exec()) {
            qWarning() << "[Seeder] Failed to insert user" << u.login
                       << "—" << q.lastError().text();
        } else {
            ids.append(q.lastInsertId().toLongLong());
            qInfo() << "[Seeder]   Created user:" << u.login;
        }
    }
    return ids;
}

/**
 * Inserts a representative catalog of books and returns their IDs.
 *
 * Tutorial note:
 *   The catalog covers multiple languages and centuries so the search and
 *   filter features are exercised with real data.  ISBNs are real so you
 *   can scan them with a barcode reader to test that path too.
 */
QList<qint64> DatabaseSeeder::seedBooks(QSqlDatabase db) {
    struct BookData {
        QString internalCode, title, author, isbn, language, publisher;
        int year;
    };

    // Two copies of Harry Potter (same ISBN, different internal codes) demonstrate
    // the multi-copy feature: a school can own more than one physical copy of a title.
    const QList<BookData> books = {
        { "LIB-001", "The Hobbit",
          "J.R.R. Tolkien",           "978-0-395-19395-8", "English",  "Houghton Mifflin",        1937 },
        { "LIB-002", "To Kill a Mockingbird",
          "Harper Lee",               "978-0-06-112008-4", "English",  "HarperCollins",            1960 },
        { "LIB-003", "1984",
          "George Orwell",            "978-0-452-28423-4", "English",  "Signet Classic",           1949 },
        { "LIB-004", "The Little Prince",
          "Antoine de Saint-Exupéry", "978-0-15-601398-4", "French",   "Harcourt",                 1943 },
        { "LIB-005", "Harry Potter and the Philosopher's Stone",
          "J.K. Rowling",             "978-0-590-35340-3", "English",  "Bloomsbury",               1997 },
        { "LIB-006", "Harry Potter and the Philosopher's Stone",
          "J.K. Rowling",             "978-0-590-35340-3", "English",  "Bloomsbury",               1997 },
        { "LIB-007", "Clean Code",
          "Robert C. Martin",         "978-0-13-235088-4", "English",  "Prentice Hall",            2008 },
        { "LIB-008", "Don Quixote",
          "Miguel de Cervantes",      "978-0-14-028329-7", "Spanish",  "Penguin Classics",         1605 },
        { "LIB-009", "Pride and Prejudice",
          "Jane Austen",              "978-0-14-143951-8", "English",  "Penguin Classics",         1813 },
        { "LIB-010", "The Alchemist",
          "Paulo Coelho",             "978-0-06-231609-7", "English",  "HarperOne",                1988 },
        { "LIB-011", "Norwegian Wood",
          "Haruki Murakami",          "978-0-37-571011-3", "Japanese", "Vintage International",    1987 },
        { "LIB-012", "The Name of the Rose",
          "Umberto Eco",              "978-0-15-144647-6", "Italian",  "Harcourt",                 1980 },
        { "LIB-013", "One Hundred Years of Solitude",
          "Gabriel García Márquez",   "978-0-06-088328-7", "Spanish",  "Harper Perennial Modern",  1967 },
    };

    QList<qint64> ids;
    ids.reserve(books.size());

    QSqlQuery q(db);
    q.prepare(
        "INSERT INTO books (internal_code, title, author, isbn, language, year, publisher) "
        "VALUES (:code, :title, :author, :isbn, :lang, :year, :pub)"
    );

    for (const auto& b : books) {
        q.bindValue(":code",   b.internalCode);
        q.bindValue(":title",  b.title);
        q.bindValue(":author", b.author);
        q.bindValue(":isbn",   b.isbn);
        q.bindValue(":lang",   b.language);
        q.bindValue(":year",   b.year);
        q.bindValue(":pub",    b.publisher);

        if (!q.exec()) {
            qWarning() << "[Seeder] Failed to insert book" << b.title
                       << "—" << q.lastError().text();
        } else {
            ids.append(q.lastInsertId().toLongLong());
        }
    }
    qInfo() << "[Seeder]   Inserted" << ids.size() << "books.";
    return ids;
}

/**
 * Creates sample rentals that cover all four possible statuses:
 *   Active   — rented, not yet due
 *   Overdue  — rented, past due date, not returned
 *   Returned — completed successfully (book back on shelf)
 *   Lost     — user cannot return the book
 *
 * Tutorial note — date arithmetic in SQLite:
 *   We store datetimes as ISO 8601 strings ("2025-06-01T10:00:00").
 *   SQLite's datetime('now', '-10 days') is handy in queries, but here
 *   we build the dates in C++ using QDateTime::addDays() for clarity.
 */
void DatabaseSeeder::seedRentals(QSqlDatabase db,
                                 const QList<qint64>& userIds,
                                 const QList<qint64>& bookIds) {
    if (userIds.size() < 3 || bookIds.size() < 6) {
        qWarning() << "[Seeder] Not enough users/books to create sample rentals.";
        return;
    }

    // Convenience aliases so the scenario below reads naturally.
    const qint64 jan   = userIds[0];
    const qint64 anna  = userIds[1];
    const qint64 piotr = userIds[2];
    // marta (userIds[3]) is blocked — she has no rentals.

    const qint64 theHobbit      = bookIds[0];
    const qint64 mockingbird    = bookIds[1];
    const qint64 nineteenEighty = bookIds[2];
    const qint64 harryPotter    = bookIds[4];  // LIB-005, first physical copy
    const qint64 cleanCode      = bookIds[6];  // LIB-007 (index shifted by the second HP copy)
    const qint64 donQuixote     = bookIds[7];  // LIB-008

    const auto now = QDateTime::currentDateTime();

    // Helper lambda — inserts one rental row and returns its ID.
    // Tutorial note: lambdas that capture local variables by reference [&]
    // are a concise alternative to helper member functions for one-shot use.
    auto insertRental = [&](qint64 userId, qint64 bookId,
                            QDateTime rentedAt, QDateTime dueDate,
                            std::optional<QDateTime> returnedAt = std::nullopt,
                            bool isLost = false,
                            int prolongedCount = 0) -> qint64 {
        QSqlQuery q(db);
        q.prepare(
            "INSERT INTO rentals "
            "(user_id, book_id, rented_at, due_date, returned_at, is_lost, prolonged_count) "
            "VALUES (:uid, :bid, :rented, :due, :ret, :lost, :prol)"
        );
        q.bindValue(":uid",   userId);
        q.bindValue(":bid",   bookId);
        q.bindValue(":rented", rentedAt.toString(Qt::ISODate));
        q.bindValue(":due",    dueDate.toString(Qt::ISODate));
        q.bindValue(":ret",    returnedAt
                                   ? returnedAt->toString(Qt::ISODate)
                                   : QVariant(QMetaType(QMetaType::QString)));
        q.bindValue(":lost",   isLost ? 1 : 0);
        q.bindValue(":prol",   prolongedCount);
        if (!q.exec()) {
            qWarning() << "[Seeder] Rental insert failed:" << q.lastError().text();
            return -1;
        }
        return q.lastInsertId().toLongLong();
    };

    // ── Scenario A: ACTIVE rentals (currently held, on time) ─────────────────
    // Jan is reading Harry Potter — due in 7 days, no issues.
    insertRental(jan, harryPotter,
                 /*rentedAt*/ now.addDays(-7),
                 /*dueDate*/  now.addDays(7));

    // Jan also has To Kill a Mockingbird — prolonged once, 14 days left.
    insertRental(jan, mockingbird,
                 now.addDays(-10),
                 now.addDays(14),
                 std::nullopt, false,
                 /*prolongedCount*/ 1);

    // ── Scenario B: OVERDUE rentals (held too long, not returned) ────────────
    // Anna was supposed to return Clean Code 10 days ago — she forgot.
    insertRental(anna, cleanCode,
                 now.addDays(-30),
                 now.addDays(-10));  // past due!

    // ── Scenario C: RETURNED rentals (successfully completed) ────────────────
    // Anna previously read 1984 and returned it 5 days ago — all good.
    insertRental(anna, nineteenEighty,
                 now.addDays(-20),
                 now.addDays(-8),
                 /*returnedAt*/ now.addDays(-5));  // ← returned before due date

    // Piotr borrowed The Hobbit, returned it on time.
    insertRental(piotr, theHobbit,
                 now.addDays(-14),
                 now.addDays(-2),
                 /*returnedAt*/ now.addDays(-3));  // returned 3 days ago, was due in 2

    // ── Scenario D: LOST book ────────────────────────────────────────────────
    // Piotr lost Don Quixote — librarian marked it as lost.
    insertRental(piotr, donQuixote,
                 now.addDays(-60),
                 now.addDays(-30),
                 std::nullopt, /*isLost*/ true);

    qInfo() << "[Seeder]   Created sample rentals covering Active, Overdue, Returned, and Lost states.";
}

} // namespace Librarian
