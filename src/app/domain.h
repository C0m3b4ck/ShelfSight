#pragma once

#include <string>
#include <chrono>
#include <vector>
#include <optional>
#include <sstream>
#include <iomanip>

namespace Domain {

using DateTime = std::chrono::system_clock::time_point;

inline DateTime now() {
    return std::chrono::system_clock::now();
}

inline std::string toISOString(const DateTime& dt) {
    auto t = std::chrono::system_clock::to_time_t(dt);
    std::stringstream ss;
    ss << std::put_time(std::gmtime(&t), "%Y-%m-%dT%H:%M:%SZ");
    return ss.str();
}

inline DateTime fromISOString(const std::string& str) {
    std::tm tm = {};
    std::istringstream ss(str);
    ss >> std::get_time(&tm, "%Y-%m-%dT%H:%M:%SZ");
    if (ss.fail()) {
        return DateTime{};
    }
    return std::chrono::system_clock::from_time_t(std::mktime(&tm));
}

inline bool isNull(const DateTime& dt) {
    return dt == DateTime{};
}

// Helper for string ID validation
inline bool isValidId(const std::string& id) {
    return !id.empty() && id != "0";
}

struct Book {
    std::string id;
    std::string title;
    std::string author;
    std::string location;
    std::string category;
    std::string status;
    DateTime createdAt;
    DateTime updatedAt;

    bool isValid() const {
        return !title.empty() && !author.empty() && isValidId(id);
    }

    std::string toDisplayString() const {
        return title + " | " + author + " | " + location + " | " + category + " | " + status + " | ID: " + id;
    }
};

struct Reader {
    std::string id;
    std::string name;
    std::string surname;
    short grade = 0;
    char classGroup = 'A';
    std::string studentId;
    DateTime createdAt;
    DateTime updatedAt;

    bool isValid() const {
        return !name.empty() && !surname.empty() && isValidId(id);
    }

    std::string toDisplayString() const {
        return name + " | " + surname + " | " + std::to_string(grade) + " | " + classGroup + " | " + studentId;
    }

    std::string fullName() const {
        return name + " " + surname;
    }
};

struct Category {
    std::string id;
    std::string name;

    bool isValid() const {
        return !name.empty() && isValidId(id);
    }
};

struct Location {
    std::string id;
    std::string name;

    bool isValid() const {
        return !name.empty() && isValidId(id);
    }
};

struct User {
    enum class Role { UserRole = 1, Admin = 2, SuperAdmin = 3 };

    std::string id;
    std::string username;
    std::string passwordHash;
    std::string salt;
    Role role = Role::UserRole;
    DateTime createdAt;
    DateTime lastLogin;

    bool isValid() const {
        return !username.empty() && !passwordHash.empty() && isValidId(id);
    }
};

struct Loan {
    std::string id;
    std::string bookId;
    std::string readerId;
    DateTime loanDate;
    DateTime dueDate;
    DateTime returnDate;
    std::string status;

    bool isActive() const {
        return isNull(returnDate) && status == "active";
    }

    bool isOverdue() const {
        return isActive() && now() > dueDate;
    }

    std::string toDisplayString() const {
        return "Loan ID: " + id + " | Book: " + bookId + " | Reader: " + readerId +
               " | Loan: " + Domain::toISOString(loanDate) + " | Due: " + Domain::toISOString(dueDate) +
               " | Return: " + (isNull(returnDate) ? "N/A" : Domain::toISOString(returnDate)) + " | Status: " + status;
    }
};

struct UndoEntry {
    enum class Type { Add, Edit, Remove };
    enum class Entity { BookEntity, ReaderEntity, CategoryEntity, LocationEntity };

    Type type;
    Entity entity;
    std::string previousData;
    std::string currentData;
    DateTime timestamp;
};

} // namespace Domain

namespace DTO {

struct BookDTO {
    std::string id;
    std::string title;
    std::string author;
    std::string location;
    std::string category;
    std::string status;
    std::string createdAt;
    std::string updatedAt;

    bool isValid() const {
        return !title.empty() && !author.empty() && Domain::isValidId(id);
    }

    std::string toDisplayString() const {
        return title + " | " + author + " | " + location + " | " + category + " | " + status + " | ID: " + id;
    }

