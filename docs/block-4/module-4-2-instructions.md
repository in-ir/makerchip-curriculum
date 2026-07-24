# Module 4.2: Instructions

**Block 4 — Building a Processor**  
**Estimated time:** 65–80 minutes  
**Prerequisites:** Module 4.1 — Anatomy of a Processor

<div id="mc-instr-viz" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to read a 32-bit RISC-V instruction and say what it does, name the fields an instruction is divided into and pull each one out with a bit slice, explain why RISC-V puts those fields where it does, and sign-extend an immediate correctly, which is the one step in this module that will bite you if you skip it.

## An instruction is a number

Your processor can now fetch. Each cycle it hands you a 32-bit number like `0x00100113` and has no idea what to do with it.

That number is not arbitrary. Packed into those 32 bits is everything the hardware needs: which operation to perform, which registers to read, where to put the answer, and any constant the instruction carries. Decoding is the act of unpacking it, and the wonderful thing is that **unpacking costs nothing**. Every field is a fixed range of bits, so pulling one out is a bit slice, not a computation.

```
$opcode[6:0] = $instr[6:0];
$rd[4:0]     = $instr[11:7];
$rs1[4:0]    = $instr[19:15];
```

No gates. Just picking wires.

## The fields

Here is how RISC-V divides up those 32 bits:

| Field | Bits | What it says |
| --- | --- | --- |
| `opcode` | `[6:0]` | What *kind* of instruction this is |
| `rd` | `[11:7]` | Destination register: where the answer goes |
| `funct3` | `[14:12]` | Which operation within that kind |
| `rs1` | `[19:15]` | First source register |
| `rs2` | `[24:20]` | Second source register |
| `funct7` | `[31:25]` | Extra operation bits, when needed |

Take `add x1, x1, x2`, which encodes as `0x002080B3`. Slice it up and you get opcode `0110011` (a register-to-register operation), `rs1 = 1`, `rs2 = 2`, `rd = 1`, `funct3 = 000` and `funct7 = 0000000`. Read together: take register 1, take register 2, do the operation that `funct3=000` with `funct7=0000000` names, which is addition, and put the result in register 1.

The VIZ at the top of this page steps through the whole program showing exactly this split. Watch the coloured boxes: the values change, the boundaries never do.

<div id="mc-fields-demo" class="makerchip-embed-small"></div>

## Why the fields sit where they do

Now the part that makes RISC-V worth studying rather than just using.

