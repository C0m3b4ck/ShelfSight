#pragma once
#include "core/models/Book.h"
#include <QList>
#include <optional>

namespace Librarian {

class BookRepository {
public:
    BookRepository() = default;

    std::optional<Book> findById(qint64 id) const;
    std::optional<Book> findByIsbn(const QString& isbn) const;
    std::optional<Book> findByInternalCode(const QString& code) const;
    QList<Book>         findAll() const;
    QList<Book>         search(const BookSearchCriteria& criteria) const;

    // Returns each book annotated with availability (no active rental)
    QList<BookAvailability> searchAvailable(const BookSearchCriteria& criteria) const;

    Book save(const Book& book);   // INSERT or UPDATE
    bool remove(qint64 id);
};

} // namespace Librarian