    Domain::Book toDomain() const {
        Domain::Book book;
        book.id = id;
        book.title = title;
        book.author = author;
        book.location = location;
        book.category = category;
        book.status = status;
        book.createdAt = Domain::fromISOString(createdAt);
        book.updatedAt = Domain::fromISOString(updatedAt);
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
        dto.createdAt = Domain::toISOString(book.createdAt);
        dto.updatedAt = Domain::toISOString(book.updatedAt);
        return dto;
    }
};

struct ReaderDTO {
    std::string id;
    std::string name;
    std::string surname;
    short grade = 0;
    char classGroup = 'A';
    std::string studentId;
    std::string createdAt;
    std::string updatedAt;

    bool isValid() const {
        return !name.empty() && !surname.empty() && Domain::isValidId(id);
    }

    std::string toDisplayString() const {
        return name + " | " + surname + " | " + std::to_string(grade) + " | " + classGroup + " | " + studentId;
    }

    std::string fullName() const {
        return name + " " + surname;
    }

    Domain::Reader toDomain() const {
        Domain::Reader reader;
        reader.id = id;
        reader.name = name;
        reader.surname = surname;
        reader.grade = grade;
        reader.classGroup = classGroup;
        reader.studentId = studentId;
        reader.createdAt = Domain::fromISOString(createdAt);
        reader.updatedAt = Domain::fromISOString(updatedAt);
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
        dto.createdAt = Domain::toISOString(reader.createdAt);
        dto.updatedAt = Domain::toISOString(reader.updatedAt);
        return dto;
    }
};

struct LoanDTO {
    std::string id;
    std::string bookId;
    std::string readerId;
    std::string loanDate;
    std::string dueDate;
    std::string returnDate;
    std::string status;

    bool isActive() const {
        return returnDate.empty() && status == "active";
    }

    bool isOverdue() const {
        if (!isActive()) return false;
        auto due = Domain::fromISOString(dueDate);
        return Domain::now() > due;
    }

    std::string toDisplayString() const {
        return "Loan ID: " + id + " | Book: " + bookId + " | Reader: " + readerId + 
               " | Loan: " + loanDate + " | Due: " + dueDate + " | Return: " + returnDate + " | Status: " + status;
    }

    Domain::Loan toDomain() const {
        Domain::Loan loan;
        loan.id = id;
        loan.bookId = bookId;
        loan.readerId = readerId;
        loan.loanDate = Domain::fromISOString(loanDate);
        loan.dueDate = Domain::fromISOString(dueDate);
        loan.returnDate = returnDate.empty() ? Domain::DateTime{} : Domain::fromISOString(returnDate);
        loan.status = status;
        return loan;
    }

    static LoanDTO fromDomain(const Domain::Loan& loan) {
        LoanDTO dto;
        dto.id = loan.id;
        dto.bookId = loan.bookId;
        dto.readerId = loan.readerId;
        dto.loanDate = Domain::toISOString(loan.loanDate);
        dto.dueDate = Domain::toISOString(loan.dueDate);
        dto.returnDate = Domain::isNull(loan.returnDate) ? "" : Domain::toISOString(loan.returnDate);
        dto.status = loan.status;
        return dto;
    }
};

struct CategoryDTO {
    std::string id;
    std::string name;

    bool isValid() const {
        return !name.empty() && Domain::isValidId(id);
    }

    Domain::Category toDomain() const {
        Domain::Category cat;
        cat.id = id;
        cat.name = name;
        return cat;
    }

    static CategoryDTO fromDomain(const Domain::Category& cat) {
        CategoryDTO dto;
        dto.id = cat.id;
        dto.name = cat.name;
        return dto;
    }
};

struct LocationDTO {
    std::string id;
    std::string name;

    bool isValid() const {
        return !name.empty() && Domain::isValidId(id);
    }

    Domain::Location toDomain() const {
        Domain::Location loc;
        loc.id = id;
        loc.name = name;
        return loc;
    }

    static LocationDTO fromDomain(const Domain::Location& loc) {
        LocationDTO dto;
        dto.id = loc.id;
        dto.name = loc.name;
        return dto;
    }
};

struct UserDTO {
    std::string id;
    std::string username;
    std::string password;
    std::optional<Domain::User::Role> role;

    bool isValid() const {
        return !username.empty() && !password.empty() && Domain::isValidId(id);
    }

    Domain::User toDomain() const {
        Domain::User user;
        user.id = id.empty() ? std::to_string(std::chrono::duration_cast<std::chrono::milliseconds>(
            std::chrono::system_clock::now().time_since_epoch()).count()) : id;
        user.username = username;
        user.passwordHash = password;
        user.role = role.value_or(Domain::User::Role::UserRole);
        user.createdAt = Domain::now();
        return user;
    }
};

} // namespace DTO