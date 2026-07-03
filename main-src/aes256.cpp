#include <string>
#include <stdexcept>
#include <iostream>

// Crypto++ headers
#include <cryptopp/cryptlib.h>
#include <cryptopp/aes.h>
#include <cryptopp/modes.h>
#include <cryptopp/filters.h>
#include <cryptopp/osrng.h>

using namespace CryptoPP;

// Validate sizes (internal check)
static void validateKeyIv(const SecByteBlock& key, const SecByteBlock& iv) {
    if (key.size() != 32)
        throw std::runtime_error("AES-256 requires a 32-byte key");

    if (iv.size() != AES::BLOCKSIZE)
        throw std::runtime_error("AES CBC requires a 16-byte IV");
}

// ----------------------------------------
// Encrypt AES-256-CBC
// Returns ciphertext string OR empty string on failure
// ----------------------------------------
std::string aes256_encrypt(
    const std::string& plaintext,
    const SecByteBlock& key,
    const SecByteBlock& iv
) {
    try {
        validateKeyIv(key, iv);

        CBC_Mode<AES>::Encryption encryptor(key, key.size(), iv);

        std::string ciphertext;

        StringSource ss(
            plaintext,
            true,
            new StreamTransformationFilter(
                encryptor,
                new StringSink(ciphertext),
                StreamTransformationFilter::PKCS_PADDING
            )
        );

        return ciphertext;
    }
    catch (const CryptoPP::Exception& e) {
        std::cerr << "Crypto++ encryption error: " << e.what() << std::endl;
        return "";
    }
    catch (const std::exception& e) {
        std::cerr << "Encryption error: " << e.what() << std::endl;
        return "";
    }
}

// ----------------------------------------
// Decrypt AES-256-CBC
// Returns plaintext string OR empty string on failure
// ----------------------------------------
std::string aes256_decrypt(
    const std::string& ciphertext,
    const SecByteBlock& key,
    const SecByteBlock& iv
) {
    try {
        validateKeyIv(key, iv);

        CBC_Mode<AES>::Decryption decryptor(key, key.size(), iv);

        std::string plaintext;

        StringSource ss(
            ciphertext,
            true,
            new StreamTransformationFilter(
                decryptor,
                new StringSink(plaintext),
                StreamTransformationFilter::PKCS_PADDING
            )
        );

        return plaintext;
    }
    catch (const CryptoPP::Exception& e) {
        std::cerr << "Crypto++ decryption error: " << e.what() << std::endl;
        return "";
    }
    catch (const std::exception& e) {
        std::cerr << "Decryption error: " << e.what() << std::endl;
        return "";
    }
}

