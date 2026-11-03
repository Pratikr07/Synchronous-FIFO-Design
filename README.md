# Synchronous FIFO Design | Verilog, SystemVerilog, Vivado

## Overview

This project implements a parameterized **Synchronous FIFO (First-In, First-Out)** using Verilog RTL. The FIFO stores data temporarily and outputs it in the same order in which it was written.

The design supports configurable FIFO depth and data width, with status flags to indicate when the FIFO is full or empty.

The RTL was simulated and verified using a SystemVerilog testbench in **AMD Vivado 2025.2 (XSim)**.

## Features

- Parameterized FIFO depth and data width.
- Synchronous read and write operations.
- Active-low asynchronous reset.
- Write and read pointers for memory addressing.
- Full and empty status flags.
- Occupancy counter to track stored data.
- Protection against overflow and underflow.
- Support for simultaneous read and write operations.

## Architecture

The FIFO consists of the following main components:

| Component | Description |
|---|---|
| Memory Array | Stores the input data |
| Write Pointer | Tracks the next write location |
| Read Pointer | Tracks the next read location |
| Counter | Tracks the number of stored elements |
| Full Flag | Indicates that the FIFO has reached its maximum capacity |
| Empty Flag | Indicates that the FIFO contains no data |

### Default Parameters

| Parameter | Value | Description |
|---|---:|---|
| DEPTH | 8 | Number of FIFO entries |
| DATA_WIDTH | 8 | Number of bits per entry |

## Module Interface

| Signal | Direction | Description |
|---|---|---|
| clk | Input | Clock signal |
| rst_n | Input | Active-low asynchronous reset |
| wren | Input | Write enable |
| rd_en | Input | Read enable |
| data_in | Input | Input data |
| data_out | Output | Output data |
| full | Output | FIFO full indicator |
| empty | Output | FIFO empty indicator |
| count | Output | Number of stored entries |

## FIFO Operations

**1. Write Operation**

- Data is written when `wren = 1` and the FIFO is not full.
- The write pointer advances after an accepted write.
- The occupancy counter increases when only a write is accepted.

**2. Read Operation**

- Data is read when `rd_en = 1` and the FIFO is not empty.
- The read pointer advances after an accepted read.
- The occupancy counter decreases when only a read is accepted.

**3. Simultaneous Read and Write**

- When both operations are accepted, the read and write pointers advance.
- The occupancy counter remains unchanged.

**4. Reset Operation**

- An active-low reset clears the pointers, counter, and output register.
- The FIFO returns to its empty state.

## Verification

A SystemVerilog testbench was developed to verify the FIFO functionality using a reference queue.

The testbench checks the output data, occupancy counter, and status flags after each operation.

### Test Cases

| Test Case | Expected Result | Status |
|---|---|---|
| Reset | FIFO becomes empty | PASS |
| Normal Write | Data stored correctly | PASS |
| Normal Read | Data returned in FIFO order | PASS |
| Underflow Protection | Read from empty FIFO is ignored | PASS |
| Fill FIFO | Counter reaches DEPTH | PASS |
| Overflow Protection | Write to full FIFO is ignored | PASS |
| Read All Data | All stored data is returned correctly | PASS |
| Simultaneous Read/Write | Both operations work correctly | PASS |
| Pointer Wraparound | FIFO continues operating after pointer wraparound | PASS |

### Simulation Results

**Simulation Tool:** AMD Vivado 2025.2 – XSim

**Simulation Output:**

```text
RESET: count=0, full=0, empty=1

PASS: Normal Write
PASS: Normal Read
PASS: Underflow Protection
PASS: Fill FIFO
PASS: Overflow Protection
PASS: Read All Data
PASS: Simultaneous Read/Write
PASS: Pointer Wraparound

ALL TESTS PASSED
```

<text>Simulation completed successfully at 520 ns, with no testbench comparison errors or assertion failures reported.</text>

## Tools Used

- Verilog HDL
- SystemVerilog
- AMD Vivado 2025.2
- XSim Simulator

## Learning Outcomes

- Understanding FIFO architecture and memory organization.
- Implementing read and write pointer logic.
- Managing FIFO occupancy using a counter.
- Handling full and empty conditions.
- Understanding simultaneous read and write operations.
- Writing a SystemVerilog testbench with a reference queue.
- Verifying RTL functionality through simulation and assertions.

## Project Status

**Completed – RTL Design and Functional Simulation Verified**

## Author

**Pratik Rathod**

B.Tech – Electronics and Communication Technology  
Indian Institute of Information Technology, Surat

GitHub: [Pratikr07](https://github.com/Pratikr07)
