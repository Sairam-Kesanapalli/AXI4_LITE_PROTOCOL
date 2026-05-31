# Toolchain variables
SIM = iverilog
VVP = vvp
FLAGS = -g2012 # Support SystemVerilog standard

# Design files
SRC = src/axi4_lite_master.v src/axi4_lite_slave.v src/register.v
# Testbench files
TB = tests/test1.sv
# Output compilation binary
OUT = check.out
# Simulation waveform output
VCD = waveform.vcd

.PHONY: all test1 clean

# Default target: compile the design and testbench
all: $(OUT)

$(OUT): $(SRC) $(TB)
	$(SIM) $(FLAGS) $(SRC) $(TB) -o $(OUT)

# Run the compiled simulation for test1
test1: all
	$(VVP) $(OUT)

# Clean build artifacts
clean:
	rm -f $(OUT) $(VCD)
