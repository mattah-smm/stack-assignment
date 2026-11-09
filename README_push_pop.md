# push_pop.asm — Basic PUSH / POP and RSP Tracking

## What this program does

`push_pop.asm` is the simplest possible demonstration of the call stack. It
pushes three 64-bit values onto the stack, pops them back off into registers,
and finally exits with a status code that proves the stack pointer returned to
its original value.

## Stack concepts shown

- `PUSH reg` decrements **RSP by 8** and stores the register's value at the new
  `[RSP]`.
- `POP reg` loads the value at `[RSP]` into the register and then **increments
  RSP by 8**.
- The stack is **LIFO** (Last-In, First-Out): the last value pushed is the first
  one popped.
- A balanced sequence of pushes and pops restores RSP to its starting value.

## Execution flow, step by step

1. **`mov r12, rsp`** — The very first instruction saves the initial stack
   pointer into `r12`. This is our reference point. At program start RSP points
   to the top of the stack (the lowest valid stack address), and the stack is
   empty as far as our program is concerned.

2. **Load and push `0x1111...1111`**
   - `mov rax, 0x1111111111111111`
   - `push rax` → RSP becomes `r12 - 8`, and `[RSP]` now holds `0x1111...`.

3. **Load and push `0x2222...2222`**
   - `push rax` → RSP becomes `r12 - 16`, `[RSP]` = `0x2222...`.
   - The previous value `0x1111...` is still sitting at `r12 - 8`, just below
     the new top.

4. **Load and push `0x3333...3333`**
   - `push rax` → RSP becomes `r12 - 24`, `[RSP]` = `0x3333...`.

   After the three pushes the stack (from low to high address) looks like:

   | Address        | Contents          |
   |----------------|-------------------|
   | `r12 - 24` (top, = RSP) | `0x3333...` |
   | `r12 - 16`    | `0x2222...`       |
   | `r12 - 8`     | `0x1111...`       |
   | `r12`         | (original top)    |

5. **`pop r13`** → reads `[RSP]` (`0x3333...`) into `r13`, then RSP += 8 →
   RSP = `r12 - 16`.

6. **`pop r14`** → reads `0x2222...` into `r14`, RSP = `r12 - 8`.

7. **`pop r15`** → reads `0x1111...` into `r15`, RSP = `r12` (back to start).

8. **Balance check**
   - `mov rax, r12` / `sub rax, rsp` → `rax = r12 - rsp = 0`.
   - This value is moved into `rdi` as the exit code.

9. **`syscall` (sys_exit, rax = 60)** — the process terminates.

## Observations from running

```
=== Running push_pop ===
exit code: 0
```

- The exit code is **0**, which is exactly `r12 - rsp` after the three pops.
  This confirms that the three pushes (24 bytes total) were perfectly undone by
  the three pops, and **RSP returned to its original value**.
- The registers ended up holding the popped values in reverse push order
  (`r13 = 0x3333...`, `r14 = 0x2222...`, `r15 = 0x1111...`), illustrating LIFO
  behavior.

## Key takeaway

Every `PUSH` must be matched by a `POP` (or an explicit `add rsp, 8` per slot)
if you want RSP to end up where it started. This program shows the balanced
pattern in its purest form.
