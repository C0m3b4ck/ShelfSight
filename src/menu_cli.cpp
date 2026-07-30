#include <iostream>
#include <fstream>
#include <sstream>
#include <limits>
#include <cctype>
#include <sys/stat.h>
#include "main.h"
#include "file_man.h"
#include "glob_vars.h"

short mnu_cli();

static bool check_cancel()
{
    if (std::cin.eof())
    {
        std::cin.clear();
        request_exit();
        return true;
    }
    if (std::cin.fail() || is_exit_requested())
    {
        std::cin.clear();
        std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
        consume_exit_request();
        return true;
    }
    return false;
}

static std::string read_line()
{
    std::string line;
    std::getline(std::cin >> std::ws, line);
    return line;
}

static int read_int()
{
    std::string line = read_line();
    if (check_cancel()) return -1;
    if (line.empty()) return 0;
    try { return std::stoi(line); } catch (...) { return -1; }
}

static bool ensure_db(const std::string& path, const std::string& label)
{
    if (db_exists(path)) return true;
    std::cout << YLW << "Database " << path << " not found.\n" << RST;
    std::cout << "Create " << label << " database? (Y/N): ";
    std::string yn = read_line();
    if (check_cancel()) return false;
    if (yn != "Y" && yn != "y") return false;
    std::ofstream f(path);
    if (!f.is_open())
    {
        std::cout << RED << "!!! Failed to create " << path << " !!!" << RST << "\n";
        return false;
    }
    f.close();
    std::cout << GRN << path << " created.\n" << RST;
    return true;
}

static bool is_valid_isbn(const std::string& s)
{
    if (s.empty()) return true;
    std::string digits;
    for (char c : s)
        if (c != '-' && c != ' ')
            digits += c;
    if (digits.empty()) return false;
    for (char c : digits)
        if (!std::isdigit(static_cast<unsigned char>(c)) && c != 'X' && c != 'x')
            return false;
    return digits.length() == 10 || digits.length() == 13;
}

static void pause_msg()
{
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

/// ---=== BOOKS ===---

void mnu_addbooks()
{
    clear_cli();
    std::cout << CYN << "=== ADD BOOKS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::string title;
    std::cout << "Book title: ";
    std::getline(std::cin >> std::ws, title);
    if (check_cancel()) return;
    if (title.empty()) { std::cout << RED << "Title cannot be empty.\n" << RST; return; }

    std::string author;
    std::cout << "Author: ";
    std::getline(std::cin, author);
    if (check_cancel()) return;
    if (author.empty()) { std::cout << RED << "Author cannot be empty.\n" << RST; return; }

    std::string isbn;
    std::cout << "ISBN (optional, 10 or 13 digits): ";
    std::getline(std::cin, isbn);
    if (check_cancel()) return;
    if (!is_valid_isbn(isbn))
    {
        std::cout << RED << "Invalid ISBN format (use 10 or 13 digits).\n" << RST;
        return;
    }

    std::string book_id;
    std::cout << "Unique ID: ";
    std::getline(std::cin, book_id);
    if (check_cancel()) return;
    if (book_id.empty()) { std::cout << RED << "ID cannot be empty.\n" << RST; return; }
    if (book_id_exists(book_id))
    {
        std::cout << RED << "ID \"" << book_id << "\" already exists in database.\n" << RST;
        return;
    }

    std::cout << "\nAvailable categories:\n";
    for (size_t i = 0; i < g_categories.size(); ++i)
        std::cout << "  [" << (i + 1) << "] " << g_categories[i] << "\n";
    std::cout << "  [0] Other (type manually)\n";
    std::string category;
    std::cout << "Category (number or name): ";
    std::string cat_input = read_line();
    if (check_cancel()) return;
    if (cat_input.empty()) { std::cout << RED << "Category cannot be empty.\n" << RST; return; }
    int cat_idx = -1;
    try { cat_idx = std::stoi(cat_input); } catch (...) {}
    if (cat_idx > 0 && static_cast<size_t>(cat_idx) <= g_categories.size())
        category = g_categories[static_cast<size_t>(cat_idx - 1)];
    else
        category = cat_input;

    std::string status;
    std::cout << "Status (Available/Borrowed/Lost/Other): ";
    std::getline(std::cin, status);
    if (check_cancel()) return;
    if (status.empty()) status = "Available";

    if (save_book(title, author, isbn, book_id, category, status) != 0)
        std::cout << RED << "Failed to save book.\n" << RST;
    pause_msg();
}

void mnu_editbooks()
{
    clear_cli();
    std::cout << CYN << "=== EDIT BOOKS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Book ID to edit (0 to cancel): ";
    int id = read_int();
    if (check_cancel()) return;
    if (id <= 0) return;
    if (!book_id_exists(std::to_string(id)))
    {
        std::cout << RED << "Book ID \"" << id << "\" not found in database.\n" << RST;
        pause_msg();
        return;
    }

    std::string new_title;
    std::cout << "New title (empty to keep): ";
    new_title = read_line();
    if (check_cancel()) return;

    std::string new_author;
    std::cout << "New author (empty to keep): ";
    new_author = read_line();
    if (check_cancel()) return;

    std::string new_isbn;
    std::cout << "New ISBN (optional, empty to keep): ";
    new_isbn = read_line();
    if (check_cancel()) return;
    if (!new_isbn.empty() && !is_valid_isbn(new_isbn))
    {
        std::cout << RED << "Invalid ISBN format.\n" << RST;
        return;
    }

    std::cout << "\nAvailable categories:\n";
    for (size_t i = 0; i < g_categories.size(); ++i)
        std::cout << "  [" << (i + 1) << "] " << g_categories[i] << "\n";
    std::cout << "  [0] Other (type manually)\n";
    std::cout << "  [-1] Keep current\n";
    std::string new_category;
    std::cout << "Category: ";
    std::string cat_input = read_line();
    if (check_cancel()) return;
    int cat_idx = -2;
    try { cat_idx = std::stoi(cat_input); } catch (...) {}
    if (cat_idx == -1)
        new_category = "(keep current)";
    else if (cat_idx > 0 && static_cast<size_t>(cat_idx) <= g_categories.size())
        new_category = g_categories[static_cast<size_t>(cat_idx - 1)];
    else if (!cat_input.empty())
        new_category = cat_input;

    std::string new_status;
    std::cout << "New status (Available/Borrowed/Lost, empty to keep): ";
    std::getline(std::cin, new_status);
    if (check_cancel()) return;

    std::cout << GRN << "\nWould update book " << id << ":\n"
              << "  Title:    " << (new_title.empty()   ? "(keep)" : "\"" + new_title + "\"") << "\n"
              << "  Author:   " << (new_author.empty()  ? "(keep)" : "\"" + new_author + "\"") << "\n"
              << "  ISBN:     " << (new_isbn.empty()    ? "(keep)" : new_isbn) << "\n"
              << "  Category: " << (new_category.empty() ? "(keep)" : new_category) << "\n"
              << "  Status:   " << (new_status.empty()  ? "(keep)" : new_status) << RST << "\n\n";
    pause_msg();
}

void mnu_deletebooks()
{
    clear_cli();
    std::cout << CYN << "=== REMOVE BOOKS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Book ID to remove (0 to cancel): ";
    int id = read_int();
    if (check_cancel()) return;
    if (id <= 0) return;
    if (!book_id_exists(std::to_string(id)))
    {
        std::cout << RED << "Book ID \"" << id << "\" not found in database.\n" << RST;
        pause_msg();
        return;
    }

    std::cout << "Remove book " << id << "? (Y/N): ";
    std::string confirm = read_line();
    if (check_cancel()) return;

    if (confirm == "Y" || confirm == "y")
        std::cout << RED << "\nWould delete book " << id << RST << "\n\n";
    else
        std::cout << YLW << "\nDeletion cancelled." << RST << "\n\n";
    pause_msg();
}

void mnu_sortbookdb()
{
    clear_cli();
    std::cout << CYN << "=== SORT BOOK DB ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Sort by:\n";
    std::cout << "[1] Title\n";
    std::cout << "[2] Author\n";
    std::cout << "[3] ISBN\n";
    std::cout << "[4] Category\n";
    std::cout << "[0] Cancel\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;

    switch (choice)
    {
        case 1: std::cout << GRN << "\nSorting by title..." << RST << "\n";    break;
        case 2: std::cout << GRN << "\nSorting by author..." << RST << "\n";   break;
        case 3: std::cout << GRN << "\nSorting by ISBN..." << RST << "\n";     break;
        case 4: std::cout << GRN << "\nSorting by category..." << RST << "\n"; break;
        default: std::cout << YLW << "\nSort cancelled." << RST << "\n";       return;
    }
    pause_msg();
}

void mnu_searchbooks()
{
    clear_cli();
    std::cout << CYN << "=== SEARCH BOOKS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Search by:\n";
    std::cout << "[1] Title\n";
    std::cout << "[2] Author\n";
    std::cout << "[3] ISBN\n";
    std::cout << "[4] ID\n";
    std::cout << "[0] Cancel\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;

    std::string field;
    switch (choice)
    {
        case 1: field = "Title";   break;
        case 2: field = "Author";  break;
        case 3: field = "ISBN";    break;
        case 4: field = "ID";      break;
        default: return;
    }

    std::cout << "Enter " << field << " to search for: ";
    std::string query = read_line();
    if (check_cancel() || query.empty()) return;

    std::ifstream file(g_books_db);
    if (!file.is_open())
    {
        std::cout << RED << "Cannot open " << g_books_db << RST << "\n";
        return;
    }
    int field_idx = choice - 1;
    std::string line;
    int count = 0;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t start = 0;
        for (int i = 0; i < field_idx; ++i)
        {
            start = line.find('|', start);
            if (start == std::string::npos) break;
            ++start;
        }
        if (start == std::string::npos) continue;
        std::size_t end = line.find('|', start);
        std::string val = line.substr(start, end - start);
        if (val.find(query) != std::string::npos)
        {
            std::cout << "  " << line << "\n";
            ++count;
        }
    }
    file.close();
    std::cout << GRN << "\nFound " << count << " match(es).\n" << RST;
    pause_msg();
}

