; stack_arithmetic.asm
; Uses the stack as scratch storage to swap two values and compute a sum.
; Demonstrates that PUSH/POP can be used for temporary save/restore of
; registers around a calculation, not just for passing arguments.
; Build: nasm -f elf64 stack_arithmetic.asm -o stack_arithmetic.o && ld stack_arithmetic.o -o stack_arithmetic

global _start

section .text
_start:
    mov r12, rsp           ; remember initial RSP

    ; two values we want to swap and add
    mov rax, 30            ; "A"
    mov rbx, 12            ; "B"

    ; save both onto the stack (A pushed first, then B)
    push rax               ; RSP -= 8,  [RSP] = 30
    push rbx               ; RSP -= 8,  [RSP] = 12

    ; we need rbx for something else, so reclaim it from the stack
    pop rbx                ; rbx = 12 (the last pushed), RSP += 8
    pop rax                ; rax = 30,  RSP += 8

    ; Now swap: put B into rax and A into rbx using the stack
    push rax               ; save A,   RSP -= 8
    push rbx               ; save B,   RSP -= 8
    pop rax                ; rax = B = 12, RSP += 8
    pop rbx                ; rbx = A = 30, RSP += 8

    ; add them: 30 + 12 = 42
    add rbx, rax           ; rbx = 30 + 12 = 42

    ; prove the stack is balanced
    mov rax, r12
    sub rax, rsp           ; should be 0

    ; exit code = the sum (42)
    mov rdi, rbx           ; exit code 42
    mov rax, 60
    syscall
