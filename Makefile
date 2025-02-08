# Makefile

.PHONY: all setup format format-check

# Default target
all: setup

# Run setup.sh
setup:
	bash setup.sh

# Run cairo-format inplace
format:
	source ./venv/bin/activate && cairo-format -i *.cairo

# Run cairo-format check
format-check:
	source ./venv/bin/activate && cairo-format -c *.cairo
