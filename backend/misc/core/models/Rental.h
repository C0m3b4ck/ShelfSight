#pragma once
/**
 * Rental.h — Data models for book rentals and related reports.
 *
 * Tutorial note — why plain structs?
 *   Qt's QObject system (with signals/slots and the meta-object compiler)
 *   is powerful but adds overhead and restrictions (non-copyable, heap-only).
 *   Plain C++ structs are lightweight, copyable, and work naturally with
 *   STL containers and Qt's QtConcurrent — ideal for data transfer objects
 *   (DTOs) that travel between the database layer and the UI.
 *
 *   Rule of thumb: data lives in plain structs; behaviour (signals, slots,
 *   event handling) lives in QObject-derived classes.
 */
#include <QDateTime>
#include <QString>
#include <optional>

namespace Librarian {

/**
 * RentalStatus — the four mutually-exclusive states a rental can be in.
 *
 * Tutorial note — enums vs. ad-hoc strings:
 *   Encoding status as a scoped enum (enum class) rather than a magic string
 *   or integer gives us:
 *     • Compile-time exhaustiveness checks in switch statements.
 *     • A single authoritative definition (change here, fix everywhere).
 *     • Readable code: RentalStatus::Returned beats comparing to "Returned".
 */
enum class RentalStatus {
    Active,    ///< Currently rented, within the due date.
    Overdue,   ///< Rented, past the due date — follow-up needed.
    Returned,  ///< Successfully returned — rental complete.
    Lost       ///< The user reported the book lost; rental closed.
};

/** Returns a human-readable label for display in the UI. */
inline QString rentalStatusLabel(RentalStatus s) {
    switch (s) {
        case RentalStatus::Active:   return "⏳ Active";
        case RentalStatus::Overdue:  return "⚠️ Overdue";
        case RentalStatus::Returned: return "✅ Returned";
        case RentalStatus::Lost:     return "🚫 Lost";
    }
    return {};
}

// ── Core rental record (maps 1:1 to the rentals table) ───────────────────────

struct Rental {
    qint64                   id{-1};
    qint64                   userId{-1};
    qint64                   bookId{-1};
    QDateTime                rentedAt;
    QDateTime                dueDate;
    std::optional<QDateTime> returnedAt; ///< Populated when the book is returned.
    bool                     isLost{false};
    int                      prolongedCount{0};

    bool isValid()     const { return id > 0; }
    bool isNewRecord() const { return id < 0; }

    /** Rental is "active" when neither returned nor lost. */
    bool isActive() const { return !returnedAt.has_value() && !isLost; }

    /**
     * Compute the current status from the rental fields.
     *
     * Tutorial note — computed property:
     *   status() derives from other fields rather than storing a separate
     *   column, eliminating the risk of the DB ever holding a contradictory
     *   state (e.g. returned_at set but is_lost = 1).
     *   This is the "derived attribute" pattern from DDD.
     */
    RentalStatus status() const {
        if (isLost)              return RentalStatus::Lost;
        if (returnedAt)          return RentalStatus::Returned;
        if (QDateTime::currentDateTime() > dueDate) return RentalStatus::Overdue;
        return RentalStatus::Active;
    }

    /** How many days past the due date (0 if not overdue). */
    qint64 daysOverdue() const {
        if (status() != RentalStatus::Overdue) return 0;
        return dueDate.daysTo(QDateTime::currentDateTime());
    }
};

// ── Denormalised view used in the UI — joins users + books ───────────────────
/**
 * RentalView bundles a Rental with the names from the related User and Book
 * rows so the UI never has to do its own joins.
 *
 * Tutorial note — the N+1 problem:
 *   If we stored only IDs and fetched user/book details per row in the UI
 *   we would trigger one DB query per row ("N+1 queries").  Instead,
 *   RentalRepository runs a single JOIN query and returns ready-made
 *   RentalView objects — much more efficient.
 */
struct RentalView {
    Rental  rental;
    QString userLogin;
    QString userFullName;
    QString bookTitle;
    QString bookAuthor;
    QString bookIsbn;
};

// ── Report result structs (returned by ReportService) ────────────────────────

struct PopularBookReport {
    qint64  bookId{-1};
    QString title;
    QString author;
    int     totalRentals{0};
};

struct DelayedRentalReport {
    qint64  rentalId{-1};
    QString userFullName;
    QString userLogin;
    QString bookTitle;
    qint64  daysOverdue{0};
};

} // namespace Librarian
