use16
org 7c00h
start:
    cli
    mov ax, cs 
    mov ss, ax   
    mov ds, ax
    mov es, ax
    mov sp, 7bFFh
    sti
    push dx    
    CLD
    mov si, 7c00h
    mov di, 7e00h
    mov cx, 200h
    rep movsb
    call count
    jmp bx
    
    ;просим ввести пароль 
ent:  
    mov ah,00h
    mov al, 3
    int 10h
    mov ah,02h
    xor dx,dx
    int 10h
    mov ah, 0Ah
    xor bx, bx
    mov cx, 1
    mov si, mess
    xor dx, dx
;цикл вывода сообщения
output:
    lodsb  
    test al, al
    jz read
    int 10h
    
    push ax
    mov ah, 02h
    inc dl
    int 10h
    pop ax
    jmp output 
;цикл ввода пароля  (4 символа - временно)  
read:    
    mov cx,4
    mov bx,password_in
    pass_read:
      mov ah, 00h
      int 16h
      cmp al, 13
      je ent
      mov [bx], al
      inc bx 
      push bx
      push cx
      xor bx,bx
      mov ah, 0ah
      mov cx,1
      mov al, '*'
      int 10h
      pop cx
      mov ah,02h
      inc dl
      int 10h
      pop bx
    loop pass_read
    mov ah, 00h
    int 16h
    cmp al,13
    jne ent
;цикл сравнения введеного пароля с исходным    
    mov bx,password_in
    mov dx, password
    mov cx,4
    compare:    
      push bx
      mov bx, dx
      mov al, [bx]
      pop bx
      cmp [bx], al
      jne ent
      inc bx
      inc dx
    loop compare
     
    mov ah, 02h
    mov al, 01h
    mov bx, 7c00h
    pop dx
    mov dh, 00h
    mov ch, 00h
    mov cl, 02h	
    int 13h
    
    
    jmp bx
password_in db 4 dup(?)
mess db "Enter the password: ", 0
    
count:
    pop ax
    mov bx, ax
    add bx, 202h
    push ax
    ret    
db (506 - ($-start)) dup(0)
password:
db 6 dup(0)                  