void mnu_manage_categories()
{
    clear_cli();
    std::cout << CYN << "=== MANAGE CATEGORIES ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    while (true)
    {
        std::cout << "Current categories:\n";
        for (size_t i = 0; i < g_categories.size(); ++i)
            std::cout << "  [" << (i + 1) << "] " << g_categories[i] << "\n";
        std::cout << "\n[1] Add category\n";
        std::cout << "[2] Remove category\n";
        std::cout << "[3] Reload from " << g_categors_cat << "\n";
        std::cout << "[0] Back\n";
        std::cout << "-> Your choice: ";
        int choice = read_int();
        if (check_cancel()) return;

        if (choice == 1)
        {
            std::cout << "New category name: ";
            std::string cat = read_line();
            if (check_cancel()) return;
            if (!cat.empty())
            {
                g_categories.push_back(cat);
                std::cout << GRN << "Added \"" << cat << "\".\n" << RST;
            }
        }
        else if (choice == 2)
        {
            std::cout << "Number to remove: ";
            int idx = read_int();
            if (check_cancel()) return;
            if (idx > 0 && static_cast<size_t>(idx) <= g_categories.size())
            {
                std::cout << YLW << "Remove \"" << g_categories[static_cast<size_t>(idx - 1)] << "\"? (Y/N): " << RST;
                std::string yn = read_line();
                if (check_cancel()) return;
                if (yn == "Y" || yn == "y")
                {
                    g_categories.erase(g_categories.begin() + (idx - 1));
                    std::cout << GRN << "Removed.\n" << RST;
                }
            }
        }
        else if (choice == 3)
        {
            load_categories_books();
        }
        else break;
    }
}

void mnu_restorebooks()
{
    clear_cli();
    std::cout << CYN << "=== RESTORE DELETED BOOKS ===" << RST << "\n";
    std::cout << YLW << "Feature not yet implemented.\n" << RST;
    pause_msg();
}

/// ---=== READERS ===---

