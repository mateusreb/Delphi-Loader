unit Decryptstring;

interface

const
BaseTable:string='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=';
function Decrypt(Str : String; Key: string): String;
function Encrypt(Str : String; Key: string): String;
function Decrypt1(Str : String; Key: string): String;

implementation

  function   FindInTable(CSource:char):integer;  
  begin  
      result:=Pos(string(CSource),BaseTable)-1;  
  end;

  function   EncodeBase64(Source:string):string;
  var  
      Times,LenSrc,i:integer;  
      x1,x2,x3,x4:char;  
      xt:byte;  
  begin  
      result:='';  
      LenSrc:=length(Source);  
      if   LenSrc   mod   3   =0   then   Times:=LenSrc   div   3  
      else   Times:=LenSrc   div   3   +   1;  
      for   i:=0   to   times-1   do  
      begin  
          if   LenSrc   >=   (3+i*3)   then  
          begin  
              x1:=BaseTable[(ord(Source[1+i*3])   shr   2)+1];  
              xt:=(ord(Source[1+i*3])   shl   4)   and   48;  
              xt:=xt   or   (ord(Source[2+i*3])   shr   4);  
              x2:=BaseTable[xt+1];  
              xt:=(Ord(Source[2+i*3])   shl   2)   and   60;  
              xt:=xt   or   (ord(Source[3+i*3])   shr   6);  
              x3:=BaseTable[xt+1];  
              xt:=(ord(Source[3+i*3])   and   63);  
              x4:=BaseTable[xt+1];  
          end  
          else   if   LenSrc>=(2+i*3)   then  
          begin  
              x1:=BaseTable[(ord(Source[1+i*3])   shr   2)+1];  
              xt:=(ord(Source[1+i*3])   shl   4)   and   48;  
              xt:=xt   or   (ord(Source[2+i*3])   shr   4);  
              x2:=BaseTable[xt+1];  
              xt:=(ord(Source[2+i*3])   shl   2)   and   60;  
              x3:=BaseTable[xt+1];  
              x4:='=';  
          end   else  
          begin  
              x1:=BaseTable[(ord(Source[1+i*3])   shr   2)+1];  
              xt:=(ord(Source[1+i*3])   shl   4)   and   48;  
              x2:=BaseTable[xt+1];  
              x3:='=';  
              x4:='=';  
          end;  
          result:=result+x1+x2+x3+x4;  
      end;  
  end;

  function   DecodeBase64(Source:string):string;
  var  
      SrcLen,Times,i:integer;  
      x1,x2,x3,x4,xt:byte;  
  begin  
      result:='';  
      SrcLen:=Length(Source);  
      Times:=SrcLen   div   4;  
      for   i:=0   to   Times-1   do  
      begin  
          x1:=FindInTable(Source[1+i*4]);  
          x2:=FindInTable(Source[2+i*4]);  
          x3:=FindInTable(Source[3+i*4]);  
          x4:=FindInTable(Source[4+i*4]);  
          x1:=x1   shl   2;  
          xt:=x2   shr   4;  
          x1:=x1   or   xt;  
          x2:=x2   shl   4;  
          result:=result+chr(x1);  
          if   x3=   64   then   break;  
          xt:=x3   shr   2;  
          x2:=x2   or   xt;  
          x3:=x3   shl   6;  
          result:=result+chr(x2);  
          if   x4=64   then   break;  
          x3:=x3   or   x4;  
          result:=result+chr(x3);  
      end;  
  end;


function Decrypt1(Str : String; Key: string): String;
var
  X, Y : Integer;
  A : Byte;
begin
  Y := 1;
  for X := 1 to Length(Str) do
  begin
    A := (ord(Str[X]) and $0f) xor (ord(Key[Y]) and $0f);
    Str[X] := char((ord(Str[X]) and $f0) + A);
    Inc(Y);
    If Y > length(Key) then Y := 1;
  end;
  Result := Str;
end;

function Encrypt(Str : String; Key: string): String;
begin
result:= Decrypt1(str,key);
result:= EncodeBase64(result);
end;

function Decrypt(Str : String; Key: string): String;
begin
result:= DecodeBase64(str);
result:= Decrypt1(result,key);
end;


end.

