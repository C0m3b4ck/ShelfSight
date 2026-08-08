#pragma once
#include <QSqlDatabase>

namespace Librarian {

/**
 * DatabaseSeeder — one-shot sample data loader.
 *
 * PURPOSE (Tutorial note):
 *   A seeder populates the database with realistic demo data so the application
 *   is immediately useful after a fresh install.  In production you would strip
 *   this out, but for a tutorial/school project it doubles as living
 *   documentation: the data shows every feature of the schema in action.
 *
 * IDEMPOTENCY:
 *   seedIfEmpty() checks whether the books table already has rows before
 *   inserting anything.  Safe to call on every startup — it is a no-op after
 *   the first run.
 *
 * THREADING:
 *   Must be called from the thread that owns the main database connection,
 *   i.e. the GUI thread during application startup (before any views open).
 *   Password hashing is slow (~0.5 s per user with Argon2id INTERACTIVE
 *   parameters) — 4 sample users ≈ 2 s on first run only.
 */
class DatabaseSeeder {
public:
    DatabaseSeeder() = delete; // static-only utility class

    /**
     * Inserts sample users, books and rentals if the database is empty.
     * Returns true if seeding was performed.
     */
    static bool seedIfEmpty(QSqlDatabase db);

private:
    // Each helper runs inside the same transaction started by seedIfEmpty().
    static QList<qint64> seedUsers(QSqlDatabase db);
    static QList<qint64> seedBooks(QSqlDatabase db);
    static void          seedRentals(QSqlDatabase db,
                                     const QList<qint64>& userIds,
                                     const QList<qint64>& bookIds);
};

} // namespace Librarian
