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

Step through it with the time slider and watch the story unfold: the PC walking through the program, the highlighted instruction, `x2` counting up as `i`, `x1` accumulating the sum, the branch flashing "looping back" each time it carries control to the top, and finally **sum = 55** when the loop completes.

Take a moment with this. You started this curriculum with a single logic gate. You are ending it with a processor that runs the same instruction set as real silicon, and you understand every wire in it, because you placed every wire yourself.

## Make it your own

The CPU is a foundation, not a finish line. Some directions:

- **Run your own program.** The instruction memory is just a list of hex words. Assemble a different program by hand, using the instruction table from Module 4.3, and watch it run. Compute a factorial, or a Fibonacci number, or count down instead of up.
- **Add an instruction.** The subset has eleven. Add `slt` (set less than), or the other branches (`bge`, `bltu`), or the logic immediates. Each is a few lines in the decoder and the ALU.
- **Add load and store.** You built the pieces in Module 4.5. Wire a small data memory into the datapath and let programs keep values in memory, not just registers.
- **Pipeline it.** Restage the whole CPU across `@1`, `@2`, `@3` as Module 4.6 showed, and watch instructions overlap.
- **Grow the register file.** Extend from a handful of registers to the full 32, and this is where TL-Verilog's hierarchy construct earns its place: one `/reg[31:0]` scope instead of 32 hand-written lines.

## The final challenge: Pac-Man

Every project in this curriculum so far has been guided. This one is not.

You now have every tool you need to build a complete arcade game in hardware, and the challenge is to do it on your own: **Pac-Man**.

Think about what it needs, and notice that you have built all of it:

- **A maze** is a grid, exactly like the Tetris board from Block 3. Walls are cells that block movement, which is the collision detection you already wrote.
- **Pac-Man's movement** through the maze is guarded motion, the same "take the move only if it is legal" pattern from Module 3.5.
- **The ghosts** are several state machines running at once, each chasing, each with its own position. Multiple instances of the same logic is what TL-Verilog's hierarchy construct is *for*: describe one ghost, instantiate four.
- **Ghost AI** is the chase logic of a simple processor: compare coordinates, pick a direction, respect the walls. If you built a CPU, you can build a ghost that decides where to go.
- **Score, lives, and game state** are a state machine and a few registers, like the game logic in Whack-a-Mole and Tetris.
- **Power pellets** flip every ghost from chase mode to flee mode at once, then each returns on its own timer. That is a global state change rippling through several independent state machines, which is the multi-FSM idea at the heart of this block.

There is no starter file and no checkpoint. That is the point. You have spent four blocks learning to build hardware with guidance, and this is where you find out that you can do it without. Start small, one moving dot in a maze, and grow it. Share what you make.

You are a hardware designer now. Go build something.

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
</script>
