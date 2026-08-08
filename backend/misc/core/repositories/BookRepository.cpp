/**
 * BookRepository.cpp
 *
 * Tutorial note — dynamic WHERE clause construction (buildSearchWhere):
 *   The search form has multiple optional fields.  If we wrote separate
 *   queries for every possible combination (title only, author only,
 *   title+author, …) we would need 2^N queries for N fields.
 *
 *   Instead, buildSearchWhere() builds the WHERE clause dynamically:
 *     - For each non-empty field it appends a LIKE predicate.
 *     - It binds the value with a named parameter (":title", etc.).
 *     - If no fields are filled in, it returns an empty string and the query
 *       becomes "SELECT * FROM books ORDER BY title" (returns all books).
 *
 *   This is a safe approach because we use parameterised queries throughout —
 *   user input never touches the SQL string itself, preventing SQL injection.
 *
 * Tutorial note — COLLATE NOCASE:
 *   SQLite's default string comparison is case-sensitive.  Adding
 *   COLLATE NOCASE to LIKE comparisons makes "tolkien" match "Tolkien".
 *   The idx_books_author index was created with COLLATE NOCASE so SQLite
 *   can still use the index for these comparisons.
 */
#include "core/repositories/BookRepository.h"
#include "core/repositories/RepositoryUtils.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

namespace Librarian {

namespace {

using detail::db;
using detail::nullableString;

Book fromQuery(const QSqlQuery& q) {
    Book b;
    b.id           = q.value("id").toLongLong();
    b.internalCode = q.value("internal_code").toString();
    b.title        = q.value("title").toString();
    b.author       = q.value("author").toString();
    b.isbn         = q.value("isbn").toString();
    b.language     = q.value("language").toString();
    b.year         = q.value("year").toInt();
    b.publisher    = q.value("publisher").toString();
    b.createdAt    = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);
    return b;
}

QString buildSearchWhere(const BookSearchCriteria& c, QSqlQuery& q) {
    QStringList clauses;

    auto bind = [&](const QString& col, const QString& val, const QString& param) {
        if (!val.isEmpty()) {
            clauses << QString("%1 LIKE %2 COLLATE NOCASE").arg(col, param);
            q.bindValue(param, '%' + val + '%');
        }
    };

    bind("internal_code", c.internalCode, ":code");
    bind("title",         c.title,        ":title");
    bind("author",        c.author,       ":author");
    bind("isbn",          c.isbn,         ":isbn");
    bind("language",      c.language,     ":lang");

    if (c.yearFrom) { clauses << "year >= :yf"; q.bindValue(":yf", *c.yearFrom); }
    if (c.yearTo)   { clauses << "year <= :yt"; q.bindValue(":yt", *c.yearTo);   }

    return clauses.isEmpty() ? QString{} : "WHERE " + clauses.join(" AND ");
}

} // anonymous namespace

std::optional<Book> BookRepository::findById(qint64 id) const {
    QSqlQuery q(db());
    q.prepare("SELECT * FROM books WHERE id = :id");
    q.bindValue(":id", id);
    if (q.exec() && q.next()) return fromQuery(q);
    return std::nullopt;
}

std::optional<Book> BookRepository::findByIsbn(const QString& isbn) const {
    QSqlQuery q(db());
    q.prepare("SELECT * FROM books WHERE isbn = :isbn LIMIT 1");
    q.bindValue(":isbn", isbn);
    if (q.exec() && q.next()) return fromQuery(q);
    return std::nullopt;
}

std::optional<Book> BookRepository::findByInternalCode(const QString& code) const {
    QSqlQuery q(db());
    q.prepare("SELECT * FROM books WHERE internal_code = :code");
    q.bindValue(":code", code);
    if (q.exec() && q.next()) return fromQuery(q);
    return std::nullopt;
}

QList<Book> BookRepository::findAll() const {
    QList<Book> books;
    QSqlQuery q("SELECT * FROM books ORDER BY title COLLATE NOCASE", db());
    while (q.next()) books.append(fromQuery(q));
    return books;
}

QList<Book> BookRepository::search(const BookSearchCriteria& criteria) const {
    QList<Book> books;
    QSqlQuery q(db());
    const QString where = buildSearchWhere(criteria, q);
    q.prepare(QString("SELECT * FROM books %1 ORDER BY title COLLATE NOCASE").arg(where));
    if (q.exec())
        while (q.next()) books.append(fromQuery(q));
    return books;
}

QList<BookAvailability> BookRepository::searchAvailable(const BookSearchCriteria& criteria) const {
    QList<BookAvailability> result;
    QSqlQuery q(db());

    const QString where = buildSearchWhere(criteria, q);

    // Count active rentals per book to determine availability
    q.prepare(QString(
        "SELECT b.*, "
        "  (SELECT COUNT(*) FROM rentals r "
        "   WHERE r.book_id=b.id AND r.returned_at IS NULL AND r.is_lost=0) AS active "
        "FROM books b %1 ORDER BY b.title COLLATE NOCASE"
    ).arg(where));

    if (q.exec()) {
        while (q.next()) {
            BookAvailability ba;
            ba.book           = fromQuery(q);
            ba.activeRentals  = q.value("active").toInt();
            ba.available      = ba.activeRentals == 0;
            result.append(ba);
        }
    }
    return result;
}

Book BookRepository::save(const Book& book) {
    QSqlQuery q(db());

    if (book.isNewRecord()) {
        q.prepare(
            "INSERT INTO books (internal_code, title, author, isbn, language, year, publisher) "
            "VALUES (:code, :title, :author, :isbn, :lang, :year, :pub)"
        );
    } else {
        q.prepare(
            "UPDATE books SET internal_code=:code, title=:title, author=:author, isbn=:isbn, "
            "language=:lang, year=:year, publisher=:pub WHERE id=:id"
        );
        q.bindValue(":id", book.id);
    }

    q.bindValue(":code",   book.internalCode);
    q.bindValue(":title",  book.title);
    q.bindValue(":author", book.author);
    q.bindValue(":isbn",   nullableString(book.isbn));
    q.bindValue(":lang",   nullableString(book.language));
    q.bindValue(":year",   book.year > 0 ? QVariant(book.year) : QVariant(QMetaType(QMetaType::Int)));
    q.bindValue(":pub",    nullableString(book.publisher));

    if (!q.exec()) {
        qWarning() << "BookRepository::save failed:" << q.lastError().text();
        return {};
    }

    Book saved = book;
    if (book.isNewRecord()) saved.id = q.lastInsertId().toLongLong();
    return saved;
}

bool BookRepository::remove(qint64 id) {
    QSqlQuery q(db());
    // Blocked by FK RESTRICT if active rentals exist — intentional
    q.prepare("DELETE FROM books WHERE id=:id");
    q.bindValue(":id", id);
    if (!q.exec()) {
        qWarning() << "BookRepository::remove failed:" << q.lastError().text();
        return false;
    }
    return true;
}

} // namespace Librarian
