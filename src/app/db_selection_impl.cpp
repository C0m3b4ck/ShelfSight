// Database Selection Implementation

void MainWindow::on_actionDatabase_Selection_triggered()
{
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    // Load saved configurations
    loadDbConfigs();

    ui->workspaces->setCurrentIndex(16); // page_17 (Database Selection)
}

void MainWindow::loadDbConfigs()
{
    ui->cboDbConfigs->clear();
    ui->lstSavedConfigs->clear();

    // Load from QSettings
    QSettings settings("ShelfSight", "DatabaseConfigs");
    QStringList configs = settings.value("configs").toStringList();

    for (const QString& config : configs) {
        ui->cboDbConfigs->addItem(config);
        ui->lstSavedConfigs->addItem(config);
    }
}

void MainWindow::on_cboDbConfigs_currentIndexChanged(int index)
{
    if (index < 0) return;

    QString configName = ui->cboDbConfigs->itemText(index);
    QSettings settings("ShelfSight", "DatabaseConfigs");
    QString configKey = "config_" + configName;

    ui->txtBooksDb->setText(settings.value(configKey + "/books").toString());
    ui->txtReadersDb->setText(settings.value(configKey + "/readers").toString());
    ui->txtLoansDb->setText(settings.value(configKey + "/loans").toString());
}

void MainWindow::on_btnLoadDbConfig_clicked()
{
    int index = ui->cboDbConfigs->currentIndex();
    if (index < 0) {
        QMessageBox::critical(this, tr("NO CONFIG SELECTED"), tr("Please select a configuration to load"));
        return;
    }

    on_cboDbConfigs_currentIndexChanged(index);

    // Apply the configuration
    database_books = ui->txtBooksDb->text();
    database_readers = ui->txtReadersDb->text();
    database_loans = ui->txtLoansDb->text();

    // Initialize data access with new databases
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.db) {
        try {
            facade.db->initialize(database_books.toStdString(), database_readers.toStdString(), database_loans.toStdString());
            QMessageBox::information(this, tr("SUCCESS"), tr("Database configuration loaded successfully"));
        } catch (const std::exception& e) {
            QMessageBox::critical(this, tr("ERROR"), tr("Failed to initialize databases: %1").arg(e.what()));
        }
    }
}

void MainWindow::on_btnBrowseBooksDb_clicked()
{
    QString file = QFileDialog::getOpenFileName(this, tr("Select Books Database"), "", tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*)"));
    if (!file.isEmpty()) {
        ui->txtBooksDb->setText(file);
    }
}

void MainWindow::on_btnBrowseReadersDb_clicked()
{
    QString file = QFileDialog::getOpenFileName(this, tr("Select Readers Database"), "", tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*)"));
    if (!file.isEmpty()) {
        ui->txtReadersDb->setText(file);
    }
}

void MainWindow::on_btnBrowseLoansDb_clicked()
{
    QString file = QFileDialog::getOpenFileName(this, tr("Select Loans Database"), "", tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*)"));
    if (!file.isEmpty()) {
        ui->txtLoansDb->setText(file);
    }
}

void MainWindow::on_btnSaveAsDefault_clicked()
{
    QString booksDb = ui->txtBooksDb->text();
    QString readersDb = ui->txtReadersDb->text();
    QString loansDb = ui->txtLoansDb->text();

    if (booksDb.isEmpty() || readersDb.isEmpty() || loansDb.isEmpty()) {
        QMessageBox::critical(this, tr("MISSING PATHS"), tr("All database paths must be filled"));
        return;
    }

    // Save as default configuration
    QSettings settings("ShelfSight", "DatabaseConfigs");
    settings.setValue("default/books", booksDb);
    settings.setValue("default/readers", readersDb);
    settings.setValue("default/loans", loansDb);
    settings.setValue("default_is_valid", true);

    QMessageBox::information(this, tr("SUCCESS"), tr("Default configuration saved"));
}

