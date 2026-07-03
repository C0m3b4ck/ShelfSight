#include <cryptopp/blake2.h>

std::string blake2s_hash(const std::string& input)
{
    try {
        std::string hash, hex;

        BLAKE2s blake;

        StringSource ss(
            input,
            true,
            new HashFilter(
                blake,
                new StringSink(hash)
            )
        );

        StringSource ss2(
            hash,
            true,
            new HexEncoder(
                new StringSink(hex),
                false
            )
        );

        return hex;
    }
    catch (...) {
        return "";
    }
}
