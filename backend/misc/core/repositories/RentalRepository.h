#pragma once
/**
 * RentalRepository.h — data access for the rentals table.
 *
 * Tutorial note — JOIN queries vs. separate lookups:
 *   The rentals table only stores foreign key IDs (user_id, book_id).
 *   When the UI needs user names and book titles, there are two options:
 *     a) Fetch the rental, then fetch user and book separately (3 queries).
 *     b) Run one JOIN query that returns all columns at once (1 query).
 *   We use approach (b) for the view methods (findAll, findAllActive, etc.)
 *   which return RentalView — a denormalised struct.  This is more efficient
 *   and avoids the "N+1 queries" problem.
 *
 * Tutorial note — SQLite date arithmetic:
 *   SQLite has no native date type; dates are stored as ISO 8601 strings
 *   ("2025-06-01T10:00:00").  The built-in datetime() function understands
 *   this format, so comparisons like `r.due_date < datetime('now')` work
 *   correctly for overdue detection.
 */
#include "core/models/Rental.h"
#include <QList>
#include <optional>

namespace Librarian {

class RentalRepository {
public:
    RentalRepository() = default;

    std::optional<Rental>  findById(qint64 id) const;
    QList<Rental>          findByUser(qint64 userId) const;
    QList<Rental>          findByBook(qint64 bookId) const;

    /** Active = not returned AND not lost. */
    QList<RentalView>      findAllActive() const;

    /** Overdue = active AND due_date < now. */
    QList<RentalView>      findOverdue() const;

    /** Returned = returned_at IS NOT NULL — rental completed successfully. */
    QList<RentalView>      findReturned() const;

    /** All rentals regardless of status, newest first. */
    QList<RentalView>      findAll() const;

    /** All rentals for one physical book copy, newest first. */
    QList<RentalView>      findViewsByBook(qint64 bookId) const;

    /** INSERT or UPDATE a rental record. */
    Rental save(const Rental& rental);

    /** Sets returned_at to the current timestamp. Fails if already returned. */
    bool markReturned(qint64 rentalId);

    /** Sets is_lost=1 — the book will not be returned. */
    bool markLost(qint64 rentalId);

    /**
     * Updates due_date and increments prolonged_count.
     * Fails (returns false) if the rental is already returned or lost.
     */
    bool prolong(qint64 rentalId, const QDateTime& newDueDate);

    // ── Report queries ────────────────────────────────────────────────────────
    /** Returns books ranked by total rental count, most popular first. */
    QList<PopularBookReport>   popularBooks(int limit = 20) const;

    /**
     * Returns currently-overdue rentals ranked by how many days past due,
     * longest delay first.
     */
    QList<DelayedRentalReport> longestDelays(int limit = 20) const;
};

} // namespace Librarian
