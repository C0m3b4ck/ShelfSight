#pragma once

#include <QString>
#include <QDateTime>
#include <vector>
#include <optional>

namespace Domain {

struct Book {
    QString id = 0;
    QString title;
    QString author;
    QString location;
    QString category;
    QString status;
    QDateTime createdAt;
    QDateTime updatedAt;

    bool isValid() const {
        return !title.isEmpty() && !author.isEmpty() && id > 0;
    }

    QString toDisplayString() const {
        return QString("%1 | %2 | %3 | %4 | %5 | ID: %6")
            .arg(title, author, location, category, status).arg(id);
    }
};

struct Reader {
    QString id = 0;
    QString name;
    QString surname;
    short grade = 0;
    QChar classGroup = 'A';
    QString studentId;
    QDateTime createdAt;
    QDateTime updatedAt;

    bool isValid() const {
        return !name.isEmpty() && !surname.isEmpty() && id > 0;
    }

    QString toDisplayString() const {
        return QString("%1 | %2 | %3 | %4 | %5")
            .arg(name, surname, QString::number(grade), classGroup, studentId);
    }

    QString fullName() const {
        return QString("%1 %2").arg(name, surname);
    }
};

struct Category {
    int id = 0;
    QString name;

    bool isValid() const {
        return !name.isEmpty();
    }
};

struct Location {
    int id = 0;
    QString name;

    bool isValid() const {
        return !name.isEmpty();
    }
};

struct User {
    enum Role { UserRole = 1, Admin = 2, SuperAdmin = 3 };

    QString id = 0;
    QString username;
    QString passwordHash;
    QString salt;
    Role role = UserRole;
    QDateTime createdAt;
    QDateTime lastLogin;

    bool isValid() const {
        return !username.isEmpty() && !passwordHash.isEmpty() && id > 0;
    }
};

struct Loan {
    QString id = 0;
    QString bookId = 0;
    QString readerId = 0;
    QDateTime loanDate;
    QDateTime dueDate;
    QDateTime returnDate;
    QString status;

    bool isActive() const {
        return returnDate.isNull() && status == "active";
    }

    bool isOverdue() const {
        return isActive() && QDateTime::currentDateTime() > dueDate;
    }
};

struct UndoEntry {
    enum Type { Add, Edit, Remove };
    enum Entity { BookEntity, ReaderEntity, CategoryEntity, LocationEntity };

    Type type;
    Entity entity;
    QString previousData;
    QString currentData;
    QDateTime timestamp;
};

} // namespace Domain

namespace DTO {

struct BookDTO {
    QString id = 0;
    QString title;
    QString author;
    QString location;
    QString category;
    QString status;
    QString createdAt;
    QString updatedAt;

    bool isValid() const {
        return !title.isEmpty() && !author.isEmpty() && !id.isEmpty();
    }

    QString toDisplayString() const {
        return QString("%1 | %2 | %3 | %4 | %5 | ID: %6")
            .arg(title, author, location, category, status).arg(id);
    }

    Domain::Book toDomain() const {
        Domain::Book book;
        book.id = id;
        book.title = title;
        book.author = author;
        book.location = location;
        book.category = category;
        book.status = status;
        book.createdAt = QDateTime::fromString(createdAt, Qt::ISODate);
        book.updatedAt = QDateTime::fromString(updatedAt, Qt::ISODate);
        return book;
    }

    static BookDTO fromDomain(const Domain::Book& book) {
        BookDTO dto;
        dto.id = book.id;
        dto.title = book.title;
        dto.author = book.author;
        dto.location = book.location;
        dto.category = book.category;
        dto.status = book.status;
        dto.createdAt = book.createdAt.toString(Qt::ISODate);
        dto.updatedAt = book.updatedAt.toString(Qt::ISODate);
        return dto;
    }
};

struct ReaderDTO {
    QString id = 0;
    QString name;
    QString surname;
    short grade = 0;
    QChar classGroup = 'A';
    QString studentId;
    QString createdAt;
    QString updatedAt;

