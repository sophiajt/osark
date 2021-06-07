bits 16
org	0x7c00

call clear_black
call disk_reset
call disk_load
call clear_red
jmp 0x80:0x100

disk_reset:
    mov ah,0x0
    int 0x13
    ret

clear_black:
    mov ah, 0x07        ; tells BIOS to scroll down window
    mov al, 0x00        ; clear entire window
    mov bh, 0x07            ; white on black
    mov cx, 0x00        ; specifies top left of screen as (0,0)
    mov dh, 0x18        ; 18h = 24 rows of chars
    mov dl, 0x4f        ; 4fh = 79 cols of chars
    int 0x10        ; calls video interrupt
    ret

clear_red:
    mov ah, 0x07        ; tells BIOS to scroll down window
    mov al, 0x00        ; clear entire window
    mov bh, 0x37            ; white on black
    mov cx, 0x00        ; specifies top left of screen as (0,0)
    mov dh, 0x18        ; 18h = 24 rows of chars
    mov dl, 0x4f        ; 4fh = 79 cols of chars
    int 0x10        ; calls video interrupt
    ret

disk_load:
    pusha

    mov ax, 0x80
    mov es, ax

    mov bx, 0x100 ; try loading in 
    mov ah, 0x02 ; read mode
    mov al, 0x03 ; number of sectors for menu
    mov cl, 0x04 ; start from sector 4
                 ; (as sector 1 is our boot sector)
    mov ch, 0x00 ; cylinder 0
    mov dh, 0x00 ; head 0
    mov dl, 0x00 ; disk 0

    ; dl = drive number is set as input to disk_load
    ; es:bx = buffer pointer is set as input as well

    int 0x13      ; BIOS interrupt

    jc disk_error ; check carry bit for error
    call clear_red

    popa
    ret

disk_error:
    mov ah, 0x07        ; tells BIOS to scroll down window
    mov al, 0x00        ; clear entire window
    mov bh, 0x17            ; white on blue
    mov cx, 0x00        ; specifies top left of screen as (0,0)
    mov dh, 0x18        ; 18h = 24 rows of chars
    mov dl, 0x4f        ; 4fh = 79 cols of chars
    int 0x10        ; calls video interrupt
    jmp disk_loop

sectors_error:
    mov ah, 0x07        ; tells BIOS to scroll down window
    mov al, 0x00        ; clear entire window
    mov bh, 0x27            ; white on ???
    mov cx, 0x00        ; specifies top left of screen as (0,0)
    mov dh, 0x18        ; 18h = 24 rows of chars
    mov dl, 0x4f        ; 4fh = 79 cols of chars
    int 0x10        ; calls video interrupt
    jmp disk_loop

disk_loop:
    jmp $


times	510-($-$$)	db	0	; fill file with 0 until 510 
dw	0xaa55 
