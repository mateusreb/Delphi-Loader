unit FormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,md5, StdCtrls, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, XPMan, ComCtrls,uLogin,FormPainel, IdAntiFreezeBase,
  IdAntiFreeze,uCrypt, uFileini,uDownload, OleCtrls, SHDocVw,ShellApi, uHwid,
  ExtCtrls, Menus;

type
  TFormLogin = class(TForm)
    XPManifest1: TXPManifest;
    GroupBox1: TGroupBox;
    lbUser: TLabel;
    lbSenha: TLabel;
    edUser: TEdit;
    edSenha: TEdit;
    btLogin: TButton;
    cbBool: TCheckBox;
    StatusBar1: TStatusBar;
    IdAntiFreeze1: TIdAntiFreeze;
    IdHTTP1: TIdHTTP;
    GroupBox2: TGroupBox;
    Bevel1: TBevel;
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    Corregirloserrores1: TMenuItem;
    Crearcuenta1: TMenuItem;
    RecarregarVIP1: TMenuItem;
    procedure btLoginClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Corregirloserrores1Click(Sender: TObject);
    procedure Crearcuenta1Click(Sender: TObject);
    procedure RecarregarVIP1Click(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.dfm}
{$R ARQ_RECURSO.RES}

procedure TFormLogin.btLoginClick(Sender: TObject);
var
url:String;
begin
edUser.Enabled:= False;
edSenha.Enabled:= False;
btLogin.Enabled:= False;
Login.LoginUser(edUser.Text,edSenha.Text);
edUser.Enabled:= True;
edSenha.Enabled:= True;
btLogin.Enabled:= True;

if(cbBool.Checked)then
begin
iIni.GravarIni('Login','U',edUser.Text);
iIni.GravarIni('Login','P',edSenha.Text);
end;
if(cbBool.Checked)then
iIni.GravarIni('Login','B','Yes')
else
iIni.GravarIni('Login','B','No');
end;

procedure TFormLogin.FormCreate(Sender: TObject);
var
  Stream: TResourceStream;
begin
if not FileExists('engine.i3en') then
begin
  Stream := TResourceStream.Create(hInstance,
    'NOME_DO_RECURSO', RT_RCDATA);
  try
    Stream.SaveToFile('engine.i3en');
  finally
    Stream.Free;
  end;
  end;

edUser.Text := iIni.LerIni('Login','U');
edSenha.Text := iIni.LerIni('Login','P');

if(iIni.LerIni('Login','B') = 'Yes') then
cbBool.Checked := True;

IdHTTP1.Request.UserAgent :='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20100101 Firefox/12.0';
Memo1.Text:= UTF8Decode(IdHTTP1.Get('http://pastebin.com/raw.php?i=EqsnL74E'));

//MessageBox(0, '[Português]'+#13+'1. Sempre execute o loader como Administrador!'+#13+'2. Efetue login no loader antes de iniciar o jogo!'+#13+#13+'[Español]'+#13+'1. Ejecute siempre el cargador como administrador!'+#13+'2. Inicie sesión en el cargador antes de iniciar el juego!', 'Advertencia!', +mb_Ok +mb_ICONWARNING);
end;

procedure TFormLogin.Corregirloserrores1Click(Sender: TObject);
begin
ShellExecute(0,'open','http://firecheats.net/index.php?threads/errofix-v0-1.179/',nil,nil,SW_SHOW);
end;

procedure TFormLogin.Crearcuenta1Click(Sender: TObject);
begin
ShellExecute(0,'open','http://firecheats.net/index.php?login/',nil,nil,SW_SHOW);
end;

procedure TFormLogin.RecarregarVIP1Click(Sender: TObject);
begin
ShellExecute(0,'open','http://firecheats.net/index.php?pages/recarga/',nil,nil,SW_SHOW);
end;

end.
