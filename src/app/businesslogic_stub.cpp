#include "businesslogic.h"
#include "domain.h"
#include <QDebug>
#include <QDateTime>
#include <QCryptographicHash>
#include <QRandomGenerator>

namespace BusinessLogic {

class StubDatabaseManager : public IDatabaseManager {
    QString m_booksDb, m_readersDb, m_loansDb;
    bool m_connected = false;

public:
    bool initialize(const QString& booksDb, const QString& readersDb, const QString& loansDb) override {
        m_booksDb = booksDb;
        m_readersDb = readersDb;
        m_loansDb = loansDb;
        m_connected = true;
        qDebug() << "Stub DB initialized:" << booksDb << readersDb << loansDb;
        return true;
    }

    void shutdown() override {
        m_connected = false;
    }

    bool isConnected() const override { return m_connected; }

    bool isBooksDbSelected() const override { return !m_booksDb.isEmpty(); }
    bool isReadersDbSelected() const override { return !m_readersDb.isEmpty(); }
    bool isLoansDbSelected() const override { return !m_loansDb.isEmpty(); }
};

class StubBookService : public IBookService {
    std::vector<Domain::Book> m_books;
    std::vector<Domain::Book> m_removedBooks;
    int m_nextId = 1;

public:
    std::vector<Domain::Book> getAllBooks() override { return m_books; }

    std::optional<Domain::Book> getBookById(int id) override {
        for (auto& b : m_books) if (b.id == id) return b;
        return std::nullopt;
    }

    std::vector<Domain::Book> searchBooks(const QString& term, const QString& field) override {
        std::vector<Domain::Book> results;
        QString t = term.toLower();
        for (auto& b : m_books) {
            bool match = false;
            if (field.isEmpty() || field == "title") match |= b.title.toLower().contains(t);
            if (field.isEmpty() || field == "author") match |= b.author.toLower().contains(t);
            if (field.isEmpty() || field == "location") match |= b.location.toLower().contains(t);
            if (field.isEmpty() || field == "category") match |= b.category.toLower().contains(t);
            if (field.isEmpty() || field == "status") match |= b.status.toLower().contains(t);
            if (field == "id") match |= QString::number(b.id).contains(t);
            if (match) results.push_back(b);
        }
        return results;
    }

    bool addBook(const Domain::Book& book) override {
        Domain::Book b = book;
        b.id = m_nextId++;
        b.createdAt = QDateTime::currentDateTime();
        b.updatedAt = b.createdAt;
        m_books.push_back(b);
        return true;
    }

    bool updateBook(const Domain::Book& book) override {
        for (auto& b : m_books) {
            if (b.id == book.id) {
                b = book;
                b.updatedAt = QDateTime::currentDateTime();
                return true;
            }
        }
        return false;
    }

    bool removeBook(int id) override {
        for (auto it = m_books.begin(); it != m_books.end(); ++it) {
            if (it->id == id) {
                Domain::Book removed = *it;
                m_removedBooks.push_back(removed);
                m_books.erase(it);
                return true;
            }
        }
        return false;
    }

    std::vector<Domain::Book> getRemovedBooks() override { return m_removedBooks; }

    bool restoreBook(int id) override {
        for (auto it = m_removedBooks.begin(); it != m_removedBooks.end(); ++it) {
            if (it->id == id) {
                m_books.push_back(*it);
                m_removedBooks.erase(it);
                return true;
            }
        }
        return false;
    }
};

class StubReaderService : public IReaderService {
    std::vector<Domain::Reader> m_readers;
    std::vector<Domain::Reader> m_removedReaders;
    int m_nextId = 1;

public:
    std::vector<Domain::Reader> getAllReaders() override { return m_readers; }

    std::optional<Domain::Reader> getReaderById(int id) override {
        for (auto& r : m_readers) if (r.id == id) return r;
        return std::nullopt;
    }

