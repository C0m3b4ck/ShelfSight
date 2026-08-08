#pragma once
#include "database/DatabaseManager.h"
#include <QMetaType>
#include <QSqlDatabase>
#include <QVariant>
#include <QString>

namespace Librarian::detail {

inline QSqlDatabase db() {
    return DatabaseManager::instance().threadConnection();
}

/// Returns SQL NULL for an empty string, otherwise wraps @p s in a QVariant.
inline QVariant nullableString(const QString& s) {
    return s.isEmpty() ? QVariant(QMetaType(QMetaType::QString)) : QVariant(s);
}

} // namespace Librarian::detail
