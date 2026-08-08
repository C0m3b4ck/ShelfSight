/**
 * DatabaseManager.cpp
 *
 * Tutorial note — SQLite configuration:
 *   Three PRAGMAs are set immediately after opening the file:
 *
 *   • PRAGMA journal_mode=WAL
 *     Switches from the default "delete" journal to Write-Ahead Logging.
 *     WAL allows concurrent readers and one writer simultaneously — much
 *     faster for desktop apps where the UI thread reads while a background
 *     thread writes.
 *
 *   • PRAGMA foreign_keys=ON
 *     SQLite does NOT enforce foreign key constraints by default (for
 *     backwards compatibility).  We enable them explicitly so that, for
 *     example, deleting a user with active rentals raises an error instead
 *     of silently orphaning rows.
 *
 *   • PRAGMA synchronous=NORMAL
 *     Reduces fsync calls.  FULL is the default (safe but slow); NORMAL is
 *     safe for WAL mode and significantly faster on spinning drives.
 */
#include "database/DatabaseManager.h"
#include "database/DatabaseSeeder.h"
#include "security/PasswordHasher.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QThread>
#include <QDebug>

namespace Librarian {

DatabaseManager::DatabaseManager(QObject* parent) : QObject(parent) {}
DatabaseManager::~DatabaseManager() { close(); }

DatabaseManager& DatabaseManager::instance() {
    // Local static — guaranteed to be initialised exactly once, thread-safe
    // in C++11 and later (Magic Statics, § 6.7 of the standard).
    static DatabaseManager inst;
    return inst;
}

bool DatabaseManager::open(const QString& path) {
    m_dbPath = path;

    // "QSQLITE" is the Qt driver name for the bundled SQLite library.
    // The connection is named so we can retrieve it later with
    // QSqlDatabase::database(k_mainConn).
    auto db = QSqlDatabase::addDatabase("QSQLITE", k_mainConn);
    db.setDatabaseName(path);

    if (!db.open()) {
        emit errorOccurred(db.lastError().text());
        return false;
    }

    // Apply performance and correctness PRAGMAs (see file header).
    {
        QSqlQuery q(db);
        q.exec("PRAGMA journal_mode=WAL");
        q.exec("PRAGMA foreign_keys=ON");
        q.exec("PRAGMA synchronous=NORMAL");
        q.exec("PRAGMA cache_size=-8000"); // 8 MB in-process page cache
    }

    // Create tables (if new database), run any pending migrations, then
    // ensure an admin account exists.
    if (!initSchema() || !seedAdminUser())
        return false;

    // Seed sample data on first launch (skips automatically if data exists).
    DatabaseSeeder::seedIfEmpty(db);

    return true;
}

void DatabaseManager::close() {
    if (QSqlDatabase::contains(k_mainConn)) {
        QSqlDatabase::database(k_mainConn).close();
        QSqlDatabase::removeDatabase(k_mainConn);
    }
}

bool DatabaseManager::isOpen() const {
    return QSqlDatabase::contains(k_mainConn) &&
           QSqlDatabase::database(k_mainConn).isOpen();
}

QSqlDatabase DatabaseManager::threadConnection() const {
    // Build a unique connection name from the current thread's address.
    // Threads are reused by Qt's thread pool, so the address stays stable
    // for the lifetime of that thread.
    const auto connName = QString("%1_t%2")
        .arg(k_mainConn)
        .arg(reinterpret_cast<quintptr>(QThread::currentThread()));

    if (QSqlDatabase::contains(connName))
        return QSqlDatabase::database(connName);

    // First call from this thread: clone the main connection (same file path,
    // different in-process connection object) and open it.
    auto db = QSqlDatabase::cloneDatabase(k_mainConn, connName);
    if (!db.open())
        qCritical() << "[DB] threadConnection open failed:" << db.lastError().text();

    // Foreign keys must be re-enabled per connection in SQLite.
    QSqlQuery(db).exec("PRAGMA foreign_keys=ON");
    return db;
}

bool DatabaseManager::initSchema() {
    auto db = QSqlDatabase::database(k_mainConn);

    // Tutorial note — why separate statements?
    //   QSqlQuery::exec() only runs a single SQL statement at a time.
    //   Some databases support multi-statement exec via a special API, but
    //   the portable approach is to split on ';' and execute each one.
    //   We use a QStringList here for readability.
    //
    // These CREATE TABLE IF NOT EXISTS statements always reflect the CURRENT
    // (latest) schema.  On a fresh database they build the full structure and
    // no migrations are needed.  On an existing database they are all no-ops;
    // runMigrations() is responsible for bringing the schema up to date.
    static const QStringList statements = {
        // users — library operator accounts.
        // COLLATE NOCASE on login means "Admin" == "admin" in WHERE clauses.
        R"(CREATE TABLE IF NOT EXISTS users (
            id            INTEGER PRIMARY KEY AUTOINCREMENT,
            login         TEXT NOT NULL UNIQUE COLLATE NOCASE,
            full_name     TEXT NOT NULL,
            email         TEXT NOT NULL,
            phone         TEXT,
            password_hash TEXT NOT NULL,
            is_blocked    INTEGER NOT NULL DEFAULT 0,
            is_admin      INTEGER NOT NULL DEFAULT 0,
            created_at    TEXT NOT NULL DEFAULT (datetime('now'))
        ))",

