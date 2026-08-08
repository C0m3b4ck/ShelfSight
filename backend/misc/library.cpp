#include "library.h"

#include <cstdio>
#include <ctime>
#include <random>

namespace shelfsight {

namespace {

std::string date_now() {
    std::time_t t = std::time(nullptr);
    std::tm tm;
    localtime_r(&t, &tm);
    char buf[24];
    std::strftime(buf, sizeof(buf), "%Y-%m-%d", &tm);
    return buf;
}

} // namespace

void Library::push_undo(Action action, const Book& book, const Reader& reader,
                        const Loan& loan) {
    undo_stack_.push_back(UndoEntry{action, book, reader, loan});
    if (undo_stack_.size() > kMaxUndo) undo_stack_.pop_front();
}

bool Library::undo() {
    if (undo_stack_.empty()) return false;
    const UndoEntry e = undo_stack_.back();
    undo_stack_.pop_back();
    switch (e.action) {
        case Action::AddBook:
            return db_.delete_book(e.book.book_id);
        case Action::EditBook:
            return db_.update_book(e.book);
        case Action::DeleteBook:
            return db_.restore_book(e.book.book_id);
        case Action::AddReader:
            return db_.delete_reader(e.reader.reader_id);
        case Action::EditReader:
            return db_.update_reader(e.reader);
        case Action::DeleteReader:
            return db_.restore_reader(e.reader.reader_id);
        case Action::AddLoan:
            return db_.delete_loan(e.loan.loan_id);
        case Action::EditLoan:
            return db_.update_loan(e.loan);
        case Action::DeleteLoan:
            return db_.add_loan(e.loan);
    }
    return false;
}

/* ------------------------- Books ------------------------- */

bool Library::add_book(const std::string& title, const std::string& author,
                       const std::string& book_id, const std::string& category,
                       const std::string& status) {
    if (title.empty() || book_id.empty()) return false;
    if (db_.get_book(book_id)) return false; // duplicate ID

    Book b;
    b.title = title;
    b.author = author;
    b.book_id = book_id;
    b.category = category;
    b.status = status;
    if (!db_.add_book(b)) return false;

    push_undo(Action::AddBook, b);
    return true;
}

bool Library::edit_book(const std::string& book_id, const std::string& title,
                        const std::string& author, const std::string& category,
                        const std::string& status) {
    std::optional<Book> before = db_.get_book(book_id);
    if (!before) return false;

    Book updated = *before;
    updated.title = title;
    updated.author = author;
    updated.category = category;
    updated.status = status;
    if (!db_.update_book(updated)) return false;

    UndoEntry e;
    e.action = Action::EditBook;
    e.book = *before;
    undo_stack_.push_back(e);
    if (undo_stack_.size() > kMaxUndo) undo_stack_.pop_front();
    return true;
}

bool Library::delete_book(const std::string& book_id) {
    std::optional<Book> b = db_.get_book(book_id);
    if (!b) return false;
    if (!db_.delete_book(book_id)) return false;

    UndoEntry e;
    e.action = Action::DeleteBook;
    e.book = *b;
    undo_stack_.push_back(e);
    if (undo_stack_.size() > kMaxUndo) undo_stack_.pop_front();
    return true;
}

bool Library::restore_book(const std::string& book_id) {
    return db_.restore_book(book_id);
}

std::optional<Book> Library::find_book(const std::string& book_id) {
    return db_.get_book(book_id);
}

std::vector<Book> Library::search_books(const std::string& query, const std::string& field) {
    return db_.search_books(query, field);
}

/* ------------------------- Readers ------------------------- */

bool Library::add_reader(const std::string& name, const std::string& surname,
                         const std::string& grade, const std::string& class_name,
                         const std::string& reader_id) {
    if (name.empty() || reader_id.empty()) return false;
    if (db_.get_reader(reader_id)) return false;

    Reader r;
    r.name = name;
    r.surname = surname;
    r.grade = grade;
    r.class_name = class_name;
    r.reader_id = reader_id;
    if (!db_.add_reader(r)) return false;

    push_undo(Action::AddReader, Book{}, r);
    return true;
}

bool Library::edit_reader(const std::string& reader_id, const std::string& name,
                          const std::string& surname, const std::string& grade,
                          const std::string& class_name) {
    std::optional<Reader> before = db_.get_reader(reader_id);
    if (!before) return false;

    Reader updated = *before;
    updated.name = name;
    updated.surname = surname;
    updated.grade = grade;
    updated.class_name = class_name;
    if (!db_.update_reader(updated)) return false;

    UndoEntry e;
    e.action = Action::EditReader;
    e.reader = *before;
    undo_stack_.push_back(e);
    if (undo_stack_.size() > kMaxUndo) undo_stack_.pop_front();
    return true;
}

bool Library::delete_reader(const std::string& reader_id) {
    std::optional<Reader> r = db_.get_reader(reader_id);
    if (!r) return false;
    if (!db_.delete_reader(reader_id)) return false;

    UndoEntry e;
    e.action = Action::DeleteReader;
    e.reader = *r;
    undo_stack_.push_back(e);
    if (undo_stack_.size() > kMaxUndo) undo_stack_.pop_front();
    return true;
}

bool Library::restore_reader(const std::string& reader_id) {
    return db_.restore_reader(reader_id);
}

std::optional<Reader> Library::find_reader(const std::string& reader_id) {
    return db_.get_reader(reader_id);
}

std::vector<Reader> Library::search_readers(const std::string& query, const std::string& field) {
    return db_.search_readers(query, field);
}

/* ------------------------- Loans ------------------------- */

std::string Library::generate_loan_id() {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_int_distribution<int> dist(0, 35);
    static const char kChars[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    std::string id = "LN-";
    for (int i = 0; i < 8; ++i) id.push_back(kChars[dist(gen)]);
    return id;
}

bool Library::add_loan(const std::string& book_id, const std::string& reader_id,
                       const std::string& loan_id, const std::string& expiry_date,
                       const std::string& status) {
    if (book_id.empty() || reader_id.empty()) return false;
    std::string lid = loan_id;
    if (lid.empty()) lid = generate_loan_id();
    if (db_.get_loan(lid)) return false;

    Loan l;
    l.book_id = book_id;
    l.reader_id = reader_id;
    l.loan_id = lid;
    l.expiry_date = expiry_date.empty() ? date_now() : expiry_date;
    l.status = status.empty() ? "Active" : status;
    if (!db_.add_loan(l)) return false;

    push_undo(Action::AddLoan, Book{}, Reader{}, l);
    return true;
}

bool Library::edit_loan(const std::string& loan_id, const std::string& book_id,
                        const std::string& reader_id, const std::string& expiry_date,
                        const std::string& status) {
    std::optional<Loan> before = db_.get_loan(loan_id);
    if (!before) return false;

    Loan updated = *before;
    updated.book_id = book_id;
    updated.reader_id = reader_id;
    updated.expiry_date = expiry_date;
    updated.status = status;
    if (!db_.update_loan(updated)) return false;

    UndoEntry e;
    e.action = Action::EditLoan;
    e.loan = *before;
    undo_stack_.push_back(e);
    if (undo_stack_.size() > kMaxUndo) undo_stack_.pop_front();
    return true;
}

bool Library::delete_loan(const std::string& loan_id) {
    std::optional<Loan> l = db_.get_loan(loan_id);
    if (!l) return false;
    if (!db_.delete_loan(loan_id)) return false;

    UndoEntry e;
    e.action = Action::DeleteLoan;
    e.loan = *l;
    undo_stack_.push_back(e);
    if (undo_stack_.size() > kMaxUndo) undo_stack_.pop_front();
    return true;
}

std::optional<Loan> Library::find_loan(const std::string& loan_id) {
    return db_.get_loan(loan_id);
}

std::vector<Loan> Library::search_loans(const std::string& query, const std::string& type,
                                        const std::string& status) {
    return db_.search_loans(query, status, type);
}

} // namespace shelfsight