An instruction set needs several *shapes* of instruction. Some take two registers (`add x1, x1, x2`). Some take one register and a constant (`addi x2, x2, 1`). Some need a branch offset. These are called **formats**, and RISC-V has a handful. Here are the four you need:

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 740 300" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <text x="20" y="40" fill="#4A3060" font-size="10">31</text>
  <text x="690" y="40" fill="#4A3060" font-size="10">0</text>

  <!-- R-type -->
  <text x="18" y="76" fill="#B39DDB" font-size="11" font-weight="bold">R</text>
  <rect x="40" y="56" width="141" height="30" rx="3" fill="#1A0533" stroke="#6D5A8A" stroke-width="1.5"/>
  <text x="110" y="76" fill="#6D5A8A" font-size="10" text-anchor="middle">funct7</text>
  <rect x="184" y="56" width="100" height="30" rx="3" fill="#14331A" stroke="#22c55e" stroke-width="1.5"/>
  <text x="234" y="76" fill="#22c55e" font-size="10" text-anchor="middle">rs2</text>
  <rect x="287" y="56" width="100" height="30" rx="3" fill="#14331A" stroke="#22c55e" stroke-width="1.5"/>
  <text x="337" y="76" fill="#22c55e" font-size="10" text-anchor="middle">rs1</text>
  <rect x="390" y="56" width="59" height="30" rx="3" fill="#3B3312" stroke="#eab308" stroke-width="1.5"/>
  <text x="420" y="76" fill="#eab308" font-size="10" text-anchor="middle">f3</text>
  <rect x="452" y="56" width="100" height="30" rx="3" fill="#2A1650" stroke="#7C4DFF" stroke-width="1.5"/>
  <text x="502" y="76" fill="#7C4DFF" font-size="10" text-anchor="middle">rd</text>
  <rect x="555" y="56" width="141" height="30" rx="3" fill="#3B1616" stroke="#ef4444" stroke-width="1.5"/>
  <text x="625" y="76" fill="#ef4444" font-size="10" text-anchor="middle">opcode</text>

  <!-- I-type -->
  <text x="18" y="126" fill="#B39DDB" font-size="11" font-weight="bold">I</text>
  <rect x="40" y="106" width="244" height="30" rx="3" fill="#0F2A38" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="162" y="126" fill="#38bdf8" font-size="10" text-anchor="middle">imm [11:0]</text>
  <rect x="287" y="106" width="100" height="30" rx="3" fill="#14331A" stroke="#22c55e" stroke-width="1.5"/>
  <text x="337" y="126" fill="#22c55e" font-size="10" text-anchor="middle">rs1</text>
  <rect x="390" y="106" width="59" height="30" rx="3" fill="#3B3312" stroke="#eab308" stroke-width="1.5"/>
  <text x="420" y="126" fill="#eab308" font-size="10" text-anchor="middle">f3</text>
  <rect x="452" y="106" width="100" height="30" rx="3" fill="#2A1650" stroke="#7C4DFF" stroke-width="1.5"/>
  <text x="502" y="126" fill="#7C4DFF" font-size="10" text-anchor="middle">rd</text>
  <rect x="555" y="106" width="141" height="30" rx="3" fill="#3B1616" stroke="#ef4444" stroke-width="1.5"/>
  <text x="625" y="126" fill="#ef4444" font-size="10" text-anchor="middle">opcode</text>

  <!-- S-type -->
  <text x="18" y="176" fill="#B39DDB" font-size="11" font-weight="bold">S</text>
  <rect x="40" y="156" width="141" height="30" rx="3" fill="#0F2A38" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="110" y="176" fill="#38bdf8" font-size="10" text-anchor="middle">imm hi</text>
  <rect x="184" y="156" width="100" height="30" rx="3" fill="#14331A" stroke="#22c55e" stroke-width="1.5"/>
  <text x="234" y="176" fill="#22c55e" font-size="10" text-anchor="middle">rs2</text>
  <rect x="287" y="156" width="100" height="30" rx="3" fill="#14331A" stroke="#22c55e" stroke-width="1.5"/>
  <text x="337" y="176" fill="#22c55e" font-size="10" text-anchor="middle">rs1</text>
  <rect x="390" y="156" width="59" height="30" rx="3" fill="#3B3312" stroke="#eab308" stroke-width="1.5"/>
  <text x="420" y="176" fill="#eab308" font-size="10" text-anchor="middle">f3</text>
  <rect x="452" y="156" width="100" height="30" rx="3" fill="#0F2A38" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="502" y="176" fill="#38bdf8" font-size="10" text-anchor="middle">imm lo</text>
  <rect x="555" y="156" width="141" height="30" rx="3" fill="#3B1616" stroke="#ef4444" stroke-width="1.5"/>
  <text x="625" y="176" fill="#ef4444" font-size="10" text-anchor="middle">opcode</text>

  <!-- B-type -->
  <text x="18" y="226" fill="#B39DDB" font-size="11" font-weight="bold">B</text>
  <rect x="40" y="206" width="141" height="30" rx="3" fill="#0F2A38" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="110" y="226" fill="#38bdf8" font-size="10" text-anchor="middle">imm hi</text>
  <rect x="184" y="206" width="100" height="30" rx="3" fill="#14331A" stroke="#22c55e" stroke-width="1.5"/>
  <text x="234" y="226" fill="#22c55e" font-size="10" text-anchor="middle">rs2</text>
  <rect x="287" y="206" width="100" height="30" rx="3" fill="#14331A" stroke="#22c55e" stroke-width="1.5"/>
  <text x="337" y="226" fill="#22c55e" font-size="10" text-anchor="middle">rs1</text>
  <rect x="390" y="206" width="59" height="30" rx="3" fill="#3B3312" stroke="#eab308" stroke-width="1.5"/>
  <text x="420" y="226" fill="#eab308" font-size="10" text-anchor="middle">f3</text>
  <rect x="452" y="206" width="100" height="30" rx="3" fill="#0F2A38" stroke="#38bdf8" stroke-width="1.5"/>
  <text x="502" y="226" fill="#38bdf8" font-size="10" text-anchor="middle">imm lo</text>
  <rect x="555" y="206" width="141" height="30" rx="3" fill="#3B1616" stroke="#ef4444" stroke-width="1.5"/>
  <text x="625" y="226" fill="#ef4444" font-size="10" text-anchor="middle">opcode</text>

  <line x1="287" y1="50" x2="287" y2="244" stroke="#22c55e" stroke-width="1" stroke-dasharray="3,3" opacity="0.6"/>
  <line x1="387" y1="50" x2="387" y2="244" stroke="#22c55e" stroke-width="1" stroke-dasharray="3,3" opacity="0.6"/>
  <line x1="555" y1="50" x2="555" y2="244" stroke="#ef4444" stroke-width="1" stroke-dasharray="3,3" opacity="0.6"/>

  <text x="368" y="268" fill="#B39DDB" font-size="11" text-anchor="middle">look down the columns: rs1, rs2, funct3 and opcode never move</text>
  <text x="368" y="288" fill="#4A3060" font-size="10" text-anchor="middle">only the immediate has to shuffle around them</text>
