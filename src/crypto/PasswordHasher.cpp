/**
 * PasswordHasher.cpp
 *
 * Tutorial note — sodium_init():
 *   libsodium requires a one-time initialisation before any of its functions
 *   are called.  We use a local static bool inside a lambda — the C++11
 *   "magic statics" guarantee that this runs exactly once, even if multiple
 *   threads call ensureInit() simultaneously.
 *
 * Tutorial note — never roll your own crypto:
 *   This file intentionally delegates 100% of the cryptographic work to
 *   libsodium.  Implementing Argon2 (or any password hash) yourself is
 *   almost certain to introduce subtle vulnerabilities.  Always use a
 *   well-audited library.
 */
#include "PasswordHasher.h"
#include <sodium.h>
#include <stdexcept>
#include <string>

namespace Librarian {

namespace {

void ensureInit() {
    static const bool ok = [] {
        if (sodium_init() < 0)
            throw std::runtime_error("libsodium initialisation failed");
        return true;
    }();
    (void)ok;
}

// Argon2id parameters — INTERACTIVE is the recommended starting point.
// Increase to SENSITIVE for higher-value accounts (admin only, etc.).
constexpr auto k_opsLimit = crypto_pwhash_OPSLIMIT_INTERACTIVE;
constexpr auto k_memLimit = crypto_pwhash_MEMLIMIT_INTERACTIVE;
constexpr auto k_alg      = crypto_pwhash_ALG_ARGON2ID13;

} // anonymous namespace

std::string PasswordHasher::hash(const std::string& password) {
    ensureInit();

    char hashBuf[crypto_pwhash_STRBYTES];

    if (crypto_pwhash_str_alg(
            hashBuf,
            password.data(),
            static_cast<unsigned long long>(password.size()),
            k_opsLimit, k_memLimit, k_alg) != 0) {
        throw std::runtime_error("Password hashing failed — out of memory");
    }

    return std::string(hashBuf);
}

bool PasswordHasher::verify(const std::string& password, const std::string& storedHash) {
    ensureInit();

    return crypto_pwhash_str_verify(
               storedHash.c_str(),
               password.data(),
               static_cast<unsigned long long>(password.size())) == 0;
}

bool PasswordHasher::needsRehash(const std::string& storedHash) {
    ensureInit();
    return crypto_pwhash_str_needs_rehash(storedHash.c_str(), k_opsLimit, k_memLimit) == 1;
}

} // namespace Librarian