TEMPLATE = app
CONFIG += c++17
TARGET = ShelfSight

QT += widgets sql

INCLUDEPATH += ../sqlitecpp/include
DEPENDPATH += ../sqlitecpp/include

LIBS += -L$$OUT_PWD/../sqlitecpp -lSQLiteCpp -lsqlite3

SOURCES += \
    businesslogic.cpp \
    dataaccesslayer.cpp \
    main.cpp \
    mainwindow.cpp \
    sanitize_string.cpp

HEADERS += \
    businesslogic.h \
    dataaccesslayer.h \
    domain.h \
    mainwindow.h

FORMS += \
    mainwindow.ui

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target