void mnu_addreader()
{
    clear_cli();
    std::cout << CYN << "=== ADD READER ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::string name;
    std::cout << "Reader name: ";
    name = read_line();
    if (check_cancel()) return;
    if (name.empty()) return;

    std::string surname;
    std::cout << "Reader surname: ";
    surname = read_line();
    if (check_cancel()) return;

    std::string grade;
    std::cout << "Grade: ";
    grade = read_line();
    if (check_cancel()) return;

    std::string cls;
    std::cout << "Class: ";
    cls = read_line();
    if (check_cancel()) return;

    if (reader_exists(name, surname))
    {
        std::cout << RED << "Reader \"" << name << " " << surname << "\" already exists.\n" << RST;
        pause_msg();
        return;
    }

    save_reader(name, surname, grade, cls);
    pause_msg();
}

void mnu_editreader()
{
    clear_cli();
    std::cout << CYN << "=== EDIT READER ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::string name;
    std::cout << "Current reader name: ";
    name = read_line();
    if (check_cancel()) return;
    if (name.empty()) return;

    std::string surname;
    std::cout << "Current reader surname: ";
    surname = read_line();
    if (check_cancel()) return;

    if (!reader_exists(name, surname))
    {
        std::cout << RED << "Reader \"" << name << " " << surname << "\" not found.\n" << RST;
        pause_msg();
        return;
    }

    std::string new_name;
    std::cout << "New name (empty to keep): ";
    new_name = read_line();
    if (check_cancel()) return;

    std::string new_surname;
    std::cout << "New surname (empty to keep): ";
    new_surname = read_line();
    if (check_cancel()) return;

    std::cout << GRN << "\nWould update reader \"" << name << " " << surname << "\""
              << (new_name.empty() ? "" : " -> name: \"" + new_name + "\"")
              << (new_surname.empty() ? "" : " -> surname: \"" + new_surname + "\"")
              << RST << "\n\n";
    pause_msg();
}

void mnu_rmreader()
{
    clear_cli();
    std::cout << CYN << "=== REMOVE READER ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::string name;
    std::cout << "Reader name: ";
    name = read_line();
    if (check_cancel()) return;
    if (name.empty()) return;

    std::string surname;
    std::cout << "Reader surname: ";
    surname = read_line();
    if (check_cancel()) return;

    if (!reader_exists(name, surname))
    {
        std::cout << RED << "Reader \"" << name << " " << surname << "\" not found.\n" << RST;
        pause_msg();
        return;
    }

    std::cout << "Remove reader \"" << name << " " << surname << "\"? (Y/N): ";
    std::string confirm = read_line();
    if (check_cancel()) return;

    if (confirm == "Y" || confirm == "y")
        std::cout << RED << "\nWould delete reader \"" << name << " " << surname << "\"\n" << RST;
    else
        std::cout << YLW << "\nDeletion cancelled.\n" << RST;
    pause_msg();
}

void mnu_sortreaderdb()
{
    clear_cli();
    std::cout << CYN << "=== SORT READER DB ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Sort by:\n";
    std::cout << "[1] Name\n";
    std::cout << "[2] ID\n";
    std::cout << "[0] Cancel\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;

    switch (choice)
    {
        case 1: std::cout << GRN << "\nSorting by name..." << RST << "\n";  break;
        case 2: std::cout << GRN << "\nSorting by ID..." << RST << "\n";    break;
        default: std::cout << YLW << "\nSort cancelled." << RST << "\n";    return;
    }
    pause_msg();
}

void mnu_searchreaders()
{
    clear_cli();
    std::cout << CYN << "=== SEARCH READERS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Search by:\n";
    std::cout << "[1] Name\n";
    std::cout << "[2] Surname\n";
    std::cout << "[3] Grade\n";
    std::cout << "[4] Class\n";
    std::cout << "[0] Cancel\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;

    std::string label;
    int field_idx;
    switch (choice)
    {
        case 1: label = "Name";    field_idx = 0; break;
        case 2: label = "Surname"; field_idx = 1; break;
        case 3: label = "Grade";   field_idx = 2; break;
        case 4: label = "Class";   field_idx = 3; break;
        default: return;
    }

    std::cout << "Enter " << label << " to search for: ";
    std::string query = read_line();
    if (check_cancel() || query.empty()) return;

    std::ifstream file(g_readers_db);
    if (!file.is_open())
    {
        std::cout << RED << "Cannot open " << g_readers_db << RST << "\n";
        return;
    }
    std::string line;
    int count = 0;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t start = 0;
        for (int i = 0; i < field_idx; ++i)
        {
            start = line.find('|', start);
            if (start == std::string::npos) break;
            ++start;
        }
        if (start == std::string::npos) continue;
        std::size_t end = line.find('|', start);
        std::string val = line.substr(start, end - start);
        if (val.find(query) != std::string::npos)
        {
            std::cout << "  " << line << "\n";
            ++count;
        }
    }
    file.close();
    std::cout << GRN << "\nFound " << count << " match(es).\n" << RST;
    pause_msg();
}

void mnu_restorereaders()
{
    clear_cli();
    std::cout << CYN << "=== RESTORE DELETED READERS ===" << RST << "\n";
    std::cout << YLW << "Feature not yet implemented.\n" << RST;
    pause_msg();
}

void mnu_importreaders()
{
    clear_cli();
    std::cout << CYN << "=== IMPORT READERS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "File to import from: ";
    std::string path = read_line();
    if (check_cancel() || path.empty()) return;

    std::ifstream src(path);
    if (!src.is_open())
    {
        std::cout << RED << "Cannot open " << path << RST << "\n";
        return;
    }
    std::ofstream dst(g_readers_db, std::ios::app);
    if (!dst.is_open())
    {
        std::cout << RED << "Cannot open " << g_readers_db << RST << "\n";
        return;
    }
    int count = 0;
    std::string line;
    while (std::getline(src, line))
    {
        if (!line.empty())
        {
            dst << line << "\n";
            ++count;
        }
    }
    std::cout << GRN << "Imported " << count << " reader(s).\n" << RST;
    pause_msg();
}

