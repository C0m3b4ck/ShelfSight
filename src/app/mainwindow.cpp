#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "domain.h"
#include "businesslogic.h"
#include "sqlite_dataaccess.h"
#include "crypto.h"
#include <QDebug>
#include <QMessageBox>
#include <QListWidget>
#include <QFileDialog>
#include <QInputDialog>
#include <QSettings>
#include <QRegularExpression>
#include <vector>

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
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    if (load_libsodium() == false)
    {
        QMessageBox::critical(this, tr("LIBSODIUM FAILED"), tr("The application cannot function correctly without cryptographic functions."));
    }

    // Load saved default config if available
    QSettings settings("ShelfSight", "DatabaseConfigs");
    bool hasDefault = settings.value("default_is_valid", false).toBool();
    if (hasDefault) {
        QString configKey = "config_default";
        database_books = settings.value(configKey + "/books").toString();
        database_readers = settings.value(configKey + "/readers").toString();
        database_loans = settings.value(configKey + "/loans").toString();
        qDebug() << "[STARTUP] Loaded default config - books:" << database_books << "readers:" << database_readers << "loans:" << database_loans;
    } else {
        // No saved config — initialize readers.db at minimum so login works
        database_books = "";
        database_readers = "readers.db";
        database_loans = "";
        qDebug() << "[STARTUP] No saved config found, using defaults (readers.db)";
    }

    auto& db = DataAccess::SQLiteDataAccess::instance();
    try {
        db.initialize(database_books.toStdString(), database_readers.toStdString(), database_loans.toStdString());
    } catch (const std::exception& e) {
        qDebug() << "[STARTUP] DB init failed:" << e.what();
    }

    set_to_backdrop();
}

MainWindow::~MainWindow()
{
    delete ui;
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
    ui->txtUsr_register->setText("");
}


void MainWindow::on_btnClear_password1_register_clicked()
{
    ui->txtPwd1_register->setText("");
}


void MainWindow::on_btnClear_password2_register_clicked()
{
    ui->txtPassword2_register->setText("");
}

void MainWindow::on_btnClear_title_book_clicked()
{
    ui->txtTitle_book->setText("");
}

void MainWindow::on_btnClear_author_book_clicked()
{
    ui->txtAuthor_book->setText("");
}

void MainWindow::on_btnClear_id_book_clicked()
{
    ui->txtId_book->setText("");
}

void MainWindow::on_btnClear_title_book_edit_clicked()
{
    ui->txtTitle_book_edit->setText("");
}


void MainWindow::on_btnClear_author_book_edit_clicked()
{
    ui->txtAuthor_book_edit->setText("");
}


void MainWindow::on_btnClear_id_book_edit_clicked()
{
    ui->txtId_book_edit->setText("");
}

void MainWindow::on_btnClear_name_category_clicked()
{
    ui->txtName_category->setText("");
}

void MainWindow::on_btnClear_name_location_clicked()
{
    ui->txtName_location->setText("");
}

void MainWindow::on_btnClear_name_addreaders_clicked()
{
    ui->txtName_addreaders->setText("");
}

void MainWindow::on_btnClear_surname_addreaders_clicked()
{
    ui->txtSurname_addreaders->setText("");
}

void MainWindow::on_btnClear_grade_addreaders_clicked()
{
    ui->txtGrade_addreaders->setText("");
}

void MainWindow::on_btnClear_class_addreaders_clicked()
{
    ui->txtClass_addreaders->setText("");
}

void MainWindow::on_btnClear_id_addreaders_clicked()
{
    ui->txtID_addreaders->setText("");
}

// =============== HELP BUTTONS =======================
void MainWindow::on_btnHelp_pwdStrenght_register_clicked()
{
    QMessageBox::information(this, tr("Password Strength"),
    tr("Judges password strength based on:  \n * length, \n * characters used (numbers, letters, special), \n * capitalization, \n * whether the password is a set of words. \n The higher the password strength, the harder it is to guess or crack using specialized tools."));
}


void MainWindow::on_btnHelp_role_register_clicked()
{
    QMessageBox::information(this, tr("User Roles"), tr("1. User \n Has the rights to manage books, readers and loans. Cannot access database and advanced settings. \n 2. Admin \n Has access to everything that User has access to plus database-related functions. \n 3. Superadmin \n The highest role, has access to all of the functions that Admin has and some critical functions, including salt modification and updating the app."));
}

void MainWindow::on_btnHelp_role_login_clicked()
{
    QMessageBox::information(this, tr("User Roles"), tr("1. User \n Has the rights to manage books, readers and loans. Cannot access database and advanced settings. \n 2. Admin \n Has access to everything that User has access to plus database-related functions. \n 3. Superadmin \n The highest role, has access to all of the functions that Admin has and some critical functions, including salt modification and updating the app."));
}

// =============== SEARCH BUTTONS ============
// search edit books
void MainWindow::on_btnSearch_book_edit_clicked()
{
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

// search undo book removal
void MainWindow::on_btnSearch_undoremovebooks_clicked()
{
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

    QString filter = search_term.toLower();
    QString filter_field = ui->cboValue_undobooks->currentText().toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_undobooks->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_undobooks->item(i);
        QString item_text = item->text().toLower();

        bool match = false;
        if (filter_field == "title" || filter_field.isEmpty())
            match = item_text.contains(filter);
        else if (filter_field == "author")
            match = item_text.split(" | ").value(1).contains(filter);
        else if (filter_field == "id")
            match = item_text.split(" | ").value(5).contains(filter);
        else if (filter_field == "location")
            match = item_text.split(" | ").value(2).contains(filter);
        else if (filter_field == "category")
            match = item_text.split(" | ").value(3).contains(filter);
        else if (filter_field == "status")
            match = item_text.split(" | ").value(4).contains(filter);

        if (match)
        {
            item->setHidden(false);
            found = true;
        }
        else
        {
            item->setHidden(true);
        }
    }

    if (!found && ui->lstSearch_undobooks->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching removed books found"));
    }
}

// search manage locations
void MainWindow::on_btnSearch_managelocations_clicked()
{
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

// search remove books
void MainWindow::on_btnSearch_removebooks_clicked()
{
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

    QString filter = search_term.toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_book_remove->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_book_remove->item(i);
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

    if (!found && ui->lstSearch_book_remove->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching books found"));
    }
}

// search edit readers
void MainWindow::on_btnSearch_editreaders_clicked()
{
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

// search remove readers
void MainWindow::on_btnSearch_removereaders_clicked()
{
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

    QString filter = search_term.toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_reader_remove->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_reader_remove->item(i);
        QString item_text = item->text().toLower();

        // Search across all fields (simple contains match)
        bool match = item_text.contains(filter);

        if (match)
        {
            item->setHidden(false);
            found = true;
        }
        else
        {
            item->setHidden(true);
        }
    }

    if (!found && ui->lstSearch_reader_remove->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching readers found"));
    }
}

// lst clicked in remove readers - populate fields with selected reader data
void MainWindow::on_lstSearch_removereaders_itemClicked(QListWidgetItem *item)
{
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 5)
    {
        ui->txtName_reader_remove->setText(parts[0].trimmed());
        ui->txtSurname_reader_remove->setText(parts[1].trimmed());
        ui->txtGrade_reader_remove->setText(parts[2].trimmed());
        ui->txtClass_reader_remove->setText(parts[3].trimmed());
        ui->txtId_reader_remove->setText(parts[4].trimmed());

        // Populate reader_selected DTO
        reader_selected.name = toStd(parts[0].trimmed());
        reader_selected.surname = toStd(parts[1].trimmed());
        reader_selected.grade = parts[2].trimmed().toShort();
        reader_selected.classGroup = parts[3].trimmed().at(0).toLatin1();
        reader_selected.studentId = toStd(parts[4].trimmed());
        reader_selected.id = std::stoi(reader_selected.studentId);
    }
}

