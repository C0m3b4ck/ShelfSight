program bookworm;

{$mode objfpc}{$H+}

uses
  Interfaces, // this includes the LCL widgetset
  Forms, mainmenu_unit, login_unit, register_unit, main_workspace_unit,
  FormManager, FileChecks, global_vars, dbmgmt;

{$R *.res}

begin
  Application.Title:='BookwormPascal';
  //RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(Tmain_form, main_form);
  Application.CreateForm(Tlogin_form, login_form);
  Application.CreateForm(Tregister_form, register_form);
  Application.CreateForm(Tmain_workspace, main_workspace);

  //form registration
  RegisterForm('mainmenu', Tmain_form);
  RegisterForm('mainworkspace', Tmain_workspace);
  RegisterForm('login', Tlogin_form);
  RegisterForm('register', Tregister_form);
  Application.Run;
end.