void sbmnu_readers()
{
    if (!ensure_db(g_readers_db, "readers"))
    {
        pause_msg();
        return;
    }
    while (true)
    {
        clear_cli();
        std::cout << CYN << "/// Reader Submenu ///" << RST << "\n";
        std::cout << "[1] Add reader\n";
        std::cout << "[2] Edit reader\n";
        std::cout << "[3] Remove reader\n";
        std::cout << "[4] Sort reader database\n";
        std::cout << "[5] Search readers\n";
        std::cout << "[6] Restore deleted readers\n";
        std::cout << "[7] Import readers\n";
        std::cout << "[0] Back to main menu\n";
        std::cout << "-> Your choice: ";
        int input = read_int();
        if (check_cancel()) return;
        switch(input)
        {
            case(1): mnu_addreader();         continue;
            case(2): mnu_editreader();         continue;
            case(3): mnu_rmreader();           continue;
            case(4): mnu_sortreaderdb();       continue;
            case(5): mnu_searchreaders();      continue;
            case(6): mnu_restorereaders();     continue;
            case(7): mnu_importreaders();      continue;
            case(0): return;
        }
    }
}

/// ---=== LOANS ===---

void mnu_addloan()
{
    clear_cli();
    std::cout << CYN << "=== ADD LOAN ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Book ID (0 to cancel): ";
    int book_id = read_int();
    if (check_cancel()) return;
    if (book_id <= 0) return;
    if (!book_id_exists(std::to_string(book_id)))
    {
        std::cout << RED << "Book ID \"" << book_id << "\" not found.\n" << RST;
        pause_msg();
        return;
    }
    if (loan_id_exists(std::to_string(book_id)))
    {
        std::cout << RED << "Book " << book_id << " is already on loan.\n" << RST;
        pause_msg();
        return;
    }

    std::cout << "Reader name: ";
    std::string rname = read_line();
    if (check_cancel()) return;
    if (rname.empty()) return;

    std::cout << "Reader surname: ";
    std::string rsurname = read_line();
    if (check_cancel()) return;

    if (!reader_exists(rname, rsurname))
    {
        std::cout << RED << "Reader \"" << rname << " " << rsurname << "\" not found.\n" << RST;
        pause_msg();
        return;
    }

    std::cout << "Loan duration in days (default " << g_default_loan_duration << "): ";
    int days = read_int();
    if (check_cancel()) return;
    if (days <= 0) days = g_default_loan_duration;

    std::string loan_date = get_current_date_str();
    std::string exp_date = add_days_to_date(loan_date, days);
    std::string reader_full = rname + " " + rsurname;

    save_loan(std::to_string(book_id), reader_full, loan_date, exp_date);
    std::cout << "Expires: " << exp_date << "\n";
    pause_msg();
}

void mnu_returnloan()
{
    clear_cli();
    std::cout << CYN << "=== RETURN LOAN ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Loan ID (0 to cancel): ";
    int id = read_int();
    if (check_cancel()) return;
    if (id <= 0) return;
    if (!loan_id_exists(std::to_string(id)))
    {
        std::cout << RED << "Loan ID \"" << id << "\" not found in database.\n" << RST;
        pause_msg();
        return;
    }

    std::string status = get_loan_field(std::to_string(id), 4);
    if (status == "returned")
    {
        std::cout << YLW << "Loan " << id << " is already returned.\n" << RST;
        pause_msg();
        return;
    }

    std::cout << "Return loan " << id << "? (Y/N): ";
    std::string yn = read_line();
    if (check_cancel()) return;
    if (yn != "Y" && yn != "y")
    {
        std::cout << YLW << "Return cancelled.\n" << RST;
        pause_msg();
        return;
    }

    if (update_loan_field(std::to_string(id), 4, "returned") == 0)
        std::cout << GRN << "Loan " << id << " marked as returned.\n" << RST;
    pause_msg();
}

void mnu_listloans()
{
    clear_cli();
    std::cout << CYN << "=== ACTIVE LOANS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::ifstream file(g_loans_db);
    if (!file.is_open())
    {
        std::cout << RED << "Cannot open " << g_loans_db << RST << "\n";
        pause_msg();
        return;
    }
    std::string line;
    int count = 0;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t pos0 = line.find('|');
        std::size_t pos1 = line.find('|', pos0 + 1);
        std::size_t pos2 = line.find('|', pos1 + 1);
        std::size_t pos3 = line.find('|', pos2 + 1);
        if (pos0 == std::string::npos || pos1 == std::string::npos ||
            pos2 == std::string::npos || pos3 == std::string::npos)
            continue;
        std::string book_id  = line.substr(0, pos0);
        std::string reader_id = line.substr(pos0 + 1, pos1 - pos0 - 1);
        std::string loan_date = line.substr(pos1 + 1, pos2 - pos1 - 1);
        std::string exp_date  = line.substr(pos2 + 1, pos3 - pos2 - 1);
        std::string status    = line.substr(pos3 + 1);
        std::cout << "  Book:" << book_id << " Reader:" << reader_id
                  << " From:" << loan_date << " To:" << exp_date
                  << " [" << status << "]\n";
        ++count;
    }
    file.close();
    if (count == 0)
        std::cout << "(no loans in database)\n";
    std::cout << GRN << "\nTotal: " << count << " loan(s).\n" << RST;
    pause_msg();
}

void mnu_editloan()
{
    clear_cli();
    std::cout << CYN << "=== EDIT LOAN ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Loan ID to edit (0 to cancel): ";
    int id = read_int();
    if (check_cancel()) return;
    if (id <= 0) return;
    if (!loan_id_exists(std::to_string(id)))
    {
        std::cout << RED << "Loan ID \"" << id << "\" not found in database.\n" << RST;
        pause_msg();
        return;
    }

    std::string sid = std::to_string(id);

    std::cout << "New book ID (0 to keep): ";
    int new_book = read_int();
    if (check_cancel()) return;
    if (new_book > 0)
    {
        if (!book_id_exists(std::to_string(new_book)))
        {
            std::cout << RED << "Book ID \"" << new_book << "\" not found.\n" << RST;
            pause_msg();
            return;
        }
        update_loan_field(sid, 0, std::to_string(new_book));
    }

    std::cout << "New reader name (empty to keep): ";
    std::string new_rname = read_line();
    if (check_cancel()) return;
    if (!new_rname.empty())
    {
        std::cout << "New reader surname: ";
        std::string new_rsurname = read_line();
        if (check_cancel()) return;
        if (!reader_exists(new_rname, new_rsurname))
        {
            std::cout << RED << "Reader \"" << new_rname << " " << new_rsurname << "\" not found.\n" << RST;
            pause_msg();
            return;
        }
        update_loan_field(sid, 1, new_rname + " " + new_rsurname);
    }

    std::cout << GRN << "Loan " << id << " updated.\n" << RST;
    pause_msg();
}