// remove readers button
void MainWindow::on_btnRemove_removereaders_clicked()
{
    // check if DB is selected
    if (database_readers.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }
    // check if reader is selected (name field not empty)
    if (is_qstring_empty(ui->txtName_reader_remove->text()))
    {
        QMessageBox::critical(this, tr("NAME EMPTY"), tr("Please select a reader to remove"));
        return;
    }

    // confirm if user wants to proceed
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Remove Reader?"));
    box.setText(tr("Are you sure you want to remove reader:\n"
                   "Name: %1\nSurname: %2\nGrade: %3\nClass: %4\nID: %5")
                      .arg(ui->txtName_reader_remove->text())
                      .arg(ui->txtSurname_reader_remove->text())
                      .arg(ui->txtGrade_reader_remove->text())
                      .arg(ui->txtClass_reader_remove->text())
                      .arg(ui->txtId_reader_remove->text()));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // remove from reader DB
        // store for undo
        reader_selected.name = toStd(ui->txtName_reader_remove->text());
        reader_selected.surname = toStd(ui->txtSurname_reader_remove->text());
        reader_selected.grade = ui->txtGrade_reader_remove->text().toShort();
        reader_selected.classGroup = ui->txtClass_reader_remove->text().at(0).toLatin1();
        reader_selected.studentId = toStd(ui->txtId_reader_remove->text());
        reader_selected.id = std::stoi(reader_selected.studentId);
    }
}

// undo removal readers
void MainWindow::on_btnUndoRemoval_removereaders_clicked()
{
    // check if there is something to undo
    if (is_reader_dto_empty(reader_selected))
    {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent removal to undo"));
        return;
    }

    // confirm if user wants to proceed
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo Removal?"));
    box.setText(tr("Are you sure you want to restore reader:\n"
                   "Name: %1\nSurname: %2\nGrade: %3\nClass: %4\nID: %5")
                      .arg(reader_selected.name)
                      .arg(reader_selected.surname)
                      .arg(reader_selected.grade)
                      .arg(reader_selected.classGroup)
                      .arg(reader_selected.studentId));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // restore to reader DB
    }
}

// undo last readers
void MainWindow::on_btnUndoLast_removereaders_clicked()
{
    // check if there is something to undo
    if (is_reader_dto_empty(last_reader_removed))
    {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent removal to undo"));
        return;
    }

    // confirm if user wants to proceed
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo Last Removal?"));
    box.setText(tr("Are you sure you want to restore last removed reader:\n"
                   "Name: %1\nSurname: %2\nGrade: %3\nClass: %4\nID: %5")
                      .arg(last_reader_removed.name)
                      .arg(last_reader_removed.surname)
                      .arg(last_reader_removed.grade)
                      .arg(last_reader_removed.classGroup)
                      .arg(last_reader_removed.studentId));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // restore to reader DB
    }
}

void MainWindow::on_btnClear_name_removereaders_clicked()
{
    ui->txtName_reader_remove->setText("");
}

void MainWindow::on_btnClear_surname_removereaders_clicked()
{
    ui->txtSurname_reader_remove->setText("");
}

void MainWindow::on_btnClear_grade_removereaders_clicked()
{
    ui->txtGrade_reader_remove->setText("");
}

void MainWindow::on_btnClear_class_removereaders_clicked()
{
    ui->txtClass_reader_remove->setText("");
}

void MainWindow::on_btnClear_id_removereaders_clicked()
{
    ui->txtId_reader_remove->setText("");
}

