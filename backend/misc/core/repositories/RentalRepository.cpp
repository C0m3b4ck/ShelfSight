/**
 * RentalRepository.cpp
 *
 * Tutorial note — the k_viewSql constant:
 *   All methods that return RentalView share the same JOIN preamble stored in
 *   k_viewSql.  We append different WHERE / ORDER BY clauses per method.
 *   This avoids copy-pasting the JOIN and keeps the column aliasing (AS
 *   user_login, AS book_title…) in one place.
 *
 * Tutorial note — "numRowsAffected() > 0":
 *   After an UPDATE we check that at least one row was actually changed.
 *   If numRowsAffected() returns 0, the WHERE clause matched nothing — for
 *   example, markReturned() WHERE returned_at IS NULL would silently succeed
 *   on an already-returned rental without this check.
 *
 * Tutorial note — julianday() in SQLite:
 *   SQLite's julianday() converts a date string to a Julian Day Number
 *   (a real number).  Subtracting two Julian Day Numbers gives the difference
 *   in fractional days.  CAST(... AS INTEGER) truncates to whole days.
 *   This is the standard SQLite idiom for "days between two dates".
 */
#include "core/repositories/RentalRepository.h"
#include "core/repositories/RepositoryUtils.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

namespace Librarian {

namespace {

using detail::db;

Rental rentalFromQuery(const QSqlQuery& q) {
    Rental r;
    r.id             = q.value("id").toLongLong();
    r.userId         = q.value("user_id").toLongLong();
    r.bookId         = q.value("book_id").toLongLong();
    r.rentedAt       = QDateTime::fromString(q.value("rented_at").toString(),    Qt::ISODate);
    r.dueDate        = QDateTime::fromString(q.value("due_date").toString(),      Qt::ISODate);
    r.isLost         = q.value("is_lost").toBool();
    r.prolongedCount = q.value("prolonged_count").toInt();

    const auto ret = q.value("returned_at").toString();
    if (!ret.isEmpty())
        r.returnedAt = QDateTime::fromString(ret, Qt::ISODate);

    return r;
}

RentalView viewFromQuery(const QSqlQuery& q) {
    RentalView v;
    v.rental        = rentalFromQuery(q);
    v.userLogin     = q.value("user_login").toString();
    v.userFullName  = q.value("user_full_name").toString();
    v.bookTitle     = q.value("book_title").toString();
    v.bookAuthor    = q.value("book_author").toString();
    v.bookIsbn      = q.value("book_isbn").toString();
    return v;
}

static constexpr auto k_viewSql =
    "SELECT r.*, "
    "  u.login AS user_login, u.full_name AS user_full_name, "
    "  b.title AS book_title, b.author AS book_author, b.isbn AS book_isbn "
    "FROM rentals r "
    "JOIN users u ON u.id = r.user_id "
    "JOIN books b ON b.id = r.book_id ";

} // anonymous namespace

std::optional<Rental> RentalRepository::findById(qint64 id) const {
    QSqlQuery q(db());
    q.prepare("SELECT * FROM rentals WHERE id = :id");
    q.bindValue(":id", id);
    if (q.exec() && q.next()) return rentalFromQuery(q);
    return std::nullopt;
}

QList<Rental> RentalRepository::findByUser(qint64 userId) const {
    QList<Rental> list;
    QSqlQuery q(db());
    q.prepare("SELECT * FROM rentals WHERE user_id=:uid ORDER BY rented_at DESC");
    q.bindValue(":uid", userId);
    if (q.exec())
        while (q.next()) list.append(rentalFromQuery(q));
    return list;
}

QList<Rental> RentalRepository::findByBook(qint64 bookId) const {
    QList<Rental> list;
    QSqlQuery q(db());
    q.prepare("SELECT * FROM rentals WHERE book_id=:bid ORDER BY rented_at DESC");
    q.bindValue(":bid", bookId);
    if (q.exec())
        while (q.next()) list.append(rentalFromQuery(q));
    return list;
}

QList<RentalView> RentalRepository::findAllActive() const {
    QList<RentalView> list;
    QSqlQuery q(db());
    q.prepare(QString(k_viewSql) +
              "WHERE r.returned_at IS NULL AND r.is_lost=0 ORDER BY r.due_date");
    if (q.exec())
        while (q.next()) list.append(viewFromQuery(q));
    return list;
}

QList<RentalView> RentalRepository::findOverdue() const {
    QList<RentalView> list;
    QSqlQuery q(db());
    q.prepare(QString(k_viewSql) +
              "WHERE r.returned_at IS NULL AND r.is_lost=0 "
              "  AND r.due_date < datetime('now') ORDER BY r.due_date");
    if (q.exec())
        while (q.next()) list.append(viewFromQuery(q));
    return list;
}

QList<RentalView> RentalRepository::findReturned() const {
    // returned_at IS NOT NULL means the book was physically returned to the shelf —
    // this is the "completed successfully" state.
    QList<RentalView> list;
    QSqlQuery q(db());
    q.prepare(QString(k_viewSql) +
              "WHERE r.returned_at IS NOT NULL ORDER BY r.returned_at DESC");
    if (q.exec())
        while (q.next()) list.append(viewFromQuery(q));
    return list;
}

QList<RentalView> RentalRepository::findAll() const {
    QList<RentalView> list;
    QSqlQuery q(QString(k_viewSql) + "ORDER BY r.rented_at DESC", db());
    while (q.next()) list.append(viewFromQuery(q));
    return list;
}

QList<RentalView> RentalRepository::findViewsByBook(qint64 bookId) const {
    QList<RentalView> list;
    QSqlQuery q(db());
    q.prepare(QString(k_viewSql) + "WHERE r.book_id=:bid ORDER BY r.rented_at DESC");
    q.bindValue(":bid", bookId);
    if (q.exec())
        while (q.next()) list.append(viewFromQuery(q));
    return list;
}

Rental RentalRepository::save(const Rental& rental) {
    QSqlQuery q(db());

    if (rental.isNewRecord()) {
        q.prepare(
            "INSERT INTO rentals (user_id, book_id, due_date) "
            "VALUES (:uid, :bid, :due)"
        );
        q.bindValue(":uid", rental.userId);
        q.bindValue(":bid", rental.bookId);
        q.bindValue(":due", rental.dueDate.toString(Qt::ISODate));
    } else {
        q.prepare(
            "UPDATE rentals SET due_date=:due, returned_at=:ret, "
            "is_lost=:lost, prolonged_count=:prol WHERE id=:id"
        );
        q.bindValue(":id",   rental.id);
        q.bindValue(":due",  rental.dueDate.toString(Qt::ISODate));
        q.bindValue(":ret",  rental.returnedAt
                                 ? rental.returnedAt->toString(Qt::ISODate)
                                 : QVariant(QMetaType(QMetaType::QString)));
        q.bindValue(":lost", rental.isLost ? 1 : 0);
        q.bindValue(":prol", rental.prolongedCount);
    }

    if (!q.exec()) {
        qWarning() << "RentalRepository::save failed:" << q.lastError().text();
        return {};
    }

    Rental saved = rental;
    if (rental.isNewRecord()) saved.id = q.lastInsertId().toLongLong();
    return saved;
}

bool RentalRepository::markReturned(qint64 rentalId) {
    QSqlQuery q(db());
    q.prepare("UPDATE rentals SET returned_at=datetime('now') WHERE id=:id AND returned_at IS NULL");
    q.bindValue(":id", rentalId);
    return q.exec() && q.numRowsAffected() > 0;
}

bool RentalRepository::markLost(qint64 rentalId) {
    QSqlQuery q(db());
    q.prepare("UPDATE rentals SET is_lost=1 WHERE id=:id");
    q.bindValue(":id", rentalId);
    return q.exec();
}

bool RentalRepository::prolong(qint64 rentalId, const QDateTime& newDueDate) {
    QSqlQuery q(db());
    q.prepare(
        "UPDATE rentals SET due_date=:due, prolonged_count=prolonged_count+1 "
        "WHERE id=:id AND returned_at IS NULL AND is_lost=0"
    );
    q.bindValue(":due", newDueDate.toString(Qt::ISODate));
    q.bindValue(":id",  rentalId);
    return q.exec() && q.numRowsAffected() > 0;
}

QList<PopularBookReport> RentalRepository::popularBooks(int limit) const {
    QList<PopularBookReport> list;
    QSqlQuery q(db());
    q.prepare(
        "SELECT b.id, b.title, b.author, COUNT(r.id) AS total "
        "FROM books b JOIN rentals r ON r.book_id=b.id "
        "GROUP BY b.id ORDER BY total DESC LIMIT :lim"
    );
    q.bindValue(":lim", limit);
    if (q.exec()) {
        while (q.next()) {
            PopularBookReport rep;
            rep.bookId       = q.value("id").toLongLong();
            rep.title        = q.value("title").toString();
            rep.author       = q.value("author").toString();
            rep.totalRentals = q.value("total").toInt();
            list.append(rep);
        }
    }
    return list;
}

QList<DelayedRentalReport> RentalRepository::longestDelays(int limit) const {
    QList<DelayedRentalReport> list;
    QSqlQuery q(db());
    q.prepare(
        "SELECT r.id, u.full_name, u.login, b.title, "
        "  CAST((julianday('now') - julianday(r.due_date)) AS INTEGER) AS days_overdue "
        "FROM rentals r "
        "JOIN users u ON u.id=r.user_id "
        "JOIN books b ON b.id=r.book_id "
        "WHERE r.returned_at IS NULL AND r.is_lost=0 "
        "  AND r.due_date < datetime('now') "
        "ORDER BY days_overdue DESC LIMIT :lim"
    );
    q.bindValue(":lim", limit);
    if (q.exec()) {
        while (q.next()) {
            DelayedRentalReport rep;
            rep.rentalId     = q.value("id").toLongLong();
            rep.userFullName = q.value("full_name").toString();
            rep.userLogin    = q.value("login").toString();
            rep.bookTitle    = q.value("title").toString();
            rep.daysOverdue  = q.value("days_overdue").toLongLong();
            list.append(rep);
        }
    }
    return list;
}

} // namespace Librarian
