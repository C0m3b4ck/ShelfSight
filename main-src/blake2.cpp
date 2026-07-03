// Required Crypto++ headers
#include <cryptopp/blake2.h>   // BLAKE2s implementation
#include <cryptopp/filters.h>  // HashFilter, HexEncoder
#include <cryptopp/hex.h>      // HexEncoder (also declared in filters.hpp)
//#include <cryptopp/streams.h>  // StringSource, StringSink

#include <string>

std::string blake2s_hash(const std::string& input)
{
    try {
        std::string hash, hex;

        CryptoPP::BLAKE2s blake;

        CryptoPP::StringSource ss(
            input,
            true,
            new CryptoPP::HashFilter(
                blake,
                new CryptoPP::StringSink(hash)
            )
        );

        CryptoPP::StringSource ss2(
            hash,
            true,
            new CryptoPP::HexEncoder(
                new CryptoPP::StringSink(hex),
                false               // no line breaks
            )
        );

        return hex;
    }
    catch (...) {
        return "";
    }
}

