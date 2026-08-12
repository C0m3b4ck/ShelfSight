#include "mainwindow.h"
#include "ui_mainwindow.h"
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
QString last_book_added[5] = {"", "", "", "", ""}; //title, author, location, category, status
QString last_book_edited[5] = {"", "", "", "", ""}; //title, author, location, category, status
QString last_book_removed[5] = {"", "", "", "", ""}; //title, author, location, category, status
QString last_book_undone[5] = {"", "", "", "", ""}; //title, author, location, category, status
QString book_selected[5] = {"", "", "", "", ""}; //title, author, location, category, status
std::vector<QString> last_undoall_books;
// ====== readers - for undoing =====
QString last_reader_added[5] = {"", "", "", "", ""}; //name, surname, grade, class, ID
QString last_reader_edited[5] = {"", "", "", "", ""}; //name, surname, grade, class, ID
QString last_reader_removed[5] = {"", "", "", "", ""}; //name, surname, grade, class, ID
QString last_reader_undone[5] = {"", "", "", "", ""}; //name, surname, grade, class, ID
QString reader_selected[5] = {"", "", "", "", ""}; //name, surname, grade, class, ID
std::vector<QString> last_undoall_readers;
// ====== categories - for undoing =====
QString last_category_added = "";
QString last_category_edited[2] = {"", ""}; // previous_name, current_name
QString last_category_removed = "";
QString category_selected = ""; //name gotten after user clicks on lst with categories
// ====== locations - for undoing =====
QString last_location_added = "";
QString last_location_edited[2] = {"", ""}; // previous_name, current_name
QString last_location_removed = "";
QString location_selected = ""; //name gotten after user clicks on lst with categories

// =============== PRE-DEFINITONS ===============
QString sanitize_string(QString stringValue);
bool is_qstring_empty(QString stringtocheck);

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
    for (int i = 0; i < 5; ++i) {
        last_book_added[i].clear();
        last_book_edited[i].clear();
        last_book_removed[i].clear();
        last_book_undone[i].clear();
        book_selected[i].clear();
    }
    last_undoall_books.clear();
    // ====== readers - for undoing =====
    for (int i = 0; i < 5; ++i) {
        last_reader_added[i].clear();
        last_reader_edited[i].clear();
        last_reader_removed[i].clear();
        last_reader_undone[i].clear();
        reader_selected[i].clear();
    }
    last_undoall_readers.clear();
    // ====== categories - for undoing =====
    last_category_added = "";
    for (int i = 0; i < 2; ++i) {
        last_category_edited[i].clear();
    }
    last_category_removed = "";
    category_selected = "";
    // ====== locations - for undoing =====
    last_location_added = "";
    for (int i = 0; i < 2; ++i) {
        last_location_edited[i].clear();
    }
    last_location_removed = "";
    location_selected = "";
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
        reader_selected[0] = ui->txtName_removereaders->text();
        reader_selected[1] = ui->txtSurname_removereaders->text();
        reader_selected[2] = ui->txtGrade_removereaders->text();
        reader_selected[3] = ui->txtClass_removereaders->text();
        reader_selected[4] = ui->txtID_removereaders->text();
    }
}

// undo removal readers
void MainWindow::on_btnUndoRemoval_removereaders_clicked()
{
    // check if there is something to undo
    if (is_qstring_empty(reader_selected[0]))
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
                     .arg(reader_selected[0])
                     .arg(reader_selected[1])
                     .arg(reader_selected[2])
                     .arg(reader_selected[3])
                     .arg(reader_selected[4]));
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
    if (is_qstring_empty(last_reader_removed[0]))
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
                     .arg(last_reader_removed[0])
                     .arg(last_reader_removed[1])
                     .arg(last_reader_removed[2])
                     .arg(last_reader_removed[3])
                     .arg(last_reader_removed[4]));
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
QString sanitize_string(QString stringValue)
{
    stringValue.replace("\\", "\\\\");
    stringValue.replace("'", "\\'");
    stringValue.replace("\"", "\\\"");
    stringValue.replace('\n', "");
    stringValue.replace('\r', "");
    stringValue.replace('\0', "");
    stringValue.replace(QChar(0x1A), "");
    return stringValue;
}

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
    // when adding, all of the info is stored in last_book_edit
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
            "Status: %5"
            )
            .arg(last_book_edited[0])
            .arg(last_book_edited[1])
            .arg(last_book_edited[2])
            .arg(last_book_edited[3])
            .arg(last_book_edited[4]));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // remove the line based on the info in last_book
    }
}

