#include <iostream>
#include <fstream>
#include <sstream>
#include <ctime>
#include <cstdio>
#include <cctype>
#include <sys/stat.h>
#include <dirent.h>
#include "main.h"
#include "glob_vars.h"

short find_string_in_file(const std::string & filename, std::string string_to_find) {
  std::ifstream file(filename);
  std::string line;

  if (file.is_open()) {
    while (std::getline(file, line)) {
      if (line == string_to_find)
      {
        return 0;
      }
    }
    file.close();
  } else {
    std::cout << RED << "Failed to open the file " << filename << RST << "\n";
    return 1;
  }
  return 2;
}

short count_string_in_file(const std::string & filename, std::string string_to_find) {
  std::ifstream file(filename);
  std::string line;
  long long counter = 0;

  if (file.is_open()) {
    while (std::getline(file, line)) {
      if (line == string_to_find)
      {
        counter++;
      }
    }
    file.close();
  } else {
    std::cout << RED << "Failed to open the file " << filename << RST << "\n";
    return -1;
  }
  return counter;
}

short load_categories_books()
{
    std::ifstream file(g_categors_cat);
    if (!file.is_open())
    {
        std::cout << YLW << "No " << g_categors_cat << " found, using defaults.\n" << RST;
        return 1;
    }
    g_categories.clear();
    std::string line;
    while (std::getline(file, line))
    {
        if (!line.empty())
            g_categories.push_back(line);
    }
    file.close();
    std::cout << GRN << "Loaded " << g_categories.size() << " categories.\n" << RST;
    return 0;
}

short create_file(std::string name, std::string extention, std::string path)
{
    std::ofstream file;

    file.open(name + '.' + extention);

    if (!file.is_open())
    {
        std::cout << RED << "!!! Error in creating file " << name << "."
                  << extention << " !!!" << RST << "\n";
        return 1;
    }
    std::cout << GRN << ":) File created successfully: " << name << "."
              << extention << " :)" << RST << "\n";

    file.close();
    return 0;
}

short signup(std::string pwd_plain, std::string usr_plain, short role)
{
    std::cout << YLW << "Registering account..." << RST << "\n";
    std::ofstream myfile;
    myfile.open("CREDS.LGN");
    if (!myfile.is_open())
    {
        std::cout << RED << "!!! Error in opening file CREDS.LGN !!!" << RST << "\n";
        return 1;
    }
    std::string hash_string = "";
    myfile << hash_string;
    myfile.close();
    return 0;
}

short login(std::string pwd_plain, std::string usr_plain, short role)
{
    std::cout << YLW << "Logging in..." << RST << "\n";
}

bool db_exists(const std::string& path)
{
    std::ifstream f(path);
    return f.is_open();
}

short save_book(const std::string& title, const std::string& author,
                const std::string& isbn, const std::string& id,
                const std::string& category, const std::string& status)
{
    std::ofstream file(g_books_db, std::ios::app);
    if (!file.is_open())
    {
        std::cout << RED << "!!! Cannot open " << g_books_db << " !!!" << RST << "\n";
        return 1;
    }
    file << title << "|" << author << "|" << isbn << "|"
         << id << "|" << category << "|" << status << "\n";
    file.close();
    std::cout << GRN << "Book \"" << title << "\" saved to " << g_books_db << RST << "\n";
    return 0;
}

bool book_id_exists(const std::string& id)
{
    std::ifstream file(g_books_db);
    if (!file.is_open()) return false;
    std::string line;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t pos = 0;
        for (int i = 0; i < 3; ++i)
        {
            pos = line.find('|', pos);
            if (pos == std::string::npos) break;
            ++pos;
        }
        std::string id_in_line;
        if (pos != std::string::npos)
            id_in_line = line.substr(pos, line.find('|', pos) - pos);
        if (id_in_line == id)
        {
            file.close();
            return true;
        }
    }
    file.close();
    return false;
}

bool reader_exists(const std::string& name, const std::string& surname)
{
    std::ifstream file(g_readers_db);
    if (!file.is_open()) return false;
    std::string line;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t pos0 = line.find('|');
        if (pos0 == std::string::npos) continue;
        std::size_t pos1 = line.find('|', pos0 + 1);
        if (pos1 == std::string::npos) continue;
        std::string n = line.substr(0, pos0);
        std::string s = line.substr(pos0 + 1, pos1 - pos0 - 1);
        if (n == name && s == surname)
        {
            file.close();
            return true;
        }
    }
    file.close();
    return false;
}

