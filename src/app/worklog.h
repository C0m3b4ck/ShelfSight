#ifndef WORKLOG_H
#define WORKLOG_H

#include <QString>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QDir>
#include <vector>
#include <mutex>

struct WorklogEntry {
    enum class ActionType { Add, Edit, Remove };
    enum class EntityType { Book, Reader, Loan };

    ActionType action;
    EntityType entity;
    std::string entityId;
    std::string description;
    std::string timestamp;

    QString actionStr() const {
        switch (action) {
            case ActionType::Add: return "ADD";
            case ActionType::Edit: return "EDIT";
            case ActionType::Remove: return "REMOVE";
        }
        return "UNKNOWN";
    }

    QString entityStr() const {
        switch (entity) {
            case EntityType::Book: return "BOOK";
            case EntityType::Reader: return "READER";
            case EntityType::Loan: return "LOAN";
        }
        return "UNKNOWN";
    }

    QString toLogString() const {
        return QString("[%1] [%2] [%3] ID:%4 %5")
            .arg(QString::fromStdString(timestamp))
            .arg(actionStr())
            .arg(entityStr())
            .arg(QString::fromStdString(entityId))
            .arg(QString::fromStdString(description));
    }
};

class Worklog {
public:
    Worklog() = default;

    void setEnabled(bool enabled) { m_enabled = enabled; }
    bool isEnabled() const { return m_enabled; }

    void setLogFile(const QString& path) {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (m_file && m_file->isOpen()) {
            m_file->close();
        }
        m_file = std::make_unique<QFile>(path);
        if (m_file->open(QIODevice::Append | QIODevice::Text)) {
            m_stream = std::make_unique<QTextStream>(m_file.get());
            *m_stream << "=== Worklog Session Started: "
                      << QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss") << " ===\n";
            m_stream->flush();
        }
    }

    void logEntry(WorklogEntry::ActionType action, WorklogEntry::EntityType entity,
                  const std::string& entityId, const std::string& description) {
        std::lock_guard<std::mutex> lock(m_mutex);
        WorklogEntry entry;
        entry.action = action;
        entry.entity = entity;
        entry.entityId = entityId;
        entry.description = description;
        entry.timestamp = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss.zzz").toStdString();

        m_entries.push_back(entry);

        if (m_enabled && m_stream) {
            *m_stream << entry.toLogString() << "\n";
            m_stream->flush();
        }
    }

    const std::vector<WorklogEntry>& getEntries() const { return m_entries; }

    int getBookAddCount() const { return countBy(WorklogEntry::ActionType::Add, WorklogEntry::EntityType::Book); }
    int getBookEditCount() const { return countBy(WorklogEntry::ActionType::Edit, WorklogEntry::EntityType::Book); }
    int getBookRemoveCount() const { return countBy(WorklogEntry::ActionType::Remove, WorklogEntry::EntityType::Book); }

    int getReaderAddCount() const { return countBy(WorklogEntry::ActionType::Add, WorklogEntry::EntityType::Reader); }
    int getReaderEditCount() const { return countBy(WorklogEntry::ActionType::Edit, WorklogEntry::EntityType::Reader); }
    int getReaderRemoveCount() const { return countBy(WorklogEntry::ActionType::Remove, WorklogEntry::EntityType::Reader); }

    int getLoanAddCount() const { return countBy(WorklogEntry::ActionType::Add, WorklogEntry::EntityType::Loan); }
    int getLoanEditCount() const { return countBy(WorklogEntry::ActionType::Edit, WorklogEntry::EntityType::Loan); }
    int getLoanRemoveCount() const { return countBy(WorklogEntry::ActionType::Remove, WorklogEntry::EntityType::Loan); }

    void close() {
        std::lock_guard<std::mutex> lock(m_mutex);
        if (m_stream) {
            *m_stream << "=== Worklog Session Ended: "
                      << QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss") << " ===\n";
            m_stream->flush();
            m_stream.reset();
        }
        if (m_file && m_file->isOpen()) {
            m_file->close();
        }
        m_file.reset();
    }

    static QString generateSessionFileName() {
        return "worklog_" + QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss") + ".log";
    }

private:
    int countBy(WorklogEntry::ActionType action, WorklogEntry::EntityType entity) const {
        int count = 0;
        for (const auto& e : m_entries) {
            if (e.action == action && e.entity == entity) ++count;
        }
        return count;
    }

    bool m_enabled = false;
    std::vector<WorklogEntry> m_entries;
    std::unique_ptr<QFile> m_file;
    std::unique_ptr<QTextStream> m_stream;
    std::mutex m_mutex;
};

#endif // WORKLOG_H
