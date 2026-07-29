#define AES256 1
#include "aes.h"

#include <cstring>
#include <iomanip>
#include <sstream>
#include <vector>

#include "picosha2.hpp"

std::vector<uint8_t> aes256_encrypt(const std::vector<uint8_t>& plain,
                                    const std::vector<uint8_t>& key,
                                    const std::vector<uint8_t>& iv)
{
    AES_ctx ctx;
    AES_init_ctx_iv(&ctx, key.data(), iv.data());

    std::vector<uint8_t> buf = plain;
    size_t pad = AES_BLOCKLEN - (buf.size() % AES_BLOCKLEN);
    buf.insert(buf.end(), pad, static_cast<uint8_t>(pad));

    AES_CBC_encrypt_buffer(&ctx, buf.data(), buf.size());
    return buf;
}

std::vector<uint8_t> aes256_decrypt(const std::vector<uint8_t>& cipher,
                                    const std::vector<uint8_t>& key,
                                    const std::vector<uint8_t>& iv)
{
    AES_ctx ctx;
    AES_init_ctx_iv(&ctx, key.data(), iv.data());

    std::vector<uint8_t> buf = cipher;
    AES_CBC_decrypt_buffer(&ctx, buf.data(), buf.size());

    uint8_t pad = buf.back();
    if (pad > 0 && pad <= AES_BLOCKLEN)
        buf.resize(buf.size() - pad);

    return buf;
}

std::string sha256_hex(const std::string& input)
{
    return picosha2::hash256_hex_string(input);
}

std::vector<uint8_t> sha256_bytes(const std::string& input)
{
    std::vector<uint8_t> hash(32);
    picosha2::hash256(input.begin(), input.end(), hash.begin(), hash.end());
    return hash;
}
