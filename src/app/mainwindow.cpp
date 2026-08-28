#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "domain.h"
#include "businesslogic.h"

#include "crypto.h"
#include <QDebug>
#include <QMessageBox>
#include <QListWidget>
#include <QFileDialog>
#include <QInputDialog>
#include <QSettings>
#include <QRegularExpression>
#include <QCloseEvent>
#include <vector>
#include <random>
#include <chrono>
#include "logger.h"
#include <QTextStream>

// ============== MAGIC NUMBERS ================
////////////// FORM NUMBERS ////////////////
// 0 - register
// 1 - login
// 2 - backdrop
// 3 - add books
// 4 - edit books
// 5 - manage categories
// 6 - undo removed books
// 7 - remove books
// 8 - manage locations
// 9 - add readers
// 10 - edit readers
// 11 - remove readers
// 12 - add loans
// 13 - edit loans (change status)
// 14 - loan statuses (search loans)
// 15 - undo removed readers
// 16 - database selection
// 17 - make report
// 18 - manage fines
// 19 - make card
// 20 - backups
// 21 - preferences
// 22 - accounts
// 23 - troubleshoot
// =============== VARIABLES =====================
// ====== databases =======
QString database_books = "";
QString database_readers = "";
QString database_loans = "";
// ====== books - for undoing =====
DTO::BookDTO last_book_added;
DTO::BookDTO last_book_edited;
DTO::BookDTO last_book_removed;
DTO::BookDTO last_book_undone;
DTO::BookDTO book_selected;
std::vector<DTO::BookDTO> last_undoall_books;
// ====== readers - for undoing =====
DTO::ReaderDTO last_reader_added;
DTO::ReaderDTO last_reader_edited;
DTO::ReaderDTO last_reader_removed;
DTO::ReaderDTO last_reader_undone;
DTO::ReaderDTO reader_selected;
std::vector<DTO::ReaderDTO> last_undoall_readers;
// ====== categories - for undoing =====
DTO::CategoryDTO last_category_added;
DTO::CategoryDTO last_category_edited;
DTO::CategoryDTO last_category_removed;
DTO::CategoryDTO category_selected;
// ====== locations - for undoing =====
DTO::LocationDTO last_location_added;
DTO::LocationDTO last_location_edited;
DTO::LocationDTO last_location_removed;
DTO::LocationDTO location_selected;
// ======= loans - for undoing =====
DTO::LoanDTO last_loan_added;
DTO::LoanDTO last_loan_edited;
DTO::LoanDTO last_loan_removed;
DTO::LoanDTO last_loan_undone;
DTO::LoanDTO loan_selected;
std::vector<DTO::LoanDTO> last_undoall_loans;

// =============== PRE-DEFINITONS ===============
QString sanitize_string(QString stringValue);
bool is_qstring_empty(QString stringtocheck);

// Helper to check if BookDTO is empty
bool is_book_dto_empty(const DTO::BookDTO& book) {
    return book.title.empty() && book.author.empty() && book.id.empty();
}

// Helper to check if ReaderDTO is empty
bool is_reader_dto_empty(const DTO::ReaderDTO& reader) {
    return reader.name.empty() && reader.surname.empty() && reader.id.empty();
}

// Helper to check if CategoryDTO is empty
bool is_category_dto_empty(const DTO::CategoryDTO& cat) {
    return cat.name.empty();
}

// Helper to check if LocationDTO is empty
bool is_location_dto_empty(const DTO::LocationDTO& loc) {
    return loc.name.empty();
}

// Helper to check if LoanDTO is empty
bool is_loan_dto_empty(const DTO::LoanDTO& loan) {
    return loan.id.empty() && loan.bookId.empty() && loan.readerId.empty();
}

// Helper to convert QString to std::string
static inline std::string toStd(const QString& qstr) {
    return qstr.toStdString();
}

// Login verification
bool MainWindow::isLoggedIn() const {
    return m_isLoggedIn;
}

void MainWindow::setLoggedIn(bool loggedIn) {
    m_isLoggedIn = loggedIn;
}

bool MainWindow::checkLoginRequired(bool requireDatabases) {
    if (!m_isLoggedIn) {
        QMessageBox::warning(this, tr("LOGIN REQUIRED"), tr("Please log in to access this feature."));
        return false;
    }
    
    // Check if databases are selected (skip for database selection menu itself)
    if (requireDatabases && (database_books.isEmpty() || database_readers.isEmpty() || database_loans.isEmpty())) {
        QMessageBox::warning(this, tr("NO DATABASE SELECTED"), tr("Please select databases from the Database Selection menu."));
        return false;
    }
    return true;
}

bool MainWindow::checkRoleRequired(BusinessLogic::RequiredRole required, bool requireDatabases) {
    if (!checkLoginRequired(requireDatabases)) {
        return false;
    }
    if (!m_currentUser.has_value()) {
        QMessageBox::warning(this, tr("ACCESS DENIED"), tr("User session invalid. Please log in again."));
        return false;
    }
    auto result = BusinessLogic::checkUserRole(m_currentUser, required);
    if (!result.hasAccess) {
        QMessageBox::warning(this, tr("ACCESS DENIED"), QString::fromStdString(result.errorMessage));
        return false;
    }
    return true;
}

Domain::User::Role MainWindow::getCurrentUserRole() const {
    if (m_currentUser.has_value()) {
        return m_currentUser->role;
    }
    return Domain::User::Role::UserRole;
}

void MainWindow::setCurrentUser(const Domain::User& user) {
    m_currentUser = user;
    m_isLoggedIn = true;
}

void MainWindow::clearCurrentUser() {
    m_currentUser.reset();
    m_isLoggedIn = false;
}

// =============== MAIN WINDOW ===================
MainWindow::MainWindow(DataAccess::IDataAccess& db, QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
    , m_db(db)
{
    ui->setupUi(this);
    if (load_libsodium() == false)
    {
        QMessageBox::critical(this, tr("LIBSODIUM FAILED"), tr("The application cannot function correctly without cryptographic functions."));
    }

    // Load saved default config if available
    QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
    bool hasDefault = settings.value("default_is_valid", false).toBool();
    if (hasDefault) {
        QString configKey = "config_default";
        database_books = settings.value(configKey + "/books").toString();
        database_readers = settings.value(configKey + "/readers").toString();
        database_loans = settings.value(configKey + "/loans").toString();
        qDebug() << "[STARTUP] Loaded default config - books:" << database_books << "readers:" << database_readers << "loans:" << database_loans;
    } else {
        // No saved config — use binary's directory as default
        QString appDir = QCoreApplication::applicationDirPath();
        database_books = appDir + "/books.db";
        database_readers = appDir + "/readers.db";
        database_loans = appDir + "/loans.db";
        qDebug() << "[STARTUP] No saved config found, using app dir:" << appDir;
    }

    try {
        m_db.initialize(database_books.toStdString(), database_readers.toStdString(), database_loans.toStdString(), "users.db");
    } catch (const std::exception& e) {
        qDebug() << "[STARTUP] DB init failed:" << e.what();
    }

    // Initialize telemetry from settings
    {
        QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
        bool telemetryEnabled = settings.value("telemetry/enabled", false).toBool();
        ui->chkTelemetry->setChecked(telemetryEnabled);
        AppLogger::instance().setTelemetryEnabled(telemetryEnabled);
        if (telemetryEnabled) {
            QString logPath = QCoreApplication::applicationDirPath() + "/telemetry_"
                + QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss") + ".log";
            AppLogger::instance().setLogFile(logPath);
            ui->label_telemetry_path->setText("Log file: " + logPath);
            ui->label_telemetry_path->setStyleSheet("color: black;");
        }
    }

    // Initialize worklog from settings
    {
        QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
        bool worklogEnabled = settings.value("worklog/enabled", false).toBool();
        ui->chkWorklog->setChecked(worklogEnabled);
        m_worklog.setEnabled(worklogEnabled);
        if (worklogEnabled) {
            m_worklogFilePath = QCoreApplication::applicationDirPath() + "/" + Worklog::generateSessionFileName();
            m_worklog.setLogFile(m_worklogFilePath);
            ui->label_worklog_path->setText("Worklog file: " + m_worklogFilePath);
            ui->label_worklog_path->setStyleSheet("color: black;");
        }
    }

    set_to_backdrop();
}

MainWindow::~MainWindow()
{
    AppLogger::instance().close();
    delete ui;
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    m_worklog.close();
    AppLogger::instance().close();
    QMainWindow::closeEvent(event);
}
// =========== HELPERS ==========
void sanitize_variables() //clears variables (called by MainWindow and upon logging out/re-logging)
{
    // ====== books - for undoing =====
    last_book_added = DTO::BookDTO{};
    last_book_edited = DTO::BookDTO{};
    last_book_removed = DTO::BookDTO{};
    last_book_undone = DTO::BookDTO{};
    book_selected = DTO::BookDTO{};
    last_undoall_books.clear();
    // ====== readers - for undoing =====
    last_reader_added = DTO::ReaderDTO{};
    last_reader_edited = DTO::ReaderDTO{};
    last_reader_removed = DTO::ReaderDTO{};
    last_reader_undone = DTO::ReaderDTO{};
    reader_selected = DTO::ReaderDTO{};
    last_undoall_readers.clear();
    // ====== categories - for undoing =====
    last_category_added = DTO::CategoryDTO{};
    last_category_edited = DTO::CategoryDTO{};
    last_category_removed = DTO::CategoryDTO{};
    category_selected = DTO::CategoryDTO{};
    // ====== locations - for undoing =====
    last_location_added = DTO::LocationDTO{};
    last_location_edited = DTO::LocationDTO{};
    last_location_removed = DTO::LocationDTO{};
    location_selected = DTO::LocationDTO{};
    // ====== loans - for undoing =====
    last_loan_added = DTO::LoanDTO{};
    last_loan_edited = DTO::LoanDTO{};
    last_loan_removed = DTO::LoanDTO{};
    last_loan_undone = DTO::LoanDTO{};
    loan_selected = DTO::LoanDTO{};
    last_undoall_loans.clear();
}
// ============== CLEAR BUTTONS ==================
void MainWindow::on_btnClear_username_register_clicked()
{
    LOG_CLICK("btnClear_username_register_clicked");
    ui->txtUsr_register->setText("");
}


void MainWindow::on_btnClear_password1_register_clicked()
{
    LOG_CLICK("btnClear_password1_register_clicked");
    ui->txtPwd1_register->setText("");
}


void MainWindow::on_btnClear_password2_register_clicked()
{
    LOG_CLICK("btnClear_password2_register_clicked");
    ui->txtPassword2_register->setText("");
}

void MainWindow::on_btnClear_title_book_clicked()
{
    LOG_CLICK("btnClear_title_book_clicked");
    ui->txtTitle_book->setText("");
}

void MainWindow::on_btnClear_author_book_clicked()
{
    LOG_CLICK("btnClear_author_book_clicked");
    ui->txtAuthor_book->setText("");
}

void MainWindow::on_btnClear_id_book_clicked()
{
    LOG_CLICK("btnClear_id_book_clicked");
    ui->txtId_book->setText("");
}

void MainWindow::on_btnClear_title_book_edit_clicked()
{
    LOG_CLICK("btnClear_title_book_edit_clicked");
    ui->txtTitle_book_edit->setText("");
}


void MainWindow::on_btnClear_author_book_edit_clicked()
{
    LOG_CLICK("btnClear_author_book_edit_clicked");
    ui->txtAuthor_book_edit->setText("");
}


void MainWindow::on_btnClear_id_book_edit_clicked()
{
    LOG_CLICK("btnClear_id_book_edit_clicked");
    ui->txtId_book_edit->setText("");
}

void MainWindow::on_btnClear_name_category_clicked()
{
    LOG_CLICK("btnClear_name_category_clicked");
    ui->txtName_category->setText("");
}

void MainWindow::on_btnClear_name_location_clicked()
{
    LOG_CLICK("btnClear_name_location_clicked");
    ui->txtName_location->setText("");
}

void MainWindow::on_btnClear_name_addreaders_clicked()
{
    LOG_CLICK("btnClear_name_addreaders_clicked");
    ui->txtName_addreaders->setText("");
}

void MainWindow::on_btnClear_surname_addreaders_clicked()
{
    LOG_CLICK("btnClear_surname_addreaders_clicked");
    ui->txtSurname_addreaders->setText("");
}

void MainWindow::on_btnClear_grade_addreaders_clicked()
{
    LOG_CLICK("btnClear_grade_addreaders_clicked");
    ui->txtGrade_addreaders->setText("");
}

void MainWindow::on_btnClear_class_addreaders_clicked()
{
    LOG_CLICK("btnClear_class_addreaders_clicked");
    ui->txtClass_addreaders->setText("");
}

void MainWindow::on_btnClear_id_addreaders_clicked()
{
    LOG_CLICK("btnClear_id_addreaders_clicked");
    ui->txtID_addreaders->clear();
    ui->txtID_addreaders->setStyleSheet("");
    ui->txtID_addreaders->setToolTip("");
}

// =============== HELP BUTTONS =======================
void MainWindow::on_btnHelp_pwdStrenght_register_clicked()
{
    LOG_CLICK("btnHelp_pwdStrenght_register_clicked");
    QMessageBox::information(this, tr("Password Strength"),
    tr("Judges password strength based on:  \n * length, \n * characters used (numbers, letters, special), \n * capitalization, \n * whether the password is a set of words. \n The higher the password strength, the harder it is to guess or crack using specialized tools."));
}


void MainWindow::on_btnHelp_role_register_clicked()
{
    LOG_CLICK("btnHelp_role_register_clicked");
    QMessageBox::information(this, tr("User Roles"), tr("1. User \n Has the rights to manage books, readers and loans. Cannot access database and advanced settings. \n 2. Admin \n Has access to everything that User has access to plus database-related functions. \n 3. Superadmin \n The highest role, has access to all of the functions that Admin has and some critical functions, including salt modification and updating the app."));
}

void MainWindow::on_btnHelp_role_login_clicked()
{
    LOG_CLICK("btnHelp_role_login_clicked");
    QMessageBox::information(this, tr("User Roles"), tr("1. User \n Has the rights to manage books, readers and loans. Cannot access database and advanced settings. \n 2. Admin \n Has access to everything that User has access to plus database-related functions. \n 3. Superadmin \n The highest role, has access to all of the functions that Admin has and some critical functions, including salt modification and updating the app."));
}

// =============== SEARCH BUTTONS ============
// search edit books
void MainWindow::on_btnSearch_book_edit_clicked()
{
    LOG_CLICK("btnSearch_book_edit_clicked");
    QString search_term = ui->txtSearch_book_edit->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
        return;
    }

    if (database_books.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No book database selected"));
        return;
    }

    QString filter = search_term.toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_book_edit->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_book_edit->item(i);
        if (item->text().toLower().contains(filter))
        {
            item->setHidden(false);
            found = true;
        }
        else
        {
            item->setHidden(true);
        }
    }

    if (!found && ui->lstSearch_book_edit->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching books found"));
    }
}

// search manage categories
void MainWindow::on_btnSearch_category_clicked()
{
    LOG_CLICK("btnSearch_category_clicked");
    QString search_term = ui->txtSearch_category->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
        return;
    }

    QString filter = search_term.toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_category->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_category->item(i);
        if (item->text().toLower().contains(filter))
        {
            item->setHidden(false);
            found = true;
        }
        else
        {
            item->setHidden(true);
        }
    }

    if (!found && ui->lstSearch_category->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching categories found"));
    }
}










// menu action: navigate to remove readers page
void MainWindow::on_actionRemoveReaders_triggered()
{
    LOG_CLICK("actionRemoveReaders_triggered");
    if (!checkLoginRequired()) return;

    if (database_readers.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    ui->txtName_reader_remove->clear();
    ui->txtSurname_reader_remove->clear();
    ui->txtGrade_reader_remove->clear();
    ui->txtClass_reader_remove->clear();
    ui->txtId_reader_remove->clear();
    ui->txtSearch_reader_remove->clear();
    ui->lstSearch_reader_remove->clear();

    auto readers = m_db.getAllReaders();
    for (const auto& reader : readers) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(reader.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(reader.id));
        ui->lstSearch_reader_remove->addItem(listItem);
    }

    ui->workspaces->setCurrentIndex(8);
}

/////////////// HELPERS ////////////////
bool is_qstring_empty(QString stringtocheck)
{
    if (sanitize_string(stringtocheck).isEmpty())
    {
        return true;
    }
    else
    {
        return false;
    }
}

////////////////////////////// MENU BUTTONS //////////////////////////////////////////////
void MainWindow::on_actionLog_out_triggered()
{
    LOG_CLICK("actionLog_out_triggered");
    QMessageBox box(this);
    box.setIcon(QMessageBox::Question);
    box.setWindowTitle(tr("LOG OUT"));
    box.setText(tr("Are you sure you want to log out?"));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);
    if (box.exec() != QMessageBox::Yes) {
        return;
    }

    clearCurrentUser();
    sanitize_variables();
    QMessageBox::information(this, tr("LOGGED OUT"), tr("You have been logged out successfully."));
    set_to_backdrop();
}

void MainWindow::on_actionLog_in_triggered()
{
    LOG_CLICK("actionLog_in_triggered");
    // clear text fields
    ui->txtUsername_login->clear();
    ui->txtPassword_login->clear();
    // navigate to login workspace (magic numbers)
    ui->workspaces->setCurrentIndex(1);
}

void MainWindow::on_actionRegister_triggered()
{
    LOG_CLICK("actionRegister_triggered");
    // clear text fields
    ui->txtUsr_register->clear();
    ui->txtPwd1_register->clear();
    ui->txtPassword2_register->clear();
    ui->cboRole_register->setCurrentIndex(0);
    // navigate to register workspace (magic numbers)
    ui->workspaces->setCurrentIndex(0);
}

