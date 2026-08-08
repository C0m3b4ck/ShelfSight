/**
 * RentalService.cpp
 *
 * Tutorial note — concurrency and data integrity in rentBook():
 *   rentBook() checks book availability and then creates a rental.  In a
 *   multi-user server this would be a race condition — two users could both
 *   see the book as available and both successfully create a rental.
 *
 *   For a single-user desktop app this is not a practical concern, but the
 *   pattern is still correct: the availability check is inside the same
 *   QtConcurrent::run() lambda as the INSERT, so no other UI action can
 *   interleave between the check and the write on this thread.
 *
 *   For a web API you would use a database transaction with a SELECT FOR
 *   UPDATE (or a UNIQUE constraint on active rentals per book) to prevent
 *   the race condition at the DB level.
 */
#include "core/services/RentalService.h"
#include "core/repositories/RentalRepository.h"
#include "core/repositories/BookRepository.h"
#include <QtConcurrent/QtConcurrent>

namespace Librarian {

RentalService::RentalService(QObject* parent) : QObject(parent) {}

QFuture<QList<RentalView>> RentalService::getAll() {
    return QtConcurrent::run([] { return RentalRepository{}.findAll(); });
}

QFuture<QList<RentalView>> RentalService::getActive() {
    return QtConcurrent::run([] { return RentalRepository{}.findAllActive(); });
}

QFuture<QList<RentalView>> RentalService::getOverdue() {
    return QtConcurrent::run([] { return RentalRepository{}.findOverdue(); });
}

QFuture<QList<RentalView>> RentalService::getReturned() {
    return QtConcurrent::run([] { return RentalRepository{}.findReturned(); });
}

QFuture<QList<RentalView>> RentalService::getHistoryForBook(qint64 bookId) {
    return QtConcurrent::run([bookId] { return RentalRepository{}.findViewsByBook(bookId); });
}

QFuture<std::optional<Rental>> RentalService::rentBook(qint64 userId,
                                                       qint64 bookId,
                                                       const QDateTime& dueDate) {
    return QtConcurrent::run([this, userId, bookId, dueDate]() -> std::optional<Rental> {
        auto avail = BookRepository{}.searchAvailable({});
        bool bookAvailable = false;
        for (const auto& ba : avail)
            if (ba.book.id == bookId) { bookAvailable = ba.available; break; }

        if (!bookAvailable) return std::nullopt;

        Rental r;
        r.userId  = userId;
        r.bookId  = bookId;
        r.dueDate = dueDate;
        auto result = RentalRepository{}.save(r);
        if (result.isValid()) emit changed();
        return result;
    });
}

QFuture<bool> RentalService::returnBook(qint64 rentalId) {
    return QtConcurrent::run([this, rentalId] {
        const bool ok = RentalRepository{}.markReturned(rentalId);
        if (ok) emit changed();
        return ok;
    });
}

QFuture<bool> RentalService::markLost(qint64 rentalId) {
    return QtConcurrent::run([this, rentalId] {
        const bool ok = RentalRepository{}.markLost(rentalId);
        if (ok) emit changed();
        return ok;
    });
}

QFuture<bool> RentalService::prolong(qint64 rentalId, const QDateTime& newDueDate) {
    return QtConcurrent::run([this, rentalId, newDueDate] {
        const bool ok = RentalRepository{}.prolong(rentalId, newDueDate);
        if (ok) emit changed();
        return ok;
    });
}

} // namespace Librarian