// undo add buttons
void MainWindow::on_btnUndoAdd_addbooks_clicked()
{
    // when adding, all of the info is stored in last_book_add
    // confirm if user wants to proceed
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo edit?"));
    box.setText(
        tr(
            "Are you sure you want to undo add book:\n"
            "Title: %1\n"
            "Author: %2\n"
            "Location: %3\n"
            "Category: %4\n"
            "Status: %5"
            )
            .arg(last_book_added[0])
            .arg(last_book_added[1])
            .arg(last_book_added[2])
            .arg(last_book_added[3])
            .arg(last_book_added[4]));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // remove the line based on the info in last_book
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
    // check fields
    else if(is_qstring_empty(ui->txtTitle_addbooks->text()) == true) // title
    {
        QMessageBox::critical(this, tr("EMPTY TITLE"), tr("Title cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtAuthor_addbooks->text()) == true) // author
    {
        QMessageBox::critical(this, tr("EMPTY AUTHOR"), tr("Author cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtID_addbooks->text()) == true) // ID
    {
        QMessageBox::critical(this, tr("EMPTY ID"), tr("ID cannot be empty!"));
        return;
    }
    // check if comboBoxes have valid selections
    else if (ui->cboLocation_addbooks->currentText().isEmpty())
    {
        QMessageBox::critical(this, tr("EMPTY LOCATION"), tr("Please select a location!"));
        return;
    }
    else if (ui->cboCategory_addbooks->currentText().isEmpty())
    {
        QMessageBox::critical(this, tr("EMPTY CATEGORY"), tr("Please select a category!"));
        return;
    }
    else if (ui->cboStatus_addbooks->currentText().isEmpty())
    {
        QMessageBox::critical(this, tr("EMPTY STATUS"), tr("Please select a status!"));
        return;
    }
    // all validations passed - add book to list (frontend only, no DB)
    else
    {
        QString title = ui->txtTitle_addbooks->text();
        QString author = ui->txtAuthor_addbooks->text();
        QString id = ui->txtID_addbooks->text();
        QString location = ui->cboLocation_addbooks->currentText();
        QString category = ui->cboCategory_addbooks->currentText();
        QString status = ui->cboStatus_addbooks->currentText();

        QString display = QString("%1 | %2 | %3 | %4 | %5 | ID: %6")
                              .arg(title).arg(author).arg(location).arg(category).arg(status).arg(id);

        // add to list widget for immediate feedback
        ui->lstSearch_editbooks->addItem(display);

        // store for undo
        last_book_added[0] = title;
        last_book_added[1] = author;
        last_book_added[2] = location;
        last_book_added[3] = category;
        last_book_added[4] = status;

        QMessageBox::information(this, tr("SUCCESS"), tr("Book added (frontend only - requires DB implementation)"));

        // clear input fields
        ui->txtTitle_addbooks->clear();
        ui->txtAuthor_addbooks->clear();
        ui->txtID_addbooks->clear();
    }
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
    // check fields
    else if(is_qstring_empty(ui->txtTitle_editbooks->text()) == true) // title
    {
        QMessageBox::critical(this, tr("EMPTY TITLE"), tr("Title cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtAuthor_editbooks->text()) == true) // author
    {
        QMessageBox::critical(this, tr("EMPTY AUTHOR"), tr("Author cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtID_editbooks->text()) == true) // ID
    {
        QMessageBox::critical(this, tr("EMPTY ID"), tr("ID cannot be empty!"));
        return;
    }
    // check if comboBoxes have valid selections
    else if (ui->cboLocation_editbooks->currentText().isEmpty())
    {
        QMessageBox::critical(this, tr("EMPTY LOCATION"), tr("Please select a location!"));
        return;
    }
    else if (ui->cboCategory_editbooks->currentText().isEmpty())
    {
        QMessageBox::critical(this, tr("EMPTY CATEGORY"), tr("Please select a category!"));
        return;
    }
    else if (ui->cboStatus_editbooks->currentText().isEmpty())
    {
        QMessageBox::critical(this, tr("EMPTY STATUS"), tr("Please select a status!"));
        return;
    }
    // check if a book is selected for editing
    else if (is_qstring_empty(book_selected[0]))
    {
        QMessageBox::critical(this, tr("NO BOOK SELECTED"), tr("Please select a book from the list to edit!"));
        return;
    }
    // all validations passed - edit book in list (frontend only, no DB)
    else
    {
        QString title = ui->txtTitle_editbooks->text();
        QString author = ui->txtAuthor_editbooks->text();
        QString id = ui->txtID_editbooks->text();
        QString location = ui->cboLocation_editbooks->currentText();
        QString category = ui->cboCategory_editbooks->currentText();
        QString status = ui->cboStatus_editbooks->currentText();

        QString display = QString("%1 | %2 | %3 | %4 | %5 | ID: %6")
                              .arg(title).arg(author).arg(location).arg(category).arg(status).arg(id);

        // find and replace the selected item in the list
        for (int i = 0; i < ui->lstSearch_editbooks->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_editbooks->item(i);
            if (item->text().contains(book_selected[0]) && item->text().contains(book_selected[1]))
            {
                item->setText(display);
                break;
            }
        }

        // store for undo
        last_book_edited[0] = book_selected[0];
        last_book_edited[1] = book_selected[1];
        last_book_edited[2] = book_selected[2];
        last_book_edited[3] = book_selected[3];
        last_book_edited[4] = book_selected[4];

        // update book_selected with new values
        book_selected[0] = title;
        book_selected[1] = author;
        book_selected[2] = location;
        book_selected[3] = category;
        book_selected[4] = status;

        QMessageBox::information(this, tr("SUCCESS"), tr("Book edited (frontend only - requires DB implementation)"));
    }
}

// lst clicked in manage categories
void MainWindow::on_lstSearch_managecategories_itemClicked(QListWidgetItem *item)
{
    ui->txtName_managecategories->setText(item->text());
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
        book_selected[0] = parts[0].trimmed();
        book_selected[1] = parts[1].trimmed();
        book_selected[2] = parts[2].trimmed();
        book_selected[3] = parts[3].trimmed();
        book_selected[4] = parts[4].trimmed();
        QString id_part = parts[5];
        if (id_part.startsWith("ID: "))
            id_part = id_part.mid(4);
    }
}

// lst clicked in manage locations - populate location name
void MainWindow::on_lstSearch_managelocations_itemClicked(QListWidgetItem *item)
{
    ui->txtName_managelocations->setText(item->text());
    location_selected = item->text();
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
    else if (is_qstring_empty(book_selected[0]) == true)
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
                "Status: %5"
                )
                .arg(book_selected[0])
                .arg(book_selected[1])
                .arg(book_selected[2])
                .arg(book_selected[3])
                .arg(book_selected[4]));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // remove from list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_removebooks->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_removebooks->item(i);
                if (item->text().contains(book_selected[0]) && item->text().contains(book_selected[1]))
                {
                    delete ui->lstSearch_removebooks->takeItem(i);
                    break;
                }
            }

            // store for undo
            last_book_removed[0] = book_selected[0];
            last_book_removed[1] = book_selected[1];
            last_book_removed[2] = book_selected[2];
            last_book_removed[3] = book_selected[3];
            last_book_removed[4] = book_selected[4];

            // clear selection
            book_selected[0] = "";
            book_selected[1] = "";
            book_selected[2] = "";
            book_selected[3] = "";
            book_selected[4] = "";

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
    if (is_qstring_empty(last_category_removed) == true)
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
                .arg(last_category_removed));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // re-add category to list widget (frontend only)
            ui->lstSearch_managecategories->addItem(last_category_removed);
            last_category_removed = "";
            QMessageBox::information(this, tr("SUCCESS"), tr("Category restored (frontend only - requires DB implementation)"));
        }
    }
}
// undo edit categories button
void MainWindow::on_btnUndoEdit_managecategories_clicked()
{
    // when editing, previous name is stored in last_category_edited[0], new name in [1]
    if (is_qstring_empty(last_category_edited[0]) == true && is_qstring_empty(last_category_edited[1]))
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
                .arg(last_category_edited[0]));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // revert category name in list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_managecategories->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_managecategories->item(i);
                if (item->text() == last_category_edited[1])
                {
                    item->setText(last_category_edited[0]);
                    break;
                }
            }
            last_category_edited[0] = "";
            last_category_edited[1] = "";
            QMessageBox::information(this, tr("SUCCESS"), tr("Category edit undone (frontend only - requires DB implementation)"));
        }
    }
}

// undo add categories button
void MainWindow::on_btnUndoAdd_managecategories_clicked()
{
    // when adding, name is stored in last_category_added
    if (is_qstring_empty(last_category_added) == true)
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
                .arg(last_category_added));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // remove category from list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_managecategories->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_managecategories->item(i);
                if (item->text() == last_category_added)
                {
                    delete ui->lstSearch_managecategories->takeItem(i);
                    break;
                }
            }
            last_category_added = "";
            QMessageBox::information(this, tr("SUCCESS"), tr("Category add undone (frontend only - requires DB implementation)"));
        }
    }
}

