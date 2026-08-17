#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "domain.h"
#include "businesslogic.h"
#include <QMessageBox>
#include <QListWidget>
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
    return book.title.isEmpty() && book.author.isEmpty() && book.id == 0;
}

// Helper to check if ReaderDTO is empty
bool is_reader_dto_empty(const DTO::ReaderDTO& reader) {
    return reader.name.isEmpty() && reader.surname.isEmpty() && reader.id == 0;
}

// Helper to check if CategoryDTO is empty
bool is_category_dto_empty(const DTO::CategoryDTO& cat) {
    return cat.name.isEmpty();
}

// Helper to check if LocationDTO is empty
bool is_location_dto_empty(const DTO::LocationDTO& loc) {
    return loc.name.isEmpty();
}

// Helper to check if LoanDTO is empty
bool is_loan_dto_empty(const DTO::LoanDTO& loan) {
    return loan.id == 0 && loan.bookId == 0 && loan.readerId == 0;
}

// =============== MAIN WINDOW ===================
MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
    , ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    set_to_backdrop();
}

MainWindow::~MainWindow()
{
    delete ui;
}
// =========== HELPERS ==========
void sanitize_variables() //clears variables (called by MainWindow and upon logging out/re-logging)
{
    // ====== databases ======
    database_books = "";
    database_readers = "";
    database_loans = "";
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
    ui->txtPwd2_register->setText("");
}

void MainWindow::on_btnClear_title_addbooks_clicked()
{
    ui->txtTitle_addbooks->setText("");
}

void MainWindow::on_btnClear_author_addbooks_clicked()
{
    ui->txtAuthor_addbooks->setText("");
}

void MainWindow::on_btnClear_id_addbooks_clicked()
{
    ui->txtID_addbooks->setText("");
}

void MainWindow::on_btnClear_title_editbooks_clicked()
{
    ui->txtTitle_editbooks->setText("");
}


void MainWindow::on_btnClear_author_editbooks_clicked()
{
    ui->txtAuthor_editbooks->setText("");
}


void MainWindow::on_btnClear_id_editbooks_clicked()
{
    ui->txtID_editbooks->setText("");
}

void MainWindow::on_btnClear_name_managecategories_clicked()
{
    ui->txtName_managecategories->setText("");
}

void MainWindow::on_btnClear_name_managelocations_clicked()
{
    ui->txtName_managelocations->setText("");
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
void MainWindow::on_btnSearch_editbooks_clicked()
{
    QString search_term = ui->txtSearch_editbooks->text();
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

    for (int i = 0; i < ui->lstSearch_editbooks->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_editbooks->item(i);
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

    if (!found && ui->lstSearch_editbooks->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching books found"));
    }
}

// search manage categories
void MainWindow::on_btnSearch_managecategories_clicked()
{
    QString search_term = ui->txtSearch_managecategories->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
        return;
    }

    QString filter = search_term.toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_managecategories->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_managecategories->item(i);
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

    if (!found && ui->lstSearch_managecategories->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching categories found"));
    }
}

// search undo book removal
void MainWindow::on_btnSearch_undoremovebooks_clicked()
{
    QString search_term = ui->txtSearch_undoremovebooks->text();
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
    QString filter_field = ui->cboValue_undoremovebooks->currentText().toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_undoremovebooks->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_undoremovebooks->item(i);
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

    if (!found && ui->lstSearch_undoremovebooks->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching removed books found"));
    }
}

// search manage locations
void MainWindow::on_btnSearch_managelocations_clicked()
{
    QString search_term = ui->txtSearch_managelocations->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
        return;
    }

    QString filter = search_term.toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_managelocations->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_managelocations->item(i);
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

    if (!found && ui->lstSearch_managelocations->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching locations found"));
    }
}

