# Module 4.5: Branches and Memory

**Block 4 — Building a Processor**  
**Estimated time:** 70–85 minutes  
**Prerequisites:** Module 4.4 — The Datapath

<div id="mc-branch-demo" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module your processor will be able to make decisions and touch memory. You will build **branches**, which let the program counter jump based on a comparison, and **loads and stores**, which move data between registers and memory. With these, the CPU can run loops and conditionals, and the sum-1-to-10 program from the start of the block will finally run to completion.

## The PC stops being a plain counter

Every program you have run so far goes straight down: fetch instruction 0, then 1, then 2, forever. The PC only ever does `+4`. That is enough for arithmetic but it cannot express the two things every real program needs: *do this only if* and *do this again*.

Both come from a single new ability: letting the PC jump somewhere other than the next instruction. That is a **branch**.

```
$pc[31:0] = *reset ? 32'd0 : $take ? >>1$pc + $offset : >>1$pc + 32'd4;
```

Look at what changed from Module 4.1. The PC used to have one update rule. Now it has two, chosen by `$take`. If the branch is not taken, `+4` as always. If it is taken, add a signed `$offset` instead, which can be negative. A negative offset sends the PC *backwards*, and a backward jump to an earlier instruction is exactly what a loop is.

The VIZ at the top of this page shows this. A tiny program increments `x1` and branches back as long as `x1 < 3`. Watch the PC jump from the branch back up to the top, three times, then fall through when the condition finally fails. That jump, repeated, is a loop running on hardware you built.

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 720 250" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="br-arr" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="7" markerHeight="7" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#6D5A8A" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
    <marker id="br-back" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="8" markerHeight="8" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#22c55e" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <text x="180" y="30" fill="#4A3060" font-size="12" text-anchor="middle">straight line: PC always +4</text>
  <text x="540" y="30" fill="#4A3060" font-size="12" text-anchor="middle">branch: PC can jump back</text>

  <!-- left column: straight line -->
  <rect x="110" y="50" width="140" height="30" rx="4" fill="#1A0533" stroke="#2A1A40" stroke-width="1.5"/>
  <text x="180" y="70" fill="#6D5A8A" font-size="11" text-anchor="middle">instr 0</text>
  <rect x="110" y="90" width="140" height="30" rx="4" fill="#1A0533" stroke="#2A1A40" stroke-width="1.5"/>
  <text x="180" y="110" fill="#6D5A8A" font-size="11" text-anchor="middle">instr 1</text>
  <rect x="110" y="130" width="140" height="30" rx="4" fill="#1A0533" stroke="#2A1A40" stroke-width="1.5"/>
  <text x="180" y="150" fill="#6D5A8A" font-size="11" text-anchor="middle">instr 2</text>
  <rect x="110" y="170" width="140" height="30" rx="4" fill="#1A0533" stroke="#2A1A40" stroke-width="1.5"/>
  <text x="180" y="190" fill="#6D5A8A" font-size="11" text-anchor="middle">instr 3</text>
  <path d="M180 80 L180 88" stroke="#6D5A8A" stroke-width="1.5" marker-end="url(#br-arr)"/>
  <path d="M180 120 L180 128" stroke="#6D5A8A" stroke-width="1.5" marker-end="url(#br-arr)"/>
  <path d="M180 160 L180 168" stroke="#6D5A8A" stroke-width="1.5" marker-end="url(#br-arr)"/>

  <!-- right column: loop -->
  <rect x="470" y="50" width="140" height="30" rx="4" fill="#3B1D6D" stroke="#7C4DFF" stroke-width="1.5"/>
  <text x="540" y="70" fill="#EDE7F6" font-size="11" text-anchor="middle">addi x1, x1, 1</text>
  <rect x="470" y="90" width="140" height="30" rx="4" fill="#3B1616" stroke="#ef4444" stroke-width="1.5"/>
  <text x="540" y="110" fill="#EDE7F6" font-size="11" text-anchor="middle">blt x1, x2, back</text>
  <rect x="470" y="150" width="140" height="30" rx="4" fill="#1A0533" stroke="#2A1A40" stroke-width="1.5"/>
  <text x="540" y="170" fill="#6D5A8A" font-size="11" text-anchor="middle">done</text>

  <path d="M540 80 L540 88" stroke="#6D5A8A" stroke-width="1.5" marker-end="url(#br-arr)"/>
  <!-- taken: loop back up -->
  <path d="M610 105 L660 105 L660 65 L613 65" fill="none" stroke="#22c55e" stroke-width="1.8" marker-end="url(#br-back)"/>
  <text x="672" y="88" fill="#22c55e" font-size="10" text-anchor="middle" transform="rotate(90 672 88)">taken: x1 &lt; x2</text>
  <!-- not taken: fall through -->
  <path d="M540 120 L540 148" stroke="#6D5A8A" stroke-width="1.5" stroke-dasharray="3,3" marker-end="url(#br-arr)"/>
  <text x="470" y="140" fill="#4A3060" font-size="9" text-anchor="end">not taken</text>

  <text x="360" y="235" fill="#4A3060" font-size="11" text-anchor="middle">the only difference is one signal: does the PC add 4, or add the offset?</text>