// menu action: navigate to remove readers page
void MainWindow::on_actionRemoveReaders_triggered()
{
    if (!checkLoginRequired()) return;

    // check if a DB is selected
    if (database_readers.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    // ==== BEFORE SHOWING ====
    // clear text fields
    ui->txtName_reader_remove->clear();
    ui->txtSurname_reader_remove->clear();
    ui->txtGrade_reader_remove->clear();
    ui->txtClass_reader_remove->clear();
    ui->txtId_reader_remove->clear();
    ui->txtSearch_reader_remove->clear();
    ui->lstSearch_reader_remove->clear();

    ui->workspaces->setCurrentIndex(8); // page_12 (Remove Readers)
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
    // clear text fields
    ui->txtUsername_login->clear();
    ui->txtPassword_login->clear();
    // navigate to login workspace (magic numbers)
    ui->workspaces->setCurrentIndex(1);
}

void MainWindow::on_actionRegister_triggered()
{
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
    if (!checkLoginRequired()) return;

    // check if a DB is selected
    // -> if yes - navigate to add books (magic numbers)
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add books
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // clear text fields
    // update comboBoxes for: category, status, locations from DBs
    ui->workspaces->setCurrentIndex(3);
}

void MainWindow::on_actionEditBooks_triggered()
{
    if (!checkLoginRequired()) return;

    // check if a DB is selected
    // -> if yes - navigate to edit books (magic numbers)
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add books
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // clear text fields
    // update comboBoxes for: category, status, locations from DBs
    ui->workspaces->setCurrentIndex(4);
}

void MainWindow::on_actionManage_Categories_triggered()
{
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    // check if categories file exists
    // -> if not, create
    // ==== BEFORE SHOWING ====
    // clear text fields
    // update comboBoxes for: category, status, locations from DBs
    ui->workspaces->setCurrentIndex(5);
}

void MainWindow::on_actionRemoveBooks_triggered()
{
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    // check if a DB is selected
    // -> if yes - find its deleted books section
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add books
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // clear text fields
    // update listBox from deleted dbs
    ui->workspaces->setCurrentIndex(7);
}

void MainWindow::on_actionUndo_Removed_triggered()
{
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    // check if a DB is selected
    // -> if yes - find its deleted books section
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add books
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // clear text fields
    // update listBox from deleted dbs (all results due to empty search term)
    ui->workspaces->setCurrentIndex(6);
}

void MainWindow::on_actionUndo_Removed_2_triggered()
{
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    // check if a reader DB is selected
    // -> if yes - find its deleted readers section
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add readers
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // clear text fields
    // update listBox from deleted readers dbs (all results due to empty search term)
    ui->workspaces->setCurrentIndex(15); // page_13 (Undo Removed Readers)
}

void MainWindow::on_actionManage_Locations_triggered()
{
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    // if location DB does not exist - make blank
    // clear text fields
    // update listBox from location DB
    ui->workspaces->setCurrentIndex(8);
}

void MainWindow::on_actionAddReaders_triggered()
{
    if (!checkLoginRequired()) return;

    // check if a DB is selected
    // -> if yes - find its deleted books section
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add books
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // clear text fields
    // update listBox from deleted dbs (all results due to empty search term)
    ui->workspaces->setCurrentIndex(9);
}

void MainWindow::on_actionEditReaders_triggered()
{
    if (!checkLoginRequired()) return;

    // check if a DB is selected
    // -> if yes - find its deleted reader section
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add reader
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // clear text fields
    // update listBox from deleted dbs (all results due to empty search term)
    ui->workspaces->setCurrentIndex(10);
}

void MainWindow::on_actionAddLoans_triggered()
{
    if (!checkLoginRequired()) return;

    // check if DBs are selected via business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::validateDatabases(db);
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
    ui->spnLoanDays_loan->setValue(14);

    ui->workspaces->setCurrentIndex(12); // page_14 (Add Loan)
}

void MainWindow::on_actionEditLoans_triggered()
{
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    // check if DBs are selected via business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::validateDatabases(db);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    // ==== BEFORE SHOWING ====
    // clear text fields
    ui->txtSearch_loan->clear();
    ui->txtSelected_loan->clear();
    ui->txtDueDate_loan->clear();
    ui->txtReturnDate_loan->clear();
    ui->cboStatus_loan->setCurrentIndex(0);

    // populate search field combo box
    ui->cboSearchField_loan->clear();
    ui->cboSearchField_loan->addItems({"ID", "Book ID", "Reader ID", "Status"});

    ui->workspaces->setCurrentIndex(13); // page_15 (Edit Loans)
}

void MainWindow::on_actionSearchLoans_triggered()
{
    if (!checkRoleRequired(BusinessLogic::RequiredRole::Admin)) return;

    // check if DBs are selected via business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::validateDatabases(db);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    // ==== BEFORE SHOWING ====
    // clear text fields
    ui->txtSearch_loanstatus->clear();
    ui->cboStatusFilter_loanstatus->setCurrentIndex(0);
    ui->lstSearch_loanstatus->clear();

    ui->workspaces->setCurrentIndex(14); // page_16 (Loan Statuses)
}

void MainWindow::on_actionDatabase_Selection_triggered()
{
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
    auto& db = DataAccess::SQLiteDataAccess::instance();
    try {
        db.initialize(database_books.toStdString(), database_readers.toStdString(), database_loans.toStdString());
        QMessageBox::information(this, tr("SUCCESS"), tr("Database configuration loaded successfully"));
    } catch (const std::exception& e) {
        QMessageBox::critical(this, tr("ERROR"), tr("Failed to initialize databases: %1").arg(e.what()));
    }
}

void MainWindow::on_btnBrowseBooksDb_clicked()
{
    QString file = QFileDialog::getOpenFileName(this, tr("Select Books Database"), "", tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*)"));
    if (!file.isEmpty()) {
        ui->txtBooksDb->setText(file);
        database_books = file;
    }
}

void MainWindow::on_btnBrowseReadersDb_clicked()
{
    QString file = QFileDialog::getOpenFileName(this, tr("Select Readers Database"), "", tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*)"));
    if (!file.isEmpty()) {
        ui->txtReadersDb->setText(file);
        database_readers = file;
    }
}

void MainWindow::on_btnBrowseLoansDb_clicked()
{
    QString file = QFileDialog::getOpenFileName(this, tr("Select Loans Database"), "", tr("SQLite Database (*.db *.sqlite *.sqlite3);;All Files (*)"));
    if (!file.isEmpty()) {
        ui->txtLoansDb->setText(file);
        database_loans = file;
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

    auto& db = DataAccess::SQLiteDataAccess::instance();
    try {
        db.initialize(booksDb.toStdString(), readersDb.toStdString(), loansDb.toStdString());
        if (db.isConnected()) {
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
    QString dir = QFileDialog::getExistingDirectory(this, tr("Select Directory for New Databases"));
    if (dir.isEmpty()) return;

    QString booksDb = dir + "/books.db";
    QString readersDb = dir + "/readers.db";
    QString loansDb = dir + "/loans.db";

    // Create new databases
    try {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        db.shutdown();
        db.initialize(booksDb.toStdString(), readersDb.toStdString(), loansDb.toStdString());

        database_books = booksDb;
        database_readers = readersDb;
        database_loans = loansDb;

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
    auto& db = DataAccess::SQLiteDataAccess::instance();

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

    auto result = BusinessLogic::addUser(db, userDTO);
    qDebug() << "[REGISTER] addUser result:" << result.isValid << "error:" << QString::fromStdString(result.errorMessage);
    if (!result.isValid) {
        QMessageBox::critical(this, tr("REGISTRATION FAILED"), QString::fromStdString(result.errorMessage));
        return;
    }

    // Auto-login after registration
    auto loginResult = BusinessLogic::login(db, userDTO.username, userDTO.password);
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
    auto& db = DataAccess::SQLiteDataAccess::instance();

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

    auto loginResult = BusinessLogic::login(db, toStd(username), toStd(password));
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
    ui->txtPwd1_register->setEchoMode(checked ? QLineEdit::Password : QLineEdit::Normal);
    ui->txtPassword2_register->setEchoMode(checked ? QLineEdit::Password : QLineEdit::Normal);
}

void MainWindow::on_chkHide_login_toggled(bool checked)
{
    ui->txtPassword_login->setEchoMode(checked ? QLineEdit::Password : QLineEdit::Normal);
}

void MainWindow::on_actionClose_Application_triggered()
{
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
void MainWindow::on_btnUndoEdit_editbooks_clicked()
{
    // when adding, all of the info is stored in last_book_edited
    if (is_book_dto_empty(last_book_edited)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent edit to undo"));
        return;
    }
    // confirm if user wants to proceed
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo edit?"));
    box.setText(
        tr(
            "Are you sure you want to undo edit book:\n"
            "Title: %1\n"
            "Author: %2\n"
            "Location: %3\n"
            "Category: %4\n"
            "Status: %5\n"
            "ID: %6"
            )
            .arg(last_book_edited.title)
            .arg(last_book_edited.author)
            .arg(last_book_edited.location)
            .arg(last_book_edited.category)
            .arg(last_book_edited.status)
            .arg(last_book_edited.id));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // restore the previous book data from last_book_edited
        // This would require DB implementation
        QMessageBox::information(this, tr("UNDO EDIT"), tr("Undo edit requires DB implementation"));
    }
}

// undo add buttons
void MainWindow::on_btnUndoAdd_addbooks_clicked()
{
    // when adding, all of the info is stored in last_book_added
    if (is_book_dto_empty(last_book_added)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent add to undo"));
        return;
    }
    // confirm if user wants to proceed
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo add?"));
    box.setText(
        tr(
            "Are you sure you want to undo add book:\n"
            "Title: %1\n"
            "Author: %2\n"
            "Location: %3\n"
            "Category: %4\n"
            "Status: %5\n"
            "ID: %6"
            )
            .arg(last_book_added.title)
            .arg(last_book_added.author)
            .arg(last_book_added.location)
            .arg(last_book_added.category)
            .arg(last_book_added.status)
            .arg(last_book_added.id));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // remove the added book from list (frontend only)
        for (int i = 0; i < ui->lstSearch_book_edit->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_book_edit->item(i);
            if (item->text().contains(QString::fromStdString(last_book_added.title)) && item->text().contains(QString::fromStdString(last_book_added.author)))
            {
                delete ui->lstSearch_book_edit->takeItem(i);
                break;
            }
        }
        last_book_added = DTO::BookDTO{};
        QMessageBox::information(this, tr("SUCCESS"), tr("Book add undone (frontend only - requires DB implementation)"));
    }
}


// add book button
void MainWindow::on_btnAddBook_addbooks_clicked()
{
    // check if DB is selected
    if (is_qstring_empty(database_books) == true)
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No book database selected"));
        return;
    }

    DTO::BookDTO book;
    book.title = toStd(ui->txtTitle_book->text());
    book.author = toStd(ui->txtAuthor_book->text());
    book.id = ui->txtId_book->text().toInt();
    book.location = toStd(ui->cboLocation_book->currentText());
    book.category = toStd(ui->cboCategory_book->currentText());
    book.status = toStd(ui->cboStatus_book->currentText());
    book.createdAt = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));
    book.updatedAt = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));

    // Validate through business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::addBook(db, book);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    QString display = QString::fromStdString(book.toDisplayString());

    // add to list widget for immediate feedback
    ui->lstSearch_book_edit->addItem(display);

    // store for undo
    last_book_added = book;

    QMessageBox::information(this, tr("SUCCESS"), tr("Book added"));

    // clear input fields
    ui->txtTitle_book->clear();
    ui->txtAuthor_book->clear();
    ui->txtId_book->clear();
}

// edit book button
void MainWindow::on_btnEditBook_editbooks_clicked()
{
    // check if DB is selected
    if (is_qstring_empty(database_books) == true)
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No book database selected"));
        return;
    }
    // check if a book is selected for editing
    else if (is_book_dto_empty(book_selected))
    {
        QMessageBox::critical(this, tr("NO BOOK SELECTED"), tr("Please select a book from the list to edit!"));
        return;
    }

    DTO::BookDTO newBook;
    newBook.title = toStd(ui->txtTitle_book_edit->text());
    newBook.author = toStd(ui->txtAuthor_book_edit->text());
    newBook.id = ui->txtId_book_edit->text().toInt();
    newBook.location = toStd(ui->cboLocation_book_edit->currentText());
    newBook.category = toStd(ui->cboCategory_book_edit->currentText());
    newBook.status = toStd(ui->cboStatus_book_edit->currentText());
    newBook.createdAt = book_selected.createdAt;
    newBook.updatedAt = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));

    // Validate through business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::updateBook(db, newBook);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    QString display = QString::fromStdString(newBook.toDisplayString());

    // find and replace the selected item in the list
    for (int i = 0; i < ui->lstSearch_book_edit->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_book_edit->item(i);
        if (item->text().contains(QString::fromStdString(book_selected.title)) && item->text().contains(QString::fromStdString(book_selected.author)))
        {
            item->setText(display);
            break;
        }
    }

    // store for undo
    last_book_edited = book_selected;

    // update book_selected with new values
    book_selected = newBook;

    QMessageBox::information(this, tr("SUCCESS"), tr("Book edited"));
}

// lst clicked in manage categories
void MainWindow::on_lstSearch_managecategories_itemClicked(QListWidgetItem *item)
{
    ui->txtName_category->setText(item->text());
    category_selected.name = toStd(item->text());
}

// lst clicked in edit books - populate edit fields
void MainWindow::on_lstSearch_book_edit_itemClicked(QListWidgetItem *item)
{
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
        book_selected.id = id_part.trimmed().toInt();

        // Also populate loan form if visible
        ui->txtSelected_book->setText(text);
    }
}