// add category button
void MainWindow::on_btnAddCategory_managecategories_clicked()
{
    QString category_toadd = ui->txtName_managecategories->text();
    if(is_qstring_empty(category_toadd) == true)
    {
        QMessageBox::critical(this, tr("Empty category!"), tr("Category cannot be empty! Please input category before adding!"));
    }
    else
    {
        // add to list widget (frontend only)
        ui->lstSearch_managecategories->addItem(category_toadd);

        // inform user if it worked
        // -> if worked, set last_category_added to category_toadd
        last_category_added = category_toadd; // !!! ONLY HAPPENS UPON SUCCESS !!!
        category_toadd = "";

        // clear input field
        ui->txtName_managecategories->clear();

        QMessageBox::information(this, tr("SUCCESS"), tr("Category added (frontend only - requires DB implementation)"));
    }
}

// edit category button
void MainWindow::on_btnEditCategory_managecategories_clicked()
{
    QString category_toadd = ui->txtName_managecategories->text();
    if(is_qstring_empty(category_toadd) == true)
    {
        QMessageBox::critical(this, tr("Empty category!"), tr("Category cannot be empty! Please input category before editing!"));
    }
    else if(is_qstring_empty(category_selected) == true) // user has not selected any category to edit
    {
        QMessageBox::critical(this, tr("Target not selected!"), tr("Category to be edited is not selected! Please select before proceeding!"));
    }
    else if (category_selected == category_toadd) // if 'edited' category is the same as the selected one
    {
        QMessageBox::critical(this, tr("Category not changed!"), tr("Category is unchanged from selected category! Not making any changes!"));
    }
    else
    {
        // edit in list widget (frontend only)
        for (int i = 0; i < ui->lstSearch_managecategories->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_managecategories->item(i);
            if (item->text() == category_selected)
            {
                item->setText(category_toadd);
                break;
            }
        }

        // inform user if it worked
        // -> if worked, set last_category_edited
        last_category_edited[0] = category_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!
        last_category_edited[1] = category_toadd; // !!! ONLY HAPPENS UPON SUCCESS !!!

        // update category_selected
        category_selected = category_toadd;
        category_toadd = "";

        // clear input field
        ui->txtName_managecategories->clear();

        QMessageBox::information(this, tr("SUCCESS"), tr("Category edited (frontend only - requires DB implementation)"));
    }
}

