program ColorPicker;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  ScrForm in 'ScrForm.pas' {ScreenForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Color Picker';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TScreenForm, ScreenForm);
  Application.Run;
end.
