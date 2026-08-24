#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QListWidget>
#include <optional>
#include "domain.h"
#include "businesslogic.h"

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
    bool isLoggedIn() const;
    void setLoggedIn(bool loggedIn);
    bool checkLoginRequired(bool requireDatabases = true);
    bool checkRoleRequired(BusinessLogic::RequiredRole required, bool requireDatabases = true);
    Domain::User::Role getCurrentUserRole() const;
    void setCurrentUser(const Domain::User& user);
    void clearCurrentUser();

private slots:
    // Register page
    void on_btnClear_username_register_clicked();
    void on_btnClear_password1_register_clicked();
    void on_btnClear_password2_register_clicked();
    void on_btnHelp_pwdStrenght_register_clicked();
    void on_btnHelp_role_register_clicked();
    void on_btnRegister_clicked();
    void on_chkHide_register_toggled(bool checked);
    void on_txtPwd1_register_textChanged(const QString &text);

    // Login page
    void on_btnLogin_clicked();
    void on_btnHelp_role_login_clicked();
    void on_chkHide_login_toggled(bool checked);

    void on_actionClose_Application_triggered();

    void on_actionLog_out_triggered();
    void on_actionLog_in_triggered();
    void on_actionRegister_triggered();

    void set_to_backdrop();

    void on_actionAddBooks_triggered();
    void on_actionEditBooks_triggered();

    // Add Books page
    void on_btnClear_title_book_clicked();
    void on_btnClear_author_book_clicked();
    void on_btnClear_id_book_clicked();
    void on_btnAdd_book_clicked();
    // Edit Books page
    void on_btnClear_title_book_edit_clicked();
    void on_btnClear_author_book_edit_clicked();
    void on_btnClear_id_book_edit_clicked();
    void on_btnUndoEdit_book_clicked();
    void on_btnEdit_book_clicked();
    void on_btnSearch_book_edit_clicked();

    void on_btnSearch_category_clicked();
    void on_lstSearch_category_itemClicked(QListWidgetItem *item);
    void on_lstSearch_book_edit_itemClicked(QListWidgetItem *item);
    void on_lstSearch_undobooks_itemClicked(QListWidgetItem *item);
    void on_lstSearch_book_remove_itemClicked(QListWidgetItem *item);
    void on_lstSearch_managelocations_itemClicked(QListWidgetItem *item);
    void on_lstSearch_reader_edit_itemClicked(QListWidgetItem *item);
    void on_lstSearch_removereaders_itemClicked(QListWidgetItem *item);

    void on_actionManage_Categories_triggered();
    void on_actionUndo_Removed_triggered();
    void on_actionUndo_Removed_2_triggered();
    void on_actionRemoveBooks_triggered();

    void on_btnClear_name_category_clicked();
    void on_btnUndoAdd_book_clicked();
    void on_btnUndoRemove_category_clicked();
    void on_btnUndoEdit_category_clicked();
    void on_btnUndoAdd_category_clicked();
    void on_btnAdd_category_clicked();
    void on_btnEdit_category_clicked();
    void on_btnRemove_category_clicked();

    void on_btnSearch_undobooks_clicked();
    void on_btnSearch_book_remove_clicked();
    void on_btnUndoAll_undobooks_clicked();
    void on_btnSearch_location_clicked();
    void on_actionManage_Locations_triggered();

    void on_btnClear_name_location_clicked();
    void on_btnRemove_location_clicked();
    void on_btnEdit_location_clicked();
    void on_btnAdd_location_clicked();
    void on_btnUndoRemove_location_clicked();
    void on_btnUndoAdd_location_clicked();
    void on_btnUndoEdit_location_clicked();

    void on_btnUndoSelected_undobooks_clicked();
    void on_btnRedoRemove_undobooks_clicked();
    void on_btnRedoAllSelected_undobooks_clicked();

    void on_btnSearch_undoreaders_clicked();
    void on_lstSearch_undoreaders_itemClicked(QListWidgetItem *item);
    void on_btnUndoAll_undoreaders_clicked();
    void on_btnUndoSelected_undoreaders_clicked();
    void on_btnRedoRemove_undoreaders_clicked();
    void on_btnRedoAllSelected_undoreaders_clicked();

    void on_actionAddReaders_triggered();

    void on_btnClear_name_addreaders_clicked();
    void on_btnClear_surname_addreaders_clicked();
    void on_btnClear_grade_addreaders_clicked();
    void on_btnClear_class_addreaders_clicked();
    void on_btnClear_id_addreaders_clicked();
    void on_btnAddBook_addreaders_clicked();
    void on_btnUndoAdd_addreaders_clicked();

    void on_btnEditBook_editreaders_clicked();
    void on_btnUndoEdit_editreaders_clicked();

    void on_btnRemove_book_clicked();
    void on_btnSearch_reader_edit_clicked();
    void on_btnSearch_reader_remove_clicked();
    void on_btnRemove_reader_clicked();
    void on_btnUndoRemoval_reader_clicked();
    void on_btnUndoLast_reader_clicked();
    void on_btnClear_name_reader_remove_clicked();
    void on_btnClear_surname_reader_remove_clicked();
    void on_btnClear_grade_reader_remove_clicked();
    void on_btnClear_class_reader_remove_clicked();
    void on_btnClear_id_reader_remove_clicked();

    void on_actionRemoveReaders_triggered();
    void on_actionEditReaders_triggered();

    void on_actionAddLoans_triggered();
    void on_btnSearch_book_clicked();
    void on_btnSearch_reader_clicked();
    void on_btnAdd_loan_clicked();
    void on_btnClear_loan_clicked();

    void on_actionEditLoans_triggered();
    void on_actionSearchLoans_triggered();
    void on_btnSearch_loan_clicked();
    void on_lstSearch_loan_itemClicked(QListWidgetItem *item);
    void on_btnUpdate_loan_clicked();
    void on_btnReturn_loan_clicked();
    void on_btnClear_loan_edit_clicked();

    void on_actionDatabase_Selection_triggered();
    void loadDbConfigs();
    void on_cboDbConfigs_currentIndexChanged(int index);
    void on_btnLoadDbConfig_clicked();
    void on_btnBrowseBooksDb_clicked();
    void on_btnBrowseReadersDb_clicked();
    void on_btnBrowseLoansDb_clicked();
    void on_btnSaveAsDefault_clicked();
    void on_btnSaveCustomConfig_clicked();
    void on_btnTestConnection_clicked();
    void on_btnCreateNewDb_clicked();
    void on_btnDeleteConfig_clicked();
    void on_lstSavedConfigs_itemDoubleClicked(QListWidgetItem *item);

    void on_btnFilter_loanstatus_clicked();
    void on_btnSearch_loanstatus_clicked();
    void on_btnRefresh_loanstatus_clicked();
    void on_btnOverdueReport_loanstatus_clicked();
    void on_lstSearch_loanstatus_itemDoubleClicked(QListWidgetItem *item);

    // Additional slots from mainwindow.cpp implementations
    void on_btnSearch_undoremovebooks_clicked();
    void on_btnSearch_managelocations_clicked();
    void on_btnSearch_removebooks_clicked();
    void on_btnSearch_editreaders_clicked();
    void on_btnSearch_removereaders_clicked();
    void on_btnRemove_removereaders_clicked();
    void on_btnUndoRemoval_removereaders_clicked();
    void on_btnUndoLast_removereaders_clicked();
    void on_btnClear_name_removereaders_clicked();
    void on_btnClear_surname_removereaders_clicked();
    void on_btnClear_grade_removereaders_clicked();
    void on_btnClear_class_removereaders_clicked();
    void on_btnClear_id_removereaders_clicked();

    void on_btnUndoEdit_editbooks_clicked();
    void on_btnUndoAdd_addbooks_clicked();
    void on_btnAddBook_addbooks_clicked();
    void on_btnEditBook_editbooks_clicked();

    void on_lstSearch_managecategories_itemClicked(QListWidgetItem *item);
    void on_lstSearch_undoremovebooks_itemClicked(QListWidgetItem *item);
    void on_lstSearch_removebooks_itemClicked(QListWidgetItem *item);

    void on_btnUndoAll_undoremovebooks_clicked();
    void on_btnRemove_removebooks_clicked();

    void on_btnUndoRemove_managecategories_clicked();
    void on_btnUndoEdit_managecategories_clicked();
    void on_btnUndoAdd_managecategories_clicked();
    void on_btnAddCategory_managecategories_clicked();
    void on_btnEditCategory_managecategories_clicked();
    void on_btnRemoveCategory_managecategories_clicked();

    void on_btnEditLocation_managelocations_clicked();
    void on_btnRemoveLocation_managelocations_clicked();
    void on_btnAddLocation_managelocations_clicked();
    void on_btnUndoRemove_managelocations_clicked();
    void on_btnUndoAdd_managelocations_clicked();
    void on_btnUndoEdit_managelocations_clicked();

    void on_btnUndoSelected_undoremovebooks_clicked();
    void on_btnRedoRemove_undoremovebooks_clicked();
    void on_btnRedoAllSelected_undoremovebooks_clicked();

    void on_btnSearch_undoremovereaders_clicked();
    void on_lstSearch_undoremovereaders_itemClicked(QListWidgetItem *item);
    void on_btnUndoAll_undoremovereaders_clicked();
    void on_btnUndoSelected_undoremovereaders_clicked();
    void on_btnRedoRemove_undoremovereaders_clicked();
    void on_btnRedoAllSelected_undoremovereaders_clicked();

    void on_btnSearchBook_addloan_clicked();
    void on_btnSearchReader_clicked();
    void on_btnAddLoan_addloan_clicked();
    void on_btnClear_addloan_clicked();
    void on_btnSearchLoan_editloan_clicked();
    void on_lstSearch_editloan_itemClicked(QListWidgetItem *item);
    void on_btnUpdateLoan_editloan_clicked();
    void on_btnReturnLoan_editloan_clicked();
    void on_btnClear_editloan_clicked();

private:
    Ui::MainWindow *ui;
    bool m_isLoggedIn = false;
    std::optional<Domain::User> m_currentUser;
};

#endif // MAINWINDOW_H
