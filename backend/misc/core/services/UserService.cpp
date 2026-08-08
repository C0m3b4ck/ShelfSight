/**
 * UserService.cpp
 *
 * Tutorial note — "fire and forget" vs. "observe the result":
 *   Every method returns QFuture<T>.  The UI layer attaches a
 *   QFutureWatcher and reacts when the future finishes.  If the UI just
 *   wants to trigger an action and doesn't need the result, it can
 *   call watcher->setFuture(future) without connecting the finished()
 *   signal — the background work still completes, it just isn't observed.
 *
 * Tutorial note — why hash in the service, not the repository?
 *   The repository knows nothing about passwords — it just stores whatever
 *   string it receives.  The service knows that a "new user" operation
 *   requires hashing, so it calls PasswordHasher before calling save().
 *   This keeps the repository a thin, reusable data-access layer.
 */
#include "core/services/UserService.h"
#include "core/repositories/UserRepository.h"
#include "security/PasswordHasher.h"
#include <QtConcurrent/QtConcurrent>

namespace Librarian {

UserService::UserService(QObject* parent) : QObject(parent) {}

QFuture<QList<User>> UserService::getAll() {
    return QtConcurrent::run([] { return UserRepository{}.findAll(); });
}

QFuture<QList<User>> UserService::search(const QString& query) {
    return QtConcurrent::run([query] { return UserRepository{}.search(query); });
}

QFuture<std::optional<User>> UserService::getById(qint64 id) {
    return QtConcurrent::run([id] { return UserRepository{}.findById(id); });
}

QFuture<User> UserService::create(const User& user, const QString& plainPassword) {
    return QtConcurrent::run([this, user, plainPassword] {
        User u = user;
        u.passwordHash = PasswordHasher::hash(plainPassword);
        auto result = UserRepository{}.save(u);
        if (result.isValid()) emit changed();
        return result;
    });
}

QFuture<User> UserService::update(const User& user) {
    return QtConcurrent::run([this, user] {
        auto result = UserRepository{}.save(user);
        if (result.isValid()) emit changed();
        return result;
    });
}

QFuture<bool> UserService::setBlocked(qint64 id, bool blocked) {
    return QtConcurrent::run([this, id, blocked] {
        const bool ok = UserRepository{}.setBlocked(id, blocked);
        if (ok) emit changed();
        return ok;
    });
}

QFuture<bool> UserService::resetPassword(qint64 id, const QString& newPassword) {
    return QtConcurrent::run([this, id, newPassword] {
        const bool ok = UserRepository{}.updatePasswordHash(id, PasswordHasher::hash(newPassword));
        if (ok) emit changed();
        return ok;
    });
}

QFuture<bool> UserService::remove(qint64 id) {
    return QtConcurrent::run([this, id] {
        const bool ok = UserRepository{}.remove(id);
        if (ok) emit changed();
        return ok;
    });
}

} // namespace Librarian
