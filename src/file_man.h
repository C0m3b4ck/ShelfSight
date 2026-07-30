#pragma once

#include <string>
#include <vector>

short find_string_in_file(const std::string& filename, std::string string_to_find);
short count_string_in_file(const std::string& filename, std::string string_to_find);
short load_categories_books();
short create_file(std::string name, std::string extention, std::string path);
short signup(std::string pwd_plain, std::string usr_plain, short role);
short login(std::string pwd_plain, std::string usr_plain, short role);
short save_book(const std::string& title, const std::string& author,
                const std::string& isbn, const std::string& id,
                const std::string& category, const std::string& status);
bool   db_exists(const std::string& path);
bool   book_id_exists(const std::string& id);
bool   reader_exists(const std::string& name, const std::string& surname);
bool   loan_id_exists(const std::string& id);
short  save_reader(const std::string& name, const std::string& surname,
                   const std::string& grade, const std::string& cls);
short  save_loan(const std::string& book_id, const std::string& reader_id,
                 const std::string& loan_date, const std::string& expiration_date);
bool   get_loan_line(const std::string& book_id, std::string& out_line);
short  update_loan_field(const std::string& book_id, int field_index,
                         const std::string& new_value);
short  delete_loan(const std::string& book_id);
std::string get_loan_field(const std::string& book_id, int field_index);
std::string get_current_date_str();
std::string add_days_to_date(const std::string& date, int days);
short backup_file(const std::string& src_path, const std::string& dest_dir);
bool load_settings();
bool save_settings();
short convert_vb6_csv(const std::string& csv_path, const std::string& db_type);
