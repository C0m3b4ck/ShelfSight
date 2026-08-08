#pragma once
#include "core/models/User.h"
#include <QObject>
#include <QFuture>
#include <QList>
#include <optional>

namespace Librarian {

class UserService : public QObject {
    Q_OBJECT
public:
    explicit UserService(QObject* parent = nullptr);

    QFuture<QList<User>>         getAll();
    QFuture<QList<User>>         search(const QString& query);
    QFuture<std::optional<User>> getById(qint64 id);

    // Creates a new user with the given plain-text password (hashed internally).
    QFuture<User> create(const User& user, const QString& plainPassword);

    QFuture<User> update(const User& user);
    QFuture<bool> setBlocked(qint64 id, bool blocked);

    // Admin-level password reset (no current password required).
    QFuture<bool> resetPassword(qint64 id, const QString& newPassword);

    QFuture<bool> remove(qint64 id);

signals:
    void changed();
};

} // namespace Librarian
