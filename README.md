# AXI4-Lite Master-Slave RTL Core & Verification Suite

This repository contains a high-performance, fully standard-compliant, and latch-free **AMBA AXI4-Lite Protocol Master-Slave IP Core** designed in Verilog, alongside a SystemVerilog verification suite.

---

## 🏛️ System Architecture

The following block diagrams illustrate the modular partitioning of the AXI4-Lite IP Core, showing the interface between the Master FSM, Slave controllers, and the Register File.

### Master-Slave Interconnect Topology
```text
MASTER                          SLAVE
              ┌─────────────┐                  ┌──────────────────┐
 write_en ───>│             │──── AW ─────────>│  Write Logic     │
 read_en  ───>│  Write FSM  │──── W  ─────────>│  (capture AW+W,  │
 addr_in  ───>│  Read FSM   │<─── B  ──────────│   decode, write) │
 wdata_in ───>│             │                  │                  │
              │             │──── AR ─────────>│  Read Logic      │──> accelerator
 rdata_out<───│             │<─── R  ──────────│  (decode, fetch) │
 done     <───│             │                  │                  │
              └─────────────┘                  │  Register File   │
                                               │  [31:0][31:0]    │
                                               └──────────────────┘
```

### Slave Module Internal Structure
```text
┌─────────────────────────────────────────────┐
│              AXI4-Lite Slave                │
│                                             │
│  ┌─────────────┐      ┌──────────────────┐  │
│  │ Write Logic │─────>│                  │  │
│  │ (AW+W+B)    │      │  Register File   │  │
│  └─────────────┘      │  [31:0][31:0]    │  │
│                       │                  │  │
│  ┌─────────────┐      │                  │  │
│  │ Read Logic  │<─────│                  │  │
│  │ (AR+R)      │      └──────────────────┘  │
│  └─────────────┘                            │
└─────────────────────────────────────────────┘
```

---

## 📂 Repository Directory Layout

The project structure is organized as follows:

* 📁 **[src/](src/)**: Core RTL design source files.
  * 📄 `axi4_lite_master.v`: The master interface controller featuring registered inputs, sequential outputs, and independent channel tracking.
  * 📄 `axi4_lite_slave.v`: The slave interface controller managing standard handshaking and address decoding.
  * 📄 `register_file.v`: A 32-deep, 32-bit register file (RF) supporting byte-lane select strobes (`WSTRB`).
* 📁 **[tests/](tests/)**: Verification suites and testbenches.
  * 📄 `test1.sv`: Loopback verification testbench for registers 0 to 11.
  * 📄 `test2.sv`: Comprehensive 32-register loopback verification testbench (registers 0 to 31).
  * 📄 `test3.sv`: Byte-lane write select strobe (`WSTRB`) verification testbench.
  * 📄 `test4.sv`: Out-of-bounds error handling and access violation (`SLVERR`) verification testbench.
* 📄 **[Makefile](Makefile)**: Automation script to compile and run simulation tests.

---

## 🛠️ Verification & Simulation Instructions

You can run, manage, and clean up the simulation directly from the repository root using `make`.

### 1. Compile & Run `test1` Simulation
To compile the core design along with `test1.sv` and execute the simulation:
```bash
make test1
```

### 2. Compile & Run `test2` Simulation
To compile the core design along with `test2.sv` and execute the simulation:
```bash
make test2
```

### 3. Compile & Run `test3` Simulation
To compile the core design along with `test3.sv` and execute the simulation:
```bash
make test3
```

### 4. Compile & Run `test4` Simulation
To compile the core design along with `test4.sv` and execute the simulation:
```bash
make test4
```

### 5. View Waveforms in GTKWave
To view the generated waveforms using GTKWave:
```bash
make view1   # Open test1 waveform (waveform.vcd)
make view2   # Open test2 waveform (waveform2.vcd)
make view3   # Open test3 waveform (waveform3.vcd)
make view4   # Open test4 waveform (waveform4.vcd)
```

### 6. Clean Up Simulation Artifacts
To clean compiled binaries and VCD waveforms:
```bash
make clean
```

---

## 💡 Key Architectural Features

1. **Strict Protocol Compliance**: Drives stable, registered versions of `AWADDR`, `WDATA`, `WSTRB`, and `ARADDR` signals, ensuring they stay perfectly stable until handshakes complete.
2. **Independent Channel Handshakes**: Implements `aw_accepted` and `w_accepted` registers in the master's `AW_W` state. This prevents duplicate transactions or deadlocks even if the slave asserts `AWREADY` and `WREADY` in different clock cycles.
3. **Clean Sequential Boundaries**: Fully sequential implementation of master read data latching (`rdata_out` / `resp_out`) ensuring robust latch-free synthesizable logic.
4. **Race-Free Verification**: Testbench tasks `axi_write` and `axi_read` utilize clock-synchronized delays to prevent active-edge simulation race conditions.

---

## 🧪 Verification Roadmap & Completed Tests

All verification tests are fully implemented, verified, and complete:
* **Test 1: Standard Loopback & Stress Test**: Verifies loopback transactions across registers `0` to `11`, clock-accurate sequential handshakes, **[NEW] mid-transaction reset recovery**, and **[NEW] simultaneous write/read master priority arbitration**.
* **Test 2: Full 32-Register Depth Sweep**: Sweeps the entire 32-register depth (indices `0` to `31`) using sequential address sweeps and inverted address sweeps (`~addr`) to verify complete address space mapping and stability.
* **Test 3: Strobe & Byte-Lane Write Strobe Test**: Tests all 16 `WSTRB` mask combinations, **[NEW] incremental multi-byte writing** (Byte 0 -> Byte 1 -> Byte 2 -> Byte 3), and **[NEW] alternate byte overwrite overlays** verifying perfect byte-lane isolation.
* **Test 4: Boundary & Access Violation Test**: Verifies `SLVERR` and `error` responses for out-of-bounds addresses (`128`, `300`, `240`, `32'h7FFFFFFF`), **[NEW] unaligned address alignment masking (offsets 1, 2, 3 and boundary 127)**, and **[NEW] mixed valid/invalid sequential transaction stream recovery**.
