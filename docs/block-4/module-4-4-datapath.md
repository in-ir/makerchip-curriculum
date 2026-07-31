# Module 4.4: The Datapath

**Block 4 — Building a Processor**  
**Estimated time:** 70–85 minutes  
**Prerequisites:** Module 4.3 — Decode

<div id="mc-datapath-viz" class="makerchip-embed-small"></div>

## What you'll learn

This is the module where the processor runs. By the end of it you will have wired the register file and the ALU into the fetch and decode stages you already built, and you will have a CPU that executes real RISC-V instructions and leaves real answers in real registers. You will understand the path a value takes from register, through the ALU, and back, and why `x0` is special.

## The last two pieces

Look back at the map from Module 4.1. You have built the PC, the instruction memory, and the decoder. Two boxes are left: the **register file** and the **ALU**. And you have built both of those before, in Block 3 and Block 1. This module is almost entirely wiring.

Here is the whole execute path, the part of the processor that actually *does* the instruction:

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 740 280" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="dp4-arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <rect x="30" y="70" width="130" height="120" rx="8" fill="#1A0533" stroke="#7C4DFF" stroke-width="2"/>
  <text x="95" y="94" fill="#7C4DFF" font-size="12" font-weight="bold" text-anchor="middle">REGISTER FILE</text>
  <text x="95" y="116" fill="#4A3060" font-size="10" text-anchor="middle">read rs1</text>
  <text x="95" y="134" fill="#4A3060" font-size="10" text-anchor="middle">read rs2</text>
  <text x="95" y="160" fill="#22c55e" font-size="10" text-anchor="middle">write rd</text>
  <text x="95" y="178" fill="#4A3060" font-size="9" text-anchor="middle">Module 3.1</text>

  <rect x="290" y="70" width="90" height="60" rx="8" fill="#1A0533" stroke="#eab308" stroke-width="2"/>
  <text x="335" y="94" fill="#eab308" font-size="11" font-weight="bold" text-anchor="middle">MUX</text>
  <text x="335" y="112" fill="#4A3060" font-size="9" text-anchor="middle">use_imm</text>

  <rect x="180" y="150" width="90" height="30" rx="5" fill="#0F2A38" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="225" y="169" fill="#38bdf8" font-size="10" text-anchor="middle">immediate</text>

  <rect x="470" y="66" width="120" height="90" rx="10" fill="#1A0533" stroke="#7C4DFF" stroke-width="2"/>
  <text x="530" y="104" fill="#7C4DFF" font-size="13" font-weight="bold" text-anchor="middle">ALU</text>
  <text x="530" y="124" fill="#4A3060" font-size="9" text-anchor="middle">Module 1.4</text>

  <rect x="470" y="200" width="120" height="34" rx="6" fill="#1A0533" stroke="#22c55e" stroke-width="1.5"/>
  <text x="530" y="221" fill="#22c55e" font-size="10" text-anchor="middle">alu_op (decode)</text>

  <line x1="160" y1="105" x2="286" y2="98" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#dp4-arr)"/>
  <text x="215" y="92" fill="#4A3060" font-size="9" text-anchor="middle">rs1</text>
  <line x1="160" y1="140" x2="176" y2="150" stroke="#4A3060" stroke-width="1.3"/>
  <text x="180" y="128" fill="#4A3060" font-size="9" text-anchor="middle">rs2</text>
  <line x1="270" y1="163" x2="335" y2="163" stroke="#4A3060" stroke-width="1.3"/>
  <line x1="335" y1="163" x2="335" y2="132" stroke="#4A3060" stroke-width="1.3" marker-end="url(#dp4-arr)"/>

  <line x1="160" y1="100" x2="200" y2="100" stroke="#B39DDB" stroke-width="1.5"/>
  <path d="M200 100 L200 84 L466 84" fill="none" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#dp4-arr)"/>
  <text x="330" y="78" fill="#4A3060" font-size="9" text-anchor="middle">first operand (rs1)</text>

  <line x1="380" y1="100" x2="422" y2="100" stroke="#B39DDB" stroke-width="1.5"/>
  <path d="M422 100 L422 120 L466 120" fill="none" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#dp4-arr)"/>
  <text x="425" y="138" fill="#4A3060" font-size="9" text-anchor="middle">second operand</text>

  <line x1="530" y1="200" x2="530" y2="160" stroke="#4A3060" stroke-width="1.3" marker-end="url(#dp4-arr)"/>

  <path d="M590 111 L640 111 L640 250 L95 250 L95 192" fill="none" stroke="#22c55e" stroke-width="1.6" stroke-dasharray="5,4" marker-end="url(#dp4-arr)"/>
  <text x="360" y="268" fill="#22c55e" font-size="10" text-anchor="middle">writeback: the result goes back into register rd  (if rf_wr)</text>