// lst clicked in undo removed books - populate undo fields
void MainWindow::on_lstSearch_undoremovebooks_itemClicked(QListWidgetItem *item)
{
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 2)
    {
        ui->txtValue_undobooks->setText(parts[0].trimmed());
        QString filter_field = parts[1].trimmed();
        int idx = ui->cboValue_undobooks->findText(filter_field);
        if (idx >= 0)
            ui->cboValue_undobooks->setCurrentIndex(idx);
    }
}

// lst clicked in remove books - store selected book for removal
void MainWindow::on_lstSearch_removebooks_itemClicked(QListWidgetItem *item)
{
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 6)
    {
        book_selected.title = toStd(parts[0].trimmed());
        book_selected.author = toStd(parts[1].trimmed());
        book_selected.location = toStd(parts[2].trimmed());
        book_selected.category = toStd(parts[3].trimmed());
        book_selected.status = toStd(parts[4].trimmed());
        QString id_part = parts[5];
        if (id_part.startsWith("ID: "))
            id_part = id_part.mid(4);
        book_selected.id = id_part.trimmed().toInt();
    }
}

// lst clicked in manage locations - populate location name
void MainWindow::on_lstSearch_managelocations_itemClicked(QListWidgetItem *item)
{
    ui->txtName_location->setText(item->text());
    location_selected.name = toStd(item->text());
}

// lst clicked in edit readers - populate edit fields
void MainWindow::on_lstSearch_reader_edit_itemClicked(QListWidgetItem *item)
{
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
        reader_selected.classGroup = parts[3].trimmed().at(0).toLatin1();
        reader_selected.studentId = toStd(parts[4].trimmed());
        reader_selected.id = std::stoi(reader_selected.studentId);

        // Also populate loan form if visible
        ui->txtSelected_reader->setText(text);
    }
}

void MainWindow::on_btnUndoAll_undoremovebooks_clicked()
{
    QString undo_term = ui->txtValue_undobooks->text();
    if (is_qstring_empty(undo_term) == true)
    {
        QMessageBox::critical(this, tr("Empty term!"), tr("Please input term before proceeding to undo!"));
        return;
    }

    if (database_books.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No book database selected"));
        return;
    }

    QString filter_field = ui->cboValue_undobooks->currentText();
    if (filter_field.isEmpty())
    {
        QMessageBox::critical(this, tr("NO FILTER SELECTED"), tr("Please select a filter field (Title, Author, ID, Location, Category, Status)"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo All Matching?"));
    box.setText(tr("Are you sure you want to restore ALL books where %1 contains '%2'?")
                    .arg(filter_field)
                    .arg(undo_term));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes)
    {
        // Note: bulk undo requires storing all matching item details
        // For frontend-only, we can only show the count of matching items
        int match_count = 0;
        for (int i = 0; i < ui->lstSearch_undobooks->count(); ++i)
        {
            if (!ui->lstSearch_undobooks->item(i)->isHidden())
                match_count++;
        }
        QMessageBox::information(this, tr("UNDO ALL (FRONTEND)"),
            tr("Would restore %1 matching books (requires DB for full implementation)").arg(match_count));
        undo_term = "";
        ui->txtValue_undobooks->clear();
    }
}

// remove books
void MainWindow::on_btnRemove_removebooks_clicked()
{
    // check if DB is selected
    if (is_qstring_empty(database_books) == true)
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No book database selected"));
        return;
    }
    // check if book is selected for removal
    else if (is_book_dto_empty(book_selected))
    {
        QMessageBox::critical(this, tr("BOOK NOT SELECTED"), tr("Please select a book from the list to remove!"));
        return;
    }
    else // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Remove Book?"));
        box.setText(
            tr(
                "Are you sure you want to remove book:\n"
                "Title: %1\n"
                "Author: %2\n"
                "Location: %3\n"
                "Category: %4\n"
                "Status: %5\n"
                "ID: %6"
                )
                .arg(book_selected.title)
                .arg(book_selected.author)
                .arg(book_selected.location)
                .arg(book_selected.category)
                .arg(book_selected.status)
                .arg(book_selected.id));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // remove from list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_book_remove->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_book_remove->item(i);
                if (item->text().contains(QString::fromStdString(book_selected.title)) && item->text().contains(QString::fromStdString(book_selected.author)))
                {
                    delete ui->lstSearch_book_remove->takeItem(i);
                    break;
                }
            }

            // store for undo
            last_book_removed = book_selected;

            // clear selection
            book_selected = DTO::BookDTO{};

            // clear input fields
            ui->txtTitle_book_remove->clear();
            ui->txtAuthor_book_remove->clear();
            ui->txtId_book_remove->clear();

            QMessageBox::information(this, tr("SUCCESS"), tr("Book removed (frontend only - requires DB implementation)"));
        }
    }
}

// ============== CATEGORIES ==============
// undo remove categories button
void MainWindow::on_btnUndoRemove_managecategories_clicked()
{
    // when removing, name is stored in last_category_removed
    if (is_category_dto_empty(last_category_removed))
    {
        QMessageBox::critical(this, tr("Nothing to undo!"), tr("Nothing to undo!"));
        return;
    }
    else // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Undo Removal?"));
        box.setText(
            tr(
                "Are you sure you want to restore category:\n %1 \n")
                .arg(last_category_removed.name));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // re-add category to list widget (frontend only)
            ui->lstSearch_category->addItem(QString::fromStdString(last_category_removed.name));
            last_category_removed = DTO::CategoryDTO{};
            QMessageBox::information(this, tr("SUCCESS"), tr("Category restored (frontend only - requires DB implementation)"));
        }
    }
}
// undo edit categories button
void MainWindow::on_btnUndoEdit_managecategories_clicked()
{
    // when editing, previous name is stored in last_category_edited
    if (is_category_dto_empty(last_category_edited))
    {
        QMessageBox::critical(this, tr("Nothing to undo!"), tr("Nothing to undo!"));
        return;
    }
    else    // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Undo Edit?"));
        box.setText(
            tr(
                "Are you sure you want to undo editing category:\n %1 \n")
                .arg(last_category_edited.name));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // revert category name in list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_category->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_category->item(i);
                if (item->text() == category_selected.name) // current name
                {
                    item->setText(QString::fromStdString(last_category_edited.name));
                    break;
                }
            }
            last_category_edited = DTO::CategoryDTO{};
            QMessageBox::information(this, tr("SUCCESS"), tr("Category edit undone (frontend only - requires DB implementation)"));
        }
    }
}

// undo add categories button
void MainWindow::on_btnUndoAdd_managecategories_clicked()
{
    // when adding, name is stored in last_category_added
    if (is_category_dto_empty(last_category_added))
    {
        QMessageBox::critical(this, tr("Nothing to undo!"), tr("Nothing to undo!"));
        return;
    }
    else // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Undo Add?"));
        box.setText(
            tr(
                "Are you sure you want to undo adding category:\n %1 \n")
                .arg(last_category_added.name));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // remove category from list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_category->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_category->item(i);
                if (item->text() == last_category_added.name)
                {
                    delete ui->lstSearch_category->takeItem(i);
                    break;
                }
            }
            last_category_added = DTO::CategoryDTO{};
            QMessageBox::information(this, tr("SUCCESS"), tr("Category add undone (frontend only - requires DB implementation)"));
        }
    }
}

// add category button
void MainWindow::on_btnAddCategory_managecategories_clicked()
{
    QString category_toadd = ui->txtName_category->text();

    DTO::CategoryDTO category;
    category.name = toStd(category_toadd);

    // Validate through business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::addCategory(db, category);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    // add to list widget (frontend only)
    ui->lstSearch_category->addItem(category_toadd);

    // inform user if it worked
    // -> if worked, set last_category_added to category_toadd
    last_category_added.name = toStd(category_toadd); // !!! ONLY HAPPENS UPON SUCCESS !!!
    category_toadd = "";

    // clear input field
    ui->txtName_category->clear();

    QMessageBox::information(this, tr("SUCCESS"), tr("Category added"));
}

