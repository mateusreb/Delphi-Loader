
 

unit unit2;
interface 
uses 
   Windows,SysUtils; 
type 
  TCPUIDResult = packed record 
    EAX: Cardinal; 
    EBX: Cardinal; 
    ECX: Cardinal; 
    EDX: Cardinal; 
  end; 
  TCPUType = (ctPrimary, ctOverDrive, ctSecondary, ctUnknown); 
  function GetCPUName: string; 
const 
   CPUID_CPUSIGNATURE	: DWORD = $1; 
 
var 
  CPUID_Level: DWORD; 
implementation 
 
uses FormMain;

function GetCPUName: string;
var
      _eax, _ebx, _ecx, _edx: Longword;
      i: Integer;
      b: Byte;
      s, s1, s2, s3, s_all: string;
begin
asm     //get brand ID
          mov eax,$80000002
          db $0F
          db $A2
          mov _eax,eax
          mov _ebx,ebx
          mov _ecx,ecx
          mov _edx,edx
        end;
        s  := '';
        s1 := '';
        s2 := '';
        s3 := '';
        for i := 0 to 3 do
        begin
          b := lo(_eax);
          s3:= s3 + chr(b);
          b := lo(_ebx);
          s := s + chr(b);
          b := lo(_ecx);
          s1 := s1 + chr(b);
          b := lo(_edx);
          s2 := s2 + chr(b);
          _eax := _eax shr 8;
          _ebx := _ebx shr 8;
          _ecx := _ecx shr 8;
          _edx := _edx shr 8;
        end;
        s_all := s3 + s + s1 + s2;
        asm
          mov eax,$80000003
          db $0F
          db $A2
          mov _eax,eax
          mov _ebx,ebx
          mov _ecx,ecx
        mov _edx,edx
        end;
        s  := '';
        s1 := '';
        s2 := '';
        s3 := '';
        for i := 0 to 3 do
        begin
          b := lo(_eax);
          s3 := s3 + chr(b);
          b := lo(_ebx);
          s := s + chr(b);
          b := lo(_ecx);
          s1 := s1 + chr(b);
          b := lo(_edx);
          s2 := s2 + chr(b);
          _eax := _eax shr 8;
          _ebx := _ebx shr 8;
          _ecx := _ecx shr 8;
          _edx := _edx shr 8;
        end;
        s_all := s_all + s3 + s + s1 + s2;
        asm
          mov eax,$80000004
          db $0F
          db $A2
          mov _eax,eax
          mov _ebx,ebx
          mov _ecx,ecx
          mov _edx,edx
        end;
        s  := '';
        s1 := '';
        s2 := '';
        s3 := '';
        for i := 0 to 3 do
        begin
          b  := lo(_eax);
          s3 := s3 + chr(b);
          b := lo(_ebx);
          s := s + chr(b);
          b := lo(_ecx);
          s1 := s1 + chr(b);
          b  := lo(_edx);
          s2 := s2 + chr(b);
          _eax := _eax shr 8;
          _ebx := _ebx shr 8;
          _ecx := _ecx shr 8;
          _edx := _edx shr 8;
        end;
        if s2[Length(s2)] = #0 then setlength(s2, Length(s2) - 1);
        result := (s_all + s3 + s + s1 + s2);
    end;

 
function ExecuteCPUID: TCPUIDResult; assembler; 
asm 
    PUSH    EBX 
    PUSH    EDI 
    MOV     EDI, EAX 
    MOV     EAX, CPUID_LEVEL 
    DW	    $A20F 
    STOSD 
    MOV     EAX, EBX 
    STOSD 
    MOV     EAX, ECX 
    STOSD 
    MOV     EAX, EDX 
    STOSD 
    POP     EDI
    POP     EBX 
end; 


end.










