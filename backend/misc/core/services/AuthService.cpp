/**
 * AuthService.cpp
 *
 * Tutorial note — QtConcurrent::run() and thread safety:
 *   The lambda passed to QtConcurrent::run() executes on a Qt thread-pool
 *   thread, not the GUI thread.  Two rules apply:
 *
 *   1. Never touch QWidget or any other GUI object from the lambda.
 *      All UI updates must happen on the main thread.
 *
 *   2. Never directly modify QObject member variables from the lambda,
 *      because Qt's object model expects QObject instances to be touched
 *      only from their "owning" thread (the thread where they were created).
 *
 *   We solve rule 2 with QMetaObject::invokeMethod(..., Qt::QueuedConnection):
 *   it posts a function call that will execute on the main thread's event
 *   loop after the background lambda finishes.  This is how m_currentUser
 *   and the loggedIn signal are safely updated from the background thread.
 */
#include "core/services/AuthService.h"
#include "core/repositories/UserRepository.h"
#include "security/PasswordHasher.h"
#include <QtConcurrent/QtConcurrent>

namespace Librarian {

AuthService::AuthService(QObject* parent) : QObject(parent) {}

QFuture<std::optional<User>> AuthService::login(const QString& login,
                                                 const QString& password) {
    // Capture by value so the lambda owns its own copies — safe across threads.
    return QtConcurrent::run([this, login, password]() -> std::optional<User> {

        // Step 1: look up the user (fast — a simple indexed SELECT).
        UserRepository repo;
        auto user = repo.findByLogin(login);
        if (!user)            return std::nullopt; // unknown login
        if (user->isBlocked)  return std::nullopt; // account suspended

        // Step 2: verify the password — slow (Argon2id, ~0.5 s).
        if (!PasswordHasher::verify(password, user->passwordHash))
            return std::nullopt;

        // Step 3: opportunistic rehash if the stored hash used weaker params.
        // This happens transparently: the user doesn't notice, but next time
        // they log in their account will be protected by the newer parameters.
        if (PasswordHasher::needsRehash(user->passwordHash)) {
            const auto newHash = PasswordHasher::hash(password);
            repo.updatePasswordHash(user->id, newHash);
            user->passwordHash = newHash;
        }

        // Step 4: update session state on the GUI thread via Qt's queued invoke.
        // [u = *user] copies the User value into the lambda's capture.
        QMetaObject::invokeMethod(this, [this, u = *user]() mutable {
            m_currentUser = u;
            emit loggedIn(u);
        }, Qt::QueuedConnection);

        return user; // the caller's QFutureWatcher will receive this value
    });
}

void AuthService::logout() {
    m_currentUser.reset();
    emit loggedOut();
}

bool AuthService::isLoggedIn() const  { return m_currentUser.has_value(); }
bool AuthService::isAdmin()    const  { return m_currentUser.has_value() && m_currentUser->isAdmin; }

const User& AuthService::currentUser() const {
    Q_ASSERT_X(m_currentUser.has_value(), "AuthService::currentUser",
               "Called before login — check isLoggedIn() first.");
    return *m_currentUser;
}

} // namespace Librarian
