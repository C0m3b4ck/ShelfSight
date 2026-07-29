#pragma once

#include <string>
#include <vector>

std::vector<uint8_t> aes256_encrypt(const std::vector<uint8_t>& plain,
                                    const std::vector<uint8_t>& key,
                                    const std::vector<uint8_t>& iv);
std::vector<uint8_t> aes256_decrypt(const std::vector<uint8_t>& cipher,
                                    const std::vector<uint8_t>& key,
                                    const std::vector<uint8_t>& iv);
std::string sha256_hex(const std::string& input);
std::vector<uint8_t> sha256_bytes(const std::string& input);
