#include <SQLiteCpp/SQLiteCpp.h>
#include <string>

bool does_id_exist(const std::string& db_name, const std::string& id)
try
{
    SQLite::Database db(db_name);
    SQLite::Statement query(db, "SELECT * FROM my_table WHERE ID = @id");
    query.bind("@id", id);
    bool found = query.executeStep();
    return found;
}
catch (std::exception& e)
{
    // MAKE THE APP RETURN A VISUAL EXCEPITON USING A QMESSAGEBOX::CRITICAL
    return false;
}