</svg>
</div>

## Deciding whether to branch

A branch carries a condition. `beq` branches if two registers are equal, `bne` if they differ, `blt` if the first is less than the second. Each is a comparison the ALU can already do, selected by `funct3`:

!!! note "Real hardware: signed comparison"

    RISC-V's `blt` compares its operands as **signed** numbers, so that
    `blt` treats `-1` as less than `1`. Our subset's operands are always small
    and positive, so the plain `<` used below gives the same answer. A complete
    RV32I core sign-extends and compares as signed, and also provides `bltu` for
    an explicitly *unsigned* comparison. It is worth knowing the distinction
    exists: an unsigned `<` on two 32-bit values treats a negative number,
    whose top bit is 1, as a very large positive one.

```
$eq  = $rs1_val == $rs2_val;
$lt  = $rs1_val <  $rs2_val;

$take = $is_branch && ( ($funct3 == 3'b000) ? $eq :
                        ($funct3 == 3'b001) ? !$eq :
                        ($funct3 == 3'b100) ? $lt :
                                              1'b0 );
```

`$take` is the whole point. It is one bit, and it is the bit that decides the future of the program. When it is high the PC leaps; when it is low execution continues in a straight line. Everything a program does that is not pure calculation, every `if`, every loop, every function call, comes down to this one signal.

## The branch offset

There is a wrinkle, and it is the scrambled B-type immediate you met in Module 4.2. A branch's jump distance is not stored as a clean 12-bit field. Its bits are scattered across the instruction so that they line up, where possible, with the immediate bits of other formats.

Reassembling it is a concatenation that puts the pieces back in order:

```
$offset[31:0] = $instr[31] ? {19'h7FFFF, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0}
                           : {19'd0,     $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0};
```

It looks intimidating and it is really just the sign-extension pattern from Module 4.2 with the middle bits gathered from several places instead of one. The trailing `1'b0` is there because branch targets are always even (instructions are 4 bytes, addresses are multiples of 2 at minimum), so the lowest bit is not stored, it is known to be zero.

You do not need to memorise this. You need to understand that the offset is *reconstructed* from scattered bits, and that if you gather them wrong, the branch jumps to the wrong place.

## Watch it break: a hardcoded jump distance

Here is a tempting shortcut. Your one test loop jumps back by a fixed amount, so why not just hardcode the offset?

<div id="mc-branch-bug" class="makerchip-embed-small"></div>

`$good_offset` reconstructs the real offset from the instruction and reads −4. `$bad_offset` is hardcoded to +8. For the one branch it was tuned to, the hardcoded version might even work. For every *other* branch in every other program, it jumps somewhere completely wrong: a loop that should step back four bytes leaps forward eight, execution lands in the middle of the program, and the machine runs whatever happens to be there.

This is the difference between a processor and a trick that passes one test. A real CPU reads the offset out of each branch, because each branch carries its own. Hardcoding it means your hardware only runs one program, which is not a processor at all.

## Loads and stores

The last capability. So far every value lives in a register, and there are only 32 of them. Real programs need more room, and that room is **data memory**.

Two instructions reach it. `sw` (store word) writes a register to memory; `lw` (load word) reads memory into a register. And here is the detail that ties the module together: **the address is computed by the ALU, as an addition.**

`lw x6, 0(x1)` means "take register `x1`, add the immediate 0, and use that sum as a memory address." That is why loads and stores set `use_imm` back in Module 4.3: the address calculation is an add like any other, base register plus offset. Your ALU already does it.

```
$addr[31:0] = $rs1_val + $imm;              // same add as everything else
$mem[$addr]  = $is_store ? $rs2_val : ...;   // store writes
$load_data   = $mem[$addr];                  // load reads
```

