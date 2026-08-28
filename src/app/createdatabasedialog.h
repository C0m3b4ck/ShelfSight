#ifndef CREATEDATABASEDIALOG_H
#define CREATEDATABASEDIALOG_H

#include <QDialog>

namespace Ui {
class CreateDatabaseDialog;
}

class CreateDatabaseDialog : public QDialog
{
    Q_OBJECT

public:
    explicit CreateDatabaseDialog(QWidget *parent = nullptr);
    ~CreateDatabaseDialog() override;

    QString dbName() const;
    QString dbType() const;
    QString directory() const;

    void setDefaultDirectory(const QString &dir);
    void setTypeFilter(const QStringList &types);

private slots:
    void on_btnBrowse_clicked();
    void on_cboType_currentIndexChanged(int index);
    void on_txtName_textChanged(const QString &text);

private:
    void updatePreview();
    Ui::CreateDatabaseDialog *ui;
};

#endif // CREATEDATABASEDIALOG_H