// edit category button
void MainWindow::on_btnEditCategory_managecategories_clicked()
{
    QString category_toadd = ui->txtName_category->text();
    if(is_qstring_empty(category_toadd) == true)
    {
        QMessageBox::critical(this, tr("Empty category!"), tr("Category cannot be empty! Please input category before editing!"));
        return;
    }
    else if(is_category_dto_empty(category_selected)) // user has not selected any category to edit
    {
        QMessageBox::critical(this, tr("Target not selected!"), tr("Category to be edited is not selected! Please select before proceeding!"));
        return;
    }
    else if (category_selected.name == toStd(category_toadd)) // if 'edited' category is the same as the selected one
    {
        QMessageBox::critical(this, tr("Category not changed!"), tr("Category is unchanged from selected category! Not making any changes!"));
        return;
    }

    DTO::CategoryDTO category;
    category.id = category_selected.id;
    category.name = toStd(category_toadd);

    // Validate through business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::updateCategory(db, category);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    // edit in list widget (frontend only)
    for (int i = 0; i < ui->lstSearch_category->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_category->item(i);
        if (item->text() == QString::fromStdString(category_selected.name))
        {
            item->setText(category_toadd);
            break;
        }
    }

    // inform user if it worked
    // -> if worked, set last_category_edited
    last_category_edited = category_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!

    // update category_selected
    category_selected.name = toStd(category_toadd);
    category_toadd = "";

    // clear input field
    ui->txtName_category->clear();

    QMessageBox::information(this, tr("SUCCESS"), tr("Category edited"));
}

// remove category button
void MainWindow::on_btnRemoveCategory_managecategories_clicked()
{
    if(is_category_dto_empty(category_selected)) // user has not selected any category to delete
    {
        QMessageBox::critical(this, tr("Target not selected!"), tr("No category selected for deletion!"));
    }
    else
    {
        // remove from list widget (frontend only)
        for (int i = 0; i < ui->lstSearch_category->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_category->item(i);
            if (item->text() == category_selected.name)
            {
                delete ui->lstSearch_category->takeItem(i);
                break;
            }
        }

        // inform user if it worked
        // -> if worked, set last_category_removed to category_selected
        last_category_removed = category_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!

        // clear selection
        category_selected = DTO::CategoryDTO{};

        // clear input field
        ui->txtName_category->clear();

        QMessageBox::information(this, tr("SUCCESS"), tr("Category removed (frontend only - requires DB implementation)"));
    }
}

// edit location button
void MainWindow::on_btnEditLocation_managelocations_clicked()
{
    QString location_toadd = ui->txtName_location->text();
    if(is_qstring_empty(location_toadd) == true)
    {
        QMessageBox::critical(this, tr("Empty location!"), tr("Location cannot be empty! Please input location before editing!"));
        return;
    }
    else if(is_location_dto_empty(location_selected)) // user has not selected any location to edit
    {
        QMessageBox::critical(this, tr("Target not selected!"), tr("Location to be edited is not selected! Please select before proceeding!"));
        return;
    }
    else if (location_selected.name == toStd(location_toadd)) // if 'edited' location is the same as the selected one
    {
        QMessageBox::critical(this, tr("Location not changed!"), tr("Location is unchanged from selected location! Not making any changes!"));
        return;
    }

    DTO::LocationDTO location;
    location.id = location_selected.id;
    location.name = toStd(location_toadd);

    // Validate through business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::updateLocation(db, location);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    // edit in list widget (frontend only)
    for (int i = 0; i < ui->lstSearch_location->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_location->item(i);
        if (item->text() == QString::fromStdString(location_selected.name))
        {
            item->setText(location_toadd);
            break;
        }
    }

    // inform user if it worked
    // -> if worked, set last_location_edited
    last_location_edited = location_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!

    // update location_selected
    location_selected.name = toStd(location_toadd);
    location_toadd = "";

    // clear input field
    ui->txtName_location->clear();

    QMessageBox::information(this, tr("SUCCESS"), tr("Location edited"));
}

// remove location button
void MainWindow::on_btnRemoveLocation_managelocations_clicked()
{
    if(is_location_dto_empty(location_selected)) // user has not selected any location to delete
    {
        QMessageBox::critical(this, tr("Target not selected!"), tr("No location selected for deletion!"));
    }
    else
    {
        // remove from list widget (frontend only)
        for (int i = 0; i < ui->lstSearch_location->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_location->item(i);
            if (item->text() == location_selected.name)
            {
                delete ui->lstSearch_location->takeItem(i);
                break;
            }
        }

        // inform user if it worked
        // -> if worked, set last_location_removed to location_selected
        last_location_removed = location_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!

        // clear selection
        location_selected = DTO::LocationDTO{};

        // clear input field
        ui->txtName_location->clear();

        QMessageBox::information(this, tr("SUCCESS"), tr("Location removed (frontend only - requires DB implementation)"));
    }
}

// add location button
void MainWindow::on_btnAddLocation_managelocations_clicked()
{
    QString location_toadd = ui->txtName_location->text();

    DTO::LocationDTO location;
    location.name = toStd(location_toadd);

    // Validate through business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::addLocation(db, location);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    // add to list widget (frontend only)
    ui->lstSearch_location->addItem(location_toadd);

    // inform user if it worked
    // -> if worked, set last_location_added to location_toadd
    last_location_added.name = toStd(location_toadd); // !!! ONLY HAPPENS UPON SUCCESS !!!
    location_toadd = "";

    // clear input field
    ui->txtName_location->clear();

    QMessageBox::information(this, tr("SUCCESS"), tr("Location added"));
}

// undo remove manage locations button
void MainWindow::on_btnUndoRemove_managelocations_clicked()
{
    // when removing, name is stored in last_location_removed
    if (is_location_dto_empty(last_location_removed))
    {
        QMessageBox::critical(this, tr("Nothing to undo!"), tr("Nothing to undo!"));
        return;
    }
    else
    {
        // confirm if user wants to proceed
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Undo Removal?"));
        box.setText(
            tr(
                "Are you sure you want to restore location:\n %1 \n")
                .arg(last_location_removed.name));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // re-add location to list widget (frontend only)
            ui->lstSearch_location->addItem(QString::fromStdString(last_location_removed.name));
            last_location_removed = DTO::LocationDTO{};
            QMessageBox::information(this, tr("SUCCESS"), tr("Location restored (frontend only - requires DB implementation)"));
        }
    }
}

// undo add manage locations button
void MainWindow::on_btnUndoAdd_managelocations_clicked()
{
    // when adding, name is stored in last_location_added
    if (is_location_dto_empty(last_location_added))
    {
        QMessageBox::critical(this, tr("Nothing to undo!"), tr("Nothing to undo!"));
        return;
    }
    else // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Undo Add?"));
        box.setText(
            tr(
                "Are you sure you want to undo adding location:\n %1 \n")
                .arg(last_location_added.name));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // remove location from list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_location->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_location->item(i);
                if (item->text() == last_location_added.name)
                {
                    delete ui->lstSearch_location->takeItem(i);
                    break;
                }
            }
            last_location_added = DTO::LocationDTO{};
            QMessageBox::information(this, tr("SUCCESS"), tr("Location add undone (frontend only - requires DB implementation)"));
        }
    }
}

// undo edit manage locations button
void MainWindow::on_btnUndoEdit_managelocations_clicked()
{
    // when editing, previous name is stored in last_location_edited
    if (is_location_dto_empty(last_location_edited))
    {
        QMessageBox::critical(this, tr("Nothing to undo!"), tr("Nothing to undo!"));
    }
    else // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Undo edit?"));
        box.setText(
            tr(
                "Are you sure you want to undo editing location:\n %1 \n")
                .arg(last_location_edited.name));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // revert location name in list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_location->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_location->item(i);
                if (item->text() == location_selected.name) // current name
                {
                    item->setText(QString::fromStdString(last_location_edited.name));
                    break;
                }
            }
            last_location_edited = DTO::LocationDTO{};
            QMessageBox::information(this, tr("SUCCESS"), tr("Location edit undone (frontend only - requires DB implementation)"));
        }
    }
}

// undo selected undo remove books button
void MainWindow::on_btnUndoSelected_undoremovebooks_clicked()
{
    // when removing, all of the info is stored in last_book_removed
    // check if there is something to undo
    if (is_book_dto_empty(last_book_removed))
    {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent removal to undo"));
        return;
    }
    // confirm if user wants to proceed
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo Removal?"));
    box.setText(
        tr(
            "Are you sure you want to restore book:\n"
            "Title: %1\n"
            "Author: %2\n"
            "Location: %3\n"
            "Category: %4\n"
            "Status: %5\n"
            "ID: %6"
            )
            .arg(last_book_removed.title)
            .arg(last_book_removed.author)
            .arg(last_book_removed.location)
            .arg(last_book_removed.category)
            .arg(last_book_removed.status)
            .arg(last_book_removed.id));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // add the book back to list widget (frontend only)
        QString display = QString::fromStdString(last_book_removed.toDisplayString());
        ui->lstSearch_undobooks->addItem(display);

        // store for redo
        last_book_undone = last_book_removed;

        // clear undo buffer
        last_book_removed = DTO::BookDTO{};

        QMessageBox::information(this, tr("SUCCESS"), tr("Book restored (frontend only - requires DB implementation)"));
    }
}

