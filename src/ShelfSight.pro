TEMPLATE = subdirs

CONFIG += ordered

SUBDIRS = \
    sqlitecpp \
    app

app.depends = sqlitecpp