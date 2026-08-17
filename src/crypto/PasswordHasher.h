#pragma once
/**
 * PasswordHasher.h — Secure password storage using Argon2id.
 *
 * Tutorial note — why Argon2id?
 *   Password hashing is different from general cryptographic hashing (SHA-256
 *   etc.).  The goal is to make brute-force attacks slow and memory-intensive
 *   even for an attacker with specialised hardware (GPUs, ASICs).
 *
 *   Argon2id is the winner of the Password Hashing Competition (2015) and is
 *   the current OWASP recommendation.  It is "memory-hard": the attacker must
 *   allocate a large amount of RAM per hash attempt, which limits parallelism.
 *
 *   libsodium wraps Argon2id behind a convenient API:
 *     • crypto_pwhash_str()        — hash a password
 *     • crypto_pwhash_str_verify() — verify a password against a stored hash
 *     • crypto_pwhash_str_needs_rehash() — check if parameters are outdated
 *
 * Tutorial note — parameters (OPSLIMIT / MEMLIMIT):
 *   OPSLIMIT_INTERACTIVE and MEMLIMIT_INTERACTIVE are libsodium's recommended
 *   values for user-facing login flows (≈ 64 MB RAM, ≈ 0.5 s on modern HW).
 *   If you upgrade to SENSITIVE values in the future, needsRehash() detects
 *   old hashes so they can be transparently re-hashed on the next login.
 *
 * Tutorial note — the stored string format:
 *   crypto_pwhash_str() returns a self-describing ASCII string like:
 *     $argon2id$v=19$m=65536,t=2,p=1$<salt>$<hash>
 *   It encodes the algorithm, version, parameters, salt, and hash all in one
 *   string — safe to store directly in the database TEXT column.
 */
#include <QString>

namespace Librarian {

class PasswordHasher {
public:
    PasswordHasher() = delete; // purely static utility — no instances needed

    /**
     * Hashes @p password with Argon2id and a freshly-generated random salt.
     * Returns the self-describing hash string suitable for DB storage.
     * Throws std::runtime_error if libsodium cannot allocate enough memory.
     */
    static QString hash(const QString& password);

    /**
     * Returns true if @p password matches @p storedHash.
     * Constant-time comparison — safe against timing side-channels.
     */
    static bool verify(const QString& password, const QString& storedHash);

    /**
     * Returns true when @p storedHash was created with weaker parameters
     * than the current OPSLIMIT / MEMLIMIT.
     *
     * Use this after a successful login to rehash transparently:
     *   if (PasswordHasher::needsRehash(user.passwordHash))
     *       repo.updatePasswordHash(user.id, PasswordHasher::hash(plaintext));
     */
    static bool needsRehash(const QString& storedHash);
};

} // namespace Librarian