</svg>
</div>

Now look down the columns rather than across the rows. **`rs1` is in bits 19:15 in every single format. `rs2` is always 24:20. `funct3` is always 14:12. `opcode` is always 6:0.** They never move.

That is not a coincidence, it is the central design decision of RISC-V, and it exists for a hardware reason. Your processor can slice `rs1` and `rs2` out of the instruction and start reading those registers **before it has worked out what the instruction even is**. The register read and the decode happen at the same time, in parallel, because the register numbers are guaranteed to be in the same place regardless.

If the fields moved around, the hardware would need a multiplexer in front of the register file to pick where to look, and that MUX would sit on the critical path of every single instruction. Freezing the field positions deletes that hardware entirely.

The price is paid by the immediate, which gets chopped into whatever space is left over. The S-type immediate is split across two chunks. The B-type immediate is worse: its bits are scrambled so that each one lands, where possible, on the same wire it would occupy in another format. It looks perverse on paper, and it is the correct trade: shuffle wires once at design time, save a multiplexer on every instruction forever.

??? note "Which fields are real?"

    Slicing is unconditional, which means the hardware always produces all six
    fields even when they are meaningless. On a B-type instruction there is no
    destination register, so the bits sitting in the `rd` position are not a
    register number at all, they are part of the branch offset.

    You will see this in the VIZ: the branch instruction shows `rd = 25` and
    `funct7 = 63`, which are nonsense as register numbers. That is fine. It is
    the decoder's job, in Module 4.3, to decide which fields to *believe*, based
    on the opcode.

## Immediates and sign extension

Instructions that carry a constant, like `addi x2, x2, 1`, keep it in the **immediate** field. For an I-type that is bits 31:20, twelve bits.

But the ALU works in 32 bits. So a 12-bit immediate has to be widened, and how you widen it depends entirely on its sign.

A positive number widens by padding with zeros. `000000000001` becomes `00000000000000000000000000000001`, still 1.

A negative number is where it gets interesting. In two's complement, `111111111111` is −1. Pad that with zeros and you get `00000000000011111111111`, which is **4095**. The value has been destroyed.

The fix is to copy the top bit into every new bit. That is **sign extension**:

```
$imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:20]} : {20'd0, $instr[31:20]};
```

If the immediate's top bit is 1, fill the upper 20 bits with ones. Otherwise fill with zeros. The `{ }` braces glue bit patterns together, which is how you build a wide signal out of narrower pieces.

## Watch it break: forgetting to sign-extend

Here is the bug, side by side. `$imm_ok` sign-extends properly; `$imm_bad` always pads with zeros:

<div id="mc-imm-demo" class="makerchip-embed-small"></div>

Set both to decimal in the waveform and compare. For `0x001` and `0x7FF` they agree. Then `0xFFF` arrives: `$imm_ok` reads **−1**, `$imm_bad` reads **4095**. And `0x800` should be **−2048** but comes out as **2048**.

