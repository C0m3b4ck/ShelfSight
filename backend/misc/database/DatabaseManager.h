#pragma once
/**
 * DatabaseManager.h
 *
 * Tutorial note — why a singleton here?
 *   The application has exactly one SQLite file and one "main" connection.
 *   A singleton (accessed via instance()) makes that uniqueness explicit and
 *   lets repositories retrieve a thread-local connection clone without having
 *   to pass a reference through every call chain.
 *
 *   Singletons have downsides (hard to test in isolation, hidden dependency).
 *   For a production codebase you might prefer dependency injection; for a
 *   tutorial app the singleton keeps every code path easy to follow.
 *
 * Tutorial note — per-thread connections:
 *   Qt's QSqlDatabase connections are NOT thread-safe: you must use a
 *   separate QSqlDatabase object on each thread.  threadConnection() clones
 *   the main connection on first call from a new thread and caches it under a
 *   name that includes the thread's pointer address, so subsequent calls from
 *   the same thread reuse the same connection object.
 *
 *   This pattern is used by every Repository when called from a thread-pool
 *   thread via QtConcurrent::run().
 *
 * Tutorial note — schema versioning:
 *   SQLite has a built-in integer slot for application use called user_version
 *   (PRAGMA user_version).  We use it to track which migrations have been
 *   applied so that each startup can bring any existing database up to the
 *   current schema in a single, linear pass — without probing column names or
 *   guessing the database state.
 *
 *   The flow on every open():
 *     1. CREATE TABLE IF NOT EXISTS — builds the full schema on a fresh file,
 *        does nothing on an existing one.
 *     2. getUserVersion() — reads the stored version number (0 for databases
 *        that predate versioning).
 *     3. runMigrations(fromVersion) — applies every numbered step between
 *        fromVersion and k_targetSchemaVersion in order.
 *     4. setUserVersion(k_targetSchemaVersion) — stamps the new version so
 *        the next startup skips all applied migrations.
 *
 *   Adding a new migration:
 *     • Increment k_targetSchemaVersion.
 *     • Add an `if (ver < N)` block inside runMigrations().
 *     • Also update the matching CREATE TABLE statement so fresh installs
 *       start at the current schema and skip the migration entirely.
 */
#include <QObject>
#include <QSqlDatabase>
#include <QString>

namespace Librarian {

class DatabaseManager : public QObject {
    Q_OBJECT
public:
    /** Returns the application-wide singleton instance. */
    static DatabaseManager& instance();

    /**
     * Opens (or creates) the SQLite database at @p path.
     * Runs schema migrations and seeds sample data on the first launch.
     * Must be called from the main thread before any background work starts.
     */
    bool open(const QString& path);

    void close();
    bool isOpen() const;

    /**
     * Returns a QSqlDatabase connection for the calling thread.
     *
     * The first call from a new thread clones the main connection and opens
     * it.  Subsequent calls return the cached clone.  Call this at the start
     * of any Repository method that runs on a background thread.
     */
    QSqlDatabase threadConnection() const;

signals:
    /** Emitted on any database error — connect to show a UI message box. */
    void errorOccurred(const QString& message);

private:
    explicit DatabaseManager(QObject* parent = nullptr);
    ~DatabaseManager() override;

    bool initSchema();                   ///< CREATE TABLE IF NOT EXISTS + migrations.
    bool runMigrations(int fromVersion); ///< Applies every pending numbered migration.
    int  getUserVersion();               ///< Reads PRAGMA user_version (0 = unset).
    bool setUserVersion(int v);          ///< Writes PRAGMA user_version.
    bool seedAdminUser();                ///< Ensures at least one admin account exists.

    QString m_dbPath;

    /** Increment this each time a new migration block is added to runMigrations(). */
    static constexpr int  k_targetSchemaVersion = 1;

    /** Name of the main (GUI-thread) connection. Thread clones append "_t<ptr>". */
    static constexpr auto k_mainConn = "librarian_main";
};

} // namespace Librarian
