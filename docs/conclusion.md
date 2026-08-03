# You Built a Computer

**A closing note**

You started this course with a single logic gate. One input, one output, a rule as simple as "flip the bit." That was Module 1.1, and if you go back and look at it now, it will feel almost impossibly small.

Look at what that gate became.

## The whole path, in one breath

You took a NOT gate and an AND gate and built a **half adder**. You put adders together into an **ALU** that does real arithmetic. You learned to hold a value across time with a **flip-flop**, and suddenly your circuits had memory. You built **counters** that walk, **shift registers** that stream, and **state machines** that decide. You gathered registers into a **register file** and cells into **memory**, and you learned to lay data out as a **grid** you could read, write, and search for collisions.

And then, in Block 4, you discovered the secret the whole course had been keeping: those were never separate topics. They were the parts of a **processor**. Your decoder became the instruction decoder. Your ALU stayed the ALU. Your counter became the program counter. Your register file and memory held the program's state. You wired them together, and a machine woke up and ran a real RISC-V program, and the number 55 appeared in a register because your hardware computed it, one instruction at a time.

That is not a toy. That is the same thing, in miniature, that is happening inside the device you are reading this on right now.

## What you actually learned

The circuits matter, but they are not the real prize. The real prize is the way of seeing that you have now.

You can look at a waveform and know what "correct" is supposed to look like. You can take a system you do not understand, break it into pieces you do, and build it back up. You can read a design, find the one signal that is wrong, and fix it. When something breaks, you no longer freeze. You open the Viz pane, step to the cycle where it goes wrong, and read the signals until the bug has nowhere left to hide.

That gap I told you about at the very beginning, between what you draw on paper and what is really happening inside the circuit, you have crossed it. That is the thing most people never get. You have it now.

## Where to go from here

This course is a foundation, and foundations are meant to be built on. A few directions, roughly from nearest to furthest:

- **Finish Pac-Man.** The final challenge is still open. It uses everything you have: grids, guarded movement, multiple state machines, hierarchy. It is the most honest test of whether the toolbox is really yours.
- **Grow your CPU.** Add instructions, add data memory, add the full 32 registers with hierarchy, pipeline it properly with `@` stages. Every one of these is a real feature of real processors, and none of them is beyond you now.
- **Take the RISC-V MYTH course.** Makerchip's own [RISC-V MYTH workshop](https://makerchip.com/) walks you from these same foundations to a more complete pipelined RISC-V core. You are exactly its intended audience now, and much of it will feel like coming home.
- **Explore WARP-V.** [WARP-V](https://github.com/stevehoover/warp-v) is an open-source, configurable RISC-V core written in TL-Verilog. Reading it is a masterclass in how the ideas from this course scale to production hardware.
- **Design something nobody asked for.** The surest sign you have learned this is when you build a thing just because you want to see it run.

## Thank you

I built this course because a professor once made hardware click for me, and I wanted to pass that feeling on. If any part of this curriculum made a circuit click for you, if there was a moment where a waveform stopped being colored lines and started being a machine you understood, then it did its job, and so did you.

You came in never having written a line of TL-Verilog. You are leaving having built a processor from gates up and understood every wire in it. That is a real accomplishment, and it is yours.

If something was unclear, or if you build something you are proud of, I would genuinely love to hear about it. Open a discussion on the [course repo](https://github.com/in-ir/makerchip-curriculum/discussions).

Now go build something.

— Ines