</svg>
</div>

Trace it once in words. The register file reads `rs1` and `rs2`. A multiplexer, steered by `use_imm` from the decoder, chooses whether the ALU's second input is register `rs2` or the immediate. The ALU computes, in the mode `alu_op` selects. And if `rf_wr` is high, the result is written back into register `rd`. That loop is a processor executing an instruction.

## The ALU

You built an ALU in Module 1.4. Here it is again, sized for RISC-V: five operations, selected by the `alu_op` signal your decoder produces.

```
$alu_out[31:0] = ($alu_op == 3'd1) ? $rs1_val - $operand2 :
                 ($alu_op == 3'd2) ? $rs1_val ^ $operand2 :
                 ($alu_op == 3'd3) ? $rs1_val | $operand2 :
                 ($alu_op == 3'd4) ? $rs1_val & $operand2 :
                                     $rs1_val + $operand2;
```

Add, subtract, XOR, OR, AND. The default case is addition, which is deliberate: `addi`, loads and stores all need an add, so making it the fallback keeps the common case simple.

<div id="mc-alu-demo" class="makerchip-embed-small"></div>

Watch the ALU cycle through its operations on a fixed pair of inputs, 12 and 10. Add gives 22, subtract gives 2, and the bitwise operations do their bit-parallel thing.

## The operand multiplexer

The one genuinely new idea in this module is small but important: the ALU's second input is not always a register.

For `add x3, x1, x2` it is register `x2`. For `addi x2, x0, 1` it is the immediate `1`. The decoder already worked out which, and handed you `use_imm`. All you do is obey it:

```
$operand2[31:0] = $use_imm ? $imm : $rs2_val;
```

A single multiplexer, driven by a single control bit. This is the moment where the decode signals from Module 4.3 stop being abstract and start steering real data. Every control signal in a processor eventually reaches a MUX like this one.

## The register file

The register file holds the processor's working registers. RISC-V has 32 of them, and each is a register exactly like the ones from Module 2.1: it holds its value until something writes a new one.

```
$x1[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd1) ? $alu_out : >>1$x1;
$x2[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd2) ? $alu_out : >>1$x2;
$x3[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd3) ? $alu_out : >>1$x3;
```

Each register asks the same question: is this instruction writing, and is it writing to *me*? If so, take the ALU result. Otherwise, hold. That is the write side. The read side is the MUX you built for the register file back in Module 3.1: given a register number, return its value.

!!! note "Thirty-two registers, and the case for hierarchy"

    Written out this way, the register file is thirty-two nearly identical
    lines, and the read MUX is a thirty-two-way ternary. It works, and it is
    exactly the pattern you built at smaller scale in Module 3.1. But it is
    also precisely the kind of mechanical repetition that a language feature
    should be able to collapse.

    TL-Verilog can. Its **hierarchy** construct lets you describe *one* register
    and instantiate it many times, `/reg[31:0]`, so the whole file becomes a
    few lines regardless of how many registers there are. That is the feature
    this block is named for, and a register file is its natural home. We build
    the file explicitly here so that every read and write is visible while the
    idea is new, the same reason we built memory by hand in Block 3. If you want
    to see the compact form, it is a natural "make it your own" once the CPU
    works.

## x0 is always zero

RISC-V reserves register `x0` for a permanent zero. Read it and you always get 0. Write to it and the write is silently discarded.

This sounds like a waste of a register and is one of the most useful decisions in the ISA. A guaranteed zero means you do not need separate instructions to load a small constant, clear a register, or copy a value: `addi x5, x0, 42` loads 42, `add x5, x1, x0` copies `x1`, and a branch against `x0` compares against zero. One reserved register removes a whole handful of instructions from the design.

In hardware, honouring it is one line: `x0` is not a register at all, it is the constant 0.

```
$x0[31:0] = 32'd0;   // never written, never changes
```

## Watch it break: a writable x0

Here is what happens if you forget, and treat `x0` as an ordinary register:

<div id="mc-datapath-bug" class="makerchip-embed-small"></div>

The program runs `addi x0, x0, 5`. The correct `$x0_ok` stays 0. The buggy `$x0_bad` becomes 5, and from that moment every instruction that reads `x0` expecting zero, which in real code is *many* of them, gets 5 instead. A loop that should compare against zero compares against five. A cleared register is not clear. The bug is catastrophic and, like the decode bug in the last module, completely silent at the point it happens.

## Your first working CPU

