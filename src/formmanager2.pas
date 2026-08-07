unit FormManager2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms,
  register_unit, login_unit, mainmenu_unit, main_workspace_unit;

//form declarations here
type
  Tlogin_form = class(TForm)
  end;

  Tregister_form = class(TForm)
  end;

  Tmain_form = class(TForm)
  end;

  Tmain_workspace = class(TForm)
  end;

//global show/hide
procedure ShowForm(AFormClass: TClass);
procedure HideForm(AFormClass: TClass);

implementation

//helper - active instance by form
function FindFormByClass(AFormClass: TClass): TCustomForm;
var
   i: Integer;
begin
  Result := nil;
  for i := 0 to Screen.FormCount -1 do
      if Screen.Forms[i].ClassType = AFormClass then
         begin
           Result := Screen.Forms[i];
           Exit;
         end;
end;

//show form
procedure ShowForm2(AFormClass: TClass);
var
   F: TCustomForm;
begin
  F := FindFormByClass(AFormClass);
  if Assigned(F) then
  begin
     F.Visible := True;
     F.Show;
     F.BringToFront;
  end
  else
      raise Exception.Create('Form class not created yet: ' + AFormClass.ClassName);
end;

//hide form
procedure HideForm(AFormClass: TClass);
var
   F: TCustomForm;
begin
  F := FindFormByClass(AFormClass);
  if Assigned(F) and F.Visible then
     begin
          F.Hide;
     end;
end;

end.