        // books — the library catalog.
        // internal_code is the spine label on the physical copy (e.g. "LIB-001").
        // It is UNIQUE per physical copy.  isbn is not unique because a library
        // can own multiple copies of the same title.
        R"(CREATE TABLE IF NOT EXISTS books (
            id            INTEGER PRIMARY KEY AUTOINCREMENT,
            internal_code TEXT NOT NULL UNIQUE,
            title         TEXT NOT NULL,
            author        TEXT NOT NULL,
            isbn          TEXT,            -- not unique; multiple copies share one ISBN
            language      TEXT,
            year          INTEGER,
            publisher     TEXT,
            created_at    TEXT NOT NULL DEFAULT (datetime('now'))
        ))",

        // rentals — tracks each borrowing event.
        // returned_at NULL means the book is still out.
        // is_lost=1 means the book was never returned and is considered gone.
        // ON DELETE RESTRICT prevents deleting a user/book that has rentals.
        R"(CREATE TABLE IF NOT EXISTS rentals (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id         INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
            book_id         INTEGER NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
            rented_at       TEXT NOT NULL DEFAULT (datetime('now')),
            due_date        TEXT NOT NULL,
            returned_at     TEXT,           -- NULL = not yet returned
            is_lost         INTEGER NOT NULL DEFAULT 0,
            prolonged_count INTEGER NOT NULL DEFAULT 0
        ))",

        // Indexes — dramatically speed up the JOIN and WHERE clauses used
        // in RentalRepository and the report queries.
        "CREATE INDEX IF NOT EXISTS idx_rentals_user         ON rentals(user_id)",
        "CREATE INDEX IF NOT EXISTS idx_rentals_book         ON rentals(book_id)",
        "CREATE INDEX IF NOT EXISTS idx_rentals_active       ON rentals(returned_at, is_lost)",
        "CREATE INDEX IF NOT EXISTS idx_books_internal_code  ON books(internal_code)",
        "CREATE INDEX IF NOT EXISTS idx_books_isbn           ON books(isbn)",
        "CREATE INDEX IF NOT EXISTS idx_books_author         ON books(author COLLATE NOCASE)",
        "CREATE INDEX IF NOT EXISTS idx_books_title          ON books(title  COLLATE NOCASE)",
    };

    for (const auto& stmt : statements) {
        QSqlQuery q(db);
        if (!q.exec(stmt)) {
            emit errorOccurred(QString("Schema init failed: %1").arg(q.lastError().text()));
            return false;
        }
    }

    const int ver = getUserVersion();
    if (ver < k_targetSchemaVersion)
        return runMigrations(ver);
    return true;
}

