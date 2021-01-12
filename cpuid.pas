unit cpuid;

// CPU identification.
// This unit defines the GetCpuID function, which uses the CPUID
// instruction to get the processor type. Not every processor supports the
// CPUID instruction, so the function must use alternate means to get this
// information.
//
// The information that Intel publishes is incorrect. The algorithm
// used here comes from Robert Collins (rcollins@x86.org). See his web site
// at www.x86.org for more information.
//
// Copyright © 1998 Tempest Software, Inc.

interface

const
  CpuFamily386 = 3;
  CpuFamily486 = 4;
  CpuFamilyPentium = 5;
  CpuFamilyPro = 6;

  CpuModel486DX = 0;  // family = CpuFamily486
  CpuModel486SX = 1;
  CpuModel487SX = 2;
  CpuModel486DX2 = 3;
  CpuModel486SL = 4; // GetCpuid does not detect 486SL processors
  CpuModel486SX2 = 5;
  CpuModel486DX2Enhanced = 7;
  CpuModel486DX4 = 8;

  CpuModelPentium66 = 1;  // 60-66
  CpuModelPentium133 = 2; // 90-133
  CpuModelPentiumOverdrive486 = 3; // overdrive for 486
  CpuModelPentiumMMX = 4;
  CpuModelPentiumOverdrive4 = 5; // overdrive for 486/DX4

  CpuModelCyrixMediaGX = 4; // family = CpuFamily486, CpuFamilyPentium
  CpuModelCyrix6x86 = 2;    // family = CpuFamilyPentium
  CpuModelCyrix6x86MX = 0;  // family = CpuFamilyPro

  CpuModelAMD5x86 = 0; // family = CpuFamily486
  CpuModelAMDK5_0 = 0; // family = Pentium
  CpuModelAMDK5_1 = 1;
  CpuModelAMDK5_2 = 2;
  CpuModelAMDK5_3 = 3;
  CpuModelAMDK6 = 6;
  CpuModelAMDK63D = 8;

  CpuModelPro = 1;
  CpuModelProOverdrive = 2;
  CpuModelProII = 3;

  VendorIntel = 'GenuineIntel';
  VendorAMD = 'AuthenticAMD';
  VendorCyrix = 'CyrixInstead';

type
  TCpuType = (cpuOriginalOEM, cpuOverdrive, cpuDual, cpuReserved);
  TCpuFeature = (cfFPU, cfVME, cfDE, cfPDE, cfTSC, cfMSR, cfMCE, cfCX8, cfAPIC,
               cfReserved10, cfReserved11, cfMTRR, cfPGE, cfMCA, cfCMOV,
               cfPAT, cfReserved17, cfReserved18, cfReserved19,
               cfReserved20, cfReserved21, cfReserved22, cfReserved23,
               cfMMX, cfFastFPU, cfReserved26, cfReserved27,
               cfReserved28, cfReserved29, cfReserved30, cfReserved31
              );
  TCpuFeatureSet = set of TCpuFeature;

  TCpuId = packed record
    CpuType: TCpuType;
    Family: Byte;
    Model: Byte;
    Stepping: Byte;
    Features: TCpuFeatureSet;
    Vendor: string[12];
  end;

// Get the CPU information and store it in Cpuid.
procedure GetCpuid(var Cpuid: TCpuid);
// Get the CPU information from Cpuid and return a readable string.
function GetCpuName(const Cpuid: TCpuid): string; overload;
// Return a readable string for the current CPU.
function GetCpuName: string; overload;

implementation

uses SysUtils;

// All 386 and early 486 processors do not support the CPUID instruction.
// Only 486 CPUs implement the XADD instruction, so that differentiates
// the two kinds of processors.
procedure NoCpuidInstruction(var Cpuid: TCpuid);
var
  FCW: Word;
