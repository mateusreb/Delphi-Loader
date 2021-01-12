unit uCrypt;

interface
uses
 Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Dialogs;
 type
    cCrypt = class
  public
    function XorStr(Stri, Strk: String): String;
    function GerarString(n:integer):String;
    function EncryptStr(const S: String; Key: Word): String;
    function DecryptStr(const S: String; Key: Word): String;
    function myCrypt(Action, Src: String): String;
  end;
var
  Crypt:cCrypt;
implementation

function cCrypt.XorStr(Stri, Strk: String): String;
var
    Longkey: string;
    I: Integer;
    Next: char;
begin
    for I := 0 to (Length(Stri) div Length(Strk)) do
    Longkey := Longkey + Strk;
    for I := 1 to length(Stri) do
    begin
        Next := chr((ord(Stri[i]) xor ord(Longkey[i])));
        Result := Result + Next;
    end;
end;

function cCrypt.EncryptStr(const S: String; Key: Word): String;
var I: Integer;
const C1 = 53761;
      C2 = 32618; 
begin
  Result := S;
  for I := 1 to Length(S) do begin
    Result[I] := char(byte(S[I]) xor (Key shr 8));
    Key := (byte(Result[I]) + Key) * C1 + C2;
  end;
end;

function cCrypt.myCrypt(Action, Src: String): String;
Label Fim;
var KeyLen : Integer;
        KeyPos : Integer;
        OffSet : Integer;
        Dest, Key : String;
        SrcPos : Integer;
        SrcAsc : Integer;
        TmpSrcAsc : Integer;
        Range : Integer;
begin
        if (Src = '') Then
        begin
        Result:= '';
        Goto Fim;
        end;
        Key := '>>1dw51ew1e8wwe1we1we1w>>e8wd4wr84t5df1d5r787w37a6d1sdb1mh5k1uol14u5hg4r5g4ef1d2d1w8e';
        Dest := '';
        KeyLen := Length(Key);
        KeyPos := 0;
       // SrcPos := 0;
      //  SrcAsc := 0;
        Range := 256;
        if (Action = UpperCase('C')) then
        begin
                Randomize;
                OffSet := Random(Range);
                Dest := Format('%1.2x',[OffSet]);
                for SrcPos := 1 to Length(Src) do
                begin
                       // Application.ProcessMessages;
                        SrcAsc := (Ord(Src[SrcPos]) + OffSet) Mod 255;
                        if KeyPos < KeyLen then KeyPos := KeyPos + 1 else KeyPos := 1;

                        SrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
                        Dest := Dest + Format('%1.2x',[SrcAsc]); //%1.2x
                        OffSet := SrcAsc;
                end;
        end
        Else if (Action = UpperCase('D')) then
        begin
                OffSet := StrToInt('$' + copy(Src,1,2));
                SrcPos := 3;
                repeat
                        SrcAsc := StrToInt('$' + copy(Src,SrcPos,2));
                        if (KeyPos < KeyLen) Then KeyPos := KeyPos + 1 else KeyPos := 1;
                        TmpSrcAsc := SrcAsc Xor Ord(Key[KeyPos]);
                        if TmpSrcAsc <= OffSet then TmpSrcAsc := 255 + TmpSrcAsc - OffSet
                        else TmpSrcAsc := TmpSrcAsc - OffSet;
                        Dest := Dest + Chr(TmpSrcAsc);
                        OffSet := SrcAsc;
                        SrcPos := SrcPos + 2;
                until (SrcPos >= Length(Src));
        end;
        Result:= Dest;
Fim:
end;


function cCrypt.DecryptStr(const S: String; Key: Word): String;
var I: Integer;
const C1 = 53761;
      C2 = 32618;
begin
  Result := S;
  for I := 1 to Length(S) do begin
   Result[I] := char(byte(S[I]) xor (Key shr 8));
   Key := (byte(S[I]) + Key) * C1 + C2;
  end;
end;

function cCrypt.GerarString(n:integer):String;
var
str: string;
begin
Randomize;
str := '1234567890abcdefghijklmnopqrstuvwxyz1234567890!@#$%¨&*()_+=§¬¢£³²¹,.°ºª{<>:;/\|ç';
Result := '';
repeat
Result := Result + str[Random(Length(str)) + 1];
until (Length(Result) = n)
end;
end.