// remove category button
void MainWindow::on_btnRemoveCategory_managecategories_clicked()
{
    if(is_qstring_empty(category_selected) == true) // user has not selected any category to delete
    {
        QMessageBox::critical(this, tr("Target not selected!"), tr("No category selected for deletion!"));
    }
    else
    {
        // remove from list widget (frontend only)
        for (int i = 0; i < ui->lstSearch_managecategories->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_managecategories->item(i);
            if (item->text() == category_selected)
            {
                delete ui->lstSearch_managecategories->takeItem(i);
                break;
            }
        }

        // inform user if it worked
        // -> if worked, set last_category_removed to category_selected
        last_category_removed = category_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!

        // clear selection
        category_selected = "";

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
    }
    else if(is_qstring_empty(location_selected) == true) // user has not selected any location to edit
    {
        QMessageBox::critical(this, tr("Target not selected!"), tr("Location to be edited is not selected! Please select before proceeding!"));
    }
    else if (location_selected == location_toadd) // if 'edited' location is the same as the selected one
    {
        QMessageBox::critical(this, tr("Location not changed!"), tr("Location is unchanged from selected location! Not making any changes!"));
    }
    else
    {
        // edit in list widget (frontend only)
        for (int i = 0; i < ui->lstSearch_managelocations->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_managelocations->item(i);
            if (item->text() == location_selected)
            {
                item->setText(location_toadd);
                break;
            }
        }

        // inform user if it worked
        // -> if worked, set last_location_edited
        last_location_edited[0] = location_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!
        last_location_edited[1] = location_toadd; // !!! ONLY HAPPENS UPON SUCCESS !!!

        // update location_selected
        location_selected = location_toadd;
        location_toadd = "";

        // clear input field
        ui->txtName_managelocations->clear();

        QMessageBox::information(this, tr("SUCCESS"), tr("Location edited (frontend only - requires DB implementation)"));
    }
}

