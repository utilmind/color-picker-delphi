unit ScrForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  acClasses, acFormHook;

type
  TScreenForm = class(TForm)
    acFormHook1: TacFormHook;
    procedure FormClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ScreenForm: TScreenForm;

implementation

uses Main;

{$R *.DFM}

procedure TScreenForm.FormClick(Sender: TObject);
begin
  MainForm.SwitchToPickerMode;
end;

end.
