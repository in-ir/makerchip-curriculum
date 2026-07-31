# Project: Your RISC-V CPU

**Block 4 — Building a Processor**  
**Estimated time:** 120–150 minutes  
**Prerequisites:** Modules 4.1 through 4.6

<div id="mc-cpu-final" class="makerchip-embed-small"></div>

This is it. Everything in this block has been building toward one machine, and now you assemble it: a working RISC-V processor that runs a real program and computes a real answer.

The program sums the numbers from 1 to 10. When it finishes, the number **55** is sitting in register `x1`, put there by a processor you designed from the gates up.

## The program

Here is what your CPU will run. Six instructions, and you can now read every one of them:

```
0:   addi x1, x0, 0      sum = 0
4:   addi x2, x0, 1      i = 1
8:   addi x3, x0, 11     limit = 11
12:  add  x1, x1, x2     sum = sum + i
16:  addi x2, x2, 1      i = i + 1
20:  blt  x2, x3, -8     if i < 11, loop back to instruction 12
```

It is a loop. Instructions 12 through 20 run over and over: add the current `i` to the running sum, increment `i`, and branch back as long as `i` is still less than 11. When `i` finally reaches 11 the branch is not taken, execution falls off the end, and `x1` holds `1 + 2 + ... + 10 = 55`.

Everything needed to run this, you have built: fetch to get each instruction, decode to understand it, the register file and ALU to execute it, and branch logic to close the loop.

## Build it in stages

Rather than assemble all six components at once, you will build the CPU in three stages, each adding one capability. Every stage hands you a starter with the earlier parts wired, so you are always extending a machine that already works.

### Stage 1: straight-line execution

Start with the execute path. Fetch and decode are provided; you build the register reads, the operand multiplexer, and the ALU. The program is three `addi` instructions in a row, no loop yet, so you can confirm values flow from the register file, through the ALU, and back.

<div id="mc-cpu-stage1" class="makerchip-embed"></div>

**Checkpoint:** x1 should settle at 0, x2 at 1, x3 at 11. If a register stays 0, check that your writeback sees the ALU output and that you are reading `>>1` of the registers.

??? tip "Hint"

    The register reads are the read MUX from Module 3.1: match `$rs1` against
    each register number and hand back its `>>1` value, with 0 for `x0`. The
    operand MUX is one ternary on `$use_imm`. The ALU needs only addition here,
    so `$rs1_val + $operand2`.

??? success "Solution"

    ```
    $rs1_val[31:0] = ($rs1 == 5'd1) ? >>1$x1 : ($rs1 == 5'd2) ? >>1$x2 : ($rs1 == 5'd3) ? >>1$x3 : 32'd0;
    $rs2_val[31:0] = ($rs2 == 5'd1) ? >>1$x1 : ($rs2 == 5'd2) ? >>1$x2 : ($rs2 == 5'd3) ? >>1$x3 : 32'd0;
    $operand2[31:0] = $use_imm ? $imm : $rs2_val;
    $alu_out[31:0] = $rs1_val + $operand2;
    ```

### Stage 2: the full ALU

Now the program uses `add` and `sub`, so the ALU needs to do more than add. Build the `alu_op` selector from Module 4.3, the one place `funct7` matters, and the ALU that obeys it.

<div id="mc-cpu-stage2" class="makerchip-embed"></div>

**Checkpoint:** x3 should become 8 (5 + 3) and x4 should become 2 (5 − 3). If x4 also shows 8, your `funct7` check is missing and `sub` is decoding as `add`, exactly the bug from Module 4.3.

??? tip "Hint"

    `$alu_op` is 0 for add and addi, and 1 for sub. Sub is distinguished from
    add by `funct7 == 7'b0100000` while both have `funct3 == 000`. The ALU then
    subtracts when `$alu_op` is 1 and adds otherwise.

??? success "Solution"

    ```
    $alu_op[2:0] = ($funct3 == 3'b000 && $funct7 == 7'b0100000) ? 3'd1 : 3'd0;
    $alu_out[31:0] = ($alu_op == 3'd1) ? $rs1_val - $operand2 : $rs1_val + $operand2;
    ```

### Stage 3: the loop

The full program, with the branch. Everything is wired except the one signal that closes the loop: the branch decision. Build it, and the CPU runs the complete sum.

<div id="mc-cpu-stage3" class="makerchip-embed"></div>

**Checkpoint:** watch x1 climb 0, 1, 3, 6, 10, 15, 21, 28, 36, 45, and stop at **55**. If x1 runs past 55 and keeps going, the branch never stops; check that your comparison is `<` and reads the right registers. If it stops early, the branch is triggering when it should not.

??? tip "Hint"

    The next-PC logic at the top of the file already uses `$take_branch`, so you
    only need the decision itself. It is high when this is a branch (`$is_branch`)
    and the branch condition holds. This program uses `blt`, so the condition is
    `$rs1_val < $rs2_val`.