    std::vector<Domain::Reader> searchReaders(const QString& term, const QString& field) override {
        std::vector<Domain::Reader> results;
        QString t = term.toLower();
        for (auto& r : m_readers) {
            bool match = false;
            if (field.isEmpty() || field == "name") match |= r.name.toLower().contains(t);
            if (field.isEmpty() || field == "surname") match |= r.surname.toLower().contains(t);
            if (field == "grade") match |= QString::number(r.grade).contains(t);
            if (field == "class") match |= QString(r.classGroup).contains(t);
            if (field == "id") match |= QString::number(r.id).contains(t);
            if (match) results.push_back(r);
        }
        return results;
    }

    bool addReader(const Domain::Reader& reader) override {
        Domain::Reader r = reader;
        r.id = m_nextId++;
        r.createdAt = QDateTime::currentDateTime();
        r.updatedAt = r.createdAt;
        m_readers.push_back(r);
        return true;
    }

    bool updateReader(const Domain::Reader& reader) override {
        for (auto& r : m_readers) {
            if (r.id == reader.id) {
                r = reader;
                r.updatedAt = QDateTime::currentDateTime();
                return true;
            }
        }
        return false;
    }

    bool removeReader(int id) override {
        for (auto it = m_readers.begin(); it != m_readers.end(); ++it) {
            if (it->id == id) {
                m_removedReaders.push_back(*it);
                m_readers.erase(it);
                return true;
            }
        }
        return false;
    }

    std::vector<Domain::Reader> getRemovedReaders() override { return m_removedReaders; }

    bool restoreReader(int id) override {
        for (auto it = m_removedReaders.begin(); it != m_removedReaders.end(); ++it) {
            if (it->id == id) {
                m_readers.push_back(*it);
                m_removedReaders.erase(it);
                return true;
            }
        }
        return false;
    }
};

class StubCategoryService : public ICategoryService {
    std::vector<Domain::Category> m_categories;
    int m_nextId = 1;

public:
    std::vector<Domain::Category> getAllCategories() override { return m_categories; }

    bool addCategory(const Domain::Category& cat) override {
        Domain::Category c = cat;
        c.id = m_nextId++;
        m_categories.push_back(c);
        return true;
    }

    bool updateCategory(const Domain::Category& cat) override {
        for (auto& c : m_categories) if (c.id == cat.id) { c = cat; return true; }
        return false;
    }

    bool removeCategory(int id) override {
        for (auto it = m_categories.begin(); it != m_categories.end(); ++it) {
            if (it->id == id) { m_categories.erase(it); return true; }
        }
        return false;
    }
};

class StubLocationService : public ILocationService {
    std::vector<Domain::Location> m_locations;
    int m_nextId = 1;

public:
    std::vector<Domain::Location> getAllLocations() override { return m_locations; }

    bool addLocation(const Domain::Location& loc) override {
        Domain::Location l = loc;
        l.id = m_nextId++;
        m_locations.push_back(l);
        return true;
    }

    bool updateLocation(const Domain::Location& loc) override {
        for (auto& l : m_locations) if (l.id == loc.id) { l = loc; return true; }
        return false;
    }

    bool removeLocation(int id) override {
        for (auto it = m_locations.begin(); it != m_locations.end(); ++it) {
            if (it->id == id) { m_locations.erase(it); return true; }
        }
        return false;
    }
};

class StubUserService : public IUserService {
    std::vector<Domain::User> m_users;
    int m_nextId = 1;

    QString hashPassword(const QString& password, const QString& salt) {
        QByteArray data = (password + salt).toUtf8();
        return QCryptographicHash::hash(data, QCryptographicHash::Sha256).toHex();
    }

    QString generateSalt() {
        QByteArray salt;
        for (int i = 0; i < 16; ++i)
            salt.append(static_cast<char>(QRandomGenerator::global()->bounded(256)));
        return salt.toHex();
    }

public:
    bool registerUser(const QString& username, const QString& password, Domain::User::Role role) override {
        for (auto& u : m_users) if (u.username == username) return false;
        Domain::User u;
        u.id = m_nextId++;
        u.username = username;
        u.salt = generateSalt();
        u.passwordHash = hashPassword(password, u.salt);
        u.role = role;
        u.createdAt = QDateTime::currentDateTime();
        m_users.push_back(u);
        return true;
    }

