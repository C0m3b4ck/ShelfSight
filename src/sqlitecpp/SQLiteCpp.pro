TEMPLATE = lib
CONFIG += staticlib c++17
TARGET = SQLiteCpp

INCLUDEPATH += include
DEPENDPATH += include

HEADERS += \
    include/SQLiteCpp/SQLiteCpp.h \
    include/SQLiteCpp/Assertion.h \
    include/SQLiteCpp/Backup.h \
    include/SQLiteCpp/Column.h \
    include/SQLiteCpp/Database.h \
    include/SQLiteCpp/Exception.h \
    include/SQLiteCpp/Savepoint.h \
    include/SQLiteCpp/Statement.h \
    include/SQLiteCpp/Transaction.h \
    include/SQLiteCpp/VariadicBind.h \
    include/SQLiteCpp/ExecuteMany.h \
    include/SQLiteCpp/Utils.h \
    include/SQLiteCpp/SQLiteCppExport.h

SOURCES += \
    src/Backup.cpp \
    src/Column.cpp \
    src/Database.cpp \
    src/Exception.cpp \
    src/Savepoint.cpp \
    src/Statement.cpp \
    src/Transaction.cpp

# Include sqlite3
include(sqlite3/sqlite3.pri)

DEFINES += SQLITE_ENABLE_COLUMN_METADATA

unix:!macx {
    LIBS += -lpthread -ldl
    QMAKE_CXXFLAGS += -fPIC
}

# Install headers
target.path = $$OUT_PWD/../../lib
INSTALLS += target

headers.path = $$OUT_PWD/../../include/SQLiteCpp
headers.files = $$HEADERS
INSTALLS += headers