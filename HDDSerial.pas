 

unit HDDSerial; 
 
interface 
 
uses Windows, SysUtils; 
 
const 
    HDD_IDE = 1; 
    HDD_UNKNOWN = 0; 
    HDD_SCSI = 2; 
 
function GetIdeDiskSerialNumber: string; 
function GetScsiDiskSerialNumber: string; 
function GetHddSerialNumber: string; 
 
implementation 
 
 
{******************************************************************************* 
��ȡ��һ��IDEӲ�̵����к� 
������� S.M.A.R.T. ioctl ����Ϣ�ɲ鿴: 
http://www.microsoft.com/hwdev/download/respec/iocltapi.rtf 
 
MSDN����Ҳ��һЩ�򵥵����� 
Windows Development -> Win32 Device Driver Kit -> 
SAMPLE: SmartApp.exe Accesses SMART stats in IDE drives 
 
�����Բ鿴 http://www.mtgroup.ru/~alexk 
IdeInfo.zip - һ���򵥵�ʹ����S.M.A.R.T. Ioctl API��DelphiӦ�ó��� 
 
ע��: 
WinNT/Win2000 - �����ӵ�ж�Ӳ�̵Ķ�/д����Ȩ�� 
Win98 - SMARTVSD.VXD ���밲װ�� \windows\system\iosubsys������ϵͳ�� 
*******************************************************************************} 
 
function GetIdeDiskSerialNumber: string; 
const IDENTIFY_BUFFER_SIZE = 512; 
type 
    TIDERegs = packed record 
        bFeaturesReg: BYTE; //Used for specifying SMART "commands". 
        bSectorCountReg: BYTE; //IDE sector count register 
        bSectorNumberReg: BYTE; //IDE sector number register 
        bCylLowReg: BYTE; //IDE low order cylinder value 
        bCylHighReg: BYTE; //IDE high order cylinder value 
        bDriveHeadReg: BYTE; //IDE drive/head register 
        bCommandReg: BYTE; //Actual IDE command. 
        bReserved: BYTE; //reserved for future use.  Must be zero. 
    end; 
    TSendCmdInParams = packed record 
        //Buffer size in bytes 
        cBufferSize: DWORD; 
        //Structure with drive register values. 
        irDriveRegs: TIDERegs; 
        //Physical drive number to send command to (0,1,2,3). 
        bDriveNumber: BYTE; 
        bReserved: array[0..2] of Byte; 
        dwReserved: array[0..3] of DWORD; 
        bBuffer: array[0..0] of Byte; //Input buffer. 
    end; 
    TIdSector = packed record 
        wGenConfig: Word; 
        wNumCyls: Word; 
        wReserved: Word; 
        wNumHeads: Word; 
        wBytesPerTrack: Word; 
        wBytesPerSector: Word; 
        wSectorsPerTrack: Word; 
        wVendorUnique: array[0..2] of Word; 
        sSerialNumber: array[0..19] of CHAR; 
        wBufferType: Word; 
        wBufferSize: Word; 
        wECCSize: Word; 
        sFirmwareRev: array[0..7] of Char; 
        sModelNumber: array[0..39] of Char; 
        wMoreVendorUnique: Word; 
        wDoubleWordIO: Word; 
        wCapabilities: Word; 
        wReserved1: Word; 
        wPIOTiming: Word; 
        wDMATiming: Word; 
        wBS: Word; 
        wNumCurrentCyls: Word; 
        wNumCurrentHeads: Word; 
        wNumCurrentSectorsPerTrack: Word; 
        ulCurrentSectorCapacity: DWORD; 
        wMultSectorStuff: Word; 
        ulTotalAddressableSectors: DWORD; 
        wSingleWordDMA: Word; 
        wMultiWordDMA: Word; 
        bReserved: array[0..127] of BYTE; 
    end; 
    PIdSector = ^TIdSector; 
    TDriverStatus = packed record 
        //���������صĴ�����룬�޴��򷵻�0 
        bDriverError: Byte; 
        //IDE����Ĵ��������ݣ�ֻ�е�bDriverError Ϊ SMART_IDE_ERROR ʱ��Ч 
        bIDEStatus: Byte; 
        bReserved: array[0..1] of Byte; 
        dwReserved: array[0..1] of DWORD; 
    end; 
    TSendCmdOutParams = packed record 
        //bBuffer�Ĵ�С 
        cBufferSize: DWORD; 
        //������״̬ 
        DriverStatus: TDriverStatus; 
        //���ڱ�������������������ݵĻ�������ʵ�ʳ�����cBufferSize���� 
        bBuffer: array[0..0] of BYTE; 
    end; 
var hDevice: THandle; 
    cbBytesReturned: DWORD; 
    //ptr : PChar; 
    SCIP: TSendCmdInParams; 
    aIdOutCmd: array[0..(SizeOf(TSendCmdOutParams) + IDENTIFY_BUFFER_SIZE - 1) - 1] of Byte; 
    IdOutCmd: TSendCmdOutParams absolute aIdOutCmd; 
    procedure ChangeByteOrder(var Data; Size: Integer); 
    var ptr: PChar; 
        i: Integer; 
        c: Char; 
    begin 
        ptr := @Data; 
        for i := 0 to (Size shr 1) - 1 do begin 
            c := ptr^; 
            ptr^ := (ptr + 1)^; 
            (ptr + 1)^ := c; 
            Inc(ptr, 2); 
        end; 
    end; 
