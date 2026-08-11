#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QListWidget>

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

    void on_btnSearch_managecategories_clicked();

    void on_lstSearch_managecategories_itemClicked(QListWidgetItem *item);

    void on_actionManage_Categories_triggered();

    void on_actionUndo_Removed_triggered();

    void on_actionRemoveBooks_triggered();

    void on_btnClear_name_managecategories_clicked();

    void on_btnUndoAdd_addbooks_clicked();

    void on_btnUndoRemove_managecategories_clicked();

    void on_btnUndoEdit_managecategories_clicked();

    void on_btnUndoAdd_managecategories_clicked();

    void on_btnAddCategory_managecategories_clicked();

    void on_btnEditCategory_managecategories_clicked();

    void on_btnRemoveCategory_managecategories_clicked();

    void on_btnSearch_undoremovebooks_clicked();

    void on_btnUndoAll_undoremovebooks_clicked();

    void on_btnSearch_managelocations_clicked();

    void on_actionManage_Locations_triggered();

    void on_btnClear_name_managelocations_clicked();

    void on_btnRemoveLocation_managelocations_clicked();

    void on_btnEditLocation_managelocations_clicked();

    void on_btnAddLocation_managelocations_clicked();

    void on_btnUndoRemove_managelocations_clicked();

    void on_btnUndoAdd_managelocations_clicked();

    void on_btnUndoEdit_managelocations_clicked();

    void on_btnUndoSelected_undoremovebooks_clicked();

    void on_btnRedoRemove_undoremovebooks_clicked();

    void on_btnRedoAllSelected_undoremovebooks_clicked();

private:
    Ui::MainWindow *ui;
};
#endif // MAINWINDOW_H
