#pragma once

#include "database.h"

#include <deque>
#include <string>
#include <vector>

namespace shelfsight {

// App-level business logic that combines the database with undo history.
// The undo stack is bounded and holds the previous state of the last change
// so an "Undo last" button can revert it.
class Library {
public:
    explicit Library(Database& db) : db_(db) {}

    // Books
    bool add_book(const std::string& title, const std::string& author,
                  const std::string& book_id, const std::string& category,
                  const std::string& status);
    bool edit_book(const std::string& book_id, const std::string& title,
                   const std::string& author, const std::string& category,
                   const std::string& status);
    bool delete_book(const std::string& book_id);
    bool restore_book(const std::string& book_id);
    std::optional<Book> find_book(const std::string& book_id);
    std::vector<Book> search_books(const std::string& query, const std::string& field);
    std::vector<Book> deleted_books() const { return db_.get_deleted_books(); }

    // Readers
    bool add_reader(const std::string& name, const std::string& surname,
                    const std::string& grade, const std::string& class_name,
                    const std::string& reader_id);
    bool edit_reader(const std::string& reader_id, const std::string& name,
                     const std::string& surname, const std::string& grade,
                     const std::string& class_name);
    bool delete_reader(const std::string& reader_id);
    bool restore_reader(const std::string& reader_id);
    std::optional<Reader> find_reader(const std::string& reader_id);
    std::vector<Reader> search_readers(const std::string& query, const std::string& field);
    std::vector<Reader> deleted_readers() const { return db_.get_deleted_readers(); }

    // Loans
    bool add_loan(const std::string& book_id, const std::string& reader_id,
                  const std::string& loan_id, const std::string& expiry_date,
                  const std::string& status);
    bool edit_loan(const std::string& loan_id, const std::string& book_id,
                   const std::string& reader_id, const std::string& expiry_date,
                   const std::string& status);
    bool delete_loan(const std::string& loan_id);
    std::optional<Loan> find_loan(const std::string& loan_id);
    std::vector<Loan> search_loans(const std::string& query, const std::string& type,
                                   const std::string& status);
    std::vector<Loan> expired_loans() const { return db_.get_expired_loans(); }

    // Undo support. Returns true if there was an entry to pop.
    bool undo();

    // Helpers for generated IDs.
    static std::string generate_loan_id();

private:
    Database& db_;

    enum class Action { AddBook, EditBook, DeleteBook, AddReader, EditReader,
                        DeleteReader, AddLoan, EditLoan, DeleteLoan };
    struct UndoEntry {
        Action action;
        Book book;
        Reader reader;
        Loan loan;
    };
    std::deque<UndoEntry> undo_stack_;
    static constexpr size_t kMaxUndo = 20;

    void push_undo(Action action, const Book& book = Book{},
                   const Reader& reader = Reader{}, const Loan& loan = Loan{});
};

} // namespace shelfsight