begin 
    Result := ''; //��������򷵻ؿմ� 
    if SysUtils.Win32Platform = VER_PLATFORM_WIN32_NT then begin //Windows NT, Windows 2000 
        //��ʾ���ı����ƿ���������������������ڶ����������� '\\.\PhysicalDrive1\' 
        hDevice := CreateFile('\\.\PhysicalDrive0', GENERIC_READ or GENERIC_WRITE, 
            FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0); 
    end else //Version Windows 95 OSR2, Windows 98 
        hDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0); 
    if hDevice = INVALID_HANDLE_VALUE then Exit; 
    try 
        FillChar(SCIP, SizeOf(TSendCmdInParams) - 1, #0); 
        FillChar(aIdOutCmd, SizeOf(aIdOutCmd), #0); 
        cbBytesReturned := 0; 
        //Set up data structures for IDENTIFY command. 
        with SCIP do begin 
            cBufferSize := IDENTIFY_BUFFER_SIZE; 
            //bDriveNumber := 0; 
            with irDriveRegs do begin 
                bSectorCountReg := 1; 
                bSectorNumberReg := 1; 
                //if Win32Platform=VER_PLATFORM_WIN32_NT then bDriveHeadReg := $A0 
                //else bDriveHeadReg := $A0 or ((bDriveNum and 1) shl 4); 
                bDriveHeadReg := $A0; 
                bCommandReg := $EC; 
            end; 
        end; 
        if not DeviceIoControl(hDevice, $0007C088, @SCIP, SizeOf(TSendCmdInParams) - 1, 
            @aIdOutCmd, SizeOf(aIdOutCmd), cbBytesReturned, nil) then Exit; 
    finally 
        CloseHandle(hDevice); 
    end; 
    with PIdSector(@IdOutCmd.bBuffer)^ do begin 
        ChangeByteOrder(sSerialNumber, SizeOf(sSerialNumber)); 
        (PChar(@sSerialNumber) + SizeOf(sSerialNumber))^ := #0; 
        Result := Trim(StrPas(@sSerialNumber)); 
    end; 
end; 
 
function GetScsiDiskSerialNumber: string; 
{$ALIGN ON} 
type 
    TScsiPassThrough = record 
        Length: Word; 
        ScsiStatus: Byte; 
        PathId: Byte; 
        TargetId: Byte; 
        Lun: Byte; 
        CdbLength: Byte; 
        SenseInfoLength: Byte; 
        DataIn: Byte; 
        DataTransferLength: ULONG; 
        TimeOutValue: ULONG; 
        DataBufferOffset: DWORD; 
        SenseInfoOffset: ULONG; 
        Cdb: array[0..15] of Byte; 
    end; 
    TScsiPassThroughWithBuffers = record 
        spt: TScsiPassThrough; 
        bSenseBuf: array[0..31] of Byte; 
        bDataBuf: array[0..191] of Byte; 
    end; 
    {ALIGN OFF} 
var 
    dwReturned: DWORD; 
    len: DWORD; 
    sDeviceName: string; 
    hDevice: THandle; 
    Buffer: array[0..SizeOf(TScsiPassThroughWithBuffers) + SizeOf(TScsiPassThrough) - 1] of Byte; 
    sptwb: TScsiPassThroughWithBuffers absolute Buffer; 
begin 
    Result := ''; 
    sDeviceName := 'C:'; 
    hDevice := CreateFile(PChar('\\.\' + sDeviceName), GENERIC_READ or GENERIC_WRITE, 
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0); 
 
    if hDevice = INVALID_HANDLE_VALUE then Exit; 
    try 
        FillChar(Buffer, SizeOf(Buffer), #0); 
        with sptwb.spt do begin 
            Length := SizeOf(TScsiPassThrough); 
            CdbLength := 6; // CDB6GENERIC_LENGTH 
            SenseInfoLength := 24; 
            DataIn := 1; // SCSI_IOCTL_DATA_IN 
            DataTransferLength := 192; 
            TimeOutValue := 2; 
            DataBufferOffset := PChar(@sptwb.bDataBuf) - PChar(@sptwb); 
            SenseInfoOffset := PChar(@sptwb.bSenseBuf) - PChar(@sptwb); 
            Cdb[0] := $12; //	OperationCode := SCSIOP_INQUIRY; 
            Cdb[1] := $01; //	Flags := CDB_INQUIRY_EVPD;  Vital product data 
            Cdb[2] := $80; //	PageCode            Unit serial number 
            Cdb[4] := 192; // AllocationLength 
        end; 
        len := sptwb.spt.DataBufferOffset + sptwb.spt.DataTransferLength; 
        if DeviceIoControl(hDevice, $0004D004, @sptwb, SizeOf(TScsiPassThrough), @sptwb, len, dwReturned, nil) and ((PChar(@sptwb.bDataBuf) + 1)^ = #$80) then 
            SetString(Result, PChar(@sptwb.bDataBuf) + 4, Ord((PChar(@sptwb.bDataBuf) + 3)^)); 
        Result := Trim(Result); 
    finally 
        CloseHandle(hDevice); 
    end; 
end; 
 
function GetHddSerialNumber: string; 
begin 
    Result := GetIdeDiskSerialNumber; 
 
    if Length(Result) = 0 then //������������ǰ��׺�ո� 
    begin 
        Result := GetScsiDiskSerialNumber; 
        if Length(Result) = 0 then Result := '' 
        else Result := '[SCSI]' + Result; 
    end 
    else Result := '[IDE]' + Result; 
 
end; 
 
end. 
 