This is worth dwelling on because of *how* it fails. Every positive immediate in your program works perfectly. Everything looks fine. Then one loop counts down instead of up, or one branch jumps forwards instead of backwards, and the program falls apart somewhere far away from the actual mistake. Sign extension bugs are quiet, and they are quiet in exactly the way that costs hours.

## Debugging tip: hex is convenient, binary is honest

You will naturally want to read instructions in hex, and you should. `0x00100113` is far easier to hold in your head than thirty-two ones and zeros, and it is how instructions are written in every RISC-V document you will ever read. Set `$instr` to hex in the waveform.

But be aware of what hex hides. Each hex digit is exactly 4 bits, and **not one RISC-V field is 4 bits wide.** The opcode is 7, registers are 5, `funct3` is 3. So field boundaries fall in the middle of hex digits, and no digit corresponds to anything meaningful on its own.

That gives you a simple rule. Use hex to identify an instruction and compare it against a listing. Switch that one signal to binary when you need to see where a field actually starts and stops. The fastest way to confirm a slice is right is to view the instruction in binary and count.

## Your turn: take an instruction apart

The instruction `0x00B00193` is waiting below. Pull out all six fields, then build the sign-extended 32-bit immediate.

<div id="mc-instr-exercise" class="makerchip-embed"></div>

??? tip "Hint"

    The six fields are pure bit slices, and the exact ranges are listed in the
    comments. There is no arithmetic anywhere in the first part.

    For the immediate, look at the raw 12 bits first and ask whether the top one
    is set. That single bit chooses which of two padding patterns you glue on the
    front, and the section above shows the shape of the answer.

??? success "Solution"

    ```
    $opcode[6:0] = $instr[6:0];
    $rd[4:0]     = $instr[11:7];
    $funct3[2:0] = $instr[14:12];
    $rs1[4:0]    = $instr[19:15];
    $rs2[4:0]    = $instr[24:20];
    $funct7[6:0] = $instr[31:25];

    $imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:20]} : {20'd0, $instr[31:20]};
    ```

    You should get `opcode = 0010011`, `rd = 3`, `rs1 = 0`, `funct3 = 000` and
    `imm = 11`. Which reads: take register 0, add 11, store the result in
    register 3. In assembly, `addi x3, x0, 11`.

    Register `x0` in RISC-V is permanently zero, so adding to it is the standard
    way to load a constant. That is exactly what this instruction is doing, and
    it is why three of the six instructions in our program are `addi` from `x0`.

## Where this fits next

You can now take an instruction apart by hand. But slicing bits out is not the same as *understanding* them. Your hardware has `opcode = 0110011` sitting on a wire and still does not know that means "use the ALU, in add mode, and write the result to a register."

In Module 4.3 you will build the **decoder**: the logic that turns those raw fields into the control signals that steer the rest of the machine. It is the piece that turns a number into an instruction.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| Field extraction | `$instr[19:15]` | A bit slice, no logic |
| Fixed positions | `rs1`, `rs2`, `rd`, `opcode` | Same bits in every format |
| Sign extend | `$x[11] ? {20'hFFFFF, $x} : {20'd0, $x}` | Copy the top bit outward |
| Concatenation | `{a, b}` | Glue bit patterns together |
| Formats | R, I, S, B | Different shapes, aligned fields |

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

  if (document.getElementById('mc-instr-viz')) {
    VizOnlyIDE.create('mc-instr-viz', { codeURL: base + 'instr-viz.tlv' });
  }
  if (document.getElementById('mc-fields-demo')) {
    WaveformOnlyIDE.create('mc-fields-demo', { codeURL: base + 'fields-demo.tlv' });
  }
  if (document.getElementById('mc-imm-demo')) {
    WaveformOnlyIDE.create('mc-imm-demo', { codeURL: base + 'imm-demo.tlv' });
  }
  if (document.getElementById('mc-instr-exercise')) {
    EditorWaveformIDE.create('mc-instr-exercise', { codeURL: base + 'instr-exercise.tlv' });
  }
</script>