??? success "Solution"

    ```
    $take_branch = $is_branch && ($rs1_val < $rs2_val);
    ```

    That one bit turns a straight-line sequence into a loop, and a loop is what
    lets six instructions add up ten numbers. When it goes low, `i` has reached
    11 and the sum is complete.

## The complete processor

Put the three stages together and you have the whole thing, running at the top of this page. Fetch, decode, register file, ALU, branch, writeback, every piece you built across four blocks, wired into a machine that executes real RISC-V.

### Following the program, cycle by cycle

Step through it with the time slider and watch the story unfold. Here is what happens on each cycle, so you know what to look for:

The first three cycles are setup. The PC sits at 0, 4, then 8, and each `addi` loads a constant: `x1` becomes 0 (the running sum), `x2` becomes 1 (the counter `i`), and `x3` becomes 11 (the limit). Nothing dramatic yet, just three registers being initialised.

Then the loop begins, and this is where it gets interesting. At PC 12, `add x1, x1, x2` reads the current sum and the current `i`, adds them in the ALU, and writes the result back to `x1`. At PC 16, `addi x2, x2, 1` bumps the counter. At PC 20, `blt x2, x3, -8` compares `i` against the limit: if `i` is still less than 11, the branch is taken and the PC jumps *backwards* by 8, landing at PC 12 again.

That backward jump is the whole game. Watch the PC in the visualization: it climbs 12, 16, 20, then snaps back to 12, over and over. Each trip round, `x1` grows by the current `i`, and `x2` ticks up by one. The sum in `x1` traces out exactly the sequence you would compute by hand: 0, then 1, then 3, then 6, 10, 15, 21, 28, 36, 45, and finally 55.

On the last trip, `x2` reaches 11. Now `blt` finds that `i` is *not* less than 11, so the branch is not taken, the PC advances past the loop, and the machine comes to rest. The answer, **55**, sits in `x1`, exactly where the program left it.

### What you are actually looking at

Every number moving in that visualization is a signal on a wire in hardware you designed. The PC is a counter from Module 2.2. The instruction it fetches comes from a memory that is the register-file read MUX from Module 3.1. The fields being pulled apart are the bit slices from Module 4.2. The decision to add versus subtract is the decoder from Module 4.3. The addition itself runs through the ALU from Module 1.4. The sum is held in registers from Module 2.1. And the loop closes through the branch logic from Module 4.5.

Four blocks of work, all of it visible at once, all of it running. There is nothing hidden, no library doing the hard part, no magic. You can point at any value on the screen and trace it back to a line you wrote.

Take a moment with this. You started this curriculum with a single logic gate. You are ending it with a processor that runs the same instruction set as real silicon, and you understand every wire in it, because you placed every wire yourself.

### Prove it to yourself

The best way to believe a processor works is to break it deliberately and watch it fail in a way you predicted. A few experiments worth trying on the complete CPU:

- **Change the limit.** Instruction 8 loads 11 into `x3`. Change it to load a different number and the sum changes to match: load 6 and you get 1+2+3+4+5 = 15. You have reprogrammed the computer by changing one constant in memory, which is exactly what running different software means.
- **Break the branch offset.** Change the `-8` in the branch to `-4` and watch the loop body shrink to a single instruction, computing the wrong sum. This is the hardcoded-offset lesson from Module 4.5, live.
- **Forget to sign-extend.** Feed the immediate through without sign extension and watch a subtraction turn into a huge positive number, the quiet failure from Module 4.2.

## Make it your own

The CPU is a foundation, not a finish line. Some directions:

- **Run your own program.** The instruction memory is just a list of hex words. Assemble a different program by hand, using the instruction table from Module 4.3, and watch it run. Compute a factorial, or a Fibonacci number, or count down instead of up.
- **Add an instruction.** The subset has eleven. Add `slt` (set less than), or the other branches (`bge`, `bltu`), or the logic immediates. Each is a few lines in the decoder and the ALU.
- **Add load and store.** You built the pieces in Module 4.5. Wire a small data memory into the datapath and let programs keep values in memory, not just registers.
- **Pipeline it.** Restage the whole CPU across `@1`, `@2`, `@3` as Module 4.6 showed, and watch instructions overlap.
- **Grow the register file.** Extend from a handful of registers to the full 32, and this is where TL-Verilog's hierarchy construct earns its place: one `/reg[31:0]` scope instead of 32 hand-written lines.

## The final challenge: Pac-Man

Every project in this curriculum so far has been guided. This one is not.

<div id="mc-pacman" class="makerchip-embed-small"></div>

