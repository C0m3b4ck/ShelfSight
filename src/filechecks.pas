unit FileChecks;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, base64;

//function defs
procedure CheckIfNote();

implementation
procedure CheckIfNote();
var
  F: TextFile;
  note_text, based: String;
begin
    if not FileExists('NOTE-FROM-AUTHOR.txt') then
    begin
      AssignFile(F, 'NOTE-FROM-AUTHOR.txt');
      Rewrite(F);
      //encoded in base64 to make modifying via debugger harder
      note_text := 'Qm9va3dvcm1QYXNjYWwgYnkgQzBtM2I0Y2suIE9ubHkgb3JpZ2luYWwgd2Vic2l0ZTogaHR0cHM6Ly9naXRodWIuY29tL0MwbTNiNGNrL0Jvb2t3b3JtUGFzY2Fs';
      based := DecodeStringBase64(note_text);
      Writeln(F, based);
      CloseFile(F);
      //ShowMessage('Media not found! Proceeding without sound...');
    end;
end;

end.