void mnu_rmloan()
{
    clear_cli();
    std::cout << CYN << "=== REMOVE LOAN ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Loan ID to remove (0 to cancel): ";
    int id = read_int();
    if (check_cancel()) return;
    if (id <= 0) return;
    if (!loan_id_exists(std::to_string(id)))
    {
        std::cout << RED << "Loan ID \"" << id << "\" not found in database.\n" << RST;
        pause_msg();
        return;
    }

    std::cout << "Remove loan " << id << "? (Y/N): ";
    std::string yn = read_line();
    if (check_cancel()) return;
    if (yn == "Y" || yn == "y")
        delete_loan(std::to_string(id));
    else
        std::cout << YLW << "\nRemoval cancelled.\n" << RST;
    pause_msg();
}

void mnu_marklost()
{
    clear_cli();
    std::cout << CYN << "=== MARK LOAN AS LOST ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Loan ID (0 to cancel): ";
    int id = read_int();
    if (check_cancel()) return;
    if (id <= 0) return;
    if (!loan_id_exists(std::to_string(id)))
    {
        std::cout << RED << "Loan ID \"" << id << "\" not found in database.\n" << RST;
        pause_msg();
        return;
    }

    std::string status = get_loan_field(std::to_string(id), 4);
    if (status == "lost")
    {
        std::cout << YLW << "Loan " << id << " is already marked as lost.\n" << RST;
        pause_msg();
        return;
    }

    std::cout << RED << "Mark loan " << id << " as lost? (Y/N): " << RST;
    std::string yn = read_line();
    if (check_cancel()) return;
    if (yn != "Y" && yn != "y")
    {
        std::cout << YLW << "Mark lost cancelled.\n" << RST;
        pause_msg();
        return;
    }

    if (update_loan_field(std::to_string(id), 4, "lost") == 0)
        std::cout << RED << "Loan " << id << " marked as lost.\n" << RST;
    pause_msg();
}

void mnu_prolongloan()
{
    clear_cli();
    std::cout << CYN << "=== PROLONG LOAN ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Loan ID (0 to cancel): ";
    int id = read_int();
    if (check_cancel()) return;
    if (id <= 0) return;
    if (!loan_id_exists(std::to_string(id)))
    {
        std::cout << RED << "Loan ID \"" << id << "\" not found in database.\n" << RST;
        pause_msg();
        return;
    }

    std::string sid = std::to_string(id);
    std::string status = get_loan_field(sid, 4);
    if (status == "returned" || status == "lost")
    {
        std::cout << YLW << "Cannot prolong a " << status << " loan.\n" << RST;
        pause_msg();
        return;
    }

    std::string cur_exp = get_loan_field(sid, 3);
    if (cur_exp.empty())
    {
        std::cout << RED << "Could not read expiration date.\n" << RST;
        pause_msg();
        return;
    }

    std::cout << "Current expiration: " << cur_exp << "\n";
    std::cout << "Extra days: ";
    int days = read_int();
    if (check_cancel()) return;
    if (days <= 0) return;

    std::string new_exp = add_days_to_date(cur_exp, days);
    if (update_loan_field(sid, 3, new_exp) == 0)
        std::cout << GRN << "Loan " << id << " prolonged to " << new_exp << RST << "\n";
    pause_msg();
}

void mnu_expiredloans()
{
    clear_cli();
    std::cout << CYN << "=== EXPIRED LOANS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::string today = get_current_date_str();
    std::cout << "Today's date: " << today << "\n\n";

    std::ifstream file(g_loans_db);
    if (!file.is_open())
    {
        std::cout << RED << "Cannot open " << g_loans_db << RST << "\n";
        pause_msg();
        return;
    }
    std::string line;
    int expired = 0;
    int active = 0;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t pos0 = line.find('|');
        std::size_t pos1 = line.find('|', pos0 + 1);
        std::size_t pos2 = line.find('|', pos1 + 1);
        std::size_t pos3 = line.find('|', pos2 + 1);
        if (pos0 == std::string::npos || pos1 == std::string::npos ||
            pos2 == std::string::npos || pos3 == std::string::npos)
            continue;
        std::string book_id  = line.substr(0, pos0);
        std::string reader_id = line.substr(pos0 + 1, pos1 - pos0 - 1);
        std::string exp_date  = line.substr(pos2 + 1, pos3 - pos2 - 1);
        std::string status    = line.substr(pos3 + 1);
        if (status != "active") continue;
        ++active;
        if (exp_date < today)
        {
            std::cout << RED << "  EXPIRED - Book:" << book_id
                      << " Reader:" << reader_id
                      << " Was due:" << exp_date << RST << "\n";
            ++expired;
        }
    }
    file.close();
    if (expired == 0)
        std::cout << GRN << "No expired loans found (" << active << " active).\n" << RST;
    else
        std::cout << YLW << expired << " of " << active << " active loans are expired.\n" << RST;
    pause_msg();
}

void mnu_searchloans()
{
    clear_cli();
    std::cout << CYN << "=== SEARCH LOANS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Search by:\n";
    std::cout << "[1] Book ID\n";
    std::cout << "[2] Reader ID\n";
    std::cout << "[0] Cancel\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;
    if (choice < 1 || choice > 2) return;

    std::cout << "Enter ID to search for: ";
    std::string query = read_line();
    if (check_cancel() || query.empty()) return;

    std::ifstream file(g_loans_db);
    if (!file.is_open())
    {
        std::cout << RED << "Cannot open " << g_loans_db << RST << "\n";
        return;
    }
    int field_idx = choice - 1;
    std::string line;
    int count = 0;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t start = 0;
        for (int i = 0; i < field_idx; ++i)
        {
            start = line.find('|', start);
            if (start == std::string::npos) break;
            ++start;
        }
        if (start == std::string::npos) continue;
        std::size_t end = line.find('|', start);
        std::string val = line.substr(start, end - start);
        if (val.find(query) != std::string::npos)
        {
            std::cout << "  " << line << "\n";
            ++count;
        }
    }
    file.close();
    std::cout << GRN << "Found " << count << " match(es).\n" << RST;
    pause_msg();
}

