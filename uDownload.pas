unit uDownload;

interface
uses Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls;

type
cDownload = class
public
function GetFileSize(aFile : TFileName) : Int64;
function GetTemporaryDir: String;
end;
var
iDownload:cDownload;
implementation
function cDownload.GetFileSize(aFile : TFileName) : Int64;
var
  vSR : TSearchRec;
  I : Integer;
begin
  I := FindFirst(aFile, faArchive, vSR);
  try
    Result := -1;
    if (I = 0) then
      Result := vSR.Size;
  finally
    FindClose(vSR);
  end;
end;

function cDownload.GetTemporaryDir: String;
var
  pNetpath: ARRAY[ 0..MAX_path - 1 ] of Char;
  nlength: Cardinal;
begin
  nlength := MAX_path;
  FillChar( pNetpath, SizeOF( pNetpath ), #0 );
  GetTemppath( nlength, pNetpath );
  Result := StrPas( pNetpath );
end;

end.
 