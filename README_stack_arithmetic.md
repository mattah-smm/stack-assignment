# stack_arithmetic.asm — Using the Stack as Scratch Storage

## What this program does

`stack_arithmetic.asm` uses `PUSH`/`POP` as a way to **temporarily save and
restore registers** while performing arithmetic. It takes two values (30 and
12), swaps them using only the stack, adds them, and exits with the sum (42).

## Stack concepts shown

- The stack can be used as **temporary scratch space** for register values, not
  just for function arguments.
- `PUSH`/`POP` pairs let you preserve a register's value across code that needs
  to reuse that same register.
- The classic **"swap via the stack"** trick: push A, push B, pop into A, pop
  into B — and A/B have exchanged values.

## Execution flow, step by step

1. **`mov r12, rsp`** — save the entry stack pointer as a reference.

2. **Set up two values**
   - `mov rax, 30` (call it A)
   - `mov rbx, 12` (call it B)

3. **Save both onto the stack**
   - `push rax` → RSP = `r12 - 8`,  `[RSP]` = 30 (A)
   - `push rbx` → RSP = `r12 - 16`, `[RSP]` = 12 (B)

   Stack (low→high): `B(12)`, `A(30)`, `(original top)`.

4. **Pop them back** (this round is just save/restore, order is unchanged)
   - `pop rbx` → rbx = 12, RSP = `r12 - 8`
   - `pop rax` → rax = 30, RSP = `r12`

   After this, `rax = 30` and `rbx = 12` again — same as before, and RSP is
   balanced.

5. **Swap the two values using the stack**
   - `push rax` → RSP = `r12 - 8`,  `[RSP]` = 30 (A)
   - `push rbx` → RSP = `r12 - 16`, `[RSP]` = 12 (B)
   - `pop rax`  → rax = 12 (B), RSP = `r12 - 8`
   - `pop rbx`  → rbx = 30 (A), RSP = `r12`

   Because the stack is LIFO, the second push (B) is the first pop, so `rax`
   receives B and `rbx` receives A. The two registers are now swapped, with no
   third register needed. RSP is back to `r12`.

6. **Add them**
   - `add rbx, rax` → rbx = 30 + 12 = **42**.

7. **Balance check**
   - `mov rax, r12` / `sub rax, rsp` → `rax = 0` (stack balanced).

8. **Exit with the sum**
   - `mov rdi, rbx` (exit code = 42)
   - `mov rax, 60` / `syscall` → sys_exit.

## Observations from running

```
=== Running stack_arithmetic ===
exit code: 42
```

- The exit code is **42**, which is `30 + 12`. This confirms the swap worked:
  after the stack-based swap `rbx` held 30 and `rax` held 12, and `add rbx, rax`
  produced 42.
- Although the stack was used four times (two pushes, two pops in the swap
  step), RSP returned to its entry value every time a push/pop pair completed.
  At no point after a balanced pair was RSP left displaced.

## Key takeaway

When you need a register for something else but don't want to lose its current
value, push it, do your work, and pop it back. The swap trick
(`push A; push B; pop A; pop B`) is the smallest useful example of treating the
stack as a LIFO buffer for register contents.
