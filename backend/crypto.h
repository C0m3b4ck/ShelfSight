#pragma once

#include <string>
#include <vector>

namespace shelfsight {

// SHA-256 hex digest of the input.
std::string sha256_hex(const std::string& input);

// HMAC-SHA256 hex digest used to derive a salted credential hash.
std::string credential_hash(const std::string& username, const std::string& password, int role);

// AES-256-CBC encryption/decryption.  key must be 32 bytes, iv 16 bytes.
std::string aes256_encrypt(const std::string& plaintext, const std::vector<unsigned char>& key,
                           const std::vector<unsigned char>& iv);
std::string aes256_decrypt(const std::string& ciphertext, const std::vector<unsigned char>& key,
                           const std::vector<unsigned char>& iv);

// Random bytes for key/IV generation.
std::vector<unsigned char> random_bytes(size_t n);

} // namespace shelfsight