bool loan_id_exists(const std::string& id)
{
    std::ifstream file(g_loans_db);
    if (!file.is_open()) return false;
    std::string line;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t end = line.find('|');
        std::string id_in_line = line.substr(0, end);
        if (id_in_line == id)
        {
            file.close();
            return true;
        }
    }
    file.close();
    return false;
}

short save_reader(const std::string& name, const std::string& surname,
                  const std::string& grade, const std::string& cls)
{
    std::ofstream file(g_readers_db, std::ios::app);
    if (!file.is_open())
    {
        std::cout << RED << "!!! Cannot open " << g_readers_db << " !!!" << RST << "\n";
        return 1;
    }
    file << name << "|" << surname << "|" << grade << "|" << cls << "\n";
    file.close();
    std::cout << GRN << "Reader \"" << name << " " << surname << "\" saved." << RST << "\n";
    return 0;
}

short save_loan(const std::string& book_id, const std::string& reader_id,
                const std::string& loan_date, const std::string& expiration_date)
{
    std::ofstream file(g_loans_db, std::ios::app);
    if (!file.is_open())
    {
        std::cout << RED << "!!! Cannot open " << g_loans_db << " !!!" << RST << "\n";
        return 1;
    }
    file << book_id << "|" << reader_id << "|" << loan_date << "|"
         << expiration_date << "|active\n";
    file.close();
    std::cout << GRN << "Loan added (book " << book_id << " -> reader "
              << reader_id << ")." << RST << "\n";
    return 0;
}

bool get_loan_line(const std::string& book_id, std::string& out_line)
{
    std::ifstream file(g_loans_db);
    if (!file.is_open()) return false;
    std::string line;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t end = line.find('|');
        std::string id_in_line = line.substr(0, end);
        if (id_in_line == book_id)
        {
            out_line = line;
            file.close();
            return true;
        }
    }
    file.close();
    return false;
}

std::string get_loan_field(const std::string& book_id, int field_index)
{
    std::string line;
    if (!get_loan_line(book_id, line)) return "";
    std::size_t start = 0;
    for (int i = 0; i < field_index; ++i)
    {
        start = line.find('|', start);
        if (start == std::string::npos) return "";
        ++start;
    }
    std::size_t end = line.find('|', start);
    return line.substr(start, end - start);
}

short update_loan_field(const std::string& book_id, int field_index,
                          const std::string& new_value)
{
    std::ifstream file(g_loans_db);
    if (!file.is_open())
    {
        std::cout << RED << "!!! Cannot open " << g_loans_db << " !!!" << RST << "\n";
        return 1;
    }
    std::vector<std::string> lines;
    std::string line;
    bool found = false;
    while (std::getline(file, line))
    {
        if (line.empty()) { lines.push_back(line); continue; }
        std::size_t end = line.find('|');
        std::string id_in_line = line.substr(0, end);
        if (id_in_line == book_id)
        {
            found = true;
            std::size_t start = 0;
            for (int i = 0; i < field_index; ++i)
            {
                start = line.find('|', start);
                if (start == std::string::npos) break;
                ++start;
            }
            std::size_t fend = line.find('|', start);
            if (start != std::string::npos)
            {
                std::string before = line.substr(0, start);
                std::string after = (fend != std::string::npos)
                    ? line.substr(fend) : "";
                line = before + new_value + after;
            }
        }
        lines.push_back(line);
    }
    file.close();
    if (!found)
    {
        std::cout << RED << "Loan " << book_id << " not found.\n" << RST;
        return 2;
    }
    std::ofstream ofile(g_loans_db, std::ios::trunc);
    if (!ofile.is_open())
    {
        std::cout << RED << "!!! Cannot write " << g_loans_db << " !!!" << RST << "\n";
        return 1;
    }
    for (const auto& l : lines)
        ofile << l << "\n";
    ofile.close();
    return 0;
}

