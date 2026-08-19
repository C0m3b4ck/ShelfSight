#include "mainwindow.h"
#include "services.h"
#include "sqlite_dataaccess.h"
#include <QApplication>
#include <memory>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    // Initialize data access layer
    auto dataAccess = std::make_shared<DataAccess::SQLiteDataAccess>();
    try {
        dataAccess->initialize("books.db", "readers.db", "loans.db");
    } catch (const std::exception& e) {
        // Continue without database for now
    }

    // Initialize services
    auto bookService = std::make_unique<BusinessLogic::BookService>(dataAccess);
    auto readerService = std::make_unique<BusinessLogic::ReaderService>(dataAccess);
    auto categoryService = std::make_unique<BusinessLogic::CategoryService>(dataAccess);
    auto locationService = std::make_unique<BusinessLogic::LocationService>(dataAccess);
    auto loanService = std::make_unique<BusinessLogic::LoanService>(dataAccess);
    auto userService = std::make_unique<BusinessLogic::UserService>(dataAccess);
    auto undoService = std::make_unique<BusinessLogic::UndoService>();
    auto dbManager = std::make_unique<BusinessLogic::DatabaseManager>(dataAccess);

    // Wire up BusinessLogicFacade
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    facade.db = std::move(dbManager);
    facade.books = std::move(bookService);
    facade.readers = std::move(readerService);
    facade.categories = std::move(categoryService);
    facade.locations = std::move(locationService);
    facade.loans = std::move(loanService);
    facade.users = std::move(userService);
    facade.undo = std::move(undoService);

    MainWindow w;
    w.show();
    return QApplication::exec();
}