    std::optional<Domain::User> login(const QString& username, const QString& password) override {
        for (auto& u : m_users) {
            if (u.username == username) {
                if (hashPassword(password, u.salt) == u.passwordHash) {
                    u.lastLogin = QDateTime::currentDateTime();
                    return u;
                }
                return std::nullopt;
            }
        }
        return std::nullopt;
    }

    bool changePassword(int userId, const QString& oldPassword, const QString& newPassword) override {
        for (auto& u : m_users) {
            if (u.id == userId) {
                if (hashPassword(oldPassword, u.salt) == u.passwordHash) {
                    u.passwordHash = hashPassword(newPassword, u.salt);
                    return true;
                }
                return false;
            }
        }
        return false;
    }

    std::vector<Domain::User> getAllUsers() override { return m_users; }
};

class StubLoanService : public ILoanService {
    std::vector<Domain::Loan> m_loans;
    int m_nextId = 1;

public:
    bool loanBook(int bookId, int readerId, int days) override {
        Domain::Loan loan;
        loan.id = m_nextId++;
        loan.bookId = bookId;
        loan.readerId = readerId;
        loan.loanDate = QDateTime::currentDateTime();
        loan.dueDate = loan.loanDate.addDays(days);
        loan.status = "active";
        m_loans.push_back(loan);
        return true;
    }

    bool returnBook(int loanId) override {
        for (auto& l : m_loans) {
            if (l.id == loanId && l.isActive()) {
                l.returnDate = QDateTime::currentDateTime();
                l.status = "returned";
                return true;
            }
        }
        return false;
    }

    std::vector<Domain::Loan> getActiveLoans() override {
        std::vector<Domain::Loan> result;
        for (auto& l : m_loans) if (l.isActive()) result.push_back(l);
        return result;
    }

    std::vector<Domain::Loan> getOverdueLoans() override {
        std::vector<Domain::Loan> result;
        for (auto& l : m_loans) if (l.isOverdue()) result.push_back(l);
        return result;
    }

    std::vector<Domain::Loan> getLoansForReader(int readerId) override {
        std::vector<Domain::Loan> result;
        for (auto& l : m_loans) if (l.readerId == readerId) result.push_back(l);
        return result;
    }

    std::vector<Domain::Loan> getLoansForBook(int bookId) override {
        std::vector<Domain::Loan> result;
        for (auto& l : m_loans) if (l.bookId == bookId) result.push_back(l);
        return result;
    }
};

class StubUndoService : public IUndoService {
    struct Entry { QString entityType; QString oldData; QString newData; QString type; };
    std::vector<Entry> m_history;

public:
    void recordAdd(const QString& entityType, const QString& data) override {
        m_history.push_back({entityType, "", data, "add"});
    }
    void recordEdit(const QString& entityType, const QString& oldData, const QString& newData) override {
        m_history.push_back({entityType, oldData, newData, "edit"});
    }
    void recordRemove(const QString& entityType, const QString& data) override {
        m_history.push_back({entityType, data, "", "remove"});
    }
    bool canUndo() const override { return !m_history.empty(); }
    bool undo() override {
        if (m_history.empty()) return false;
        // TODO: implement actual undo logic
        m_history.pop_back();
        return true;
    }
    void clear() override { m_history.clear(); }
};

void initializeStubServices() {
    auto& logic = BusinessLogicFacade::instance();
    logic.db = std::make_unique<StubDatabaseManager>();
    logic.books = std::make_unique<StubBookService>();
    logic.readers = std::make_unique<StubReaderService>();
    logic.categories = std::make_unique<StubCategoryService>();
    logic.locations = std::make_unique<StubLocationService>();
    logic.users = std::make_unique<StubUserService>();
    logic.loans = std::make_unique<StubLoanService>();
    logic.undo = std::make_unique<StubUndoService>();
}

} // namespace BusinessLogic