// search remove books
void MainWindow::on_btnSearch_removebooks_clicked()
{
    QString search_term = ui->txtSearch_removebooks->text();
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

    for (int i = 0; i < ui->lstSearch_removebooks->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_removebooks->item(i);
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

    if (!found && ui->lstSearch_removebooks->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching books found"));
    }
}

// search edit readers
void MainWindow::on_btnSearch_editreaders_clicked()
{
    QString search_term = ui->txtSearch_editreaders->text();
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

    for (int i = 0; i < ui->lstSearch_editreaders->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_editreaders->item(i);
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

    if (!found && ui->lstSearch_editreaders->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching readers found"));
    }
}

// search remove readers
void MainWindow::on_btnSearch_removereaders_clicked()
{
    QString search_term = ui->txtSearch_removereaders->text();
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
    QString filter_field = ui->cboFilter_removereaders->currentText().toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_removereaders->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_removereaders->item(i);
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

if (!found && ui->lstSearch_removereaders->count() > 0)
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
        ui->txtName_removereaders->setText(parts[0].trimmed());
        ui->txtSurname_removereaders->setText(parts[1].trimmed());
        ui->txtGrade_removereaders->setText(parts[2].trimmed());
        ui->txtClass_removereaders->setText(parts[3].trimmed());
        ui->txtID_removereaders->setText(parts[4].trimmed());

        // Populate reader_selected DTO
        reader_selected.name = parts[0].trimmed();
        reader_selected.surname = parts[1].trimmed();
        reader_selected.grade = parts[2].trimmed().toShort();
        reader_selected.classGroup = parts[3].trimmed().at(0);
        reader_selected.studentId = parts[4].trimmed();
        reader_selected.id = reader_selected.studentId.toInt();
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
    if (is_qstring_empty(ui->txtName_removereaders->text()))
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
                      .arg(ui->txtName_removereaders->text())
                      .arg(ui->txtSurname_removereaders->text())
                      .arg(ui->txtGrade_removereaders->text())
                      .arg(ui->txtClass_removereaders->text())
                      .arg(ui->txtID_removereaders->text()));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // remove from reader DB
        // store for undo
        reader_selected.name = ui->txtName_removereaders->text();
        reader_selected.surname = ui->txtSurname_removereaders->text();
        reader_selected.grade = ui->txtGrade_removereaders->text().toShort();
        reader_selected.classGroup = ui->txtClass_removereaders->text().at(0);
        reader_selected.studentId = ui->txtID_removereaders->text();
        reader_selected.id = reader_selected.studentId.toInt();
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
    ui->txtName_removereaders->setText("");
}

void MainWindow::on_btnClear_surname_removereaders_clicked()
{
    ui->txtSurname_removereaders->setText("");
}

void MainWindow::on_btnClear_grade_removereaders_clicked()
{
    ui->txtGrade_removereaders->setText("");
}

void MainWindow::on_btnClear_class_removereaders_clicked()
{
    ui->txtClass_removereaders->setText("");
}

void MainWindow::on_btnClear_id_removereaders_clicked()
{
    ui->txtID_removereaders->setText("");
}

// menu action: navigate to remove readers page
void MainWindow::on_actionRemoveReaders_triggered()
{
    // check if a DB is selected
    if (database_readers.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    // ==== BEFORE SHOWING ====
    // clear text fields
    ui->txtName_removereaders->clear();
    ui->txtSurname_removereaders->clear();
    ui->txtGrade_removereaders->clear();
    ui->txtClass_removereaders->clear();
    ui->txtID_removereaders->clear();
    ui->txtSearch_removereaders->clear();
    ui->lstSearch_removereaders->clear();
    ui->cboFilter_removereaders->setCurrentIndex(0);

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
    // change logged in bool to false or whatever the checking function will be
    // set role to null, switch workspace to backdrop
    set_to_backdrop();
}

void MainWindow::on_actionLog_in_triggered()
{
    // clear text fields
    // navigate to login workspace (magic numbers)
    ui->workspaces->setCurrentIndex(1);
}

void MainWindow::on_actionRegister_triggered()
{
    // clear text fields
    // navigate to register workspace (magic numbers)
    ui->workspaces->setCurrentIndex(0);
}

void MainWindow::on_actionAddBooks_triggered()
{
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
    // check if categories file exists
    // -> if not, create
    // ==== BEFORE SHOWING ====
    // clear text fields
    // update comboBoxes for: category, status, locations from DBs
    ui->workspaces->setCurrentIndex(5);
}

void MainWindow::on_actionRemoveBooks_triggered()
{
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
    // check if a reader DB is selected
    // -> if yes - find its deleted readers section
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add readers
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // clear text fields
    // update listBox from deleted readers dbs (all results due to empty search term)
    ui->workspaces->setCurrentIndex(13);
}

void MainWindow::on_actionManage_Locations_triggered()
{
    // if location DB does not exist - make blank
    // clear text fields
    // update listBox from location DB
    ui->workspaces->setCurrentIndex(8);
}

void MainWindow::on_actionAddReaders_triggered()
{
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
    // check if DBs are selected via business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.db) {
        auto result = BusinessLogic::validateDatabases(*facade.db, true, true, false);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("NO DATABASE SELECTED"), result.errorMessage);
            return;
        }
    }

    // ==== BEFORE SHOWING ====
    // clear text fields
    ui->txtBookSearch_addloan->clear();
    ui->txtReaderSearch_addloan->clear();
    ui->txtBookSelected_addloan->clear();
    ui->txtReaderSelected_addloan->clear();
    ui->spnLoanDays_addloan->setValue(14);

    ui->workspaces->setCurrentIndex(13); // page_14 (Add Loan)
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
    // check whether username and password are the same
    // check if both passwords match
    // check password score - if it is low, warn user
    // if both pass, create DB if not exist, make hash from usr+pwd+salt, write to DB
    // then let user in with the role that they registered with (bypass login)
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


