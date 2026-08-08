#pragma once
/**
 * UserRepository.h — data access for the users table.
 *
 * Tutorial note — the Repository pattern:
 *   A Repository encapsulates all SQL for one table (or closely related
 *   tables).  It translates between:
 *     • The relational world  — QSqlQuery, column names, data types.
 *     • The domain world      — C++ structs (User, Book, Rental…).
 *
 *   Benefits:
 *     1. The rest of the app never writes SQL — it calls typed C++ methods.
 *     2. SQL changes stay in one place (easy to optimise or switch DB).
 *     3. Repositories are trivially testable with a test database.
 *
 * Tutorial note — thread safety:
 *   UserRepository has no member variables — it is a stateless value type.
 *   You can create a temporary instance on the stack inside a lambda that
 *   runs on a Qt thread-pool thread:
 *
 *     QtConcurrent::run([] { return UserRepository{}.findAll(); });
 *
 *   Each method calls DatabaseManager::instance().threadConnection() to
 *   get the correct per-thread QSqlDatabase handle.
 */
#include "core/models/User.h"
#include <QList>
#include <optional>

namespace Librarian {

class UserRepository {
public:
    UserRepository() = default;

    /** Returns the user with the given primary key, or nullopt if not found. */
    std::optional<User> findById(qint64 id) const;

    /**
     * Looks up a user by login (case-insensitive).
     * Used by AuthService during the login flow.
     */
    std::optional<User> findByLogin(const QString& login) const;

    /** Returns all users ordered by full name. */
    QList<User> findAll() const;

    /**
     * Full-text search across login, full_name and email columns.
     * Uses SQL LIKE with leading/trailing wildcards — sufficient for a
     * small table; for large tables consider FTS5.
     */
    QList<User> search(const QString& query) const;

    /**
     * INSERT (if user.isNewRecord()) or UPDATE an existing user.
     * The passwordHash field is written as-is — the caller is responsible
     * for passing an already-hashed value (never plaintext).
     * Returns the saved User with id populated on success, or an invalid
     * User (id=-1) on failure.
     */
    User save(const User& user);

    /** Sets is_blocked for the given user. */
    bool setBlocked(qint64 id, bool blocked);

    /**
     * Replaces the password hash for the given user.
     * Called by AuthService (transparent rehash) and UserService (reset).
     */
    bool updatePasswordHash(qint64 id, const QString& newHash);

    /**
     * Deletes the user — will fail (return false) if the DB raises a
     * FOREIGN KEY constraint error (user has rentals).
     * Admin accounts (is_admin=1) are excluded from deletion by the query.
     */
    bool remove(qint64 id);
};

} // namespace Librarian
