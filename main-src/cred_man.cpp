//cred_man.cpp
#include <string>
#include <fstream>
#include <string>
#include <iostream>
//blake2.h for hashing
#include "blake2.h"
#include <cstddef> 
#include <array>
#include <cctype>

//HARDCODED - YOU CAN CHANGE IT FOR YOUR OWN SALT
const std::string SALT_CREDS = "N7s97s&Tnpf9&(*)697pbDF&P9bSFO*&9t7nos7notfs*O89ST(fs7g&r9sd53Y#@3sTg0";

std::byte keyBytes[32] = {    std::byte{0x00}, std::byte{0x01}, std::byte{0x02}, std::byte{0x03},    std::byte{0x04}, std::byte{0x05}, std::byte{0x06}, std::byte{0x07},    std::byte{0x08}, std::byte{0x09}, std::byte{0x0A}, std::byte{0x0B},    std::byte{0x0C}, std::byte{0x0D}, std::byte{0x0E}, std::byte{0x0F},    std::byte{0x10}, std::byte{0x11}, std::byte{0x12}, std::byte{0x13},    std::byte{0x14}, std::byte{0x15}, std::byte{0x16}, std::byte{0x17},    std::byte{0x18}, std::byte{0x19}, std::byte{0x1A}, std::byte{0x1B},    std::byte{0x1C}, std::byte{0x1D}, std::byte{0x1E}, std::byte{0x1F}};
std::byte ivBytes[16] = {    std::byte{0x0F}, std::byte{0x0E}, std::byte{0x0D}, std::byte{0x0C},    std::byte{0x0B}, std::byte{0x0A}, std::byte{0x09}, std::byte{0x08},    std::byte{0x07}, std::byte{0x06}, std::byte{0x05}, std::byte{0x04},    std::byte{0x03}, std::byte{0x02}, std::byte{0x01}, std::byte{0x00}};

// open login file
short open_login_file(char mode)
{
    try
    {
        if (mode == 'r')
        {
            std::fstream str("CRED.LGN", std::ios::in);
            if (!str.is_open()) return -1;           // open failed
            return 0;
        }
        else if (mode == 'f')
        {
            std::fstream str("CRED.LGN", std::ios::in | std::ios::out | std::ios::app);
            if (!str.is_open()) return -1;           // open failed
            return 0;
        }
        else
        {
        	std::cout << "Invalid mode provided! Programmer error! \n";
            return -2; // invalid mode
        }
    }
    catch (const std::ios_base::failure&)
    {
        std::cout << "Stream/IO exception! Check if program has permission to access the file! \n";
        return -3; // stream/IO exception
    }
    catch (...)
    {
        std::cout << "Unknown error! \n";
        return -4; // unknown error
    }
}

// write to login file
short write_login_file(char mode, const std::string& data)
{
	std::fstream str; 
	
    try
    {
        if (mode == 'a') // append
        {
            str.open("CRED.LGN", std::ios::app);
        }
        else
        {
            std::cout << "Invalid mode passed (programmer error) \n";
            return -1; // invalid mode
        }

        if (!str.is_open())
        {
            std::cout << "Failed to open filestream \n";
            return -2; // open failed
        }

        // optionally throw on bad writes
        // str.exceptions(std::ios::badbit | std::ios::failbit);

        str << data;
        if (!str.good())
        {
            std::cout << "Write failed \n";
            return -3; // write failed
        }

        str.close();
        return 0;
    }
    catch (const std::ios_base::failure&)
    {
        str.close();
        std::cout << "Stream/IO exception \n";
        return -4; // stream/IO exception
    }
    catch (...)
    {
        str.close();
        std::cout << "Unknown error caught \n";
        return -5; // unknown error
    }
}

// function for checking if string in file exists
bool file_contains_string(const std::string& searched_string, const std::string& filename)
{
    std::ifstream inp(filename);
    if (!inp.is_open())
    {
        std::cout << "Input has not been opened, function failed \n";
        return false;
    }

    std::string line;
    while (std::getline(inp, line))
    {
        if (line.find(searched_string) != std::string::npos)
        {
            std::cout << "Line found: " << line << " \n";
            return true;
        }
    }

    return false;
}


// function to trim unwanted spaces from a string
std::string trim(const std::string& str)
{
    size_t start = 0;
    while (start < str.size() && std::isspace(static_cast<unsigned char>(str[start])))
        start++;

    size_t end = str.size();
    while (end > start && std::isspace(static_cast<unsigned char>(str[end - 1])))
        end--;

    return str.substr(start, end - start);
}


// function that gets user input and: 1. gets hash 2. checks if it exists in CRED.LGN - if yes, 3. runs login() func
bool verify_login(std::string plaintext_password, std::string plaintext_username, short role)
{
    // trims strings from spaces etc
    plaintext_username = trim(plaintext_username);
    plaintext_password = trim(plaintext_password);

    // get hash
    std::string writeline = blake2s_hash(plaintext_username + "," + plaintext_password + "," + std::to_string(role) + "," + SALT_CREDS);

    // lookup in db
    bool rc = file_contains_string("CRED.LGN", writeline);
    if (!rc)
    {
        //returns user not found
        std::cout << "Line not found in file - user does not exist \n";
        return false;
    }
    else {
        //returns user found
        std::cout << "Line found in file - user exists! \n";
        // thanks to return change, login() is triggered in shelfsight_gui.cxx CBs
        return true;
    }
}

// writes credentials into db, returns value (CBs in shelfsight_gui.cxx then prompt for login etc)
short register_in_db(std::string credentials)
{
    if (credentials.empty())
    {
        std::cout << "Empty credentials! Cannot proceed! \n";
        return -1;
    }

    std::fstream str("CRED.LGN", std::ios::app);
    if (!str.is_open())
    {
        std::cout << "Filestream is not open! Function cannot proceed! \n";
        return -2;
    }

    str << credentials;
    if (!str.good())
    {
        std::cout << "Write failed \n";
        return -3;
    }

    str.close();
    std::cout << "Function ran succesfully! \n";
    return 0;
}


// function that 1. verifies if user is eligible for register (correct password, pwd not usr etc) - if yes 2. runs register_in_db() func
short verify_register(std::string plaintext_password1, std::string plaintext_password2, std::string plaintext_username, short role)
{
    if ((plaintext_password1.length() < 8) || (plaintext_password2.length() < 8))
    {
        std::cout << "Passwords too short! \n";
        return -1;
    }
    else if (plaintext_username.empty())
    {
        std::cout << "Empty username! \n";
        return -2;
    }
    else if (role == 0)
    {
        std::cout << "Incorrect role! \n";
        return -3;
    }

    std::cout << "Trimming strings! \n";
    plaintext_password1 = trim(plaintext_password1);
    plaintext_password2 = trim(plaintext_password2);
    plaintext_username = trim(plaintext_username);

    if (plaintext_password1 != plaintext_password2)
    {
        std::cout << "Passwords do not match! \n";
        return -4;
    }

    std::string writeline = blake2s_hash(plaintext_username + "," + plaintext_password1 + "," + std::to_string(role) + "," + SALT_CREDS);

    if (!file_contains_string(writeline, "CRED.LGN"))
    {
        std::cout << "User does not exists! Proceeding to register credentials in database... \n";
        short rc = register_in_db(writeline);
        if (rc != 0)
        {
            std::cout << "register_in_db failed with code " << rc << "\n";
            return -5;
        }

        std::cout << "Register succesful! \n";
        return 0;
    }
    else
    {
        std::cout << "User exists! Redirect user to login! \n";
        return -6;
    }
}