void MainWindow::on_actionAddBooks_triggered()
{
    LOG_CLICK("actionAddBooks_triggered");
    if (!checkLoginRequired()) return;

    // check if a DB is selected
    // -> if yes - navigate to add books
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add books
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // clear text fields
    ui->txtTitle_book->clear();
    ui->txtAuthor_book->clear();
    ui->txtId_book->clear();
    ui->txtId_book->setStyleSheet("");
    ui->txtId_book->setToolTip("");

    // populate category combo from DB
    ui->cboCategory_book->clear();
    auto catItems = BusinessLogic::populateList(m_db, "categories");
    for (const auto& item : catItems) {
        ui->cboCategory_book->addItem(QString::fromStdString(item.displayText));
    }

    // populate location combo from DB
    ui->cboLocation_book->clear();
    auto locItems = BusinessLogic::populateList(m_db, "locations");
    for (const auto& item : locItems) {
        ui->cboLocation_book->addItem(QString::fromStdString(item.displayText));
    }

    // status combo is pre-filled in UI (Available, Missing, Damaged, Borrowed, Banned)
    ui->cboStatus_book->setCurrentIndex(0);

    ui->workspaces->setCurrentIndex(3);
}

void MainWindow::on_actionEditBooks_triggered()
{
    LOG_CLICK("actionEditBooks_triggered");
    if (!checkLoginRequired()) return;

    ui->txtTitle_book_edit->clear();
    ui->txtAuthor_book_edit->clear();
    ui->txtId_book_edit->clear();
    ui->lstSearch_book_edit->clear();

    auto catItems = BusinessLogic::populateList(m_db, "categories");
    ui->cboCategory_book_edit->clear();
    for (const auto& item : catItems) {
        ui->cboCategory_book_edit->addItem(QString::fromStdString(item.displayText));
    }

    auto locItems = BusinessLogic::populateList(m_db, "locations");
    ui->cboLocation_book_edit->clear();
    for (const auto& item : locItems) {
        ui->cboLocation_book_edit->addItem(QString::fromStdString(item.displayText));
    }

    ui->cboStatus_book_edit->setCurrentIndex(0);

    auto books = m_db.getAllBooks();
    for (const auto& book : books) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(book.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(book.id));
        ui->lstSearch_book_edit->addItem(listItem);
    }

    ui->workspaces->setCurrentIndex(4);
}

void MainWindow::on_actionManage_Categories_triggered()
{
    LOG_CLICK("actionManage_Categories_triggered");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    ui->txtName_category->clear();
    ui->lstSearch_category->clear();

    auto items = BusinessLogic::populateList(m_db, "categories");
    for (const auto& item : items) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(item.displayText));
        listItem->setData(Qt::UserRole, QString::fromStdString(item.id));
        ui->lstSearch_category->addItem(listItem);
    }

    ui->workspaces->setCurrentIndex(5);
}

void MainWindow::on_actionRemoveBooks_triggered()
{
    LOG_CLICK("actionRemoveBooks_triggered");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    ui->txtSearch_book_remove->clear();
    ui->txtTitle_book_remove->clear();
    ui->txtAuthor_book_remove->clear();
    ui->txtId_book_remove->clear();
    ui->lstSearch_book_remove->clear();

    auto books = m_db.getAllBooks();
    for (const auto& book : books) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(book.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(book.id));
        ui->lstSearch_book_remove->addItem(listItem);
    }

    ui->workspaces->setCurrentIndex(7);
}

void MainWindow::on_actionUndo_Removed_triggered()
{
    LOG_CLICK("actionUndo_Removed_triggered");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    ui->txtSearch_undobooks->clear();
    ui->lstSearch_undobooks->clear();

    auto removedBooks = m_db.getRemovedBooks();
    for (const auto& book : removedBooks) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(book.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(book.id));
        ui->lstSearch_undobooks->addItem(listItem);
    }

    ui->workspaces->setCurrentIndex(6);
}

void MainWindow::on_actionUndo_Removed_2_triggered()
{
    LOG_CLICK("actionUndo_Removed_2_triggered");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    ui->txtSearch_undoreaders->clear();
    ui->lstSearch_undoreaders->clear();

    auto removedReaders = m_db.getRemovedReaders();
    for (const auto& reader : removedReaders) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(reader.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(reader.id));
        ui->lstSearch_undoreaders->addItem(listItem);
    }

    ui->workspaces->setCurrentIndex(15);
}

void MainWindow::on_actionManage_Locations_triggered()
{
    LOG_CLICK("actionManage_Locations_triggered");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    ui->txtName_location->clear();
    ui->lstSearch_location->clear();

    auto items = BusinessLogic::populateList(m_db, "locations");
    for (const auto& item : items) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(item.displayText));
        listItem->setData(Qt::UserRole, QString::fromStdString(item.id));
        ui->lstSearch_location->addItem(listItem);
    }

    ui->workspaces->setCurrentIndex(9);
}

void MainWindow::on_actionAddReaders_triggered()
{
    LOG_CLICK("actionAddReaders_triggered");
    if (!checkLoginRequired()) return;

    // check if a DB is selected
    // -> if yes - find its deleted books section
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add books
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // clear text fields
    // update listBox from deleted dbs (all results due to empty search term)
    ui->workspaces->setCurrentIndex(10);
}

void MainWindow::on_actionEditReaders_triggered()
{
    LOG_CLICK("actionEditReaders_triggered");
    if (!checkLoginRequired()) return;

    ui->txtName_reader_edit->clear();
    ui->txtSurname_reader_edit->clear();
    ui->txtGrade_reader_edit->clear();
    ui->txtClass_reader_edit->clear();
    ui->txtId_reader_edit->clear();
    ui->txtSearch_reader_edit->clear();
    ui->lstSearch_reader_edit->clear();

    auto readers = m_db.getAllReaders();
    for (const auto& reader : readers) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(reader.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(reader.id));
        ui->lstSearch_reader_edit->addItem(listItem);
    }

    ui->workspaces->setCurrentIndex(11);
}

void MainWindow::on_actionAddLoans_triggered()
{
    LOG_CLICK("actionAddLoans_triggered");
    if (!checkLoginRequired()) return;

    // check if DBs are selected via business logic
    {
        auto result = BusinessLogic::validateDatabases(m_db);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    // ==== BEFORE SHOWING ====
    // clear text fields
    ui->txtSearch_book->clear();
    ui->txtSearch_reader->clear();
    ui->txtSelected_book->clear();
    ui->txtSelected_reader->clear();
    ui->lstSearch_book->clear();
    ui->lstSearch_reader->clear();
    ui->spnLoanDays_loan->setValue(14);

    // populate book search filter combo
    ui->cboSearchField_book->clear();
    ui->cboSearchField_book->addItems({"title", "author", "location", "category", "status", "id"});

    // populate reader search filter combo
    ui->cboSearchField_reader->clear();
    ui->cboSearchField_reader->addItems({"name", "surname", "studentId", "id"});

    // book and reader selected DTOs
    book_selected = DTO::BookDTO{};
    reader_selected = DTO::ReaderDTO{};

    ui->workspaces->setCurrentIndex(12); // page_14 (Add Loan)
}

void MainWindow::on_actionEditLoans_triggered()
{
    LOG_CLICK("actionEditLoans_triggered");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    {
        auto result = BusinessLogic::validateDatabases(m_db);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    ui->txtSearch_loan->clear();
    ui->txtSelected_loan->clear();
    ui->txtDueDate_loan->clear();
    ui->txtReturnDate_loan->clear();
    ui->cboStatus_loan->setCurrentIndex(-1);
    ui->lstSearch_loan->clear();

    ui->cboSearchField_loan->clear();
    ui->cboSearchField_loan->addItems({"ID", "Book ID", "Reader ID", "Status"});

    auto loans = m_db.getAllLoans();
    for (const auto& loan : loans) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(loan.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(loan.id));
        ui->lstSearch_loan->addItem(listItem);
    }

    ui->workspaces->setCurrentIndex(13);
}

void MainWindow::on_actionSearchLoans_triggered()
{
    LOG_CLICK("actionSearchLoans_triggered");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    {
        auto result = BusinessLogic::validateDatabases(m_db);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    ui->txtSearch_loanstatus->clear();
    ui->cboStatusFilter_loanstatus->setCurrentIndex(0);
    ui->lstSearch_loanstatus->clear();

    auto allLoans = m_db.getActiveLoans();
    auto overdueLoans = m_db.getOverdueLoans();
    std::vector<Domain::Loan> loans;
    loans.insert(loans.end(), allLoans.begin(), allLoans.end());
    for (const auto& ol : overdueLoans) {
        bool found = false;
        for (const auto& l : loans) {
            if (l.id == ol.id) { found = true; break; }
        }
        if (!found) loans.push_back(ol);
    }

    for (const auto& loan : loans) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(loan.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(loan.id));
        ui->lstSearch_loanstatus->addItem(listItem);
    }

    ui->workspaces->setCurrentIndex(14);
}

void MainWindow::on_actionDatabase_Selection_triggered()
{
    LOG_CLICK("actionDatabase_Selection_triggered");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin, false)) return;

    // Load saved configurations
    loadDbConfigs();

    // Show current paths in the text fields
    ui->txtBooksDb->setText(database_books);
    ui->txtReadersDb->setText(database_readers);
    ui->txtLoansDb->setText(database_loans);

    // Select "default" in combo box if it exists
    int defaultIndex = ui->cboDbConfigs->findText("default");
    if (defaultIndex >= 0) {
        ui->cboDbConfigs->setCurrentIndex(defaultIndex);
    }

    ui->workspaces->setCurrentIndex(16); // page_17 (Database Selection)
}

void MainWindow::loadDbConfigs()
{
    ui->cboDbConfigs->clear();
    ui->lstSavedConfigs->clear();

    // Load from QSettings
    QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
    QStringList configs = settings.value("configs").toStringList();

    for (const QString& config : configs) {
        ui->cboDbConfigs->addItem(config);
        ui->lstSavedConfigs->addItem(config);
    }
}

void MainWindow::on_cboDbConfigs_currentIndexChanged(int index)
{
    LOG_CLICK("cboDbConfigs_currentIndexChanged");
    if (index < 0) return;

    QString configName = ui->cboDbConfigs->itemText(index);
    QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
    QString configKey = "config_" + configName;

    ui->txtBooksDb->setText(settings.value(configKey + "/books").toString());
    ui->txtReadersDb->setText(settings.value(configKey + "/readers").toString());
    ui->txtLoansDb->setText(settings.value(configKey + "/loans").toString());
}

void MainWindow::on_btnLoadDbConfig_clicked()
{
    LOG_CLICK("btnLoadDbConfig_clicked");
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
    try {
        m_db.initialize(database_books.toStdString(), database_readers.toStdString(),
                        database_loans.toStdString(), "users.db");
        QMessageBox::information(this, tr("SUCCESS"), tr("Database configuration loaded successfully"));
    } catch (const std::exception& e) {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to initialize databases: %1").arg(e.what()));
    }
}

void MainWindow::on_btnBrowseBooksDb_clicked()
{
    LOG_CLICK("btnBrowseBooksDb_clicked");
    QString file = QFileDialog::getOpenFileName(this, tr("Select Books Database"), "", tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*)"));
    if (!file.isEmpty()) {
        ui->txtBooksDb->setText(file);
        database_books = file;
    }
}

void MainWindow::on_btnBrowseReadersDb_clicked()
{
    LOG_CLICK("btnBrowseReadersDb_clicked");
    QString file = QFileDialog::getOpenFileName(this, tr("Select Readers Database"), "", tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*)"));
    if (!file.isEmpty()) {
        ui->txtReadersDb->setText(file);
        database_readers = file;
    }
}

void MainWindow::on_btnBrowseLoansDb_clicked()
{
    LOG_CLICK("btnBrowseLoansDb_clicked");
    QString file = QFileDialog::getOpenFileName(this, tr("Select Loans Database"), "", tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*)"));
    if (!file.isEmpty()) {
        ui->txtLoansDb->setText(file);
        database_loans = file;
    }
}

void MainWindow::on_btnSaveAsDefault_clicked()
{
    LOG_CLICK("btnSaveAsDefault_clicked");
    QString booksDb = ui->txtBooksDb->text();
    QString readersDb = ui->txtReadersDb->text();
    QString loansDb = ui->txtLoansDb->text();

    if (booksDb.isEmpty() || readersDb.isEmpty() || loansDb.isEmpty()) {
        QMessageBox::critical(this, tr("MISSING PATHS"), tr("All database paths must be filled"));
        return;
    }

    // Save as default configuration
    QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
    QString configKey = "config_default";
    settings.setValue(configKey + "/books", booksDb);
    settings.setValue(configKey + "/readers", readersDb);
    settings.setValue(configKey + "/loans", loansDb);
    settings.setValue("default_is_valid", true);

    // Add "default" to config list so it appears in the combo box
    QStringList configs = settings.value("configs").toStringList();
    if (!configs.contains("default")) {
        configs.append("default");
        settings.setValue("configs", configs);
    }

    // Refresh UI
    loadDbConfigs();

    // Select "default" in the combo box
    int index = ui->cboDbConfigs->findText("default");
    if (index >= 0) {
        ui->cboDbConfigs->setCurrentIndex(index);
    }

    QMessageBox::information(this, tr("SUCCESS"), tr("Default configuration saved"));
}

void MainWindow::on_btnSaveCustomConfig_clicked()
{
    LOG_CLICK("btnSaveCustomConfig_clicked");
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

    QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
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
    LOG_CLICK("btnTestConnection_clicked");
    QString booksDb = ui->txtBooksDb->text();
    QString readersDb = ui->txtReadersDb->text();
    QString loansDb = ui->txtLoansDb->text();

    if (booksDb.isEmpty() || readersDb.isEmpty() || loansDb.isEmpty()) {
        QMessageBox::critical(this, tr("MISSING PATHS"), tr("All database paths must be filled"));
        return;
    }

    // Derive users.db path from readers.db directory
    try {
        m_db.initialize(booksDb.toStdString(), readersDb.toStdString(), loansDb.toStdString(), "users.db");
        if (m_db.isConnected()) {
            QMessageBox::information(this, tr("SUCCESS"), tr("Connection test successful! All databases are accessible."));
        } else {
            QMessageBox::critical(this, tr("FAILED"), tr("Failed to connect to databases"));
        }
    } catch (const std::exception& e) {
        QMessageBox::critical(this, tr("ERROR"), tr("Connection failed: %1").arg(e.what()));
    }
}

void MainWindow::on_btnCreateNewDb_clicked()
{
    LOG_CLICK("btnCreateNewDb_clicked");

    QString appDir = QCoreApplication::applicationDirPath();

    // Pick which type of database to create
    QStringList types;
    types << tr("Books Database (books.db)")
          << tr("Readers Database (readers.db)")
          << tr("Loans Database (loans.db)");

    bool ok;
    QString picked = QInputDialog::getItem(this, tr("Create Database"),
        tr("Select database type to create in:\n%1").arg(appDir), types, 0, false, &ok);
    if (!ok || picked.isEmpty()) return;

    QString dbPath;
    QString dbLabel;
    if (picked.startsWith("Books")) {
        dbPath = appDir + "/books.db";
        dbLabel = "books.db";
    } else if (picked.startsWith("Readers")) {
        dbPath = appDir + "/readers.db";
        dbLabel = "readers.db";
    } else {
        dbPath = appDir + "/loans.db";
        dbLabel = "loans.db";
    }

    // Check if it already exists
    if (QFile::exists(dbPath)) {
        QMessageBox::warning(this, tr("EXISTS"),
            tr("%1 already exists at:\n%2\n\nCannot overwrite.").arg(dbLabel, dbPath));
        return;
    }

    try {
        m_db.shutdown();
        m_db.initialize(database_books.toStdString(), database_readers.toStdString(),
                        database_loans.toStdString(), "users.db");

        // Update the path for the newly created DB
        if (picked.startsWith("Books")) {
            database_books = dbPath;
            ui->txtBooksDb->setText(dbPath);
        } else if (picked.startsWith("Readers")) {
            database_readers = dbPath;
            ui->txtReadersDb->setText(dbPath);
        } else {
            database_loans = dbPath;
            ui->txtLoansDb->setText(dbPath);
        }

        QMessageBox::information(this, tr("SUCCESS"),
            tr("Created %1 at:\n%2").arg(dbLabel, dbPath));
    } catch (const std::exception& e) {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to create database: %1").arg(e.what()));
    }
}

void MainWindow::on_btnCreateStarterDbs_clicked()
{
    LOG_CLICK("btnCreateStarterDbs_clicked");

    QString appDir = QCoreApplication::applicationDirPath();
    QString booksPath = appDir + "/books.db";
    QString readersPath = appDir + "/readers.db";
    QString loansPath = appDir + "/loans.db";

    // Only create if none exist
    bool hasAny = QFile::exists(booksPath) || QFile::exists(readersPath) || QFile::exists(loansPath);
    if (hasAny) {
        QMessageBox::information(this, tr("DATABASES EXIST"),
            tr("At least one database already exists.\nUse 'Create Database' to add individual ones."));
        return;
    }

    try {
        m_db.shutdown();
        m_db.initialize(booksPath.toStdString(), readersPath.toStdString(),
                        loansPath.toStdString(), "");

        database_books = booksPath;
        database_readers = readersPath;
        database_loans = loansPath;

        ui->txtBooksDb->setText(booksPath);
        ui->txtReadersDb->setText(readersPath);
        ui->txtLoansDb->setText(loansPath);

        // Save as default configuration
        QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
        settings.setValue("config_default/books", booksPath);
        settings.setValue("config_default/readers", readersPath);
        settings.setValue("config_default/loans", loansPath);
        settings.setValue("default_is_valid", true);

        QStringList configs = settings.value("configs").toStringList();
        if (!configs.contains("default")) {
            configs.append("default");
            settings.setValue("configs", configs);
        }
        loadDbConfigs();

        QMessageBox::information(this, tr("SUCCESS"),
            tr("Starter databases created at:\n%1\n\nDefault configuration saved.").arg(appDir));
    } catch (const std::exception& e) {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to create databases: %1").arg(e.what()));
    }
}

