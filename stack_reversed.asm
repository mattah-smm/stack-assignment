; stack_reversed.asm
; Uses the stack's LIFO nature to reverse the order of a small set of values.
; We push 4 numbers in order, then pop them into consecutive registers:
; the first popped is the last pushed, so the order is reversed.
; Build: nasm -f elf64 stack_reversed.asm -o stack_reversed.o && ld stack_reversed.o -o stack_reversed

global _start

section .data
    ; original order: 10, 20, 30, 40
    ; after push-then-pop the registers will hold 40, 30, 20, 10

section .text
_start:
    mov r12, rsp          ; entry RSP

    ; ---- push four values in ascending order ----
    mov rax, 10
    push rax             ; RSP -= 8, [RSP] = 10   (lowest, pushed first)
    mov rax, 20
    push rax             ; RSP -= 8, [RSP] = 20
    mov rax, 30
    push rax             ; RSP -= 8, [RSP] = 30
    mov rax, 40
    push rax             ; RSP -= 8, [RSP] = 40   (top of stack)

    ; RSP is now 32 bytes below r12.

    ; ---- pop them: first pop gets 40, last pop gets 10 ----
    pop r15             ; r15 = 40, RSP += 8
    pop r14             ; r14 = 30, RSP += 8
    pop r13             ; r13 = 20, RSP += 8
    pop rbx             ; rbx = 10, RSP += 8

    ; RSP is back to r12 (stack balanced).

    ; build an exit code that proves the reversal:
    ; the last popped value (10) sits in rbx -> exit code 10
    mov rdi, rbx        ; exit code 10
    mov rax, 60
    syscall
