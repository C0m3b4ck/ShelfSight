unit FormManager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms;
  //register_unit, login_unit, mainmenu_unit, main_workspace_unit;

type
  TFormClass = class of TForm;

procedure RegisterForm(const AName: string; AClass: TFormClass);
procedure ShowForm(const FormName: string);
procedure HideForm(const FormName: string);
procedure FreeForm(const FormName: string);

implementation

var
   FormClasses: TStringList;
   FormInstances: TStringList;

//register form
procedure RegisterForm(const AName: string; AClass: TFormClass);
begin
  if FormClasses.IndexOf(AName) < 0 then FormClasses.Add(AName); //key exists
  FormClasses.Objects[FormClasses.IndexOf(AName)] := TObject(AClass);
end;

//show form
procedure ShowForm(const FormName: string);
var
   Idx: Integer;
   FrmClass: TFormClass;
   Frm: TForm;

begin
     //reuse instance if exists
     Idx := FormInstances.IndexOf(FormName);
     if Idx >= 0 then begin
       TForm(FormInstances.Objects[Idx]).Show;
       Exit;
     end;
     //find class
     Idx := FormClasses.IndexOf(FormName);
     if Idx < 0 then
     begin
        raise Exception.Create('Form "' + FormName + '" not registered! Add to .lpr or form init.');
        Exit;
     end;

     FrmClass := TFormClass(FormClasses.Objects[Idx]);
     Frm := FrmClass.Create(nil);
     FormInstances.AddObject(FormName, Frm);
     Frm.Visible := True;
     Frm.Show;
end;

//hide form
procedure HideForm(const FormName: string);
var
   Idx: Integer;
begin
     Idx := FormInstances.IndexOf(FormName);
     if Idx >= 0 then begin
        with TForm(FormInstances.Objects[Idx]) do begin
          Visible := False;
          Hide;
        end;
     end;
end;

//free form
procedure FreeForm(const FormName: string);
var
   Idx: Integer;
begin
     Idx := FormInstances.IndexOf(FormName);
     if Idx >= 0 then
        TForm(FormInstances.Objects[Idx]).Free;
        FormInstances.Delete(Idx);
     //end;
end;

initialization
FormClasses := TStringList.Create;
FormInstances := TStringList.Create;

finalization
FormInstances.Free;
FormClasses.Free;

end.