// redo remove remove books buttons
void MainWindow::on_btnRedoRemove_undoremovebooks_clicked()
{
    // when undoing, the book info is stored in last_book_undone
    if (is_book_dto_empty(last_book_undone))
    {
        QMessageBox::critical(this, tr("NOTHING TO REDO"), tr("Nothing to redo!"));
        return;
    }
    else // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Redo Removal?"));
        box.setText(
            tr(
                "Are you sure you want to re-remove this book:\n"
                "Title: %1\n"
                "Author: %2\n"
                "Location: %3\n"
                "Category: %4\n"
                "Status: %5\n"
                "ID: %6"
                )
                .arg(last_book_undone.title)
                .arg(last_book_undone.author)
                .arg(last_book_undone.location)
                .arg(last_book_undone.category)
                .arg(last_book_undone.status)
                .arg(last_book_undone.id));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // remove the book from list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_undobooks->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_undobooks->item(i);
                if (item->text().contains(QString::fromStdString(last_book_undone.title)) && item->text().contains(QString::fromStdString(last_book_undone.author)))
                {
                    delete ui->lstSearch_undobooks->takeItem(i);
                    break;
                }
            }

            // restore to removed buffer for future undo
            last_book_removed = last_book_undone;

            // clear redo buffer
            last_book_undone = DTO::BookDTO{};

            QMessageBox::information(this, tr("SUCCESS"), tr("Book re-removed (frontend only - requires DB implementation)"));
        }
    }
}

// redo all selected undo remove books buttons
void MainWindow::on_btnRedoAllSelected_undoremovebooks_clicked()
{
    // when mass-undoing, data is saved in last_undoall_books vector
    QMessageBox box(this);
    long long num_redelete_all = last_undoall_books.size();
    if (num_redelete_all == 0)
    {
        QMessageBox::critical(this, tr("NOTHING TO REDO"), tr("NOTHING TO REDO"));
        return;
    }
    else // confirm if user wants to proceed
    {
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Re-do Removal?"));
        box.setText(
            tr(
                "Are you sure you want to re-delete %1 books?"
                )
                .arg(std::to_string(num_redelete_all)));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // Note: full implementation requires storing all book details in last_undoall_books
            // For now, just clear the vector and show message
            last_undoall_books.clear();
            QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("Redo All requires storing full book details - needs DB implementation"));
        }
    }
}

/// =============================================== UNDO REMOVED READERS ===================================

// search undo removed readers
void MainWindow::on_btnSearch_undoremovereaders_clicked()
{
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

    QString filter = search_term.toLower();
    QString filter_field = ui->cboValue_undoreaders->currentText().toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_undoreaders->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_undoreaders->item(i);
        QString item_text = item->text().toLower();

        bool match = false;
        // Reader list format: "Name | Surname | Grade | Class | ID"
        if (filter_field == "name" || filter_field.isEmpty())
            match = item_text.split(" | ").value(0).contains(filter);
        else if (filter_field == "surname")
            match = item_text.split(" | ").value(1).contains(filter);
        else if (filter_field == "id")
            match = item_text.split(" | ").value(4).contains(filter);
        else if (filter_field == "grade")
            match = item_text.split(" | ").value(2).contains(filter);
        else if (filter_field == "class")
            match = item_text.split(" | ").value(3).contains(filter);

        if (match)
        {
            item->setHidden(false);
            found = true;
        }
        else
        {
            item->setHidden(true);
        }
    }

    if (!found && ui->lstSearch_undoreaders->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching removed readers found"));
    }
}

// lst clicked in undo removed readers - populate undo fields
void MainWindow::on_lstSearch_undoremovereaders_itemClicked(QListWidgetItem *item)
{
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 2)
    {
        ui->txtValue_undoreaders->setText(parts[0].trimmed());
        QString filter_field = parts[1].trimmed();
        int idx = ui->cboValue_undoreaders->findText(filter_field);
        if (idx >= 0)
            ui->cboValue_undoreaders->setCurrentIndex(idx);
    }
}

// undo all removed readers
void MainWindow::on_btnUndoAll_undoremovereaders_clicked()
{
    QString undo_term = ui->txtValue_undoreaders->text();
    if (is_qstring_empty(undo_term) == true)
    {
        QMessageBox::critical(this, tr("Empty term!"), tr("Please input term before proceeding to undo!"));
        return;
    }

    if (database_readers.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    QString filter_field = ui->cboValue_undoreaders->currentText();
    if (filter_field.isEmpty())
    {
        QMessageBox::critical(this, tr("NO FILTER SELECTED"), tr("Please select a filter field (Name, Surname, ID, Grade, Class)"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo All Matching?"));
    box.setText(tr("Are you sure you want to restore ALL readers where %1 contains '%2'?")
                    .arg(filter_field)
                    .arg(undo_term));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes)
    {
        // Note: bulk undo requires storing all matching item details
        // For frontend-only, we can only show the count of matching items
        int match_count = 0;
        for (int i = 0; i < ui->lstSearch_undoreaders->count(); ++i)
        {
            if (!ui->lstSearch_undoreaders->item(i)->isHidden())
                match_count++;
        }
        QMessageBox::information(this, tr("UNDO ALL (FRONTEND)"),
            tr("Would restore %1 matching readers (requires DB for full implementation)").arg(match_count));
        undo_term = "";
        ui->txtValue_undoreaders->clear();
    }
}

// undo selected removed reader
void MainWindow::on_btnUndoSelected_undoremovereaders_clicked()
{
    // check if there is a reader selected for undo
    if (is_reader_dto_empty(reader_selected))
    {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No reader selected for restore"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo Removal?"));
    box.setText(
        tr(
            "Are you sure you want to restore reader:\n"
            "Name: %1\n"
            "Surname: %2\n"
            "Grade: %3\n"
            "Class: %4\n"
            "ID: %5"
            )
            .arg(reader_selected.name)
            .arg(reader_selected.surname)
            .arg(reader_selected.grade)
            .arg(reader_selected.classGroup)
            .arg(reader_selected.studentId));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // add the reader back to list widget (frontend only)
        QString display = QString::fromStdString(reader_selected.toDisplayString());
        ui->lstSearch_undoreaders->addItem(display);

        // store for redo
        last_reader_undone = reader_selected;

        // clear undo buffer
        reader_selected = DTO::ReaderDTO{};

        QMessageBox::information(this, tr("SUCCESS"), tr("Reader restored (frontend only - requires DB implementation)"));
    }
}

// redo remove removed readers
void MainWindow::on_btnRedoRemove_undoremovereaders_clicked()
{
    // check if there is something to redo
    if (is_reader_dto_empty(last_reader_undone))
    {
        QMessageBox::critical(this, tr("NOTHING TO REDO"), tr("Nothing to redo!"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Redo Removal?"));
    box.setText(
        tr(
            "Are you sure you want to re-remove this reader:\n"
            "Name: %1\n"
            "Surname: %2\n"
            "Grade: %3\n"
            "Class: %4\n"
            "ID: %5"
            )
            .arg(last_reader_undone.name)
            .arg(last_reader_undone.surname)
            .arg(last_reader_undone.grade)
            .arg(last_reader_undone.classGroup)
            .arg(last_reader_undone.studentId));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // remove the reader from list widget (frontend only)
        for (int i = 0; i < ui->lstSearch_undoreaders->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_undoreaders->item(i);
            if (item->text().contains(QString::fromStdString(last_reader_undone.name)) && item->text().contains(QString::fromStdString(last_reader_undone.surname)))
            {
                delete ui->lstSearch_undoreaders->takeItem(i);
                break;
            }
        }

        // restore to undo buffer
        reader_selected = last_reader_undone;

        // clear redo buffer
        last_reader_undone = DTO::ReaderDTO{};

        QMessageBox::information(this, tr("SUCCESS"), tr("Reader re-removed (frontend only - requires DB implementation)"));
    }
}

// redo all selected removed readers
void MainWindow::on_btnRedoAllSelected_undoremovereaders_clicked()
{
    QMessageBox box(this);
    long long num_redelete_all = last_undoall_readers.size();
    if (num_redelete_all == 0)
    {
        QMessageBox::critical(this, tr("NOTHING TO REDO"), tr("NOTHING TO REDO"));
        return;
    }
    else
    {
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Re-do Removal?"));
        box.setText(
            tr(
                "Are you sure you want to re-delete %1 readers?"
                )
                .arg(std::to_string(num_redelete_all)));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // Note: full implementation requires storing all reader details in last_undoall_readers
            // For now, just clear the vector and show message
            last_undoall_readers.clear();
            QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("Redo All requires storing full reader details - needs DB implementation"));
        }
    }
}

/// =============================================== READERS ===================================
// add readers button
void MainWindow::on_btnAddBook_addreaders_clicked()
{
    // check if DB is selected
    if (is_qstring_empty(database_readers) == true)
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    DTO::ReaderDTO reader;
    reader.name = toStd(ui->txtName_addreaders->text());
    reader.surname = toStd(ui->txtSurname_addreaders->text());
    reader.grade = ui->txtGrade_addreaders->text().toShort();
    reader.classGroup = ui->txtClass_addreaders->text().at(0).toLatin1();
    reader.studentId = toStd(ui->txtID_addreaders->text());
    reader.id = std::stoi(reader.studentId);
    reader.createdAt = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));
    reader.updatedAt = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));

    // Validate through business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::addReader(db, reader);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    QString display = QString::fromStdString(reader.toDisplayString());

    // add to list widget for immediate feedback
    ui->lstSearch_reader_edit->addItem(display);

    // store for undo
    last_reader_added = reader;

    QMessageBox::information(this, tr("SUCCESS"), tr("Reader added"));

    // clear input fields
    ui->txtName_addreaders->clear();
    ui->txtSurname_addreaders->clear();
    ui->txtGrade_addreaders->clear();
    ui->txtClass_addreaders->clear();
    ui->txtID_addreaders->clear();
}