You now have every tool you need to build a complete arcade game in hardware, and the challenge is to do it on your own: **Pac-Man**. The visualization above is a glimpse, a dot moving through a maze with a ghost one step behind. It is deliberately simple, because the point is not to hand you a finished game. It is to show you that the pieces are already in your hands.

### You have built every part already

Think about what Pac-Man needs, and notice where each piece came from:

- **A maze** is a grid, exactly like the Tetris board from Block 3. Each cell is a bit: wall or open. Reading and testing those cells is the grid work from Module 3.3, and the walls that block movement are the collision detection from Module 3.5.
- **Pac-Man's movement** is guarded motion: he moves in a direction unless a wall is in the way. That is the exact "take the move only if it is legal" pattern you built for the falling Tetris piece in Module 3.5, now in two dimensions.
- **The ghosts** are several state machines running at once, each with its own position and its own behaviour. This is the multi-FSM idea at the heart of this block, and it is where TL-Verilog's hierarchy construct earns its place: describe *one* ghost, then instantiate four with `/ghost[3:0]`, exactly as you would instantiate registers in a register file.
- **Ghost AI** is the chase logic of a simple processor: look at Pac-Man's position, compare it to your own, pick the direction that closes the gap, and respect the walls. Comparing coordinates and choosing a direction is decision logic no harder than the branch you just built into a CPU.
- **Score, lives, and game state** are a state machine and a few registers, the same shape as the game logic in Whack-a-Mole and Tetris.
- **Power pellets** are the most satisfying piece. Eat one and *every* ghost flips from chase mode to flee mode at once, then each returns to chasing on its own timer. That is a single global event rippling through several independent state machines, each responding and then recovering on its own schedule. It is the multi-FSM idea in its purest form, and it is genuinely Pac-Man.

### How to approach it

The trap with a project this open is trying to build all of it at once. Do not. Build it the way you built everything else in this course: one working piece at a time, each verified before the next.

A sensible order:

1. **Draw a static maze.** Just the walls, no movement. Get the grid rendering in the Viz pane. This is Module 3.3 with a nicer shape.
2. **Add Pac-Man, moving in one direction.** Make him slide right and stop at a wall. Now you have guarded movement working.
3. **Let him turn.** Add a simple rule for changing direction, a fixed pattern is fine to start. Now he navigates.
4. **Add one ghost that chases.** A single state machine comparing its position to Pac-Man's. Get one ghost right before you make four.
5. **Instantiate the rest with hierarchy.** Once one ghost works, `/ghost[3:0]` gives you four for almost free. This is the moment the block's title, hierarchy, pays off.
6. **Add pellets, scoring, and power mode.** The game logic on top.

Each step is something you have done before, in a different costume. None of them is beyond you now.

### No starter, no checkpoint

There is no starter file here and no solution to reveal. That is the point. You have spent four blocks learning to build hardware with guidance, and this is where you find out that you can do it without. Start with a single dot in a maze and grow it as far as you like. When something breaks, you now know how to open the Viz pane, step to the cycle where it goes wrong, and read the signals until you find it. That skill, more than any single circuit, is what you actually built here.

Share what you make. Post it to the course repository, show it to someone, put it in the Makerchip gallery. The world has one more hardware designer in it now, and that is you.

Go build something.

<style>
.makerchip-embed       { position: relative; width: 100%; height: 540px; }
.makerchip-embed-small { position: relative; width: 100%; height: 440px; }
</style>

<script type="module">
  import IdePlugin from 'https://beta.makerchip.com/dist/makerchip-plugin.js';

  const base = 'https://raw.githubusercontent.com/in-ir/makerchip-curriculum/main/code/block-4/';

  class VizOnlyIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({ panes: ['Viz'], activePane: 'Viz' });
      await this.compile();
    }
  }

  class EditorWaveformIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({
        sides: {
          left:  { panes: ['Editor'],   activePane: 'Editor'   },
          right: { panes: ['Waveform'], activePane: 'Waveform' }
        },
        splitAt: 0.5
      });
    }
  }

  if (document.getElementById('mc-cpu-final')) {
    VizOnlyIDE.create('mc-cpu-final', { codeURL: base + 'cpu.tlv' });
  }
  if (document.getElementById('mc-cpu-stage1')) {
    EditorWaveformIDE.create('mc-cpu-stage1', { codeURL: base + 'cpu-stage1.tlv' });
  }
  if (document.getElementById('mc-cpu-stage2')) {
    EditorWaveformIDE.create('mc-cpu-stage2', { codeURL: base + 'cpu-stage2.tlv' });
  }
  if (document.getElementById('mc-cpu-stage3')) {
    EditorWaveformIDE.create('mc-cpu-stage3', { codeURL: base + 'cpu-stage3.tlv' });
  }
  if (document.getElementById('mc-pacman')) {
    VizOnlyIDE.create('mc-pacman', { codeURL: base + 'pacman-viz.tlv' });
  }
</script>