short delete_loan(const std::string& book_id)
{
    std::ifstream file(g_loans_db);
    if (!file.is_open())
    {
        std::cout << RED << "!!! Cannot open " << g_loans_db << " !!!" << RST << "\n";
        return 1;
    }
    std::vector<std::string> lines;
    std::string line;
    bool found = false;
    while (std::getline(file, line))
    {
        if (line.empty()) continue;
        std::size_t end = line.find('|');
        std::string id_in_line = line.substr(0, end);
        if (id_in_line == book_id)
        {
            found = true;
            continue;
        }
        lines.push_back(line);
    }
    file.close();
    if (!found)
    {
        std::cout << RED << "Loan " << book_id << " not found.\n" << RST;
        return 2;
    }
    std::ofstream ofile(g_loans_db, std::ios::trunc);
    if (!ofile.is_open())
    {
        std::cout << RED << "!!! Cannot write " << g_loans_db << " !!!" << RST << "\n";
        return 1;
    }
    for (const auto& l : lines)
        ofile << l << "\n";
    ofile.close();
    std::cout << GRN << "Loan " << book_id << " deleted.\n" << RST;
    return 0;
}

std::string get_current_date_str()
{
    std::time_t t = std::time(nullptr);
    std::tm* tm = std::localtime(&t);
    char buf[32];
    std::snprintf(buf, sizeof(buf), "%04d-%02d-%02d",
                  tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday);
    return std::string(buf);
}

std::string add_days_to_date(const std::string& date, int days)
{
    int y, m, d;
    if (std::sscanf(date.c_str(), "%d-%d-%d", &y, &m, &d) != 3)
        return date;
    std::tm tm = {};
    tm.tm_year = y - 1900;
    tm.tm_mon  = m - 1;
    tm.tm_mday = d;
    std::mktime(&tm);
    tm.tm_mday += days;
    std::mktime(&tm);
    char buf[32];
    std::snprintf(buf, sizeof(buf), "%04d-%02d-%02d",
                  tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday);
    return std::string(buf);
}

short backup_file(const std::string& src_path, const std::string& dest_dir)
{
    std::ifstream src(src_path, std::ios::binary);
    if (!src.is_open())
    {
        std::cout << RED << "Cannot open source: " << src_path << RST << "\n";
        return 1;
    }
    std::string fname = src_path;
    std::size_t slash = fname.rfind('/');
    if (slash != std::string::npos) fname = fname.substr(slash + 1);
    std::string dst_path = dest_dir + "/" + fname;
    std::ofstream dst(dst_path, std::ios::binary);
    if (!dst.is_open())
    {
        std::cout << RED << "Cannot create: " << dst_path << RST << "\n";
        return 1;
    }
    dst << src.rdbuf();
    src.close();
    dst.close();
    std::cout << GRN << "Backed up " << src_path << " -> " << dst_path << RST << "\n";
    return 0;
}

bool load_settings()
{
    std::ifstream file(g_settings_file);
    if (!file.is_open()) return false;
    std::string line;
    int lineno = 0;
    while (std::getline(file, line))
    {
        ++lineno;
        if (line.empty()) continue;
        switch (lineno)
        {
            case 1: g_default_language = line; break;
            case 2: g_save_worklogs = (line == "True"); break;
            case 3: g_enable_networking = (line == "True"); break;
            case 4: g_enable_same_ids = (line == "True"); break;
            case 5: g_check_loans = (line == "True"); break;
            case 6: try { g_default_loan_duration = std::stoi(line); } catch (...) {} break;
        }
    }
    file.close();
    return true;
}

bool save_settings()
{
    std::ofstream file(g_settings_file, std::ios::trunc);
    if (!file.is_open()) return false;
    file << g_default_language << "\n";
    file << (g_save_worklogs ? "True" : "False") << "\n";
    file << (g_enable_networking ? "True" : "False") << "\n";
    file << (g_enable_same_ids ? "True" : "False") << "\n";
    file << (g_check_loans ? "True" : "False") << "\n";
    file << g_default_loan_duration << "\n";
    file.close();
    return true;
}

static std::string trim_str(const std::string& s)
{
    std::size_t start = s.find_first_not_of(" \t\r\n");
    if (start == std::string::npos) return "";
    std::size_t end = s.find_last_not_of(" \t\r\n");
    return s.substr(start, end - start + 1);
}

