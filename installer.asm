format PE Console 4.0
entry Start
 
include 'win32a.inc'
 
Start:
  invoke CreateFile, DEVICE_NAME, GENERIC_WRITE + GENERIC_READ, FILE_SHARE_WRITE + FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
  mov word [HANDLE], ax
  ;;deinstall start
  invoke SetFilePointer, [HANDLE], 0, NULL, FILE_BEGIN 
  invoke ReadFile, [HANDLE], BUF, 512, nSIZE, 0
  
  invoke SetFilePointer, [HANDLE], 0, NULL, FILE_BEGIN 
  invoke WriteFile, [HANDLE], BUF, 512, nSIZE, 0
  ;;deinstall end
  invoke ReadFile, [HANDLE], BUF, 512, nSIZE, 0
  
  invoke SetFilePointer, [HANDLE], 512, NULL, FILE_BEGIN 
  invoke WriteFile, [HANDLE], BUF, 512, nSIZE, 0
  
  invoke CreateFile, nFile, GENERIC_READ, FILE_SHARE_READ, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
  mov word [hFile], ax
  invoke ReadFile, [hFile], LOADER, 512, nSIZE, 0
  invoke CloseHandle, [hFile]
;BUF[443] -> LOADER[443]
  mov cx,69
  mov esi,443
  copy:
  mov al, [BUF+esi]
  mov [LOADER+esi], al
  inc bx
  inc esi
  cmp cx, 0
  jz off
  loop copy
off:  
  ;выводим запрос на ввод пароля
  invoke AllocConsole
  invoke GetStdHandle, STD_OUTPUT_HANDLE
  mov [stdout], eax
  invoke WriteConsole, [stdout], mess, 32, nSIZE, 0
  ;вводим пароль и сохраняем его в буфер(4 символа - временно)    
  invoke GetStdHandle, STD_INPUT_HANDLE
  mov [stdin], eax
  invoke ReadConsole, [stdin], LOADER+506, 4, nSIZE
  
  invoke SetFilePointer, [HANDLE], 0, NULL, FILE_BEGIN
  invoke WriteFile, [HANDLE], LOADER, 512, nSIZE, 0
  
  invoke CloseHandle, [HANDLE]
     
Exit:
  invoke  ExitProcess, 0
DEVICE_NAME db "\\.\PhysicalDrive0", 0
HANDLE dd ?
nSIZE dd 512
BUF RB 512
mess db 'Enter the password (4 symbols): ', 0
password db 4 dup(?)
hFile dd ?
nFile db 'loader.bin', 0
LOADER RB 512
stdout dd ?
stdin dd ?
 
data import
 library kernel32, 'kernel32.dll'
  import kernel32,\
    ExitProcess, 'ExitProcess',\
    CreateFile, 'CreateFileA',\
    ReadFile, 'ReadFile',\
    WriteFile, 'WriteFile',\
    GetLastError, 'GetLastError',\
    SetFilePointer, 'SetFilePointer',\
    CloseHandle, 'CloseHandle',\
    WriteConsole, 'WriteConsoleA',\ 
    ReadConsole, 'ReadConsoleA',\ 
    GetStdHandle, 'GetStdHandle',\
    AllocConsole, 'AllocConsole'
end data