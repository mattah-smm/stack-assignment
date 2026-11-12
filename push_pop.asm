; push_pop.asm
; Demonstrates basic PUSH and POP operations and how RSP changes.
; Build: nasm -f elf64 push_pop.asm -o push_pop.o && ld push_pop.o -o push_pop

global _start

section .bss
    buf resb 32          ; buffer to hold the printable result

section .text
_start:
    ; ---- record the initial stack pointer ----
    mov r12, rsp          ; r12 = RSP at program start (top of stack)

    ; ---- push three 64-bit values onto the stack ----
    mov rax, 0x1111111111111111
    push rax              ; RSP -= 8,  [RSP] = 0x1111...
    mov rax, 0x2222222222222222
    push rax              ; RSP -= 8,  [RSP] = 0x2222...
    mov rax, 0x3333333333333333
    push rax              ; RSP -= 8,  [RSP] = 0x3333...

    ; RSP is now 24 bytes below r12 (3 * 8).

    ; ---- pop them off in reverse order (LIFO) ----
    pop r13               ; r13 = 0x3333...  RSP += 8
    pop r14               ; r14 = 0x2222...  RSP += 8
    pop r15               ; r15 = 0x1111...  RSP += 8

    ; RSP is back to r12 (the initial value), proving the stack balanced.

    ; ---- compute how far RSP travelled (should be 0) ----
    mov rax, r12
    sub rax, rsp           ; rax = initial - final = 0

    ; ---- exit with that value as the process status ----
    mov rdi, rax           ; exit code = 0
    mov rax, 60            ; syscall: sys_exit
    syscall
