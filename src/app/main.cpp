#include "mainwindow.h"
#include "sqlite_dataaccess.h"
#include <QApplication>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    auto& db = DataAccess::SQLiteDataAccess::instance();
    MainWindow w(db);
    w.show();
    return QApplication::exec();
}
