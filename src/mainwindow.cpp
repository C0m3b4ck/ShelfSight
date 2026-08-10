#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QMessageBox>
#include <QListWidget>

// =============== VARIABLES =====================
std::string last_book_added[5] = {"title", "author", "location", "category", "status"}; //title, author, location, category, status
std::string last_book_edited[5] = {"title", "author", "location", "category", "status"}; //title, author, location, category, status
std::string last_book_removed[5] = {"title", "author", "location", "category", "status"}; //title, author, location, category, status

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
void MainWindow::on_btnSearch_editbooks_clicked()
{
    // if user query is empty, throw error
    QString to_check_string = ui->txtSearch_editbooks->text();
    if (sanitize_string(to_check_string).isEmpty())
    {
        QMessageBox::critical(this, tr("SEARCH CANNOT BE EMPTY"), tr("SEARCH CANNOT BE EMPTY!!!"));
    }
    else
    {
        // get results from SQL DB
        // while not EOF - populate list widget
    }
}

void MainWindow::on_btnSearch_managecategories_clicked()
{
    // if user query is empty, throw error
    QString to_check_string = ui->txtSearch_managecategories->text();
    if (sanitize_string(to_check_string).isEmpty())
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

////////////////////////////// MENU BUTTONS //////////////////////////////////////////////
void MainWindow::on_actionLog_out_triggered()
{
    // change logged in bool to false or whatever the checking function will be
    // set role to null, switch workspace to backdrop
    set_to_backdrop();
}

void MainWindow::on_actionLog_in_triggered()
{
    // navigate to login workspace (magic numbers)
    ui->workspaces->setCurrentIndex(1);
}

void MainWindow::on_actionRegister_triggered()
{
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
    // update comboBoxes for: category, status, locations from DBs
    ui->workspaces->setCurrentIndex(4);
}

void MainWindow::on_actionManage_Categories_triggered()
{
    // check if categories file exists
    // -> if not, create
    // ==== BEFORE SHOWING ====
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
    // update listBox from deleted dbs
    ui->workspaces->setCurrentIndex(6);
}

void MainWindow::on_actionUndo_Removed_triggered()
{
    // check if a DB is selected
    // -> if yes - find its deleted books section
    // -> if no - ask about loading default config
    //      -> if yes, use default and navigate to add books
    //      -> if no, navigate to DB selection

    // ==== BEFORE SHOWING ====
    // update listBox from deleted dbs
    ui->workspaces->setCurrentIndex(2); // backdrop
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
    // when adding, all of the info is stored in last_book
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

