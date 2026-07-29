#include <iostream>
#include <limits>
#include "main.h"
#include "file_man.h"

/// ### PRE-DEFINITIONS ###
short mnu_cli();

/// ---=== BOOKS ===---

static bool check_cancel()
{
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

void mnu_addbooks()
{
    clear_cli();
    std::cout << CYN << "=== ADD BOOKS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::string title;
    std::cout << "Book title: ";
    std::getline(std::cin >> std::ws, title);
    if (check_cancel()) return;
    if (title.empty()) return;

    std::string author;
    std::cout << "Author: ";
    std::getline(std::cin, author);
    if (check_cancel()) return;

    std::string isbn;
    std::cout << "ISBN: ";
    std::getline(std::cin, isbn);
    if (check_cancel()) return;

    std::cout << GRN << "\nWould add: \"" << title << "\" by " << author
              << " (ISBN: " << isbn << ")" << RST << "\n\n";
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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

    std::string new_title;
    std::cout << "New title: ";
    new_title = read_line();
    if (check_cancel()) return;

    std::cout << GRN << "\nWould update book " << id << " to title: \""
              << new_title << "\"" << RST << "\n\n";
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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

    std::cout << "Remove book " << id << "? (Y/N): ";
    std::string confirm = read_line();
    if (check_cancel()) return;

    if (confirm == "Y" || confirm == "y")
    {
        std::cout << RED << "\nWould delete book " << id << RST << "\n\n";
    }
    else
    {
        std::cout << YLW << "\nDeletion cancelled." << RST << "\n\n";
    }
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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
    std::cout << "[0] Cancel\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;

    switch (choice)
    {
        case 1: std::cout << GRN << "\nSorting by title..." << RST << "\n";    break;
        case 2: std::cout << GRN << "\nSorting by author..." << RST << "\n";   break;
        case 3: std::cout << GRN << "\nSorting by ISBN..." << RST << "\n";     break;
        default: std::cout << YLW << "\nSort cancelled." << RST << "\n";       return;
    }
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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

    std::cout << GRN << "\nWould add reader: \"" << name << "\"" << RST << "\n\n";
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

void mnu_editreader()
{
    clear_cli();
    std::cout << CYN << "=== EDIT READER ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Reader ID to edit (0 to cancel): ";
    int id = read_int();
    if (check_cancel()) return;
    if (id <= 0) return;

    std::string new_name;
    std::cout << "New name: ";
    new_name = read_line();
    if (check_cancel()) return;

    std::cout << GRN << "\nWould update reader " << id << " to: \""
              << new_name << "\"" << RST << "\n\n";
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

void mnu_rmreader()
{
    clear_cli();
    std::cout << CYN << "=== REMOVE READER ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Reader ID to remove (0 to cancel): ";
    int id = read_int();
    if (check_cancel()) return;
    if (id <= 0) return;

    std::cout << "Remove reader " << id << "? (Y/N): ";
    std::string confirm = read_line();
    if (check_cancel()) return;

    if (confirm == "Y" || confirm == "y")
        std::cout << RED << "\nWould delete reader " << id << RST << "\n\n";
    else
        std::cout << YLW << "\nDeletion cancelled." << RST << "\n\n";

    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

void sbmnu_readers()
{
    while (true)
    {
        clear_cli();
        std::cout << CYN << "/// Reader Submenu ///" << RST << "\n";
        std::cout << "[1] Add reader\n";
        std::cout << "[2] Edit reader\n";
        std::cout << "[3] Remove reader\n";
        std::cout << "[4] Sort reader database\n";
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

    std::cout << "Reader ID (0 to cancel): ";
    int reader_id = read_int();
    if (check_cancel()) return;
    if (reader_id <= 0) return;

    std::cout << GRN << "\nWould loan book " << book_id
              << " to reader " << reader_id << RST << "\n\n";
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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

    std::cout << GRN << "\nWould mark loan " << id << " as returned" << RST << "\n\n";
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

void mnu_listloans()
{
    clear_cli();
    std::cout << CYN << "=== ACTIVE LOANS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Listing active loans...\n";
    std::cout << "(no loans in database yet)\n\n";
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

void sbmnu_loans()
{
    while (true)
    {
        clear_cli();
        std::cout << CYN << "/// Loan Submenu ///" << RST << "\n";
        std::cout << "[1] Add loan\n";
        std::cout << "[2] Return loan\n";
        std::cout << "[3] List active loans\n";
        std::cout << "[0] Back to main menu\n";
        std::cout << "-> Your choice: ";
        int input = read_int();
        if (check_cancel()) return;
        switch(input)
        {
            case(1): mnu_addloan();      continue;
            case(2): mnu_returnloan();   continue;
            case(3): mnu_listloans();    continue;
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

    std::cout << "Backup name: ";
    std::string name = read_line();
    if (check_cancel()) return;
    if (name.empty()) return;

    std::cout << GRN << "\nWould create backup \"" << name << "\"" << RST << "\n\n";
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

void mnu_restorebackup()
{
    clear_cli();
    std::cout << CYN << "=== RESTORE BACKUP ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Backup ID to restore (0 to cancel): ";
    int id = read_int();
    if (check_cancel()) return;
    if (id <= 0) return;

    std::cout << "Restore backup " << id << "? (Y/N): ";
    std::string confirm = read_line();
    if (check_cancel()) return;

    if (confirm == "Y" || confirm == "y")
        std::cout << RED << "\nWould restore backup " << id << RST << "\n\n";
    else
        std::cout << YLW << "\nRestore cancelled." << RST << "\n\n";

    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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

void mnu_changesettings()
{
    clear_cli();
    std::cout << CYN << "=== CHANGE SETTINGS ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Setting to change:\n";
    std::cout << "[1] Theme\n";
    std::cout << "[2] Language\n";
    std::cout << "[0] Cancel\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;

    switch (choice)
    {
        case 1: std::cout << GRN << "\nTheme changed." << RST << "\n";      break;
        case 2: std::cout << GRN << "\nLanguage changed." << RST << "\n";   break;
        default: std::cout << YLW << "\nCancelled." << RST << "\n";         return;
    }
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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
        std::cout << RED << "\nSettings reset to defaults." << RST << "\n\n";
    else
        std::cout << YLW << "\nReset cancelled." << RST << "\n\n";

    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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

/// ---=== SINGLE-ACTION FUNCTIONS ===---

void mnu_seldb()
{
    clear_cli();
    std::cout << CYN << "=== SELECT SESSION DATABASES ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "Available databases:\n";
    std::cout << "[1] Default\n";
    std::cout << "[2] Custom path\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;

    if (choice == 2)
    {
        std::cout << "Enter path: ";
        std::string path = read_line();
        if (check_cancel()) return;
        if (!path.empty())
            std::cout << GRN << "\nSelected: " << path << RST << "\n";
    }
    else
    {
        std::cout << GRN << "\nUsing default databases." << RST << "\n";
    }
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

void mnu_login()
{
    clear_cli();
    std::cout << CYN << "=== LOG IN/OUT ===" << RST << "\n";
    std::cout << YLW << "iii empty to go back iii" << RST << "\n\n";

    std::cout << "[1] Log in\n";
    std::cout << "[2] Log out\n";
    std::cout << "-> Your choice: ";
    int choice = read_int();
    if (check_cancel()) return;

    if (choice == 1)
    {
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
    }
    else if (choice == 2)
    {
        std::cout << YLW << "\nLogged out." << RST << "\n";
    }
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
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
    std::cout << "Press Enter to continue...";
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

/// ---=== BOOKS ===---

void sbmnu_books()
{
    while (true)
    {
        clear_cli();
        std::cout << CYN << "/// Book Submenu ///" << RST << "\n";
        std::cout << "[1] Add books \n";
        std::cout << "[2] Edit books \n";
        std::cout << "[3] Remove books \n";
        std::cout << "[4] Sort book database \n";
        std::cout << "[0] Back to main menu \n";
        std::cout << "-> Your choice: ";
        int input = read_int();
        if (check_cancel()) return;
        switch(input)
        {
            case(1):
                mnu_addbooks();
                continue;
            case(2):
                mnu_editbooks();
                continue;
            case(3):
                mnu_deletebooks();
                continue;
            case(4):
                mnu_sortbookdb();
                continue;
            case(0):
                return;
        }
    }
}

// menu CLI - like main view in FLTK implementation
short mnu_cli()
{
    while (true)
    {
        clear_cli();
        std::cout << CYN << "///===--- ShelfSight CLI ---===///" << RST << "\n";
        std::cout << "[1] Books \n";
        std::cout << "[2] Readers \n";
        std::cout << "[3] Loans \n";
        std::cout << "[4] Backups \n";
        std::cout << "[5] Settings \n";
        std::cout << "[6] Select session databases \n";
        std::cout << "[7] Log in/out \n";
        std::cout << "[8] Register \n";
        std::cout << "[0] Quit program \n";
        std::cout << "-> Enter choice: ";
        int input = read_int();
        if (check_cancel()) continue;
        switch(input)
        {
            case(1): sbmnu_books();   continue;
            case(2): sbmnu_readers(); continue;
            case(3): sbmnu_loans();   continue;
            case(4): sbmnu_backups(); continue;
            case(5): sbmnu_settings(); continue;
            case(6): mnu_seldb();     continue;
            case(7): mnu_login();     continue;
            case(8): mnu_register();  continue;
            case(0):
                std::cout << RED << "!!! Exit app: Y/N: " << RST;
                {
                    std::string yn = read_line();
                    if (check_cancel()) continue;
                    if (yn != "Y" && yn != "y") continue;
                }
                return 0;
        }
    }
}