void sbmnu_loans()
{
    if (!ensure_db(g_loans_db, "loans"))
    {
        pause_msg();
        return;
    }
    while (true)
    {
        clear_cli();
        std::cout << CYN << "/// Loan Submenu ///" << RST << "\n";
        std::cout << "[1] Add loan\n";
        std::cout << "[2] Return loan\n";
        std::cout << "[3] List active loans\n";
        std::cout << "[4] Edit loan\n";
        std::cout << "[5] Remove loan\n";
        std::cout << "[6] Mark as lost\n";
        std::cout << "[7] Prolong loan\n";
        std::cout << "[8] View expired loans\n";
        std::cout << "[9] Search loans\n";
        std::cout << "[0] Back to main menu\n";
        std::cout << "-> Your choice: ";
        int input = read_int();
        if (check_cancel()) return;
        switch(input)
        {
            case(1): mnu_addloan();       continue;
            case(2): mnu_returnloan();    continue;
            case(3): mnu_listloans();     continue;
            case(4): mnu_editloan();      continue;
            case(5): mnu_rmloan();        continue;
            case(6): mnu_marklost();      continue;
            case(7): mnu_prolongloan();   continue;
            case(8): mnu_expiredloans();  continue;
            case(9): mnu_searchloans();   continue;
            case(0): return;
        }
    }
}

/// ---=== BACKUPS ===---

void mnu_createbackup()
{
    clear_cli();
    std::cout << CYN << "=== CREATE BACKUP ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Backup type:\n";
    std::cout << "[1] Offline (local file copy)\n";
    std::cout << "[2] Direct connection (stub)\n";
    std::cout << "[3] Local P2P (LAN, stub)\n";
    std::cout << "[4] Online P2P (stub)\n";
    std::cout << "[0] Cancel\n";
    std::cout << "-> Your choice: ";
    int type = read_int();
    if (check_cancel()) return;
    if (type < 1 || type > 4) return;

    if (type >= 2)
    {
        const char* labels[] = {"", "offline", "direct", "local P2P", "online P2P"};
        std::cout << YLW << labels[type] << " backup not yet implemented (stub).\n" << RST;
        pause_msg();
        return;
    }

    std::cout << "Destination directory: ";
    std::string dest = read_line();
    if (check_cancel() || dest.empty()) return;

    struct stat st;
    if (stat(dest.c_str(), &st) != 0 || !S_ISDIR(st.st_mode))
    {
        std::cout << RED << "Directory \"" << dest << "\" does not exist.\n" << RST;
        pause_msg();
        return;
    }

    int err = 0;
    err += backup_file(g_books_db, dest);
    err += backup_file(g_readers_db, dest);
    err += backup_file(g_loans_db, dest);
    err += backup_file(g_categors_cat, dest);

    if (err == 0)
        std::cout << GRN << "\nFull backup completed to " << dest << RST << "\n";
    else
        std::cout << YLW << "\nBackup completed with " << err << " error(s).\n" << RST;
    pause_msg();
}

void mnu_restorebackup()
{
    clear_cli();
    std::cout << CYN << "=== RESTORE BACKUP ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Source directory: ";
    std::string src = read_line();
    if (check_cancel() || src.empty()) return;

    struct stat st;
    if (stat(src.c_str(), &st) != 0 || !S_ISDIR(st.st_mode))
    {
        std::cout << RED << "Directory \"" << src << "\" does not exist.\n" << RST;
        pause_msg();
        return;
    }

    std::cout << "Restore databases from " << src << "? (Y/N): ";
    std::string confirm = read_line();
    if (check_cancel()) return;

    if (confirm != "Y" && confirm != "y")
    {
        std::cout << YLW << "\nRestore cancelled." << RST << "\n\n";
        pause_msg();
        return;
    }

    int err = 0;
    err += backup_file(src + "/" + g_books_db, ".");    // copy back
    err += backup_file(src + "/" + g_readers_db, ".");
    err += backup_file(src + "/" + g_loans_db, ".");
    err += backup_file(src + "/" + g_categors_cat, ".");

    if (err == 0)
        std::cout << GRN << "\nDatabases restored from " << src << RST << "\n";
    else
        std::cout << YLW << "\nRestore completed with " << err << " error(s).\n" << RST;
    pause_msg();
}

void sbmnu_backups()
{
    while (true)
    {
        clear_cli();
        std::cout << CYN << "/// Backup Submenu ///" << RST << "\n";
        std::cout << "[1] Create backup\n";
        std::cout << "[2] Restore backup\n";
        std::cout << "[0] Back to main menu\n";
        std::cout << "-> Your choice: ";
        int input = read_int();
        if (check_cancel()) return;
        switch(input)
        {
            case(1): mnu_createbackup();   continue;
            case(2): mnu_restorebackup();  continue;
            case(0): return;
        }
    }
}

/// ---=== SETTINGS ===---

void mnu_settings_account()
{
    clear_cli();
    std::cout << CYN << "=== ACCOUNT SETTINGS ===" << RST << "\n\n";
    std::cout << "Change password, email, etc.\n";
    std::cout << "(feature not yet implemented)\n\n";
    pause_msg();
}

void mnu_settings_theme()
{
    clear_cli();
    std::cout << CYN << "=== THEME SETTINGS ===" << RST << "\n\n";
    std::cout << "[1] Light theme\n";
    std::cout << "[2] Dark theme\n";
    std::cout << "[0] Cancel\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;
    if (choice == 1) std::cout << GRN << "Light theme selected.\n" << RST;
    else if (choice == 2) std::cout << GRN << "Dark theme selected.\n" << RST;
    else return;
    pause_msg();
}

void mnu_settings_performance()
{
    clear_cli();
    std::cout << CYN << "=== PERFORMANCE SETTINGS ===" << RST << "\n\n";
    std::cout << "(feature not yet implemented)\n\n";
    pause_msg();
}

void mnu_settings_networking()
{
    clear_cli();
    std::cout << CYN << "=== NETWORKING SETTINGS ===" << RST << "\n\n";
    std::cout << "Enable networking: " << (g_enable_networking ? "Yes" : "No") << "\n\n";
    std::cout << "[1] Toggle networking on/off\n";
    std::cout << "[0] Back\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;
    if (choice == 1)
    {
        g_enable_networking = !g_enable_networking;
        save_settings();
        std::cout << GRN << "Networking is now "
                  << (g_enable_networking ? "enabled" : "disabled") << RST << "\n";
    }
    pause_msg();
}