void MainWindow::on_btnDeleteConfig_clicked()
{
    LOG_CLICK("btnDeleteConfig_clicked");
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
        QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);

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

void MainWindow::on_chkTelemetry_toggled(bool checked)
{
    LOG_CLICK("chkTelemetry_toggled");
    QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
    settings.setValue("telemetry/enabled", checked);
    AppLogger::instance().setTelemetryEnabled(checked);

    if (checked) {
        QString logPath = QCoreApplication::applicationDirPath() + "/telemetry_"
            + QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss") + ".log";
        AppLogger::instance().setLogFile(logPath);
        ui->label_telemetry_path->setText("Log file: " + logPath);
        ui->label_telemetry_path->setStyleSheet("color: black;");
        LOG_INFO("Telemetry enabled");
    } else {
        ui->label_telemetry_path->setText("Log file: (telemetry disabled)");
        ui->label_telemetry_path->setStyleSheet("color: gray;");
    }
}

void MainWindow::on_lstSavedConfigs_itemDoubleClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSavedConfigs_itemDoubleClicked");
    QString configName = item->text();
    int index = ui->cboDbConfigs->findText(configName);
    if (index >= 0) {
        ui->cboDbConfigs->setCurrentIndex(index);
    }
}

///// =========== HELPERS ============
void MainWindow::set_to_backdrop()
{
    // sets to backdrop (currently 2)
    ui->workspaces->setCurrentIndex(2);
}
////////////////////////////// FUNCTIONAL BUTTONS /////////////////////////////////////////
// ============================ ACCOUT MANAGEMENT ======================================================
void MainWindow::on_btnRegister_clicked()
{
    LOG_CLICK("btnRegister_clicked");

    QString username = ui->txtUsr_register->text().trimmed();
    QString password1 = ui->txtPwd1_register->text();
    QString password2 = ui->txtPassword2_register->text();

    qDebug() << "[REGISTER] username:" << username << "password1 len:" << password1.length() << "password2 len:" << password2.length();

    if (username.isEmpty() || password1.isEmpty() || password2.isEmpty()) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("All fields are required"));
        return;
    }

    if (password1 != password2) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Passwords do not match"));
        return;
    }

    // Check password strength
    {
        int score = 0;
        if (password1.length() >= 8) score += 20;
        if (password1.length() >= 12) score += 10;
        if (password1.length() >= 16) score += 10;
        if (password1.contains(QRegularExpression("[a-z]"))) score += 15;
        if (password1.contains(QRegularExpression("[A-Z]"))) score += 15;
        if (password1.contains(QRegularExpression("[0-9]"))) score += 15;
        if (password1.contains(QRegularExpression("[^a-zA-Z0-9]"))) score += 15;
        if (score > 100) score = 100;

        if (score < 30) {
            QMessageBox box(this);
            box.setIcon(QMessageBox::Warning);
            box.setWindowTitle(tr("WEAK PASSWORD"));
            box.setText(tr("Your password is very weak. Are you sure you want to continue?"));
            box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
            box.setDefaultButton(QMessageBox::No);
            if (box.exec() != QMessageBox::Yes) {
                return;
            }
        }
    }

    int roleIndex = ui->cboRole_register->currentIndex();
    if (roleIndex < 0) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Please select a role"));
        return;
    }

    Domain::User::Role role;
    switch (roleIndex) {
        case 0: role = Domain::User::Role::UserRole; break;
        case 1: role = Domain::User::Role::Admin; break;
        case 2: role = Domain::User::Role::SuperAdmin; break;
        default: role = Domain::User::Role::UserRole; break;
    }

    DTO::UserDTO userDTO;
    userDTO.username = toStd(username);
    userDTO.password = toStd(password1);
    userDTO.role = role;

    qDebug() << "[REGISTER] calling addUser... username:" << QString::fromStdString(userDTO.username) << "role:" << static_cast<int>(role);

    auto result = BusinessLogic::addUser(m_db, userDTO);
    qDebug() << "[REGISTER] addUser result:" << result.isValid << "error:" << QString::fromStdString(result.errorMessage);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("REGISTRATION FAILED"), QString::fromStdString(result.errorMessage));
        return;
    }

    // Auto-login after registration
    auto loginResult = BusinessLogic::login(m_db, userDTO.username, userDTO.password);
    if (loginResult.has_value()) {
        setCurrentUser(*loginResult);
        QMessageBox::information(this, tr("SUCCESS"), tr("Registration successful! You are now logged in."));
        set_to_backdrop();
    } else {
        QMessageBox::information(this, tr("SUCCESS"), tr("Registration successful! Please log in."));
        ui->workspaces->setCurrentIndex(1); // Go to login page
    }

    // Clear form
    ui->txtUsr_register->clear();
    ui->txtPwd1_register->clear();
    ui->txtPassword2_register->clear();
    ui->cboRole_register->setCurrentIndex(0);
}

void MainWindow::on_btnLogin_clicked()
{
    LOG_CLICK("btnLogin_clicked");

    QString username = ui->txtUsername_login->text().trimmed();
    QString password = ui->txtPassword_login->text();
    QString roleStr = ui->cboRole_login->currentText();

    if (username.isEmpty() || password.isEmpty()) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Username and password are required"));
        return;
    }

    Domain::User::Role selectedRole;
    if (roleStr == "Admin") selectedRole = Domain::User::Role::Admin;
    else if (roleStr == "Superadmin") selectedRole = Domain::User::Role::SuperAdmin;
    else selectedRole = Domain::User::Role::UserRole;

    auto loginResult = BusinessLogic::login(m_db, toStd(username), toStd(password));
    if (loginResult.has_value()) {
        // Verify role matches
        if (loginResult->role != selectedRole) {
            QMessageBox::critical(this, tr("LOGIN FAILED"), tr("Invalid role for this user"));
            return;
        }
        setCurrentUser(*loginResult);
        QMessageBox::information(this, tr("SUCCESS"), tr("Login successful!"));
        set_to_backdrop();

        // Clear form
        ui->txtUsername_login->clear();
        ui->txtPassword_login->clear();
        ui->cboRole_login->setCurrentIndex(0);
    } else {
        QMessageBox::critical(this, tr("LOGIN FAILED"), tr("Invalid username or password"));
    }
}

void MainWindow::on_chkHide_register_toggled(bool checked)
{
    LOG_CLICK("chkHide_register_toggled");
    ui->txtPwd1_register->setEchoMode(checked ? QLineEdit::Password : QLineEdit::Normal);
    ui->txtPassword2_register->setEchoMode(checked ? QLineEdit::Password : QLineEdit::Normal);
}

void MainWindow::on_chkHide_login_toggled(bool checked)
{
    LOG_CLICK("chkHide_login_toggled");
    ui->txtPassword_login->setEchoMode(checked ? QLineEdit::Password : QLineEdit::Normal);
}

void MainWindow::on_actionClose_Application_triggered()
{
    LOG_CLICK("actionClose_Application_triggered");
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Close Application"));
    box.setText(tr("Close application?"));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // gracefully close all streams etc etc
        QCoreApplication::exit();
    }
}

// ======================================= BOOKS ======================================================

//undo edit button






// lst clicked in edit books - populate edit fields
void MainWindow::on_lstSearch_book_edit_itemClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_book_edit_itemClicked");
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 6)
    {
        ui->txtTitle_book_edit->setText(parts[0].trimmed());
        ui->txtAuthor_book_edit->setText(parts[1].trimmed());
        ui->cboLocation_book_edit->setCurrentText(parts[2].trimmed());
        ui->cboCategory_book_edit->setCurrentText(parts[3].trimmed());
        ui->cboStatus_book_edit->setCurrentText(parts[4].trimmed());
        QString id_part = parts[5];
        if (id_part.startsWith("ID: "))
            id_part = id_part.mid(4);
        ui->txtId_book_edit->setText(id_part.trimmed());

        // Populate book_selected DTO
        book_selected.title = toStd(parts[0].trimmed());
        book_selected.author = toStd(parts[1].trimmed());
        book_selected.location = toStd(parts[2].trimmed());
        book_selected.category = toStd(parts[3].trimmed());
        book_selected.status = toStd(parts[4].trimmed());
        book_selected.id = id_part.trimmed().toStdString();

        // Also populate loan form if visible
        ui->txtSelected_book->setText(text);
    }
}


// lst clicked in edit readers - populate edit fields
void MainWindow::on_lstSearch_reader_edit_itemClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_reader_edit_itemClicked");
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 5)
    {
        ui->txtName_reader_edit->setText(parts[0].trimmed());
        ui->txtSurname_reader_edit->setText(parts[1].trimmed());
        ui->txtGrade_reader_edit->setText(parts[2].trimmed());
        ui->txtClass_reader_edit->setText(parts[3].trimmed());
        ui->txtId_reader_edit->setText(parts[4].trimmed());

        // Populate reader_selected DTO
        reader_selected.name = toStd(parts[0].trimmed());
        reader_selected.surname = toStd(parts[1].trimmed());
        reader_selected.grade = parts[2].trimmed().toShort();
        QString classStr = parts[3].trimmed();
        reader_selected.classGroup = classStr.isEmpty() ? 'A' : classStr.at(0).toLatin1();
        reader_selected.studentId = toStd(parts[4].trimmed());
        reader_selected.id = reader_selected.studentId;

        // Also populate loan form if visible
        ui->txtSelected_reader->setText(text);
    }
}



// ============== CATEGORIES ==============















/// =============================================== UNDO REMOVED READERS ===================================







/// =============================================== READERS ===================================
// add readers button
void MainWindow::on_btnAddBook_addreaders_clicked()
{
    LOG_CLICK("btnAddBook_addreaders_clicked");
    DTO::ReaderDTO reader;
    reader.name = toStd(ui->txtName_addreaders->text());
    reader.surname = toStd(ui->txtSurname_addreaders->text());
    reader.grade = ui->txtGrade_addreaders->text().toShort();
    QString classStr = ui->txtClass_addreaders->text().trimmed();
    reader.classGroup = classStr.isEmpty() ? 'A' : classStr.at(0).toLatin1();
    reader.createdAt = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));
    reader.updatedAt = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));

    // Autogenerate ID if checkbox is checked
    if (ui->chkAutogenerateID_addreaders->isChecked()) {
        int length = ui->txtIDlength_addreaders->text().toInt();
        if (length < 1) length = 8;

        QString idType = ui->cboIDtypes_addreaders->currentText();
        std::string generatedId;

        if (idType.contains("sequential")) {
            auto allReaders = m_db.getAllReaders();
            int maxId = 0;
            for (const auto& r : allReaders) {
                try {
                    int numId = std::stoi(r.id);
                    if (numId > maxId) maxId = numId;
                } catch (...) {}
            }
            generatedId = std::to_string(maxId + 1);
            while ((int)generatedId.size() < length) generatedId = "0" + generatedId;
        } else if (idType.contains("randomized")) {
            static std::mt19937 rng(std::chrono::steady_clock::now().time_since_epoch().count());
            std::uniform_int_distribution<int> dist(0, 9);
            generatedId = "";
            for (int i = 0; i < length; ++i) generatedId += std::to_string(dist(rng));
        } else if (idType.contains("hash")) {
            std::string data = reader.name + reader.surname + reader.createdAt;
            std::hash<std::string> hasher;
            size_t hash = hasher(data);
            generatedId = std::to_string(hash);
            if ((int)generatedId.size() > length) generatedId = generatedId.substr(0, length);
            else while ((int)generatedId.size() < length) generatedId = "0" + generatedId;
        } else {
            // Alphanumeric random
            static std::mt19937 rng(std::chrono::steady_clock::now().time_since_epoch().count());
            std::uniform_int_distribution<int> dist(0, 35);
            generatedId = "";
            const char chars[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
            for (int i = 0; i < length; ++i) generatedId += chars[dist(rng)];
        }

        // Check uniqueness if checkbox is checked
        if (ui->chkUniqueID_addreaders->isChecked()) {
            int attempts = 0;
            while (m_db.getReaderById(generatedId).has_value() && attempts < 100) {
                std::mt19937 rng(std::chrono::steady_clock::now().time_since_epoch().count() + attempts);
                std::uniform_int_distribution<int> dist(0, 9);
                generatedId = "";
                for (int i = 0; i < length; ++i) generatedId += std::to_string(dist(rng));
                ++attempts;
            }
        }

        reader.studentId = generatedId;
        reader.id = generatedId;
    } else {
        reader.studentId = toStd(ui->txtID_addreaders->text());
        reader.id = reader.studentId;
    }

    // Validate through business logic
    {
        auto result = BusinessLogic::addReader(m_db, reader);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    QString display = QString::fromStdString(reader.toDisplayString());

    auto* listItem = new QListWidgetItem(display);
    listItem->setData(Qt::UserRole, QString::fromStdString(reader.id));
    ui->lstSearch_reader_edit->addItem(listItem);

    last_reader_added = reader;

    m_worklog.logEntry(WorklogEntry::ActionType::Add, WorklogEntry::EntityType::Reader,
        reader.id, "Name: " + reader.name + " " + reader.surname);

    QMessageBox::information(this, tr("SUCCESS"), tr("Reader added"));

    ui->txtName_addreaders->clear();
    ui->txtSurname_addreaders->clear();
    ui->txtGrade_addreaders->clear();
    ui->txtClass_addreaders->clear();
    if (!ui->chkAutogenerateID_addreaders->isChecked()) {
        ui->txtID_addreaders->clear();
    }
}

void MainWindow::on_chkAutogenerateID_addreaders_toggled(bool checked)
{
    LOG_CLICK("chkAutogenerateID_addreaders_toggled");
    ui->txtID_addreaders->setReadOnly(checked);
    ui->txtID_addreaders->clear();
    if (checked) {
        ui->txtID_addreaders->setStyleSheet("QLineEdit { background-color: #e0e0e0; }");
        ui->txtID_addreaders->setToolTip("ID will be auto-generated when you click Add Reader");
    } else {
        ui->txtID_addreaders->setStyleSheet("");
        ui->txtID_addreaders->setToolTip("");
    }
}

void MainWindow::on_btnCheckId_addreaders_clicked()
{
    LOG_CLICK("btnCheckId_addreaders_clicked");
    QString id = ui->txtID_addreaders->text().trimmed();
    if (is_qstring_empty(id)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Please enter a reader ID to check!"));
        return;
    }

    auto reader = m_db.getReaderById(toStd(id));
    if (reader.has_value()) {
        QMessageBox::warning(this, tr("ID EXISTS"), tr("Reader ID %1 already exists:\nName: %2 %3")
            .arg(id)
            .arg(QString::fromStdString(reader->name))
            .arg(QString::fromStdString(reader->surname)));
    } else {
        QMessageBox::information(this, tr("ID AVAILABLE"), tr("Reader ID %1 is available").arg(id));
    }
}

// ======================================= LOANS ======================================================





// ============================ EDIT LOANS ======================================================






// ============================ LOAN STATUSES ======================================================

// filter loans by status
void MainWindow::on_btnFilter_loanstatus_clicked()
{
    LOG_CLICK("btnFilter_loanstatus_clicked");
    QString statusFilter = ui->cboStatusFilter_loanstatus->currentText();
    QString returnDateFilter = ui->cboReturnDateFilter_loanstatus->currentText();
    ui->lstSearch_loanstatus->clear();

    if (database_loans.isEmpty()) {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No loan database selected"));
        return;
    }

    std::vector<Domain::Loan> loans;
    if (statusFilter.isEmpty() || statusFilter == "All") {
        loans = m_db.getAllLoans();
    } else if (statusFilter == "Overdue") {
        loans = m_db.getOverdueLoans();
    } else {
        auto allLoans = m_db.getAllLoans();
        for (const auto& loan : allLoans) {
            if (loan.status == toStd(statusFilter)) {
                loans.push_back(loan);
            }
        }
    }

    if (!returnDateFilter.isEmpty() && returnDateFilter != "All") {
        std::vector<Domain::Loan> filtered;
        for (const auto& loan : loans) {
            bool isReturned = !Domain::isNull(loan.returnDate);
            if (returnDateFilter == "Returned" && isReturned) {
                filtered.push_back(loan);
            } else if (returnDateFilter == "Not Returned" && !isReturned) {
                filtered.push_back(loan);
            }
        }
        loans = filtered;
    }

    for (const auto& loan : loans) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(loan.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(loan.id));
        ui->lstSearch_loanstatus->addItem(listItem);
    }

    if (loans.empty()) {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No loans match the filter"));
    }
}

// search loans
void MainWindow::on_btnSearch_loanstatus_clicked()
{
    LOG_CLICK("btnSearch_loanstatus_clicked");
    QString search_term = ui->txtSearch_loanstatus->text();
    if (search_term.trimmed().isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("Search term cannot be empty"));
        return;
    }

    if (database_loans.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No loan database selected"));
        return;
    }

    ui->lstSearch_loanstatus->clear();
    auto allLoans = m_db.getActiveLoans();
    auto overdueLoans = m_db.getOverdueLoans();
    std::vector<Domain::Loan> loans;
    loans.insert(loans.end(), allLoans.begin(), allLoans.end());
    for (const auto& ol : overdueLoans) {
        bool found = false;
        for (const auto& l : loans) {
            if (l.id == ol.id) { found = true; break; }
        }
        if (!found) loans.push_back(ol);
    }

    QString filter = search_term.toLower();
    bool found = false;
    for (const auto& loan : loans) {
        QString display = QString::fromStdString(loan.toDisplayString());
        if (display.toLower().contains(filter)) {
            auto* listItem = new QListWidgetItem(display);
            listItem->setData(Qt::UserRole, QString::fromStdString(loan.id));
            ui->lstSearch_loanstatus->addItem(listItem);
            found = true;
        }
    }

    if (!found) {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching loans found"));
    }
}

