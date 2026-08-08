/**
 * UserRepository.cpp
 *
 * Tutorial note — mapping SQL rows to C++ structs (the "fromQuery" pattern):
 *   Every SELECT method delegates row-to-struct conversion to the local
 *   fromQuery() helper.  A single place to update when the schema changes.
 *
 * Tutorial note — named bind parameters:
 *   We use ":name" placeholders (named binding) rather than "?" (positional).
 *   Named bindings are more readable and order-independent — important when
 *   a parameter appears multiple times in the same query (e.g. ":q" in the
 *   search query below).
 *
 * Tutorial note — NULL vs empty string in SQLite:
 *   SQLite differentiates between a missing value (NULL) and an empty string.
 *   For optional fields like `phone` we store NULL (via QVariant with the
 *   appropriate QMetaType) rather than "", so IS NULL queries work correctly.
 */
#include "core/repositories/UserRepository.h"
#include "core/repositories/RepositoryUtils.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

namespace Librarian {

namespace {

using detail::db;
using detail::nullableString;

/** Maps the current row of @p q to a User struct. */
User fromQuery(const QSqlQuery& q) {
    User u;
    u.id           = q.value("id").toLongLong();
    u.login        = q.value("login").toString();
    u.fullName     = q.value("full_name").toString();
    u.email        = q.value("email").toString();
    u.phone        = q.value("phone").toString();
    u.passwordHash = q.value("password_hash").toString();
    u.isBlocked    = q.value("is_blocked").toBool();
    u.isAdmin      = q.value("is_admin").toBool();
    // SQLite stores datetimes as ISO 8601 strings; Qt parses them with Qt::ISODate.
    u.createdAt    = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);
    return u;
}

} // anonymous namespace

std::optional<User> UserRepository::findById(qint64 id) const {
    QSqlQuery q(db());
    q.prepare("SELECT * FROM users WHERE id = :id");
    q.bindValue(":id", id);
    if (q.exec() && q.next()) return fromQuery(q);
    return std::nullopt;
}

std::optional<User> UserRepository::findByLogin(const QString& login) const {
    QSqlQuery q(db());
    // COLLATE NOCASE is already defined on the column, but being explicit here
    // documents intent and also handles databases opened without the index.
    q.prepare("SELECT * FROM users WHERE login = :login COLLATE NOCASE");
    q.bindValue(":login", login);
    if (q.exec() && q.next()) return fromQuery(q);
    return std::nullopt;
}

QList<User> UserRepository::findAll() const {
    QList<User> users;
    QSqlQuery q("SELECT * FROM users ORDER BY full_name COLLATE NOCASE", db());
    while (q.next()) users.append(fromQuery(q));
    return users;
}

QList<User> UserRepository::search(const QString& query) const {
    QList<User> users;
    QSqlQuery q(db());
    // ":q" appears three times — named binding binds it once.
    const auto pattern = '%' + query + '%';
    q.prepare(
        "SELECT * FROM users "
        "WHERE login    LIKE :q COLLATE NOCASE "
        "   OR full_name LIKE :q COLLATE NOCASE "
        "   OR email     LIKE :q COLLATE NOCASE "
        "ORDER BY full_name COLLATE NOCASE"
    );
    q.bindValue(":q", pattern);
    if (q.exec())
        while (q.next()) users.append(fromQuery(q));
    return users;
}

User UserRepository::save(const User& user) {
    QSqlQuery q(db());

    if (user.isNewRecord()) {
        // INSERT path — password_hash must already be set by the caller.
        q.prepare(
            "INSERT INTO users (login, full_name, email, phone, password_hash, is_blocked, is_admin) "
            "VALUES (:login, :name, :email, :phone, :hash, :blocked, :admin)"
        );
    } else {
        // UPDATE path — we intentionally do NOT update password_hash here;
        // use updatePasswordHash() for that so it is always an explicit action.
        q.prepare(
            "UPDATE users SET login=:login, full_name=:name, email=:email, phone=:phone, "
            "is_blocked=:blocked, is_admin=:admin WHERE id=:id"
        );
        q.bindValue(":id", user.id);
    }

    q.bindValue(":login",   user.login);
    q.bindValue(":name",    user.fullName);
    q.bindValue(":email",   user.email);
    q.bindValue(":phone",   nullableString(user.phone));
    q.bindValue(":hash",    user.passwordHash);
    q.bindValue(":blocked", user.isBlocked ? 1 : 0);
    q.bindValue(":admin",   user.isAdmin   ? 1 : 0);

    if (!q.exec()) {
        qWarning() << "UserRepository::save failed:" << q.lastError().text();
        return {}; // Returns User with id=-1 to signal failure.
    }

    User saved = user;
    // After INSERT, retrieve the auto-generated primary key.
    if (user.isNewRecord()) saved.id = q.lastInsertId().toLongLong();
    return saved;
}

bool UserRepository::setBlocked(qint64 id, bool blocked) {
    QSqlQuery q(db());
    q.prepare("UPDATE users SET is_blocked=:b WHERE id=:id");
    q.bindValue(":b",  blocked ? 1 : 0);
    q.bindValue(":id", id);
    return q.exec();
}

bool UserRepository::updatePasswordHash(qint64 id, const QString& newHash) {
    QSqlQuery q(db());
    q.prepare("UPDATE users SET password_hash=:h WHERE id=:id");
    q.bindValue(":h",  newHash);
    q.bindValue(":id", id);
    return q.exec();
}

bool UserRepository::remove(qint64 id) {
    QSqlQuery q(db());
    // The "AND is_admin=0" clause prevents deleting the last administrator
    // account directly via SQL — a safety net in addition to any UI guards.
    q.prepare("DELETE FROM users WHERE id=:id AND is_admin=0");
    q.bindValue(":id", id);
    if (!q.exec()) {
        // Likely hit the FOREIGN KEY constraint (user has rentals) or the
        // is_admin guard — both are expected business errors, not bugs.
        qWarning() << "UserRepository::remove failed:" << q.lastError().text();
        return false;
    }
    return q.numRowsAffected() > 0;
}

} // namespace Librarian