// remove location button
void MainWindow::on_btnRemoveLocation_managelocations_clicked()
{
    if(is_qstring_empty(location_selected) == true) // user has not selected any location to delete
    {
        QMessageBox::critical(this, tr("Target not selected!"), tr("No location selected for deletion!"));
    }
    else
    {
        // remove from list widget (frontend only)
        for (int i = 0; i < ui->lstSearch_managelocations->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_managelocations->item(i);
            if (item->text() == location_selected)
            {
                delete ui->lstSearch_managelocations->takeItem(i);
                break;
            }
        }

        // inform user if it worked
        // -> if worked, set last_location_removed to location_selected
        last_location_removed = location_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!

        // clear selection
        location_selected = "";

        // clear input field
        ui->txtName_managelocations->clear();

        QMessageBox::information(this, tr("SUCCESS"), tr("Location removed (frontend only - requires DB implementation)"));
    }
}

// add location button
void MainWindow::on_btnAddLocation_managelocations_clicked()
{
    QString location_toadd = ui->txtName_managelocations->text();
    if(is_qstring_empty(location_toadd) == true)
    {
        QMessageBox::critical(this, tr("Empty location!"), tr("Location cannot be empty! Please input location before adding!"));
    }
    else
    {
        // add to list widget (frontend only)
        ui->lstSearch_managelocations->addItem(location_toadd);

        // inform user if it worked
        // -> if worked, set last_location_added to location_toadd
        last_location_added = location_toadd; // !!! ONLY HAPPENS UPON SUCCESS !!!
        location_toadd = "";

        // clear input field
        ui->txtName_managelocations->clear();

        QMessageBox::information(this, tr("SUCCESS"), tr("Location added (frontend only - requires DB implementation)"));
    }
}

// undo remove manage locations button
void MainWindow::on_btnUndoRemove_managelocations_clicked()
{
    // when removing, name is stored in last_location_removed
    if (is_qstring_empty(last_location_removed) == true)
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
                .arg(last_location_removed));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // re-add location to list widget (frontend only)
            ui->lstSearch_managelocations->addItem(last_location_removed);
            last_location_removed = "";
            QMessageBox::information(this, tr("SUCCESS"), tr("Location restored (frontend only - requires DB implementation)"));
        }
    }
}