// ── Schema versioning helpers ─────────────────────────────────────────────────

int DatabaseManager::getUserVersion() {
    // Tutorial note — PRAGMA user_version:
    //   SQLite reserves a 32-bit integer in the database file header for
    //   application use.  It is zero on any database that has never set it,
    //   which is exactly the right default: "no migrations applied yet."
    QSqlQuery q(QSqlDatabase::database(k_mainConn));
    q.exec("PRAGMA user_version");
    return q.next() ? q.value(0).toInt() : 0;
}

bool DatabaseManager::setUserVersion(int v) {
    // PRAGMA user_version does not support value binding (:param syntax),
    // so the integer is formatted directly into the SQL string.
    // This is safe because v is always a C++ int — never user-supplied text.
    QSqlQuery q(QSqlDatabase::database(k_mainConn));
    return q.exec(QString("PRAGMA user_version = %1").arg(v));
}

// ── Migration engine ──────────────────────────────────────────────────────────

bool DatabaseManager::runMigrations(int fromVersion) {
    // Tutorial note — how to add a new migration:
    //   1. Increment k_targetSchemaVersion in the header.
    //   2. Add an `if (ver < N)` block below with the ALTER TABLE (or table-
    //      rebuild) statements needed for that version.
    //   3. Update the matching CREATE TABLE IF NOT EXISTS in initSchema() so
    //      fresh installs get the new schema without running the migration.
    //
    // Each block is guarded by `if (ver < N)` rather than `else if`, so a
    // database that is multiple versions behind catches up in a single pass.

    qInfo() << "[DB] Schema version:" << fromVersion
            << "→ target:" << k_targetSchemaVersion;

    auto db = QSqlDatabase::database(k_mainConn);

    // Convenience wrapper: logs and returns false on SQL error.
    auto exec = [&](const char* sql) -> bool {
        QSqlQuery q(db);
        if (!q.exec(QString::fromUtf8(sql))) {
            qCritical() << "[DB] Migration step failed:" << q.lastError().text();
            return false;
        }
        return true;
    };

    int ver = fromVersion;

    // ── Migration 0 → 1 ───────────────────────────────────────────────────────
    // Adds internal_code to books and relaxes the UNIQUE constraint on isbn so
    // a library can hold multiple physical copies of the same title.
    //
    // Tutorial note — ALTER TABLE limitations in SQLite:
    //   SQLite supports only two ALTER TABLE forms: ADD COLUMN and RENAME.
    //   Adding a UNIQUE column, removing a constraint, or changing a column
    //   type requires recreating the table using SQLite's official 12-step
    //   procedure: https://www.sqlite.org/lang_altertable.html#otheralter
    //
    //   Steps: disable FKs → BEGIN → create _new table → copy rows → drop
    //   old → rename _new → PRAGMA foreign_key_check → COMMIT (or ROLLBACK).
    //
    // This migration is idempotent: if internal_code already exists (because
    // the app was previously run before versioning was introduced) the block
    // detects it via PRAGMA table_info and skips the rebuild safely.
    if (ver < 1) {
        qInfo() << "[DB] Applying migration 0 → 1 (internal_code, isbn constraint).";

        // Check whether the column was already added by a pre-versioning run.
        bool hasInternalCode = false;
        {
            QSqlQuery info(db);
            info.exec("PRAGMA table_info(books)");
            while (info.next()) {
                if (info.value("name").toString() == "internal_code") {
                    hasInternalCode = true;
                    break;
                }
            }
        }

        if (!hasInternalCode) {
            // FKs must be disabled outside any transaction (SQLite requirement).
            if (!exec("PRAGMA foreign_keys = OFF")) return false;
            if (!exec("BEGIN TRANSACTION"))         return false;

            bool ok =
                exec(R"(CREATE TABLE books_new (
                    id            INTEGER PRIMARY KEY AUTOINCREMENT,
                    internal_code TEXT NOT NULL UNIQUE,
                    title         TEXT NOT NULL,
                    author        TEXT NOT NULL,
                    isbn          TEXT,
                    language      TEXT,
                    year          INTEGER,
                    publisher     TEXT,
                    created_at    TEXT NOT NULL DEFAULT (datetime('now'))
                ))") &&
                exec("INSERT INTO books_new "
                     "(id, internal_code, title, author, isbn, language, year, publisher, created_at) "
                     "SELECT id, 'LIB-' || CAST(id AS TEXT), title, author, isbn, "
                     "       language, year, publisher, created_at FROM books") &&
                exec("DROP TABLE books") &&
                exec("ALTER TABLE books_new RENAME TO books") &&
                exec("CREATE INDEX idx_books_internal_code ON books(internal_code)") &&
                exec("CREATE INDEX idx_books_isbn          ON books(isbn)") &&
                exec("CREATE INDEX idx_books_author        ON books(author COLLATE NOCASE)") &&
                exec("CREATE INDEX idx_books_title         ON books(title  COLLATE NOCASE)");

            if (ok) {
                QSqlQuery fk(db);
                fk.exec("PRAGMA foreign_key_check");
                if (fk.next()) {
                    qCritical() << "[DB] Migration 0→1 FK check failed — rolling back.";
                    ok = false;
                }
            }

            exec(ok ? "COMMIT" : "ROLLBACK");
            exec("PRAGMA foreign_keys = ON");

            if (!ok) return false;
            qInfo() << "[DB] Migration 0 → 1 complete.";
        } else {
            qInfo() << "[DB] Migration 0 → 1 skipped (already applied before versioning).";
        }

        ver = 1;
    }

    // ── Future migrations go here ─────────────────────────────────────────────
    // Example — migration 1 → 2 (add a notes column to users):
    //
    //   if (ver < 2) {
    //       qInfo() << "[DB] Applying migration 1 → 2 (users.notes).";
    //       if (!exec("ALTER TABLE users ADD COLUMN notes TEXT")) return false;
    //       ver = 2;
    //   }
    //
    // ALTER TABLE … ADD COLUMN is the easy case: SQLite supports it natively
    // and it does not need the table-rebuild procedure above.
    // ─────────────────────────────────────────────────────────────────────────

    if (!setUserVersion(ver)) return false;
    qInfo() << "[DB] Schema is now at version" << ver << ".";
    return true;
}