void MainWindow::on_btnSaveCustomConfig_clicked()
{
    QString booksDb = ui->txtBooksDb->text();
    QString readersDb = ui->txtReadersDb->text();
    QString loansDb = ui->txtLoansDb->text();

    if (booksDb.isEmpty() || readersDb.isEmpty() || loansDb.isEmpty()) {
        QMessageBox::critical(this, tr("MISSING PATHS"), tr("All database paths must be filled"));
        return;
    }

    bool ok;
    QString configName = QInputDialog::getText(this, tr("Save Configuration"), tr("Configuration name:"), QLineEdit::Normal, "", &ok);
    if (!ok || configName.isEmpty()) return;

    QSettings settings("ShelfSight", "DatabaseConfigs");
    QString configKey = "config_" + configName;

    settings.setValue(configKey + "/books", booksDb);
    settings.setValue(configKey + "/readers", readersDb);
    settings.setValue(configKey + "/loans", loansDb);

    // Add to config list
    QStringList configs = settings.value("configs").toStringList();
    if (!configs.contains(configName)) {
        configs.append(configName);
        settings.setValue("configs", configs);
    }

    // Refresh UI
    loadDbConfigs();

    // Select the new config
    int index = ui->cboDbConfigs->findText(configName);
    if (index >= 0) {
        ui->cboDbConfigs->setCurrentIndex(index);
    }

    QMessageBox::information(this, tr("SUCCESS"), tr("Configuration saved as '%1'").arg(configName));
}

void MainWindow::on_btnTestConnection_clicked()
{
    QString booksDb = ui->txtBooksDb->text();
    QString readersDb = ui->txtReadersDb->text();
    QString loansDb = ui->txtLoansDb->text();

    if (booksDb.isEmpty() || readersDb.isEmpty() || loansDb.isEmpty()) {
        QMessageBox::critical(this, tr("MISSING PATHS"), tr("All database paths must be filled"));
        return;
    }

    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.db) {
        try {
            facade.db->initialize(booksDb.toStdString(), readersDb.toStdString(), loansDb.toStdString());
            if (facade.db->isConnected()) {
                QMessageBox::information(this, tr("SUCCESS"), tr("Connection test successful! All databases are accessible."));
            } else {
                QMessageBox::critical(this, tr("FAILED"), tr("Failed to connect to databases"));
            }
        } catch (const std::exception& e) {
            QMessageBox::critical(this, tr("ERROR"), tr("Connection failed: %1").arg(e.what()));
        }
    } else {
        QMessageBox::critical(this, tr("ERROR"), tr("Database manager not initialized"));
    }
}

void MainWindow::on_btnCreateNewDb_clicked()
{
    QString dir = QFileDialog::getExistingDirectory(this, tr("Select Directory for New Databases"));
    if (dir.isEmpty()) return;

    QString booksDb = dir + "/books.db";
    QString readersDb = dir + "/readers.db";
    QString loansDb = dir + "/loans.db";

    // Create new databases
    try {
        DataAccess::SQLiteDataAccess tempDb;
        tempDb.initialize(booksDb.toStdString(), readersDb.toStdString(), loansDb.toStdString());
        tempDb.shutdown();

        ui->txtBooksDb->setText(booksDb);
        ui->txtReadersDb->setText(readersDb);
        ui->txtLoansDb->setText(loansDb);

        QMessageBox::information(this, tr("SUCCESS"), tr("New databases created at:\n%1").arg(dir));
    } catch (const std::exception& e) {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to create databases: %1").arg(e.what()));
    }
}

void MainWindow::on_btnDeleteConfig_clicked()
{
    QListWidgetItem *item = ui->lstSavedConfigs->currentItem();
    if (!item) {
        QMessageBox::critical(this, tr("NO CONFIG SELECTED"), tr("Please select a configuration to delete"));
        return;
    }

    QString configName = item->text();
    if (configName == "default") {
        QMessageBox::critical(this, tr("CANNOT DELETE"), tr("Cannot delete the default configuration"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("DELETE CONFIGURATION"));
    box.setText(tr("Are you sure you want to delete configuration '%1'?").arg(configName));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        QString configKey = "config_" + configName;
        QSettings settings("ShelfSight", "DatabaseConfigs");

        settings.remove(configKey + "/books");
        settings.remove(configKey + "/readers");
        settings.remove(configKey + "/loans");

        QStringList configs = settings.value("configs").toStringList();
        configs.removeAll(configName);
        settings.setValue("configs", configs);

        loadDbConfigs();

        QMessageBox::information(this, tr("SUCCESS"), tr("Configuration '%1' deleted").arg(configName));
    }
}

void MainWindow::on_lstSavedConfigs_itemDoubleClicked(QListWidgetItem *item)
{
    QString configName = item->text();
    int index = ui->cboDbConfigs->findText(configName);
    if (index >= 0) {
        ui->cboDbConfigs->setCurrentIndex(index);
    }
}