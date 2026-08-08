#include "crypto.h"

#include <openssl/evp.h>
#include <openssl/hmac.h>
#include <openssl/rand.h>
#include <openssl/sha.h>

#include <cstring>
#include <stdexcept>

namespace shelfsight {

namespace {

constexpr char kSalt[] =
    "N7s97s&Tnpf9&(*)697pbDF&P9bSFO*&9t7nos7notfs*O89ST(fs7g&r9sd53Y#@3sTg0";

std::string to_hex(const unsigned char* data, size_t len) {
    static const char kDigits[] = "0123456789abcdef";
    std::string out;
    out.reserve(len * 2);
    for (size_t i = 0; i < len; ++i) {
        out.push_back(kDigits[data[i] >> 4]);
        out.push_back(kDigits[data[i] & 0x0f]);
    }
    return out;
}

std::string hmac_sha256_hex(const std::string& key, const std::string& data) {
    unsigned char digest[SHA256_DIGEST_LENGTH];
    unsigned int len = 0;
    HMAC(EVP_sha256(), key.data(), static_cast<int>(key.size()),
         reinterpret_cast<const unsigned char*>(data.data()), data.size(),
         digest, &len);
    return to_hex(digest, len);
}

} // namespace

std::string sha256_hex(const std::string& input) {
    unsigned char digest[SHA256_DIGEST_LENGTH];
    SHA256(reinterpret_cast<const unsigned char*>(input.data()), input.size(), digest);
    return to_hex(digest, SHA256_DIGEST_LENGTH);
}

std::string credential_hash(const std::string& username, const std::string& password, int role) {
    const std::string payload = username + "," + password + "," + std::to_string(role);
    return hmac_sha256_hex(kSalt, payload);
}

std::vector<unsigned char> random_bytes(size_t n) {
    std::vector<unsigned char> out(n);
    if (RAND_bytes(out.data(), static_cast<int>(n)) != 1) {
        throw std::runtime_error("RAND_bytes failed");
    }
    return out;
}

std::string aes256_encrypt(const std::string& plaintext, const std::vector<unsigned char>& key,
                           const std::vector<unsigned char>& iv) {
    if (key.size() != 32 || iv.size() != 16) {
        throw std::runtime_error("AES-256-CBC requires a 32-byte key and 16-byte IV");
    }

    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx) throw std::runtime_error("EVP_CIPHER_CTX_new failed");

    std::string ciphertext;
    int out_len = 0;
    int total = 0;

    try {
        if (EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), nullptr, key.data(), iv.data()) != 1) {
            throw std::runtime_error("EVP_EncryptInit_ex failed");
        }
        ciphertext.resize(plaintext.size() + EVP_CIPHER_block_size(EVP_aes_256_cbc()));
        if (EVP_EncryptUpdate(ctx, reinterpret_cast<unsigned char*>(&ciphertext[0]), &out_len,
                              reinterpret_cast<const unsigned char*>(plaintext.data()),
                              static_cast<int>(plaintext.size())) != 1) {
            throw std::runtime_error("EVP_EncryptUpdate failed");
        }
        total = out_len;
        if (EVP_EncryptFinal_ex(ctx, reinterpret_cast<unsigned char*>(&ciphertext[total]),
                                &out_len) != 1) {
            throw std::runtime_error("EVP_EncryptFinal_ex failed");
        }
        total += out_len;
        ciphertext.resize(total);
    } catch (...) {
        EVP_CIPHER_CTX_free(ctx);
        throw;
    }
    EVP_CIPHER_CTX_free(ctx);
    return ciphertext;
}

std::string aes256_decrypt(const std::string& ciphertext, const std::vector<unsigned char>& key,
                           const std::vector<unsigned char>& iv) {
    if (key.size() != 32 || iv.size() != 16) {
        throw std::runtime_error("AES-256-CBC requires a 32-byte key and 16-byte IV");
    }

    EVP_CIPHER_CTX* ctx = EVP_CIPHER_CTX_new();
    if (!ctx) throw std::runtime_error("EVP_CIPHER_CTX_new failed");

    std::string plaintext;
    int out_len = 0;
    int total = 0;

    try {
        if (EVP_DecryptInit_ex(ctx, EVP_aes_256_cbc(), nullptr, key.data(), iv.data()) != 1) {
            throw std::runtime_error("EVP_DecryptInit_ex failed");
        }
        plaintext.resize(ciphertext.size());
        if (EVP_DecryptUpdate(ctx, reinterpret_cast<unsigned char*>(&plaintext[0]), &out_len,
                              reinterpret_cast<const unsigned char*>(ciphertext.data()),
                              static_cast<int>(ciphertext.size())) != 1) {
            throw std::runtime_error("EVP_DecryptUpdate failed");
        }
        total = out_len;
        if (EVP_DecryptFinal_ex(ctx, reinterpret_cast<unsigned char*>(&plaintext[total]),
                                &out_len) != 1) {
            throw std::runtime_error("EVP_DecryptFinal_ex failed (bad padding or key)");
        }
        total += out_len;
        plaintext.resize(total);
    } catch (...) {
        EVP_CIPHER_CTX_free(ctx);
        throw;
    }
    EVP_CIPHER_CTX_free(ctx);
    return plaintext;
}

} // namespace shelfsight