void MainWindow::on_btnLogin_clicked()
{
    // check if empty usr/pwd
    // if not - make hash from usr + pwd + salt
    // then search for it in user DB using SQL
    // if EOF - no such account, refuse
    // if not EOF - log in
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
        for (int i = 0; i < ui->lstSearch_editbooks->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_editbooks->item(i);
            if (item->text().contains(last_book_added.title) && item->text().contains(last_book_added.author))
            {
                delete ui->lstSearch_editbooks->takeItem(i);
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
    book.title = ui->txtTitle_addbooks->text();
    book.author = ui->txtAuthor_addbooks->text();
    book.id = ui->txtID_addbooks->text().toInt();
    book.location = ui->cboLocation_addbooks->currentText();
    book.category = ui->cboCategory_addbooks->currentText();
    book.status = ui->cboStatus_addbooks->currentText();
    book.createdAt = QDateTime::currentDateTime().toString(Qt::ISODate);
    book.updatedAt = QDateTime::currentDateTime().toString(Qt::ISODate);

    // Validate through business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.books) {
        auto result = BusinessLogic::addBook(*facade.books, book);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), result.errorMessage);
            return;
        }
    }

    QString display = book.toDisplayString();

    // add to list widget for immediate feedback
    ui->lstSearch_editbooks->addItem(display);

    // store for undo
    last_book_added = book;

    QMessageBox::information(this, tr("SUCCESS"), tr("Book added"));

    // clear input fields
    ui->txtTitle_addbooks->clear();
    ui->txtAuthor_addbooks->clear();
    ui->txtID_addbooks->clear();
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
    newBook.title = ui->txtTitle_editbooks->text();
    newBook.author = ui->txtAuthor_editbooks->text();
    newBook.id = ui->txtID_editbooks->text().toInt();
    newBook.location = ui->cboLocation_editbooks->currentText();
    newBook.category = ui->cboCategory_editbooks->currentText();
    newBook.status = ui->cboStatus_editbooks->currentText();
    newBook.createdAt = book_selected.createdAt;
    newBook.updatedAt = QDateTime::currentDateTime().toString(Qt::ISODate);

    // Validate through business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.books) {
        auto result = BusinessLogic::updateBook(*facade.books, newBook);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), result.errorMessage);
            return;
        }
    }

    QString display = newBook.toDisplayString();

    // find and replace the selected item in the list
    for (int i = 0; i < ui->lstSearch_editbooks->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_editbooks->item(i);
        if (item->text().contains(book_selected.title) && item->text().contains(book_selected.author))
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
    ui->txtName_managecategories->setText(item->text());
    category_selected.name = item->text();
}

// lst clicked in edit books - populate edit fields
void MainWindow::on_lstSearch_editbooks_itemClicked(QListWidgetItem *item)
{
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 6)
    {
        ui->txtTitle_editbooks->setText(parts[0].trimmed());
        ui->txtAuthor_editbooks->setText(parts[1].trimmed());
        ui->cboLocation_editbooks->setCurrentText(parts[2].trimmed());
        ui->cboCategory_editbooks->setCurrentText(parts[3].trimmed());
        ui->cboStatus_editbooks->setCurrentText(parts[4].trimmed());
        QString id_part = parts[5];
        if (id_part.startsWith("ID: "))
            id_part = id_part.mid(4);
        ui->txtID_editbooks->setText(id_part.trimmed());

        // Populate book_selected DTO
        book_selected.title = parts[0].trimmed();
        book_selected.author = parts[1].trimmed();
        book_selected.location = parts[2].trimmed();
        book_selected.category = parts[3].trimmed();
        book_selected.status = parts[4].trimmed();
        book_selected.id = id_part.trimmed().toInt();

        // Also populate loan form if visible
        ui->txtBookSelected_addloan->setText(text);
    }
}