// undo add manage locations button
void MainWindow::on_btnUndoAdd_managelocations_clicked()
{
    // when adding, name is stored in last_location_added
    if (is_qstring_empty(last_location_added) == true)
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
                .arg(last_location_added));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // remove location from list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_managelocations->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_managelocations->item(i);
                if (item->text() == last_location_added)
                {
                    delete ui->lstSearch_managelocations->takeItem(i);
                    break;
                }
            }
            last_location_added = "";
            QMessageBox::information(this, tr("SUCCESS"), tr("Location add undone (frontend only - requires DB implementation)"));
        }
    }
}

// undo edit manage locations button
void MainWindow::on_btnUndoEdit_managelocations_clicked()
{
    // when removing, name is stored in last_location_edited
    if (is_qstring_empty(last_location_removed) == true)
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
                .arg(last_location_edited[0]));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // revert location name in list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_managelocations->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_managelocations->item(i);
                if (item->text() == last_location_edited[1])
                {
                    item->setText(last_location_edited[0]);
                    break;
                }
            }
            last_location_edited[0] = "";
            last_location_edited[1] = "";
            QMessageBox::information(this, tr("SUCCESS"), tr("Location edit undone (frontend only - requires DB implementation)"));
        }
    }
}

// undo selected undo remove books button
void MainWindow::on_btnUndoSelected_undoremovebooks_clicked()
{
    // when removing, all of the info is stored in last_book_removed
    // check if there is something to undo
    if (is_qstring_empty(last_book_removed[0]))
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
            "Status: %5"
            )
            .arg(last_book_removed[0])
            .arg(last_book_removed[1])
            .arg(last_book_removed[2])
            .arg(last_book_removed[3])
            .arg(last_book_removed[4]));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // add the book back to list widget (frontend only)
        QString display = QString("%1 | %2 | %3 | %4 | %5 | ID: %6")
                              .arg(last_book_removed[0])
                              .arg(last_book_removed[1])
                              .arg(last_book_removed[2])
                              .arg(last_book_removed[3])
                              .arg(last_book_removed[4])
                              .arg(""); // ID not stored in last_book_removed
        ui->lstSearch_undoremovebooks->addItem(display);

        // store for redo
        last_book_undone[0] = last_book_removed[0];
        last_book_undone[1] = last_book_removed[1];
        last_book_undone[2] = last_book_removed[2];
        last_book_undone[3] = last_book_removed[3];
        last_book_undone[4] = last_book_removed[4];

        // clear undo buffer
        last_book_removed[0] = "";
        last_book_removed[1] = "";
        last_book_removed[2] = "";
        last_book_removed[3] = "";
        last_book_removed[4] = "";

        QMessageBox::information(this, tr("SUCCESS"), tr("Book restored (frontend only - requires DB implementation)"));
    }
}

