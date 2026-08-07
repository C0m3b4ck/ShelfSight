unit main_workspace_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Menus,
  StdCtrls, ComCtrls, ExtCtrls, FormManager, global_vars, sqlite3conn,
  sqldb, DB, Types, dbmgmt;

type

  { Tmain_workspace }

  Tmain_workspace = class(TForm)
    btnCheck_title: TButton;
    btnCheck_author: TButton;
    btnCheck_location: TButton;
    btnDelete1: TButton;
    btnDelete2: TButton;
    btnCloseDeleteReaders: TButton;
    btnEditReaders: TButton;
    btnClear_EditReaders: TButton;
    btnCloseEditReaders: TButton;
    btnCheckID_book: TButton;
    btnEdit2: TButton;
    btnClear_EditBooks: TButton;
    btnCloseEditBooks: TButton;
    btnDelete: TButton;
    btnSearch: TButton;
    btnUndoLastDelete: TButton;
    btnCloseRemoveBooks: TButton;
    backdrop_image: TImage;
    btnAddBook: TButton;
    btnClear_AddBooks: TButton;
    btnCloseAddBooks: TButton;
    btnSearch2: TButton;
    btnCloseSearchBooks: TButton;
    btnClear_SearchBooks: TButton;
    btnAddReaders: TButton;
    btnClose_AddReaders: TButton;
    btnClear_AddReaders: TButton;
    btnSearch_DeleteReaders: TButton;
    btnCloseSearchLoans: TButton;
    btnClear_SearchLoans: TButton;
    btnRefresh_DeleteReaders: TButton;
    btnSearch_SearchReaders: TButton;
    Button1: TButton;
    Button12: TButton;
    Button13: TButton;
    AddAll_Readers: TButton;
    Button15: TButton;
    Button16: TButton;
    btnClear_ExpiredLoans: TButton;
    Button18: TButton;
    Button19: TButton;
    btnClear_AddUsers: TButton;
    btnAddSelected_SearchReaders: TButton;
    btnAddSelected_SearchLoans: TButton;
    btnAddUser: TButton;
    btnRefresh_EditBooks: TButton;
    btnSearch3: TButton;
    Button2: TButton;
    Button22: TButton;
    btnCategories_AddBooks: TButton;
    btnAddDatabases_CurrentDatabases: TButton;
    btnAddSelected_SearchBooks: TButton;
    btnRefresh_Remove: TButton;
    btnSearch_EditReaders: TButton;
    btnRefresh_EditReaders: TButton;
    Button3: TButton;
    btnSearchReaders_AddLoans: TButton;
    btnSearchBooks_AddLoans: TButton;
    Button4: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    chkBulkMode_Readers: TCheckBox;
    chkBulkMode: TCheckBox;
    chkHideNewKey_EditDatabases: TCheckBox;
    chkHideOldKey_EditDatabases: TCheckBox;
    btnClear_EditUsers: TButton;
    Button24: TButton;
    Button25: TButton;
    Button26: TButton;
    Button27: TButton;
    Button28: TButton;
    btnClose_AddDatabase: TButton;
    btnCloseAddLoans: TButton;
    btnClear_AddLoans: TButton;
    btnClear_EditLoans: TButton;
    Button30: TButton;
    btnCreateDB: TButton;
    Button32: TButton;
    Button33: TButton;
    Button34: TButton;
    Button35: TButton;
    Button36: TButton;
    Button37: TButton;
    Button38: TButton;
    Button39: TButton;
    btnCloseEditLoans: TButton;
    btnSearch_p2p: TButton;
    Button41: TButton;
    Button42: TButton;
    Button43: TButton;
    Button44: TButton;
    Button45: TButton;
    Button46: TButton;
    Button47: TButton;
    Button48: TButton;
    Button49: TButton;
    Button5: TButton;
    Button50: TButton;
    Button51: TButton;
    Button52: TButton;
    Button53: TButton;
    Button54: TButton;
    Button55: TButton;
    btnCloseSearchReaders: TButton;
    btnClear_SearchReaders: TButton;
    Button58: TButton;
    Button6: TButton;
    btnLoadDefaultCfg: TButton;
    btnSetDefaultCfg: TButton;
    applyandclose: TButton;
    btnLoadCfg: TButton;
    btnSaveCfg: TButton;
    cboEncryptionType_Add: TComboBox;
    chkHidePrivateKey_AddDatabases: TCheckBox;
    cboChangeDate: TComboBox;
    cboOldEncryption_EditDatabases: TComboBox;
    cboNewEncryption_EditDatabases: TComboBox;
    dbselect_books: TButton;
    dbselect_readers: TButton;
    dbselect_loans: TButton;
    btnCloseRemoveLoans: TButton;
    Button8: TButton;
    Button9: TButton;
    cboStatus2: TComboBox;
    cboCategory2: TComboBox;
    cboCategory: TComboBox;
    cboStatus: TComboBox;
    cboFilters: TComboBox;
    cboFilters2: TComboBox;
    cboFilters5: TComboBox;
    chkHideAddPswd1: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    chkHideEditPswd1: TCheckBox;
    chkHideEditPswd2: TCheckBox;
    chkHideAddPswd2: TCheckBox;
    chkTimestamped_HDD: TCheckBox;
    chkBackupLog_HDD: TCheckBox;
    chkCompressBackup_HDD: TCheckBox;
    chkWhitelist_p2p: TCheckBox;
    chkRemoveOld_Update: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    cboFilters6: TComboBox;
    cboChangeStatus_ExpiredLoans: TComboBox;
    cboSearchBy_ExpiredLoans: TComboBox;
    cboSortBy_ExpiredLoans: TComboBox;
    cboRole_AddUsers: TComboBox;
    cboSearch_EditUsers: TComboBox;
    cboSearch_RemoveUsers: TComboBox;
    cboSearch_UserPermissions: TComboBox;
    cboPermission_UserPermissions: TComboBox;
    cboDBType: TComboBox;
    ComboBox19: TComboBox;
    cboSearch_EditBooks: TComboBox;
    cboFilters4: TComboBox;
    cboSearch_EditDatabases: TComboBox;
    cboSearch_DeleteDatabases: TComboBox;
    cboMode_p2p: TComboBox;
    cboMode_Server: TComboBox;
    cboView_Statistics: TComboBox;
    cboTimespan_Statistics: TComboBox;
    ComboBox26: TComboBox;
    databases_sort: TMenuItem;
    Label200: TLabel;
    Label201: TLabel;
    loginout: TMenuItem;
    txtReaderID_Add: TEdit;
    txtReaderClass_Edit1: TEdit;
    txtReaderID_AddLoans: TEdit;
    Label199: TLabel;
    txtBookID_AddLoans: TEdit;
    Label141: TLabel;
    Label143: TLabel;
    Label193: TLabel;
    Label194: TLabel;
    Label195: TLabel;
    Label196: TLabel;
    Label197: TLabel;
    Label198: TLabel;
    lbl_expiredloans_readers_db: TLabel;
    lbl_expiredloans_books_db: TLabel;
    lbl_searchloans_readers_db: TLabel;
    lbl_searchloans_books_db: TLabel;
    lbl_removeloans_readers_db: TLabel;
    lbl_removeloans_books_db: TLabel;
    lbl_editloans_readers_db: TLabel;
    lbl_editloans_books_db: TLabel;
    Label80: TLabel;
    Label83: TLabel;
    Label92: TLabel;
    lbl_addloans_readers_db: TLabel;
    lbl_addloans_books_db: TLabel;
    txtSelectedID_DeleteReaders: TEdit;
    Label60: TLabel;
    txtID_DeleteBooks: TEdit;
    Label49: TLabel;
    txtDBdir_Server: TEdit;
    Label26: TLabel;
    Label190: TLabel;
    txtSearchReadersBy_AddLoans: TComboBox;
    txtSearchBooksBy_AddLoans: TComboBox;
    cboSearchByLoans_EditLoans: TComboBox;
    cboSearchByReaders_EditLoans: TComboBox;
    cboSearchByBooks_EditLoans: TComboBox;
    cboSearchBy_RemoveLoans: TComboBox;
    cboSearchByLoans: TComboBox;
    txtReaderName_Add: TEdit;
    txtSearchReaders: TEdit;
    txtSearchReaders_AddLoans: TEdit;
    txtSearchBooks_AddLoans: TEdit;
    txtDays_AddLoans: TEdit;
    txtSearchLoans_EditLoans: TEdit;
    txtSearchReaders_EditLoans: TEdit;
    txtSearchBooks_EditLoans: TEdit;
    txtSearch_RemoveLoans: TEdit;
    txtSearchLoans: TEdit;
    txtDays_EditLoans: TEdit;
    txtDays_ExpiredLoans: TEdit;
    txtSearch_ExpiredLoans: TEdit;
    txtUsername_AddUsers: TEdit;
    currentdatabases_main: TMenuItem;
    Label170: TLabel;
    Label171: TLabel;
    Label172: TLabel;
    Label173: TLabel;
    Label174: TLabel;
    Label175: TLabel;
    Label176: TLabel;
    Label177: TLabel;
    Label178: TLabel;
    Label179: TLabel;
    Label180: TLabel;
    Label181: TLabel;
    Label182: TLabel;
    Label183: TLabel;
    Label184: TLabel;
    Label185: TLabel;
    Label186: TLabel;
    Label187: TLabel;
    Label188: TLabel;
    Label189: TLabel;
    lbl_expiredloans_db: TLabel;
    lbl_searchloans_db: TLabel;
    lbl_removeloans_db: TLabel;
    lbl_editloans_db: TLabel;
    lbl_addloans_db: TLabel;
    lbl_searchreaders_db: TLabel;
    lbl_deletereaders_db: TLabel;
    lbl_editreaders_db: TLabel;
    lbl_searchbooks_db: TLabel;
    lbl_addreaders_db: TLabel;
    lbl_removebooks_db: TLabel;
    Label192: TLabel;
    lbl_editbooks_db: TLabel;
    lbl_addbooks_db: TLabel;
    lbl_bookdb: TLabel;
    lbl_readerdb: TLabel;
    lbl_loandb: TLabel;
    OpenDialog1: TOpenDialog;
    TabSheet29: TTabSheet;
    txtPassword1_AddUsers: TEdit;
    txtPassword2_AddUsers: TEdit;
    txtSearch_EditUsers: TEdit;
    txtUsername_EditUsers: TEdit;
    txtDBName_Add: TEdit;
    txtEditPassword1: TEdit;
    txtEditPassword2: TEdit;
    txtAuthenticate_EditUsers: TEdit;
    txtSearch_RemoveUsers: TEdit;
    txtSearch_UserPermissions: TEdit;
    Edit35: TEdit;
    Edit36: TEdit;
    txtSearch_EditDatabases: TEdit;
    txtName_EditDatabases: TEdit;
    txtOldKey_EditDatabases: TEdit;
    txtNewKey_EditDatabases: TEdit;
    txtSearch_DeleteDatabases: TEdit;
    txtDBdir_HDD: TEdit;
    txtBackupDir_HDD: TEdit;
    txtPort_p2p: TEdit;
    txtDBdir_p2p: TEdit;
    txtAddress_Server: TEdit;
    txtPort_Server: TEdit;
    txtUserID_Statistics: TEdit;
    Label100: TLabel;
    Label101: TLabel;
    Label102: TLabel;
    Label103: TLabel;
    Label104: TLabel;
    Label105: TLabel;
    Label106: TLabel;
    Label107: TLabel;
    Label108: TLabel;
    Label109: TLabel;
    Label110: TLabel;
    Label111: TLabel;
    Label112: TLabel;
    Label113: TLabel;
    Label114: TLabel;
    Label115: TLabel;
    Label116: TLabel;
    Label117: TLabel;
    Label118: TLabel;
    Label119: TLabel;
    Label120: TLabel;
    Label121: TLabel;
    Label122: TLabel;
    Label123: TLabel;
    Label124: TLabel;
    Label125: TLabel;
    Label126: TLabel;
    Label127: TLabel;
    Label128: TLabel;
    Label129: TLabel;
    Label130: TLabel;
    Label131: TLabel;
    Label132: TLabel;
    Label133: TLabel;
    Label134: TLabel;
    Label135: TLabel;
    Label136: TLabel;
    Label137: TLabel;
    Label138: TLabel;
    Label139: TLabel;
    Label140: TLabel;
    lblSpaceGB_HDD: TLabel;
    Label142: TLabel;
    lblSpaceMB_HDD: TLabel;
    Label144: TLabel;
    Label145: TLabel;
    Label146: TLabel;
    Label147: TLabel;
    Label148: TLabel;
    Label149: TLabel;
    Label150: TLabel;
    Label151: TLabel;
    Label152: TLabel;
    Label153: TLabel;
    Label154: TLabel;
    Label155: TLabel;
    Label156: TLabel;
    Label157: TLabel;
    Label158: TLabel;
    Label159: TLabel;
    Label160: TLabel;
    Label161: TLabel;
    Label162: TLabel;
    Label163: TLabel;
    Label164: TLabel;
    Label165: TLabel;
    Label166: TLabel;
    Label167: TLabel;
    Label168: TLabel;
    Label169: TLabel;
    Label43: TLabel;
    Label44: TLabel;
    Label45: TLabel;
    Label46: TLabel;
    Label47: TLabel;
    Label48: TLabel;
    lblReaderSum: TLabel;
    Label50: TLabel;
    Label51: TLabel;
    Label52: TLabel;
    Label53: TLabel;
    Label54: TLabel;
    Label55: TLabel;
    Label56: TLabel;
    Label57: TLabel;
    Label58: TLabel;
    Label59: TLabel;
    Label61: TLabel;
    Label62: TLabel;
    Label63: TLabel;
    Label64: TLabel;
    Label65: TLabel;
    Label66: TLabel;
    Label67: TLabel;
    Label68: TLabel;
    Label69: TLabel;
    Label70: TLabel;
    Label71: TLabel;
    Label72: TLabel;
    Label73: TLabel;
    Label74: TLabel;
    Label75: TLabel;
    Label76: TLabel;
    Label77: TLabel;
    Label78: TLabel;
    Label79: TLabel;
    lblLoanSum: TLabel;
    Label81: TLabel;
    Label82: TLabel;
    Label84: TLabel;
    Label85: TLabel;
    Label86: TLabel;
    Label87: TLabel;
    Label88: TLabel;
    Label89: TLabel;
    Label90: TLabel;
    Label91: TLabel;
    Label93: TLabel;
    Label94: TLabel;
    Label95: TLabel;
    Label96: TLabel;
    Label97: TLabel;
    Label98: TLabel;
    Label99: TLabel;
    lstDeleteReaders: TListBox;
    lstResults_ExpiredLoans: TListBox;
    lstSelect_EditUsers: TListBox;
    lstSelect_RemoveUsers: TListBox;
    lstSelect_UserPermissions: TListBox;
    lstSelect_EditDatabases: TListBox;
    lstSelect_DeleteDatabases: TListBox;
    lstPeers_p2p: TListBox;
    lstReaders: TListBox;
    lstReaders_AddLoans: TListBox;
    lstBooks_AddLoans: TListBox;
    lstLoans_EditLoans: TListBox;
    lstReaders_EditLoans: TListBox;
    lstSelect_RemoveLoans: TListBox;
    lstSearchLoans: TListBox;
    lstBooks_EditLoans: TListBox;
    lstEditReaders: TListBox;
    AppChangelog: TMemo;
    StatsConsole: TMemo;
    statistics_main: TMenuItem;
    ServerConsole: TMemo;
    PeerConsole: TMemo;
    TabSheet18: TTabSheet;
    TabSheet19: TTabSheet;
    TabSheet20: TTabSheet;
    TabSheet21: TTabSheet;
    TabSheet22: TTabSheet;
    TabSheet23: TTabSheet;
    TabSheet24: TTabSheet;
    TabSheet25: TTabSheet;
    TabSheet26: TTabSheet;
    TabSheet27: TTabSheet;
    TabSheet28: TTabSheet;
    txtPrivateKey_Add: TEdit;
    users_permissions: TMenuItem;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    TabSheet13: TTabSheet;
    TabSheet14: TTabSheet;
    TabSheet15: TTabSheet;
    TabSheet16: TTabSheet;
    TabSheet17: TTabSheet;
    TabSheet9: TTabSheet;
    txtSearch4: TEdit;
    txtReaderSurname_Add: TEdit;
    txtReaderGrade_Add: TEdit;
    txtReaderClass_Add: TEdit;
    txtReaderName_Edit: TEdit;
    txtReaderSurname_Edit: TEdit;
    txtReaderGrade_Edit: TEdit;
    txtReaderClass_Edit: TEdit;
    txtSearch_DeleteReaders: TEdit;
    lblBookSum: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Label37: TLabel;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    lstResults2: TListBox;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    txtSearch3: TEdit;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    settings_main: TMenuItem;
    settings_app: TMenuItem;
    settings_networking: TMenuItem;
    TabSheet5: TTabSheet;
    txtID: TEdit;
    txtAuthor2: TEdit;
    txtLocation2: TEdit;
    txtSearch2: TEdit;
    txtTitle: TEdit;
    txtAuthor: TEdit;
    txtLocation: TEdit;
    txtSearch: TEdit;
    txtBookID2: TEdit;
    txtTitle2: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    leave_main: TMenuItem;
    leave_logout: TMenuItem;
    leave_exit: TMenuItem;
    clear_workspace: TMenuItem;
    lstEdit: TListBox;
    lstDelete: TListBox;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    workspace_control: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    top_toolbar: TMainMenu;
    books_main: TMenuItem;
    books_remove: TMenuItem;
    books_search: TMenuItem;
    loans_add: TMenuItem;
    loans_edit: TMenuItem;
    loans_remove: TMenuItem;
    loans_search: TMenuItem;
    loans_expired: TMenuItem;
    databases_add: TMenuItem;
    databases_edit: TMenuItem;
    databases_remove: TMenuItem;
    databases_backup: TMenuItem;
    databases_server: TMenuItem;
    databases_p2p: TMenuItem;
    users_add: TMenuItem;
    users_edit: TMenuItem;
    users_remove: TMenuItem;
    readers_add: TMenuItem;
    readers_edit: TMenuItem;
    readers_remove: TMenuItem;
    readers_search: TMenuItem;
    readers_main: TMenuItem;
    loans_main: TMenuItem;
    users_main: TMenuItem;
    databases_main: TMenuItem;
    update_main: TMenuItem;
    books_add: TMenuItem;
    books_edit: TMenuItem;
    procedure app_backupClick(Sender: TObject);
    procedure app_updateClick(Sender: TObject);
    procedure books_addClick(Sender: TObject);
    procedure books_editClick(Sender: TObject);
    procedure books_mainClick(Sender: TObject);
    procedure books_removeClick(Sender: TObject);
    procedure books_searchClick(Sender: TObject);
    procedure btnAddBookClick(Sender: TObject);
    procedure btnAddDatabases_CurrentDatabasesClick(Sender: TObject);
    procedure btnAddReadersClick(Sender: TObject);
    procedure btnCategories_AddBooksClick(Sender: TObject);
    procedure btnCheckID_bookClick(Sender: TObject);
    procedure btnClear_AddLoansClick(Sender: TObject);
    procedure btnClear_EditBooksClick(Sender: TObject);
    procedure btnClear_SearchBooksClick(Sender: TObject);
    procedure btnClear_AddReadersClick(Sender: TObject);
    procedure btnClear_EditReadersClick(Sender: TObject);
    procedure btnClear_AddBooksClick(Sender: TObject);
    procedure btnClear_SearchLoansClick(Sender: TObject);
    procedure btnClear_SearchReadersClick(Sender: TObject);
    procedure btnCloseEditBooksClick(Sender: TObject);
    procedure btnCloseRemoveBooksClick(Sender: TObject);
    procedure btnCloseSearchBooksClick(Sender: TObject);
    procedure btnClose_AddReadersClick(Sender: TObject);
    procedure btnCloseEditReadersClick(Sender: TObject);
    procedure btnCloseDeleteReadersClick(Sender: TObject);
    procedure btnDelete1Click(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnEdit2Click(Sender: TObject);
    procedure btnEditReadersClick(Sender: TObject);
    procedure btnRefresh_DeleteReadersClick(Sender: TObject);
    procedure btnRefresh_EditBooksClick(Sender: TObject);
    procedure btnRefresh_EditReadersClick(Sender: TObject);
    procedure btnRefresh_RemoveClick(Sender: TObject);
    procedure btnSearch2Click(Sender: TObject);
    procedure btnSearch3Click(Sender: TObject);
    procedure btnSearchBooks_AddLoansClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnSearchReaders_AddLoansClick(Sender: TObject);
    procedure btnSearch_SearchReadersClick(Sender: TObject);
    procedure btnSetDefaultCfgClick(Sender: TObject);
    procedure btnCloseSearchLoansClick(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure btnClear_ExpiredLoansClick(Sender: TObject);
    procedure btnClear_AddUsersClick(Sender: TObject);
    procedure btnAddUserClick(Sender: TObject);
    procedure btnSearch_DeleteReadersClick(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure btnClear_EditUsersClick(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure Button28Click(Sender: TObject);
    procedure btnClose_AddDatabaseClick(Sender: TObject);
    procedure btnCreateDBClick(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure Button34Click(Sender: TObject);
    procedure Button37Click(Sender: TObject);
    procedure btnCloseAddLoansClick(Sender: TObject);
    procedure btnClear_EditLoansClick(Sender: TObject);
    procedure btnSearch_EditReadersClick(Sender: TObject);
    procedure Button41Click(Sender: TObject);
    procedure Button44Click(Sender: TObject);
    procedure Button48Click(Sender: TObject);
    procedure btnCloseEditLoansClick(Sender: TObject);
    procedure Button51Click(Sender: TObject);
    procedure Button52Click(Sender: TObject);
    procedure Button54Click(Sender: TObject);
    procedure btnCloseSearchReadersClick(Sender: TObject);
    procedure Button59Click(Sender: TObject);
    procedure btnLoadDefaultCfgClick(Sender: TObject);
    procedure btnLoadCfgClick(Sender: TObject);
    procedure btnSaveCfgClick(Sender: TObject);
    procedure applyandcloseClick(Sender: TObject);
    procedure chkBulkModeChange(Sender: TObject);
    procedure chkHidePrivateKey_AddDatabasesChange(Sender: TObject);
    procedure databases_mainClick(Sender: TObject);
    procedure dbselect_booksClick(Sender: TObject);
    procedure btnCloseRemoveLoansClick(Sender: TObject);
    procedure btnCloseAddBooksClick(Sender: TObject);
    procedure chkHideAddPswd1Change(Sender: TObject);
    procedure chkHideAddPswd2Change(Sender: TObject);
    procedure chkHideEditPswd1Change(Sender: TObject);
    procedure chkHideEditPswd2Change(Sender: TObject);
    procedure clear_workspaceClick(Sender: TObject);
    procedure databases_addClick(Sender: TObject);
    procedure databases_backupClick(Sender: TObject);
    procedure databases_editClick(Sender: TObject);
    procedure databases_serverClick(Sender: TObject);
    procedure databases_p2pClick(Sender: TObject);
    procedure databases_removeClick(Sender: TObject);
    procedure dbselect_loansClick(Sender: TObject);
    procedure dbselect_readersClick(Sender: TObject);
    procedure lstBooks_AddLoansClick(Sender: TObject);
    procedure lstDeleteClick(Sender: TObject);
    procedure lstDeleteReadersClick(Sender: TObject);
    procedure lstEditClick(Sender: TObject);
    procedure lstEditReadersClick(Sender: TObject);
    procedure lstReaders_AddLoansClick(Sender: TObject);
    procedure databases_sortClick(Sender: TObject);
    procedure statistics_mainClick(Sender: TObject);
    procedure loans_addClick(Sender: TObject);
    procedure loans_editClick(Sender: TObject);
    procedure loans_expiredClick(Sender: TObject);
    procedure loans_removeClick(Sender: TObject);
    procedure loans_searchClick(Sender: TObject);
    procedure permissions_changeClick(Sender: TObject);
    procedure readers_addClick(Sender: TObject);
    procedure readers_editClick(Sender: TObject);
    procedure readers_removeClick(Sender: TObject);
    procedure readers_searchClick(Sender: TObject);
    procedure settings_appClick(Sender: TObject);
    procedure settings_networkingClick(Sender: TObject);
    procedure TabSheet1Show(Sender: TObject); //upon showing form
    procedure TabSheet21ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TabSheet2Show(Sender: TObject);
    //procedure TabSheet3Show(Sender: TObject); //this is the backdrop
    procedure TabSheet4Show(Sender: TObject);
    procedure TabSheet5Show(Sender: TObject);
    procedure TabSheet6Show(Sender: TObject);
    procedure TabSheet7Show(Sender: TObject);
    procedure TabSheet8Show(Sender: TObject);
    procedure TabSheet9Show(Sender: TObject);
    procedure TabSheet10Show(Sender: TObject);
    procedure TabSheet11Show(Sender: TObject);
    procedure TabSheet12Show(Sender: TObject);
    procedure TabSheet13Show(Sender: TObject);
    procedure TabSheet14Show(Sender: TObject);
    procedure TabSheet15Show(Sender: TObject);
    procedure TabSheet16Show(Sender: TObject);
    procedure TabSheet17Show(Sender: TObject);
    procedure TabSheet18Show(Sender: TObject);
    procedure TabSheet19Show(Sender: TObject);
    procedure TabSheet20Show(Sender: TObject);
    procedure TabSheet21Show(Sender: TObject);
    procedure TabSheet22Show(Sender: TObject);
    procedure TabSheet23Show(Sender: TObject);
    procedure TabSheet24Show(Sender: TObject);
    procedure TabSheet25Show(Sender: TObject);
    procedure TabSheet26Show(Sender: TObject);
    procedure TabSheet27Show(Sender: TObject);
    procedure TabSheet28Show(Sender: TObject);
    procedure TabSheet29Show(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure backdrop_imageClick(Sender: TObject);
    procedure leave_exitClick(Sender: TObject);
    procedure leave_logoutClick(Sender: TObject);
    procedure update_mainClick(Sender: TObject);
    procedure users_addClick(Sender: TObject);
    procedure users_editClick(Sender: TObject);
    procedure users_passwordsClick(Sender: TObject);
    procedure users_permissionsClick(Sender: TObject);
    procedure users_removeClick(Sender: TObject);
    procedure currentdatabases_mainClick(Sender: TObject);
    procedure goto_backdrop();
    procedure goto_db_selection();
    procedure PopulateBookListInternal();
    procedure PopulateBookListInternal_Remove();
    function check_dbs_created(): Boolean;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  main_workspace: Tmain_workspace;
  AppDir: string;
  current_edit_reader_ID: string;

implementation

{$R *.lfm}

{ Tmain_workspace }

function Tmain_workspace.check_dbs_created(): Boolean;
begin
  if not check_other_dbs() then
  begin
    if authenticate(3) then
    begin
       ShowMessage('Please create a database by clicking the "Add Databases" button!');
       Result := False;
       Exit;
    end
    else
    begin
      ShowMessage('Request database creation from a Superadmin!');
      Result := False;
      Exit;
    end;
  end
  else //if check_other_dbs() returns true
  begin
    Result := True;
    Exit;
  end;

end;

procedure Tmain_workspace.books_addClick(Sender: TObject);
begin
  //workspace_control.Pages[1].TabVisible := False;
      if current_books_db = '' then
    begin
         ShowMessage('Please select current database for books!');
         goto_db_selection();
         Exit;
    end
    else
    begin
        If not dbmgmt.authenticate(2) then Exit;
        workspace_control.ShowTabs := False;
        workspace_control.PageIndex := 0;
        workspace_control.Refresh;
        TabSheet1Show(Self);
    end;

end;

procedure Tmain_workspace.goto_backdrop();
begin
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 2;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.app_updateClick(Sender: TObject);
begin
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 24;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.app_backupClick(Sender: TObject);
begin
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 25;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.books_editClick(Sender: TObject);
begin
   //workspace_control.Pages[0].TabVisible := False;
  if current_books_db = '' then
    begin
         ShowMessage('Please select current database for books!');
         goto_db_selection();
    end
  else
  begin
      If not authenticate(2) then Exit;
      workspace_control.ShowTabs := False;
      workspace_control.PageIndex := 1;
      workspace_control.Refresh;
      TabSheet2Show(Self);
  end;
end;

procedure Tmain_workspace.books_mainClick(Sender: TObject);
begin

end;

procedure Tmain_workspace.books_removeClick(Sender: TObject);
begin
  if current_books_db = '' then
    begin
         ShowMessage('Please select current database for books!');
         goto_db_selection();
    end
  else
  begin
      If not authenticate(2) then Exit;
      workspace_control.ShowTabs := False;
      workspace_control.PageIndex := 3;
      workspace_control.Refresh;
      TabSheet4Show(Self);
  end;
end;

procedure Tmain_workspace.books_searchClick(Sender: TObject);
begin
  if current_books_db = '' then
    begin
         ShowMessage('Please select current database for books!');
         goto_db_selection();
    end
  else
  begin
      If not authenticate(2) then Exit;
      workspace_control.ShowTabs := False;
      workspace_control.PageIndex := 4;
      workspace_control.Refresh;
      TabSheet5Show(Self);
  end;
end;

procedure Tmain_workspace.btnAddBookClick(Sender: TObject);
begin
  ///-----checks of inputs fields---\\\
  If (Trim(current_books_db) = '') then
  begin
    ShowMessage('No database selected! Please return to Database Selection and choose book database!');
    Exit;
  end;

  If (Trim(txtID.Text) = '') then
  begin
    ShowMessage('Please input book ID!');
    Exit;
  end;

  If (Trim(txtTitle.Text) = '') then
  begin
    ShowMessage('Please input book title!');
    Exit;
  end;

  If (Trim(txtAuthor.Text) = '') then
  begin
    ShowMessage('Please input book author!');
    Exit;
  end;

  If (Trim(txtLocation.Text) = '') then
  begin
    ShowMessage('Please input book location!');
    Exit;
  end;

  If (cboCategory.Text = '') then
  begin
    ShowMessage('Please select book category!');
    Exit;
  end;

  If (cboStatus.Text = '') then
  begin
    ShowMessage('Please select book status!');
    Exit;
  end;

  /// if everything filled out - proceeds \\\
  try
    try
     // Create table if needed
     SQLite3ConnectionBooks.ExecuteDirect(
     'CREATE TABLE IF NOT EXISTS books (' +
     'id INTEGER PRIMARY KEY AUTOINCREMENT,' +
     'book_id TEXT NOT NULL UNIQUE,' +
     'book_title TEXT NOT NULL,' +
     'book_author TEXT NOT NULL,' +
     'book_location TEXT NOT NULL,' +
     'book_category TEXT NOT NULL,' +
     'book_status TEXT NOT NULL)'
     );

     // Insert book
     SQLQueryBooks.SQL.Clear;
     SQLQueryUsers.SQL.Add('INSERT INTO books (book_id, book_title, book_author, book_location, book_category, book_status) VALUES (:book_id, :book_title, :book_author, :book_location, :book_category, :book_status)');
     SQLQueryUsers.Prepare;  // parse params BEFORE ParamByName

     SQLQueryBooks.ParamByName('book_id').AsString := Trim(txtID.Text);
     SQLQueryBooks.ParamByName('book_title').AsString := Trim(txtTitle.Text);
     SQLQueryBooks.ParamByName('book_author').AsString := Trim(txtAuthor.Text);
     SQLQueryBooks.ParamByName('book_location').AsString := Trim(txtLocation.Text);
     SQLQueryBooks.ParamByName('book_category').AsString := cboCategory.Text;
     SQLQueryBooks.ParamByName('book_status').AsString := cboStatus.Text;
     SQLQueryUsers.Open;



     SQLTransactionBooks.Commit;
     ShowMessage('Book added succesfully!');

	  except
                on E: EDatabaseError do
                begin
                  if Pos('DB error: UNIQUE constant failed: books.book_id', E.Message) > 0 then
                  begin
                   ShowMessage('Book with same ID already exists! Please choose different ID!');
                   Exit;
                  end
                  else
                    ShowMessage('DB error: ' + E.Message);
                    SQLTransactionBooks.Rollback;
                    Exit; //exit on error
                end;
                on E: Exception do
		begin
		  SQLTransactionBooks.Rollback;
		  ShowMessage('Book addition failed: ' + E.Message);
		  Exit;  //exit on error
		end;

	  end;

	  // Clear only on success
	  txtID.Text := '';
          if (chkBulkMode.Checked = False) then
          begin
           txtAuthor.Text := '';
           txtLocation.Text := '';
           txtTitle.Text := '';
          end;


	  finally
             SQLQueryBooks.Close;
          end;

end;

procedure Tmain_workspace.btnAddDatabases_CurrentDatabasesClick(Sender: TObject
  );
begin
     if authenticate(3) then
     begin
          workspace_control.ShowTabs := False;
          workspace_control.PageIndex := 18;
          workspace_control.Refresh;
          TabSheet19Show(Self);
     end;
end;

procedure Tmain_workspace.btnAddReadersClick(Sender: TObject);
begin
  ///-----checks of inputs fields---\\\
  If (Trim(current_readers_db) = '') then
  begin
    ShowMessage('No database selected! Please return to Database Selection and choose reader database!');
    Exit;
  end;

  If (Trim(txtReaderName_Add.Text) = '') then
  begin
    ShowMessage('Please input reader name!');
    Exit;
  end;

    If (Trim(txtReaderSurname_Add.Text) = '') then
  begin
    ShowMessage('Please input reader surname!');
    Exit;
  end;

      If (Trim(txtReaderGrade_Add.Text) = '') then
  begin
    ShowMessage('Please input reader grade!');
    Exit;
  end;

        If (Trim(txtReaderClass_Add.Text) = '') then
  begin
    ShowMessage('Please input reader class!');
    Exit;
  end;

  /// if everything filled out - proceeds \\\
  try
    try
     // Create table if needed
     SQLite3ConnectionBooks.ExecuteDirect(
     'CREATE TABLE IF NOT EXISTS readers (' +
     'reader_name TEXT NOT NULL,' +
     'reader_surname TEXT NOT NULL,' +
     'reader_grade TEXT NOT NULL,' +
     'reader_class TEXT NOT NULL,' +
     'reader_id INTEGER PRIMARY KEY AUTOINCREMENT)'
     );

     // Insert user
     SQLQueryBooks.SQL.Text :=
     'INSERT INTO readers (reader_name, reader_surname, reader_grade, reader_class) ' +
     'VALUES (:reader_name, :reader_surname, :reader_grade, :reader_class)';
     SQLQueryBooks.ParamByName('reader_name').AsString := Trim(txtReaderName_Add.Text);
     SQLQueryBooks.ParamByName('reader_surname').AsString := Trim(txtReaderSurname_Add.Text);
     SQLQueryBooks.ParamByName('reader_grade').AsString := Trim(txtReaderGrade_Add.Text);
     SQLQueryBooks.ParamByName('reader_class').AsString := Trim(txtReaderClass_Add.Text);
     SQLQueryBooks.ExecSQL;

     SQLTransactionBooks.Commit;
     ShowMessage('Reader added succesfully!');

	  except
                on E: EDatabaseError do
                begin
                    ShowMessage('DB error: ' + E.Message);
                    SQLTransactionBooks.Rollback;
                    Exit; //exit on error
                end;
                on E: Exception do
		begin
		  SQLTransactionBooks.Rollback;
		  ShowMessage('Reader addition failed: ' + E.Message);
		  Exit;  //exit on error
		end;

	  end;

	  // Clear only on success
	  txtID.Text := '';
          if (chkBulkMode_Readers.Checked = False) then
          begin
           txtReaderName_Add.Text := '';
           txtReaderSurname_Add.Text := '';
           txtReaderGrade_Add.Text := '';
           txtReaderClass_Add.Text := '';
          end;


	  finally
          end;
end;

procedure Tmain_workspace.btnCategories_AddBooksClick(Sender: TObject);
begin

end;

procedure Tmain_workspace.btnCheckID_bookClick(Sender: TObject);
begin

end;

procedure Tmain_workspace.btnClear_AddLoansClick(Sender: TObject);
begin
  //clear fields
  txtSearchReaders_AddLoans.Text := '';
  txtSearchReadersBy_AddLoans.Text := '';
  lstReaders_AddLoans.Caption := '';
  txtSearchBooks_AddLoans.Text := '';
  txtSearchBooksBy_AddLoans.Text := '';
  lstBooks_AddLoans.Caption := '';
  txtDays_AddLoans.Text := '';
end;

procedure Tmain_workspace.btnClear_EditBooksClick(Sender: TObject);
begin
  //clear fields
  txtSearch.Text := '';
  lstEdit.Caption := '';
  txtBookID2.Text := '';
  txtTitle2.Text := '';
  txtAuthor2.Text := '';
  txtLocation2.Text := '';
  lbl_editbooks_db.Caption := '';
end;

procedure Tmain_workspace.btnClear_SearchBooksClick(Sender: TObject);
begin
  //clear fields
  lbl_searchbooks_db.Caption := '';
  lstResults2.Caption := '';
  cboFilters2.Text := '';
  txtSearch3.Text := '';
  lblBookSum.Caption := '';
end;

procedure Tmain_workspace.btnClear_AddReadersClick(Sender: TObject);
begin
  //clear fields
  txtReaderName_Add.Text := '';
  txtReaderSurname_Add.Text := '';
  txtReaderGrade_Add.Text := '';
  txtReaderClass_Add.Text := '';
  lbl_addreaders_db.Caption := '';
end;

procedure Tmain_workspace.btnClear_EditReadersClick(Sender: TObject);
begin
  //clear fields
  txtReaderName_Edit.Text := '';
  txtReaderSurname_Edit.Text := '';
  txtReaderGrade_Edit.Text := '';
  txtReaderClass_Edit.Text := '';
  txtSearch4.Text := '';
  cboFilters4.Text := '';
  lstEditReaders.Caption := '';
  lbl_editreaders_db.Caption := '';
end;

procedure Tmain_workspace.btnClear_AddBooksClick(Sender: TObject);
begin
  //clear fields
     txtID.Text := '';
     txtTitle.Text := '';
     txtAuthor.Text := '';
     txtLocation.Text := '';
     cboCategory.Text := '';
     cboStatus.Text := '';
     lbl_addbooks_db.Caption := '';
end;

procedure Tmain_workspace.btnClear_SearchLoansClick(Sender: TObject);
begin
  //clear fields
  lstSearchLoans.Caption := '';
  txtSearchLoans.Text := '';
  cboSearchByLoans.Text := '';
  lblLoanSum.Caption := '';
  lbl_searchloans_db.Caption := '';
end;

procedure Tmain_workspace.btnClear_SearchReadersClick(Sender: TObject);
begin
  //clear fields
  txtSearchReaders.Text := '';
  lbl_searchreaders_db.Caption := '';
  cboFilters6.Text := '';
  lblReaderSum.Caption := '';
end;

procedure Tmain_workspace.btnCloseEditBooksClick(Sender: TObject);
begin
  //clear fields
  txtSearch.Text := '';
  lstEdit.Caption := '';
  txtBookID2.Text := '';
  txtTitle2.Text := '';
  txtAuthor2.Text := '';
  txtLocation2.Text := '';
  lbl_editbooks_db.Caption := '';

  goto_backdrop();
end;

procedure Tmain_workspace.btnCloseRemoveBooksClick(Sender: TObject);
begin
  //clear fields
  txtSearch2.Text := '';
  lstDelete.Caption := '';
  cboFilters.Text := '';
  lbl_removebooks_db.Caption := '';
  goto_backdrop();
end;

procedure Tmain_workspace.btnCloseSearchBooksClick(Sender: TObject);
begin
//clear fields
  lbl_searchbooks_db.Caption := '';
  lstResults2.Caption := '';
  cboFilters2.Text := '';
  txtSearch3.Text := '';
  lblBookSum.Caption := '';

  goto_backdrop();
end;

procedure Tmain_workspace.btnClose_AddReadersClick(Sender: TObject);
begin
//clear fields
  txtReaderName_Add.Text := '';
  txtReaderSurname_Add.Text := '';
  txtReaderGrade_Add.Text := '';
  txtReaderClass_Add.Text := '';
  lbl_addreaders_db.Caption := '';

  goto_backdrop();
end;

procedure Tmain_workspace.btnCloseEditReadersClick(Sender: TObject);
begin
  //clear fields
  txtReaderName_Edit.Text := '';
  txtReaderSurname_Edit.Text := '';
  txtReaderGrade_Edit.Text := '';
  txtReaderClass_Edit.Text := '';
  txtSearch4.Text := '';
  cboFilters4.Text := '';
  lstEditReaders.Caption := '';
  lbl_editreaders_db.Caption := '';
  goto_backdrop();
end;

procedure Tmain_workspace.btnCloseDeleteReadersClick(Sender: TObject);
begin
  //clear fields
  txtSearch_DeleteReaders.Text := '';
  cboFilters5.Text := '';
  lbl_deletereaders_db.Caption := '';
  lstDeleteReaders.Caption := '';
  goto_backdrop();
end;

procedure Tmain_workspace.btnDelete1Click(Sender: TObject);
var
  deleteID: string;
begin
  deleteID := Trim(txtSelectedID_DeleteReaders.Text);
  if deleteID = '' then
  begin
    ShowMessage('No reader selected.');
    Exit;
  end;

  try
    try
  SQLQueryBooks.SQL.Text := 'DELETE FROM readers WHERE reader_id = :id';
  SQLQueryBooks.ParamByName('id').AsString := DeleteID;

    if MessageDlg('Are you sure?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
       begin
           SQLQueryBooks.ExecSQL;
           SQLTransactionBooks.Commit;
           ShowMessage('Reader deleted succesfully!');
           btnRefresh_DeleteReadersClick(Self); // Refresh list
       end;
  except
    on E: EDatabaseError do
    begin
      SQLTransactionBooks.Rollback;
      if Pos('UNIQUE constraint failed', UpperCase(E.Message)) > 0 then
        ShowMessage('Duplicate reader ID!')
      else
        ShowMessage('DB error: ' + E.Message);
    end;
    on E: Exception do
    begin
      SQLTransactionBooks.Rollback;
      ShowMessage('Error: ' + E.Message);
    end;
  end;

  finally
  end;
end;

procedure Tmain_workspace.btnDeleteClick(Sender: TObject);
var
  deleteID: string;
begin
  deleteID := Trim(txtID_DeleteBooks.Text);
  if deleteID = '' then
  begin
    ShowMessage('No book selected.');
    Exit;
  end;

  try
    try
  SQLQueryBooks.SQL.Text := 'DELETE FROM books WHERE book_id = :id';
  SQLQueryBooks.ParamByName('id').AsString := DeleteID;

    if MessageDlg('Are you sure?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
       begin
           SQLQueryBooks.ExecSQL;
           SQLTransactionBooks.Commit;
           ShowMessage('Book deleted succesfully!');
           PopulateBookListInternal_Remove;  // Refresh list
       end;
  except
    on E: EDatabaseError do
    begin
      SQLTransactionBooks.Rollback;
      if Pos('UNIQUE constraint failed', UpperCase(E.Message)) > 0 then
        ShowMessage('Duplicate book_id or title!')
      else
        ShowMessage('DB error: ' + E.Message);
    end;
    on E: Exception do
    begin
      SQLTransactionBooks.Rollback;
      ShowMessage('Error: ' + E.Message);
    end;
  end;

  finally
  end;
end;

procedure Tmain_workspace.btnEdit2Click(Sender: TObject);
begin
  if Trim(txtBookID2.Text) = '' then
  begin
    ShowMessage('No book selected.');
    Exit;
  end;

  try
     try

  SQLQueryBooks.SQL.Text := 'UPDATE books SET ' +
    'book_title = :title, book_author = :author, ' +
    'book_location = :location, book_category = :category, ' +
    'book_status = :status ' +
    'WHERE book_id = :id';  // Fixed: book_id (TEXT)

  SQLQueryBooks.ParamByName('title').AsString := Trim(txtTitle2.Text);
  SQLQueryBooks.ParamByName('author').AsString := Trim(txtAuthor2.Text);
  SQLQueryBooks.ParamByName('location').AsString := Trim(txtLocation2.Text);
  SQLQueryBooks.ParamByName('category').AsString := Trim(cboCategory2.Text);
  SQLQueryBooks.ParamByName('status').AsString := Trim(cboStatus2.Text);
  SQLQueryBooks.ParamByName('id').AsString := Trim(txtBookID2.Text);  // Last, matches WHERE

    SQLQueryBooks.ExecSQL;
    SQLTransactionBooks.Commit;
    ShowMessage('Book edited successfully!');
    PopulateBookListInternal;  // Refresh list
  except
    on E: EDatabaseError do
    begin
      SQLTransactionBooks.Rollback;
      if Pos('UNIQUE constraint failed', UpperCase(E.Message)) > 0 then
        ShowMessage('Duplicate book_id or title!')
      else
        ShowMessage('DB error: ' + E.Message);
    end;
    on E: Exception do
    begin
      SQLTransactionBooks.Rollback;
      ShowMessage('Error: ' + E.Message);
    end;
  end;

  finally

  end;
end;

procedure Tmain_workspace.btnEditReadersClick(Sender: TObject);
begin
  if Trim(current_edit_reader_ID) = '' then
  begin
    ShowMessage('No reader selected.');
    Exit;
  end;

  try
     try
  SQLQueryBooks.SQL.Text := 'UPDATE readers SET ' +
    'reader_name = :name, reader_surname = :surname, ' +
    'reader_grade = :grade, reader_class = :class ' +
    'WHERE reader_id = :id';  // Fixed: book_id (TEXT)

  SQLQueryBooks.ParamByName('name').AsString := Trim(txtReaderName_Edit.Text);
  SQLQueryBooks.ParamByName('surname').AsString := Trim(txtReaderSurname_Edit.Text);
  SQLQueryBooks.ParamByName('grade').AsString := Trim(txtReaderGrade_Edit.Text);
  SQLQueryBooks.ParamByName('class').AsString := Trim(txtReaderClass_Edit.Text);
  SQLQueryBooks.ParamByName('id').AsString := current_edit_reader_ID;  // Last, matches WHERE

    SQLQueryBooks.ExecSQL;
    SQLTransactionBooks.Commit;
    ShowMessage('Reader edited successfully!');
    //PopulateReaderList;  // Refresh list DB NAME HERE
  except
    on E: EDatabaseError do
    begin
      SQLTransactionBooks.Rollback;
      if Pos('UNIQUE constraint failed', UpperCase(E.Message)) > 0 then
        ShowMessage('Duplicate reader_id!')
      else
        ShowMessage('DB error: ' + E.Message);
    end;
    on E: Exception do
    begin
      SQLTransactionBooks.Rollback;
      ShowMessage('Error: ' + E.Message);
    end;
  end;

  finally
  end;
end;

procedure Tmain_workspace.btnRefresh_DeleteReadersClick(Sender: TObject);
begin
  btnSearch_DeleteReadersClick(Self);
end;


procedure Tmain_workspace.btnRefresh_EditBooksClick(Sender: TObject);
begin
  PopulateBookListInternal();
end;

procedure Tmain_workspace.btnRefresh_EditReadersClick(Sender: TObject);
begin
  btnSearch_EditReadersClick(Self);
end;



procedure Tmain_workspace.btnSearch2Click(Sender: TObject);
var
   search_term: String;
begin
     try
       try
        lstDelete.Clear;

        search_term := '%' + Trim(txtSearch2.Text) + '%';  // Fix: Add wildcards

        // Fix: Set SQL BEFORE Open/Prepare
        SQLQueryBooks.SQL.Text := 'SELECT book_id, book_title FROM books WHERE book_title LIKE :search_term';
        SQLQueryBooks.ParamByName('search_term').AsString := search_term;
        SQLQueryBooks.Prepare;
        SQLQueryBooks.Open;  // Now safe

        while not SQLQueryBooks.Eof do
        begin
             lstDelete.Items.Add(SQLQueryBooks.FieldByName('book_title').AsString);
             SQLQueryBooks.Next;
        end;
        SQLTransactionBooks.Commit;  // Add success commit

     except
        on E: EDatabaseError do
        begin
             ShowMessage('DB error: ' + E.Message);
             SQLTransactionBooks.Rollback;
             Exit;
        end;
        on E: Exception do
        begin
             SQLTransactionBooks.Rollback;
             ShowMessage('Search failed: ' + E.Message);
             Exit;
        end;
     end;

     //call refresh button
     btnRefresh_RemoveClick(Self);
     finally  // Safe cleanup
     end;
end;

procedure Tmain_workspace.btnSearch3Click(Sender: TObject);
var
   search_term: String;
begin
     try
       try
        lstEdit.Clear;

        search_term := '%' + Trim(txtSearch.Text) + '%';  // Fix: Add wildcards

        // Fix: Set SQL BEFORE Open/Prepare
        SQLQueryBooks.SQL.Text := 'SELECT book_id, book_title FROM books WHERE book_title LIKE :search_term';
        SQLQueryBooks.ParamByName('search_term').AsString := search_term;
        SQLQueryBooks.Prepare;
        SQLQueryBooks.Open;  // Now safe

        while not SQLQueryBooks.Eof do
        begin
             lstEdit.Items.Add(SQLQueryBooks.FieldByName('book_title').AsString);
             SQLQueryBooks.Next;
        end;
        SQLTransactionBooks.Commit;  // Add success commit

     except
        on E: EDatabaseError do
        begin
             ShowMessage('DB error: ' + E.Message);
             SQLTransactionBooks.Rollback;
             Exit;
        end;
        on E: Exception do
        begin
             SQLTransactionBooks.Rollback;
             ShowMessage('Search failed: ' + E.Message);
             Exit;
        end;
     end;

     //call refresh button
     btnRefresh_EditBooksClick(Self);
     finally  // Safe cleanup
     end;
end;

procedure Tmain_workspace.btnSearchBooks_AddLoansClick(Sender: TObject);
var
   search_term: String;
begin
     try
       try
        lstBooks_AddLoans.Clear;

        search_term := '%' + Trim(txtSearchBooks_AddLoans.Text) + '%';  // Fix: Add wildcards

        // Fix: Set SQL BEFORE Open/Prepare
        SQLQueryBooks.SQL.Text := 'SELECT book_id, book_title FROM books WHERE book_title LIKE :search_term';
        SQLQueryBooks.ParamByName('search_term').AsString := search_term;
        SQLQueryBooks.Prepare;
        SQLQueryBooks.Open;  // Now safe

        while not SQLQueryBooks.Eof do
        begin
             lstBooks_AddLoans.Items.Add(SQLQueryBooks.FieldByName('book_title').AsString);
             SQLQueryBooks.Next;
        end;
        SQLTransactionBooks.Commit;  // Add success commit

     except
        on E: EDatabaseError do
        begin
             ShowMessage('DB error: ' + E.Message);
             SQLTransactionBooks.Rollback;
             Exit;
        end;
        on E: Exception do
        begin
             SQLTransactionBooks.Rollback;
             ShowMessage('Search failed: ' + E.Message);
             Exit;
        end;
     end;

     //call refresh button
     //btnRefresh_EditBooksClick(Self);
     finally  // Safe cleanup
     end;
end;

procedure Tmain_workspace.btnSearchClick(Sender: TObject);
var
   search_term: String;
begin

     try
       try
        lstEdit.Clear;

        search_term := '%' + Trim(txtSearch.Text) + '%';  // Fix: Add wildcards

        // Fix: Set SQL BEFORE Open/Prepare
        SQLQueryBooks.SQL.Text := 'SELECT book_id, book_title FROM books WHERE book_title LIKE :search_term';
        SQLQueryBooks.ParamByName('search_term').AsString := search_term;
        SQLQueryBooks.Prepare;
        SQLQueryBooks.Open;  // Now safe

        while not SQLQueryBooks.Eof do
        begin
             lstEdit.Items.Add(SQLQueryBooks.FieldByName('book_title').AsString);
             SQLQueryBooks.Next;
        end;
        SQLTransactionBooks.Commit;  // Add success commit

     except
        on E: EDatabaseError do
        begin
             ShowMessage('DB error: ' + E.Message);
             SQLTransactionBooks.Rollback;
             Exit;
        end;
        on E: Exception do
        begin
             SQLTransactionBooks.Rollback;
             ShowMessage('Search failed: ' + E.Message);
             Exit;
        end;
     end;

     //call refresh button
     btnRefresh_EditBooksClick(Self);
     finally  // Safe cleanup

     end;
end;

procedure Tmain_workspace.btnSearchReaders_AddLoansClick(Sender: TObject);
var
   search_term: String;
   search_by: String;
begin
     try
       try
        lstReaders_AddLoans.Clear;

        search_term := '%' + Trim(txtSearchReaders_AddLoans.Text) + '%';  // Fix: Add wildcards

        // Fix: Set SQL BEFORE Open/Prepare
        SQLQueryBooks.SQL.Text := 'SELECT reader_id, reader_name FROM readers WHERE :search_by LIKE :search_term';
        SQLQueryBooks.ParamByName('search_term').AsString := search_term;
        SQLQueryBooks.ParamByName('search_by').AsString := 'reader_name';
        SQLQueryBooks.Prepare;
        SQLQueryBooks.Open;  // Now safe

        while not SQLQueryBooks.Eof do
        begin
             lstReaders_AddLoans.Items.Add((SQLQueryBooks.FieldByName('reader_id').AsString) + ' - ' + (SQLQueryBooks.FieldByName('reader_name').AsString));
             SQLQueryBooks.Next;
        end;
        SQLTransactionBooks.Commit;  // Add success commit

     except
        on E: EDatabaseError do
        begin
             SQLTransactionBooks.Rollback;
             ShowMessage('DB error: ' + E.Message);
             Exit;
        end;
        on E: Exception do
        begin
             SQLTransactionBooks.Rollback;
             ShowMessage('Search failed: ' + E.Message);
             Exit;
        end;
     end;

     //call refresh button
     //btnRefresh_EditReadersClick(Self);
     finally  // Safe cleanup
     end;
end;

procedure Tmain_workspace.btnSearch_SearchReadersClick(Sender: TObject);
begin

end;


procedure Tmain_workspace.btnSetDefaultCfgClick(Sender: TObject);
var
  AppDir: string;
  CfgDir: string;
  CfgPath: string;
  CfgNum: Integer;
  CfgFileName: string;
  F: TextFile;
begin
  CfgNum := 1; //for now - constant cfg number
  AppDir := ExtractFilePath(Application.ExeName);
  CfgDir := IncludeTrailingPathDelimiter(AppDir) + 'configs';
  ForceDirectories(CfgDir); //create db folder if not exist
  CfgFileName := 'default.cfg';
  CfgPath := IncludeTrailingPathDelimiter(CfgDir) + CfgFileName; //full path with filename
  AssignFile(F, CfgPath);
  Rewrite(F);
  Writeln(F, current_books_db);
  Writeln(F, current_readers_db);
  Writeln(F, current_loans_db);
  Writeln(F, 'Created on: ' + DateTimeToStr(Now));
  Writeln(F, 'This was created as default config file.');
  CloseFile(F);

  ShowMessage('Config saved as: ' + CfgFileName);
end;

procedure Tmain_workspace.btnCloseSearchLoansClick(Sender: TObject);
begin
  //clear fields
  lstSearchLoans.Caption := '';
  txtSearchLoans.Text := '';
  cboSearchByLoans.Text := '';
  lblLoanSum.Caption := '';
  lbl_searchloans_db.Caption := '';

  goto_backdrop();
end;

procedure Tmain_workspace.Button16Click(Sender: TObject);
begin
  //clear fields
  txtSearch_ExpiredLoans.Text := '';
  cboSearchBy_ExpiredLoans.Text := '';
  cboSortBy_ExpiredLoans.Text := '';
  cboChangeDate.Text := '';
  lbl_expiredloans_db.Caption := '';

  goto_backdrop();
end;

procedure Tmain_workspace.btnClear_ExpiredLoansClick(Sender: TObject);
begin
  //clear fields
  txtSearch_ExpiredLoans.Text := '';
  cboSearchBy_ExpiredLoans.Text := '';
  cboSortBy_ExpiredLoans.Text := '';
  cboChangeDate.Text := '';
  lbl_expiredloans_db.Caption := '';
end;

procedure Tmain_workspace.btnClear_AddUsersClick(Sender: TObject);
begin
  txtPassword1_AddUsers.Text := '';
  txtPassword2_AddUsers.Text := '';
  txtUsername_AddUsers.Text := '';
  cboRole_AddUsers.Text := '';
end;

procedure Tmain_workspace.btnAddUserClick(Sender: TObject);
  var
  role: string;
  role_int: Integer;
  password: string;
  username: string;
  username_hash, password_hash: string;
  AppDir: string;
  DBDir: string;
  DBPath: string;
begin
  Application.ProcessMessages;
  //check if fields are empty
  if ((Trim(txtUsername_AddUsers.Text) = '')) or ((Trim(txtPassword1_AddUsers.Text) = '')) or ((Trim(txtPassword2_AddUsers.Text) = '')) then
     begin
          ShowMessage('Username and password cannot be empty!');
          Exit;
     end;
  //check if username and password are the same
  if (txtPassword1_AddUsers.Text = txtUsername_AddUsers.Text) or (txtPassword2_AddUsers.Text = txtUsername_AddUsers.Text) then
     begin
       ShowMessage('Username and password cannot be the same!');
       Exit;
     end
  else
  //check if passwords match
  if (txtPassword1_AddUsers.Text <> txtPassword2_AddUsers.Text) then
     begin
       ShowMessage('Passwords do not match!');
       Exit;
     end;

  //check if role selected
  if (not cboRole_AddUsers.ItemIndex >= 0 ) then //when ItemIndex <0 that means no user role selection
      begin
           ShowMessage('Select a user role!');
           Exit;
      end;

  //check if all of the above are correct
	  role := cboRole_AddUsers.Text;
	  password := txtPassword1_AddUsers.Text;
	  username := txtUsername_AddUsers.Text;
          //get SHA-512 hashes of usr and pwd
          password_hash := SHA512String(password);
          username_hash := SHA512String(username);
          //translate role into role number
          if (role = 'Superadmin') then
          begin
               role_int := 3;
          end
          else if (role = 'Admin') then
          begin
               role_int := 2;
          end
          else //if not either - default to user
          begin
               role_int := 1;
          end;



	  try
             try
		// Create table if needed
		SQLite3ConnectionBooks.ExecuteDirect(
		  'CREATE TABLE IF NOT EXISTS users (' +
		  'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
		  'username TEXT NOT NULL UNIQUE, ' +
		  'password TEXT NOT NULL, ' +
		  'role INTEGER NOT NULL)');

		// Insert user
		SQLQueryBooks.SQL.Text :=
		  'INSERT INTO users (username, password, role) ' +
		  'VALUES (:username, :password, :role)';
		SQLQueryBooks.ParamByName('username').AsString := username_hash;
		SQLQueryBooks.ParamByName('password').AsString := password_hash;
		SQLQueryBooks.ParamByName('role').AsString := IntToStr(role_int);
		SQLQueryBooks.ExecSQL;

		SQLTransactionBooks.Commit;
		ShowMessage('User created successfully! Please log in.');

	  except
                on E: EDatabaseError do
                begin
                  if Pos('DB error: UNIQUE constant failed: users.username', E.Message) > 0 then
                  begin
                   ShowMessage('User already exists! Please use a different username!');
                   Exit;
                  end
                  else
                    ShowMessage('DB error: ' + E.Message);
                    SQLTransactionBooks.Rollback;
                    Exit; //exit on error
                end;
                on E: Exception do
		begin
		  SQLTransactionBooks.Rollback;
		  ShowMessage('Registration failed: ' + E.Message);
		  Exit;  //exit on error
		end;

	  end;

	  // Clear only on success
	  txtUsername_AddUsers.Clear;
	  txtPassword1_AddUsers.Clear;
	  txtPassword2_AddUsers.Clear;

          username := '';
          password := '';
          role := '';
          role_int := 0;

	  finally
          end;
end;

procedure Tmain_workspace.btnSearch_DeleteReadersClick(Sender: TObject);
  var
     search_term: String;
     search_by: String;
  begin
       try
         try
          lstDeleteReaders.Clear;

          search_term := '%' + Trim(txtSearch_DeleteReaders.Text) + '%';  // Fix: Add wildcards

          // Fix: Set SQL BEFORE Open/Prepare
          SQLQueryBooks.SQL.Text := 'SELECT reader_id, reader_name FROM readers WHERE :search_by LIKE :search_term';
          SQLQueryBooks.ParamByName('search_term').AsString := search_term;
          SQLQueryBooks.ParamByName('search_by').AsString := 'reader_name';
          SQLQueryBooks.Prepare;
          SQLQueryBooks.Open;  // Now safe

          while not SQLQueryBooks.Eof do
          begin
               lstDeleteReaders.Items.Add((SQLQueryBooks.FieldByName('reader_id').AsString) + ' - ' + (SQLQueryBooks.FieldByName('reader_name').AsString));
               SQLQueryBooks.Next;
          end;
          SQLTransactionBooks.Commit;  // Add success commit

       except
          on E: EDatabaseError do
          begin
               SQLTransactionBooks.Rollback;
               ShowMessage('DB error: ' + E.Message);
               Exit;
          end;
          on E: Exception do
          begin
               SQLTransactionBooks.Rollback;
               ShowMessage('Search failed: ' + E.Message);
               Exit;
          end;
       end;

       //call refresh button
       //btnRefresh_EditReadersClick(Self);
       finally  // Safe cleanup
       end;
  end;

procedure Tmain_workspace.Button22Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.btnClear_EditUsersClick(Sender: TObject);
begin
  lstSelect_EditUsers.Caption := '';
  txtSearch_EditUsers.Text := '';
  cboSearch_EditUsers.Text := '';
  txtUsername_EditUsers.Text := '';
  txtEditPassword1.Text := '';
  txtEditPassword2.Text := '';
  txtAuthenticate_EditUsers.Text := '';
  chkHideEditPswd1.Checked := true;
  chkHideEditPswd2.Checked := true;
end;

procedure Tmain_workspace.Button24Click(Sender: TObject);
begin

end;

procedure Tmain_workspace.Button25Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.goto_db_selection();
begin
  //check if dbs other than users exist
  If not check_dbs_created then Exit;
  //go to actual form
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 28;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.Button28Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.btnClose_AddDatabaseClick(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.btnCreateDBClick(Sender: TObject);
var
  dbname: string;
  db_type: string;
  pkey_db: string;
  encryption_type: string;
  bookdb_execute, readerdb_execute, loandb_execute : string;
  to_execute: string;
  DBDir, DBPath: string;
begin
    if cboDBType.Text = '' then
    begin
         ShowMessage('Please select database type!');
         Exit;
    end;
    if txtDBName_Add.Text = '' then
    begin
         ShowMessage('Please input database name!');
         Exit;
    end;
    if (Length(cboEncryptionType_Add.Text) > 0) and (Length(txtPrivateKey_Add.Text) = 0) then
    begin
        if MessageDlg('It seems that you want to encrypt your database, yet you have no private key inputted. Generate one automatically?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
            //random key generation here
            ShowMessage('Not made yet!');
            Exit; //for now - exit function
        end
        else
        begin
            ShowMessage('Please input private key!');
            Exit;
        end;
    end;
    if (Length(cboEncryptionType_Add.Text) = 0) and (Length(txtPrivateKey_Add.Text) > 0) then
    begin
        ShowMessage('It seems that you want to encrypt your database, yet you have no encryption type. Please select encryption type.');
        Exit;
    end;
  	  dbname := txtDBName_Add.Text;
          db_type := cboDBType.Text;
  	  pkey_db := txtPrivateKey_Add.Text;
          encryption_type := cboEncryptionType_Add.Text;
  	  try
             try
          AppDir := ExtractFilePath(Application.ExeName);
          DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
          ForceDirectories(DBDir); //create db folder if not exist
          DBPath := IncludeTrailingPathDelimiter(DBDir) + txtDBName_Add.Text + '.db'; //full path with filename
          SQLite3ConnectionDatabases.DatabaseName := DBPath; //sets connection to this path
          //SQLQuery1.Prepare;
          if not SQLite3ConnectionDatabases.Connected then
          begin
	       SQLite3ConnectionDatabases.Open;
          end;
          SQLQueryDatabases.Database := SQLite3ConnectionDatabases; //connect db to sql query
          SQLTransactionDatabases.Database := SQLite3ConnectionDatabases;
          SQLQueryDatabases.Transaction := SQLTransactionDatabases;
          SQLTransactionDatabases.StartTransaction;  // Start explicit transaction

                //create different databases based on user selection
                bookdb_execute := 'CREATE TABLE IF NOT EXISTS books (' + LineEnding +
  		  'id INTEGER PRIMARY KEY AUTOINCREMENT,' + LineEnding +
  		  'book_id TEXT NOT NULL UNIQUE,' + LineEnding +
  		  'book_title TEXT NOT NULL,' + LineEnding +
  		  'book_author TEXT NOT NULL,' + LineEnding +
                  'book_location TEXT NOT NULL,' + LineEnding +
                  'book_category TEXT NOT NULL,' + LineEnding +
                  'book_status TEXT NOT NULL)';
                readerdb_execute := 'CREATE TABLE IF NOT EXISTS readers (' + LineEnding +
  		  'reader_name TEXT NOT NULL, ' + LineEnding +
  		  'reader_surname TEXT NOT NULL, ' + LineEnding +
  		  'reader_grade INTEGER NOT NULL,' + LineEnding +
                  'reader_class TEXT NOT NULL,' + LineEnding +
                  'reader_id INTEGER PRIMARY KEY AUTOINCREMENT)';
                loandb_execute := 'CREATE TABLE IF NOT EXISTS loans (' + LineEnding +
  		  'loan_id INTEGER PRIMARY KEY AUTOINCREMENT,' + LineEnding +
  		  'book_id TEXT NOT NULL,' + LineEnding +
  		  //'book_name TEXT NOT NULL,' + LineEnding +
  		  //'book_author TEXT NOT NULL,' + LineEnding +
                  //'book_location TEXT NOT NULL,' + LineEnding +
                  //'book_category TEXT NOT NULL,' + LineEnding +
                  //'book_status TEXT NOT NULL,' + LineEnding +
  		  //'name TEXT NOT NULL, ' + LineEnding +
  		  //'surname TEXT NOT NULL, ' + LineEnding +
  		  //'grade INTEGER NOT NULL,' + LineEnding +
                  //'class TEXT NOT NULL,' + LineEnding +
                  'reader_id INTEGER NOT NULL,' + LineEnding +
                  'date_of_return DATE NOT NULL)';
                if db_type = 'Books' then to_execute := bookdb_execute;
                if db_type = 'Readers' then to_execute := readerdb_execute;
                if db_type = 'Loans' then to_execute := loandb_execute;

  		// execute specified payload
  		SQLite3ConnectionDatabases.ExecuteDirect(to_execute);

  		SQLTransactionDatabases.Commit;

  	  except
                on E: Exception do
                begin
                  SQLTransactionDatabases.Rollback;
  		  ShowMessage('DB creation failed: ' + E.Message);
  		  Exit;  //exit on error
  		end;
  	  end;


          // Clear only on success
  	  txtPrivateKey_Add.Clear;
  	  txtDBName_Add.Clear;
          ShowMessage('Database ' + dbname + ' created succesfully! Type: ' + db_type);

          finally
              SQLQueryDatabases.DisableControls;
              SQLQueryDatabases.Close;
              SQLQueryDatabases.SQL.Clear;
              SQLQueryDatabases.Transaction := SQLTransactionBooks;
              SQLQueryDatabases.Database := SQLite3ConnectionBooks;
              SQLQueryDatabases.SQLConnection := SQLite3ConnectionBooks;
          end;

end;

procedure Tmain_workspace.Button32Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.Button34Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.Button37Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.btnCloseAddLoansClick(Sender: TObject);
begin
  //clear fields
  txtSearchReaders_AddLoans.Text := '';
  txtSearchReadersBy_AddLoans.Text := '';
  txtSearchBooks_AddLoans.Text := '';
  txtSearchBooksBy_AddLoans.Text := '';
  lstBooks_AddLoans.Caption := '';
  txtDays_AddLoans.Text := '';
  lbl_addloans_db.Caption := '';
  goto_backdrop();
end;

procedure Tmain_workspace.btnClear_EditLoansClick(Sender: TObject);
begin
  //clear fields
  txtSearchLoans_EditLoans.Text := '';
  txtSearchReaders_EditLoans.Text := '';
  txtSearchBooks_EditLoans.Text := '';
  cboSearchByLoans_EditLoans.Text := '';
  cboSearchByReaders_EditLoans.Text := '';
  cboSearchByBooks_EditLoans.Text := '';
  lstLoans_EditLoans.Caption := '';
  lstReaders_EditLoans.Caption := '';
  lstBooks_EditLoans.Caption := '';
  lbl_editloans_db.Caption := '';
  txtDays_EditLoans.Text := '';
end;

procedure Tmain_workspace.btnSearch_EditReadersClick(Sender: TObject);
var
   search_term: String;
   search_by: String;
begin
     try
       try
        lstEditReaders.Clear;

        search_term := '%' + Trim(txtSearch4.Text) + '%';  // Fix: Add wildcards

        // Fix: Set SQL BEFORE Open/Prepare
        SQLQueryBooks.SQL.Text := 'SELECT reader_id, reader_name FROM readers WHERE :search_by LIKE :search_term';
        SQLQueryBooks.ParamByName('search_term').AsString := search_term;
        SQLQueryBooks.ParamByName('search_by').AsString := 'reader_name';
        SQLQueryBooks.Prepare;
        SQLQueryBooks.Open;  // Now safe

        while not SQLQueryBooks.Eof do
        begin
             lstEditReaders.Items.Add((SQLQueryBooks.FieldByName('reader_id').AsString) + ' - ' + (SQLQueryBooks.FieldByName('reader_name').AsString));
             SQLQueryBooks.Next;
        end;
        SQLTransactionBooks.Commit;  // Add success commit

     except
        on E: EDatabaseError do
        begin
             SQLTransactionBooks.Rollback;
             ShowMessage('DB error: ' + E.Message);
             Exit;
        end;
        on E: Exception do
        begin
             SQLTransactionBooks.Rollback;
             ShowMessage('Search failed: ' + E.Message);
             Exit;
        end;
     end;

     //call refresh button
     //btnRefresh_EditReadersClick(Self);
     finally  // Safe cleanup
     end;
end;

procedure Tmain_workspace.Button41Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.Button44Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.Button48Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.btnCloseEditLoansClick(Sender: TObject);
begin
  //clear fields
  txtSearchLoans_EditLoans.Text := '';
  txtSearchReaders_EditLoans.Text := '';
  txtSearchBooks_EditLoans.Text := '';
  cboSearchByLoans_EditLoans.Text := '';
  cboSearchByReaders_EditLoans.Text := '';
  cboSearchByBooks_EditLoans.Text := '';
  lstLoans_EditLoans.Caption := '';
  lstReaders_EditLoans.Caption := '';
  lstBooks_EditLoans.Caption := '';
  lbl_editloans_db.Caption := '';
  txtDays_EditLoans.Text := '';
  goto_backdrop();
end;

procedure Tmain_workspace.Button51Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.Button52Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.Button54Click(Sender: TObject);
begin
  goto_backdrop();
end;

procedure Tmain_workspace.btnCloseSearchReadersClick(Sender: TObject);
begin
  //clear fields
  txtSearchReaders.Text := '';
  lbl_searchreaders_db.Caption := '';
  cboFilters6.Text := '';
  lblReaderSum.Caption := '';
  goto_backdrop();
end;

procedure Tmain_workspace.Button59Click(Sender: TObject);
begin
  //add "are you sure"
  current_books_db := '';
  current_readers_db := '';
  current_loans_db := '';
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 2;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.btnLoadDefaultCfgClick(Sender: TObject);
var
  AppDir: string;
  DBDir: string;
  filename: string;
  CurrentLine: integer;
  tmpLine: string;
  F: TextFile;
begin
  AppDir := ExtractFilePath(Application.ExeName);
  DBDir := IncludeTrailingPathDelimiter(AppDir) + 'configs';
  filename := IncludeTrailingPathDelimiter(DBDir) + 'default.cfg';

  //start iterating through the lines
  AssignFile(F, filename);
  try
    Reset(F);
    CurrentLine := 0;
    while not EOF(F) and (CurrentLine < 3) do
    begin
        ReadLn(F, tmpLine); //reads line into tmpLine
        If CurrentLine = 0 then
        begin
             current_books_db := tmpLine;
             lbl_bookdb.Caption := current_books_db; //update visually
        end
        else if CurrentLine = 1 then
        begin
             current_readers_db := tmpLine;
             lbl_readerdb.Caption := current_books_db; //update visually
        end
        else if CurrentLine = 2 then
        begin
             current_loans_db := tmpLine;
             lbl_loandb.Caption := current_books_db; //update visually
        end;
        Inc(CurrentLine); //incements current line
    end;
  finally
    CloseFile(F);
  end;
end;

procedure Tmain_workspace.btnLoadCfgClick(Sender: TObject);
var
  AppDir: string;
  DBDir: string;
  filename: string;
  CurrentLine: integer;
  tmpLine: string;
  F: TextFile;
begin
  AppDir := ExtractFilePath(Application.ExeName);
  DBDir := IncludeTrailingPathDelimiter(AppDir) + 'configs';
  OpenDialog1.InitialDir := DBDir;
  OpenDialog1.FileName := '';
  OpenDialog1.Filter := 'Configuration Files (*.cfg)';
  if OpenDialog1.Execute then
  begin
    //ShowMessage('Selected file: ' + OpenDialog1.FileName);
  end;
  filename := ExtractFileName(OpenDialog1.FileName);

  //start iterating through the lines
  AssignFile(F, FileName);
  try
    Reset(F);
    CurrentLine := 0;
    while not EOF(F) and (CurrentLine < 3) do
    begin
        ReadLn(F, tmpLine); //reads line into tmpLine
        If CurrentLine = 0 then
        begin
             current_books_db := tmpLine;
             lbl_bookdb.Caption := current_books_db; //update visually
        end
        else if CurrentLine = 1 then
        begin
             current_readers_db := tmpLine;
             lbl_readerdb.Caption := current_books_db; //update visually
        end
        else if CurrentLine = 2 then
        begin
             current_loans_db := tmpLine;
             lbl_loandb.Caption := current_books_db; //update visually
        end;
        Inc(CurrentLine); //incements current line
    end;
  finally
    CloseFile(F);
  end;


end;

procedure Tmain_workspace.btnSaveCfgClick(Sender: TObject);
var
  AppDir: string;
  CfgDir: string;
  CfgPath: string;
  CfgNum: Integer;
  CfgFileName: string;
  F: TextFile;
begin
  CfgNum := 1; //for now - constant cfg number
  AppDir := ExtractFilePath(Application.ExeName);
  CfgDir := IncludeTrailingPathDelimiter(AppDir) + 'configs';
  ForceDirectories(CfgDir); //create db folder if not exist
  CfgFileName := 'config' + IntToStr(CfgNum) + '.cfg';
  CfgPath := IncludeTrailingPathDelimiter(CfgDir) + CfgFileName; //full path with filename
  AssignFile(F, CfgPath);
  Rewrite(F);
  If (current_books_db = '') then
     Writeln(F, 'NODBSELECTED')
  else
     Writeln(F, current_books_db);

  If (current_readers_db = '') then
     Writeln(F, 'NODBSELECTED')
  else
     Writeln(F, current_readers_db);

  If (current_loans_db = '') then
     Writeln(F, 'NODBSELECTED')
  else
     Writeln(F, current_loans_db);

  Writeln(F, 'Created on: ' + DateTimeToStr(Now));
  CloseFile(F);

  ShowMessage('Config saved as: ' + CfgFileName);
end;

procedure Tmain_workspace.applyandcloseClick(Sender: TObject);
begin
  If (current_books_db = '') or (current_readers_db = '') or (current_loans_db = '') then
  begin
     if MessageDlg('One of the DB forms are not selected. Are you sure you want to proceed? You can always return to this menu by clicking "Current Databases" in the toolbar.', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
       begin
         workspace_control.ShowTabs := False;
         workspace_control.PageIndex := 2;
         workspace_control.Refresh;
       end
  end
  else
  begin
       goto_backdrop();
  end;

end;

procedure Tmain_workspace.chkBulkModeChange(Sender: TObject);
begin

end;

procedure Tmain_workspace.chkHidePrivateKey_AddDatabasesChange(Sender: TObject);
begin
  if chkHidePrivateKey_AddDatabases.Checked then
     txtPrivateKey_Add.PasswordChar := '*'
  else
      txtPrivateKey_Add.PasswordChar := #0;
end;

procedure Tmain_workspace.databases_mainClick(Sender: TObject);
begin

end;

procedure Tmain_workspace.dbselect_booksClick(Sender: TObject);
var
  AppDir: string;
  DBDir: string;
begin
  AppDir := ExtractFilePath(Application.ExeName);
  DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
  OpenDialog1.InitialDir := DBDir;
  OpenDialog1.FileName := '';
  OpenDialog1.Filter := 'Databases (*.db)';
  if OpenDialog1.Execute then
  begin
    if (ExtractFileName(OpenDialog1.FileName) = 'users.db') then //check if user selected user db
    begin
      ShowMessage('Do not select users.db database');
      Exit;
    end
    else if ExtractFileName(OpenDialog1.FileName) = '' then
    begin
      ShowMessage('No book database selected.');
      Exit;
    end;
    ShowMessage('Selected file: ' + OpenDialog1.FileName);
  end;
  current_books_db := ExtractFileName(OpenDialog1.FileName);
  lbl_bookdb.Caption := '';
  lbl_bookdb.Caption := current_books_db;

  ConnectToDB_books(); //connect to DB

end;

procedure Tmain_workspace.btnCloseRemoveLoansClick(Sender: TObject);
begin
  //clear fields
  txtSearch_RemoveLoans.Text := '';
  lbl_removeloans_db.Caption := '';
  lstSelect_RemoveLoans.Caption := '';
  cboSearchBy_RemoveLoans.Text := '';

  goto_backdrop();
end;

procedure Tmain_workspace.btnCloseAddBooksClick(Sender: TObject);
begin
     //clear fields
     txtID.Text := '';
     txtTitle.Text := '';
     txtAuthor.Text := '';
     txtLocation.Text := '';
     cboCategory.Text := '';
     cboStatus.Text := '';
     lbl_addbooks_db.Caption := '';

     goto_backdrop();
end;

procedure Tmain_workspace.chkHideAddPswd1Change(Sender: TObject);
begin
  if chkHideAddPswd1.Checked then
     txtPassword1_AddUsers.PasswordChar := '*'
  else
      txtPassword1_AddUsers.PasswordChar := #0;
end;

procedure Tmain_workspace.chkHideAddPswd2Change(Sender: TObject);
begin
  if chkHideAddPswd2.Checked then
     txtPassword2_AddUsers.PasswordChar := '*'
  else
      txtPassword2_AddUsers.PasswordChar := #0;
end;

procedure Tmain_workspace.chkHideEditPswd1Change(Sender: TObject);
begin
  if chkHideEditPswd1.Checked then
     txtEditPassword1.PasswordChar := '*'
  else
      txtEditPassword1.PasswordChar := #0;
end;

procedure Tmain_workspace.chkHideEditPswd2Change(Sender: TObject);
begin
  if chkHideEditPswd2.Checked then
     txtEditPassword2.PasswordChar := '*'
  else
      txtEditPassword2.PasswordChar := #0;
end;

procedure Tmain_workspace.clear_workspaceClick(Sender: TObject);
begin
    //AppDir := ExtractFilePath(Application.ExeName); //gets app dir
    //workspace_control.ShowTabs := False;
    //backdrop_image.Picture.LoadFromFile(AppDir + 'BookwormPascalLogo1.png');
    //backdrop_image.Visible := True;
    workspace_control.ShowTabs := False;
    workspace_control.PageIndex := 2;
    workspace_control.Refresh;
end;

procedure Tmain_workspace.databases_addClick(Sender: TObject);
begin
  If not authenticate(3) then Exit;
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 18;
  workspace_control.Refresh;
  TabSheet19Show(Self);
end;

procedure Tmain_workspace.databases_backupClick(Sender: TObject);
begin
  If not authenticate(3) then Exit;
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 21;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.databases_editClick(Sender: TObject);
begin
  If not authenticate(3) then Exit;
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 19;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.databases_serverClick(Sender: TObject);
begin
  If not authenticate(3) then Exit;
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 23;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.databases_p2pClick(Sender: TObject);
begin
  If not authenticate(3) then Exit;
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 22;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.databases_removeClick(Sender: TObject);
begin
  If not authenticate(3) then Exit;
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 20;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.dbselect_loansClick(Sender: TObject);
var
  AppDir: string;
  DBDir: string;
begin
      AppDir := ExtractFilePath(Application.ExeName);
      DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
      OpenDialog1.InitialDir := DBDir;
      OpenDialog1.FileName := '';
      OpenDialog1.Filter := 'Databases (*.db)';
      if OpenDialog1.Execute then
      begin
      If (ExtractFileName(OpenDialog1.FileName) = 'users.db') then //check if user selected user db
      begin
           ShowMessage('Do not select users.db database');
           Exit;
      end
      else if ExtractFileName(OpenDialog1.FileName) = '' then
      begin
           ShowMessage('No book database selected.');
           Exit;
      end;
        ShowMessage('Selected file: ' + OpenDialog1.FileName);
      end;
      current_loans_db := ExtractFileName(OpenDialog1.FileName);
      lbl_loandb.Caption := '';
      lbl_loandb.Caption := current_loans_db;

        ConnectToDB_loans(); //connect to DB
end;

procedure Tmain_workspace.dbselect_readersClick(Sender: TObject);
var
AppDir: string;
DBDir: string;
begin
    AppDir := ExtractFilePath(Application.ExeName);
    DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
    OpenDialog1.InitialDir := DBDir;
    OpenDialog1.FileName := '';
    OpenDialog1.Filter := 'Databases (*.db)';
    if OpenDialog1.Execute then
    begin
      If (ExtractFileName(OpenDialog1.FileName) = 'users.db') then //check if user selected user db
      begin
           ShowMessage('Do not select users.db database');
           Exit;
      end
      else if ExtractFileName(OpenDialog1.FileName) = '' then
      begin
           ShowMessage('No book database selected.');
           Exit;
      end;
      ShowMessage('Selected file: ' + OpenDialog1.FileName);
    end;
    current_readers_db := ExtractFileName(OpenDialog1.FileName);;
    lbl_readerdb.Caption := '';
    lbl_readerdb.Caption := current_readers_db;

    ConnectToDB_readers(); //connect to DB
end;

procedure Tmain_workspace.lstBooks_AddLoansClick(Sender: TObject);
var
  SelIndex: Integer;
  ItemText: string;
  DashPos: Integer;
  RecID: string;
begin
  SelIndex := lstBooks_AddLoans.ItemIndex;
  if SelIndex < 0 then Exit;

  ItemText := lstBooks_AddLoans.Items[SelIndex];
  DashPos := Pos(' - ', ItemText);
  if DashPos <= 0 then
  begin
    ShowMessage('List format invalid. Run PopulateReaderList first.');
    Exit;  // NO repopulate here
  end;

  RecID := Trim(Copy(ItemText, 1, DashPos - 1));
  if RecID = '' then Exit;

  try
     try
  // Safe query use
  SQLQueryBooks.SQL.Clear;
  SQLQueryBooks.SQL.Add('SELECT * FROM books WHERE book_id = :id');
  SQLQueryBooks.ParamByName('id').AsString := RecID;
  SQLQueryBooks.Open;

  if not SQLQueryBooks.Eof then
  begin
    txtBookID_AddLoans.Text := SQLQueryBooks.FieldByName('book_id').AsString;
  end
  else
    ShowMessage('ID "' + RecID + '" not found.');

    except
    on E: EDatabaseError do
    begin
      ShowMessage('DB error: ' + E.Message);
      Exit; //exit on error
    end;
    on E: Exception do
    begin
      ShowMessage('General Error: ' + E.ClassName + ' - ' + E.Message);
      Exit; //exit on error
    end;
  end;

     finally
     //db cleanup
     end;

end;

procedure Tmain_workspace.lstDeleteClick(Sender: TObject);
var
  SelIndex: Integer;
  ItemText: string;
  DashPos: Integer;
  RecID: string;
begin
  SelIndex := lstDelete.ItemIndex;
  if SelIndex < 0 then Exit;

  ItemText := lstDelete.Items[SelIndex];
  DashPos := Pos(' - ', ItemText);
  if DashPos <= 0 then
  begin
    ShowMessage('List format invalid. Run PopulateBookList first.');
    Exit;  // NO repopulate here
  end;

  RecID := Trim(Copy(ItemText, 1, DashPos - 1));
  if RecID = '' then Exit;
  try
     try
  // Safe query use
  SQLQueryBooks.Close;
  SQLQueryBooks.SQL.Clear;
  SQLQueryBooks.SQL.Add('SELECT * FROM books WHERE book_id = :id');
  SQLQueryBooks.ParamByName('id').AsString := RecID;
  SQLQueryBooks.Open;

  if not SQLQueryBooks.Eof then
  begin
    txtID_DeleteBooks.Text := SQLQueryBooks.FieldByName('book_id').AsString;
  end
  else
    ShowMessage('ID "' + RecID + '" not found.');

    except
    on E: EDatabaseError do
    begin
      ShowMessage('DB error: ' + E.Message);
      Exit; //exit on error
    end;
    on E: Exception do
    begin
      ShowMessage('General Error: ' + E.ClassName + ' - ' + E.Message);
      Exit; //exit on error
    end;
  end;

     finally
     //db cleanup
     end;

end;

procedure Tmain_workspace.lstDeleteReadersClick(Sender: TObject);
var
  SelIndex: Integer;
  ItemText: string;
  DashPos: Integer;
  RecID: string;
begin
  SelIndex := lstDeleteReaders.ItemIndex;
  if SelIndex < 0 then Exit;

  ItemText := lstDeleteReaders.Items[SelIndex];
  DashPos := Pos(' - ', ItemText);
  if DashPos <= 0 then
  begin
    ShowMessage('List format invalid. Run PopulateReaderList first.');
    Exit;  // NO repopulate here
  end;

  RecID := Trim(Copy(ItemText, 1, DashPos - 1));
  if RecID = '' then Exit;

  try
     try
  // Safe query use
  SQLQueryBooks.SQL.Clear;
  SQLQueryBooks.SQL.Add('SELECT * FROM readers WHERE reader_id = :id');
  SQLQueryBooks.ParamByName('id').AsString := RecID;
  SQLQueryBooks.Open;

  if not SQLQueryBooks.Eof then
  begin
    txtSelectedID_DeleteReaders.Text := SQLQueryBooks.FieldByName('reader_id').AsString;
  end
  else
    ShowMessage('ID "' + RecID + '" not found.');

    except
    on E: EDatabaseError do
    begin
      ShowMessage('DB error: ' + E.Message);
      Exit; //exit on error
    end;
    on E: Exception do
    begin
      ShowMessage('General Error: ' + E.ClassName + ' - ' + E.Message);
      Exit; //exit on error
    end;
  end;

     finally
     //db cleanup
     end;

end;

procedure Tmain_workspace.lstEditReadersClick(Sender: TObject);
var
  SelIndex: Integer;
  ItemText: string;
  DashPos: Integer;
  RecID: string;
begin
  SelIndex := lstEditReaders.ItemIndex;  //LST NAME HERE
  if SelIndex < 0 then Exit;

  ItemText := lstEditReaders.Items[SelIndex]; //LST NAME HERE
  DashPos := Pos(' - ', ItemText);
  if DashPos <= 0 then
  begin
    ShowMessage('List format invalid. Run PopulateBookList first.');
    Exit;  // NO repopulate here
  end;

  RecID := Trim(Copy(ItemText, 1, DashPos - 1));
  if RecID = '' then Exit;

  try
   try
  // Safe query use
  SQLQueryBooks.SQL.Clear;
  SQLQueryBooks.SQL.Add('SELECT * FROM readers WHERE reader_id = :id');
  SQLQueryBooks.ParamByName('id').AsString := RecID;
  current_edit_reader_ID := RecID; //set form variable for Edit

  if not SQLQueryBooks.Eof then
  begin
    txtReaderName_Edit.Text := SQLQueryBooks.FieldByName('reader_name').AsString;
    txtReaderSurname_Edit.Text := SQLQueryBooks.FieldByName('reader_surname').AsString;
    txtReaderGrade_Edit.Text := SQLQueryBooks.FieldByName('reader_grade').AsString;
    txtReaderClass_Edit.Text := SQLQueryBooks.FieldByName('reader_class').AsString;
  end
  else
    ShowMessage('ID "' + RecID + '" not found.');

  except
    on E: EDatabaseError do
    begin
      ShowMessage('DB error: ' + E.Message);
      Exit; //exit on error
    end;
    on E: Exception do
    begin
      ShowMessage('General Error: ' + E.ClassName + ' - ' + E.Message);
      Exit; //exit on error
    end;
  end;


  finally
  //db cleanup
  end;
end;

procedure Tmain_workspace.lstReaders_AddLoansClick(Sender: TObject);
var
  SelIndex: Integer;
  ItemText: string;
  DashPos: Integer;
  RecID: string;
begin
  SelIndex := lstReaders_AddLoans.ItemIndex;
  if SelIndex < 0 then Exit;

  ItemText := lstReaders_AddLoans.Items[SelIndex];
  DashPos := Pos(' - ', ItemText);
  if DashPos <= 0 then
  begin
    ShowMessage('List format invalid. Run PopulateReaderList first.');
    Exit;  // NO repopulate here
  end;

  RecID := Trim(Copy(ItemText, 1, DashPos - 1));
  if RecID = '' then Exit;

  try
     try
  // Safe query use
  SQLQueryBooks.SQL.Clear;
  SQLQueryBooks.SQL.Add('SELECT * FROM readers WHERE reader_id = :id');
  SQLQueryBooks.ParamByName('id').AsString := RecID;

  if not SQLQueryBooks.Eof then
  begin
    txtReaderID_AddLoans.Text := SQLQueryBooks.FieldByName('reader_id').AsString;
  end
  else
    ShowMessage('ID "' + RecID + '" not found.');

    except
    on E: EDatabaseError do
    begin
      ShowMessage('DB error: ' + E.Message);
      Exit; //exit on error
    end;
    on E: Exception do
    begin
      ShowMessage('General Error: ' + E.ClassName + ' - ' + E.Message);
      Exit; //exit on error
    end;
  end;

     finally
     //db cleanup
     end;

end;

procedure Tmain_workspace.databases_sortClick(Sender: TObject);
begin

end;

procedure Tmain_workspace.lstEditClick(Sender: TObject);
var
  SelIndex: Integer;
  ItemText: string;
  DashPos: Integer;
  RecID: string;
begin
  SelIndex := lstEdit.ItemIndex;
  if SelIndex < 0 then Exit;

  ItemText := lstEdit.Items[SelIndex];
  DashPos := Pos(' - ', ItemText);
  if DashPos <= 0 then
  begin
    ShowMessage('List format invalid. Run PopulateBookList first.');
    Exit;  // NO repopulate here
  end;

  RecID := Trim(Copy(ItemText, 1, DashPos - 1));
  if RecID = '' then Exit;

  try
   try
  // Safe query use
  SQLQueryBooks.SQL.Clear;
  SQLQueryBooks.SQL.Add('SELECT * FROM books WHERE book_id = :id');
  SQLQueryBooks.ParamByName('id').AsString := RecID;
  SQLQueryBooks.Open;

  if not SQLQueryBooks.Eof then
  begin
    txtBookID2.Text := SQLQueryBooks.FieldByName('book_id').AsString;
    txtTitle2.Text := SQLQueryBooks.FieldByName('book_title').AsString;
    txtAuthor2.Text := SQLQueryBooks.FieldByName('book_author').AsString;
    txtLocation2.Text := SQLQueryBooks.FieldByName('book_location').AsString;
    cboCategory2.Text := SQLQueryBooks.FieldByName('book_category').AsString;
    cboStatus2.Text := SQLQueryBooks.FieldByName('book_status').AsString;
  end
  else
    ShowMessage('ID "' + RecID + '" not found.');

     except
    on E: EDatabaseError do
    begin
      ShowMessage('DB error: ' + E.Message);
      Exit; //exit on error
    end;
    on E: Exception do
    begin
      ShowMessage('General Error: ' + E.ClassName + ' - ' + E.Message);
      Exit; //exit on error
    end;
  end;

  finally

  end;
end;


procedure Tmain_workspace.PopulateBookListInternal_Remove;
begin
  lstDelete.Items.Clear;
  try
   try
    SQLQueryBooks.SQL.Text := 'SELECT book_id, book_title FROM books ORDER BY book_title';
    SQLQueryBooks.Open;
    while not SQLQueryBooks.Eof do
    begin
      lstDelete.Items.Add(
        SQLQueryBooks.FieldByName('book_id').AsString + ' - ' +
        SQLQueryBooks.FieldByName('book_title').AsString
      );
      SQLQueryBooks.Next;
    end;

    except
    on E: EDatabaseError do
    begin
      ShowMessage('DB error: ' + E.Message);
      Exit; //exit on error
    end;
    on E: Exception do
    begin
      ShowMessage('General Error: ' + E.ClassName + ' - ' + E.Message);
      Exit; //exit on error
    end;
  end;

  finally
  end;
end;

procedure Tmain_workspace.PopulateBookListInternal;
begin
  lstEdit.Items.Clear;
  try
   try
    SQLQueryBooks.SQL.Text := 'SELECT book_id, book_title FROM books ORDER BY book_title';
    SQLQueryBooks.Open;
    while not SQLQueryBooks.Eof do
    begin
      lstEdit.Items.Add(
        SQLQueryBooks.FieldByName('book_id').AsString + ' - ' +
        SQLQueryBooks.FieldByName('book_title').AsString
      );
      SQLQueryBooks.Next;
    end;

    except
    on E: EDatabaseError do
    begin
      ShowMessage('DB error: ' + E.Message);
      Exit; //exit on error
    end;
    on E: Exception do
    begin
      ShowMessage('General Error: ' + E.ClassName + ' - ' + E.Message);
      Exit; //exit on error
    end;
  end;

  finally
  end;
end;


procedure Tmain_workspace.statistics_mainClick(Sender: TObject);
begin
    If not authenticate(3) then Exit;
    workspace_control.ShowTabs := False;
    workspace_control.PageIndex := 25;
    workspace_control.Refresh;
end;

procedure Tmain_workspace.loans_addClick(Sender: TObject);
begin
    if current_loans_db = '' then
      begin
           ShowMessage('Please select current database for loans!');
           main_workspace.goto_db_selection();
      end
    else
    begin
        If not authenticate(2) then Exit;
        workspace_control.ShowTabs := False;
        workspace_control.PageIndex := 9;
        workspace_control.Refresh;
    end;
end;

procedure Tmain_workspace.loans_editClick(Sender: TObject);
begin
    if current_loans_db = '' then
      begin
           ShowMessage('Please select current database for loans!');
           main_workspace.goto_db_selection();
      end
    else
    begin
        If not authenticate(2) then Exit;
        workspace_control.ShowTabs := False;
        workspace_control.PageIndex := 10;
        workspace_control.Refresh;
    end;
end;

procedure Tmain_workspace.loans_expiredClick(Sender: TObject);
begin
    if current_loans_db = '' then
      begin
           ShowMessage('Please select current database for loans!');
           main_workspace.goto_db_selection();
      end
    else
    begin
        If not authenticate(2) then Exit;
        workspace_control.ShowTabs := False;
        workspace_control.PageIndex := 13;
        workspace_control.Refresh;
    end;
end;

procedure Tmain_workspace.loans_removeClick(Sender: TObject);
begin
    if current_loans_db = '' then
      begin
           ShowMessage('Please select current database for loans!');
           main_workspace.goto_db_selection();
      end
    else
    begin
        If not authenticate(2) then Exit;
        workspace_control.ShowTabs := False;
        workspace_control.PageIndex := 11;
        workspace_control.Refresh;
    end;
end;

procedure Tmain_workspace.loans_searchClick(Sender: TObject);
begin
    if current_loans_db = '' then
      begin
           ShowMessage('Please select current database for loans!');
           main_workspace.goto_db_selection();
      end
    else
    begin
        If not authenticate(2) then Exit;
        workspace_control.ShowTabs := False;
        workspace_control.PageIndex := 12;
        workspace_control.Refresh;
    end;
end;

procedure Tmain_workspace.permissions_changeClick(Sender: TObject);
begin
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 17;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.readers_addClick(Sender: TObject);
begin
    if current_readers_db = '' then
      begin
           ShowMessage('Please select current database for readers!');
           main_workspace.goto_db_selection();
      end
    else
    begin
        If not authenticate(2) then Exit;
        workspace_control.ShowTabs := False;
        workspace_control.PageIndex := 4;
        workspace_control.Refresh;
        TabSheet6Show(Self);
    end;
end;

procedure Tmain_workspace.readers_editClick(Sender: TObject);
begin
    if current_readers_db = '' then
      begin
           ShowMessage('Please select current database for readers!');
           main_workspace.goto_db_selection();
      end
    else
    begin
        If not authenticate(2) then Exit;
        workspace_control.ShowTabs := False;
        workspace_control.PageIndex := 6;
        workspace_control.Refresh;
        TabSheet7Show(Self);
    end;
end;

procedure Tmain_workspace.readers_removeClick(Sender: TObject);
begin
    if current_readers_db = '' then
      begin
           ShowMessage('Please select current database for readers!');
           main_workspace.goto_db_selection();
      end
    else
    begin
        If not authenticate(2) then Exit;
        workspace_control.ShowTabs := False;
        workspace_control.PageIndex := 7;
        workspace_control.Refresh;
        TabSheet8Show(Self);
    end;
end;

procedure Tmain_workspace.readers_searchClick(Sender: TObject);
begin
    if current_readers_db = '' then
      begin
           ShowMessage('Please select current database for readers!');
           main_workspace.goto_db_selection();
      end
    else
    begin
        If not authenticate(2) then Exit;
        workspace_control.ShowTabs := False;
        workspace_control.PageIndex := 8;
        workspace_control.Refresh;
        TabSheet9Show(Self);
    end;
end;

procedure Tmain_workspace.settings_appClick(Sender: TObject);
begin
    If not authenticate(2) then Exit;
    workspace_control.ShowTabs := False;
    workspace_control.PageIndex := 26;
    workspace_control.Refresh;
    TabSheet27Show(Self);
end;

procedure Tmain_workspace.settings_networkingClick(Sender: TObject);
begin
    If not authenticate(3) then Exit;
    workspace_control.ShowTabs := False;
    workspace_control.PageIndex := 27;
    workspace_control.Refresh;
    TabSheet28Show(Self);
end;

///\\\-----------------------------------------------///\\\
//on tab sheet is shown procedures ontabsheetshown
procedure Tmain_workspace.TabSheet1Show(Sender: TObject);
begin
     //clear all fields by calling button click
     btnClear_AddBooksClick(TObject(Self));
     lbl_addbooks_db.Caption := current_books_db;

       //populate cbos
       cboStatus.Clear;
       cboStatus.Items.Add('Available');
       cboStatus.Items.Add('Not available');
       cboStatus.Items.Add('Not for lending');

       cboCategory.Clear;
       cboCategory.Items.Add('Example category'); //note - will require loading from categories.txt

       cboStatus.ItemIndex := 0; //first item set upon loading

       chkBulkMode.State := cbChecked; //check bulk mode by default

end;

procedure Tmain_workspace.TabSheet21ContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure Tmain_workspace.TabSheet2Show(Sender: TObject);
begin
     //clear all fields by calling button click
     btnClear_EditBooksClick(TObject(Self));
     lbl_editbooks_db.Caption := current_books_db;

     //populate cboBox
     cboSearch_EditBooks.Clear;
     cboSearch_EditBooks.Items.Add('Title');
     cboSearch_EditBooks.Items.Add('Author');
     cboSearch_EditBooks.Items.Add('Book ID');
     cboSearch_EditBooks.Items.Add('Location');
     cboSearch_EditBooks.Items.Add('Category');
     cboSearch_EditBooks.Items.Add('Status');
     cboSearch_EditBooks.ItemIndex := 0;

     cboStatus2.Clear;
     cboStatus2.Items.Add('Available');
     cboStatus2.Items.Add('Not available');
     cboStatus2.Items.Add('Not for lending');
     cboStatus2.ItemIndex := 0;

     //categories will need to be loaded from categories.txt
     cboCategory.Items.Add('Example category');


end;
//TabSheet3 is the backdrop - no fields and no dbs

procedure Tmain_workspace.TabSheet4Show(Sender: TObject);
begin
     //remove tabsheets have no clear button
     txtSearch2.Text := '';
     lstDelete.Caption := '';
     cboFilters.Text := '';
     lbl_removebooks_db.Caption := '';
     lbl_removebooks_db.Caption := current_books_db;
     //populate cbo
       cboFilters.Items.Add('ID');
       cboFilters.Items.Add('Title');
       cboFilters.Items.Add('Author');
       cboFilters.Items.Add('Date Published');
       cboFilters.Items.Add('Category');
       cboFilters.Items.Add('Status');
end;

procedure Tmain_workspace.TabSheet6Show(Sender: TObject);
begin
     //clear all fields by calling button click
     btnClear_AddReadersClick(TObject(Self));

     lbl_addreaders_db.Caption := current_readers_db;

end;

procedure Tmain_workspace.TabSheet5Show(Sender: TObject);
begin
     //clear all fields by calling button click
     btnClear_SearchBooksClick(TObject(Self));

     lbl_searchbooks_db.Caption := current_books_db;
end;

procedure Tmain_workspace.TabSheet7Show(Sender: TObject);
begin
     //clear all fields by calling button click
     btnClear_EditReadersClick(TObject(Self));

     lbl_editreaders_db.Caption := current_readers_db;

end;

procedure Tmain_workspace.TabSheet8Show(Sender: TObject);
begin
     //no clear button
     txtSearch_DeleteReaders.Text := '';
     cboFilters5.Text := '';
     lstDeleteReaders.Caption := '';

     lbl_deletereaders_db.Caption := current_readers_db;

end;

procedure Tmain_workspace.TabSheet9Show(Sender: TObject);
begin
     //clear all fields by calling button click
     btnClear_SearchReadersClick(TObject(Self));
     lbl_searchreaders_db.Caption := current_readers_db;

     lbl_searchreaders_db.Caption := current_readers_db;
end;

procedure Tmain_workspace.TabSheet10Show(Sender: TObject);
begin
     //clear all fields by calling button click
     btnClear_AddLoansClick(TObject(Self));
     lbl_addloans_db.Caption := current_loans_db;
end;

procedure Tmain_workspace.TabSheet11Show(Sender: TObject);
begin
     //clear all fields by calling button click
     btnClear_EditLoansClick(TObject(Self));
     lbl_editloans_db.Caption := current_loans_db;
end;

procedure Tmain_workspace.TabSheet12Show(Sender: TObject);
begin
     //no clear button
     txtSearch_RemoveLoans.Text := '';
     lstSelect_RemoveLoans.Caption := '';
     lbl_removeloans_db.Caption := current_loans_db;
end;

procedure Tmain_workspace.TabSheet13Show(Sender: TObject);
begin
     //clear all fields by calling button click
     btnClear_SearchLoansClick(TObject(Self));
     lbl_searchloans_db.Caption := current_loans_db;
end;

procedure Tmain_workspace.TabSheet14Show(Sender: TObject);
begin
    //clear all fields by calling button click
     btnClear_ExpiredLoansClick(TObject(Self));
     lbl_expiredloans_db.Caption := current_loans_db;
end;

//on TabSheet15 shown
procedure Tmain_workspace.TabSheet15Show(Sender: TObject);
begin
     //hide passwords
    chkHideAddPswd1.Checked := True;
    chkHideAddPswd2.Checked := True;
    txtPassword1_AddUsers.PasswordChar := '*';
    txtPassword2_AddUsers.PasswordChar := '*';

    //clear all fields by calling button click
    btnClear_AddUsersClick(TObject(Self));

    //populate cboBoxes
    cboRole_AddUsers.Clear;
    cboRole_AddUsers.Items.Add('Superadmin');
    cboRole_AddUsers.Items.Add('Admin');
    cboRole_AddUsers.Items.Add('User');
    cboRole_AddUsers.ItemIndex := 2; //user as default
end;

//on TabSheet16 shown
procedure Tmain_workspace.TabSheet16Show(Sender: TObject);
begin
     //hide passwords
    chkHideEditPswd1.Checked := True;
    chkHideEditPswd2.Checked := True;

    //clear all fields by calling button click
    btnClear_EditUsersClick(TObject(Self));
end;

procedure Tmain_workspace.TabSheet17Show(Sender: TObject);
begin
  //no clear button
  txtSearch_RemoveUsers.Text := '';
  lstSelect_RemoveUsers.Caption := '';
  cboSearch_RemoveUsers.Text := '';
end;

procedure Tmain_workspace.TabSheet18Show(Sender: TObject);
begin
  //no clear button
  lstSelect_UserPermissions.Caption := '';
  cboSearch_UserPermissions.Text := '';
  txtSearch_UserPermissions.Text := '';
  cboPermission_UserPermissions.Text := '';
end;

procedure Tmain_workspace.TabSheet19Show(Sender: TObject);
begin
  //set private key to hidden
  chkHidePrivateKey_AddDatabases.State := cbChecked ;
  //no clear button
  txtDBName_Add.Text := '';
  cboDBType.Text := '';
  cboEncryptionType_Add.Text := '';
  txtPrivateKey_Add.Text := '';

  //ADDING ITEMS TO COMBO BOX
    cboDBType.Clear;
    cboDBType.Items.Add('Books');
    cboDBType.Items.Add('Readers');
    cboDBType.Items.Add('Loans');

    //adding encryption types to combo box
end;

procedure Tmain_workspace.TabSheet20Show(Sender: TObject);
begin
  //set to hidden
  chkHideOldKey_EditDatabases.State := cbChecked;
  chkHideNewKey_EditDatabases.State := cbChecked;
  //no clear button
  txtSearch_EditDatabases.Text := '';
  cboSearch_EditDatabases.Text := '';
  lstSelect_EditDatabases.Caption := '';
  txtName_EditDatabases.Text := '';
  cboOldEncryption_EditDatabases.Text := '';
  cboNewEncryption_EditDatabases.Text := '';
end;

procedure Tmain_workspace.TabSheet21Show(Sender: TObject);
begin
  //no clear button
  txtSearch_DeleteDatabases.Text := '';
  cboSearch_DeleteDatabases.Text := '';
  lstSelect_DeleteDatabases.Caption := '';
end;

procedure Tmain_workspace.TabSheet22Show(Sender: TObject);
var
   AppDir, DBDir: string;
begin
  //get database directory
  AppDir := ExtractFilePath(Application.ExeName);
  DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
  txtDBdir_HDD.Text := DBDir; //set txt to DBDir

  //calculate available space in gb and mb

  //no clear button
  txtBackupDir_HDD.Text := '';
  chkTimestamped_HDD.State := cbUnchecked;
  chkBackupLog_HDD.State := cbUnchecked;
  chkCompressBackup_HDD.State := cbUnchecked;

end;

procedure Tmain_workspace.TabSheet23Show(Sender: TObject);
var
   AppDir, DBDir: string;
begin
  //get database directory
  AppDir := ExtractFilePath(Application.ExeName);
  DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
  txtDBdir_p2p.Text := DBDir; //set txt to DBDir

  //no clear button
  cboMode_p2p.Text := '';
  txtPort_p2p.Text := '';
  lstPeers_p2p.Caption := '';
  chkWhitelist_p2p.State := cbUnchecked;
  PeerConsole.Lines.Clear;
  txtBackupDir_p2p.Text := '';
end;

procedure Tmain_workspace.TabSheet24Show(Sender: TObject);
var
   AppDir, DBDir: string;
begin
  //get database directory
  AppDir := ExtractFilePath(Application.ExeName);
  DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
  txtDBdir_Server.Text := DBDir; //set txt to DBDir

  //no clear button
  cboMode_Server.Text := '';
  txtAddress_Server.Text := '';
  txtPort_Server.Text := '';
  ServerConsole.Lines.Clear;

end;

procedure Tmain_workspace.TabSheet25Show(Sender: TObject);
begin
   //clear changelog, uncheck "remove old version"
   chkRemoveOld_Update.State := cbUnchecked;
   AppChangelog.Lines.Clear;
end;

procedure Tmain_workspace.TabSheet26Show(Sender: TObject);
begin
  //no clear button
  cboView_Statistics.Text := '';
  txtUserID_Statistics.Text := '';
  cboTimespan_Statistics.Text := '';
  StatsConsole.Lines.Clear;

end;

procedure Tmain_workspace.TabSheet27Show(Sender: TObject);
begin
  //loading info from settings into interface
end;

procedure Tmain_workspace.TabSheet28Show(Sender: TObject);
begin
  //loading info from settings into interface
end;

procedure Tmain_workspace.TabSheet29Show(Sender: TObject);
begin
  lbl_bookdb.Caption := current_books_db;
  lbl_readerdb.Caption := current_readers_db;
  lbl_loandb.Caption := current_loans_db;
end;

//on form creation
procedure Tmain_workspace.FormCreate(Sender: TObject);
begin
    AppDir := ExtractFilePath(Application.ExeName); //gets app dir
    workspace_control.ShowTabs := False;
    backdrop_image.Picture.Bitmap := nil;
    backdrop_image.Picture.Graphic := nil;
    backdrop_image.Visible := False;
    backdrop_image.Picture.Clear;
    If FileExists(AppDir + 'assets' + DirectorySeparator + 'BookwormPascalLogo1.png') then
    begin
      backdrop_image.Picture.LoadFromFile(AppDir + 'assets' + DirectorySeparator + 'BookwormPascalLogo1.png'); //loads image
      backdrop_image.Visible := True; //visible image
    end;
    //does not call the goto_db_selection function to avoid popup
    workspace_control.ShowTabs := False;
    workspace_control.PageIndex := 28;
    workspace_control.Refresh;
end;

procedure Tmain_workspace.backdrop_imageClick(Sender: TObject);
begin

end;

procedure Tmain_workspace.leave_exitClick(Sender: TObject);
begin
  if MessageDlg('Exit Bookworm?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
    ShowMessage('Bye from Bookworm!');
    Application.Terminate;
    end
  else
    begin
        ShowMessage('Returning to application...');
    end;
end;

procedure Tmain_workspace.leave_logoutClick(Sender: TObject);
begin
  clear_global_vars; //calls clearing global variables
  goto_db_selection; //goes to db selection in order to avoid hanging forms (and lower roles getting access to some forms)
  Self.Hide;
  ShowForm('mainmenu');
end;

procedure Tmain_workspace.update_mainClick(Sender: TObject);
begin
  If not authenticate(3) then Exit;
  workspace_control.ShowTabs := False;
  workspace_control.PageIndex := 24;
  workspace_control.Refresh;
end;

procedure Tmain_workspace.users_addClick(Sender: TObject);
begin
      If not authenticate(3) then
      begin
      ShowMessage('Not authenticated!'); //debug
      end;

      workspace_control.ShowTabs := False;
      workspace_control.PageIndex := 14;
      workspace_control.Refresh;
      TabSheet15Show(Self);

end;

procedure Tmain_workspace.users_editClick(Sender: TObject);
begin
      If not authenticate(3) then Exit;
      workspace_control.ShowTabs := False;
      workspace_control.PageIndex := 15;
      workspace_control.Refresh;
end;

procedure Tmain_workspace.users_passwordsClick(Sender: TObject);
begin

end;

procedure Tmain_workspace.users_permissionsClick(Sender: TObject);
begin
      If not authenticate(3) then Exit;
      workspace_control.ShowTabs := False;
      workspace_control.PageIndex := 17;
      workspace_control.Refresh;
end;

procedure Tmain_workspace.btnRefresh_RemoveClick(Sender: TObject);
begin
  PopulateBookListInternal_Remove;
end;

procedure Tmain_workspace.users_removeClick(Sender: TObject);
begin
      If not authenticate(3) then Exit;
      workspace_control.ShowTabs := False;
      workspace_control.PageIndex := 16;
      workspace_control.Refresh;
end;

procedure Tmain_workspace.currentdatabases_mainClick(Sender: TObject);
begin
     goto_db_selection();
end;

end.

