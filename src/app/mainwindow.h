#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QListWidget>
#include <optional>
#include "domain.h"
#include "businesslogic.h"
#include "dataaccess.h"
#include "worklog.h"

QT_BEGIN_NAMESPACE
namespace Ui {
class MainWindow;
}
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(DataAccess::IDataAccess& db, QWidget *parent = nullptr);
    ~MainWindow() override;

protected:
    void closeEvent(QCloseEvent *event) override;

public:
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
    void on_btnCheckId_book_clicked();
    void on_txtId_book_textChanged(const QString &text);
    void on_chkAutogenerateID_book_toggled(bool checked);
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
    void on_lstSearch_reader_edit_itemClicked(QListWidgetItem *item);

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
    void on_lstSearch_location_itemClicked(QListWidgetItem *item);

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
    void on_chkAutogenerateID_addreaders_toggled(bool checked);
    void on_btnCheckId_addreaders_clicked();

    void on_btnRemove_book_clicked();
    void on_btnSearch_reader_edit_clicked();
    void on_btnEdit_reader_clicked();
    void on_btnUndoEdit_reader_clicked();
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
    void on_lstSearch_book_itemClicked(QListWidgetItem *item);
    void on_btnSearch_reader_clicked();
    void on_lstSearch_reader_itemClicked(QListWidgetItem *item);
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
    void on_actionCreate_Database_triggered();
    void loadDbConfigs();
    void on_chkTelemetry_toggled(bool checked);
    void on_cboDbConfigs_currentIndexChanged(int index);
    void on_btnLoadDbConfig_clicked();
    void on_btnBrowseBooksDb_clicked();
    void on_btnBrowseReadersDb_clicked();
    void on_btnBrowseLoansDb_clicked();
    void on_btnSaveAsDefault_clicked();
    void on_btnSaveCustomConfig_clicked();
    void on_btnTestConnection_clicked();
    void on_btnCreateNewDb_clicked();
    void on_btnCreateStarterDbs_clicked();
    void on_btnDeleteConfig_clicked();
    void on_lstSavedConfigs_itemDoubleClicked(QListWidgetItem *item);

    void on_btnFilter_loanstatus_clicked();
    void on_btnSearch_loanstatus_clicked();
    void on_btnRefresh_loanstatus_clicked();
    void on_btnOverdueReport_loanstatus_clicked();
    void on_lstSearch_loanstatus_itemDoubleClicked(QListWidgetItem *item);

    // Menu actions - new pages
    void on_actionMake_Report_triggered();
    void on_actionManage_Fines_triggered();
    void on_actionMake_Card_triggered();
    void on_actionBackups_triggered();
    void on_actionPreferences_triggered();
    void on_actionAccounts_triggered();
    void on_actionTroubleshoot_triggered();
    void on_actionSort_triggered();
    void on_actionLog_out_2_triggered();
    void on_actionNetworking_triggered();
    void on_actionOnline_local_triggered();
    void on_actionOnline_remote_triggered();
    void on_actionOnline_local_P2P_triggered();
    void on_actionOnline_remote_P2P_triggered();
    void on_actionOffline_triggered();
    void on_actionCryptography_triggered();
    void on_actionUpdate_triggered();
    void on_actionManage_triggered();

    // Make Report page
    void on_btnGenerateReport_clicked();
    void on_btnExportReport_clicked();

    // Manage Fines page
    void on_btnSearchFines_clicked();
    void on_btnAddFine_clicked();
    void on_btnPayFine_clicked();

    // Make Card page
    void on_btnSearchCard_clicked();
    void on_btnPreviewCard_clicked();
    void on_btnPrintCard_clicked();

    // Backups page
    void on_btnBackupNow_clicked();
    void on_btnRestoreBackup_clicked();
    void on_btnBrowseBackupDir_clicked();

    // Preferences page
    void on_btnSavePreferences_clicked();
    void on_btnResetPreferences_clicked();

    // Accounts page
    void on_btnSearchAccount_clicked();
    void on_btnChangeRole_clicked();
    void on_btnDeleteAccount_clicked();

    // Troubleshoot page
    void on_btnTestDbConnection_clicked();
    void on_btnCheckDbIntegrity_clicked();
    void on_btnViewLogs_clicked();
    void on_btnExportDiagnostics_clicked();
    void on_btnCompactDatabases_clicked();

    // Preferences - worklog
    void on_chkWorklog_toggled(bool checked);

    // Worklog Stats page
    void on_actionWorklogStats_triggered();
    void on_btnRefreshWorklog_clicked();
    void on_btnExportWorklog_clicked();

    // Accounts - password change
    void on_btnChangePassword_clicked();

private:
    Ui::MainWindow *ui;
    DataAccess::IDataAccess& m_db;
    bool m_isLoggedIn = false;
    std::optional<Domain::User> m_currentUser;
    bool m_loadingDbConfigs = false;
    Worklog m_worklog;
    QString m_worklogFilePath;
};

#endif // MAINWINDOW_H
