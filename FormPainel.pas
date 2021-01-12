unit FormPainel;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,TlHelp32 ,uCrypt,uFileini, ComCtrls;

type
  TPainel = class(TForm)
    GroupBox1: TGroupBox;
    lbUser: TLabel;
    iUser: TLabel;
    Timer1: TTimer;
    tInject: TTimer;
    GroupBox2: TGroupBox;
    Memo1: TMemo;
    procedure Timer1Timer(Sender: TObject);
    procedure tInjectTimer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Painel: TPainel;
  Status:Integer;
  hFile:THandle;
implementation

uses FormMain;

{$R *.dfm}

procedure TPainel.Timer1Timer(Sender: TObject);
begin
iUser.Caption:= FormLogin.edUser.text;
FormLogin.Hide;
end;

function GetPID(ProcessName: string): DWORD;
var MyHandle: THandle;
    Struct: TProcessEntry32;
begin
 Result:=0;
 try
  MyHandle:=CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
  Struct.dwSize:=Sizeof(TProcessEntry32);
  if Process32First(MyHandle, Struct) then
   if Struct.szExeFile=ProcessName then
    begin
     Result:=Struct.th32ProcessID;
     Exit;
    end;
  while Process32Next(MyHandle, Struct) do
   if Struct.szExeFile=ProcessName then
    begin
     Result:=Struct.th32ProcessID;
     Exit;
    end;
 except on exception do
  Exit;
 end;
end;

procedure TPainel.tInjectTimer(Sender: TObject);
var
  pPID: DWORD;
  PID:DWORD;
  DLL:PAnsiChar;
  Fun:PDWORD;
begin
try
  pPID:=GetPID('PointBlank.exe');
  if(pPID > 0)then
  begin
  tInject.Enabled:= false;
  Fun := GetProcAddress(LoadLibrary('engine.i3en'), 'Exit');
  hFile:= CreateFile('fc.fc',GENERIC_READ,FILE_SHARE_READ or FILE_SHARE_WRITE,nil,OPEN_EXISTING,0,0);
  asm
  push hFile
  call Fun
  call ExitProcess
  end;
end;
except
end;
  end;
end.
