#pragma once

#include "database.h"

#include <string>

namespace shelfsight {

enum class AuthResult {
    Success,
    InvalidInput,
    PasswordsMismatch,
    UserExists,
    UserNotFound,
    RoleInvalid,
    DbError,
    PasswordsTooShort,
    EmptyUsername,
};

std::string auth_result_message(AuthResult r);

class CredentialManager {
public:
    explicit CredentialManager(Database& db) : db_(db) {}

    // Role is 1-based user-facing: 1 = user, 2 = librarian, 3 = admin.
    AuthResult login(const std::string& username, const std::string& password, int role);
    AuthResult register_user(const std::string& username, const std::string& password1,
                             const std::string& password2, int role);

private:
    Database& db_;
};

} // namespace shelfsight