<div id="mc-memory-demo" class="makerchip-embed-small"></div>

The demo stores 42 to memory and loads it straight back into another register. Watch `x1` become 42, then the store push it into `mem0`, then the load pull it into `x2`. The value makes a round trip through memory and comes back intact.

!!! note "The load-use delay"

    Reading memory takes a cycle, exactly like the register-file read you met in
    Module 3.2: the value you ask for this cycle arrives next cycle. In a
    simple design that means the instruction immediately after a load cannot use
    the loaded value yet. Real pipelines handle this with a "load-use hazard"
    check, and it is one of the things Module 4.6 will make visible when we
    pipeline the processor. For our single-instruction-per-cycle CPU it does not
    bite, but it is worth knowing the delay is there.

## Your turn: build the branch logic

Below is the counting loop. Fetch, the registers, and the offset reconstruction are done for you. Build the two signals that make a branch work: the decision, and the next PC.

<div id="mc-branch-exercise" class="makerchip-embed"></div>

??? tip "Hint"

    **The decision.** This program uses `blt`, funct3 `100`, which is "less
    than." So `$take` is high when the instruction is a branch and last cycle's
    `x1` is less than `x2`. One `&&` joining those two conditions.

    **The next PC.** Two cases: taken adds the signed `$offset`, not-taken adds
    4. A single ternary on `$take`, and remember to reset to 0. Keep it on one
    line.

??? success "Solution"

    ```
    $take = $is_branch && (>>1$x1 < $x2);

    $pc[31:0] = *reset ? 32'd0 : $take ? >>1$pc + $offset : >>1$pc + 32'd4;
    ```

    Watch `$pc` in the waveform. It should climb 0, 4, then jump back to 0 from
    the branch, over and over, until `x1` reaches 3. Then `$take` goes low, the
    PC advances to 8, and the loop is done. If the PC runs away past 8, your
    `$take` never goes low; check the comparison direction.

## Your CPU is complete

Stop and take this in. Your processor now has arithmetic, logic, decisions, and memory. That is not a teaching subset of a computer, it is a computer. Anything that can be computed at all can be computed by a machine with exactly these capabilities. You built one.

The sum-1-to-10 program that opened this block, the one whose instructions you learned to read, decode, and execute, now runs start to finish: the loop counts, the branch carries it back nine times, and the answer, 55, comes to rest in `x1`. You will assemble the whole thing in the project.

## Where this fits next

There is one more module, and it is the one that makes this a *TL-Verilog* processor rather than just a processor.

Right now your CPU does everything for one instruction before starting the next: fetch, decode, execute, all in a single cycle. That works, but it is slow, because the fetch hardware sits idle while the ALU runs, and vice versa. In Module 4.6 you will **pipeline** the processor: overlap the stages so that while one instruction executes, the next is already being decoded and a third is being fetched. Pipelining is the feature TL-Verilog was built to express, and you will see why the language exists.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| Branch PC | `$take ? >>1$pc + $offset : >>1$pc + 32'd4` | Jump or continue |
| Branch decision | `$is_branch && $condition` | The bit that steers control flow |
| beq / bne / blt | `funct3` selects | Equal, not equal, less than |
| Address | `$rs1_val + $imm` | Computed by the ALU, an add |
| Store / load | `sw` writes, `lw` reads | Move data to and from memory |

<style>
.makerchip-embed       { position: relative; width: 100%; height: 500px; }
.makerchip-embed-small { position: relative; width: 100%; height: 400px; }
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

  class WaveformOnlyIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({ panes: ['Waveform'], activePane: 'Waveform' });
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

  if (document.getElementById('mc-branch-demo')) {
    VizOnlyIDE.create('mc-branch-demo', { codeURL: base + 'branch-demo.tlv' });
  }
  if (document.getElementById('mc-branch-bug')) {
    WaveformOnlyIDE.create('mc-branch-bug', { codeURL: base + 'branch-bug.tlv' });
  }
  if (document.getElementById('mc-memory-demo')) {
    WaveformOnlyIDE.create('mc-memory-demo', { codeURL: base + 'memory-demo.tlv' });
  }
  if (document.getElementById('mc-branch-exercise')) {
    EditorWaveformIDE.create('mc-branch-exercise', { codeURL: base + 'branch-exercise.tlv' });
  }
</script>
