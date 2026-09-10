; ============================================
; Main Entry Point....
; ============================================

global main

; Window
extern Window_start

section .text

; ------------------------
; Main
; ------------------------
main:
    push rbp
    mov rbp, rsp
    sub rsp, 32

    ; Start Window
    call Window_start

    mov rsp, rbp
    pop rbp
    ret
