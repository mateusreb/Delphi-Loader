unit uHwid;

interface

uses
   Windows, Messages, Classes, Controls, Forms, sysutils,Registry,
  Dialogs, TLHelp32, ExtCtrls, Math, StdCtrls;
type
    cHwid = class
  public
    function GetHDSerialNumber: LongInt;
  end;

var
  HDDSerialNo: String;
  THwid:cHwid;
implementation

function cHwid.GetHDSerialNumber: LongInt;
{$IFDEF WIN32}
var
  Pdw : pDWord;
  Mc, Fl : dword;
{$ENDIF}
begin
  {$IfDef WIN32}
  New(Pdw);
  GetVolumeInformation('C:\', nil, 0, Pdw, Mc, Fl, nil, 0);
  Result := pdw^;
  dispose(Pdw);
  {$ELSE}
  Result := GetWinFlags;
  {$ENDIF}
end;

procedure GetHardwareID;
var
  A, B, C, D: LongWord;
  uretici: Array [0..3] of Dword;
  x: PChar;
  sysdir: Array[0..144] of Char;
  temp_klasor: Array[0..MAX_PATH] of Char;
  MS: TMemoryStatus;
  Reg: TRegistry;
  yyil: String;
begin
  // HDD Serial No
   Try
     HDDSerialno := IntToStr(THwid.GetHDSerialNumber);
   Except
     HDDSerialNo := 'ERRO!'; //'87142390';
   end;
end;
end.




