#pragma once
/**
 * User.h — Data model for library operator accounts.
 *
 * Tutorial note — authentication vs. authorisation:
 *   The User struct carries both identity information (login, email) and the
 *   authorisation flag (isAdmin).  In a larger system these would be separate
 *   tables (users + roles), but for a school library two roles (admin /
 *   regular) are sufficient and keeping them in one struct is simpler.
 *
 *   isBlocked lets a librarian revoke access without deleting the account —
 *   deletion would break the referential integrity of the rentals table
 *   (a rental row must always point to a valid user).
 */
#include <QString>
#include <QDateTime>

namespace Librarian {

struct User {
    qint64    id{-1};       ///< Auto-assigned by SQLite; -1 means "not yet saved".
    QString   login;        ///< Unique username, case-insensitive in the DB.
    QString   fullName;     ///< Display name shown in the UI.
    QString   email;
    QString   phone;
    /**
     * The Argon2id hash produced by PasswordHasher::hash().
     * NEVER store a plaintext password — not even temporarily in memory
     * longer than the immediate verification call.
     */
    QString   passwordHash;
    bool      isBlocked{false};
    bool      isAdmin{false};
    QDateTime createdAt;

    bool isValid()     const { return id > 0; }
    bool isNewRecord() const { return id < 0; }
};

} // namespace Librarian