static std::vector<std::string> parse_csv_line(const std::string& line)
{
    std::vector<std::string> fields;
    std::string field;
    bool in_quotes = false;
    for (std::size_t i = 0; i < line.size(); ++i)
    {
        char c = line[i];
        if (in_quotes)
        {
            if (c == '"')
            {
                if (i + 1 < line.size() && line[i + 1] == '"')
                {
                    field += '"';
                    ++i;
                }
                else
                {
                    in_quotes = false;
                }
            }
            else
            {
                field += c;
            }
        }
        else
        {
            if (c == '"')
            {
                in_quotes = true;
            }
            else if (c == ',')
            {
                fields.push_back(field);
                field.clear();
            }
            else
            {
                field += c;
            }
        }
    }
    fields.push_back(field);
    return fields;
}

short convert_vb6_csv(const std::string& csv_path, const std::string& db_type)
{
    std::ifstream file(csv_path);
    if (!file.is_open())
    {
        std::cout << RED << "Cannot open " << csv_path << RST << "\n";
        return 1;
    }
    std::string line;
    int lineno = 0;
    int converted = 0;
    int skipped = 0;

    while (std::getline(file, line))
    {
        ++lineno;
        line = trim_str(line);
        if (line.empty()) continue;

        if (lineno == 1)
        {
            std::string lower;
            for (char c : line) lower += static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
            if (lower.find("books") != std::string::npos ||
                lower.find("readers") != std::string::npos ||
                lower.find("reader") != std::string::npos ||
                lower.find("loans") != std::string::npos ||
                lower.find("loan") != std::string::npos ||
                lower.find("language") != std::string::npos ||
                lower.find("title") != std::string::npos ||
                lower.find("name") != std::string::npos)
            {
                continue;
            }
        }

        std::vector<std::string> fields = parse_csv_line(line);

        if (db_type == "books" || db_type == "book" || db_type == "b")
        {
            if (fields.size() < 6)
            {
                ++skipped;
                continue;
            }
            std::string title    = trim_str(fields[0]);
            std::string author   = trim_str(fields[1]);
            std::string isbn     = trim_str(fields[2]);
            std::string id       = trim_str(fields[3]);
            std::string status   = trim_str(fields[4]);
            std::string category = trim_str(fields[5]);
            if (title.empty() && author.empty()) { ++skipped; continue; }
            std::ofstream of(g_books_db, std::ios::app);
            if (of.is_open())
            {
                of << title << "|" << author << "|" << isbn << "|"
                   << id << "|" << category << "|" << status << "\n";
                of.close();
                ++converted;
            }
        }
        else if (db_type == "readers" || db_type == "reader" || db_type == "r")
        {
            if (fields.size() < 2)
            {
                ++skipped;
                continue;
            }
            std::string name    = trim_str(fields[0]);
            std::string surname = trim_str(fields[1]);
            std::string grade   = (fields.size() >= 3) ? trim_str(fields[2]) : "";
            std::string cls     = (fields.size() >= 4) ? trim_str(fields[3]) : "";

            if (name.empty() && surname.empty()) { ++skipped; continue; }

            std::ofstream of(g_readers_db, std::ios::app);
            if (of.is_open())
            {
                of << name << "|" << surname << "|" << grade << "|" << cls << "\n";
                of.close();
                ++converted;
            }
        }
        else if (db_type == "loans" || db_type == "loan" || db_type == "l")
        {
            if (fields.size() < 3)
            {
                ++skipped;
                continue;
            }
            std::string reader_name = trim_str(fields[0]);
            std::string book_name   = trim_str(fields[1]);
            std::string ts          = trim_str(fields[2]);
            std::string loan_date   = ts.substr(0, 10);
            int dur = (g_default_loan_duration > 0) ? g_default_loan_duration : 14;
            std::string exp_date    = add_days_to_date(loan_date, dur);
            std::ofstream of(g_loans_db, std::ios::app);
            if (of.is_open())
            {
                of << book_name << "|" << reader_name << "|"
                   << loan_date << "|" << exp_date << "|active\n";
                of.close();
                ++converted;
            }
        }
    }
    file.close();

    std::cout << GRN << "Converted " << converted << " record(s)";
    if (skipped > 0) std::cout << YLW << " (" << skipped << " skipped)";
    std::cout << RST << "\n";
    return 0;
}
