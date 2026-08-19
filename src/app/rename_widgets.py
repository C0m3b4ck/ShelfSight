#!/usr/bin/env python3
"""
Script to systematically rename all widget names in mainwindow.ui
to follow consistent naming pattern: <type><Action>_<entity>_<page>
"""

import re
import sys

def rename_widgets(content):
    """Apply systematic renaming rules"""
    
    # Define page mappings (UI page name -> standardized page suffix)
    page_map = {
        'page': 'register',           # page (index 0) - Register
        'page_2': 'login',            # page_2 (index 1) - Login
        'page_7': 'backdrop',         # page_7 (index 2) - Backdrop
        'page_3': 'book_add',         # page_3 (index 3) - Add Books
        'page_9': 'book_edit',        # page_9 (index 4) - Edit Books
        'page_5': 'category',         # page_5 (index 5) - Manage Categories
        'page_6': 'book_undo',        # page_6 (index 6) - Undo Removed Books
        'page_4': 'book_remove',      # page_4 (index 7) - Remove Books
        'page_8': 'location',         # page_8 (index 8) - Manage Locations
        'page_10': 'reader_add',      # page_10 (index 9) - Add Readers
        'page_11': 'reader_edit',     # page_11 (index 10) - Edit Readers
        'page_12': 'book_undo',       # page_12 (index 11) - Undo Removed Books (duplicate?)
        'page_13': 'reader_undo',     # page_13 (index 12) - Undo Removed Readers
        'page_14': 'loan_add',        # page_14 (index 13) - Add Loans
        'page_15': 'loan_edit',       # page_15 (index 14) - Edit Loans
        'page_16': 'loan_status',     # page_16 (index 15) - Loan Statuses
    }
    
    # Widget name mapping rules
    # Pattern: old_name -> new_name
    # We'll do this by finding all name="..." attributes and applying transformations
    
    # First, let's extract all widget names and build a mapping
    widget_names = re.findall(r'name="([^"]*)"', content)
    unique_names = sorted(set(widget_names))
    
    print(f"Found {len(unique_names)} unique widget names")
    
    # Build renaming mapping
    rename_map = {}
    
    for name in unique_names:
        new_name = name
        
        # Skip non-widget names (actions, menus, etc.)
        if name.startswith(('action', 'menu', 'MainWindow', 'centralwidget', 'workspaces', 'menubar', 'statusbar', 'page')):
            continue
            
        # Skip labels (they don't need consistent naming)
        if name.startswith('label'):
            continue
            
        # Apply transformations based on widget type prefix
        # Format: <type><Name>_<entity>_<page>
        
        # Buttons
        if name.startswith('btn'):
            # Clear buttons
            if 'Clear_' in name:
                # btnClear_title_book -> btnClear_title_book_add
                # btnClear_title_book_edit -> btnClear_title_book_edit
                # btnClear_title_book_remove -> btnClear_title_book_remove
                # btnClear_name_category -> btnClear_name_category (single page)
                # btnClear_name_location -> btnClear_name_location (single page)
                # btnClear_name_reader -> btnClear_name_reader_add
                # btnClear_name_reader_edit -> btnClear_name_reader_edit
                # btnClear_name_reader_remove -> btnClear_name_reader_remove
                pass  # Already mostly good
            
            # Search buttons
            elif name.startswith('btnSearch_'):
                # btnSearch_book -> btnSearch_book_add
                # btnSearch_book_edit -> btnSearch_book_edit
                # btnSearch_book_remove -> btnSearch_book_remove
                # btnSearch_category -> btnSearch_category (single page)
                # btnSearch_location -> btnSearch_location (single page)
                # btnSearch_reader -> btnSearch_reader_add
                # btnSearch_reader_edit -> btnSearch_reader_edit
                # btnSearch_reader_remove -> btnSearch_reader_remove
                # btnSearch_loan_edit -> btnSearch_loan_edit
                # btnSearch_loanstatus -> btnSearch_loan_status
                # btnSearch_undobooks -> btnSearch_book_undo
                # btnSearch_undoreaders -> btnSearch_reader_undo
                pass
            
            # Add buttons
            elif name.startswith('btnAdd_'):
                # btnAdd_book -> btnAdd_book_add
                # btnAdd_reader -> btnAdd_reader_add
                # btnAdd_category -> btnAdd_category
                # btnAdd_location -> btnAdd_location
                # btnAdd_loan -> btnAdd_loan_add
                pass
            
            # Edit buttons
            elif name.startswith('btnEdit_'):
                # btnEdit_book -> btnEdit_book_edit
                # btnEdit_reader -> btnEdit_reader_edit
                # btnEdit_category -> btnEdit_category
                # btnEdit_location -> btnEdit_location
                pass
            
            # Remove buttons
            elif name.startswith('btnRemove_'):
                # btnRemove_book -> btnRemove_book_remove
                # btnRemove_reader -> btnRemove_reader_remove
                # btnRemove_category -> btnRemove_category
                # btnRemove_location -> btnRemove_location
                pass
            
            # Undo buttons
            elif name.startswith('btnUndo'):
                pass  # Complex, handle individually
            
            # Redo buttons
            elif name.startswith('btnRedo'):
                pass
            
            # Other buttons
            elif name in ['btnRegister', 'btnLogin']:
                pass  # These are on register/login pages
                
        # Text inputs
        elif name.startswith('txt'):
            pass  # Mostly good
            
        # Combo boxes
        elif name.startswith('cbo'):
            pass
            
        # List widgets
        elif name.startswith('lstSearch_'):
            pass  # Mostly good
            
        # Checkboxes
        elif name.startswith('chk'):
            pass
            
        # Spin boxes
        elif name.startswith('spn'):
            pass
            
        # Calendar
        elif name == 'calendarWidget':
            pass
            
        if new_name != name:
            rename_map[name] = new_name
    
    # Manual comprehensive mapping for all widgets
    manual_map = {
        # Register page (page)
        'txtUsr_register': 'txtUsername_register',
        'txtPwd1_register': 'txtPassword_register',
        'txtPwd2_register': 'txtPasswordConfirm_register',
        'txtPassword2_register': 'txtPasswordConfirm_register',
        'btnClear_username_register': 'btnClear_username_register',
        'btnClear_password1_register': 'btnClear_password_register',
        'btnClear_password2_register': 'btnClear_passwordConfirm_register',
        'cboRole_register': 'cboRole_register',
        'btnHelp_pwdStrenght_register': 'btnHelp_passwordStrength_register',
        'btnHelp_role_register': 'btnHelp_role_register',
        'barPasswordStrenght_register': 'barPasswordStrength_register',
        'btnGenerateStrongPassword_register': 'btnGeneratePassword_register',
        'btnRegister': 'btnRegister_register',
        'chkHide_login_register': 'chkHidePassword_register',
        'chkHide_login_2': 'chkHidePassword_register',  # duplicate?
        
        # Login page (page_2)
        'txtUsr_register_3': 'txtUsername_login',
        'txtPwd1_register_3': 'txtPassword_login',
        'txtPassword_login': 'txtPassword_login',  # already exists?
        'btnClear_username_login': 'btnClear_username_login',
        'btnClear_password_login': 'btnClear_password_login',
        'cboRole_login': 'cboRole_login',
        'btnHelp_role_login': 'btnHelp_role_login',
        'btnLogin': 'btnLogin_login',
        'chkHide_login': 'chkHidePassword_login',
        
        # Add Books page (page_3)
        'txtTitle_addbooks': 'txtTitle_book_add',
        'txtAuthor_addbooks': 'txtAuthor_book_add',
        'txtID_addbooks': 'txtId_book_add',
        'btnClear_title_addbooks': 'btnClear_title_book_add',
        'btnClear_author_addbooks': 'btnClear_author_book_add',
        'btnClear_id_addbooks': 'btnClear_id_book_add',
        'cboLocation_addbooks': 'cboLocation_book_add',
        'cboCategory_addbooks': 'cboCategory_book_add',
        'cboStatus_addbooks': 'cboStatus_book_add',
        'btnAddBook_addbooks': 'btnAdd_book_add',
        'btnUndoAdd_addbooks': 'btnUndoAdd_book_add',
        
        # Edit Books page (page_9)
        'txtTitle_editbooks': 'txtTitle_book_edit',
        'txtAuthor_editbooks': 'txtAuthor_book_edit',
        'txtID_editbooks': 'txtId_book_edit',
        'txtSearch_editbooks': 'txtSearch_book_edit',
        'btnSearch_editbooks': 'btnSearch_book_edit',
        'btnClear_title_editbooks': 'btnClear_title_book_edit',
        'btnClear_author_editbooks': 'btnClear_author_book_edit',
        'btnClear_id_editbooks': 'btnClear_id_book_edit',
        'cboLocation_editbooks': 'cboLocation_book_edit',
        'cboCategory_editbooks': 'cboCategory_book_edit',
        'cboStatus_editbooks': 'cboStatus_book_edit',
        'btnEditBook_editbooks': 'btnEdit_book_edit',
        'btnUndoEdit_editbooks': 'btnUndoEdit_book_edit',
        'btnUndoAdd_editbooks': 'btnUndoAdd_book_edit',  # if exists
        'lstSearch_editbooks': 'lstSearch_book_edit',
        
        # Manage Categories page (page_5)
        'txtSearch_managecategories': 'txtSearch_category',
        'btnSearch_managecategories': 'btnSearch_category',
        'lstSearch_managecategories': 'lstSearch_category',
        'txtName_managecategories': 'txtName_category',
        'btnClear_name_managecategories': 'btnClear_name_category',
        'btnAddCategory_managecategories': 'btnAdd_category',
        'btnEditCategory_managecategories': 'btnEdit_category',
        'btnRemoveCategory_managecategories': 'btnRemove_category',
        'btnUndoRemove_managecategories': 'btnUndoRemove_category',
        'btnUndoEdit_managecategories': 'btnUndoEdit_category',
        'btnUndoAdd_managecategories': 'btnUndoAdd_category',
        
        # Undo Removed Books page (page_6)
        'txtValue_undoremovebooks': 'txtValue_book_undo',
        'txtSearch_undoremovebooks': 'txtSearch_book_undo',
        'btnSearch_undoremovebooks': 'btnSearch_book_undo',
        'btnUndoAll_undoremovebooks': 'btnUndoAll_book_undo',
        'btnUndoSelected_undoremovebooks': 'btnUndoSelected_book_undo',
        'btnRedoRemove_undoremovebooks': 'btnRedoRemove_book_undo',
        'btnRedoAllSelected_undoremovebooks': 'btnRedoAllSelected_book_undo',
        'lstSearch_undoremovebooks': 'lstSearch_book_undo',
        'cboValue_undoremovebooks': 'cboValue_book_undo',
        
        # Remove Books page (page_4)
        'txtSearch_removebooks': 'txtSearch_book_remove',
        'btnSearch_removebooks': 'btnSearch_book_remove',
        'btnClear_title_removebooks': 'btnClear_title_book_remove',
        'btnClear_author_removebooks': 'btnClear_author_book_remove',
        'btnClear_id_removebooks': 'btnClear_id_book_remove',
        'txtTitle_removebooks': 'txtTitle_book_remove',
        'txtAuthor_removebooks': 'txtAuthor_book_remove',
        'txtID_removebooks': 'txtId_book_remove',
        'cboCategory_removebooks': 'cboCategory_book_remove',
        'cboLocation_removebooks': 'cboLocation_book_remove',
        'cboStatus_removebooks': 'cboStatus_book_remove',
        'btnRemove_removebooks': 'btnRemove_book_remove',
        'btnUndoRemoval_removebooks': 'btnUndoRemoval_book_remove',
        'btnUndoLast_removebooks': 'btnUndoLast_book_remove',
        'lstSearch_removebooks': 'lstSearch_book_remove',
        
        # Manage Locations page (page_8)
        'txtSearch_managelocations': 'txtSearch_location',
        'btnSearch_managelocations': 'btnSearch_location',
        'lstSearch_managelocations': 'lstSearch_location',
        'txtName_managelocations': 'txtName_location',
        'btnClear_name_managelocations': 'btnClear_name_location',
        'btnAddLocation_managelocations': 'btnAdd_location',
        'btnEditLocation_managelocations': 'btnEdit_location',
        'btnRemoveLocation_managelocations': 'btnRemove_location',
        'btnUndoRemove_managelocations': 'btnUndoRemove_location',
        'btnUndoEdit_managelocations': 'btnUndoEdit_location',
        'btnUndoAdd_managelocations': 'btnUndoAdd_location',
        
        # Add Readers page (page_10)
        'txtName_addreaders': 'txtName_reader_add',
        'txtSurname_addreaders': 'txtSurname_reader_add',
        'txtGrade_addreaders': 'txtGrade_reader_add',
        'txtClass_addreaders': 'txtClass_reader_add',
        'txtID_addreaders': 'txtId_reader_add',
        'btnClear_name_addreaders': 'btnClear_name_reader_add',
        'btnClear_surname_addreaders': 'btnClear_surname_reader_add',
        'btnClear_grade_addreaders': 'btnClear_grade_reader_add',
        'btnClear_class_addreaders': 'btnClear_class_reader_add',
        'btnClear_id_addreaders': 'btnClear_id_reader_add',
        'btnAddBook_addreaders': 'btnAdd_reader_add',
        'btnUndoAdd_addreaders': 'btnUndoAdd_reader_add',
        'chkAutogenerateID_addreaders': 'chkAutogenerateId_reader_add',
        'cboIDtypes_addreaders': 'cboIdType_reader_add',
        'txtIDlength_addreaders': 'txtIdLength_reader_add',
        'chkUniqueID_addreaders': 'chkUniqueId_reader_add',
        
        # Edit Readers page (page_11)
        'txtSearch_editreaders': 'txtSearch_reader_edit',
        'btnSearch_editreaders': 'btnSearch_reader_edit',
        'lstSearch_editreaders': 'lstSearch_reader_edit',
        'txtName_editreaders': 'txtName_reader_edit',
        'txtSurname_editreaders': 'txtSurname_reader_edit',
        'txtGrade_editreaders': 'txtGrade_reader_edit',
        'txtClass_editreaders': 'txtClass_reader_edit',
        'txtID_editreaders': 'txtId_reader_edit',
        'btnClear_name_editreaders': 'btnClear_name_reader_edit',
        'btnClear_surname_editreaders': 'btnClear_surname_reader_edit',
        'btnClear_grade_editreaders': 'btnClear_grade_reader_edit',
        'btnClear_class_editreaders': 'btnClear_class_reader_edit',
        'btnClear_id_editreaders': 'btnClear_id_reader_edit',
        'btnEditBook_editreaders': 'btnEdit_reader_edit',
        'btnUndoEdit_editreaders': 'btnUndoEdit_reader_edit',
        
        # Remove Readers page (page_12)
        'txtSearch_removereaders': 'txtSearch_reader_remove',
        'btnSearch_removereaders': 'btnSearch_reader_remove',
        'lstSearch_removereaders': 'lstSearch_reader_remove',
        'txtName_removereaders': 'txtName_reader_remove',
        'txtSurname_removereaders': 'txtSurname_reader_remove',
        'txtGrade_removereaders': 'txtGrade_reader_remove',
        'txtClass_removereaders': 'txtClass_reader_remove',
        'txtID_removereaders': 'txtId_reader_remove',
        'btnClear_name_removereaders': 'btnClear_name_reader_remove',
        'btnClear_surname_removereaders': 'btnClear_surname_reader_remove',
        'btnClear_grade_removereaders': 'btnClear_grade_reader_remove',
        'btnClear_class_removereaders': 'btnClear_class_reader_remove',
        'btnClear_id_removereaders': 'btnClear_id_reader_remove',
        'btnRemove_removereaders': 'btnRemove_reader_remove',
        'btnUndoRemoval_removereaders': 'btnUndoRemoval_reader_remove',
        'btnUndoLast_removereaders': 'btnUndoLast_reader_remove',
        'cboFilter_removereaders': 'cboFilter_reader_remove',
        
        # Undo Removed Readers page (page_13)
        'txtValue_undoremovereaders': 'txtValue_reader_undo',
        'txtSearch_undoremovereaders': 'txtSearch_reader_undo',
        'btnSearch_undoremovereaders': 'btnSearch_reader_undo',
        'btnUndoAll_undoremovereaders': 'btnUndoAll_reader_undo',
        'btnUndoSelected_undoremovereaders': 'btnUndoSelected_reader_undo',
        'btnRedoRemove_undoremovereaders': 'btnRedoRemove_reader_undo',
        'btnRedoAllSelected_undoremovereaders': 'btnRedoAllSelected_reader_undo',
        'lstSearch_undoremovereaders': 'lstSearch_reader_undo',
        'cboValue_undoremovereaders': 'cboValue_reader_undo',
        
        # Add Loans page (page_14)
        'txtBookSearch_AddLoans': 'txtSearch_book_loan_add',
        'txtReaderSearch_AddLoans': 'txtSearch_reader_loan_add',
        'txtBookSelected_AddLoans': 'txtSelected_book_loan_add',
        'txtReaderSelected_AddLoans': 'txtSelected_reader_loan_add',
        'btnSearchBook_addloan': 'btnSearch_book_loan_add',
        'btnSearchReader_clicked': 'btnSearch_reader_loan_add',  # check actual name
        'btnAddLoan_addloan': 'btnAdd_loan_add',
        'btnClear_addloan': 'btnClear_loan_add',
        'spnLoanDays_AddLoans': 'spnLoanDays_loan_add',
        'cboSearchField_book': 'cboSearchField_book_loan_add',
        'cboSearchField_reader': 'cboSearchField_reader_loan_add',
        'lstSearch_book': 'lstSearch_book_loan_add',
        'lstSearch_reader': 'lstSearch_reader_loan_add',
        'chkCheckUnreturned_loan': 'chkCheckUnreturned_loan_add',
        
        # Edit Loans page (page_15)
        'txtLoanSearch_EditLoans': 'txtSearch_loan_edit',
        'btnSearchLoan_editloan': 'btnSearch_loan_edit',
        'lstSearch_EditLoans': 'lstSearch_loan_edit',
        'txtLoanSelected_EditLoans': 'txtSelected_loan_edit',
        'txtDueDate_EditLoans': 'txtDueDate_loan_edit',
        'txtReturnDate_EditLoans': 'txtReturnDate_loan_edit',
        'btnUpdateLoan_editloan': 'btnUpdate_loan_edit',
        'btnReturnLoan_editloan': 'btnReturn_loan_edit',
        'btnClear_editloan': 'btnClear_loan_edit',
        'cboLoanSearchField_EditLoans': 'cboSearchField_loan_edit',
        'cboStatus_EditLoans': 'cboStatus_loan_edit',
        
        # Loan Statuses page (page_16)
        'txtSearch_LoanStatuses': 'txtSearch_loan_status',
        'btnSearch_loanstatus': 'btnSearch_loan_status',
        'btnRefresh_loanstatus': 'btnRefresh_loan_status',
        'btnOverdueReport_loanstatus': 'btnOverdueReport_loan_status',
        'btnFilter_loanstatus': 'btnFilter_loan_status',
        'cboStatusFilter_LoanStatuses': 'cboStatusFilter_loan_status',
        'lstSearch_LoanStatuses': 'lstSearch_loan_status',
    }
    
    # Apply manual mappings
    for old, new in manual_map.items():
        if old in content:
            content = content.replace(f'name="{old}"', f'name="{new}"')
            print(f"Renamed: {old} -> {new}")
    
    # Fix zorder references
    for old, new in manual_map.items():
        if f'<zorder>{old}</zorder>' in content:
            content = content.replace(f'<zorder>{old}</zorder>', f'<zorder>{new}</zorder>')
            print(f"Fixed zorder: {old} -> {new}")
    
    return content

if __name__ == '__main__':
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'r') as f:
        content = f.read()
    
    new_content = rename_widgets(content)
    
    with open('/home/sb3x/Code/ShelfSight/src/src/app/mainwindow.ui', 'w') as f:
        f.write(new_content)
    
    print("Done!")