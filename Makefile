# Toolchain variables
SIM = iverilog
VVP = vvp
FLAGS = -g2012 # Support SystemVerilog standard

# Design files
SRC = src/axi4_lite_master.v src/axi4_lite_slave.v src/register.v

# Output compilation binaries
OUT1 = check1.out
OUT2 = check2.out
OUT3 = check3.out
OUT4 = check4.out

# Simulation waveform outputs
VCD1 = waveform.vcd
VCD2 = waveform2.vcd
VCD3 = waveform3.vcd
VCD4 = waveform4.vcd

.PHONY: all test1 test2 test3 test4 clean

# Compile all tests
all: $(OUT1) $(OUT2) $(OUT3) $(OUT4)

# Target for Test 1
$(OUT1): $(SRC) tests/test1.sv
	$(SIM) $(FLAGS) $(SRC) tests/test1.sv -o $(OUT1)

test1: $(OUT1)
	$(VVP) $(OUT1)

# Target for Test 2
$(OUT2): $(SRC) tests/test2.sv
	$(SIM) $(FLAGS) $(SRC) tests/test2.sv -o $(OUT2)

test2: $(OUT2)
	$(VVP) $(OUT2)

# Target for Test 3
$(OUT3): $(SRC) tests/test3.sv
	$(SIM) $(FLAGS) $(SRC) tests/test3.sv -o $(OUT3)

test3: $(OUT3)
	$(VVP) $(OUT3)

# Target for Test 4
$(OUT4): $(SRC) tests/test4.sv
	$(SIM) $(FLAGS) $(SRC) tests/test4.sv -o $(OUT4)

test4: $(OUT4)
	$(VVP) $(OUT4)
# Clean build artifacts
clean:
	rm -f $(OUT1) $(OUT2) $(OUT3) $(OUT4) $(VCD1) $(VCD2) $(VCD3) $(VCD4)
