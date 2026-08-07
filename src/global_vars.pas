unit global_vars;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, DCPsha256, DCPsha512;

function SHA256String(target_string: string): string;
function SHA512String(target_string: string): string;
procedure clear_global_vars();
function check_other_dbs(): Boolean;

var
  current_user_password_hash, current_user_username_hash, current_loans_db, current_readers_db,
  current_books_db : string;
  current_user_ID: integer;

implementation
function check_other_dbs(): Boolean;
var
  AppRunDir, DbDir: string;
  DbFiles: TStringList;
  i: Integer;
begin
  Result := False;
  AppRunDir := ExtractFilePath(ParamStr(0));
  DbDir := IncludeTrailingPathDelimiter(AppRunDir) + 'databases';

  if not DirectoryExists(DbDir) then
    Exit;

  DbFiles := FindAllFiles(DbDir, '*.db', False);  // non-recursive
  try
    for i := 0 to DbFiles.Count - 1 do
    begin
      if CompareText(ExtractFileName(DbFiles[i]), 'users.db') <> 0 then
      begin
        Result := True;   // found SOME .db file that is not users.db
        Exit;             // no need to check further
      end;
    end;
  finally
    DbFiles.Free;
  end;
end;


procedure clear_global_vars();
begin
  //clears all global variables
  current_user_password_hash := '';
  current_user_username_hash := '';
  current_loans_db := '';
  current_readers_db := '';
  current_books_db := '';
  current_user_ID := 0;
end;

function SHA256String(target_string: string): string;
var
  Hash: TDCP_sha256;
  Digest: array[0..31] of byte; //32 bytes
  i: Integer;
  HexStr: string;
begin
  Hash := TDCP_sha256.Create(nil);
  try
    Hash.Init;
    Hash.UpdateStr(target_string); //hashes UTF-8 encoded string
    Hash.Final(Digest);

    HexStr := '';
    for i := 0 to 31 do
        HexStr := HexStr + IntToHex(Digest[i], 2);
    Result := HexStr;
  finally
    Hash.Free;
  end;
end;

function SHA512String(target_string: string): string;
var
  Hash: TDCP_sha512;
  HashBytes: array[0..63] of byte; //64 bytes
  i: Integer;
begin
  Hash := TDCP_sha512.Create(nil);
  try
    Hash.Init;
    Hash.UpdateStr(target_string); //hashes UTF-8 encoded string
    Hash.Final(HashBytes);
    for i := 0 to 63 do
        Result := Result + IntToHex(HashBytes[i], 2);
  finally
    Hash.Free;
  end;
end;

end.

