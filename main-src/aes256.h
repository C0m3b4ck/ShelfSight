#include "aes256.cpp"
#pragma once

static void validateKeyIv(const SecByteBlock& key, const SecByteBlock& iv);
std::string aes256_encrypt(const std::string& plaintext, const SecByteBlock& key, const SecByteBlock& iv);
std::string aes256_decrypt(const std::string& ciphertext, const SecByteBlock& key, const SecByteBlock& iv);

