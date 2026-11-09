# stack_frame.asm — Function Calls and Stack Frames

## What this program does

`stack_frame.asm` demonstrates a real **function call**. `_start` pushes two
arguments onto the stack, `call`s a subroutine `add_numbers`, which sets up a
proper **stack frame** with `PUSH RBP` / `MOV RBP, RSP`, reserves space for
local variables, computes the sum of the arguments, tears the frame down with
an epilogue, and returns. The program exits with the result (12).

## Stack concepts shown

- **Arguments passed on the stack** (classic cdecl-style calling convention).
- The `CALL` instruction automatically **pushes the return address** onto the
  stack (RSP -= 8) before jumping.
- The **prologue** `push rbp` / `mov rbp, rsp` establishes a frame base pointer
  so arguments and locals can be referenced as fixed offsets from `RBP` even as
  `RSP` moves.
- **Local variables** live below `RBP` at negative offsets
  (`[rbp-8]`, `[rbp-16]`, ...), while arguments live above `RBP` at positive
  offsets (`[rbp+16]`, `[rbp+24]`, ...). The return address sits at `[rbp+8]`.
- The **epilogue** `mov rsp, rbp` / `pop rbp` (or `LEAVE`) restores RSP and RBP,
  and `RET` pops the return address back into RIP.

## Execution flow, step by step

### In `_start`

1. **`mov r12, rsp`** — remember the program's entry stack pointer.

2. **Push the two arguments**
   - `mov rax, 7` / `push rax`  → RSP = `r12 - 8`,  `[RSP]` = 7  (arg2)
   - `mov rax, 5` / `push rax`  → RSP = `r12 - 16`, `[RSP]` = 5  (arg1)

   By convention the **first** argument ends up at the **lowest** address, so
   it is the last one pushed.

3. **`call add_numbers`**
   - The CPU pushes the **return address** (the address of the instruction right
     after `call`) onto the stack: RSP = `r12 - 24`, `[RSP]` = return addr.
   - Execution jumps to `add_numbers`.

   Stack at the moment `add_numbers` begins (low → high):

   | Address      | Contents        |
   |--------------|-----------------|
   | `r12 - 24` (RSP) | return address |
   | `r12 - 16`  | arg1 = 5        |
   | `r12 - 8`   | arg2 = 7        |
   | `r12`       | (original top)  |

### Inside `add_numbers`

4. **Prologue**
   - `push rbp` → saves the caller's RBP. RSP = `r12 - 32`.
   - `mov rbp, rsp` → `RBP = r12 - 32`. From now on we reference everything
     relative to RBP, because RSP will keep moving while RBP stays fixed.

   New layout relative to RBP:

   | Offset from RBP | Contents        |
   |-----------------|-----------------|
   | `+24`           | arg2 = 7        |
   | `+16`           | arg1 = 5        |
   | `+8`            | return address  |
   | `0`             | saved RBP       |
   | `-8`            | local "sum"     |
   | `-16`           | local "temp"    |

5. **Reserve locals**
   - `sub rsp, 16` → RSP = `r12 - 48`. The 16 bytes below RBP are now available
     for two 8-byte local variables. RSP has moved, but RBP has not, so the
     argument offsets (`+16`, `+24`) are still valid.

6. **Read arguments via RBP and add**
   - `mov rax, [rbp+16]` → rax = arg1 = 5
   - `mov rcx, [rbp+24]` → rcx = arg2 = 7
   - `add rax, rcx`      → rax = 12
   - `mov [rbp-8], rax`  → store 12 into the local "sum"

7. **Load the result into RAX for return**
   - `mov rax, [rbp-8]` → rax = 12 (the return-value register).

8. **Epilogue**
   - `mov rsp, rbp` → RSP = `r12 - 32`. This **discards the local variables in
     one move** — no matter how many bytes of locals were allocated, restoring
     RSP from RBP cleans them all up.
   - `pop rbp` → restores the caller's RBP, RSP = `r12 - 24` (now pointing at
     the return address again).

9. **`ret`**
   - Pops the return address into RIP: RSP = `r12 - 16`.
   - Execution returns to the instruction right after the `call` in `_start`.

### Back in `_start`

10. **Clean up the arguments**
    - `add rsp, 16` → RSP = `r12`. The two pushed arguments (16 bytes) are
      discarded. The stack is now fully balanced.

11. **Balance check**
    - `mov rbx, r12` / `sub rbx, rsp` → rbx = 0, confirming RSP == entry RSP.

12. **Exit with the result**
    - `mov rdi, rax` (exit code = 12)
    - `mov rax, 60` / `syscall`.

## Observations from running

```
=== Running stack_frame ===
exit code: 12
```

- The exit code is **12**, which is `5 + 7`. The function correctly read its two
  arguments from the stack, stored the sum in a local variable at `[rbp-8]`,
  loaded it back into RAX, and returned it.
- The whole sequence — 2 argument pushes (16 bytes), the `CALL` return-address
  push (8 bytes), the `PUSH RBP` (8 bytes), and 16 bytes of locals — moved RSP
  down by 48 bytes at its deepest. After the epilogue, `RET`, and the caller's
  `add rsp, 16`, RSP returned to exactly its entry value. The stack was
  perfectly balanced.

## Key takeaway

A stack frame gives a function a private, addressable workspace:

- **RBP** is the fixed anchor: arguments are above it (`+` offsets), locals are
  below it (`-` offsets).
- **RSP** moves as you push/pop or allocate locals, but you never lose your
  place because everything is referenced through RBP.
- The epilogue (`mov rsp, rbp; pop rbp`) collapses the whole frame in two
  instructions, and `RET` pops the return address so control flows back to the
  caller. The caller is then responsible for removing any arguments it pushed.
