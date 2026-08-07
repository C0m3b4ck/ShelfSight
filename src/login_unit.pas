unit login_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, sqlite3conn, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls, FormManager, db, global_vars, main_workspace_unit;

type

  { Tlogin_form }

  Tlogin_form = class(TForm)
    btnBack: TButton;
    btnLogin: TButton;
    btnClear: TButton;
    chkHidePassword: TCheckBox;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    txtPassword: TEdit;
    txtUsername: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure btnBackClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure chkHidePasswordChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  login_form: Tlogin_form;
  username, password, role: string;
  timeout_counter: integer;

implementation

{$R *.lfm}

{ Tlogin_form }

procedure Tlogin_form.btnBackClick(Sender: TObject);
begin
     txtUsername.Clear;  //clear text when leaving
     txtPassword.Clear;
     ShowForm('mainmenu');
     Self.Hide;
end;

procedure Tlogin_form.btnClearClick(Sender: TObject);
begin
     txtUsername.Clear;
     txtPassword.Clear;
end;

procedure Tlogin_form.btnLoginClick(Sender: TObject);
var
  enteredUser, enteredPass, AppDir, DBDir, DBPath: string;
  tmp_userID: integer;
  tmp_role: string;
  password_hash: string;
  username_hash: string;
  stored_password_hash: string;   // read from DB
  stored_username_hash: string;
begin
  enteredUser := Trim(txtUsername.Text);
  enteredPass := Trim(txtPassword.Text);

  if (enteredUser = '') or (enteredPass = '') then
  begin
    ShowMessage('Enter username and password');
    Exit;
  end;

  try
   try
    AppDir := ExtractFilePath(Application.ExeName);
    DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
    DBPath := IncludeTrailingPathDelimiter(DBDir) + 'users.db';

    // Check if DB exists
    if not FileExists(DBPath) then
    begin
      ShowMessage('No accounts registered! Please register account!');
      ShowForm('register');
      Self.Hide;
      Exit;
    end;

    // Open connection
    SQLite3Connection1.DatabaseName := DBPath;
    //SQLQuery1.Prepare;
    SQLite3Connection1.Open;

    // START transaction
    SQLTransaction1.Database := SQLite3Connection1;
    SQLTransaction1.StartTransaction;

    // Compute hash of entered password and username
      password_hash := SHA512String(enteredPass);
      username_hash := SHA512String(enteredUser);

    // Assign query and link components
    SQLQuery1.SQL.Text :=
      'SELECT id, username, password, role FROM users ' +
      'WHERE username = :username_hash'; // username hash
    SQLQuery1.ParamByName('username_hash').AsString := username_hash;
    SQLQuery1.Database := SQLite3Connection1;
    SQLQuery1.Transaction := SQLTransaction1;
    SQLQuery1.Open;

    if not SQLQuery1.IsEmpty then
    begin
      // Read stored hashes from DB
      stored_password_hash := SQLQuery1.FieldByName('password').AsString;
      stored_username_hash := SQLQuery1.FieldByName('username').AsString;

      if (password_hash = stored_password_hash) and (username_hash = stored_username_hash) then
      begin
          tmp_userID := SQLQuery1.FieldByName('id').AsInteger;
          tmp_role := SQLQuery1.FieldByName('role').AsString;

          ShowMessage('Welcome ' + enteredUser + ' (' + tmp_role + ')');

          // Save globally
          current_user_username_hash := username_hash;
          current_user_password_hash := password_hash;
          current_user_ID := tmp_userID;

          ShowForm('mainworkspace');
          main_workspace.goto_db_selection(); //switches to DB selection
          main_workspace.workspace_control.Refresh; //refresh
          Self.Hide;
      end
      else
      begin
        ShowMessage('Invalid username or password');
      end;
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

  //clearing text fields upon success
  username_hash := '';
  password_hash := '';
  txtPassword.Text := '';
  txtUsername.Text := '';

  finally
  // Cleanup
  SQLQuery1.Close;
  SQLTransaction1.Active := False;
  SQLite3Connection1.Close;
  end;

end;

procedure Tlogin_form.chkHidePasswordChange(Sender: TObject);
begin
     if (chkHidePassword.State = cbChecked) then
        txtPassword.PasswordChar := '*'
     else
         txtPassword.PasswordChar := #0;
end;

//UPON CREATING FORM
procedure Tlogin_form.FormCreate(Sender: TObject);
begin
     //clear text fields
     txtUsername.Clear;
     txtPassword.Clear;
     //set password to hidden
     if (chkHidePassword.State = cbUnchecked) then
         txtPassword.PasswordChar := #0
     else
         txtPassword.PasswordChar := '*';

     //refresh to actually hide
     //chkHidePasswordChange(TObject(Self));
     //chkHidePasswordChange(TObject(Self));
     chkHidePassword.Invalidate;
     chkHidePassword.Update;
     chkHidePassword.Repaint;
     txtPassword.PasswordChar := '*';
     txtPassword.Refresh;

     chkHidePasswordChange(Self);
end;

end.
