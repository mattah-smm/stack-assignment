; stack_frame.asm
; Demonstrates a function call: setting up a stack frame with PUSH RBP /
; MOV RBP, RSP, local variables accessed through RBP, and the epilogue
; that restores RSP and RBP (LEAVE / MOV RSP,RBP ; POP RBP).
; Build: nasm -f elf64 stack_frame.asm -o stack_frame.o && ld stack_frame.o -o stack_frame

global _start

section .text
_start:
    mov r12, rsp           ; remember entry RSP for the whole program

    ; pass two arguments to our function via the stack (classic cdecl style)
    mov rax, 7
    push rax              ; argument 2 (pushed first => higher address)
    mov rax, 5
    push rax              ; argument 1 (pushed last  => lower address, [rsp])

    call add_numbers      ; PUSH return address (RSP -= 8), jump to label

    ; after return: rax holds the result (12). Clean up the 2 pushed args.
    add rsp, 16           ; RSP += 16, discarding the two arguments

    ; verify RSP is back to the program-entry value
    mov rbx, r12
    sub rbx, rsp          ; rbx = 0

    ; exit with the result
    mov rdi, rax          ; exit code 12
    mov rax, 60
    syscall

; add_numbers: reads two 64-bit args from the stack and returns their sum in rax.
; Stack layout right after CALL executed:
;     [rsp]     -> return address
;     [rsp+8]   -> arg1 (5)
;     [rsp+16]  -> arg2 (7)
add_numbers:
    push rbp              ; save caller's RBP,          RSP -= 8
    mov  rbp, rsp         ; new frame base = current RSP

    ; Now layout relative to RBP:
    ;     [rbp]     -> saved RBP
    ;     [rbp+8]   -> return address
    ;     [rbp+16]  -> arg1 (5)
    ;     [rbp+24]  -> arg2 (7)

    ; reserve 16 bytes for two local variables
    sub rsp, 16           ; RSP -= 16
    ;     [rbp-8]  -> local "sum"
    ;     [rbp-16] -> local "temp"

    mov rax, [rbp+16]     ; rax = arg1 = 5
    mov rcx, [rbp+24]     ; rcx = arg2 = 7
    add rax, rcx          ; rax = 12
    mov [rbp-8], rax      ; store sum in local var

    ; copy result into rax for the return value
    mov rax, [rbp-8]      ; rax = 12

    ; epilogue: restore RSP from RBP, then pop the saved RBP
    mov rsp, rbp          ; RSP = RBP  (drops the locals)
    pop rbp               ; RSP += 8,  RBP restored

    ret                   ; POP return address into RIP, RSP += 8