// refresh loan statuses
void MainWindow::on_btnRefresh_loanstatus_clicked()
{
    LOG_CLICK("btnRefresh_loanstatus_clicked");
    ui->txtSearch_loanstatus->clear();
    ui->cboStatusFilter_loanstatus->setCurrentIndex(0);
    ui->lstSearch_loanstatus->clear();

    if (database_loans.isEmpty()) {
        QMessageBox::information(this, tr("REFRESH"), tr("No loan database selected"));
        return;
    }

    auto allLoans = m_db.getAllLoans();

    for (const auto& loan : allLoans) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(loan.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(loan.id));
        ui->lstSearch_loanstatus->addItem(listItem);
    }
}

// overdue report
void MainWindow::on_btnOverdueReport_loanstatus_clicked()
{
    LOG_CLICK("btnOverdueReport_loanstatus_clicked");
    if (database_loans.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No loan database selected"));
        return;
    }

    ui->lstSearch_loanstatus->clear();
    auto overdueLoans = m_db.getOverdueLoans();

    for (const auto& loan : overdueLoans) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(loan.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(loan.id));
        ui->lstSearch_loanstatus->addItem(listItem);
    }

    if (overdueLoans.empty()) {
        QMessageBox::information(this, tr("NO OVERDUE LOANS"), tr("There are no overdue loans"));
    } else {
        QMessageBox::information(this, tr("OVERDUE REPORT"), tr("Found %1 overdue loan(s)").arg(overdueLoans.size()));
    }
}

// double-click loan in status list to edit
void MainWindow::on_lstSearch_loanstatus_itemDoubleClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_loanstatus_itemDoubleClicked");
    QString text = item->text();
    QString id = item->data(Qt::UserRole).toString();

    loan_selected.id = toStd(id);
    loan_selected.bookId = "";
    loan_selected.readerId = "";
    loan_selected.status = "";

    QStringList parts = text.split(" | ");
    for (const auto& part : parts) {
        QString trimmed = part.trimmed();
        if (trimmed.startsWith("Book: ")) {
            loan_selected.bookId = trimmed.mid(6).toStdString();
        } else if (trimmed.startsWith("Reader: ")) {
            loan_selected.readerId = trimmed.mid(8).toStdString();
        } else if (trimmed.startsWith("Status: ")) {
            loan_selected.status = trimmed.mid(8).toStdString();
        } else if (trimmed.startsWith("Due: ")) {
            loan_selected.dueDate = trimmed.mid(5).toStdString();
        }
    }

    QMessageBox::information(this, tr("LOAN DETAILS"),
        tr("Loan ID: %1\nBook ID: %2\nReader ID: %3\nStatus: %4\nDue: %5")
        .arg(QString::fromStdString(loan_selected.id))
        .arg(QString::fromStdString(loan_selected.bookId))
        .arg(QString::fromStdString(loan_selected.readerId))
        .arg(QString::fromStdString(loan_selected.status))
        .arg(QString::fromStdString(loan_selected.dueDate)));
}

// ==================== STUB IMPLEMENTATIONS FOR MISSING SLOTS ====================
// These are minimal stubs to allow compilation. Full implementations needed for functionality.

void MainWindow::on_btnClear_loan_edit_clicked()
{
    LOG_CLICK("btnClear_loan_edit_clicked");
    ui->txtSearch_loan->clear();
    ui->txtSelected_loan->clear();
    ui->txtDueDate_loan->clear();
    ui->txtReturnDate_loan->clear();
    ui->cboStatus_loan->setCurrentIndex(-1);
    ui->lstSearch_loan->clear();
}

void MainWindow::on_btnReturn_loan_clicked()
{
    LOG_CLICK("btnReturn_loan_clicked");
    QList<QListWidgetItem*> selected = ui->lstSearch_loan->selectedItems();
    if (selected.isEmpty()) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Please select a loan to return"));
        return;
    }

    QListWidgetItem* item = selected.first();
    QString id = item->data(Qt::UserRole).toString();

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Return loan?"));
    box.setText(tr("Are you sure you want to return this loan?"));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    bool success = m_db.returnBook(toStd(id));
    if (success) {
        m_worklog.logEntry(WorklogEntry::ActionType::Edit, WorklogEntry::EntityType::Loan,
            toStd(id), "Returned");
        QMessageBox::information(this, tr("SUCCESS"), tr("Book returned successfully"));
        int row = ui->lstSearch_loan->row(item);
        delete ui->lstSearch_loan->takeItem(row);
    } else {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to return book"));
    }
}

void MainWindow::on_btnUpdate_loan_clicked()
{
    LOG_CLICK("btnUpdate_loan_clicked");
    QList<QListWidgetItem*> selected = ui->lstSearch_loan->selectedItems();
    if (selected.isEmpty()) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Please select a loan to update"));
        return;
    }

    QListWidgetItem* item = selected.first();
    QString id = item->data(Qt::UserRole).toString();

    QString status = ui->cboStatus_loan->currentText();

    auto allLoans = m_db.getAllLoans();
    Domain::Loan* loanPtr = nullptr;
    for (auto& loan : allLoans) {
        if (loan.id == toStd(id)) {
            loanPtr = &loan;
            break;
        }
    }

    if (!loanPtr) {
        QMessageBox::critical(this, tr("ERROR"), tr("Loan not found"));
        return;
    }

    DTO::LoanDTO updatedLoan = DTO::LoanDTO::fromDomain(*loanPtr);
    updatedLoan.status = toStd(status);

    if (status == "returned") {
        updatedLoan.returnDate = Domain::toISOString(Domain::now());
    }

    auto result = BusinessLogic::updateLoan(m_db, updatedLoan);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    item->setText(QString::fromStdString(updatedLoan.toDisplayString()));

    m_worklog.logEntry(WorklogEntry::ActionType::Edit, WorklogEntry::EntityType::Loan,
        updatedLoan.id, "Status: " + updatedLoan.status);

    QMessageBox::information(this, tr("SUCCESS"), tr("Loan updated"));
}

void MainWindow::on_lstSearch_loan_itemClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_loan_itemClicked");
    QString text = item->text();
    ui->txtSelected_loan->setText(text);

    QString id = item->data(Qt::UserRole).toString();
    loan_selected.id = toStd(id);

    QStringList parts = text.split(" | ");
    for (const auto& part : parts) {
        QString trimmed = part.trimmed();
        if (trimmed.startsWith("Status: ")) {
            QString statusVal = trimmed.mid(8);
            int idx = ui->cboStatus_loan->findText(statusVal);
            if (idx >= 0) ui->cboStatus_loan->setCurrentIndex(idx);
        } else if (trimmed.startsWith("Due: ")) {
            ui->txtDueDate_loan->setText(trimmed.mid(5));
        } else if (trimmed.startsWith("Return: ")) {
            ui->txtReturnDate_loan->setText(trimmed.mid(8));
        }
    }
}

void MainWindow::on_btnSearch_loan_clicked()
{
    LOG_CLICK("btnSearch_loan_clicked");
    QString search_term = ui->txtSearch_loan->text().trimmed();
    if (is_qstring_empty(search_term)) {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("Please enter a search term!"));
        return;
    }

    if (database_loans.isEmpty()) {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No loan database selected"));
        return;
    }

    QString field = ui->cboSearchField_loan->currentText();
    std::string stdField = toStd(field);
    std::string stdTerm = toStd(search_term);

    ui->lstSearch_loan->clear();

    std::vector<Domain::Loan> results;
    if (field == "ID") {
        auto allLoans = m_db.getAllLoans();
        for (const auto& loan : allLoans) {
            if (loan.id.find(stdTerm) != std::string::npos) {
                results.push_back(loan);
            }
        }
    } else if (field == "Book ID") {
        auto allLoans = m_db.getAllLoans();
        for (const auto& loan : allLoans) {
            if (loan.bookId.find(stdTerm) != std::string::npos) {
                results.push_back(loan);
            }
        }
    } else if (field == "Reader ID") {
        auto allLoans = m_db.getAllLoans();
        for (const auto& loan : allLoans) {
            if (loan.readerId.find(stdTerm) != std::string::npos) {
                results.push_back(loan);
            }
        }
    } else if (field == "Status") {
        auto allLoans = m_db.getAllLoans();
        for (const auto& loan : allLoans) {
            if (loan.status.find(stdTerm) != std::string::npos) {
                results.push_back(loan);
            }
        }
    } else {
        results = m_db.getAllLoans();
    }

    for (const auto& loan : results) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(loan.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(loan.id));
        ui->lstSearch_loan->addItem(listItem);
    }

    if (results.empty()) {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching loans found"));
    }
}

void MainWindow::on_btnClear_loan_clicked()
{
    LOG_CLICK("btnClear_loan_clicked");
    ui->txtSearch_book->clear();
    ui->txtSearch_reader->clear();
    ui->txtSelected_book->clear();
    ui->txtSelected_reader->clear();
    ui->lstSearch_book->clear();
    ui->lstSearch_reader->clear();
    ui->spnLoanDays_loan->setValue(14);
    book_selected = DTO::BookDTO{};
    reader_selected = DTO::ReaderDTO{};
}

void MainWindow::on_btnAdd_loan_clicked()
{
    LOG_CLICK("btnAdd_loan_clicked");
    if (book_selected.id.empty()) {
        QMessageBox::critical(this, tr("NO BOOK SELECTED"), tr("Please search and select a book first!"));
        return;
    }
    if (reader_selected.id.empty()) {
        QMessageBox::critical(this, tr("NO READER SELECTED"), tr("Please search and select a reader first!"));
        return;
    }

    int days = ui->spnLoanDays_loan->value();

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Confirm Loan"));
    box.setText(tr("Create loan for:\nBook: %1 by %2\nReader: %3 %4\nDays: %5")
        .arg(QString::fromStdString(book_selected.title))
        .arg(QString::fromStdString(book_selected.author))
        .arg(QString::fromStdString(reader_selected.name))
        .arg(QString::fromStdString(reader_selected.surname))
        .arg(days));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    bool success = m_db.loanBook(book_selected.id, reader_selected.id, days);
    if (!success) {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to create loan. The book may already be borrowed."));
        return;
    }

    QMessageBox::information(this, tr("SUCCESS"), tr("Loan created successfully"));

    m_worklog.logEntry(WorklogEntry::ActionType::Add, WorklogEntry::EntityType::Loan,
        "new", "Book: " + book_selected.title + " | Reader: " + reader_selected.name + " " + reader_selected.surname);

    // Clear selections
    book_selected = DTO::BookDTO{};
    reader_selected = DTO::ReaderDTO{};
    ui->txtSelected_book->clear();
    ui->txtSelected_reader->clear();
    ui->lstSearch_book->clear();
    ui->lstSearch_reader->clear();
    ui->txtSearch_book->clear();
    ui->txtSearch_reader->clear();
}

void MainWindow::on_btnSearch_book_clicked()
{
    LOG_CLICK("btnSearch_book_clicked");
    QString term = ui->txtSearch_book->text().trimmed();
    if (is_qstring_empty(term)) {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("Please enter a search term!"));
        return;
    }

    QString field = ui->cboSearchField_book->currentText();
    auto books = m_db.searchBooks(toStd(term), toStd(field));

    ui->lstSearch_book->clear();
    for (const auto& book : books) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(book.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(book.id));
        ui->lstSearch_book->addItem(listItem);
    }

    if (books.empty()) {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching books found"));
    }
}

void MainWindow::on_btnSearch_reader_clicked()
{
    LOG_CLICK("btnSearch_reader_clicked");
    QString term = ui->txtSearch_reader->text().trimmed();
    if (is_qstring_empty(term)) {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("Please enter a search term!"));
        return;
    }

    QString field = ui->cboSearchField_reader->currentText();
    auto readers = m_db.searchReaders(toStd(term), toStd(field));

    ui->lstSearch_reader->clear();
    for (const auto& reader : readers) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(reader.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(reader.id));
        ui->lstSearch_reader->addItem(listItem);
    }

    if (readers.empty()) {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching readers found"));
    }
}

void MainWindow::on_lstSearch_book_itemClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_book_itemClicked");
    QString id = item->data(Qt::UserRole).toString();
    auto book = m_db.getBookById(toStd(id));
    if (book.has_value()) {
        book_selected = DTO::BookDTO::fromDomain(*book);
        ui->txtSelected_book->setText(QString::fromStdString(book->toDisplayString()));
    }
}

void MainWindow::on_lstSearch_reader_itemClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_reader_itemClicked");
    QString id = item->data(Qt::UserRole).toString();
    auto reader = m_db.getReaderById(toStd(id));
    if (reader.has_value()) {
        reader_selected = DTO::ReaderDTO::fromDomain(*reader);
        ui->txtSelected_reader->setText(item->text());
    }
}

void MainWindow::on_btnClear_id_reader_remove_clicked()
{
    LOG_CLICK("btnClear_id_reader_remove_clicked");
    ui->txtId_reader_remove->clear();
}

void MainWindow::on_btnClear_class_reader_remove_clicked()
{
    LOG_CLICK("btnClear_class_reader_remove_clicked");
    ui->txtClass_reader_remove->clear();
}

void MainWindow::on_btnClear_grade_reader_remove_clicked()
{
    LOG_CLICK("btnClear_grade_reader_remove_clicked");
    ui->txtGrade_reader_remove->clear();
}

void MainWindow::on_btnClear_surname_reader_remove_clicked()
{
    LOG_CLICK("btnClear_surname_reader_remove_clicked");
    ui->txtSurname_reader_remove->clear();
}

void MainWindow::on_btnClear_name_reader_remove_clicked()
{
    LOG_CLICK("btnClear_name_reader_remove_clicked");
    ui->txtName_reader_remove->clear();
}

