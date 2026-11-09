# 07_stack — Stack Operation Demonstrations in x86-64 Assembly

This folder contains four small NASM (x86-64, Linux) programs that demonstrate
how the **call stack** works, from the simplest push/pop pair up to a full
function-call stack frame.

Each program is self-contained, builds with `nasm` + `ld`, and exits with a
status code that serves as an observable check of the stack behavior. Each has
its own `README_*.md` explaining the stack flow instruction by instruction.

## Programs

| Program               | Exit code | What it shows                                                      | README                  |
|-----------------------|-----------|--------------------------------------------------------------------|-------------------------|
| `push_pop.asm`        | 0         | Basic PUSH/POP and RSP tracking; stack balances to its start.      | README_push_pop.md      |
| `stack_arithmetic.asm`| 42        | Using the stack as scratch storage; swap via push/pop, then add.   | README_stack_arithmetic.md |
| `stack_frame.asm`     | 12        | A real function call: prologue, frame pointer, locals, epilogue, RET. | README_stack_frame.md   |
| `stack_reversed.asm`  | 10        | LIFO reversal: push 10,20,30,40 and pop them out in reverse.       | README_stack_reversed.md |

## Build and run

From this directory:

```
make run
```

This assembles and links every `.asm` file with NASM, then runs each program
and prints its exit code. To build without running, use `make`; to remove all
build artifacts, use `make clean`.

Manual build for a single program:

```
nasm -f elf64 push_pop.asm -o push_pop.o
ld push_pop.o -o push_pop
./push_pop; echo "exit code: $?"
```

## Stack facts used throughout

- The stack grows **downward** toward lower addresses. `PUSH reg` does
  `RSP -= 8; [RSP] = reg`. `POP reg` does `reg = [RSP]; RSP += 8`.
- The stack is **LIFO**: the last value pushed is the first popped.
- A **balanced** sequence of pushes and pops leaves RSP unchanged.
- In a function frame, **RBP** is the fixed anchor: arguments are at positive
  offsets above it, locals at negative offsets below it. The prologue is
  `push rbp; mov rbp, rsp`; the epilogue is `mov rsp, rbp; pop rbp` (or
  `leave`), followed by `ret` which pops the return address.
