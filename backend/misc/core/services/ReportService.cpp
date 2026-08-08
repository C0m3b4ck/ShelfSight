#include "core/services/ReportService.h"
#include "core/repositories/RentalRepository.h"
#include <QtConcurrent/QtConcurrent>

namespace Librarian {

ReportService::ReportService(QObject* parent) : QObject(parent) {}

QFuture<QList<PopularBookReport>> ReportService::mostPopularBooks(int limit) {
    return QtConcurrent::run([limit] { return RentalRepository{}.popularBooks(limit); });
}

QFuture<QList<DelayedRentalReport>> ReportService::longestDelays(int limit) {
    return QtConcurrent::run([limit] { return RentalRepository{}.longestDelays(limit); });
}

QFuture<QList<RentalView>> ReportService::currentlyOverdue() {
    return QtConcurrent::run([] { return RentalRepository{}.findOverdue(); });
}

} // namespace Librarian
