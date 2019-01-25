unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls,
  acClasses, acUtils, acFormRoller, acFormHelp, acFormMagnet,
  acCaptionButton, acFormTopmost, acTrayIcon, Menus,
  acAutoUpgrader, acFormPlacementSaver, Buttons,
  acFormHints, acFormHook, acQuickAboutBox, acEdit, acControls,
  acFormSystemMenu, acAppCursors, acHTTP;

type
  TMainForm = class(TForm)
    acFormTopmost: TacFormTopmost;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Timer: TTimer;
    Label5: TLabel;
    Label6: TLabel;
    acFormMagnet1: TacFormMagnet;
    acFormHelp1: TacFormHelp;
    HiddenButton: TButton;
    acTrayIcon: TacTrayIcon;
    PopupMenu1: TPopupMenu;
    Restore1: TMenuItem;
    N1: TMenuItem;
    Close1: TMenuItem;
    N2: TMenuItem;
    About1: TMenuItem;
    acCaptionButton1: TacCaptionButton;
    acAutoUpgrader1: TacAutoUpgrader;
    acFormPlacementSaver: TacFormPlacementSaver;
    HTMLColor: TacEdit;
    Label7: TLabel;
    acFormHints: TacFormHints;
    PickBtn: TSpeedButton;
    Red: TacNumberEdit;
    Green: TacNumberEdit;
    Blue: TacNumberEdit;
    acFormHook1: TacFormHook;
    DecColor: TacNumberEdit;
    HexColor: TacNumberEdit;
    acQuickAboutBox: TacQuickAboutBox;
    PickerBox: TacCheckGroupBox;
    PaintBox: TPaintBox;
    acFormSystemMenu1: TacFormSystemMenu;
    acAppCursors1: TacAppCursors;
    procedure TimerTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Close1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure PickBtnClick(Sender: TObject);
    procedure acFormHook1MessageBefore(Sender: TObject;
      var Message: TMessage; var Handled: Boolean);
    procedure RedChange(Sender: TObject);
    procedure GreenChange(Sender: TObject);
    procedure BlueChange(Sender: TObject);
    procedure acAutoUpgrader1Progress(Sender: TObject; TotalSize, ReadSize,
      ReadPercents: Integer);
  private
    DesktopDC: hDC;
    Busy: Boolean;
    Topmost: Boolean;

    procedure RGBToColors;
  public
    procedure SwitchToPickerMode;
  end;

var
  MainForm: TMainForm;

implementation

uses ScrForm;

{$R *.DFM}

const
  crPick = 5;

procedure TMainForm.RGBToColors;
var
  HexStr, HTMLStr: String;
begin
  DecColor.Value := RGB(Red.Value, Green.Value, Blue.Value);

  HexStr := DecToHex(RGB(Red.Value, Green.Value, Blue.Value));
  while Length(HexStr) < 6 do Insert('0', HexStr, 1);
  HTMLStr := HexStr;
  HTMLStr[1] := HexStr[5];
  HTMLStr[2] := HexStr[6];
  HTMLStr[5] := HexStr[1];
  HTMLStr[6] := HexStr[2];
  HexColor.Text := HexStr;
  HTMLColor.Text := '#' + HTMLStr;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
var
  MousePos: TPoint;
  PixelColor: TColor;
begin
  GetCursorPos(MousePos);

  if not PickerBox.Checked then Exit;

  Label1.Caption := ' Current color at mouse position (X=' + IntToStr(MousePos.X) + ', Y=' + IntToStr(MousePos.Y) + '):';
  PixelColor := GetPixel(DesktopDC, MousePos.X, MousePos.Y);

  Red.Value   := GetRValue(PixelColor);
  Green.Value := GetGValue(PixelColor);
  Blue.Value  := GetBValue(PixelColor);

  RGBToColors;

  if not Busy then
   begin
    Busy := True;
    StretchBlt(PaintBox.Canvas.Handle, 0, 0, PaintBox.Width, PaintBox.Height,
               DesktopDC, MousePos.X - 5, MousePos.Y - 3, 11, 7, SRCCOPY);
    with PaintBox.Canvas do
     begin
      Pen.Mode := pmNot;
      Pen.Width := 2;
      MoveTo(PaintBox.Width div 2 - 5, PaintBox.Height div 2);
      LineTo(PaintBox.Width div 2 + 5, PaintBox.Height div 2);
      MoveTo(PaintBox.Width div 2, PaintBox.Height div 2 - 5);
      LineTo(PaintBox.Width div 2, PaintBox.Height div 2 + 5);
     end;
    Busy := False; 
   end;  
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  DesktopDC := GetWindowDC(GetDesktopWindow);

  Screen.Cursors[crPick] := LoadCursor(hInstance, 'PIPETKA');
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ReleaseDC(GetDesktopWindow, DesktopDC);
end;

procedure TMainForm.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.About1Click(Sender: TObject);
begin
  acQuickAboutBox.Execute;
end;

procedure TMainForm.PickBtnClick(Sender: TObject);
begin
  with ScreenForm do
   begin
    PickBtn.Down := True;
    PickerBox.Checked := True;

    Left := 0;
    Top := 0;
    Width := Screen.Width;
    Height := Screen.Height;
    Application.ProcessMessages;
    ScreenForm.Visible := True;
    Topmost := acFormTopmost.Topmost;
    acFormTopmost.Topmost := True;
   end;
end;

procedure TMainForm.SwitchToPickerMode;
begin
  ScreenForm.Visible := False;
  acFormTopmost.Topmost := Topmost;
  PickBtn.Down := False;
  PickerBox.Checked := False;
end;

procedure TMainForm.acFormHook1MessageBefore(Sender: TObject;
  var Message: TMessage; var Handled: Boolean);
begin
  if PickBtn.Down then
   with Message do
    if Msg = WM_NCLBUTTONDOWN then
      SwitchToPickerMode;
end;

procedure TMainForm.RedChange(Sender: TObject);
begin
  if PickerBox.Checked then Exit;
  RGBToColors;
end;

procedure TMainForm.GreenChange(Sender: TObject);
begin
  if PickerBox.Checked then Exit;
  RGBToColors;
end;

procedure TMainForm.BlueChange(Sender: TObject);
begin
  if PickerBox.Checked then Exit;
  RGBToColors;
end;

procedure TMainForm.acAutoUpgrader1Progress(Sender: TObject; TotalSize,
  ReadSize, ReadPercents: Integer);
begin
  Caption := 'Upgrading: ' + IntToStr(ReadPercents) + '%';
end;

end.
