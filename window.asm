default rel

extern GetModuleHandleA
extern RegisterClassExA
extern CreateWindowExA
extern ShowWindow
extern UpdateWindow
extern GetMessageA
extern TranslateMessage
extern DispatchMessageA
extern DefWindowProcA
extern PostQuitMessage
extern DestroyWindow
extern MessageBoxA

global Window_init
global Window_close
global Window_clear
global Window_update
global Window_run
global Window_shouldClose
global Window_start

CS_HREDRAW equ 0x0002
CS_VREDRAW equ 0x0001
WS_OVERLAPPEDWINDOW equ 0x00CF0000
SW_SHOWNORMAL equ 0x0001
WM_DESTROY equ 0x0002
NULL equ 0

section .data
    CLASS_NAME db 'Window', 0
    WINDOW_TITLE db 'window', 0

    WINDOW_WIDTH equ 800
    WINDOW_HEIGHT equ 600

    ERROR_MSG db 'Window creation failed!', 0
    ERROR_TITLE db 'Error', 0

section .bss
    hInstance resq 1
    hwnd resq 1
    msg resb 48
    shouldClose resb 1

section .text

; ------------------------
; Init
; ------------------------
Window_init:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Get Instance
    xor rcx, rcx
    call GetModuleHandleA
    mov [hInstance], rax

    ; Register Class
    sub rsp, 80

    ; Clear structure
    mov rdi, rsp
    xor eax, eax
    mov rcx, 20
    rep stosd

    ; Fill Window Class
    mov rdi, rsp
    mov dword [rdi + 0], 80 ; cbSize
    mov dword [rdi + 4], CS_HREDRAW | CS_VREDRAW ; style

    lea rax, [rel WndProc]
    mov qword [rdi + 8], rax ; lpfnWndProc
    mov dword [rdi + 16], 0 ; cbClsExtra
    mov dword [rdi + 20], 0 ; cbWndExtra
    
    mov rax, [hInstance]
    mov qword [rdi + 24], rax ; hInstance
    mov qword [rdi + 32], 0 ; hIcon
    mov qword [rdi + 40], 0 ; hCursor
    mov qword [rdi + 48], 0 ; hbrBackground
    mov qword [rdi + 56], 0 ; lpszMenuName

    lea rax, [rel CLASS_NAME]
    mov qword [rdi + 64], rax ; lpszClassName
    mov qword [rdi + 72], 0 ; hIconSm

    mov rcx, rdi
    call RegisterClassExA
    add rsp, 80
    cmp eax, 0
    je .error

    ; Create Window
    sub rsp, 80
    xor rcx, rcx ; dwExStyle
    lea rdx, [CLASS_NAME] ; lpClassName
    lea r8, [WINDOW_TITLE] ; lpWindowName
    mov r9, WS_OVERLAPPEDWINDOW ; dwStyle

    mov qword [rsp + 32], 0 ; X
    mov qword [rsp + 40], 0 ; Y
    mov qword [rsp + 48], WINDOW_WIDTH ; Width
    mov qword [rsp + 56], WINDOW_HEIGHT ; Height
    mov qword [rsp + 64], NULL ; hWndParent
    mov qword [rsp + 72], NULL ; hMenu

    mov rax, [hInstance]
    mov qword [rsp + 80], rax ; hInstance
    mov qword [rsp + 88], NULL ; lpParam

    call CreateWindowExA
    add rsp, 80
    cmp rax, 0
    je .error
    mov [hwnd], rax

    ; Show Window
    mov rcx, [hwnd]
    mov rdx, SW_SHOWNORMAL
    call ShowWindow

    mov rcx, [hwnd]
    call UpdateWindow

    mov byte [shouldClose], 0
    mov eax, 1
    mov rsp, rbp
    pop rbp
    ret

;
; Window Error
;
.error:
    xor rcx, rcx
    lea rdx, [ERROR_MSG]
    lea r8, [ERROR_TITLE]
    mov r9, 0
    call MessageBoxA
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret

; ------------------------
; Run
; ------------------------
Window_run:
    push rbp
    mov rbp, rsp
    sub rsp, 32

;
; Message Loop
;
.messageLoop:
    mov rcx, msg
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    call GetMessageA

    cmp eax, 0
    je .exitMessageLoop

    mov rcx, msg
    call TranslateMessage

    mov rcx, msg
    call DispatchMessageA

    jmp .messageLoop

;
; Exit Message Loop
;
.exitMessageLoop:
    mov rsp, rbp
    pop rbp
    ret

; ------------------------
; Close
; ------------------------
Window_close:
    push rbp
    mov rbp, rsp

    mov rcx, [hwnd]
    call DestroyWindow

    pop rbp
    ret

;
; Should Close
;
Window_shouldClose:
    push rbp
    mov rbp, rsp

    movzx eax, byte [shouldClose]
    pop rbp
    ret

; ------------------------
; Clear
; ------------------------
Window_clear:
    push rbp
    mov rbp, rsp

    pop rbp
    ret

; ------------------------
; Update
; ------------------------
Window_update:
    push rbp
    mov rbp, rsp

    pop rbp
    ret

; ------------------------
; Start
; ------------------------
Window_start:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Init
    call Window_init
    cmp eax, 0
    je .error

    ; Run
    call Window_run

    ; Close
    call Window_close

    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret

;
; Error
;
.error:
    mov eax, 1
    mov rsp, rbp
    pop rbp
    ret

; ------------------------
; Window Procedure
; ------------------------
WndProc:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    mov [rsp + 0], rcx
    mov [rsp + 8], rdx
    mov [rsp + 16], r8
    mov [rsp + 24], r9

    cmp edx, WM_DESTROY
    je .onDestroy

    mov rcx, [rsp + 0]
    mov rdx, [rsp + 8]
    mov r8, [rsp + 16]
    mov r9, [rsp + 24]
    call DefWindowProcA
    jmp .finish

;
; On Destroy
;
.onDestroy:
    mov byte [shouldClose], 1
    xor rcx, rcx
    call PostQuitMessage
    xor eax, eax

;
; Finish
;
.finish:
    mov rsp, rbp
    pop rbp
    ret