bool DatabaseManager::seedAdminUser() {
    auto db = QSqlDatabase::database(k_mainConn);

    // Only create the default admin when no admin account exists at all.
    QSqlQuery check(db);
    if (!check.exec("SELECT COUNT(*) FROM users WHERE is_admin=1")) {
        emit errorOccurred(QString("Admin check failed: %1").arg(check.lastError().text()));
        return false;
    }
    if (check.next() && check.value(0).toInt() > 0)
        return true;

    QSqlQuery q(db);
    q.prepare(
        "INSERT INTO users (login, full_name, email, password_hash, is_admin) "
        "VALUES (:login, :name, :email, :hash, 1)"
    );
    q.bindValue(":login", "admin");
    q.bindValue(":name",  "System Administrator");
    q.bindValue(":email", "admin@library.local");
    // Hash the default password — slow by design (Argon2id).
    q.bindValue(":hash",  PasswordHasher::hash("admin"));

    if (!q.exec()) {
        emit errorOccurred(QString("Admin seed failed: %1").arg(q.lastError().text()));
        return false;
    }

    // This warning is intentional: the first person who opens the app should
    // change the admin password immediately via Users → Change Password.
    qWarning() << "[Security] Default admin created with password 'admin'."
               << "Change it immediately after first login!";
    return true;
}

} // namespace Librarian