begin
  Cpuid.Vendor := '';
  Cpuid.CpuType := cpuOriginalOem;
  Cpuid.Model := 0;
  Cpuid.Stepping := 0;
  try
    asm
      xadd dl, dl
    end;
    // The CPU implements the XADD instruction, so it's a 486.
    Cpuid.Family := CpuFamily486;

    // Now try to determine which kind of 486.
    Cpuid.Model := CpuModel486DX; // assume DX until proven otherwise
    asm
      mov edx, cr0          // Try to set the DX flag in the CR0 register
      and dl, not $10       // Clear the flag
      mov cr0, edx          // Set CR0
      mov edx, cr0          // Get CR0
      and dl, $10           // Test the flag: did the CPU turn on the flag?
      jz @Exit              // No: it's a 486DX

      // Now try to tell the difference between a 486SX and a 487SX
      // The latter has a floating point processor
      inc Cpuid.Model           // Start by guessing 486SX

      mov word ptr FCW, $5a5a   // store a non-zero value
      fninit                    // must use non-wait form
      fnstsw FCW                // store the status
      cmp byte ptr FCW, 0       // was the correct status read?
      jne @Exit                 // no
      fnstcw FCW                // save control word
      mov dx, FCW               // get the control word
      and dx, $103              // mask the proper status bits
      cmp dx, $3f               // Is a numeric processor installed?
      jne @Exit                 // no: it's a 486SX
      inc Cpuid.Model           // yes: it's a 487SX
    @Exit:
    end;
  except
    on EInvalidOp do
      Cpuid.Family := CpuFamily386;
    else
      raise;
  end;
end;

procedure GetCpuid(var Cpuid: TCpuid);
label
  CanUseCpuId;
begin
  asm
    // Test whether the processor supports the CPUID instruction
    pushfd
    pop ecx;                     // Get the EFLAGS into ECX
    mov edx, ecx                 // Save a copy of EFLAGS in EDX
    xor ecx, $200000             // Toggle the ID flag
    push ecx                     // Try to set EFLAGS
    popfd
    pushfd                       // Now test whether the change sticks
    pop ecx                      // Get the new EFLAGS into ECX
    xor ecx, edx                 // Compare with EDX
    jnz CanUseCpuid              // If the bits are different, the CPUID instruction works
  end;

  NoCpuidInstruction(Cpuid);
  Exit;

  asm
CanUseCpuID:
    push esi                     // preserve ESI and EBX
    push ebx                     // Delphi lets a function trash EAX, ECX, and EDX
    mov esi, DWORD PTR Cpuid     // Because the CPUID instruction tramples EAX..EDX
                                 // save the CPUID argument in ESI

    // Okay to use CPUID instruction. Restore original EFLAGS
    push edx
    popfd

    // Get the vendor name, which is the concatenation of the contents
    // of the EBX, EDX, and EAX registers, treated as three 4-byte
    // character arrays.
    mov eax, 0
    dw $a20f                                 // CPUID instruction
    mov BYTE(TCpuid(esi).Vendor), 12         // string length
    mov DWORD(TCpuid(esi).Vendor+1), ebx     // string content
    mov [OFFSET(TCpuid(esi).Vendor)+5], edx
    mov [OFFSET(TCpuid(esi).Vendor)+9], ecx

    // Get the processor information
    mov eax, 1
    dw $a20f               // CPUID instruction
    mov TCpuid(esi).Features, edx

    // The signature comes in parts, most of which are 4 bits long.
    // Delphi doesn't support bit fields, so the TCpuid record uses bytes
    // to store these fields. That means unpacking the nibbles into bytes.
    mov edx, eax
    and al, $F
    mov TCpuid(esi).Stepping, al

    shr edx, 4
    mov eax, edx
    and al, $F
    mov TCpuid(esi).Model, al

    shr edx, 4
    mov eax, edx
    and al, $F
    mov TCpuid(esi).Family, al

    shr edx, 4
    mov eax, edx
    and al, $3
    mov TCpuid(esi).CpuType, al

    pop ebx
    pop esi
  end;
end;

resourcestring
  sOverdrive = ' Overdrive';
  sMMX = ' MMX';
  sDual = ' (Dual processor)';
  sPentiumIIModel = 'Pentium II Model %d';
  s486 = '486 (Model %d)';
  sK5 = 'K5 (Model %d)';
  sUnknown = 'P%d (Model %d)';
  sModel = ' (Model %d)';