// edit readers button
void MainWindow::on_btnEditBook_editreaders_clicked()
{
    // check if DB is selected
    if (is_qstring_empty(database_readers) == true)
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }
    // check if a reader is selected for editing
    else if (is_reader_dto_empty(reader_selected))
    {
        QMessageBox::critical(this, tr("NO READER SELECTED"), tr("Please select a reader from the list to edit!"));
        return;
    }

    DTO::ReaderDTO newReader;
    newReader.name = toStd(ui->txtName_reader_edit->text());
    newReader.surname = toStd(ui->txtSurname_reader_edit->text());
    newReader.grade = ui->txtGrade_reader_edit->text().toShort();
    newReader.classGroup = ui->txtClass_reader_edit->text().at(0).toLatin1();
    newReader.studentId = toStd(ui->txtId_reader_edit->text());
    newReader.id = std::stoi(newReader.studentId);
    newReader.createdAt = reader_selected.createdAt;
    newReader.updatedAt = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));

    // Validate through business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::updateReader(db, newReader);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    QString display = QString::fromStdString(newReader.toDisplayString());

    // find and replace the selected item in the list
    for (int i = 0; i < ui->lstSearch_reader_edit->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_reader_edit->item(i);
        if (item->text().contains(QString::fromStdString(reader_selected.name)) && item->text().contains(QString::fromStdString(reader_selected.surname)))
        {
            item->setText(display);
            break;
        }
    }

    // store for undo
    last_reader_edited = reader_selected;

    // update reader_selected with new values
    reader_selected = newReader;

    QMessageBox::information(this, tr("SUCCESS"), tr("Reader edited"));
}

// undo edit edit readers
void MainWindow::on_btnUndoEdit_editreaders_clicked()
{
    // when adding, all of the info is stored in last_reader_edited
    if (is_reader_dto_empty(last_reader_edited)) {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("No recent edit to undo"));
        return;
    }
    // confirm if user wants to proceed
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo edit?"));
    box.setText(
        tr(
            "Are you sure you want to undo edit reader:\n"
            "Name: %1\n"
            "Surname: %2\n"
            "Grade: %3\n"
            "Class: %4\n"
            "ID: %5"
            )
            .arg(last_reader_edited.name)
            .arg(last_reader_edited.surname)
            .arg(last_reader_edited.grade)
            .arg(last_reader_edited.classGroup)
            .arg(last_reader_edited.studentId));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // restore the previous reader data from last_reader_edited
        // This would require DB implementation
        QMessageBox::information(this, tr("UNDO EDIT"), tr("Undo edit requires DB implementation"));
    }
}

// ======================================= LOANS ======================================================

// search book for loan
void MainWindow::on_btnSearchBook_addloan_clicked()
{
    QString search_term = ui->txtSearch_book->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("Please enter a book title or author to search"));
        return;
    }

    if (database_books.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No book database selected"));
        return;
    }

    QString filter = search_term.toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_book->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_book->item(i);
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

    if (!found && ui->lstSearch_book->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching books found"));
    }
    else if (found)
    {
        // Show the list widget for selection (reuse edit books list)
        // In a full implementation, we'd have a dedicated list for loan book selection
        QMessageBox::information(this, tr("SEARCH COMPLETE"), tr("Click a book in the Edit Books list to select it, then return here"));
    }
}

// search reader for loan
void MainWindow::on_btnSearchReader_clicked()
{
    QString search_term = ui->txtSearch_reader->text();
    QString searchField = ui->cboSearchField_reader->currentText();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("Please enter a search term"));
        return;
    }

    if (database_readers.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    // Use business logic to populate the list
    auto& db = DataAccess::SQLiteDataAccess::instance();
    auto items = db.populateList("readers", search_term.toStdString(), searchField.toStdString());
    ui->lstSearch_reader->clear();
    for (const auto& item : items) {
        ui->lstSearch_reader->addItem(QString::fromStdString(item.displayText));
    }
}

// add loan button
void MainWindow::on_btnAddLoan_addloan_clicked()
{
    // check if DBs are selected via business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::validateDatabases(db);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("NO DATABASE SELECTED"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    // check if book is selected
    if (ui->txtSelected_book->text().isEmpty())
    {
        QMessageBox::critical(this, tr("NO BOOK SELECTED"), tr("Please select a book for the loan"));
        return;
    }

    // check if reader is selected
    if (ui->txtSelected_reader->text().isEmpty())
    {
        QMessageBox::critical(this, tr("NO READER SELECTED"), tr("Please select a reader for the loan"));
        return;
    }

    int loanDays = ui->spnLoanDays_loan->value();

    // Parse book ID from selected book text
    QString bookText = ui->txtSelected_book->text();
    QStringList bookParts = bookText.split(" | ");
    int bookId = 0;
    if (bookParts.size() >= 6)
    {
        QString idPart = bookParts[5];
        if (idPart.startsWith("ID: "))
            idPart = idPart.mid(4);
        bookId = idPart.trimmed().toInt();
    }

    // Parse reader ID from selected reader text
    QString readerText = ui->txtSelected_reader->text();
    QStringList readerParts = readerText.split(" | ");
    int readerId = 0;
    if (readerParts.size() >= 5)
    {
        readerId = readerParts[4].trimmed().toInt();
    }

    if (bookId <= 0 || readerId <= 0)
    {
        QMessageBox::critical(this, tr("INVALID SELECTION"), tr("Could not parse book or reader ID"));
        return;
    }

    // Create loan DTO
    DTO::LoanDTO loan;
    loan.bookId = bookId;
    loan.readerId = readerId;
    loan.loanDate = toStd(QDateTime::currentDateTime().toString(Qt::ISODate));
    loan.dueDate = toStd(QDateTime::currentDateTime().addDays(loanDays).toString(Qt::ISODate));
    loan.status = "active";
    loan.returnDate = "";

    // Validate through business logic
    {
        auto& db = DataAccess::SQLiteDataAccess::instance();
        auto result = BusinessLogic::addLoan(db, loan);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), QString::fromStdString(result.errorMessage));
            return;
        }
    }

    QMessageBox::information(this, tr("SUCCESS"), tr("Loan created successfully"));

    // Clear form
    ui->txtSearch_book->clear();
    ui->txtSearch_reader->clear();
    ui->txtSelected_book->clear();
    ui->txtSelected_reader->clear();
    ui->spnLoanDays_loan->setValue(14);
}

// clear loan form
void MainWindow::on_btnClear_addloan_clicked()
{
    ui->txtSearch_book->clear();
    ui->txtSearch_reader->clear();
    ui->txtSelected_book->clear();
    ui->txtSelected_reader->clear();
    ui->spnLoanDays_loan->setValue(14);
}

// ============================ EDIT LOANS ======================================================

