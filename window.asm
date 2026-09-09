extern XOpenDisplay
extern XDefaultScreen
extern XCreateSimpleWindow
extern XStoreName
extern XMapWindow
extern XSelectInput
extern XNextEvent
extern XCloseDisplay
extern XClearWindow
extern XFlush
extern XInternAtom
extern XSetWMProtocols

global Window_init
global Window_clear
global Window_update
global Window_close
global Window_shouldClose
global Window_getEvent

section .data
    WINDOW_WIDTH equ 800
    WINDOW_HEIGHT equ 600
    WINDOW_TITLE: db "window", 0

    X_KeyPress: eq 0x02
    X_ClientMessage: eq 0x21

    WM_PROTOCOLS: db "WM_PROTOCOLS", 0
    WM_DELETE_WONDOW: db "WM_DELETE_WINDOW", 0

section .bss
    windowId: resd 1

    display_ptr: resq 1
    screen_num: resd 1

    wm_protols_atom: resd 1
    wm_delete_window_atom: resd 1

    event_struct: resb 512
    
    shouldClose: resb 1

section .text

; ------------------------
; Init
; ------------------------
Window_init:
    push rbp
    mov rbp, rsp

    ; Display
    mov rdi, 0
    call XOpenDisplay
    test rax, rax
    jz .error
    mov [display_ptr], rax

    ; Default Screen
    mov rdi, [display_ptr]
    call XDefaultScreen
    mov [screenNum], eax

    ;
    ; Create Window
    ;
    mov rdi, [display_ptr]
    mov esi, [screen_num]
    mov edx, 0 ; x
    mov ecx, 0 ; y
    mov r8d, WINDOW_WIDTH ; width
    mov r9d, WINDOW_HEIGHT ; height
    push 2 ; border width
    push 0 ; border color
    push 0 ; background color
    call XCreateSimpleWindow
    add rsp, 24
    mov [windowId], eax

    ; Window Title
    mov rdi, [display_ptr]
    mov esi, [windowId]
    lea rdx, [WINDOW_TITLE]
    call XStoreName

    ; Select Events
    mov rdi, [display_ptr]
    mov esi, [windowId]
    mov edx, 0x7FFFFFFF
    call XSelectInput

    ; Set VM Protocols...
    mov rdi, [display_ptr]
    mov esi, [windowId]
    mov rsi, [WM_PROTOCOLS]
    mov edx, 1
    call XInternAtom
    mov [vm_protocols_atom], eax

    mov rdi, [display_ptr]
    lea rsi, [VM_DELETE_WINDOW]
    mov edx, 1
    call XInternAtom
    mov [vm_delete_window_atom], eax

    mov rdi, [display_ptr]
    mov esi, [windowId]
    mov edx, [wm_protocols_atom]
    lea rcx, [vm_delete_window_atom]
    mov r8d, 1
    call XSetVMProtocols

    ; Map Window
    mov rdi, [display_ptr]
    mov esi, [windowId]
    call XMapWindow

    ; Flush Commands
    mov rdi, [display_ptr]
    call XFlush

    ; Should Close
    mov byte [shouldClose], 0

    mov eax, 1
    pop rbp
    ret

.error
    xor eax, eax
    pop rbp
    ret

; ------------------------
; Clear
; ------------------------
Window_clear:
    push rbp
    mov rbp, rsp

    mov rdi, [display_ptr]
    mov esi, [windowId]
    call XClearWindow

    pop rbp
    ret

; ------------------------
; Update
; ------------------------
Window_update:
    push rbp
    mov rbp, rsp

    mov rdi, [display_ptr]
    call XFlush

    pop rbp
    ret

; ------------------------
; Get Event
; ------------------------
Window_getEvent:
    push rbp
    mov rbp, rsp

    mov rdi, [display_ptr]
    lea rsi, [event_struct]
    call XNextEvent

    ; Check Event Type
    xor eax, eax
    mov al, byte [event_struct]

    cmp al, X_ClientMessage
    je .clientMessage

    ; Return Event Type
    pop rbp
    ret

;
; Client Message
;
.clientMessage:
    mov byte [shouldClose], 1
    mov eax, 1
    pop rbp
    ret

; ------------------------
; Should Close
; ------------------------
Window_shouldClose:
    push rbp
    mov rbp, rsp

    movzx eax, byte [shouldClose]
    pop rbp
    ret

;
; Close Window
;
Window_close:
    push rbp
    mov rbp, rsp

    mov rdi, [display_ptr]
    call XCloseDisplay

    pop rdp
    ret
