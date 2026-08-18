#include <sodium.h>
#include <stdio.h>
#include <string.h>
#include <string>

bool load_libsodium() // for initializing the library
{
    if (sodium_init() < 0) {
        /* panic! the library couldn't be initialized */
        return false;
    }
    return true; //upon no failure
}

std::string hash_string(std::string string_to_hash)
{
    char hashed_string[crypto_pwhash_argon2id_STRBYTES];

    /* Hash the string using Argon2id (explicitly) */
    if (crypto_pwhash_str_alg(
            hashed_string,
            string_to_hash.c_str(), string_to_hash.size(),
            crypto_pwhash_argon2id_OPSLIMIT_INTERACTIVE,
            crypto_pwhash_argon2id_MEMLIMIT_INTERACTIVE,
            crypto_pwhash_ALG_ARGON2ID13) != 0) {
        /* out of memory */
        return "";
    }

    return hashed_string;
}