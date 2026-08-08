#pragma once
#include "core/models/Book.h"
#include <QObject>
#include <QFuture>
#include <QList>
#include <optional>

namespace Librarian {

class BookService : public QObject {
    Q_OBJECT
public:
    explicit BookService(QObject* parent = nullptr);

    QFuture<QList<Book>>             getAll();
    QFuture<QList<Book>>             search(const BookSearchCriteria& criteria);
    QFuture<QList<BookAvailability>> searchAvailable(const BookSearchCriteria& criteria);
    QFuture<std::optional<Book>>     getById(qint64 id);

    QFuture<Book> save(const Book& book);   // create or update
    QFuture<bool> remove(qint64 id);

signals:
    void changed();
};

} // namespace Librarian
