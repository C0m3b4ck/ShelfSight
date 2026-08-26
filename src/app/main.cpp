#include "mainwindow.h"
#include "sqlite_dataaccess.h"
#include "logger.h"
#include <QApplication>
#include <QDateTime>
#include <cstdlib>

static void cleanupLogger() {
    AppLogger::instance().close();
}

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    std::atexit(cleanupLogger);
    QObject::connect(&a, &QCoreApplication::aboutToQuit, &cleanupLogger);

    if (a.arguments().contains("--telemetry")) {
        QString logPath = QCoreApplication::applicationDirPath() + "/telemetry_"
            + QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss") + ".log";
        AppLogger::instance().setTelemetryEnabled(true);
        AppLogger::instance().setLogFile(logPath);
        qDebug() << "[TELEMETRY] Enabled via CLI flag, log:" << logPath;
    }

    auto& db = DataAccess::SQLiteDataAccess::instance();
    MainWindow w(db);
    w.show();
    return QApplication::exec();
}
