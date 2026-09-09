; ============================================
; Main Entry Point....
; ============================================

global _start

; Window
extern Window_init
extern Window_close
extern Window_clear
extern Window_update
extern Window_getEvent
extern Window_shouldClose

section .bss
    running: resb 1

section .text

; ------------------------
; Start
; ------------------------
_start:
    ; Init Window
    call Window_init
    cmp eax, 0
    je .error_exit

    ; Running
    mov byte [running], 1

    ; Clear Window
    call Window_clear
    call Window_update

; ------------------------
; Run
; ------------------------
.run:
    ; Check
    call Window_shouldClose
    cmp eax, 1
    je .cleanup

    ; Process Events
    call Window_getEvent

    jmp .run

; ------------------------
; Cleanup
; ------------------------
.cleanup:
    call Window_close
    mov eax, 0x1
    xor ebx, ebx
    int 0x80

;
; Error
;
.error_exit:
    mov eax, 0x1
    mov ebx, 0x1
    int 0x80


