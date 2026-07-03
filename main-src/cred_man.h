//cred_man.h
#include "cred_man.cpp"
#pragma once

short open_login_file(char mode);
short write_login_file(char mode, const std::string& data);
bool file_contains_string(const std::string& searched_string, const std::string& filename);
std::string trim(const std::string& str);
bool verify_login(std::string plaintext_password, std::string plaintext_username, short role);
short register_in_db(std::string credentials);
short verify_register(std::string plaintext_password1, std::string plaintext_password2, std::string plaintext_username, short role)
