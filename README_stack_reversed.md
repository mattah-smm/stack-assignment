# stack_reversed.asm — Reversing Order with the LIFO Stack

## What this program does

`stack_reversed.asm` exploits the **LIFO** (Last-In, First-Out) nature of the
stack to reverse the order of four values. It pushes 10, 20, 30, 40 in that
order and then pops them into registers — the first pop returns 40, the last
returns 10.

## Stack concepts shown

- The stack reverses insertion order: whatever you push last comes off first.
- Each `PUSH` lowers RSP by 8 and writes at the new `[RSP]`; each `POP` reads
  `[RSP]` and then raises RSP by 8.
- After a balanced push/pop sequence RSP returns to its starting value.

## Execution flow, step by step

1. **`mov r12, rsp`** — save the entry stack pointer as the reference.

2. **Push four values in ascending order**
   - `mov rax, 10` / `push rax` → RSP = `r12 - 8`,  `[RSP]` = 10
   - `mov rax, 20` / `push rax` → RSP = `r12 - 16`, `[RSP]` = 20
   - `mov rax, 30` / `push rax` → RSP = `r12 - 24`, `[RSP]` = 30
   - `mov rax, 40` / `push rax` → RSP = `r12 - 32`, `[RSP]` = 40

   Stack after all four pushes (low → high address):

   | Address         | Contents |
   |-----------------|----------|
   | `r12 - 32` (RSP, top) | 40 |
   | `r12 - 24`      | 30       |
   | `r12 - 16`      | 20       |
   | `r12 - 8`       | 10       |
   | `r12`           | (original top) |

   RSP is now 32 bytes below its entry value.

3. **Pop the values — order is reversed**
   - `pop r15` → r15 = **40** (the last pushed), RSP = `r12 - 24`
   - `pop r14` → r14 = **30**, RSP = `r12 - 16`
   - `pop r13` → r13 = **20**, RSP = `r12 - 8`
   - `pop rbx` → rbx = **10** (the first pushed), RSP = `r12`

   The registers now hold the original sequence in reverse: `r15, r14, r13, rbx`
   = `40, 30, 20, 10`.

4. **Exit with the last-popped value**
   - `mov rdi, rbx` (exit code = 10)
   - `mov rax, 60` / `syscall` → sys_exit.

## Observations from running

```
=== Running stack_reversed ===
exit code: 10
```

- The exit code is **10**, which is the value that was pushed **first** and
  therefore popped **last**. This is direct evidence of LIFO reversal: the
  4th-pushed value (40) came out first into `r15`, and the 1st-pushed value
  (10) came out last into `rbx`.
- RSP descended by 32 bytes (4 × 8) during the pushes and climbed back up by
  the same 32 bytes during the pops, returning exactly to `r12`.

## Key takeaway

Because the stack grows downward and is accessed only at `[RSP]`, a push-then-
pop sequence is a natural way to **reverse** a series of values: push them in
order, pop them out, and the order is flipped. This is the same property that
makes the stack useful for reversing strings, evaluating postfix expressions,
and implementing backtracking — anywhere you need last-in-first-out ordering.
