# Block 4: Building a Processor

This is where everything comes together.

Over the last three blocks you have built logic gates, multiplexers, decoders, an ALU, registers, counters, state machines, a register file, and memory. What you have not been told is that those are not a random assortment of circuits. They are, almost exactly, the parts list for a **processor**.

Look at what is already sitting in your toolbox:

| You built | In a CPU it is called |
| --- | --- |
| A decoder (Module 1.3) | The instruction decoder |
| An ALU (Module 1.4) | The ALU |
| Registers (Module 2.1) | State registers |
| A counter (Module 2.2) | The program counter |
| A state machine (Module 2.4) | The control unit |
| A register file (Module 3.1) | The register file |
| RAM (Module 3.2) | Instruction and data memory |

Every one of those is a real part of a real CPU, and you have already built and debugged all of them. This block is about wiring them together into a machine that reads instructions out of memory and executes them.

And not a made-up machine. You are going to build a subset of **RISC-V**, the open instruction set used in everything from research chips to shipping silicon, and the architecture behind Makerchip's own RISC-V course. The programs you run on it will be real RISC-V programs, assembled from real RISC-V encodings.

## What you'll learn

- How a processor fetches, decodes, and executes instructions, one per cycle
- How an instruction is encoded as a 32-bit number, and how hardware pulls it apart
- How to turn instruction bits into control signals that steer the datapath
- How to wire the register file and ALU into a working execution path
- How branches let a program make decisions, and how loads and stores reach memory
- How to **pipeline** the whole thing, the feature TL-Verilog was designed for

## Modules

1. [Module 4.1 — Anatomy of a Processor](module-4-1-anatomy.md)
2. [Module 4.2 — Instructions](module-4-2-instructions.md)
3. [Module 4.3 — Decode](module-4-3-decode.md)
4. [Module 4.4 — The Datapath](module-4-4-datapath.md)
5. [Module 4.5 — Branches and Memory](module-4-5-branches-memory.md)
6. [Module 4.6 — Pipelining](module-4-6-pipelining.md)
7. [Project — Your RISC-V CPU](block-4-project.md)

## Project

By the end you will have a working RISC-V processor running a real program: a loop that adds up the numbers from 1 to 10 and leaves the answer, 55, sitting in a register. You will watch it happen instruction by instruction, in the visualizer, on hardware you designed.

Then, if you want to keep going, there is an open challenge waiting: **Pac-Man**, unguided this time, using everything you have learned across all four blocks.