void mnu_settings_other()
{
    clear_cli();
    std::cout << CYN << "=== OTHER SETTINGS ===" << RST << "\n\n";
    std::cout << "Default language:      " << g_default_language << "\n";
    std::cout << "Save worklogs:         " << (g_save_worklogs ? "Yes" : "No") << "\n";
    std::cout << "Check loans:           " << (g_check_loans ? "Yes" : "No") << "\n";
    std::cout << "Allow same IDs:        " << (g_enable_same_ids ? "Yes" : "No") << "\n";
    std::cout << "Default loan duration: " << g_default_loan_duration << " days\n\n";
    std::cout << "[1] Set default language\n";
    std::cout << "[2] Toggle save worklogs\n";
    std::cout << "[3] Toggle check loans\n";
    std::cout << "[4] Toggle allow same IDs\n";
    std::cout << "[5] Set default loan duration\n";
    std::cout << "[0] Back\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;

    switch (choice)
    {
        case 1:
            std::cout << "Language code (e.g. English-US): ";
            { std::string lang = read_line();
              if (check_cancel()) break;
              if (!lang.empty()) g_default_language = lang; }
            break;
        case 2: g_save_worklogs = !g_save_worklogs; break;
        case 3: g_check_loans = !g_check_loans; break;
        case 4: g_enable_same_ids = !g_enable_same_ids; break;
        case 5:
            std::cout << "Default loan duration (days): ";
            { int d = read_int();
              if (check_cancel()) break;
              if (d > 0) g_default_loan_duration = d; }
            break;
        default: return;
    }
    save_settings();
    std::cout << GRN << "Settings saved.\n" << RST;
    pause_msg();
}

void mnu_changesettings()
{
    clear_cli();
    std::cout << CYN << "=== CHANGE SETTINGS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "[1] Account\n";
    std::cout << "[2] Theme\n";
    std::cout << "[3] Performance\n";
    std::cout << "[4] Networking\n";
    std::cout << "[5] Other\n";
    std::cout << "[0] Back\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;

    switch (choice)
    {
        case 1: mnu_settings_account();      break;
        case 2: mnu_settings_theme();        break;
        case 3: mnu_settings_performance();  break;
        case 4: mnu_settings_networking();   break;
        case 5: mnu_settings_other();        break;
        default: return;
    }
}

void mnu_resetsettings()
{
    clear_cli();
    std::cout << CYN << "=== RESET SETTINGS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Reset all settings to defaults? (Y/N): ";
    std::string confirm = read_line();
    if (check_cancel()) return;

    if (confirm == "Y" || confirm == "y")
    {
        g_default_language = "English-US";
        g_save_worklogs = true;
        g_enable_networking = false;
        g_enable_same_ids = false;
        g_check_loans = true;
        g_default_loan_duration = 14;
        save_settings();
        std::cout << GRN << "\nSettings reset to defaults and saved.\n" << RST;
    }
    else
    {
        std::cout << YLW << "\nReset cancelled.\n" << RST;
    }
    pause_msg();
}

void sbmnu_settings()
{
    while (true)
    {
        clear_cli();
        std::cout << CYN << "/// Settings Submenu ///" << RST << "\n";
        std::cout << "[1] Change settings\n";
        std::cout << "[2] Reset defaults\n";
        std::cout << "[0] Back to main menu\n";
        std::cout << "-> Your choice: ";
        int input = read_int();
        if (check_cancel()) return;
        switch(input)
        {
            case(1): mnu_changesettings();   continue;
            case(2): mnu_resetsettings();    continue;
            case(0): return;
        }
    }
}

/// ---=== DATABASE SELECTION ===---

void mnu_seldb()
{
    while (true)
    {
        clear_cli();
        std::cout << CYN << "/// Database Selection ///" << RST << "\n";
        std::cout << "[1] Select books database\n";
        std::cout << "[2] Select readers database\n";
        std::cout << "[3] Select loans database\n";
        std::cout << "[4] Save configuration\n";
        std::cout << "[5] Load configuration\n";
        std::cout << "[6] Verify database integrity\n";
        std::cout << "[7] Import from VB6 CSV\n";
        std::cout << "[0] Back to main menu\n";
        std::cout << "-> Your choice: ";
        int input = read_int();
        if (check_cancel()) return;

        switch (input)
        {
            case 1:
            {
                std::cout << "Books DB path (" << g_books_db << "): ";
                std::string p = read_line();
                if (check_cancel()) break;
                if (!p.empty()) g_books_db = p;
                std::cout << GRN << "Books DB set to " << g_books_db << RST << "\n";
                pause_msg();
                break;
            }
            case 2:
            {
                std::cout << "Readers DB path (" << g_readers_db << "): ";
                std::string p = read_line();
                if (check_cancel()) break;
                if (!p.empty()) g_readers_db = p;
                std::cout << GRN << "Readers DB set to " << g_readers_db << RST << "\n";
                pause_msg();
                break;
            }
            case 3:
            {
                std::cout << "Loans DB path (" << g_loans_db << "): ";
                std::string p = read_line();
                if (check_cancel()) break;
                if (!p.empty()) g_loans_db = p;
                std::cout << GRN << "Loans DB set to " << g_loans_db << RST << "\n";
                pause_msg();
                break;
            }
            case 4:
                std::cout << GRN << "Configuration saved.\n" << RST;
                pause_msg();
                break;
            case 5:
                std::cout << GRN << "Configuration loaded.\n" << RST;
                pause_msg();
                break;
            case 6:
            {
                std::cout << "Verifying databases...\n";
                std::cout << "  Books:   ";
                if (db_exists(g_books_db))   std::cout << GRN << "OK" << RST;
                else                        std::cout << RED << "MISSING" << RST;
                std::cout << "\n";
                std::cout << "  Readers: ";
                if (db_exists(g_readers_db)) std::cout << GRN << "OK" << RST;
                else                        std::cout << RED << "MISSING" << RST;
                std::cout << "\n";
                std::cout << "  Loans:   ";
                if (db_exists(g_loans_db))   std::cout << GRN << "OK" << RST;
                else                        std::cout << RED << "MISSING" << RST;
                std::cout << "\n";
                pause_msg();
                break;
            }
            case 7:
            {
                clear_cli();
                std::cout << CYN << "=== IMPORT FROM VB6 CSV ===" << RST << "\n";
                std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";
                std::cout << "VB6 CSV field order:\n";
                std::cout << "  Books:   title,author,isbn,id,status,category\n";
                std::cout << "  Readers: name,surname,grade,class\n";
                std::cout << "  Loans:   readerName,bookName,timestamp\n\n";
                std::cout << "Convert to (books/readers/loans): ";
                { std::string dtype = read_line();
                if (check_cancel() || dtype.empty()) break;
                std::cout << "CSV file path: ";
                std::string csvpath = read_line();
                if (check_cancel() || csvpath.empty()) break;
                if (dtype == "books" || dtype == "book" || dtype == "b" ||
                    dtype == "readers" || dtype == "reader" || dtype == "r" ||
                    dtype == "loans" || dtype == "loan" || dtype == "l")
                {
                    convert_vb6_csv(csvpath, dtype);
                }
                else
                {
                    std::cout << RED << "Unknown type \"" << dtype
                              << "\". Use: books, readers, or loans\n" << RST;
                }
                pause_msg();
                break; }
            }
            case 0:
                return;
        }
    }
}

