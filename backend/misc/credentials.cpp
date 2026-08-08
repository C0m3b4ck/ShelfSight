#include "credentials.h"

#include "crypto.h"

#include <algorithm>
#include <cctype>
#include <cstdio>

namespace shelfsight {

namespace {

std::string trim(const std::string& s) {
    size_t start = 0;
    while (start < s.size() && std::isspace(static_cast<unsigned char>(s[start]))) ++start;
    size_t end = s.size();
    while (end > start && std::isspace(static_cast<unsigned char>(s[end - 1]))) --end;
    return s.substr(start, end - start);
}

} // namespace

std::string auth_result_message(AuthResult r) {
    switch (r) {
        case AuthResult::Success:
            return "Operation successful.";
        case AuthResult::InvalidInput:
            return "Username and password are required.";
        case AuthResult::PasswordsMismatch:
            return "The two passwords do not match.";
        case AuthResult::UserExists:
            return "This user already exists.";
        case AuthResult::UserNotFound:
            return "Invalid username or password.";
        case AuthResult::RoleInvalid:
            return "A valid role must be selected.";
        case AuthResult::DbError:
            return "A database error occurred.";
        case AuthResult::PasswordsTooShort:
            return "Passwords must be at least 8 characters long.";
        case AuthResult::EmptyUsername:
            return "Username must not be empty.";
    }
    return "Unknown error.";
}

AuthResult CredentialManager::login(const std::string& username, const std::string& password,
                                    int role) {
    const std::string u = trim(username);
    const std::string p = trim(password);
    if (u.empty() || p.empty()) return AuthResult::InvalidInput;

    const std::string hash = credential_hash(u, p, role);
    if (db_.verify_credential(u, hash, role)) return AuthResult::Success;
    return AuthResult::UserNotFound;
}

AuthResult CredentialManager::register_user(const std::string& username,
                                            const std::string& password1,
                                            const std::string& password2, int role) {
    if (password1.size() < 8 || password2.size() < 8) return AuthResult::PasswordsTooShort;
    const std::string u = trim(username);
    if (u.empty()) return AuthResult::EmptyUsername;
    if (role < 1 || role > 3) return AuthResult::RoleInvalid;
    if (password1 != password2) return AuthResult::PasswordsMismatch;

    if (db_.get_credential(u)) return AuthResult::UserExists;

    const std::string hash = credential_hash(u, password1, role);
    Credential c;
    c.username = u;
    c.password_hash = hash;
    c.role = role;
    if (!db_.add_credential(c)) return AuthResult::DbError;
    return AuthResult::Success;
}

} // namespace shelfsight