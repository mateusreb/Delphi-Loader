unit uLogin;

interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,Forms,
  Dialogs,md5, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP,ComCtrls, ShellApi, uFileini,FormPainel, uHwid , uDownload, uCrypt,cpuid,Decryptstring,HDDSerial,Unit2;
  type
    cLogin = class
  public
    procedure LoginUser(sUser,sPass:String);
  end;

var
 Login:cLogin;
implementation
procedure cLogin.LoginUser(sUser,sPass:String);
var
  MySocket:TidHttp;
  StringList:TStringList;
  abhe:String;
begin
  abhe:=GetIdeDiskSerialNumber+GetScsiDiskSerialNumber+GetHddSerialNumber+GetCPUName;
  abhe:=Encrypt(abhe,'firecheats.net');
try
  MySocket:=TidHttp.Create(nil);
  StringList:=TStringList.Create;
  MySocket.Request.UserAgent :='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0';
  StringList.Text:=MySocket.Post('http://firecheats.net/system/ValidateKaybo.php?user=' + sUser + '&pass=' + sPass + '&token=' + abhe,StringList);
  {abrir painel}

if(StringList[0] = '18783d4f71f133ca40d5a8dee7e1e520')then //LOGIN_OK
begin
  if(StringList[1] <> '0.6') then
  begin
  MessageBox(0, 'Esta versão foi desativada, baixe a nova no site!'+#13+'Esta versión ha sido deshabilitado, descargue el nuevo sitio!', 'Update', +mb_Ok +mb_ICONWARNING);
  ShellExecute(0,'open','http://firecheats.net/index.php?forums/download.9/',nil,nil,SW_SHOW);
  end
  else
  begin
  Application.CreateForm(TPainel, Painel);
  Painel.Show;
  end;
end;
  {hwid banido}
if(StringList[0] = '1803ee0c606313409353256baf80bdfa')then //LOGIN_BAN
begin
  MessageBox(0, 'Su HWID fue prohibido de nuestro sistema!'+#13+'Espere a que la decisión de algunas ADMINISTRADOR!', 'HWID', +mb_Ok +mb_ICONWARNING);
end;

  {vip expirado}
if(StringList[0] = 'db2c259fc720367f973d433632a0c3ab')then //NOT_VIP
begin
MessageBox(0, 'Seu VIP expirou!'+#13+'Deseja recarregar novamente?', 'VIP', +mb_Ok +mb_ICONWARNING);
  ShellExecute(0,'open','http://firecheats.net/index.php?pages/recarga/',nil,nil,SW_SHOW);
end;

  {login incorreto}
if(StringList[0] = '97005f4136c2e47ca4308600782ec003')then  //LOGIN_FAIL
begin
  MessageBox(0, 'Usuario o la contraseña no son correctos!', 'Sesión', +mb_Ok +mb_ICONWARNING);
end;

  {hwid diferente}
if(StringList[0] = 'de5fb169ea8d8790ec07c79a01246313')then  //TOKEN_ERROR
begin
MessageBox(0, 'El HWID esta cuenta ya ha sido vinculada a otro equipo!', 'HWID', +mb_Ok +mb_ICONWARNING);
ShellExecute(0,'open','http://firecheats.net/index.php?pages/reset/',nil,nil,SW_SHOW);
end;

except
MessageBox(0, 'No se pudo conectar con el servidor!', 'Servidor', +mb_Ok +mb_ICONWARNING);
end;
end;
end.
