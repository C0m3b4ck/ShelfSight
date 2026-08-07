unit mainmenu_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  FormManager, FileChecks;

type

  { Tmain_form }

  Tmain_form = class(TForm)
    btnRegister: TButton;
    btnLogin: TButton;
    btnAbout: TButton;
    btnExit: TButton;
    Label1: TLabel;
    procedure btnAboutClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnLoginClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  main_form: Tmain_form;

implementation

{$R *.lfm}

{ Tmain_form }

procedure Tmain_form.btnExitClick(Sender: TObject);
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

procedure Tmain_form.btnLoginClick(Sender: TObject);
begin
  ShowForm('login');
  Self.Hide;
end;

procedure Tmain_form.btnRegisterClick(Sender: TObject);
begin
  ShowForm('register');
  Self.Hide;
end;

procedure Tmain_form.FormCreate(Sender: TObject);
begin
     CheckIfNote();
end;

procedure Tmain_form.btnAboutClick(Sender: TObject);
begin
  ShowMessage('BookwormPascal by C0m3b4ck under APL 2.0');
end;

end.

