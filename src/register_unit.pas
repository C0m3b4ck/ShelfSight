unit register_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  login_unit, FormManager, sqldb, sqlite3conn, db, global_vars;

type

  { Tregister_form }

  Tregister_form = class(TForm)
    btnRegister: TButton;
    btnBack: TButton;
    btnClear: TButton;
    cboRole: TComboBox;
    chkHide1: TCheckBox;
    chkHide2: TCheckBox;
    Label5: TLabel;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    txtUsername: TEdit;
    txtPassword1: TEdit;
    txtPassword2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure btnBackClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure chkHide1Change(Sender: TObject);
    procedure chkHide2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure RadioButtonAdminChange(Sender: TObject);
    procedure RadioButtonSuperadminChange(Sender: TObject);
    procedure RadioButtonUserChange(Sender: TObject);
    procedure txtPassword1Change(Sender: TObject);
    procedure txtUsernameChange(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  register_form: Tregister_form;
  canRegister: Integer;

implementation

{$R *.lfm}

{ Tregister_form }

procedure Tregister_form.btnBackClick(Sender: TObject);
begin
  txtUsername.Clear;  //clear text when leaving
  txtPassword1.Clear;
  txtPassword2.Clear;
  Self.Hide;
  ShowForm('mainmenu');
end;

procedure Tregister_form.btnRegisterClick(Sender: TObject);
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
  if ((Trim(txtUsername.Text) = '')) or ((Trim(txtPassword1.Text) = '')) or ((Trim(txtPassword2.Text) = '')) then
     begin
          ShowMessage('Username and password cannot be empty!');
          Exit;
     end;
  //check if username and password are the same
  if (txtPassword1.Text = txtUsername.Text) or (txtPassword2.Text = txtUsername.Text) then
     begin
       ShowMessage('Username and password cannot be the same!');
       Exit;
     end
  else
  //check if passwords match
  if (txtPassword1.Text <> txtPassword2.Text) then
     begin
       ShowMessage('Passwords do not match!');
       Exit;
     end;

  //check if role selected
  if (not cboRole.ItemIndex >= 0 ) then //when ItemIndex <0 that means no user role selection
      begin
           ShowMessage('Select a user role!');
           Exit;
      end;

  //check if all of the above are correct
	  role := cboRole.Text;
	  password := txtPassword1.Text;
	  username := txtUsername.Text;
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
		AppDir := ExtractFilePath(Application.ExeName);
                DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
                ForceDirectories(DBDir); //create db folder if not exist
                DBPath := IncludeTrailingPathDelimiter(DBDir) + 'users.db'; //full path with filename
		SQLite3Connection1.DatabaseName := DBPath; //sets connection to this path
                //SQLQuery1.Prepare;
                if not SQLite3Connection1.Connected then
                begin
                   SQLite3Connection1.Open;
                end;
                SQLQuery1.Database := SQLite3Connection1; //connect db to sql query
                SQLTransaction1.Database := SQLite3Connection1;
                SQLQuery1.Transaction := SQLTransaction1;
		SQLTransaction1.StartTransaction;  // Start explicit transaction
		
		// Create table if needed
		SQLite3Connection1.ExecuteDirect(
		  'CREATE TABLE IF NOT EXISTS users (' +
		  'id INTEGER PRIMARY KEY AUTOINCREMENT, ' +
		  'username TEXT NOT NULL UNIQUE, ' +
		  'password TEXT NOT NULL, ' +
		  'role INTEGER NOT NULL)');
		
		// Insert user
		SQLQuery1.SQL.Text := 
		  'INSERT INTO users (username, password, role) ' +
		  'VALUES (:username, :password, :role)';
		SQLQuery1.ParamByName('username').AsString := username_hash;
		SQLQuery1.ParamByName('password').AsString := password_hash;
		SQLQuery1.ParamByName('role').AsString := IntToStr(role_int);
		SQLQuery1.ExecSQL;
		
		SQLTransaction1.Commit;
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
                    SQLTransaction1.Rollback;
                    Exit; //exit on error
                end;
                on E: Exception do
		begin
		  SQLTransaction1.Rollback;
		  ShowMessage('Registration failed: ' + E.Message);
		  Exit;  //exit on error
		end;

	  end;
	  
	  // Clear only on success
	  txtUsername.Clear;
	  txtPassword1.Clear;
	  txtPassword2.Clear;
	  
	  login_form.Show;
	  Self.Hide;

          username := '';
          password := '';
          role := '';
          role_int := 0;
	  
          finally
	  SQLQuery1.Close;
	  SQLTransaction1.Active := False;
	  SQLite3Connection1.Close;
          end;
end;

procedure Tregister_form.chkHide1Change(Sender: TObject);
begin
  if chkHide1.Checked then
     txtPassword1.PasswordChar := '*'
  else
      txtPassword1.PasswordChar := #0;
end;

procedure Tregister_form.chkHide2Change(Sender: TObject);
begin
  if chkHide2.Checked then
     txtPassword2.PasswordChar := '*'
  else
      txtPassword2.PasswordChar := #0;
end;

procedure Tregister_form.btnClearClick(Sender: TObject);
begin
  txtUsername.Clear;
  txtPassword1.Clear;
  txtPassword2.Clear;
end;

//UPON CREATING FORM
procedure Tregister_form.FormCreate(Sender: TObject);
begin
  txtUsername.Clear;
  txtPassword1.Clear;
  txtPassword2.Clear;

  //ADDING ITEMS TO COMBO BOX
  cboRole.Items.Add('User');
  cboRole.Items.Add('Admin');
  cboRole.Items.Add('Superadmin');

  //hide passwords by default
  chkHide1.Checked := True;
  chkHide2.Checked := True;
end;

procedure Tregister_form.RadioButtonAdminChange(Sender: TObject);
begin

end;

procedure Tregister_form.RadioButtonSuperadminChange(Sender: TObject);
begin

end;

procedure Tregister_form.RadioButtonUserChange(Sender: TObject);
begin

end;

procedure Tregister_form.txtPassword1Change(Sender: TObject);
begin

end;

procedure Tregister_form.txtUsernameChange(Sender: TObject);
begin

end;

end.

