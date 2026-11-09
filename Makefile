ASMS = push_pop stack_arithmetic stack_frame stack_reversed
OBJS = $(addsuffix .o,$(ASMS))

all: $(ASMS)

%: %.asm
	nasm -f elf64 $< -o $@.o
	ld $@.o -o $@

run: all
	@for prog in $(ASMS); do \
	  echo "=== Running $$prog ==="; \
	  ./$$prog; \
	  echo "exit code: $$?"; \
	  echo; \
	done

clean:
	rm -f $(OBJS) $(ASMS)

.PHONY: all run clean