The VIZ at the top of this page is the whole thing, running. Fetch, decode, execute, writeback, wired together, stepping through a real program: load 5 into x1, load 3 into x2, add them into x3, subtract into x3, XOR into x4.

Watch the registers on the left fill in as the program runs. Purple means a register is being read this step; green means it is being written. Follow one instruction all the way across: the two operands leave the register file, the MUX picks the second one, the ALU combines them, and the green arrow carries the answer back. That is a processor. You built it.

Step through it a cycle at a time with the time slider and read each instruction as it executes. When `add x3, x1, x2` comes up, you should see x1 and x2 light purple, the ALU show `5 + 3`, and x3 light green with 8.

<div id="mc-datapath-demo" class="makerchip-embed-small"></div>

The demo above is the same CPU with the visualization stripped away, so you can watch the register values directly in the waveform. Set them to decimal. Over the five instructions, x1 settles at 5, x2 at 3, x3 at 8 and then 2, and x4 at 6.

## Your turn: build the execute stage

Fetch and decode are wired for you below. Build the part that runs the instruction: read the source registers, choose the second operand, compute, and write the result into x3. The program adds 5 and 3 and should leave 8 in x3.

<div id="mc-datapath-exercise" class="makerchip-embed"></div>

??? tip "Hint"

    **The register reads** are the read MUX from Module 3.1: given the number in
    `$rs1`, hand back that register's value, using `>>1` to read last cycle's
    value. `x0` returns 0.

    **The operand MUX** is one ternary on `$use_imm`, exactly as shown earlier
    in this module.

    **The ALU** only needs addition for this program, so `$rs1_val + $operand2`
    is enough here.

    **The writeback** for x3 is the same shape as the x1 and x2 lines already
    written for you: write when `$rf_wr` is high and `$rd` is 3, otherwise hold.

??? success "Solution"

    ```
    $rs1_val[31:0] = ($rs1 == 5'd1) ? >>1$x1 : ($rs1 == 5'd2) ? >>1$x2 : ($rs1 == 5'd3) ? >>1$x3 : 32'd0;
    $rs2_val[31:0] = ($rs2 == 5'd1) ? >>1$x1 : ($rs2 == 5'd2) ? >>1$x2 : ($rs2 == 5'd3) ? >>1$x3 : 32'd0;

    $operand2[31:0] = $use_imm ? $imm : $rs2_val;

    $alu_out[31:0] = $rs1_val + $operand2;

    $x3[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd3) ? $alu_out : >>1$x3;
    ```

    Set x1, x2 and x3 to decimal in the waveform. You should watch x1 become 5,
    then x2 become 3, then x3 become 8. If x3 stays 0, check that your `$rd`
    comparison uses 3 and that `$rs1_val` and `$rs2_val` are reading `>>1` of the
    registers rather than the current cycle.

## Where this fits next

You have a processor. It reads instructions from memory, decodes them, computes, and writes results back. For straight-line arithmetic it is complete and correct.

What it cannot do yet is make a decision or touch memory. Every program so far runs top to bottom, once. In Module 4.5 you will add the last two capabilities: **branches**, which let the PC jump based on a comparison, turning a list of instructions into loops and conditionals, and **loads and stores**, which let the processor reach the data memory. With those, the CPU is Turing-complete, and the sum-1-to-10 program from the start of the block will finally run to completion.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| Register read | `($rs1 == N) ? >>1$xN : ...` | Read MUX, one per read port |
| Operand MUX | `$use_imm ? $imm : $rs2_val` | Register or immediate |
| ALU | `($alu_op == N) ? ... ` | Select the operation |
| Writeback | `($rf_wr && $rd == N) ? $alu_out : >>1$xN` | Write when addressed |
| x0 | `32'd0` | Hardwired zero, never written |

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

  if (document.getElementById('mc-datapath-viz')) {
    VizOnlyIDE.create('mc-datapath-viz', { codeURL: base + 'datapath-viz.tlv' });
  }
  if (document.getElementById('mc-alu-demo')) {
    WaveformOnlyIDE.create('mc-alu-demo', { codeURL: base + 'alu-demo.tlv' });
  }
  if (document.getElementById('mc-datapath-bug')) {
    WaveformOnlyIDE.create('mc-datapath-bug', { codeURL: base + 'datapath-bug.tlv' });
  }
  if (document.getElementById('mc-datapath-demo')) {
    WaveformOnlyIDE.create('mc-datapath-demo', { codeURL: base + 'datapath-demo.tlv' });
  }
  if (document.getElementById('mc-datapath-exercise')) {
    EditorWaveformIDE.create('mc-datapath-exercise', { codeURL: base + 'datapath-exercise.tlv' });
  }
</script>
