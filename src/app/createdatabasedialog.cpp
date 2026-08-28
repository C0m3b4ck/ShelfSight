#include "createdatabasedialog.h"
#include "ui_createdatabasedialog.h"
#include <QFileDialog>
#include <QDir>
#include <QMessageBox>

CreateDatabaseDialog::CreateDatabaseDialog(QWidget *parent)
    : QDialog(parent)
    , ui(new Ui::CreateDatabaseDialog)
{
    ui->setupUi(this);
    setWindowTitle(tr("Create Database"));
    setMinimumWidth(480);

    ui->cboType->addItem(tr("Books Database"), "books");
    ui->cboType->addItem(tr("Readers Database"), "readers");
    ui->cboType->addItem(tr("Loans Database"), "loans");

    ui->txtName->setText("books.db");
    ui->txtDirectory->setText(QCoreApplication::applicationDirPath());

    ui->lblPreview->setStyleSheet("color: gray; font-style: italic;");
    updatePreview();
}

CreateDatabaseDialog::~CreateDatabaseDialog()
{
    delete ui;
}

QString CreateDatabaseDialog::dbName() const
{
    return ui->txtName->text().trimmed();
}

QString CreateDatabaseDialog::dbType() const
{
    return ui->cboType->currentData().toString();
}

QString CreateDatabaseDialog::directory() const
{
    return ui->txtDirectory->text().trimmed();
}

void CreateDatabaseDialog::setDefaultDirectory(const QString &dir)
{
    ui->txtDirectory->setText(dir);
    updatePreview();
}

void CreateDatabaseDialog::setTypeFilter(const QStringList &types)
{
    ui->cboType->clear();
    for (const QString &type : types) {
        if (type.contains("book", Qt::CaseInsensitive))
            ui->cboType->addItem(tr("Books Database"), "books");
        else if (type.contains("reader", Qt::CaseInsensitive))
            ui->cboType->addItem(tr("Readers Database"), "readers");
        else if (type.contains("loan", Qt::CaseInsensitive))
            ui->cboType->addItem(tr("Loans Database"), "loans");
    }
}

void CreateDatabaseDialog::on_btnBrowse_clicked()
{
    QString dir = QFileDialog::getExistingDirectory(this, tr("Select Directory"), ui->txtDirectory->text());
    if (!dir.isEmpty()) {
        ui->txtDirectory->setText(dir);
        updatePreview();
    }
}

void CreateDatabaseDialog::on_cboType_currentIndexChanged(int index)
{
    Q_UNUSED(index);
    QString type = dbType();
    if (!type.isEmpty() && ui->txtName->text().isEmpty()) {
        ui->txtName->setText(type + ".db");
    }
    updatePreview();
}

void CreateDatabaseDialog::on_txtName_textChanged(const QString &text)
{
    Q_UNUSED(text);
    updatePreview();
}

void CreateDatabaseDialog::updatePreview()
{
    QString dir = ui->txtDirectory->text().trimmed();
    QString name = ui->txtName->text().trimmed();
    if (dir.isEmpty() || name.isEmpty()) {
        ui->lblPreview->setText(tr("Full path will be shown here"));
        return;
    }
    QString fullPath = dir + "/" + name;
    ui->lblPreview->setText(tr("Path: %1").arg(fullPath));
}