// lst clicked in undo removed books - populate undo fields
void MainWindow::on_lstSearch_undoremovebooks_itemClicked(QListWidgetItem *item)
{
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 2)
    {
        ui->txtValue_undoremovebooks->setText(parts[0].trimmed());
        QString filter_field = parts[1].trimmed();
        int idx = ui->cboValue_undoremovebooks->findText(filter_field);
        if (idx >= 0)
            ui->cboValue_undoremovebooks->setCurrentIndex(idx);
    }
}

// lst clicked in remove books - store selected book for removal
void MainWindow::on_lstSearch_removebooks_itemClicked(QListWidgetItem *item)
{
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 6)
    {
        book_selected.title = parts[0].trimmed();
        book_selected.author = parts[1].trimmed();
        book_selected.location = parts[2].trimmed();
        book_selected.category = parts[3].trimmed();
        book_selected.status = parts[4].trimmed();
        QString id_part = parts[5];
        if (id_part.startsWith("ID: "))
            id_part = id_part.mid(4);
        book_selected.id = id_part.trimmed().toInt();
    }
}

// lst clicked in manage locations - populate location name
void MainWindow::on_lstSearch_managelocations_itemClicked(QListWidgetItem *item)
{
    ui->txtName_managelocations->setText(item->text());
    location_selected.name = item->text();
}

// lst clicked in edit readers - populate edit fields
void MainWindow::on_lstSearch_editreaders_itemClicked(QListWidgetItem *item)
{
    QString text = item->text();
    QStringList parts = text.split(" | ");
    if (parts.size() >= 5)
    {
        ui->txtName_editreaders->setText(parts[0].trimmed());
        ui->txtSurname_editreaders->setText(parts[1].trimmed());
        ui->txtGrade_editreaders->setText(parts[2].trimmed());
        ui->txtClass_editreaders->setText(parts[3].trimmed());
        ui->txtID_editreaders->setText(parts[4].trimmed());

        // Populate reader_selected DTO
        reader_selected.name = parts[0].trimmed();
        reader_selected.surname = parts[1].trimmed();
        reader_selected.grade = parts[2].trimmed().toShort();
        reader_selected.classGroup = parts[3].trimmed().at(0);
        reader_selected.studentId = parts[4].trimmed();
        reader_selected.id = reader_selected.studentId.toInt();

        // Also populate loan form if visible
        ui->txtReaderSelected_addloan->setText(text);
    }
}

void MainWindow::on_btnUndoAll_undoremovebooks_clicked()
{
    QString undo_term = ui->txtValue_undoremovebooks->text();
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

    QString filter_field = ui->cboValue_undoremovebooks->currentText();
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
        for (int i = 0; i < ui->lstSearch_undoremovebooks->count(); ++i)
        {
            if (!ui->lstSearch_undoremovebooks->item(i)->isHidden())
                match_count++;
        }
        QMessageBox::information(this, tr("UNDO ALL (FRONTEND)"),
            tr("Would restore %1 matching books (requires DB for full implementation)").arg(match_count));
        undo_term = "";
        ui->txtValue_undoremovebooks->clear();
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
            for (int i = 0; i < ui->lstSearch_removebooks->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_removebooks->item(i);
                if (item->text().contains(book_selected.title) && item->text().contains(book_selected.author))
                {
                    delete ui->lstSearch_removebooks->takeItem(i);
                    break;
                }
            }

            // store for undo
            last_book_removed = book_selected;

            // clear selection
            book_selected = DTO::BookDTO{};

            // clear input fields
            ui->txtTitle_removebooks->clear();
            ui->txtAuthor_removebooks->clear();
            ui->txtID_removebooks->clear();

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
            ui->lstSearch_managecategories->addItem(last_category_removed.name);
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
            for (int i = 0; i < ui->lstSearch_managecategories->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_managecategories->item(i);
                if (item->text() == category_selected.name) // current name
                {
                    item->setText(last_category_edited.name);
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
            for (int i = 0; i < ui->lstSearch_managecategories->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_managecategories->item(i);
                if (item->text() == last_category_added.name)
                {
                    delete ui->lstSearch_managecategories->takeItem(i);
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
    QString category_toadd = ui->txtName_managecategories->text();

    DTO::CategoryDTO category;
    category.name = category_toadd;

    // Validate through business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.categories) {
        auto result = BusinessLogic::addCategory(*facade.categories, category);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), result.errorMessage);
            return;
        }
    }

    // add to list widget (frontend only)
    ui->lstSearch_managecategories->addItem(category_toadd);

    // inform user if it worked
    // -> if worked, set last_category_added to category_toadd
    last_category_added.name = category_toadd; // !!! ONLY HAPPENS UPON SUCCESS !!!
    category_toadd = "";

    // clear input field
    ui->txtName_managecategories->clear();

    QMessageBox::information(this, tr("SUCCESS"), tr("Category added"));
}

