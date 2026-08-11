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
// =============== VARIABLES =====================
// ====== books - for undoing =====
QString last_book_added[5] = {"", "", "", "", ""}; //title, author, location, category, status
QString last_book_edited[5] = {"", "", "", "", ""}; //title, author, location, category, status
QString last_book_removed[5] = {"", "", "", "", ""}; //title, author, location, category, status
QString last_book_undone[5] = {"", "", "", "", ""}; //title, author, location, category, status
std::vector<QString> last_undoall_books;
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
void sanitize_variables() //clears variables (called my MainWindow and upon logging out/re-logging)
{
    // ====== books - for undoing =====
    last_book_added[5].clear();
    last_book_edited[5].clear();
    last_book_removed[5].clear();
    last_book_undone[5].clear();
    last_undoall_books.clear();
    // ====== categories - for undoing =====
    last_category_added = "";
    last_category_edited[2].clear(); // previous_name, current_name
    last_category_removed = "";
    category_selected = ""; //name gotten after user clicks on lst with categories
    // ====== locations - for undoing =====
    last_location_added = "";
    last_location_edited[2].clear(); // previous_name, current_name
    last_location_removed = "";
    location_selected = ""; //name gotten after user clicks on lst with categories
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
    // if user query is empty, throw error
    QString search_term = ui->txtSearch_editbooks->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
    }
    else
    {
        // get results from SQL DB
        // while not EOF - populate list widget
    }
}

// search manage categories
void MainWindow::on_btnSearch_managecategories_clicked()
{
    // if user query is empty, throw error
    QString search_term = ui->txtSearch_managecategories->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
    }
    else
    {
        // get results from SQL DB
        // while not EOF - populate list widget
    }
}

// search undo book removal
void MainWindow::on_btnSearch_undoremovebooks_clicked()
{
    // if user query is empty, throw error
    QString search_term = ui->txtSearch_undoremovebooks->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
    }
    else
    {
        // get results from SQL DB
        // while not EOF - populate list widget
    }
}

// search manage locations
void MainWindow::on_btnSearch_managelocations_clicked()
{
    // if user query is empty, throw error
    QString search_term = ui->txtSearch_managelocations->text();
    if (sanitize_string(search_term).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
    }
    else
    {
        // get results from SQL DB
        // while not EOF - populate list widget
    }
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

void MainWindow::on_actionManage_Locations_triggered()
{
    // if location DB does not exist - make blank
    // clear text fields
    // update listBox from location DB
    ui->workspaces->setCurrentIndex(8);
}
///// =========== HELPERS ============
void MainWindow::set_to_backdrop()
{
    // sets to backdrop (currently 2)
    ui->workspaces->setCurrentIndex(2);
}
////////////////////////////// FUNCTIONAL BUTTONS /////////////////////////////////////////
// =============== ACCOUT MANAGEMENT ==================
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

// =============== BOOKS ====================

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
    // check if ID checking is checked
    //  -> if yes, check if ID exists in book DB
    //      -> if yes, warn user about adding Y/N
    //          -> if yes, add to DB
    //          -> if no, break function
    //      -> if no, do nothing
    // -> if no, add to DB and inform user
}

// edit book button
void MainWindow::on_btnEditBook_editbooks_clicked()
{
    // check if ID checking is checked
    //  -> if yes, check if ID exists in book DB
    //      -> if yes, warn user about adding Y/N
    //          -> if yes, add to DB
    //          -> if no, break function
    //      -> if no, do nothing
    // -> if no, replace the previous line in DB and inform user
}

// lst clicked in manage categories
void MainWindow::on_lstSearch_managecategories_itemClicked(QListWidgetItem *item)
{
    //populate txtName_managecategories.Text with the category name
}

void MainWindow::on_btnUndoAll_undoremovebooks_clicked()
{
    QString undo_term = ui->txtValue_undoremovebooks->text();
    if(is_qstring_empty(undo_term) == true) // empty term
    {
        QMessageBox::critical(this, tr("Empty term!"), tr("Please input term before proceeding to undo!"));
    }
    // check if cboValue_undoremovebooks is set
    else
    {
        // run function that:
        // * gets all values via SQL (maybe into array)
        // * adds them to actual book DB
        // -> if succesfull, removes from removed_books DB
        undo_term = "";
    }
}

