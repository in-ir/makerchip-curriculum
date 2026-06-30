# Block 2: Sequential Logic

In this block you'll learn the missing ingredient from Block 1: **state**.

A sequential circuit is one where the output depends not just on the current inputs, but on what the circuit remembers from before. That memory comes from registers, clocked one cycle at a time, and it's what lets a circuit count, track, and behave differently over time instead of just reacting.

## What you'll learn

- How a flip-flop captures and holds a value on a clock edge
- How to read and write registers in TL-Verilog using `>>1`
- How to build counters that increment, hold, and wrap around
- How shift registers move bits through a chain, and how that powers randomness
- How finite state machines let a circuit behave differently depending on what state it's in

## Modules

1. [Module 2.1 — Registers](module-2-1-registers.md)
2. [Module 2.2 — Counters](module-2-2-counters.md)
3. [Module 2.3 — Shift Registers](module-2-3-shift-registers.md)
4. [Module 2.4 — Finite State Machines](module-2-4-fsm.md)
5. [Project — Whack-a-Mole](block-2-project.md)

## Project

By the end of Block 2 you'll have everything needed to build circuits with memory and behavior, not just instant reactions. These are the building blocks for the FSM-driven Whack-a-Mole project, and for everything in Blocks 3 and 4.