// edit category button
void MainWindow::on_btnEditCategory_managecategories_clicked()
{
    QString category_toadd = ui->txtName_managecategories->text();
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
    else if (category_selected.name == category_toadd) // if 'edited' category is the same as the selected one
    {
        QMessageBox::critical(this, tr("Category not changed!"), tr("Category is unchanged from selected category! Not making any changes!"));
        return;
    }

    DTO::CategoryDTO category;
    category.id = category_selected.id;
    category.name = category_toadd;

    // Validate through business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.categories) {
        auto result = BusinessLogic::updateCategory(*facade.categories, category);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), result.errorMessage);
            return;
        }
    }

    // edit in list widget (frontend only)
    for (int i = 0; i < ui->lstSearch_managecategories->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_managecategories->item(i);
        if (item->text() == category_selected.name)
        {
            item->setText(category_toadd);
            break;
        }
    }

    // inform user if it worked
    // -> if worked, set last_category_edited
    last_category_edited = category_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!

    // update category_selected
    category_selected.name = category_toadd;
    category_toadd = "";

    // clear input field
    ui->txtName_managecategories->clear();

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
        for (int i = 0; i < ui->lstSearch_managecategories->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_managecategories->item(i);
            if (item->text() == category_selected.name)
            {
                delete ui->lstSearch_managecategories->takeItem(i);
                break;
            }
        }

        // inform user if it worked
        // -> if worked, set last_category_removed to category_selected
        last_category_removed = category_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!

        // clear selection
        category_selected = DTO::CategoryDTO{};

        // clear input field
        ui->txtName_managecategories->clear();

        QMessageBox::information(this, tr("SUCCESS"), tr("Category removed (frontend only - requires DB implementation)"));
    }
}

// edit location button
void MainWindow::on_btnEditLocation_managelocations_clicked()
{
    QString location_toadd = ui->txtName_managelocations->text();
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
    else if (location_selected.name == location_toadd) // if 'edited' location is the same as the selected one
    {
        QMessageBox::critical(this, tr("Location not changed!"), tr("Location is unchanged from selected location! Not making any changes!"));
        return;
    }

    DTO::LocationDTO location;
    location.id = location_selected.id;
    location.name = location_toadd;

    // Validate through business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.locations) {
        auto result = BusinessLogic::updateLocation(*facade.locations, location);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), result.errorMessage);
            return;
        }
    }

    // edit in list widget (frontend only)
    for (int i = 0; i < ui->lstSearch_managelocations->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_managelocations->item(i);
        if (item->text() == location_selected.name)
        {
            item->setText(location_toadd);
            break;
        }
    }

    // inform user if it worked
    // -> if worked, set last_location_edited
    last_location_edited = location_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!

    // update location_selected
    location_selected.name = location_toadd;
    location_toadd = "";

    // clear input field
    ui->txtName_managelocations->clear();

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
        for (int i = 0; i < ui->lstSearch_managelocations->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_managelocations->item(i);
            if (item->text() == location_selected.name)
            {
                delete ui->lstSearch_managelocations->takeItem(i);
                break;
            }
        }

        // inform user if it worked
        // -> if worked, set last_location_removed to location_selected
        last_location_removed = location_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!

        // clear selection
        location_selected = DTO::LocationDTO{};

        // clear input field
        ui->txtName_managelocations->clear();

        QMessageBox::information(this, tr("SUCCESS"), tr("Location removed (frontend only - requires DB implementation)"));
    }
}

