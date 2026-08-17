/**
 * PasswordHasher.cpp
 *
 * Tutorial note — sodium_init():
 *   libsodium requires a one-time initialisation before any of its functions
 *   are called.  We use a local static bool inside a lambda — the C++11
 *   "magic statics" guarantee that this runs exactly once, even if multiple
 *   threads call ensureInit() simultaneously.
 *
 * Tutorial note — why toLatin1() for the hash string?
 *   The Argon2id output from crypto_pwhash_str() is pure ASCII (the '$'-
 *   separated PHC format).  QByteArray::toLatin1() gives us a null-terminated
 *   byte array compatible with the C API without any encoding conversion.
 *   We use fromLatin1() on the way back to Qt for the same reason.
 *
 * Tutorial note — never roll your own crypto:
 *   This file intentionally delegates 100% of the cryptographic work to
 *   libsodium.  Implementing Argon2 (or any password hash) yourself is
 *   almost certain to introduce subtle vulnerabilities.  Always use a
 *   well-audited library.
 */
#include "security/PasswordHasher.h"
#include <sodium.h>
#include <stdexcept>

namespace Librarian {

namespace {

void ensureInit() {
    static const bool ok = [] {
        // sodium_init() returns 0 on success, 1 if already initialised, -1 on failure.
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

QString PasswordHasher::hash(const QString& password) {
    ensureInit();
    const auto pwd = password.toUtf8();

    // crypto_pwhash_STRBYTES is the maximum length of the output string
    // including the null terminator — always use this constant, not a
    // hardcoded size, so the code stays correct if libsodium changes.
    char hashBuf[crypto_pwhash_STRBYTES];

    if (crypto_pwhash_str_alg(
            hashBuf,
            pwd.constData(),
            static_cast<unsigned long long>(pwd.size()),
            k_opsLimit, k_memLimit, k_alg) != 0) {
        // This only fails if the system is critically out of memory.
        throw std::runtime_error("Password hashing failed — out of memory");
    }

    return QString::fromLatin1(hashBuf);
}

bool PasswordHasher::verify(const QString& password, const QString& storedHash) {
    ensureInit();
    const auto pwd  = password.toUtf8();
    const auto hash = storedHash.toLatin1();

    // crypto_pwhash_str_verify() uses a constant-time comparison internally —
    // it takes the same amount of time whether the password matches or not,
    // which prevents timing attacks that could leak information about the hash.
    return crypto_pwhash_str_verify(
               hash.constData(),
               pwd.constData(),
               static_cast<unsigned long long>(pwd.size())) == 0;
}

bool PasswordHasher::needsRehash(const QString& storedHash) {
    ensureInit();
    const auto hash = storedHash.toLatin1();
    // Returns 1 if the stored hash was made with weaker k_opsLimit/k_memLimit
    // than what we currently pass — safe to transparently upgrade on next login.
    return crypto_pwhash_str_needs_rehash(hash.constData(), k_opsLimit, k_memLimit) == 1;
}

} // namespace Librarian
