#pragma once
#include "core/models/Rental.h"
#include <QObject>
#include <QFuture>
#include <QList>
#include <QDateTime>
#include <optional>

namespace Librarian {

class RentalService : public QObject {
    Q_OBJECT
public:
    explicit RentalService(QObject* parent = nullptr);

    QFuture<QList<RentalView>> getAll();
    QFuture<QList<RentalView>> getActive();
    QFuture<QList<RentalView>> getOverdue();
    QFuture<QList<RentalView>> getReturned();          ///< Successfully returned rentals.
    QFuture<QList<RentalView>> getHistoryForBook(qint64 bookId);

    // Creates a new rental.  Returns nullopt if book has an active rental.
    QFuture<std::optional<Rental>> rentBook(qint64 userId,
                                            qint64 bookId,
                                            const QDateTime& dueDate);

    QFuture<bool> returnBook(qint64 rentalId);
    QFuture<bool> markLost(qint64 rentalId);
    QFuture<bool> prolong(qint64 rentalId, const QDateTime& newDueDate);

signals:
    void changed();
};

} // namespace Librarian