// redo remove remove books buttons
void MainWindow::on_btnRedoRemove_undoremovebooks_clicked()
{
    // when undoing, the book info is stored in last_book_undone
    if (is_qstring_empty(last_book_undone[0]))
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
                "Status: %5"
                )
                .arg(last_book_undone[0])
                .arg(last_book_undone[1])
                .arg(last_book_undone[2])
                .arg(last_book_undone[3])
                .arg(last_book_undone[4]));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // remove the book from list widget (frontend only)
            for (int i = 0; i < ui->lstSearch_undoremovebooks->count(); ++i)
            {
                QListWidgetItem *item = ui->lstSearch_undoremovebooks->item(i);
                if (item->text().contains(last_book_undone[0]) && item->text().contains(last_book_undone[1]))
                {
                    delete ui->lstSearch_undoremovebooks->takeItem(i);
                    break;
                }
            }

            // restore to removed buffer for future undo
            last_book_removed[0] = last_book_undone[0];
            last_book_removed[1] = last_book_undone[1];
            last_book_removed[2] = last_book_undone[2];
            last_book_removed[3] = last_book_undone[3];
            last_book_removed[4] = last_book_undone[4];

            // clear redo buffer
            last_book_undone[0] = "";
            last_book_undone[1] = "";
            last_book_undone[2] = "";
            last_book_undone[3] = "";
            last_book_undone[4] = "";

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
    if (is_qstring_empty(reader_selected[0]))
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
            .arg(reader_selected[0])
            .arg(reader_selected[1])
            .arg(reader_selected[2])
            .arg(reader_selected[3])
            .arg(reader_selected[4]));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // add the reader back to list widget (frontend only)
        QString display = QString("%1 | %2 | %3 | %4 | %5")
                              .arg(reader_selected[0])
                              .arg(reader_selected[1])
                              .arg(reader_selected[2])
                              .arg(reader_selected[3])
                              .arg(reader_selected[4]);
        ui->lstSearch_undoremovereaders->addItem(display);

        // store for redo
        last_reader_undone[0] = reader_selected[0];
        last_reader_undone[1] = reader_selected[1];
        last_reader_undone[2] = reader_selected[2];
        last_reader_undone[3] = reader_selected[3];
        last_reader_undone[4] = reader_selected[4];

        // clear undo buffer
        reader_selected[0] = "";
        reader_selected[1] = "";
        reader_selected[2] = "";
        reader_selected[3] = "";
        reader_selected[4] = "";

        QMessageBox::information(this, tr("SUCCESS"), tr("Reader restored (frontend only - requires DB implementation)"));
    }
}

