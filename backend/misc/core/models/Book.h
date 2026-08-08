#pragma once
/**
 * Book.h — Data model for books in the library catalog.
 *
 * Tutorial note — internal_code as the physical-copy key:
 *   A school library can own multiple physical copies of the same book, each
 *   with the same ISBN but its own spine label (e.g. "LIB-001", "LIB-002").
 *   internal_code is that spine label: unique per physical copy, assigned by
 *   the librarian when the copy is added to the catalog.
 *   ISBN is still stored (for catalog look-up), but is no longer UNIQUE in the
 *   database — two rows with isbn="978-..." are two different physical copies.
 */
#include <QString>
#include <QDateTime>
#include <optional>

namespace Librarian {

struct Book {
    qint64    id{-1};
    QString   internalCode;  ///< Library spine code, unique per physical copy.
    QString   title;
    QString   author;
    QString   isbn;          ///< May be empty; not unique — multiple copies share one ISBN.
    QString   language;
    int       year{0};       ///< Publication year; 0 = unknown.
    QString   publisher;
    QDateTime createdAt;

    bool isValid()     const { return id > 0; }
    bool isNewRecord() const { return id < 0; }
};

/**
 * Search filter passed from the UI to BookService / BookRepository.
 *
 * Tutorial note — value semantics for query parameters:
 *   Passing a criteria struct (instead of a long parameter list) makes it
 *   easy to extend search without changing every call site, and the struct
 *   copies cheaply across thread boundaries inside QtConcurrent::run().
 */
struct BookSearchCriteria {
    QString            title;
    QString            author;
    QString            isbn;
    QString            internalCode;
    QString            language;
    std::optional<int> yearFrom;   ///< Inclusive lower bound on publication year.
    std::optional<int> yearTo;     ///< Inclusive upper bound on publication year.
};

/**
 * BookAvailability annotates a Book with its current rental state.
 * Produced by BookRepository::searchAvailable() via a SQL subquery —
 * no additional round-trips to the database needed in the UI.
 */
struct BookAvailability {
    Book book;
    bool available{false};     ///< True when no active (un-returned) rental exists.
    int  activeRentals{0};     ///< Number of concurrent active rentals (normally 0 or 1).
};

} // namespace Librarian