// ============== CATEGORIES ==============
// undo remove categories button
void MainWindow::on_btnUndoRemove_managecategories_clicked()
{
    // when removing, name is stored in last_category_edited
    if (is_qstring_empty(last_category_removed) == true)
    {
        QMessageBox::critical(this, tr("Nothing to undo!"), tr("Nothing to undo!"));
    }
    else // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Undo removal?"));
        box.setText(
            tr(
                "Are you sure you want to undo removing category:\n %1 \n")
                .arg(last_category_removed));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // re-add category into category DB
        }
    }
}
// undo edit categories button
void MainWindow::on_btnUndoEdit_managecategories_clicked()
{
    // when removing, name is stored in last_category_edited
    if (is_qstring_empty(last_category_edited[0]) == true && is_qstring_empty(last_category_edited[1]))
    {
        QMessageBox::critical(this, tr("Nothing to undo!"), tr("Nothing to undo!"));
    }
    else    // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Undo edit?"));
        box.setText(
            tr(
                "Are you sure you want to undo editing category:\n %1 \n")
                .arg(last_category_edited[0]));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // call function to re-write the line[1] with previous name [0]
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
    }
    else // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Undo add?"));
        box.setText(
            tr(
                "Are you sure you want to undo adding category:\n %1 \n")
                .arg(last_category_added));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // remove the category from DB
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
        // add to DB
        // infom user if it worked
        // -> if worked, set last_category_added to category_toadd
        last_category_added = category_toadd; // !!! ONLY HAPPENS UPON SUCCESS !!!
        category_toadd = "";
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
        QMessageBox::critical(this, tr("Category not changed!"), tr("Category is unchanged from selected category! Not making any changes to DB!"));
    }
    else
    {
        // add to DB
        // infom user if it worked
        // -> if worked, set last_category_added to category_toadd
        last_category_edited[0] = category_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!
        last_category_edited[1] = category_toadd; // !!! ONLY HAPPENS UPON SUCCESS !!!
        category_toadd = "";
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
        // remove from DB
        // infom user if it worked
        // -> if worked, set last_category_deleted to category_selected
        last_category_removed = category_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!
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
        QMessageBox::critical(this, tr("Location not changed!"), tr("Location is unchanged from selected location! Not making any changes to DB!"));
    }
    else
    {
        // add to DB
        // infom user if it worked
        // -> if worked, set last_location_added to location_toadd
        last_location_edited[0] = location_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!
        last_location_edited[1] = location_toadd; // !!! ONLY HAPPENS UPON SUCCESS !!!
        location_toadd = "";
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
        // remove from DB
        // infom user if it worked
        // -> if worked, set last_location_deleted to location_selected
        last_location_removed = location_selected; // !!! ONLY HAPPENS UPON SUCCESS !!!
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
        // add to DB
        // infom user if it worked
        // -> if worked, set last_location_added to location_toadd
        last_location_added = location_toadd; // !!! ONLY HAPPENS UPON SUCCESS !!!
        location_toadd = "";
    }
}

// undo remove manage locations button
void MainWindow::on_btnUndoRemove_managelocations_clicked()
{
    // when removing, name is stored in last_location_edited
    if (is_qstring_empty(last_location_removed) == true)
    {
        QMessageBox::critical(this, tr("Nothing to undo!"), tr("Nothing to undo!"));
    }
    else
    {
        // confirm if user wants to proceed
        // check if there is something to remove
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Undo removal?"));
        box.setText(
            tr(
                "Are you sure you want to undo removing location:\n %1 \n")
                .arg(last_location_removed));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // re-add location into location DB
        }
    }
}

// undo add manage locations button
void MainWindow::on_btnUndoAdd_managelocations_clicked()
{
    // when adding, name is stored in last_location_added
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
                "Are you sure you want to undo adding location:\n %1 \n")
                .arg(last_location_added));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // remove the location from DB
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
            // re-write the line[1] with previous name [0]
        }
    }
}

// undo selected undo remove books button
void MainWindow::on_btnUndoSelected_undoremovebooks_clicked()
{
    // when adding, all of the info is stored in last_book_removed
    // confirm if user wants to proceed
    QMessageBox box(this);
    box.setIcon(QMessageBox::Warning);
    box.setWindowTitle(tr("Undo edit?"));
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
        // add the line back into book DB
        // -> if succesfull, remove from deleted book DB
    }
}

// redo remove remove books buttons
void MainWindow::on_btnRedoRemove_undoremovebooks_clicked()
{
    // when adding, all of the info is stored in last_book_removed
    if (last_book_undone[0] == "")
    {
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("NOTHING TO UNDO"));
    }
    else // confirm if user wants to proceed
    {
        QMessageBox box(this);
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Redo removal?"));
        box.setText(
            tr(
                "Are you sure you want to redo the removal of this book:\n"
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
            // add the line back into book DB
            // -> if succesfull, remove from deleted book DB
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
        QMessageBox::critical(this, tr("NOTHING TO UNDO"), tr("NOTHING TO UNDO"));
    }
    else // confirm if user wants to proceed
    {
        box.setIcon(QMessageBox::Warning);
        box.setWindowTitle(tr("Re-do removal?"));
        box.setText(
            tr(
                "Are you sure you want to re-delete %1 books?"
                )
                .arg(std::to_string(num_redelete_all)));
        box.setStandardButtons(QMessageBox::Yes | QMessageBox::No);
        box.setDefaultButton(QMessageBox::No);

        if (box.exec() == QMessageBox::Yes) {
            // add the line back into book DB
            // -> if succesfull, remove from deleted book DB
        }
    }
}

