#include "glob_vars.h"

std::vector<std::string> g_categories = {
    "Fiction",
    "Non-Fiction",
    "Science",
    "History",
    "Fantasy",
    "Biography",
    "Technology",
    "Art",
    "Philosophy",
    "Children"
};

std::string g_books_db       = "BOOKS.DB";
std::string g_readers_db     = "READERS.DB";
std::string g_loans_db       = "LOANS.DB";
std::string g_categors_cat   = "CATEGORS.CAT";
std::string g_settings_file  = "SETTINGS.CFG";
std::string g_default_language = "English-US";
bool        g_save_worklogs    = true;
bool        g_enable_networking = false;
bool        g_enable_same_ids  = false;
bool        g_check_loans      = true;
int         g_default_loan_duration = 14;
