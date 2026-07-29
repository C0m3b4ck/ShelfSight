#pragma once

#include <string>

short find_string_in_file(const std::string& filename, std::string string_to_find);
short count_string_in_file(const std::string& filename, std::string string_to_find);
short load_categories_books();
short create_file(std::string name, std::string extention, std::string path);
short signup(std::string pwd_plain, std::string usr_plain, short role);
short login(std::string pwd_plain, std::string usr_plain, short role);
