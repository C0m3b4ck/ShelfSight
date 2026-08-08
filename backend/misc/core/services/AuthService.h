#pragma once
/**
 * AuthService.h — login, logout, and password management.
 *
 * Tutorial note — the Service layer:
 *   Repositories handle raw SQL; Services implement business rules that may
 *   involve multiple repositories or non-trivial logic.  AuthService is a
 *   good example:
 *     • findByLogin()     — UserRepository
 *     • verify()          — PasswordHasher (slow, must not block UI)
 *     • needsRehash()     — PasswordHasher
 *     • updatePasswordHash() — UserRepository
 *   None of those steps belong in the UI or in a single repository.
 *
 * Tutorial note — QFuture for async results:
 *   login() returns QFuture<std::optional<User>> because Argon2id
 *   verification takes ~0.5 s — calling it synchronously on the GUI thread
 *   would freeze the window.
 *
 *   QtConcurrent::run() runs the lambda on Qt's global thread pool and
 *   returns a QFuture immediately.  The caller connects a QFutureWatcher
 *   to the future to be notified when the result is ready, then updates
 *   the UI on the main thread.  See LoginDialog.cpp for the usage pattern.
 *
 * Tutorial note — session state:
 *   m_currentUser is a simple optional<User> stored in memory.  No JWT, no
 *   session token, no cookie — the app is single-user per process, so
 *   in-memory state is correct and safe.
 */
#include "core/models/User.h"
#include <QObject>
#include <QFuture>
#include <optional>

namespace Librarian {

class AuthService : public QObject {
    Q_OBJECT
public:
    explicit AuthService(QObject* parent = nullptr);

    /**
     * Authenticates @p login / @p password asynchronously.
     * Returns nullopt on failure (wrong credentials OR blocked account).
     * On success, updates the internal session and emits loggedIn().
     *
     * The future must be observed via QFutureWatcher — see LoginDialog.cpp.
     */
    QFuture<std::optional<User>> login(const QString& login, const QString& password);

    /** Clears the session and emits loggedOut(). */
    void logout();

    bool        isLoggedIn() const;
    const User& currentUser() const;   ///< Precondition: isLoggedIn() == true.
    bool        isAdmin()    const;

signals:
    void loggedIn(const User& user);
    void loggedOut();

private:
    std::optional<User> m_currentUser; ///< Populated on login, reset on logout.
};

} // namespace Librarian