// redo remove removed readers
void MainWindow::on_btnRedoRemove_undoremovereaders_clicked()
{
    // check if there is something to redo
    if (is_qstring_empty(last_reader_undone[0]))
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
            .arg(last_reader_undone[0])
            .arg(last_reader_undone[1])
            .arg(last_reader_undone[2])
            .arg(last_reader_undone[3])
            .arg(last_reader_undone[4]));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // remove the reader from list widget (frontend only)
        for (int i = 0; i < ui->lstSearch_undoremovereaders->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_undoremovereaders->item(i);
            if (item->text().contains(last_reader_undone[0]) && item->text().contains(last_reader_undone[1]))
            {
                delete ui->lstSearch_undoremovereaders->takeItem(i);
                break;
            }
        }

        // restore to undo buffer
        reader_selected[0] = last_reader_undone[0];
        reader_selected[1] = last_reader_undone[1];
        reader_selected[2] = last_reader_undone[2];
        reader_selected[3] = last_reader_undone[3];
        reader_selected[4] = last_reader_undone[4];

        // clear redo buffer
        last_reader_undone[0] = "";
        last_reader_undone[1] = "";
        last_reader_undone[2] = "";
        last_reader_undone[3] = "";
        last_reader_undone[4] = "";

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
    // check fields
    else if(is_qstring_empty(ui->txtName_addreaders->text()) == true) // name
    {
        QMessageBox::critical(this, tr("EMPTY NAME"), tr("Name cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtSurname_addreaders->text()) == true) // surname
    {
        QMessageBox::critical(this, tr("EMPTY SURNAME"), tr("Surname cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtGrade_addreaders->text()) == true) // grade
    {
        QMessageBox::critical(this, tr("EMPTY GRADE"), tr("Grade cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtClass_addreaders->text()) == true) // class
    {
        QMessageBox::critical(this, tr("EMPTY CLASS"), tr("Class cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtID_addreaders->text()) == true) // ID
    {
        QMessageBox::critical(this, tr("EMPTY ID"), tr("ID cannot be empty!"));
        return;
    }
    // all validations passed - add reader to list (frontend only, no DB)
    else
    {
        QString name = ui->txtName_addreaders->text();
        QString surname = ui->txtSurname_addreaders->text();
        QString grade = ui->txtGrade_addreaders->text();
        QString class_ = ui->txtClass_addreaders->text();
        QString id = ui->txtID_addreaders->text();

        QString display = QString("%1 | %2 | %3 | %4 | %5")
                              .arg(name).arg(surname).arg(grade).arg(class_).arg(id);

        // add to list widget for immediate feedback
        ui->lstSearch_editreaders->addItem(display);

        // store for undo
        last_reader_added[0] = name;
        last_reader_added[1] = surname;
        last_reader_added[2] = grade;
        last_reader_added[3] = class_;
        last_reader_added[4] = id;

        QMessageBox::information(this, tr("SUCCESS"), tr("Reader added (frontend only - requires DB implementation)"));

        // clear input fields
        ui->txtName_addreaders->clear();
        ui->txtSurname_addreaders->clear();
        ui->txtGrade_addreaders->clear();
        ui->txtClass_addreaders->clear();
        ui->txtID_addreaders->clear();
    }
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
    // check fields
    else if(is_qstring_empty(ui->txtName_editreaders->text()) == true) // name
    {
        QMessageBox::critical(this, tr("EMPTY NAME"), tr("Name cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtSurname_editreaders->text()) == true) // surname
    {
        QMessageBox::critical(this, tr("EMPTY SURNAME"), tr("Surname cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtGrade_editreaders->text()) == true) // grade
    {
        QMessageBox::critical(this, tr("EMPTY GRADE"), tr("Grade cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtClass_editreaders->text()) == true) // class
    {
        QMessageBox::critical(this, tr("EMPTY CLASS"), tr("Class cannot be empty!"));
        return;
    }
    else if(is_qstring_empty(ui->txtID_editreaders->text()) == true) // ID
    {
        QMessageBox::critical(this, tr("EMPTY ID"), tr("ID cannot be empty!"));
        return;
    }
    // check if a reader is selected for editing
    else if (is_qstring_empty(reader_selected[0]))
    {
        QMessageBox::critical(this, tr("NO READER SELECTED"), tr("Please select a reader from the list to edit!"));
        return;
    }
    // all validations passed - edit reader in list (frontend only, no DB)
    else
    {
        QString name = ui->txtName_editreaders->text();
        QString surname = ui->txtSurname_editreaders->text();
        QString grade = ui->txtGrade_editreaders->text();
        QString class_ = ui->txtClass_editreaders->text();
        QString id = ui->txtID_editreaders->text();

        QString display = QString("%1 | %2 | %3 | %4 | %5")
                              .arg(name).arg(surname).arg(grade).arg(class_).arg(id);

        // find and replace the selected item in the list
        for (int i = 0; i < ui->lstSearch_editreaders->count(); ++i)
        {
            QListWidgetItem *item = ui->lstSearch_editreaders->item(i);
            if (item->text().contains(reader_selected[0]) && item->text().contains(reader_selected[1]))
            {
                item->setText(display);
                break;
            }
        }

        // store for undo
        last_reader_edited[0] = reader_selected[0];
        last_reader_edited[1] = reader_selected[1];
        last_reader_edited[2] = reader_selected[2];
        last_reader_edited[3] = reader_selected[3];
        last_reader_edited[4] = reader_selected[4];

        // update reader_selected with new values
        reader_selected[0] = name;
        reader_selected[1] = surname;
        reader_selected[2] = grade;
        reader_selected[3] = class_;
        reader_selected[4] = id;

        QMessageBox::information(this, tr("SUCCESS"), tr("Reader edited (frontend only - requires DB implementation)"));
    }
}

// undo edit edit readers
void MainWindow::on_btnUndoEdit_editreaders_clicked()
{
    // when adding, all of the info is stored in last_book_edit
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
            .arg(last_reader_edited[0])
            .arg(last_reader_edited[1])
            .arg(last_reader_edited[2])
            .arg(last_reader_edited[3])
            .arg(last_reader_edited[4]));
    box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
    box.setDefaultButton(QMessageBox::No);

    if (box.exec() == QMessageBox::Yes) {
        // remove the line based on the info in last_reader
    }
}

