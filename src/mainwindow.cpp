#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QMessageBox>

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

