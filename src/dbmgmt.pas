unit dbmgmt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, global_vars, sqldb, db, Forms, Dialogs;

procedure ConnectToDB_books();
procedure ConnectToDB_readers();
procedure ConnectToDB_loans();
procedure ConnectToDB_users();
procedure DebugSQLState_users;
function authenticate(minimumRole: Integer): Boolean;

implementation
uses main_workspace_unit;

function authenticate(minimumRole: Integer): Boolean;
var
  stored_username_hash, stored_password_hash: string;
  user_role: Integer;
  tmp_role: String;
  MainWorkspace: Tmain_workspace;
begin
  Result := False;
  MainWorkspace := main_workspace_unit.main_workspace;

  try
    try
      ConnectToDB_users;

      if not (Assigned(MainWorkspace.SQLQueryUsers) and Assigned(MainWorkspace.SQLQueryUsers.SQL)) then
      begin
        ShowMessage('SQLQueryUsers/SQL not assigned!');
        Exit;
      end;

      // prepare FIRST to parse parameters
      MainWorkspace.SQLQueryUsers.SQL.Clear;
      MainWorkspace.SQLQueryUsers.SQL.Add('SELECT id, username, password, role FROM users WHERE username = :username_hash');
      MainWorkspace.SQLQueryUsers.Prepare;  // parse params BEFORE ParamByName

      MainWorkspace.SQLQueryUsers.ParamByName('username_hash').AsString := current_user_username_hash;
      MainWorkspace.SQLQueryUsers.Open;

      if not MainWorkspace.SQLQueryUsers.IsEmpty then
      begin
        stored_password_hash := MainWorkspace.SQLQueryUsers.FieldByName('password').AsString;
        stored_username_hash := MainWorkspace.SQLQueryUsers.FieldByName('username').AsString;

        if (current_user_password_hash = stored_password_hash) and
           (current_user_username_hash = stored_username_hash) then
        begin
          tmp_role := MainWorkspace.SQLQueryUsers.FieldByName('role').AsString;
          user_role := StrToIntDef(tmp_role, 0);
          Result := (user_role >= minimumRole);
        end;
      end else
        ShowMessage('User not found!');

    except
      on E: EDatabaseError do ShowMessage('DB error: ' + E.Message);
      on E: Exception do ShowMessage('Error: ' + E.ClassName + ' - ' + E.Message +
        ' at line: SQLQueryUsers.SQL.Count=' + IntToStr(MainWorkspace.SQLQueryUsers.SQL.Count));
    end;

  finally
    if Assigned(MainWorkspace.SQLQueryUsers) then
      MainWorkspace.SQLQueryUsers.Close;
  end;
end;


procedure ConnectToDB_books();
var
   AppDir, DBDir, DBPath: string;
   MainForm: Tmain_workspace;
begin
     MainForm := main_workspace_unit.main_workspace;
     if current_books_db = '' then Exit;
     AppDir := ExtractFilePath(Application.ExeName);
     DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
     ForceDirectories(DBDir); //create db folder if not exist
     DBPath := IncludeTrailingPathDelimiter(DBDir) + current_books_db;
     If not FileExists(DBPath) then Exit; //handle non-existing DB

     MainForm.SQLite3ConnectionBooks.Close;
     MainForm.SQLite3ConnectionBooks.DatabaseName := DBPath;

     MainForm.SQLite3ConnectionBooks.Open;
     MainForm.SQLTransactionBooks.Active := true;

end;

procedure ConnectToDB_readers();
var
   AppDir, DBDir, DBPath: string;
   MainForm: Tmain_workspace;
begin
     MainForm := main_workspace_unit.main_workspace;
     if current_readers_db = '' then Exit;
     AppDir := ExtractFilePath(Application.ExeName);
     DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
     ForceDirectories(DBDir); //create db folder if not exist
     DBPath := IncludeTrailingPathDelimiter(DBDir) + current_readers_db;
     If not FileExists(DBPath) then Exit; //handle non-existing DB

     MainForm.SQLite3ConnectionReaders.Close;
     MainForm.SQLite3ConnectionReaders.DatabaseName := DBPath;

     MainForm.SQLite3ConnectionReaders.Open;
     MainForm.SQLTransactionReaders.Active := true;

end;

procedure ConnectToDB_loans();
var
   AppDir, DBDir, DBPath: string;
   MainForm: Tmain_workspace;
begin
     MainForm := main_workspace_unit.main_workspace;
     if current_loans_db = '' then Exit;
     AppDir := ExtractFilePath(Application.ExeName);
     DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
     ForceDirectories(DBDir); //create db folder if not exist
     DBPath := IncludeTrailingPathDelimiter(DBDir) + current_loans_db;
     If not FileExists(DBPath) then Exit; //handle non-existing DB

     MainForm.SQLite3ConnectionLoans.Close;
     MainForm.SQLite3ConnectionLoans.DatabaseName := DBPath;

     MainForm.SQLite3ConnectionLoans.Open;
     MainForm.SQLTransactionLoans.Active := true;

end;

procedure ConnectToDB_users();
var
   AppDir, DBDir, DBPath: string;
   MainForm: Tmain_workspace;
begin
     MainForm := main_workspace_unit.main_workspace;
     AppDir := ExtractFilePath(Application.ExeName);
     DBDir := IncludeTrailingPathDelimiter(AppDir) + 'databases';
     ForceDirectories(DBDir); //create db folder if not exist
     DBPath := IncludeTrailingPathDelimiter(DBDir) + 'users.db';
     If not FileExists(DBPath) then Exit; //handle non-existing DB

     MainForm.SQLite3ConnectionUsers.Close;
     MainForm.SQLite3ConnectionUsers.DatabaseName := DBPath;

     MainForm.SQLite3ConnectionUsers.Open;
     MainForm.SQLTransactionUsers.Active := true;

end;

procedure DebugSQLState_users;
var
  MainForm: Tmain_workspace;
begin
  //MainForm := main_workspace_unit.Form1;

  ShowMessage('=== SQL DEBUG START ===');
  ShowMessage('1. Form1 Assigned: ' + BoolToStr(Assigned(MainForm), True));
  ShowMessage('2. Conn Assigned: ' + BoolToStr(Assigned(MainForm.SQLite3ConnectionUsers), True));
  ShowMessage('3. Conn Connected: ' + BoolToStr(MainForm.SQLite3ConnectionUsers.Connected, True));
  ShowMessage('4. DBPath: ' + MainForm.SQLite3ConnectionUsers.DatabaseName);
  ShowMessage('5. Trans Assigned: ' + BoolToStr(Assigned(MainForm.SQLTransactionUsers), True));
  ShowMessage('6. Trans Active: ' + BoolToStr(MainForm.SQLTransactionUsers.Active, True));
  ShowMessage('7. Query Assigned: ' + BoolToStr(Assigned(MainForm.SQLQueryUsers), True));
  ShowMessage('8. Query Active: ' + BoolToStr(MainForm.SQLQueryUsers.Active, True));
  ShowMessage('9. Query Capacity: ' + IntToStr(MainForm.SQLQueryUsers.SQL.Capacity));
  ShowMessage('=== SQL DEBUG END ===');
end;


end.