// add location button
void MainWindow::on_btnAddLocation_managelocations_clicked()
{
    QString location_toadd = ui->txtName_managelocations->text();

    DTO::LocationDTO location;
    location.name = location_toadd;

    // Validate through business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.locations) {
        auto result = BusinessLogic::addLocation(*facade.locations, location);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), result.errorMessage);
            return;
        }
    }

    // add to list widget (frontend only)
    ui->lstSearch_managelocations->addItem(location_toadd);

    // inform user if it worked
    // -> if worked, set last_location_added to location_toadd
    last_location_added.name = location_toadd; // !!! ONLY HAPPENS UPON SUCCESS !!!
    location_toadd = "";

    // clear input field
    ui->txtName_managelocations->clear();

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
            ui->lstSearch_managelocations->addItem(last_location_removed.name);
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
            for (int i = 0; i < ui->lstSearch_managelocations->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_managelocations->item(i);
                if (item->text() == last_location_added.name)
                {
                    delete ui->lstSearch_managelocations->takeItem(i);
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
            for (int i = 0; i < ui->lstSearch_managelocations->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_managelocations->item(i);
                if (item->text() == location_selected.name) // current name
                {
                    item->setText(last_location_edited.name);
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
        QString display = last_book_removed.toDisplayString();
        ui->lstSearch_undoremovebooks->addItem(display);

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
            for (int i = 0; i < ui->lstSearch_undoremovebooks->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_undoremovebooks->item(i);
                if (item->text().contains(last_book_undone.title) && item->text().contains(last_book_undone.author))
                {
                    delete ui->lstSearch_undoremovebooks->takeItem(i);
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
    QString search_term = ui->txtSearch_undoremovereaders->text();
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
    QString filter_field = ui->cboValue_undoremovereaders->currentText().toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_undoremovereaders->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_undoremovereaders->item(i);
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

    if (!found && ui->lstSearch_undoremovereaders->count() > 0)
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
        ui->txtValue_undoremovereaders->setText(parts[0].trimmed());
        QString filter_field = parts[1].trimmed();
        int idx = ui->cboValue_undoremovereaders->findText(filter_field);
        if (idx >= 0)
            ui->cboValue_undoremovereaders->setCurrentIndex(idx);
    }
}

// undo all removed readers
void MainWindow::on_btnUndoAll_undoremovereaders_clicked()
{
    QString undo_term = ui->txtValue_undoremovereaders->text();
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

    QString filter_field = ui->cboValue_undoremovereaders->currentText();
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
        for (int i = 0; i < ui->lstSearch_undoremovereaders->count(); ++i)
        {
            if (!ui->lstSearch_undoremovereaders->item(i)->isHidden())
                match_count++;
        }
        QMessageBox::information(this, tr("UNDO ALL (FRONTEND)"),
            tr("Would restore %1 matching readers (requires DB for full implementation)").arg(match_count));
        undo_term = "";
        ui->txtValue_undoremovereaders->clear();
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
        QString display = reader_selected.toDisplayString();
        ui->lstSearch_undoremovereaders->addItem(display);

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
        for (int i = 0; i < ui->lstSearch_undoremovereaders->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_undoremovereaders->item(i);
            if (item->text().contains(last_reader_undone.name) && item->text().contains(last_reader_undone.surname))
            {
                delete ui->lstSearch_undoremovereaders->takeItem(i);
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
    reader.name = ui->txtName_addreaders->text();
    reader.surname = ui->txtSurname_addreaders->text();
    reader.grade = ui->txtGrade_addreaders->text().toShort();
    reader.classGroup = ui->txtClass_addreaders->text().at(0);
    reader.studentId = ui->txtID_addreaders->text();
    reader.id = reader.studentId.toInt();
    reader.createdAt = QDateTime::currentDateTime().toString(Qt::ISODate);
    reader.updatedAt = QDateTime::currentDateTime().toString(Qt::ISODate);

    // Validate through business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.readers) {
        auto result = BusinessLogic::addReader(*facade.readers, reader);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), result.errorMessage);
            return;
        }
    }

    QString display = reader.toDisplayString();

    // add to list widget for immediate feedback
    ui->lstSearch_editreaders->addItem(display);

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
    newReader.name = ui->txtName_editreaders->text();
    newReader.surname = ui->txtSurname_editreaders->text();
    newReader.grade = ui->txtGrade_editreaders->text().toShort();
    newReader.classGroup = ui->txtClass_editreaders->text().at(0);
    newReader.studentId = ui->txtID_editreaders->text();
    newReader.id = newReader.studentId.toInt();
    newReader.createdAt = reader_selected.createdAt;
    newReader.updatedAt = QDateTime::currentDateTime().toString(Qt::ISODate);

    // Validate through business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.readers) {
        auto result = BusinessLogic::updateReader(*facade.readers, newReader);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), result.errorMessage);
            return;
        }
    }

    QString display = newReader.toDisplayString();

    // find and replace the selected item in the list
    for (int i = 0; i < ui->lstSearch_editreaders->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_editreaders->item(i);
        if (item->text().contains(reader_selected.name) && item->text().contains(reader_selected.surname))
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
    QString search_term = ui->txtBookSearch_addloan->text();
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

    for (int i = 0; i < ui->lstSearch_editbooks->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_editbooks->item(i);
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

    if (!found && ui->lstSearch_editbooks->count() > 0)
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
void MainWindow::on_btnSearchReader_addloan_clicked()
{
    QString search_term = ui->txtReaderSearch_addloan->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("Please enter a reader name or surname to search"));
        return;
    }

    if (database_readers.isEmpty())
    {
        QMessageBox::critical(this, tr("NO DATABASE SELECTED"), tr("No reader database selected"));
        return;
    }

    QString filter = search_term.toLower();
    bool found = false;

    for (int i = 0; i < ui->lstSearch_editreaders->count(); ++i)
    {
        QListWidgetItem *item = ui->lstSearch_editreaders->item(i);
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

    if (!found && ui->lstSearch_editreaders->count() > 0)
    {
        QMessageBox::information(this, tr("NO RESULTS"), tr("No matching readers found"));
    }
    else if (found)
    {
        QMessageBox::information(this, tr("SEARCH COMPLETE"), tr("Click a reader in the Edit Readers list to select it, then return here"));
    }
}

// add loan button
void MainWindow::on_btnAddLoan_addloan_clicked()
{
    // check if DBs are selected via business logic
    auto& facade = BusinessLogic::BusinessLogicFacade::instance();
    if (facade.db) {
        auto result = BusinessLogic::validateDatabases(*facade.db, true, true, false);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("NO DATABASE SELECTED"), result.errorMessage);
            return;
        }
    }

    // check if book is selected
    if (ui->txtBookSelected_addloan->text().isEmpty())
    {
        QMessageBox::critical(this, tr("NO BOOK SELECTED"), tr("Please select a book for the loan"));
        return;
    }

    // check if reader is selected
    if (ui->txtReaderSelected_addloan->text().isEmpty())
    {
        QMessageBox::critical(this, tr("NO READER SELECTED"), tr("Please select a reader for the loan"));
        return;
    }

    int loanDays = ui->spnLoanDays_addloan->value();

    // Parse book ID from selected book text
    QString bookText = ui->txtBookSelected_addloan->text();
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
    QString readerText = ui->txtReaderSelected_addloan->text();
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
    loan.loanDate = QDateTime::currentDateTime().toString(Qt::ISODate);
    loan.dueDate = QDateTime::currentDateTime().addDays(loanDays).toString(Qt::ISODate);
    loan.status = "active";
    loan.returnDate = "";

    // Validate through business logic (already declared facade above)
    if (facade.loans) {
        auto result = BusinessLogic::addLoan(*facade.loans, loan);
        if (!result.isValid) {
            QMessageBox::critical(this, tr("VALIDATION ERROR"), result.errorMessage);
            return;
        }
    }

    QMessageBox::information(this, tr("SUCCESS"), tr("Loan created successfully"));

    // Clear form
    ui->txtBookSearch_addloan->clear();
    ui->txtReaderSearch_addloan->clear();
    ui->txtBookSelected_addloan->clear();
    ui->txtReaderSelected_addloan->clear();
    ui->spnLoanDays_addloan->setValue(14);
}

// clear loan form
void MainWindow::on_btnClear_addloan_clicked()
{
    ui->txtBookSearch_addloan->clear();
    ui->txtReaderSearch_addloan->clear();
    ui->txtBookSelected_addloan->clear();
    ui->txtReaderSelected_addloan->clear();
    ui->spnLoanDays_addloan->setValue(14);
}

