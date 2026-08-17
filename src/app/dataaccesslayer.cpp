#include <SQLiteCpp/SQLiteCpp.h>
#include <QString>

#include <iostream>

bool does_id_exist(const std::string& db_name, const QString& id)
try
{
    // Open database file
    SQLite::Database db(db_name);

    // Compile a SQL query with one named parameter
    SQLite::Statement query(db, "SELECT * FROM my_table WHERE ID = @id");

    // Bind the id value to the named parameter "@id"
    query.bind("@id", id.toStdString());

    // executeStep() returns true if a row was found, false if none (EOF)
    bool found = query.executeStep();

    return found;
}
catch (std::exception& e)
{
    std::cout << "exception: " << e.what() << "\n";
    return false;
}