// search loan for editing
void MainWindow::on_btnSearchLoan_editloan_clicked()
{
    QString search_term = ui->txtSearch_loan->text();
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

    QString filter = search_term.toLower();
    QString field = ui->cboSearchField_loan->currentText().toLower();

    ui->lstSearch_loan->clear();

    // In a full implementation, we'd query the database
    // For now, we show a placeholder message
    QMessageBox::information(this, tr("SEARCH"), tr("Loan search requires database implementation"));
}

// lst clicked in edit loans - populate edit fields
void MainWindow::on_lstSearch_editloan_itemClicked(QListWidgetItem *item)
{
    QString text = item->text();
    ui->txtSelected_loan->setText(text);

    // Parse loan details from display text
    // Format: "Loan ID: X | Book: Y | Reader: Z | Loan: ... | Due: ... | Return: ... | Status: ..."
    QStringList parts = text.split(" | ");
    if (parts.size() >= 7)
    {
        // Extract status
        QString statusPart = parts[6];
        if (statusPart.startsWith("Status: "))
        {
            QString status = statusPart.mid(8);
            int idx = ui->cboStatus_loan->findText(status);
            if (idx >= 0)
                ui->cboStatus_loan->setCurrentIndex(idx);
        }

        // Extract due date
        QString duePart = parts[4];
        if (duePart.startsWith("Due: "))
        {
            ui->txtDueDate_loan->setText(duePart.mid(5).trimmed());
        }

        // Extract return date
        QString returnPart = parts[5];
        if (returnPart.startsWith("Return: "))
        {
            QString ret = returnPart.mid(8).trimmed();
            ui->txtReturnDate_loan->setText(ret);
        }
    }
}

// update loan button
void MainWindow::on_btnUpdateLoan_editloan_clicked()
{
    if (ui->txtSelected_loan->text().isEmpty())
    {
        QMessageBox::critical(this, tr("NO LOAN SELECTED"), tr("Please select a loan to update"));
        return;
    }

    // Parse loan ID from selected loan text
    QString loanText = ui->txtSelected_loan->text();
    QStringList parts = loanText.split(" | ");
    int loanId = 0;
    if (parts.size() >= 1)
    {
        QString idPart = parts[0];
        if (idPart.startsWith("Loan ID: "))
            idPart = idPart.mid(9);
        loanId = idPart.trimmed().toInt();
    }

    if (loanId <= 0)
    {
        QMessageBox::critical(this, tr("INVALID LOAN"), tr("Could not parse loan ID"));
        return;
    }

    QString newStatus = ui->cboStatus_loan->currentText();
    QString dueDate = ui->txtDueDate_loan->text();
    QString returnDate = ui->txtReturnDate_loan->text();

    // Validate
    if (newStatus == "returned" && returnDate.isEmpty())
    {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Returned loan must have a return date"));
        return;
    }
    if (newStatus == "active" && !returnDate.isEmpty())
    {
        QMessageBox::critical(this, tr("VALIDATION ERROR"), tr("Active loan cannot have a return date"));
        return;
    }

    // In a full implementation, we'd call the business logic to update the loan
    QMessageBox::information(this, tr("UPDATE"), tr("Loan update requires database implementation"));

    // Store for undo
    loan_selected.id = loanId;
    loan_selected.status = toStd(newStatus);
    loan_selected.dueDate = toStd(dueDate);
    loan_selected.returnDate = toStd(returnDate);
}

// return loan button (mark as returned)
void MainWindow::on_btnReturnLoan_editloan_clicked()
{
    if (ui->txtSelected_loan->text().isEmpty())
    {
        QMessageBox::critical(this, tr("NO LOAN SELECTED"), tr("Please select a loan to return"));
        return;
    }

    QMessageBox box(this);
    box.setIcon(QMessageBox::Question);
    box.setWindowTitle(tr("Return Loan"));
    box.setText(tr("Mark the selected loan as returned?"));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes)
    {
        ui->cboStatus_loan->setCurrentText("returned");
        ui->txtReturnDate_loan->setText(QDateTime::currentDateTime().toString(Qt::ISODate));
        on_btnUpdateLoan_editloan_clicked();
    }
}

// clear edit loan form
void MainWindow::on_btnClear_editloan_clicked()
{
    ui->txtSearch_loan->clear();
    ui->txtSelected_loan->clear();
    ui->txtDueDate_loan->clear();
    ui->txtReturnDate_loan->clear();
    ui->cboStatus_loan->setCurrentIndex(0);
    ui->lstSearch_loan->clear();
}

// ============================ LOAN STATUSES ======================================================

// filter loans by status
void MainWindow::on_btnFilter_loanstatus_clicked()
{
    QString statusFilter = ui->cboStatusFilter_loanstatus->currentText();
    ui->lstSearch_loanstatus->clear();

    // In a full implementation, we'd query the database with the filter
    QMessageBox::information(this, tr("FILTER"), tr("Loan filtering requires database implementation"));
}

// search loans
void MainWindow::on_btnSearch_loanstatus_clicked()
{
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
    QMessageBox::information(this, tr("SEARCH"), tr("Loan search requires database implementation"));
}

// refresh loan statuses
void MainWindow::on_btnRefresh_loanstatus_clicked()
{
    ui->txtSearch_loanstatus->clear();
    ui->cboStatusFilter_loanstatus->setCurrentIndex(0);
    ui->lstSearch_loanstatus->clear();
    QMessageBox::information(this, tr("REFRESH"), tr("Loan refresh requires database implementation"));
}

// overdue report
void MainWindow::on_btnOverdueReport_loanstatus_clicked()
{
    if (database_loans.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No loan database selected"));
        return;
    }

    ui->lstSearch_loanstatus->clear();
    QMessageBox::information(this, tr("OVERDUE REPORT"), tr("Overdue report requires database implementation"));
}

// double-click loan in status list to edit
void MainWindow::on_lstSearch_loanstatus_itemDoubleClicked(QListWidgetItem *item)
{
    QString text = item->text();
    QMessageBox::information(this, tr("EDIT LOAN"), tr("Double-click to edit loan: %1").arg(text));
    // In a full implementation, this would open the edit loan form with the selected loan
}

// ==================== STUB IMPLEMENTATIONS FOR MISSING SLOTS ====================
// These are minimal stubs to allow compilation. Full implementations needed for functionality.

void MainWindow::on_btnClear_loan_edit_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnReturn_loan_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUpdate_loan_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_lstSearch_loan_itemClicked(QListWidgetItem *item)
{
    Q_UNUSED(item);
}

void MainWindow::on_btnSearch_loan_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnClear_loan_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnAdd_loan_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnSearch_reader_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnSearch_book_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnClear_id_reader_remove_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnClear_class_reader_remove_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnClear_grade_reader_remove_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnClear_surname_reader_remove_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnClear_name_reader_remove_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoLast_reader_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoRemoval_reader_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnRemove_reader_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnSearch_reader_remove_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnSearch_reader_edit_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnRemove_book_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoAdd_addreaders_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnRedoAllSelected_undoreaders_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnRedoRemove_undoreaders_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoSelected_undoreaders_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoAll_undoreaders_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_lstSearch_undoreaders_itemClicked(QListWidgetItem *item)
{
    Q_UNUSED(item);
}

void MainWindow::on_btnSearch_undoreaders_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnRedoAllSelected_undobooks_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnRedoRemove_undobooks_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoSelected_undobooks_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoEdit_location_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoAdd_location_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoRemove_location_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnAdd_location_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnEdit_location_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnRemove_location_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnSearch_location_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoAll_undobooks_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnSearch_book_remove_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnSearch_undobooks_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnRemove_category_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnEdit_category_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnAdd_category_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoAdd_category_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoEdit_category_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoRemove_category_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoAdd_book_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_lstSearch_book_remove_itemClicked(QListWidgetItem *item)
{
    Q_UNUSED(item);
}

void MainWindow::on_lstSearch_undobooks_itemClicked(QListWidgetItem *item)
{
    Q_UNUSED(item);
}

void MainWindow::on_lstSearch_category_itemClicked(QListWidgetItem *item)
{
    Q_UNUSED(item);
}

void MainWindow::on_btnEdit_book_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnUndoEdit_book_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_btnAdd_book_clicked()
{
    QMessageBox::information(this, tr("NOT IMPLEMENTED"), tr("This feature is not yet implemented"));
}

void MainWindow::on_txtPwd1_register_textChanged(const QString &text)
{
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