function GetCpuName(const Cpuid: TCpuid): string;
begin
  if Cpuid.Vendor = VendorIntel then
  begin
    Result := 'Intel ';
    case Cpuid.Family of
    CpuFamily386:
      Result := Result + '386';
    CpuFamily486:
      case Cpuid.Model of
      CpuModel486DX:
        Result := Result + '486DX';
      CpuModel486SX:
        Result := Result + '486SX';
      CpuModel487SX:
        Result := Result + '487SX';
      CpuModel486DX2:
        Result := Result + '486DX2';
      CpuModel486SX2:
        Result := Result + '486SX2';
      CpuModel486DX2Enhanced:
        Result := Result + '486DX2 Write-back enhanced';
      CpuModel486DX4:
        Result := Result + '486DX4';
      else
        Result := Format(s486, [Cpuid.Model]);
      end;
    CpuFamilyPentium:
      Result := Result + 'Pentium';
    CpuFamilyPro:
      case Cpuid.Model of
      CpuModelPro:
        Result := Result + 'Pentium Pro';
      CpuModelProOverdrive:
        Result := Result + 'Pentium Pro ' + sOverdrive;
      CpuModelProII:
        Result := Result + 'Pentium II';
      else
        Result := Result + Format(sPentiumIIModel, [Cpuid.Model]);
      end;
    else
      Result := Format(sUnknown, [Cpuid.Family, Cpuid.Model]);
    end;
    if cfMMX in Cpuid.Features then
      Result := Result + sMMX;
    if Cpuid.CpuType = cpuOverdrive then
      Result := Result + sOverdrive;
  end

  else if Cpuid.Vendor = VendorCyrix then
  begin
    Result := 'Cyrix ';
    case Cpuid.Family of
    CpuFamily486:
      Result := Result + 'Media GX';
    CpuFamilyPentium:
      case Cpuid.Model of
      CpuModelCyrixMediaGX:
        Result := Result + 'Media GX';
      CpuModelCyrix6x86:
        Result := Result + '6x86';
      else
        Result := Format(sUnknown, [Cpuid.Family, Cpuid.Model]);
      end;
    CpuFamilyPro:
      case Cpuid.Family of
      CpuModelCyrix6x86MX:
        Result := Result + '6x86MX';
      else
        Result := Format(sUnknown, [Cpuid.Family, Cpuid.Model]);
      end;
    else
      Result := Format(sUnknown, [Cpuid.Family, Cpuid.Model]);
    end;
  end

  else if Cpuid.Vendor = VendorAMD then
  begin
    Result := 'AMD ';
    case Cpuid.Family of
    CpuFamily486:
      Result := Result + '486/5x86';
    CpuFamilyPentium:
      case Cpuid.Model of
      CpuModelAMDK5_0,
      CpuModelAMDK5_1,
      CpuModelAMDK5_2,
      CpuModelAMDK5_3:
        Result := Result + Format(sK5, [Cpuid.Model]);
      CpuModelAMDK6:
        Result := Result + 'K6';
      CpuModelAMDK63D:
        Result := Result + 'K6-3D';
      end;
    else
      Result := Format(sUnknown, [Cpuid.Family, Cpuid.Model]);
    end;
  end

  else
  begin
    Result := Cpuid.Vendor;
    if (Length(Result) > 0) and (Result[Length(Result)] <> ' ') then
      Result := Result + ' ';
    case Cpuid.Family of
    CpuFamily386:
      Result := Result + '386';
    CpuFamily486:
      Result := Result + '486';
    CpuFamilyPentium:
      Result := Result + '586';
    else
      Result := Format('%d86', [Cpuid.Family]);
    end;
    Result := Result + Format(sModel, [Cpuid.Model]);
  end;

  if Cpuid.CpuType = cpuDual then
    Result := Result + sDual;
end;

function GetCpuName: string; overload;
var
  Cpuid: TCpuid;
begin
  GetCpuid(Cpuid);
  Result := GetCpuName(Cpuid);
end;

end.

