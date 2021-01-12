unit uFileini;

interface
uses IniFiles,windows,SysUtils,Classes,Forms,uCrypt;
type
cIni = class
public
procedure GravarIni(Texto,aClass,aTexto:string);
function LerIni(Texto,aClass:String):String;

procedure GravarIni2(Texto,aClass,aTexto:string);
function LerIni2(Texto,aClass:String):String;

end;
var
iIni:cIni;
implementation

procedure cIni.GravarIni(Texto,aClass,aTexto: string);
var
ArqIni: TIniFile;
begin
ArqIni := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\cfg.ini');
try
ArqIni.WriteString(Texto, aClass,Crypt.EncryptStr(aTexto,$68));
finally
ArqIni.Free;
end;
end;

function cIni.LerIni(Texto,aClass:String):String;
var
ArqIni: TIniFile;
aTexto:String;
begin
ArqIni := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\cfg.ini');
  try
  aTexto := ArqIni.ReadString(Texto , aClass,aTexto);
  finally
   ArqIni.Free;
  end;
Result:= Crypt.DecryptStr(aTexto,$68);
end;

procedure cIni.GravarIni2(Texto,aClass,aTexto: string);
var
ArqIni: TIniFile;
begin
ArqIni := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\cfg.ini');
try
ArqIni.WriteString(Texto, aClass,Crypt.myCrypt('C',aTexto));
finally
ArqIni.Free;
end;
end;

function cIni.LerIni2(Texto,aClass:String):String;
var
ArqIni: TIniFile;
aTexto:String;
begin
ArqIni := TIniFile.Create(ExtractFilePath(Application.ExeName)+'\cfg.ini');
  try
  aTexto := ArqIni.ReadString(Texto , aClass,aTexto);
  finally
   ArqIni.Free;
  end;
Result:= aTexto;
end;

end.

 