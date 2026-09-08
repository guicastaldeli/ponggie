global _start

section .data
    align 2
    hello: db 'Hello World!', 0xa
    helloLen: equ $-hello

    pressMsg: db 'Press any key to exit!...', 0xa
    pressLen: equ $-pressMsg

section .bss
    buffer: resb 1
    termios: resb 36
    old_termios: resb 36

section .text
    _start:
        ; Hello World
        mov eax, 0x4
        mov ebx, 0x1
        mov ecx, hello
        mov edx, helloLen
        int 0x80

        ; Press Message
        mov eax, 0x4
        mov ebx, 0x1
        mov ecx, pressMsg
        mov edx, pressLen
        int 0x80

        ; Current Terminal
        mov eax, 0x36
        mov ebx, 0x0
        mov ecx, 0x5401
        mov edx, termios
        int 0x80

        ; Save
        mov esi, termios
        mov edi, old_termios
        mov ecx, 36
        rep movsb

        ; Clear Flags
        mov eax, [termios + 12]
        and eax, ~(1 << 1)
        and eax, ~(1 << 3)
        mov [termios + 12], eax

        ; Apply
        mov eax, 0x36
        mov ebx, 0x0
        mov ecx, 0x5402
        mov edx, termios
        int 0x80

        ; Read char
        mov eax, 0x3
        mov ebx, 0x0
        mov ecx, buffer
        mov edx, 0x1
        int 0x80

        ; Restore
        mov eax, 0x36
        mov ebx, 0x0
        mov ecx, 0x5402
        mov edx, old_termios
        int 0x80

        ; Exit
        mov eax, 0x1
        xor ebx, ebx
        int 0x80