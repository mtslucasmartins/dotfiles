.PHONY: help install install-work test

# Optional, forwarded to tests/run_tests.sh:
#   TARGET=ubuntu:24,ubuntu:26   targets to test (default: all)
#   WORKTREE=1                   include uncommitted changes
#   ENTRY="./install work"       install command (default: ./install)
#   DEBUG=1                      open a shell in the container afterwards
TEST_ARGS = $(if $(TARGET),--target=$(TARGET)) \
            $(if $(WORKTREE),--worktree) \
            $(if $(ENTRY),--entry="$(ENTRY)") \
            $(if $(DEBUG),--shell)

help:
	@echo 'make install        public + personal layers'
	@echo 'make install-work   also the PicPay work layer'
	@echo 'make test [TARGET=ubuntu:24,ubuntu:26] [WORKTREE=1] [ENTRY="cmd"] [DEBUG=1]'

test:
	@tests/run_tests.sh $(TEST_ARGS)

install:
	@./install

install-work:
	@./install work
