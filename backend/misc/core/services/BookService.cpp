#include "core/services/BookService.h"
#include "core/repositories/BookRepository.h"
#include <QtConcurrent/QtConcurrent>

namespace Librarian {

BookService::BookService(QObject* parent) : QObject(parent) {}

QFuture<QList<Book>> BookService::getAll() {
    return QtConcurrent::run([] { return BookRepository{}.findAll(); });
}

QFuture<QList<Book>> BookService::search(const BookSearchCriteria& criteria) {
    return QtConcurrent::run([criteria] { return BookRepository{}.search(criteria); });
}

QFuture<QList<BookAvailability>> BookService::searchAvailable(const BookSearchCriteria& criteria) {
    return QtConcurrent::run([criteria] { return BookRepository{}.searchAvailable(criteria); });
}

QFuture<std::optional<Book>> BookService::getById(qint64 id) {
    return QtConcurrent::run([id] { return BookRepository{}.findById(id); });
}

QFuture<Book> BookService::save(const Book& book) {
    return QtConcurrent::run([this, book] {
        auto result = BookRepository{}.save(book);
        if (result.isValid()) emit changed();
        return result;
    });
}

QFuture<bool> BookService::remove(qint64 id) {
    return QtConcurrent::run([this, id] {
        const bool ok = BookRepository{}.remove(id);
        if (ok) emit changed();
        return ok;
    });
}

} // namespace Librarian