void MainWindow::on_btnUndoLast_reader_clicked()
{
    LOG_CLICK("btnUndoLast_reader_clicked");
    if (is_reader_dto_empty(last_reader_added)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent add to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo add?"));
    box.setText(tr("Undo adding reader:\nName: %1 %2")
        .arg(QString::fromStdString(last_reader_added.name))
        .arg(QString::fromStdString(last_reader_added.surname)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    m_db.removeReader(last_reader_added.id);

    for (int i = 0; i < ui->lstSearch_reader_edit->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_reader_edit->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(last_reader_added.id)) {
            delete ui->lstSearch_reader_edit->takeItem(i);
            break;
        }
    }

    last_reader_added = DTO::ReaderDTO{};
    QMessageBox::information(this, tr("UNDO ADD"), tr("Reader add undone"));
}

void MainWindow::on_btnUndoRemoval_reader_clicked()
{
    LOG_CLICK("btnUndoRemoval_reader_clicked");
    if (is_reader_dto_empty(last_reader_removed)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent removal to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo removal?"));
    box.setText(tr("Undo removing reader:\nName: %1 %2")
        .arg(QString::fromStdString(last_reader_removed.name))
        .arg(QString::fromStdString(last_reader_removed.surname)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    bool success = m_db.restoreReader(last_reader_removed.id);
    if (!success) {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to restore reader"));
        return;
    }

    auto* listItem = new QListWidgetItem(QString::fromStdString(last_reader_removed.toDisplayString()));
    listItem->setData(Qt::UserRole, QString::fromStdString(last_reader_removed.id));
    ui->lstSearch_reader_edit->addItem(listItem);

    last_reader_removed = DTO::ReaderDTO{};
    QMessageBox::information(this, tr("UNDO REMOVE"), tr("Reader removal undone"));
}

void MainWindow::on_btnRemove_reader_clicked()
{
    LOG_CLICK("btnRemove_reader_clicked");
    if (is_reader_dto_empty(reader_selected)) {
        QMessageBox::critical(this, tr("NO READER SELECTED"), tr("Please select a reader from the list to remove!"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Remove reader?"));
    box.setText(tr("Are you sure you want to remove reader:\nName: %1 %2")
        .arg(QString::fromStdString(reader_selected.name))
        .arg(QString::fromStdString(reader_selected.surname)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    bool success = m_db.removeReader(reader_selected.id);
    if (!success) {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to remove reader"));
        return;
    }

    last_reader_removed = reader_selected;

    m_worklog.logEntry(WorklogEntry::ActionType::Remove, WorklogEntry::EntityType::Reader,
        reader_selected.id, "Name: " + reader_selected.name + " " + reader_selected.surname);

    for (int i = 0; i < ui->lstSearch_reader_remove->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_reader_remove->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(reader_selected.id)) {
            delete ui->lstSearch_reader_remove->takeItem(i);
            break;
        }
    }

    reader_selected = DTO::ReaderDTO{};
    ui->txtName_reader_remove->clear();
    ui->txtSurname_reader_remove->clear();
    ui->txtGrade_reader_remove->clear();
    ui->txtClass_reader_remove->clear();
    ui->txtId_reader_remove->clear();
    QMessageBox::information(this, tr("SUCCESS"), tr("Reader removed"));
}

void MainWindow::on_btnSearch_reader_remove_clicked()
{
    LOG_CLICK("btnSearch_reader_remove_clicked");
    QString search_term = ui->txtSearch_reader_remove->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
        return;
    }

    if (database_readers.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    ui->lstSearch_reader_remove->clear();
    auto readers = m_db.searchReaders(toStd(search_term), "name");
    for (const auto& reader : readers) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(reader.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(reader.id));
        ui->lstSearch_reader_remove->addItem(listItem);
    }

    if (readers.empty()) {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching readers found"));
    }
}

void MainWindow::on_btnSearch_reader_edit_clicked()
{
    LOG_CLICK("btnSearch_reader_edit_clicked");
    QString search_term = ui->txtSearch_reader_edit->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
        return;
    }

    if (database_readers.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    QString filter = search_term.toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_reader_edit->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_reader_edit->item(i);
        if (item->text().toLower().contains(filter))
        {
            item->setHidden(false);
            found = true;
        }
        else
        {
            item->setHidden(true);
        }
    }

    if (!found && ui->lstSearch_reader_edit->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching readers found"));
    }
}

void MainWindow::on_btnEdit_reader_clicked()
{
    LOG_CLICK("btnEdit_reader_clicked");
    if (is_reader_dto_empty(reader_selected)) {
        QMessageBox::critical(this, tr("NO READER SELECTED"), tr("Please select a reader from the list to edit!"));
        return;
    }

    QString name = ui->txtName_reader_edit->text().trimmed();
    QString surname = ui->txtSurname_reader_edit->text().trimmed();
    QString grade = ui->txtGrade_reader_edit->text().trimmed();
    QString classGroup = ui->txtClass_reader_edit->text().trimmed();
    QString id = ui->txtId_reader_edit->text().trimmed();

    if (is_qstring_empty(name)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Name cannot be empty!"));
        return;
    }
    if (is_qstring_empty(surname)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Surname cannot be empty!"));
        return;
    }

    DTO::ReaderDTO updatedReader;
    updatedReader.id = toStd(id);
    updatedReader.name = toStd(name);
    updatedReader.surname = toStd(surname);
    updatedReader.grade = grade.toShort();
    updatedReader.classGroup = classGroup.isEmpty() ? 'A' : classGroup.at(0).toLatin1();
    updatedReader.studentId = toStd(id);

    auto result = BusinessLogic::updateReader(m_db, updatedReader);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    last_reader_edited = reader_selected;

    m_worklog.logEntry(WorklogEntry::ActionType::Edit, WorklogEntry::EntityType::Reader,
        reader_selected.id, "Name: " + updatedReader.name + " " + updatedReader.surname);

    for (int i = 0; i < ui->lstSearch_reader_edit->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_reader_edit->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(reader_selected.id)) {
            item->setText(QString::fromStdString(updatedReader.toDisplayString()));
            break;
        }
    }

    reader_selected = updatedReader;
    QMessageBox::information(this, tr("SUCCESS"), tr("Reader edited"));
}

void MainWindow::on_btnUndoEdit_reader_clicked()
{
    LOG_CLICK("btnUndoEdit_reader_clicked");
    if (is_reader_dto_empty(last_reader_edited)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent edit to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo edit?"));
    box.setText(tr("Undo editing reader:\nName: %1 %2")
        .arg(QString::fromStdString(last_reader_edited.name))
        .arg(QString::fromStdString(last_reader_edited.surname)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    auto result = BusinessLogic::updateReader(m_db, last_reader_edited);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    for (int i = 0; i < ui->lstSearch_reader_edit->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_reader_edit->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(reader_selected.id)) {
            item->setText(QString::fromStdString(last_reader_edited.toDisplayString()));
            break;
        }
    }

    last_reader_edited = DTO::ReaderDTO{};
    QMessageBox::information(this, tr("UNDO EDIT"), tr("Reader edit undone"));
}

void MainWindow::on_btnRemove_book_clicked()
{
    LOG_CLICK("btnRemove_book_clicked");
    if (is_book_dto_empty(book_selected)) {
        QMessageBox::critical(this, tr("NO BOOK SELECTED"), tr("Please select a book from the list to remove!"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Remove book?"));
    box.setText(tr("Are you sure you want to remove book:\nTitle: %1\nAuthor: %2")
        .arg(QString::fromStdString(book_selected.title))
        .arg(QString::fromStdString(book_selected.author)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    bool success = m_db.removeBook(book_selected.id);
    if (!success) {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to remove book"));
        return;
    }

    last_book_removed = book_selected;

    m_worklog.logEntry(WorklogEntry::ActionType::Remove, WorklogEntry::EntityType::Book,
        book_selected.id, "Title: " + book_selected.title + " | Author: " + book_selected.author);

    for (int i = 0; i < ui->lstSearch_book_remove->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_book_remove->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(book_selected.id)) {
            delete ui->lstSearch_book_remove->takeItem(i);
            break;
        }
    }

    book_selected = DTO::BookDTO{};
    ui->txtTitle_book_remove->clear();
    ui->txtAuthor_book_remove->clear();
    ui->txtId_book_remove->clear();
    QMessageBox::information(this, tr("SUCCESS"), tr("Book removed"));
}

void MainWindow::on_btnUndoAdd_addreaders_clicked()
{
    LOG_CLICK("btnUndoAdd_addreaders_clicked");
    if (is_reader_dto_empty(last_reader_added)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent add to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo add?"));
    box.setText(tr("Undo adding reader:\nName: %1 %2")
        .arg(QString::fromStdString(last_reader_added.name))
        .arg(QString::fromStdString(last_reader_added.surname)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    m_db.removeReader(last_reader_added.id);

    for (int i = 0; i < ui->lstSearch_reader_edit->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_reader_edit->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(last_reader_added.id)) {
            delete ui->lstSearch_reader_edit->takeItem(i);
            break;
        }
    }

    last_reader_added = DTO::ReaderDTO{};
    QMessageBox::information(this, tr("UNDO ADD"), tr("Reader add undone"));
}

void MainWindow::on_btnRedoAllSelected_undoreaders_clicked()
{
    LOG_CLICK("btnRedoAllSelected_undoreaders_clicked");
    QList<QListWidgetItem*> selected = ui->lstSearch_undoreaders->selectedItems();
    if (selected.isEmpty()) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Please select items to re-remove"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Re-remove selected readers?"));
    box.setText(tr("Are you sure you want to remove %1 selected readers again?").arg(selected.size()));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    int removed = 0;
    for (QListWidgetItem* item : selected) {
        QString id = item->data(Qt::UserRole).toString();
        if (m_db.removeReader(toStd(id))) {
            ++removed;
        }
    }

    qDeleteAll(selected);

    QMessageBox::information(this, tr("SUCCESS"), tr("Re-removed %1 readers").arg(removed));
}

void MainWindow::on_btnRedoRemove_undoreaders_clicked()
{
    LOG_CLICK("btnRedoRemove_undoreaders_clicked");
    QList<QListWidgetItem*> selected = ui->lstSearch_undoreaders->selectedItems();
    if (selected.isEmpty()) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Please select an item to re-remove"));
        return;
    }

    QListWidgetItem* item = selected.first();
    QString id = item->data(Qt::UserRole).toString();

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Re-remove reader?"));
    box.setText(tr("Are you sure you want to remove this reader again?"));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    bool success = m_db.removeReader(toStd(id));
    if (success) {
        int row = ui->lstSearch_undoreaders->row(item);
        delete ui->lstSearch_undoreaders->takeItem(row);
        QMessageBox::information(this, tr("SUCCESS"), tr("Reader re-removed"));
    } else {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to remove reader"));
    }
}

void MainWindow::on_btnUndoSelected_undoreaders_clicked()
{
    LOG_CLICK("btnUndoSelected_undoreaders_clicked");
    QList<QListWidgetItem*> selected = ui->lstSearch_undoreaders->selectedItems();
    if (selected.isEmpty()) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Please select items to restore"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Restore selected readers?"));
    box.setText(tr("Are you sure you want to restore %1 selected readers?").arg(selected.size()));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    int restored = 0;
    for (QListWidgetItem* item : selected) {
        QString id = item->data(Qt::UserRole).toString();
        if (m_db.restoreReader(toStd(id))) {
            auto reader = m_db.getReaderById(toStd(id));
            if (reader.has_value()) {
                auto* listItem = new QListWidgetItem(QString::fromStdString(reader->toDisplayString()));
                listItem->setData(Qt::UserRole, QString::fromStdString(reader->id));
                ui->lstSearch_reader_edit->addItem(listItem);
            }
            ++restored;
        }
    }

    for (QListWidgetItem* item : selected) {
        int row = ui->lstSearch_undoreaders->row(item);
        delete ui->lstSearch_undoreaders->takeItem(row);
    }

    QMessageBox::information(this, tr("SUCCESS"), tr("Restored %1 readers").arg(restored));
}

void MainWindow::on_btnUndoAll_undoreaders_clicked()
{
    LOG_CLICK("btnUndoAll_undoreaders_clicked");
    if (database_readers.isEmpty()) {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    auto removedReaders = m_db.getRemovedReaders();
    if (removedReaders.empty()) {
        QMessageBox::information(this, tr("NOTHING TO UNDO"), tr("No removed readers to restore"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Restore all removed readers?"));
    box.setText(tr("Are you sure you want to restore all %1 removed readers?").arg(removedReaders.size()));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    int restored = 0;
    for (const auto& reader : removedReaders) {
        if (m_db.restoreReader(reader.id)) {
            auto* listItem = new QListWidgetItem(QString::fromStdString(reader.toDisplayString()));
            listItem->setData(Qt::UserRole, QString::fromStdString(reader.id));
            ui->lstSearch_reader_edit->addItem(listItem);
            ++restored;
        }
    }

    ui->lstSearch_undoreaders->clear();
    QMessageBox::information(this, tr("SUCCESS"), tr("Restored %1 readers").arg(restored));
}

void MainWindow::on_lstSearch_undoreaders_itemClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_undoreaders_itemClicked");
    QString text = item->text();
    last_reader_undone = DTO::ReaderDTO{};
    QStringList parts = text.split(" | ");
    if (parts.size() >= 5)
    {
        last_reader_undone.name = toStd(parts[0].trimmed());
        last_reader_undone.surname = toStd(parts[1].trimmed());
        last_reader_undone.grade = parts[2].trimmed().toShort();
        QString classStr = parts[3].trimmed();
        last_reader_undone.classGroup = classStr.isEmpty() ? 'A' : classStr.at(0).toLatin1();
        last_reader_undone.studentId = toStd(parts[4].trimmed());
        last_reader_undone.id = last_reader_undone.studentId;
    }
}

void MainWindow::on_btnSearch_undoreaders_clicked()
{
    LOG_CLICK("btnSearch_undoreaders_clicked");
    QString search_term = ui->txtSearch_undoreaders->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
        return;
    }

    if (database_readers.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    ui->lstSearch_undoreaders->clear();
    auto readers = m_db.getRemovedReaders();
    QString filter = search_term.toLower();
    bool found = false;
    for (const auto& reader : readers) {
        QString display = QString::fromStdString(reader.toDisplayString());
        if (display.toLower().contains(filter)) {
            auto* listItem = new QListWidgetItem(display);
            listItem->setData(Qt::UserRole, QString::fromStdString(reader.id));
            ui->lstSearch_undoreaders->addItem(listItem);
            found = true;
        }
    }

    if (!found) {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching removed readers found"));
    }
}

void MainWindow::on_btnRedoAllSelected_undobooks_clicked()
{
    LOG_CLICK("btnRedoAllSelected_undobooks_clicked");
    QList<QListWidgetItem*> selected = ui->lstSearch_undobooks->selectedItems();
    if (selected.isEmpty()) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Please select items to re-remove"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Re-remove selected books?"));
    box.setText(tr("Are you sure you want to remove %1 selected books again?").arg(selected.size()));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    int removed = 0;
    for (QListWidgetItem* item : selected) {
        QString id = item->data(Qt::UserRole).toString();
        if (m_db.removeBook(toStd(id))) {
            ++removed;
        }
    }

    qDeleteAll(selected);

    QMessageBox::information(this, tr("SUCCESS"), tr("Re-removed %1 books").arg(removed));
}

void MainWindow::on_btnRedoRemove_undobooks_clicked()
{
    LOG_CLICK("btnRedoRemove_undobooks_clicked");
    QList<QListWidgetItem*> selected = ui->lstSearch_undobooks->selectedItems();
    if (selected.isEmpty()) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Please select an item to re-remove"));
        return;
    }

    QListWidgetItem* item = selected.first();
    QString id = item->data(Qt::UserRole).toString();

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Re-remove book?"));
    box.setText(tr("Are you sure you want to remove this book again?"));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    bool success = m_db.removeBook(toStd(id));
    if (success) {
        int row = ui->lstSearch_undobooks->row(item);
        delete ui->lstSearch_undobooks->takeItem(row);
        QMessageBox::information(this, tr("SUCCESS"), tr("Book re-removed"));
    } else {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to remove book"));
    }
}

void MainWindow::on_btnUndoSelected_undobooks_clicked()
{
    LOG_CLICK("btnUndoSelected_undobooks_clicked");
    QList<QListWidgetItem*> selected = ui->lstSearch_undobooks->selectedItems();
    if (selected.isEmpty()) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Please select items to restore"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Restore selected books?"));
    box.setText(tr("Are you sure you want to restore %1 selected books?").arg(selected.size()));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    int restored = 0;
    for (QListWidgetItem* item : selected) {
        QString id = item->data(Qt::UserRole).toString();
        if (m_db.restoreBook(toStd(id))) {
            auto book = m_db.getBookById(toStd(id));
            if (book.has_value()) {
                auto* listItem = new QListWidgetItem(QString::fromStdString(book->toDisplayString()));
                listItem->setData(Qt::UserRole, QString::fromStdString(book->id));
                ui->lstSearch_book_edit->addItem(listItem);
            }
            ++restored;
        }
    }

    for (QListWidgetItem* item : selected) {
        int row = ui->lstSearch_undobooks->row(item);
        delete ui->lstSearch_undobooks->takeItem(row);
    }

    QMessageBox::information(this, tr("SUCCESS"), tr("Restored %1 books").arg(restored));
}

void MainWindow::on_btnUndoEdit_location_clicked()
{
    LOG_CLICK("btnUndoEdit_location_clicked");
    if (is_location_dto_empty(last_location_edited)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent edit to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo edit?"));
    box.setText(tr("Undo editing location:\nName: %1")
        .arg(QString::fromStdString(last_location_edited.name)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    auto result = BusinessLogic::updateLocation(m_db, last_location_edited);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    // Update list item back by ID
    for (int i = 0; i < ui->lstSearch_location->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_location->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(location_selected.id)) {
            item->setText(QString::fromStdString(last_location_edited.name));
            break;
        }
    }

    last_location_edited = DTO::LocationDTO{};
    QMessageBox::information(this, tr("UNDO EDIT"), tr("Location edit undone"));
}

void MainWindow::on_btnUndoAdd_location_clicked()
{
    LOG_CLICK("btnUndoAdd_location_clicked");
    if (is_location_dto_empty(last_location_added)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent add to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo add?"));
    box.setText(tr("Undo adding location:\nName: %1")
        .arg(QString::fromStdString(last_location_added.name)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    m_db.removeLocation(last_location_added.id);

    // Remove from list by ID
    for (int i = 0; i < ui->lstSearch_location->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_location->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(last_location_added.id)) {
            delete ui->lstSearch_location->takeItem(i);
            break;
        }
    }

    last_location_added = DTO::LocationDTO{};
    QMessageBox::information(this, tr("UNDO ADD"), tr("Location add undone"));
}

void MainWindow::on_btnUndoRemove_location_clicked()
{
    LOG_CLICK("btnUndoRemove_location_clicked");
    if (is_location_dto_empty(last_location_removed)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent remove to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo remove?"));
    box.setText(tr("Undo removing location:\nName: %1")
        .arg(QString::fromStdString(last_location_removed.name)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    auto result = BusinessLogic::addLocation(m_db, last_location_removed);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    auto* listItem = new QListWidgetItem(QString::fromStdString(last_location_removed.name));
    listItem->setData(Qt::UserRole, QString::fromStdString(last_location_removed.id));
    ui->lstSearch_location->addItem(listItem);
    last_location_removed = DTO::LocationDTO{};
    QMessageBox::information(this, tr("UNDO REMOVE"), tr("Location remove undone"));
}

void MainWindow::on_lstSearch_location_itemClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_location_itemClicked");
    ui->txtName_location->setText(item->text().trimmed());
    location_selected.name = toStd(item->text().trimmed());
    location_selected.id = toStd(item->data(Qt::UserRole).toString());
}

void MainWindow::on_btnAdd_location_clicked()
{
    LOG_CLICK("btnAdd_location_clicked");
    QString name = ui->txtName_location->text().trimmed();
    if (is_qstring_empty(name)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Location name cannot be empty!"));
        return;
    }

    DTO::LocationDTO loc;
    loc.name = toStd(name);
    loc.id = std::to_string(std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()).count());

    auto result = BusinessLogic::addLocation(m_db, loc);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    last_location_added = loc;

    auto* listItem = new QListWidgetItem(name);
    listItem->setData(Qt::UserRole, QString::fromStdString(loc.id));
    ui->lstSearch_location->addItem(listItem);
    ui->txtName_location->clear();

    QMessageBox::information(this, tr("SUCCESS"), tr("Location added"));
}

void MainWindow::on_btnEdit_location_clicked()
{
    LOG_CLICK("btnEdit_location_clicked");
    if (is_location_dto_empty(location_selected)) {
        QMessageBox::critical(this, tr("NO LOCATION SELECTED"), tr("Please select a location from the list to edit!"));
        return;
    }

    QString name = ui->txtName_location->text().trimmed();
    if (is_qstring_empty(name)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Location name cannot be empty!"));
        return;
    }

    DTO::LocationDTO updatedLoc;
    updatedLoc.id = location_selected.id;
    updatedLoc.name = toStd(name);

    auto result = BusinessLogic::updateLocation(m_db, updatedLoc);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    last_location_edited = location_selected;

    // Update list item by ID
    for (int i = 0; i < ui->lstSearch_location->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_location->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(location_selected.id)) {
            item->setText(name);
            break;
        }
    }

    location_selected = updatedLoc;
    QMessageBox::information(this, tr("SUCCESS"), tr("Location edited"));
}

void MainWindow::on_btnRemove_location_clicked()
{
    LOG_CLICK("btnRemove_location_clicked");
    if (is_location_dto_empty(location_selected)) {
        QMessageBox::critical(this, tr("NO LOCATION SELECTED"), tr("Please select a location from the list to remove!"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Remove location?"));
    box.setText(tr("Are you sure you want to remove location:\nName: %1")
        .arg(QString::fromStdString(location_selected.name)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    m_db.removeLocation(location_selected.id);
    last_location_removed = location_selected;

    // Remove from list by ID
    for (int i = 0; i < ui->lstSearch_location->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_location->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(location_selected.id)) {
            delete ui->lstSearch_location->takeItem(i);
            break;
        }
    }

    location_selected = DTO::LocationDTO{};
    ui->txtName_location->clear();
    QMessageBox::information(this, tr("SUCCESS"), tr("Location removed"));
}

void MainWindow::on_btnSearch_location_clicked()
{
    LOG_CLICK("btnSearch_location_clicked");
    QString search_term = ui->txtSearch_location->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
        return;
    }

    QString filter = search_term.toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_location->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_location->item(i);
        if (item->text().toLower().contains(filter))
        {
            item->setHidden(false);
            found = true;
        }
        else
        {
            item->setHidden(true);
        }
    }

    if (!found && ui->lstSearch_location->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching locations found"));
    }
}

void MainWindow::on_btnUndoAll_undobooks_clicked()
{
    LOG_CLICK("btnUndoAll_undobooks_clicked");
    if (database_books.isEmpty()) {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No book database selected"));
        return;
    }

    auto removedBooks = m_db.getRemovedBooks();
    if (removedBooks.empty()) {
        QMessageBox::information(this, tr("NOTHING TO UNDO"), tr("No removed books to restore"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Restore all removed books?"));
    box.setText(tr("Are you sure you want to restore all %1 removed books?").arg(removedBooks.size()));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    int restored = 0;
    for (const auto& book : removedBooks) {
        if (m_db.restoreBook(book.id)) {
            auto* listItem = new QListWidgetItem(QString::fromStdString(book.toDisplayString()));
            listItem->setData(Qt::UserRole, QString::fromStdString(book.id));
            ui->lstSearch_book_edit->addItem(listItem);
            ++restored;
        }
    }

    ui->lstSearch_undobooks->clear();
    QMessageBox::information(this, tr("SUCCESS"), tr("Restored %1 books").arg(restored));
}

void MainWindow::on_btnSearch_book_remove_clicked()
{
    LOG_CLICK("btnSearch_book_remove_clicked");
    QString search_term = ui->txtSearch_book_remove->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
        return;
    }

    if (database_books.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No book database selected"));
        return;
    }

    ui->lstSearch_book_remove->clear();
    auto books = m_db.searchBooks(toStd(search_term), "title");
    for (const auto& book : books) {
        auto* listItem = new QListWidgetItem(QString::fromStdString(book.toDisplayString()));
        listItem->setData(Qt::UserRole, QString::fromStdString(book.id));
        ui->lstSearch_book_remove->addItem(listItem);
    }

    if (books.empty()) {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching books found"));
    }
}

void MainWindow::on_btnSearch_undobooks_clicked()
{
    LOG_CLICK("btnSearch_undobooks_clicked");
    QString search_term = ui->txtSearch_undobooks->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
        return;
    }

    if (database_books.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No book database selected"));
        return;
    }

    ui->lstSearch_undobooks->clear();
    auto books = m_db.getRemovedBooks();
    QString filter = search_term.toLower();
    bool found = false;
    for (const auto& book : books) {
        QString display = QString::fromStdString(book.toDisplayString());
        if (display.toLower().contains(filter)) {
            auto* listItem = new QListWidgetItem(display);
            listItem->setData(Qt::UserRole, QString::fromStdString(book.id));
            ui->lstSearch_undobooks->addItem(listItem);
            found = true;
        }
    }

    if (!found) {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching removed books found"));
    }
}

void MainWindow::on_btnRemove_category_clicked()
{
    LOG_CLICK("btnRemove_category_clicked");
    if (is_category_dto_empty(category_selected)) {
        QMessageBox::critical(this, tr("NO CATEGORY SELECTED"), tr("Please select a category from the list to remove!"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Remove category?"));
    box.setText(tr("Are you sure you want to remove category:\nName: %1")
        .arg(QString::fromStdString(category_selected.name)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    m_db.removeCategory(category_selected.id);
    last_category_removed = category_selected;

    // Remove from list by ID
    for (int i = 0; i < ui->lstSearch_category->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_category->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(category_selected.id)) {
            delete ui->lstSearch_category->takeItem(i);
            break;
        }
    }

    category_selected = DTO::CategoryDTO{};
    ui->txtName_category->clear();
    QMessageBox::information(this, tr("SUCCESS"), tr("Category removed"));
}

void MainWindow::on_btnEdit_category_clicked()
{
    LOG_CLICK("btnEdit_category_clicked");
    if (is_category_dto_empty(category_selected)) {
        QMessageBox::critical(this, tr("NO CATEGORY SELECTED"), tr("Please select a category from the list to edit!"));
        return;
    }

    QString name = ui->txtName_category->text().trimmed();
    if (is_qstring_empty(name)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Category name cannot be empty!"));
        return;
    }

    DTO::CategoryDTO updatedCat;
    updatedCat.id = category_selected.id;
    updatedCat.name = toStd(name);

    auto result = BusinessLogic::updateCategory(m_db, updatedCat);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    last_category_edited = category_selected;

    // Update list item by ID
    for (int i = 0; i < ui->lstSearch_category->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_category->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(category_selected.id)) {
            item->setText(name);
            break;
        }
    }

    category_selected = updatedCat;

    QMessageBox::information(this, tr("SUCCESS"), tr("Category edited"));
}

void MainWindow::on_btnAdd_category_clicked()
{
    LOG_CLICK("btnAdd_category_clicked");
    QString name = ui->txtName_category->text().trimmed();
    if (is_qstring_empty(name)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Category name cannot be empty!"));
        return;
    }

    DTO::CategoryDTO cat;
    cat.name = toStd(name);
    cat.id = std::to_string(std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::system_clock::now().time_since_epoch()).count());

    auto result = BusinessLogic::addCategory(m_db, cat);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    last_category_added = cat;

    auto* listItem = new QListWidgetItem(name);
    listItem->setData(Qt::UserRole, QString::fromStdString(cat.id));
    ui->lstSearch_category->addItem(listItem);
    ui->txtName_category->clear();

    QMessageBox::information(this, tr("SUCCESS"), tr("Category added"));
}

void MainWindow::on_btnUndoAdd_category_clicked()
{
    LOG_CLICK("btnUndoAdd_category_clicked");
    if (is_category_dto_empty(last_category_added)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent add to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo add?"));
    box.setText(tr("Undo adding category:\nName: %1")
        .arg(QString::fromStdString(last_category_added.name)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    m_db.removeCategory(last_category_added.id);

    // Remove from list by ID
    for (int i = 0; i < ui->lstSearch_category->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_category->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(last_category_added.id)) {
            delete ui->lstSearch_category->takeItem(i);
            break;
        }
    }

    last_category_added = DTO::CategoryDTO{};
    QMessageBox::information(this, tr("UNDO ADD"), tr("Category add undone"));
}

void MainWindow::on_btnUndoEdit_category_clicked()
{
    LOG_CLICK("btnUndoEdit_category_clicked");
    if (is_category_dto_empty(last_category_edited)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent edit to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo edit?"));
    box.setText(tr("Undo editing category:\nName: %1")
        .arg(QString::fromStdString(last_category_edited.name)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    auto result = BusinessLogic::updateCategory(m_db, last_category_edited);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    // Update list item back by ID
    for (int i = 0; i < ui->lstSearch_category->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_category->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(category_selected.id)) {
            item->setText(QString::fromStdString(last_category_edited.name));
            break;
        }
    }

    last_category_edited = DTO::CategoryDTO{};
    QMessageBox::information(this, tr("UNDO EDIT"), tr("Category edit undone"));
}

void MainWindow::on_btnUndoRemove_category_clicked()
{
    LOG_CLICK("btnUndoRemove_category_clicked");
    if (is_category_dto_empty(last_category_removed)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent remove to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo remove?"));
    box.setText(tr("Undo removing category:\nName: %1")
        .arg(QString::fromStdString(last_category_removed.name)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    auto result = BusinessLogic::addCategory(m_db, last_category_removed);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    auto* listItem = new QListWidgetItem(QString::fromStdString(last_category_removed.name));
    listItem->setData(Qt::UserRole, QString::fromStdString(last_category_removed.id));
    ui->lstSearch_category->addItem(listItem);
    last_category_removed = DTO::CategoryDTO{};
    QMessageBox::information(this, tr("UNDO REMOVE"), tr("Category remove undone"));
}

void MainWindow::on_btnUndoAdd_book_clicked()
{
    LOG_CLICK("btnUndoAdd_book_clicked");
    if (is_book_dto_empty(last_book_added)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent add to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo add?"));
    box.setText(tr("Undo adding book:\nTitle: %1\nAuthor: %2")
        .arg(QString::fromStdString(last_book_added.title))
        .arg(QString::fromStdString(last_book_added.author)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    m_db.removeBook(last_book_added.id);

    for (int i = 0; i < ui->lstSearch_book_edit->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_book_edit->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(last_book_added.id)) {
            delete ui->lstSearch_book_edit->takeItem(i);
            break;
        }
    }

    last_book_added = DTO::BookDTO{};
    QMessageBox::information(this, tr("UNDO ADD"), tr("Book add undone"));
}

void MainWindow::on_lstSearch_book_remove_itemClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_book_remove_itemClicked");
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 6)
    {
        ui->txtTitle_book_remove->setText(parts[0].trimmed());
        ui->txtAuthor_book_remove->setText(parts[1].trimmed());
        ui->cboLocation_book_remove->setCurrentText(parts[2].trimmed());
        ui->cboCategory_book_remove->setCurrentText(parts[3].trimmed());
        QString id_part = parts[5];
        if (id_part.startsWith("ID: "))
            id_part = id_part.mid(4);
        ui->txtId_book_remove->setText(id_part.trimmed());

        book_selected.title = toStd(parts[0].trimmed());
        book_selected.author = toStd(parts[1].trimmed());
        book_selected.location = toStd(parts[2].trimmed());
        book_selected.category = toStd(parts[3].trimmed());
        book_selected.status = toStd(parts[4].trimmed());
        book_selected.id = id_part.trimmed().toStdString();
    }
}

void MainWindow::on_lstSearch_undobooks_itemClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_undobooks_itemClicked");
    QString text = item->text();
    last_book_undone = DTO::BookDTO{};
    QStringList parts = text.split(" | ");
    if (parts.size() >= 6)
    {
        last_book_undone.title = toStd(parts[0].trimmed());
        last_book_undone.author = toStd(parts[1].trimmed());
        last_book_undone.location = toStd(parts[2].trimmed());
        last_book_undone.category = toStd(parts[3].trimmed());
        last_book_undone.status = toStd(parts[4].trimmed());
        QString id_part = parts[5];
        if (id_part.startsWith("ID: "))
            id_part = id_part.mid(4);
        last_book_undone.id = id_part.trimmed().toStdString();
    }
}

void MainWindow::on_lstSearch_category_itemClicked(QListWidgetItem *item)
{
    LOG_CLICK("lstSearch_category_itemClicked");
    ui->txtName_category->setText(item->text().trimmed());
    category_selected.name = toStd(item->text().trimmed());
    category_selected.id = toStd(item->data(Qt::UserRole).toString());
}

void MainWindow::on_btnEdit_book_clicked()
{
    LOG_CLICK("btnEdit_book_clicked");
    if (is_book_dto_empty(book_selected)) {
        QMessageBox::critical(this, tr("NO BOOK SELECTED"), tr("Please select a book from the list to edit!"));
        return;
    }

    QString title = ui->txtTitle_book_edit->text().trimmed();
    QString author = ui->txtAuthor_book_edit->text().trimmed();
    QString id = ui->txtId_book_edit->text().trimmed();
    QString location = ui->cboLocation_book_edit->currentText();
    QString category = ui->cboCategory_book_edit->currentText();
    QString status = ui->cboStatus_book_edit->currentText();

    if (is_qstring_empty(title)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Title cannot be empty!"));
        return;
    }
    if (is_qstring_empty(author)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Author cannot be empty!"));
        return;
    }

    DTO::BookDTO updatedBook;
    updatedBook.id = toStd(id);
    updatedBook.title = toStd(title);
    updatedBook.author = toStd(author);
    updatedBook.location = toStd(location);
    updatedBook.category = toStd(category);
    updatedBook.status = toStd(status);

    auto result = BusinessLogic::updateBook(m_db, updatedBook);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    last_book_edited = book_selected;

    m_worklog.logEntry(WorklogEntry::ActionType::Edit, WorklogEntry::EntityType::Book,
        book_selected.id, "Title: " + updatedBook.title + " | Author: " + updatedBook.author);

    for (int i = 0; i < ui->lstSearch_book_edit->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_book_edit->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(book_selected.id)) {
            item->setText(QString::fromStdString(updatedBook.toDisplayString()));
            break;
        }
    }

    book_selected = updatedBook;
    QMessageBox::information(this, tr("SUCCESS"), tr("Book edited"));
}

void MainWindow::on_btnUndoEdit_book_clicked()
{
    LOG_CLICK("btnUndoEdit_book_clicked");
    if (is_book_dto_empty(last_book_edited)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent edit to undo"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo edit?"));
    box.setText(tr("Undo editing book:\nTitle: %1\nAuthor: %2")
        .arg(QString::fromStdString(last_book_edited.title))
        .arg(QString::fromStdString(last_book_edited.author)));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    auto result = BusinessLogic::updateBook(m_db, last_book_edited);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    for (int i = 0; i < ui->lstSearch_book_edit->count(); ++i) {
        QListWidgetItem *item = ui->lstSearch_book_edit->item(i);
        if (item->data(Qt::UserRole).toString() == QString::fromStdString(book_selected.id)) {
            item->setText(QString::fromStdString(last_book_edited.toDisplayString()));
            break;
        }
    }

    last_book_edited = DTO::BookDTO{};
    QMessageBox::information(this, tr("UNDO EDIT"), tr("Book edit undone"));
}

void MainWindow::on_btnAdd_book_clicked()
{
    LOG_CLICK("btnAdd_book_clicked");
    QString title = ui->txtTitle_book->text().trimmed();
    QString author = ui->txtAuthor_book->text().trimmed();
    QString id = ui->txtId_book->text().trimmed();
    QString location = ui->cboLocation_book->currentText();
    QString category = ui->cboCategory_book->currentText();
    QString status = ui->cboStatus_book->currentText();

    if (is_qstring_empty(title)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Title cannot be empty!"));
        return;
    }
    if (is_qstring_empty(author)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Author cannot be empty!"));
        return;
    }
    if (is_qstring_empty(id)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("ID cannot be empty!"));
        return;
    }

    DTO::BookDTO book;
    book.id = toStd(id);
    book.title = toStd(title);
    book.author = toStd(author);
    book.location = toStd(location);
    book.category = toStd(category);
    book.status = toStd(status);

    auto result = BusinessLogic::addBook(m_db, book);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("ERROR"), QString::fromStdString(result.errorMessage));
        return;
    }

    last_book_added = book;

    m_worklog.logEntry(WorklogEntry::ActionType::Add, WorklogEntry::EntityType::Book,
        book.id, "Title: " + book.title + " | Author: " + book.author);

    auto* listItem = new QListWidgetItem(QString::fromStdString(book.toDisplayString()));
    listItem->setData(Qt::UserRole, QString::fromStdString(book.id));
    ui->lstSearch_book_edit->addItem(listItem);

    ui->txtTitle_book->clear();
    ui->txtAuthor_book->clear();
    ui->txtId_book->clear();

    QMessageBox::information(this, tr("SUCCESS"), tr("Book added"));
}

void MainWindow::on_btnCheckId_book_clicked()
{
    LOG_CLICK("btnCheckId_book_clicked");
    QString id = ui->txtId_book->text().trimmed();
    if (is_qstring_empty(id)) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Please enter a book ID to check!"));
        return;
    }

    auto book = m_db.getBookById(toStd(id));
    if (book.has_value()) {
        QMessageBox::warning(this, tr("ID EXISTS"), tr("Book ID %1 already exists:\nTitle: %2\nAuthor: %3")
            .arg(id)
            .arg(QString::fromStdString(book->title))
            .arg(QString::fromStdString(book->author)));
    } else {
        QMessageBox::information(this, tr("ID AVAILABLE"), tr("Book ID %1 is available").arg(id));
    }
}

void MainWindow::on_txtId_book_textChanged(const QString &text)
{
    LOG_CLICK("txtId_book_textChanged");
    if (!ui->chkAutoCheckId_book->isChecked()) return;

    QString id = text.trimmed();
    if (is_qstring_empty(id)) return;

    auto book = m_db.getBookById(toStd(id));
    if (book.has_value()) {
        ui->txtId_book->setStyleSheet("QLineEdit { background-color: #ffcccc; }");
        ui->txtId_book->setToolTip(QString("ID EXISTS - Title: %1, Author: %2")
            .arg(QString::fromStdString(book->title))
            .arg(QString::fromStdString(book->author)));
    } else {
        ui->txtId_book->setStyleSheet("QLineEdit { background-color: #ccffcc; }");
        ui->txtId_book->setToolTip("ID is available");
    }
}

void MainWindow::on_chkAutogenerateID_book_toggled(bool checked)
{
    Q_UNUSED(checked);
}

void MainWindow::on_txtPwd1_register_textChanged(const QString &text)
{
    LOG_CLICK("txtPwd1_register_textChanged");
    int score = 0;
    QString password = text;

    // Length scoring
    if (password.length() >= 8) score += 20;
    if (password.length() >= 12) score += 10;
    if (password.length() >= 16) score += 10;

    // Character type scoring
    if (password.contains(QRegularExpression("[a-z]"))) score += 15;
    if (password.contains(QRegularExpression("[A-Z]"))) score += 15;
    if (password.contains(QRegularExpression("[0-9]"))) score += 15;
    if (password.contains(QRegularExpression("[^a-zA-Z0-9]"))) score += 15;

    // Cap at 100
    if (score > 100) score = 100;

    qDebug() << "[PASSWORD STRENGTH] text:" << text << "score:" << score;

    ui->barPasswordStrenght_register->setRange(0, 100);
    ui->barPasswordStrenght_register->setValue(score);

    // Color the bar based on strength
    if (score < 30) {
        ui->barPasswordStrenght_register->setStyleSheet("QProgressBar::chunk { background-color: red; }");
    } else if (score < 60) {
        ui->barPasswordStrenght_register->setStyleSheet("QProgressBar::chunk { background-color: orange; }");
    } else if (score < 80) {
        ui->barPasswordStrenght_register->setStyleSheet("QProgressBar::chunk { background-color: yellow; }");
    } else {
        ui->barPasswordStrenght_register->setStyleSheet("QProgressBar::chunk { background-color: green; }");
    }
}

// ============ NEW MENU ACTION HANDLERS ============

// --- Make Report ---
void MainWindow::on_actionMake_Report_triggered()
{
    LOG_CLICK("actionMake_Report_triggered");
    if (!checkLoginRequired()) return;

    auto result = BusinessLogic::validateDatabases(m_db);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
        return;
    }

    ui->cboReportType->clear();
    ui->cboReportType->addItems({"All Loans", "Active Loans", "Overdue Loans", "Returned Loans", "Loans by Reader"});
    ui->cboReportStatus->clear();
    ui->cboReportStatus->addItems({"All", "Active", "Returned", "Overdue"});
    ui->txtReportOutput->clear();
    ui->workspaces->setCurrentIndex(17);
}

void MainWindow::on_btnGenerateReport_clicked()
{
    LOG_CLICK("btnGenerateReport_clicked");
    QString reportType = ui->cboReportType->currentText();
    std::string statusFilter = ui->cboReportStatus->currentText().toStdString();

    std::vector<Domain::Loan> loans;
    if (reportType == "All Loans") {
        loans = m_db.getAllLoans();
    } else if (reportType == "Active Loans") {
        loans = m_db.getActiveLoans();
    } else if (reportType == "Overdue Loans") {
        loans = m_db.getOverdueLoans();
    } else if (reportType == "Returned Loans") {
        auto all = m_db.getAllLoans();
        for (const auto& l : all) {
            if (l.status == "returned") loans.push_back(l);
        }
    } else if (reportType == "Loans by Reader") {
        bool ok;
        QString readerId = QInputDialog::getText(this, tr("Reader ID"), tr("Enter Reader ID:"), QLineEdit::Normal, "", &ok);
        if (!ok || readerId.isEmpty()) return;
        loans = m_db.getLoansForReader(toStd(readerId));
    }

    if (statusFilter != "All" && reportType == "All Loans") {
        std::vector<Domain::Loan> filtered;
        for (const auto& l : loans) {
            if (l.status == statusFilter) filtered.push_back(l);
        }
        loans = filtered;
    }

    QString report;
    report += "=== LOAN REPORT ===\n";
    report += "Type: " + reportType + "\n";
    report += "Generated: " + QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss") + "\n";
    report += "Total loans: " + QString::number(loans.size()) + "\n";
    report += "===================\n\n";

    int active = 0, returned = 0, overdue = 0;
    for (const auto& l : loans) {
        if (l.status == "active") active++;
        else if (l.status == "returned") returned++;
        else if (l.status == "overdue") overdue++;
    }
    report += "Active: " + QString::number(active) + " | Returned: " + QString::number(returned) + " | Overdue: " + QString::number(overdue) + "\n\n";

    for (const auto& l : loans) {
        report += QString::fromStdString(l.toDisplayString()) + "\n";
    }

    ui->txtReportOutput->setText(report);
}

void MainWindow::on_btnExportReport_clicked()
{
    LOG_CLICK("btnExportReport_clicked");
    QString content = ui->txtReportOutput->toPlainText();
    if (content.isEmpty()) {
        QMessageBox::critical(this, tr("NO REPORT"), tr("Generate a report first"));
        return;
    }

    QString filePath = QFileDialog::getSaveFileName(this, tr("Export Report"), "loan_report.txt", "Text Files (*.txt);;All Files (*)");
    if (filePath.isEmpty()) return;

    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        stream << content;
        file.close();
        QMessageBox::information(this, tr("SUCCESS"), tr("Report exported to %1").arg(filePath));
    } else {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to export report"));
    }
}

// --- Manage Fines ---
void MainWindow::on_actionManage_Fines_triggered()
{
    LOG_CLICK("actionManage_Fines_triggered");
    if (!checkLoginRequired()) return;

    auto result = BusinessLogic::validateDatabases(m_db);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
        return;
    }

    ui->txtFinesReaderId->clear();
    ui->lstFines->clear();
    ui->spnFinesAmount->setValue(0);
    ui->label_fines_total->setText("Total Unpaid: $0.00");
    ui->workspaces->setCurrentIndex(18);
}

void MainWindow::on_btnSearchFines_clicked()
{
    LOG_CLICK("btnSearchFines_clicked");
    QString readerId = ui->txtFinesReaderId->text().trimmed();
    if (readerId.isEmpty()) {
        QMessageBox::critical(this, tr("EMPTY"), tr("Please enter a Reader ID"));
        return;
    }

    auto loans = m_db.getLoansForReader(toStd(readerId));
    ui->lstFines->clear();

    double totalUnpaid = 0;
    for (const auto& loan : loans) {
        if (loan.status == "overdue" || (!Domain::isNull(loan.returnDate) && loan.returnDate > loan.dueDate)) {
            auto overdueMs = std::chrono::duration_cast<std::chrono::milliseconds>(loan.returnDate - loan.dueDate).count();
            double daysOverdue = overdueMs / (1000.0 * 60 * 60 * 24);
            double fine = daysOverdue * 0.50;
            totalUnpaid += fine;

            QString text = QString("Loan: %1 | Book: %2 | Due: %3 | Return: %4 | Overdue: %5 days | Fine: $%6")
                .arg(QString::fromStdString(loan.id))
                .arg(QString::fromStdString(loan.bookId))
                .arg(QString::fromStdString(Domain::toISOString(loan.dueDate)))
                .arg(Domain::isNull(loan.returnDate) ? "N/A" : QString::fromStdString(Domain::toISOString(loan.returnDate)))
                .arg(daysOverdue, 0, 'f', 1)
                .arg(fine, 0, 'f', 2);

            auto* item = new QListWidgetItem(text);
            item->setData(Qt::UserRole, QString::fromStdString(loan.id));
            item->setData(Qt::UserRole + 1, fine);
            ui->lstFines->addItem(item);
        }
    }

    ui->label_fines_total->setText(QString("Total Unpaid: $%1").arg(totalUnpaid, 0, 'f', 2));
}

void MainWindow::on_btnAddFine_clicked()
{
    LOG_CLICK("btnAddFine_clicked");
    QListWidgetItem* item = ui->lstFines->currentItem();
    if (!item) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Select a loan to add a fine to"));
        return;
    }

    double amount = ui->spnFinesAmount->value();
    if (amount <= 0) {
        QMessageBox::critical(this, tr("INVALID AMOUNT"), tr("Fine amount must be greater than 0"));
        return;
    }

    QMessageBox::information(this, tr("SUCCESS"), tr("Fine of $%1 added to loan %2").arg(amount, 0, 'f', 2).arg(item->text().split("|").first().trimmed()));
}

void MainWindow::on_btnPayFine_clicked()
{
    LOG_CLICK("btnPayFine_clicked");
    QListWidgetItem* item = ui->lstFines->currentItem();
    if (!item) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Select a fine to mark as paid"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Mark Fine as Paid?"));
    box.setText(tr("Are you sure you want to mark this fine as paid?"));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    double fine = item->data(Qt::UserRole + 1).toDouble();
    int row = ui->lstFines->row(item);
    delete ui->lstFines->takeItem(row);
    QMessageBox::information(this, tr("SUCCESS"), tr("Fine of $%1 marked as paid").arg(fine, 0, 'f', 2));
}

// --- Make Card ---
void MainWindow::on_actionMake_Card_triggered()
{
    LOG_CLICK("actionMake_Card_triggered");
    if (!checkLoginRequired()) return;

    auto result = BusinessLogic::validateDatabases(m_db);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
        return;
    }

    ui->txtCardSearch->clear();
    ui->lstCardReaders->clear();
    ui->txtCardPreview->clear();
    ui->workspaces->setCurrentIndex(19);
}

void MainWindow::on_btnSearchCard_clicked()
{
    LOG_CLICK("btnSearchCard_clicked");
    QString term = ui->txtCardSearch->text().trimmed();
    if (term.isEmpty()) {
        QMessageBox::critical(this, tr("EMPTY"), tr("Please enter a search term"));
        return;
    }

    auto readers = m_db.searchReaders(toStd(term), "name");
    auto surnames = m_db.searchReaders(toStd(term), "surname");
    for (const auto& r : surnames) {
        bool found = false;
        for (const auto& existing : readers) {
            if (existing.id == r.id) { found = true; break; }
        }
        if (!found) readers.push_back(r);
    }

    ui->lstCardReaders->clear();
    for (const auto& reader : readers) {
        auto* item = new QListWidgetItem(QString::fromStdString(reader.name + " " + reader.surname + " | ID: " + reader.studentId));
        item->setData(Qt::UserRole, QString::fromStdString(reader.id));
        ui->lstCardReaders->addItem(item);
    }
}

void MainWindow::on_btnPreviewCard_clicked()
{
    LOG_CLICK("btnPreviewCard_clicked");
    QListWidgetItem* item = ui->lstCardReaders->currentItem();
    if (!item) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Select a reader to preview their card"));
        return;
    }

    QString id = item->data(Qt::UserRole).toString();
    auto reader = m_db.getReaderById(toStd(id));
    if (!reader) {
        QMessageBox::critical(this, tr("ERROR"), tr("Reader not found"));
        return;
    }

    QString card;
    card += "╔══════════════════════════════════════╗\n";
    card += "║        LIBRARY MEMBER CARD           ║\n";
    card += "╠══════════════════════════════════════╣\n";
    card += "║ Name:    " + QString::fromStdString(reader->name) + " " + QString::fromStdString(reader->surname) + "\n";
    card += "║ ID:      " + QString::fromStdString(reader->studentId) + "\n";
    card += "║ Grade:   " + QString::number(reader->grade) + "\n";
    card += "║ Class:   " + QString(reader->classGroup) + "\n";
    card += "║ System ID: " + QString::fromStdString(reader->id) + "\n";
    card += "╚══════════════════════════════════════╝\n";

    ui->txtCardPreview->setText(card);
}

void MainWindow::on_btnPrintCard_clicked()
{
    LOG_CLICK("btnPrintCard_clicked");
    QString content = ui->txtCardPreview->toPlainText();
    if (content.isEmpty()) {
        QMessageBox::critical(this, tr("NO CARD"), tr("Preview a card first"));
        return;
    }

    QString filePath = QFileDialog::getSaveFileName(this, tr("Save Card"), "library_card.txt", "Text Files (*.txt);;All Files (*)");
    if (filePath.isEmpty()) return;

    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        stream << content;
        file.close();
        QMessageBox::information(this, tr("SUCCESS"), tr("Card saved to %1").arg(filePath));
    } else {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to save card"));
    }
}

// --- Backups ---
void MainWindow::on_actionBackups_triggered()
{
    LOG_CLICK("actionBackups_triggered");
    if (!checkLoginRequired()) return;

    auto result = BusinessLogic::validateDatabases(m_db);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
        return;
    }

    QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
    ui->chkAutoBackup->setChecked(settings.value("backup/auto", false).toBool());
    ui->txtBackupDir->setText(settings.value("backup/dir", "").toString());

    ui->cboBackupInterval->clear();
    ui->cboBackupInterval->addItems({"Every day", "Every week", "Every month"});

    ui->lstBackups->clear();
    QString backupDir = ui->txtBackupDir->text();
    if (!backupDir.isEmpty()) {
        QDir dir(backupDir);
        QStringList filters;
        filters << "*.db.bak" << "*.backup";
        QFileInfoList files = dir.entryInfoList(filters, QDir::Files, QDir::Time);
        for (const auto& f : files) {
            ui->lstBackups->addItem(f.fileName() + " (" + f.lastModified().toString("yyyy-MM-dd hh:mm:ss") + ")");
        }
    }

    ui->workspaces->setCurrentIndex(20);
}

void MainWindow::on_btnBackupNow_clicked()
{
    LOG_CLICK("btnBackupNow_clicked");
    QString backupDir = ui->txtBackupDir->text();
    if (backupDir.isEmpty()) {
        backupDir = QFileDialog::getExistingDirectory(this, tr("Select Backup Directory"));
        if (backupDir.isEmpty()) return;
        ui->txtBackupDir->setText(backupDir);
    }

    QDir dir(backupDir);
    if (!dir.exists()) {
        dir.mkpath(".");
    }

    QString timestamp = QDateTime::currentDateTime().toString("yyyyMMdd_hhmmss");
    QStringList dbs = {database_books, database_readers, database_loans};
    QStringList names = {"books", "readers", "loans"};

    int success = 0;
    for (int i = 0; i < dbs.size(); i++) {
        if (dbs[i].isEmpty()) continue;
        QString dest = backupDir + "/" + names[i] + "_" + timestamp + ".db.bak";
        if (QFile::copy(dbs[i], dest)) success++;
    }

    QMessageBox::information(this, tr("BACKUP"), tr("Backed up %1 of %2 databases to %3").arg(success).arg(dbs.size()).arg(backupDir));
}

void MainWindow::on_btnRestoreBackup_clicked()
{
    LOG_CLICK("btnRestoreBackup_clicked");
    QString backupDir = ui->txtBackupDir->text();
    if (backupDir.isEmpty()) {
        QMessageBox::critical(this, tr("NO DIRECTORY"), tr("Set a backup directory first"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Restore Backup?"));
    box.setText(tr("This will overwrite current databases. Are you sure?"));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    QStringList dbs = {database_books, database_readers, database_loans};
    QStringList names = {"books", "readers", "loans"};

    int restored = 0;
    for (int i = 0; i < dbs.size(); i++) {
        if (dbs[i].isEmpty()) continue;
        QDir dir(backupDir);
        QStringList filters;
        filters << names[i] + "_*.db.bak";
        QFileInfoList files = dir.entryInfoList(filters, QDir::Files, QDir::Time);
        if (!files.isEmpty()) {
            if (QFile::remove(dbs[i])) {
                if (QFile::copy(files.first().filePath(), dbs[i])) restored++;
            }
        }
    }

    QMessageBox::information(this, tr("RESTORE"), tr("Restored %1 of %2 databases").arg(restored).arg(dbs.size()));
}

void MainWindow::on_btnBrowseBackupDir_clicked()
{
    LOG_CLICK("btnBrowseBackupDir_clicked");
    QString dir = QFileDialog::getExistingDirectory(this, tr("Select Backup Directory"));
    if (!dir.isEmpty()) {
        ui->txtBackupDir->setText(dir);
    }
}

// --- Preferences ---
void MainWindow::on_actionPreferences_triggered()
{
    LOG_CLICK("actionPreferences_triggered");

    QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
    ui->chkDarkMode->setChecked(settings.value("prefs/darkMode", false).toBool());
    ui->chkShowWelcome->setChecked(settings.value("prefs/showWelcome", true).toBool());
    ui->chkConfirmActions->setChecked(settings.value("prefs/confirmActions", true).toBool());

    ui->cboLanguage->clear();
    ui->cboLanguage->addItems({"English", "Polski", "Deutsch", "Francais", "Espanol"});
    QString lang = settings.value("prefs/language", "English").toString();
    int langIdx = ui->cboLanguage->findText(lang);
    if (langIdx >= 0) ui->cboLanguage->setCurrentIndex(langIdx);

    ui->spnFontSize->setValue(settings.value("prefs/fontSize", 10).toInt());

    bool worklogEnabled = settings.value("worklog/enabled", false).toBool();
    ui->chkWorklog->setChecked(worklogEnabled);

    ui->workspaces->setCurrentIndex(21);
}

void MainWindow::on_btnSavePreferences_clicked()
{
    LOG_CLICK("btnSavePreferences_clicked");
    QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
    settings.setValue("prefs/darkMode", ui->chkDarkMode->isChecked());
    settings.setValue("prefs/showWelcome", ui->chkShowWelcome->isChecked());
    settings.setValue("prefs/confirmActions", ui->chkConfirmActions->isChecked());
    settings.setValue("prefs/language", ui->cboLanguage->currentText());
    settings.setValue("prefs/fontSize", ui->spnFontSize->value());
    QMessageBox::information(this, tr("SUCCESS"), tr("Preferences saved"));
}

void MainWindow::on_btnResetPreferences_clicked()
{
    LOG_CLICK("btnResetPreferences_clicked");
    ui->chkDarkMode->setChecked(false);
    ui->chkShowWelcome->setChecked(true);
    ui->chkConfirmActions->setChecked(true);
    ui->cboLanguage->setCurrentIndex(0);
    ui->spnFontSize->setValue(10);
    ui->chkWorklog->setChecked(false);
}

void MainWindow::on_chkWorklog_toggled(bool checked)
{
    LOG_CLICK("chkWorklog_toggled");
    QSettings settings(QCoreApplication::applicationDirPath() + "/DatabaseConfigs.ini", QSettings::IniFormat);
    settings.setValue("worklog/enabled", checked);
    m_worklog.setEnabled(checked);

    if (checked) {
        m_worklogFilePath = QCoreApplication::applicationDirPath() + "/" + Worklog::generateSessionFileName();
        m_worklog.setLogFile(m_worklogFilePath);
        ui->label_worklog_path->setText("Worklog file: " + m_worklogFilePath);
        ui->label_worklog_path->setStyleSheet("color: black;");
        LOG_INFO("Worklog enabled");
    } else {
        m_worklog.close();
        m_worklogFilePath.clear();
        ui->label_worklog_path->setText("Worklog file: (worklog disabled)");
        ui->label_worklog_path->setStyleSheet("color: gray;");
    }
}

// --- Accounts ---
void MainWindow::on_actionAccounts_triggered()
{
    LOG_CLICK("actionAccounts_triggered");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    ui->txtAccountSearch->clear();
    ui->lstAccounts->clear();
    ui->txtAccountUsername->clear();

    ui->cboAccountRole->clear();
    ui->cboAccountRole->addItems({"User", "Admin", "SuperAdmin"});

    auto users = m_db.getAllUsers();
    for (const auto& user : users) {
        QString roleStr;
        switch (user.role) {
            case Domain::User::Role::UserRole: roleStr = "User"; break;
            case Domain::User::Role::Admin: roleStr = "Admin"; break;
            case Domain::User::Role::SuperAdmin: roleStr = "SuperAdmin"; break;
        }
        auto* item = new QListWidgetItem(QString::fromStdString(user.username) + " | Role: " + roleStr);
        item->setData(Qt::UserRole, QString::fromStdString(user.username));
        ui->lstAccounts->addItem(item);
    }

    ui->workspaces->setCurrentIndex(22);
}

void MainWindow::on_btnSearchAccount_clicked()
{
    LOG_CLICK("btnSearchAccount_clicked");
    QString term = ui->txtAccountSearch->text().trimmed();
    if (term.isEmpty()) {
        QMessageBox::critical(this, tr("EMPTY"), tr("Please enter a search term"));
        return;
    }

    auto users = m_db.getAllUsers();
    ui->lstAccounts->clear();
    for (const auto& user : users) {
        if (QString::fromStdString(user.username).contains(term, Qt::CaseInsensitive)) {
            QString roleStr;
            switch (user.role) {
                case Domain::User::Role::UserRole: roleStr = "User"; break;
                case Domain::User::Role::Admin: roleStr = "Admin"; break;
                case Domain::User::Role::SuperAdmin: roleStr = "SuperAdmin"; break;
            }
            auto* item = new QListWidgetItem(QString::fromStdString(user.username) + " | Role: " + roleStr);
            item->setData(Qt::UserRole, QString::fromStdString(user.username));
            ui->lstAccounts->addItem(item);
        }
    }
}

void MainWindow::on_btnChangeRole_clicked()
{
    LOG_CLICK("btnChangeRole_clicked");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::SuperAdmin)) return;

    QListWidgetItem* item = ui->lstAccounts->currentItem();
    if (!item) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Select an account to modify"));
        return;
    }

    QString username = item->data(Qt::UserRole).toString();
    if (m_currentUser && m_currentUser->username == toStd(username)) {
        QMessageBox::critical(this, tr("ERROR"), tr("Cannot change your own role"));
        return;
    }

    auto user = m_db.getUserByUsername(toStd(username));
    if (!user) {
        QMessageBox::critical(this, tr("ERROR"), tr("User not found"));
        return;
    }

    QString roleStr = ui->cboAccountRole->currentText();
    Domain::User::Role newRole;
    if (roleStr == "Admin") newRole = Domain::User::Role::Admin;
    else if (roleStr == "SuperAdmin") newRole = Domain::User::Role::SuperAdmin;
    else newRole = Domain::User::Role::UserRole;

    user->role = newRole;
    if (m_db.updateUser(*user)) {
        QMessageBox::information(this, tr("SUCCESS"), tr("Role updated for %1").arg(username));
        on_actionAccounts_triggered();
    } else {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to update role"));
    }
}

void MainWindow::on_btnDeleteAccount_clicked()
{
    LOG_CLICK("btnDeleteAccount_clicked");
    QListWidgetItem* item = ui->lstAccounts->currentItem();
    if (!item) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Select an account to delete"));
        return;
    }

    QString username = item->data(Qt::UserRole).toString();
    if (m_currentUser && m_currentUser->username == toStd(username)) {
        QMessageBox::critical(this, tr("ERROR"), tr("Cannot delete your own account"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("DELETE ACCOUNT"));
    box.setText(tr("Are you sure you want to delete account '%1'?").arg(username));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() != QMessageBox::Yes) return;

    QMessageBox::information(this, tr("INFO"), tr("Account deletion is not yet supported via the UI. Use the database directly."));
}

// --- Troubleshoot ---
void MainWindow::on_actionTroubleshoot_triggered()
{
    LOG_CLICK("actionTroubleshoot_triggered");

    ui->txtTroubleshootOutput->clear();
    ui->workspaces->setCurrentIndex(23);
}

void MainWindow::on_btnTestDbConnection_clicked()
{
    LOG_CLICK("btnTestDbConnection_clicked");
    QString output;
    output += "=== Database Connection Test ===\n";

    if (m_db.isConnected()) {
        output += "Status: CONNECTED\n\n";

        auto books = m_db.getAllBooks();
        output += "Books DB: " + QString::number(books.size()) + " records\n";

        auto readers = m_db.getAllReaders();
        output += "Readers DB: " + QString::number(readers.size()) + " records\n";

        auto loans = m_db.getAllLoans();
        output += "Loans DB: " + QString::number(loans.size()) + " records\n";

        auto users = m_db.getAllUsers();
        output += "Users DB: " + QString::number(users.size()) + " records\n";
    } else {
        output += "Status: DISCONNECTED\n";
    }

    output += "\n=== Test Complete ===\n";
    ui->txtTroubleshootOutput->setText(output);
}

void MainWindow::on_btnCheckDbIntegrity_clicked()
{
    LOG_CLICK("btnCheckDbIntegrity_clicked");
    QString output;
    output += "=== Database Integrity Check ===\n\n";

    if (!database_books.isEmpty()) {
        output += "Books DB path: " + database_books + "\n";
        output += "File exists: " + QString(QFile::exists(database_books) ? "YES" : "NO") + "\n";
        QFileInfo fi(database_books);
        output += "File size: " + QString::number(fi.size()) + " bytes\n\n";
    } else {
        output += "Books DB: NOT CONFIGURED\n\n";
    }

    if (!database_readers.isEmpty()) {
        output += "Readers DB path: " + database_readers + "\n";
        output += "File exists: " + QString(QFile::exists(database_readers) ? "YES" : "NO") + "\n";
        QFileInfo fi(database_readers);
        output += "File size: " + QString::number(fi.size()) + " bytes\n\n";
    } else {
        output += "Readers DB: NOT CONFIGURED\n\n";
    }

    if (!database_loans.isEmpty()) {
        output += "Loans DB path: " + database_loans + "\n";
        output += "File exists: " + QString(QFile::exists(database_loans) ? "YES" : "NO") + "\n";
        QFileInfo fi(database_loans);
        output += "File size: " + QString::number(fi.size()) + " bytes\n\n";
    } else {
        output += "Loans DB: NOT CONFIGURED\n\n";
    }

    output += "=== Check Complete ===\n";
    ui->txtTroubleshootOutput->setText(output);
}

void MainWindow::on_btnViewLogs_clicked()
{
    LOG_CLICK("btnViewLogs_clicked");
    QString logPath = QCoreApplication::applicationDirPath();
    QDir logDir(logPath);
    QStringList filters;
    filters << "telemetry_*.log";
    QFileInfoList logs = logDir.entryInfoList(filters, QDir::Files, QDir::Time);

    QString output;
    output += "=== Telemetry Logs ===\n\n";
    if (logs.isEmpty()) {
        output += "No log files found in: " + logPath + "\n";
    } else {
        for (const auto& log : logs) {
            output += log.fileName() + " (" + QString::number(log.size()) + " bytes, " + log.lastModified().toString("yyyy-MM-dd hh:mm:ss") + ")\n";
        }
    }
    output += "\n=== End of Log List ===\n";
    ui->txtTroubleshootOutput->setText(output);
}

void MainWindow::on_btnExportDiagnostics_clicked()
{
    LOG_CLICK("btnExportDiagnostics_clicked");
    QString output = ui->txtTroubleshootOutput->toPlainText();
    if (output.isEmpty()) {
        QMessageBox::critical(this, tr("NO DATA"), tr("Run a diagnostic first"));
        return;
    }

    QString filePath = QFileDialog::getSaveFileName(this, tr("Export Diagnostics"), "diagnostics.txt", "Text Files (*.txt);;All Files (*)");
    if (filePath.isEmpty()) return;

    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        stream << output;
        file.close();
        QMessageBox::information(this, tr("SUCCESS"), tr("Diagnostics exported to %1").arg(filePath));
    } else {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to export diagnostics"));
    }
}

void MainWindow::on_btnCompactDatabases_clicked()
{
    LOG_CLICK("btnCompactDatabases_clicked");
    QMessageBox::information(this, tr("COMPACT"), tr("Database compaction is performed automatically during maintenance. No action needed."));
}

// --- Sort ---
void MainWindow::on_actionSort_triggered()
{
    LOG_CLICK("actionSort_triggered");
    if (!checkLoginRequired()) return;

    auto result = BusinessLogic::validateDatabases(m_db);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
        return;
    }

    QStringList options;
    options << "Sort Books by Title" << "Sort Books by Author" << "Sort Readers by Name" << "Sort Readers by Surname" << "Sort Loans by Date" << "Sort Loans by Due Date";
    bool ok;
    QString choice = QInputDialog::getItem(this, tr("Sort Database"), tr("Select sort order:"), options, 0, false, &ok);
    if (!ok) return;

    QString message;
    if (choice == "Sort Books by Title") message = "Books sorted by title";
    else if (choice == "Sort Books by Author") message = "Books sorted by author";
    else if (choice == "Sort Readers by Name") message = "Readers sorted by name";
    else if (choice == "Sort Readers by Surname") message = "Readers sorted by surname";
    else if (choice == "Sort Loans by Date") message = "Loans sorted by loan date";
    else if (choice == "Sort Loans by Due Date") message = "Loans sorted by due date";

    QMessageBox::information(this, tr("SORT"), message + ". Results will appear on their respective pages.");
}

// --- Duplicate Logout ---
void MainWindow::on_actionLog_out_2_triggered()
{
    LOG_CLICK("actionLog_out_2_triggered");
    on_actionLog_out_triggered();
}

// --- Worklog Stats ---
void MainWindow::on_actionWorklogStats_triggered()
{
    LOG_CLICK("actionWorklogStats_triggered");
    on_btnRefreshWorklog_clicked();
    ui->workspaces->setCurrentIndex(24);
}

void MainWindow::on_btnRefreshWorklog_clicked()
{
    LOG_CLICK("btnRefreshWorklog_clicked");

    int bookAdd = m_worklog.getBookAddCount();
    int bookEdit = m_worklog.getBookEditCount();
    int bookRemove = m_worklog.getBookRemoveCount();
    ui->label_wl_books_stats->setText(QString("Added: %1 | Edited: %2 | Removed: %3").arg(bookAdd).arg(bookEdit).arg(bookRemove));

    int readerAdd = m_worklog.getReaderAddCount();
    int readerEdit = m_worklog.getReaderEditCount();
    int readerRemove = m_worklog.getReaderRemoveCount();
    ui->label_wl_readers_stats->setText(QString("Added: %1 | Edited: %2 | Removed: %3").arg(readerAdd).arg(readerEdit).arg(readerRemove));

    int loanAdd = m_worklog.getLoanAddCount();
    int loanEdit = m_worklog.getLoanEditCount();
    int loanRemove = m_worklog.getLoanRemoveCount();
    ui->label_wl_loans_stats->setText(QString("Added: %1 | Edited: %2 | Removed: %3").arg(loanAdd).arg(loanEdit).arg(loanRemove));

    ui->lstWorklogEntries->clear();
    const auto& entries = m_worklog.getEntries();
    for (int i = entries.size() - 1; i >= 0; --i) {
        auto* item = new QListWidgetItem(entries[i].toLogString());
        ui->lstWorklogEntries->addItem(item);
    }
}

void MainWindow::on_btnExportWorklog_clicked()
{
    LOG_CLICK("btnExportWorklog_clicked");
    if (m_worklogFilePath.isEmpty()) {
        QMessageBox::critical(this, tr("NO WORKLOG"), tr("No active worklog session. Enable worklog in Preferences first."));
        return;
    }

    QString filePath = QFileDialog::getSaveFileName(this, tr("Export Worklog"), "worklog_export.txt", "Text Files (*.txt);;All Files (*)");
    if (filePath.isEmpty()) return;

    QFile file(filePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream stream(&file);
        stream << "=== Worklog Export ===\n";
        stream << "Session file: " << m_worklogFilePath << "\n\n";

        stream << "=== Statistics ===\n";
        stream << "Books   - Added: " << m_worklog.getBookAddCount() << " | Edited: " << m_worklog.getBookEditCount() << " | Removed: " << m_worklog.getBookRemoveCount() << "\n";
        stream << "Readers - Added: " << m_worklog.getReaderAddCount() << " | Edited: " << m_worklog.getReaderEditCount() << " | Removed: " << m_worklog.getReaderRemoveCount() << "\n";
        stream << "Loans   - Added: " << m_worklog.getLoanAddCount() << " | Edited: " << m_worklog.getLoanEditCount() << " | Removed: " << m_worklog.getLoanRemoveCount() << "\n\n";

        stream << "=== All Entries ===\n";
        const auto& entries = m_worklog.getEntries();
        for (const auto& entry : entries) {
            stream << entry.toLogString() << "\n";
        }

        file.close();
        QMessageBox::information(this, tr("SUCCESS"), tr("Worklog exported to %1").arg(filePath));
    } else {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to export worklog"));
    }
}

// --- Password Change (SuperAdmin only) ---
void MainWindow::on_btnChangePassword_clicked()
{
    LOG_CLICK("btnChangePassword_clicked");
    if (!checkRoleRequired(BusinessLogic::RequiredRole::SuperAdmin)) return;

    QListWidgetItem* item = ui->lstAccounts->currentItem();
    if (!item) {
        QMessageBox::critical(this, tr("NO SELECTION"), tr("Select an account to change password"));
        return;
    }

    QString username = item->data(Qt::UserRole).toString();
    QString newPwd = ui->txtAccountNewPassword->text();

    if (newPwd.isEmpty()) {
        QMessageBox::critical(this, tr("EMPTY"), tr("Please enter a new password"));
        return;
    }
    if (newPwd.length() < 8) {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Password must be at least 8 characters"));
        return;
    }

    auto user = m_db.getUserByUsername(toStd(username));
    if (!user) {
        QMessageBox::critical(this, tr("ERROR"), tr("User not found"));
        return;
    }

    user->passwordHash = hash_string(newPwd.toStdString());
    user->salt = "";

    if (m_db.updateUser(*user)) {
        ui->txtAccountNewPassword->clear();
        QMessageBox::information(this, tr("SUCCESS"), tr("Password updated for %1").arg(username));
    } else {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to update password"));
    }
}

// --- Networking / P2P / Update / Crypto (placeholder stubs) ---
void MainWindow::on_actionNetworking_triggered()
{
    LOG_CLICK("actionNetworking_triggered");
    QMessageBox::information(this, tr("NETWORKING"), tr("Networking features are planned for a future release. Currently, ShelfSight operates in offline mode only."));
}

void MainWindow::on_actionOnline_local_triggered()
{
    LOG_CLICK("actionOnline_local_triggered");
    QMessageBox::information(this, tr("ONLINE (LOCAL)"), tr("Local online mode is planned for a future release."));
}

void MainWindow::on_actionOnline_remote_triggered()
{
    LOG_CLICK("actionOnline_remote_triggered");
    QMessageBox::information(this, tr("ONLINE (REMOTE)"), tr("Remote online mode is planned for a future release."));
}

void MainWindow::on_actionOnline_local_P2P_triggered()
{
    LOG_CLICK("actionOnline_local_P2P_triggered");
    QMessageBox::information(this, tr("ONLINE (LOCAL) [P2P]"), tr("Local P2P mode is planned for a future release."));
}

void MainWindow::on_actionOnline_remote_P2P_triggered()
{
    LOG_CLICK("actionOnline_remote_P2P_triggered");
    QMessageBox::information(this, tr("ONLINE (REMOTE) [P2P]"), tr("Remote P2P mode is planned for a future release."));
}

void MainWindow::on_actionOffline_triggered()
{
    LOG_CLICK("actionOffline_triggered");
    QMessageBox::information(this, tr("OFFLINE"), tr("ShelfSight is already operating in offline mode. All databases are local."));
}

void MainWindow::on_actionCryptography_triggered()
{
    LOG_CLICK("actionCryptography_triggered");
    QMessageBox::information(this, tr("CRYPTOGRAPHY"), tr("ShelfSight uses libsodium (Argon2) for password hashing and per-user salts. Database encryption settings will be available in a future release."));
}

void MainWindow::on_actionUpdate_triggered()
{
    LOG_CLICK("actionUpdate_triggered");
    QMessageBox::information(this, tr("UPDATE"), tr("ShelfSight does not currently support automatic updates. Please check the GitHub releases page for the latest version."));
}

void MainWindow::on_actionManage_triggered()
{
    LOG_CLICK("actionManage_triggered");
    on_actionDatabase_Selection_triggered();
}

