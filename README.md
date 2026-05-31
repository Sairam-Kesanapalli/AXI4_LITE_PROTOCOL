# AXI4-Lite Master-Slave RTL Core & Verification Suite

This repository contains a high-performance, fully standard-compliant, and latch-free **AMBA AXI4-Lite Protocol Master-Slave IP Core** designed in Verilog, alongside a SystemVerilog verification suite.

---

## 📂 Repository Directory Layout

The project structure is organized as follows:

* 📁 **[src/](file:///home/Sairam/Documents/Cutout/AXI4_LITE_PROTOCOL/src)**: Core RTL design source files.
  * 📄 `axi4_lite_master.v`: The master interface controller featuring registered inputs, sequential outputs, and independent channel tracking.
  * 📄 `axi4_lite_slave.v`: The slave interface controller managing standard handshaking and address decoding.
  * 📄 `register.v`: A 32-deep, 32-bit register file (RF) supporting byte-lane select strobes (`WSTRB`).
* 📁 **[tests/](file:///home/Sairam/Documents/Cutout/AXI4_LITE_PROTOCOL/tests)**: Verification suites and testbenches.
  * 📄 `test1.sv`: Cycle-accurate, race-free loopback verification testbench.
* 📄 **[Makefile](file:///home/Sairam/Documents/Cutout/AXI4_LITE_PROTOCOL/Makefile)**: Automation script to compile and run simulation tests.

---

## 🛠️ Verification & Simulation Instructions

You can run, manage, and clean up the simulation directly from the repository root using `make`.

### 1. Compile & Run `test1` Simulation
To compile the core design along with `test1.sv` and execute the simulation, run:
```bash
make test1
```

### 2. Clean Up Simulation Artifacts
To clean compiled binaries (`check.out`) and VCD waveforms (`waveform.vcd`), run:
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

## 🧪 Verification Roadmap & WIP Tests

In addition to the completed `test1` loopback test, the following test suites are planned for full protocol verification and are currently under development (WIP):
* **Test 2: Asymmetric Backpressure Test (WIP)**: Verifies robust processing when channel handshakes (`READY`/`VALID`) occur asynchronously on separate cycles.
* **Test 3: Boundary & Access Violation Test (WIP)**: Verifies proper `SLVERR` and `DECERR` responses on invalid/unmapped address reads or writes.
* **Test 4: Arbitration Test (WIP)**: Verifies bus arbitration and priority when write and read requests are asserted in the same cycle.
