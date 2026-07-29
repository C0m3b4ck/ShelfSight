#include <iostream>
#include <fstream>
#include "main.h"

short find_string_in_file(const std::string & filename, std::string string_to_find) {
  std::ifstream file(filename); // Open file with given filename for reading
  std::string line; // Declare a string to store each line of text

  if (file.is_open()) { // Check if the file was successfully opened
    while (std::getline(file, line)) { // Read each line from the file
      if (line == string_to_find) // Display each line of the file
      {
        return 0;
      }
    }
    file.close(); // Close the file
  } else {
    std::cout << RED << "Failed to open the file " << filename << RST << "\n";
    return 1;
  }
  return 2;
}

short count_string_in_file(const std::string & filename, std::string string_to_find) {
  std::ifstream file(filename); // Open file with given filename for reading
  std::string line; // Declare a string to store each line of text
  long long counter = 0;

  if (file.is_open()) { // Check if the file was successfully opened
    while (std::getline(file, line)) { // Read each line from the file
      if (line == string_to_find) // Display each line of the file
      {
        counter++;
      }
    }
    file.close(); // Close the file
  } else {
    std::cout << RED << "Failed to open the file " << filename << RST << "\n";
    return -1;
  }
  return counter;
}

short load_categories_books()
{
    std::cout << CYN << "{{{ Loading book categories..." << RST << "\n";
}

short create_file(std::string name, std::string extention, std::string path)
{
    std::ofstream file;

    file.open(name + '.' + extention);

    if (!file.is_open())
    {
        std::cout << RED << "!!! Error in creating file " << name << "."
                  << extention << " !!!" << RST << "\n";
        return 1;
    }
    std::cout << GRN << ":) File created successfully: " << name << "."
              << extention << " :)" << RST << "\n";

    file.close();
    return 0;
}

short signup(std::string pwd_plain, std::string usr_plain, short role)
{
    std::cout << YLW << "Registering account..." << RST << "\n";
    std::ofstream myfile;
    myfile.open("CREDS.LGN");
    if (!myfile.is_open())
    {
        std::cout << RED << "!!! Error in opening file CREDS.LGN !!!" << RST << "\n";
        return 1;
    }
    // get salt if not present already
    // get hash (usr + pwd + role + salt)
    std::string hash_string = "";
    myfile << hash_string;
    myfile.close();
    return 0;
}

short login(std::string pwd_plain, std::string usr_plain, short role)
{
    std::cout << YLW << "Logging in..." << RST << "\n";
    // 1. make hash of all 3 + salt   
}