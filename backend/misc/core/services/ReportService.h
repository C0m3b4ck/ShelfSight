#pragma once
#include "core/models/Rental.h"
#include <QObject>
#include <QFuture>
#include <QList>

namespace Librarian {

class ReportService : public QObject {
    Q_OBJECT
public:
    explicit ReportService(QObject* parent = nullptr);

    QFuture<QList<PopularBookReport>>   mostPopularBooks(int limit = 20);
    QFuture<QList<DelayedRentalReport>> longestDelays(int limit = 20);
    QFuture<QList<RentalView>>          currentlyOverdue();
};

} // namespace Librarian