    bool isValid() const {
        return !name.isEmpty() && !surname.isEmpty() && !id.isEmpty();
    }

    QString toDisplayString() const {
        return QString("%1 | %2 | %3 | %4 | %5")
            .arg(name, surname, QString::number(grade), classGroup, studentId);
    }

    QString fullName() const {
        return QString("%1 %2").arg(name, surname);
    }

    Domain::Reader toDomain() const {
        Domain::Reader reader;
        reader.id = id;
        reader.name = name;
        reader.surname = surname;
        reader.grade = grade;
        reader.classGroup = classGroup;
        reader.studentId = studentId;
        reader.createdAt = QDateTime::fromString(createdAt, Qt::ISODate);
        reader.updatedAt = QDateTime::fromString(updatedAt, Qt::ISODate);
        return reader;
    }

    static ReaderDTO fromDomain(const Domain::Reader& reader) {
        ReaderDTO dto;
        dto.id = reader.id;
        dto.name = reader.name;
        dto.surname = reader.surname;
        dto.grade = reader.grade;
        dto.classGroup = reader.classGroup;
        dto.studentId = reader.studentId;
        dto.createdAt = reader.createdAt.toString(Qt::ISODate);
        dto.updatedAt = reader.updatedAt.toString(Qt::ISODate);
        return dto;
    }
};

struct LoanDTO {
    QString id = 0;
    QString bookId = 0;
    QString readerId = 0;
    QString loanDate;
    QString dueDate;
    QString returnDate;
    QString status;

    bool isActive() const {
        return returnDate.isEmpty() && status == "active";
    }

    bool isOverdue() const {
        if (!isActive()) return false;
        QDateTime due = QDateTime::fromString(dueDate, Qt::ISODate);
        return QDateTime::currentDateTime() > due;
    }

    QString toDisplayString() const {
        return QString("Loan ID: %1 | Book: %2 | Reader: %3 | Loan: %4 | Due: %5 | Return: %6 | Status: %7")
            .arg(id).arg(bookId).arg(readerId).arg(loanDate).arg(dueDate).arg(returnDate).arg(status);
    }

    Domain::Loan toDomain() const {
        Domain::Loan loan;
        loan.id = id;
        loan.bookId = bookId;
        loan.readerId = readerId;
        loan.loanDate = QDateTime::fromString(loanDate, Qt::ISODate);
        loan.dueDate = QDateTime::fromString(dueDate, Qt::ISODate);
        loan.returnDate = returnDate.isEmpty() ? QDateTime() : QDateTime::fromString(returnDate, Qt::ISODate);
        loan.status = status;
        return loan;
    }

    static LoanDTO fromDomain(const Domain::Loan& loan) {
        LoanDTO dto;
        dto.id = loan.id;
        dto.bookId = loan.bookId;
        dto.readerId = loan.readerId;
        dto.loanDate = loan.loanDate.toString(Qt::ISODate);
        dto.dueDate = loan.dueDate.toString(Qt::ISODate);
        dto.returnDate = loan.returnDate.isNull() ? "" : loan.returnDate.toString(Qt::ISODate);
        dto.status = loan.status;
        return dto;
    }
};

struct CategoryDTO {
    //QString id = 0;
    QString name;

    bool isValid() const {
        return !name.isEmpty();
    }

    Domain::Category toDomain() const {
        Domain::Category cat;
        //cat.id = id;
        cat.name = name;
        return cat;
    }

    static CategoryDTO fromDomain(const Domain::Category& cat) {
        CategoryDTO dto;
        //dto.id = cat.id;
        dto.name = cat.name;
        return dto;
    }
};

struct LocationDTO {
    //QString id = 0;
    QString name;

    bool isValid() const {
        return !name.isEmpty();
    }

    Domain::Location toDomain() const {
        Domain::Location loc;
        //loc.id = id;
        loc.name = name;
        return loc;
    }

    static LocationDTO fromDomain(const Domain::Location& loc) {
        LocationDTO dto;
        //dto.id = loc.id;
        dto.name = loc.name;
        return dto;
    }
};

} // namespace DTO