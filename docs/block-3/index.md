# Block 3: Memory and Arrays

In this block you'll learn how circuits **store and retrieve data** — not just a value or two, but whole banks of memory you can address by number.

So far your circuits have held a handful of named signals. Real systems need more: a processor's working registers, a screen's pixels, a game's playfield. All of these are _addressable storage_ — you hand the circuit a location, and it reads or writes the value there. That's what this block is about, building up to a full Tetris game running on a memory grid.

## What you'll learn

- How to build a register file: a bank of registers you address by number
- How RAM works: writing to and reading from a memory by address
- How to represent a 2D grid (like a game board) in hardware
- How to read, write, and scan the cells of that grid
- How collision detection works — the heart of any grid-based game

## Modules

1. [Module 3.1 — Register Files](module-3-1-register-files.md)
2. [Module 3.2 — Memory (RAM)](module-3-2-memory.md)
3. [Module 3.3 — The 2D Grid](module-3-3-grid.md)
4. [Module 3.4 — Reading and Writing the Grid](module-3-4-grid-ops.md)
5. [Module 3.5 — Collision Detection](module-3-5-collision.md)
6. [Project — Tetris](block-3-project.md)

## Project

By the end of Block 3 you'll build a complete Tetris game: a falling piece, movement and rotation, collision detection against a stored grid, line-clearing, and a difficulty timer that speeds things up. It's the payoff for everything about memory and arrays, and it uses every concept in the block at once.