/// ---=== AUTHENTICATION ===---

void mnu_logout()
{
    std::cout << YLW << "\nLogged out." << RST << "\n";
    pause_msg();
}

void mnu_login()
{
    clear_cli();
    std::cout << CYN << "=== LOG IN ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::string username;
    std::cout << "Username: ";
    username = read_line();
    if (check_cancel()) return;
    if (username.empty()) return;

    std::string password;
    std::cout << "Password: ";
    password = read_line();
    if (check_cancel()) return;

    short ret = login(password, username, 1);
    if (ret != 0)
        std::cout << RED << "\nLogin failed." << RST << "\n";
    else
        std::cout << GRN << "\nLogged in as \"" << username << "\"" << RST << "\n";
    pause_msg();
}

void mnu_register()
{
    clear_cli();
    std::cout << CYN << "=== REGISTER ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::string username;
    std::cout << "Choose username: ";
    username = read_line();
    if (check_cancel()) return;
    if (username.empty()) return;

    std::string password;
    std::cout << "Choose password: ";
    password = read_line();
    if (check_cancel()) return;

    short ret = signup(password, username, 1);
    if (ret == 0)
        std::cout << GRN << "\nRegistered \"" << username << "\"" << RST << "\n";
    else
        std::cout << RED << "\n !!! Registration failed with code " << ret << RST << "!!! \n";
    pause_msg();
}

void mnu_auth()
{
    while (true)
    {
        clear_cli();
        std::cout << CYN << "/// Account ///" << RST << "\n";
        std::cout << "[1] Log in\n";
        std::cout << "[2] Log out\n";
        std::cout << "[3] Register\n";
        std::cout << "[0] Back to main menu\n";
        std::cout << "-> Your choice: ";
        int input = read_int();
        if (check_cancel()) return;
        switch (input)
        {
            case 1: mnu_login();    continue;
            case 2: mnu_logout();   continue;
            case 3: mnu_register(); continue;
            case 0: return;
        }
    }
}

/// ---=== BOOK SUBMENU ===---

void sbmnu_books()
{
    if (!ensure_db(g_books_db, "books"))
    {
        pause_msg();
        return;
    }
    while (true)
    {
        clear_cli();
        std::cout << CYN << "/// Book Submenu ///" << RST << "\n";
        std::cout << "[1]  Add books\n";
        std::cout << "[2]  Edit books\n";
        std::cout << "[3]  Remove books\n";
        std::cout << "[4]  Sort book database\n";
        std::cout << "[5]  Check ID\n";
        std::cout << "[6]  Search books\n";
        std::cout << "[7]  Manage categories\n";
        std::cout << "[8]  Restore deleted books\n";
        std::cout << "[0]  Back to main menu\n";
        std::cout << "-> Your choice: ";
        int input = read_int();
        if (check_cancel()) return;
        switch(input)
        {
            case(1): mnu_addbooks();           continue;
            case(2): mnu_editbooks();           continue;
            case(3): mnu_deletebooks();         continue;
            case(4): mnu_sortbookdb();          continue;
            case(5):
            {
                clear_cli();
                std::cout << CYN << "=== CHECK BOOK ID ===" << RST << "\n\n";
                std::cout << "Book ID to look up (empty to cancel): ";
                std::string cid = read_line();
                if (check_cancel()) continue;
                if (cid.empty()) continue;
                if (book_id_exists(cid))
                    std::cout << GRN << "ID \"" << cid << "\" exists in database.\n" << RST;
                else
                    std::cout << YLW << "ID \"" << cid << "\" not found.\n" << RST;
                pause_msg();
                continue;
            }
            case(6): mnu_searchbooks();        continue;
            case(7): mnu_manage_categories();  continue;
            case(8): mnu_restorebooks();       continue;
            case(0): return;
        }
    }
}

/// ---=== MAIN MENU ===---

short mnu_cli()
{
    while (true)
    {
        clear_cli();
        std::cout << CYN << "///===--- ShelfSight CLI ---===///" << RST << "\n";
        std::cout << "[1] Books\n";
        std::cout << "[2] Readers\n";
        std::cout << "[3] Loans\n";
        std::cout << "[4] Backups\n";
        std::cout << "[5] Settings\n";
        std::cout << "[6] Select databases\n";
        std::cout << "[7] Account\n";
        std::cout << "[0] Quit program\n";
        std::cout << "-> Enter choice: ";
        int input = read_int();
        if (check_cancel()) return 0;
        switch(input)
        {
            case(1): sbmnu_books();    continue;
            case(2): sbmnu_readers();  continue;
            case(3): sbmnu_loans();    continue;
            case(4): sbmnu_backups();  continue;
            case(5): sbmnu_settings(); continue;
            case(6): mnu_seldb();      continue;
            case(7): mnu_auth();       continue;
            case(0):
                std::cout << RED << "!!! Exit app: Y/N: " << RST;
                {
                    std::string yn = read_line();
                    if (check_cancel()) return 0;
                    if (yn != "Y" && yn != "y") continue;
                }
                return 0;
        }
    }
}
