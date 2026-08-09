#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow() override;

private slots:
    void on_btnClear_username_register_clicked();

    void on_btnClear_password1_register_clicked();

    void on_btnClear_password2_register_clicked();

    void on_btnHelp_pwdStrenght_register_clicked();

    void on_btnHelp_role_register_clicked();

    void on_btnRegister_clicked();

    void on_actionClose_Application_triggered();

    void on_btnLogin_clicked();

    void on_btnHelp_role_login_clicked();

    void on_actionLog_out_triggered();

    void on_actionLog_in_triggered();

    void on_actionRegister_triggered();

    void set_to_backdrop();

    void on_actionAddBooks_triggered();

    void on_actionEditBooks_triggered();

    void on_btnClear_title_addbooks_clicked();

    void on_btnClear_author_addbooks_clicked();

    void on_btnClear_id_addbooks_clicked();

    void on_btnAddBook_addbooks_clicked();

    void on_btnClear_title_editbooks_clicked();

    void on_btnClear_author_editbooks_clicked();

    void on_btnClear_id_editbooks_clicked();

    void on_btnUndoEdit_editbooks_clicked();

    void on_btnEditBook_editbooks_clicked();

    void on_btnSearch_editbooks_clicked();

    void on_actionRemove_triggered();

private:
    Ui::MainWindow *ui;
};
#endif // MAINWINDOW_H
