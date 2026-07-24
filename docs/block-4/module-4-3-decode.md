# Module 4.3: Decode

**Block 4 — Building a Processor**  
**Estimated time:** 70–85 minutes  
**Prerequisites:** Module 4.2 — Instructions

<div id="mc-decode-viz" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to turn raw instruction fields into **control signals**, explain how `opcode`, `funct3` and `funct7` narrow an instruction down step by step, build a decoder that identifies every instruction in our subset, and work out which datapath control signals a given instruction needs. This is the module where your hardware stops holding numbers and starts holding meaning.

## From bits to meaning

After Module 4.2 your processor can slice an instruction into fields. It has `opcode = 0110011` sitting on a wire. And it still has no idea what to do, because a bit pattern is not an instruction until something *interprets* it.

That something is the **decoder**, and its job is to answer questions the rest of the machine needs answered:

- Is this an arithmetic instruction, a branch, or a memory access?
- Which exact operation is it?
- Should the ALU's second input come from a register or from the immediate?
- Should the result be written back to a register, or thrown away?

Each answer is a **control signal**: usually a single bit that steers one part of the datapath. The decoder produces them all, and every other block in the processor obeys them.

You have built this before, incidentally. In Module 1.3 you made a decoder that turned a binary number into a one-hot set of outputs, exactly one line high. That is precisely what this is, just with a wider input and more meaningful output names.

## Narrowing down, one field at a time

RISC-V identifies an instruction in up to three steps, and the design is deliberately hierarchical.

**Step one: the opcode** says what *kind* of instruction this is. That is one comparison per kind:

```
$is_r_type = $opcode == 7'b0110011;   // register-to-register arithmetic
$is_i_alu  = $opcode == 7'b0010011;   // arithmetic with an immediate
$is_load   = $opcode == 7'b0000011;
$is_store  = $opcode == 7'b0100011;
$is_branch = $opcode == 7'b1100011;
```

**Step two: `funct3`** picks the operation within that kind. All five branch instructions share one opcode and are told apart entirely by `funct3`:

```
$is_beq = $is_branch && ($funct3 == 3'b000);
$is_bne = $is_branch && ($funct3 == 3'b001);
$is_blt = $is_branch && ($funct3 == 3'b100);
```

**Step three: `funct7`**, only when `funct3` is not enough. This happens exactly once in our subset, and it is worth knowing why.

`add` and `sub` are both R-type, and they *both* use `funct3 = 000`. Nothing in the opcode or `funct3` distinguishes them. The only difference is bit 30, which lives in `funct7`:

```
$is_add = $is_r_type && ($funct3 == 3'b000) && ($funct7 == 7'b0000000);
$is_sub = $is_r_type && ($funct3 == 3'b000) && ($funct7 == 7'b0100000);
```

That looks like an oversight and is actually deliberate. Addition and subtraction share almost all their hardware, a subtractor is an adder with one input inverted, so RISC-V encodes them as the *same* operation with a modifier bit rather than as two unrelated instructions. The single bit that flips `add` into `sub` is the same bit that flips the adder into subtract mode. The encoding mirrors the hardware.

Here is the whole narrowing process as a picture. Each level asks about one more field, and the path you take through the tree *is* the decode:

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 740 320" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="dec-arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#4A3060" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <text x="75" y="26" fill="#4A3060" font-size="10" text-anchor="middle">the instruction</text>
  <text x="230" y="26" fill="#ef4444" font-size="10" text-anchor="middle">ask the opcode</text>
  <text x="425" y="26" fill="#eab308" font-size="10" text-anchor="middle">ask funct3</text>
  <text x="620" y="26" fill="#6D5A8A" font-size="10" text-anchor="middle">ask funct7</text>

  <rect x="20" y="140" width="110" height="44" rx="6" fill="#1A0533" stroke="#B39DDB" stroke-width="2"/>
  <text x="75" y="167" fill="#EDE7F6" font-size="12" text-anchor="middle">32 bits</text>

  <rect x="170" y="52" width="120" height="38" rx="5" fill="#3B1616" stroke="#ef4444" stroke-width="1.6"/>
  <text x="230" y="70" fill="#ef4444" font-size="10" text-anchor="middle">0110011</text>
  <text x="230" y="83" fill="#6D5A8A" font-size="9" text-anchor="middle">R-type</text>

  <rect x="170" y="152" width="120" height="38" rx="5" fill="#3B1616" stroke="#ef4444" stroke-width="1.6"/>
  <text x="230" y="170" fill="#ef4444" font-size="10" text-anchor="middle">0010011</text>
  <text x="230" y="183" fill="#6D5A8A" font-size="9" text-anchor="middle">I-type ALU</text>

  <rect x="170" y="242" width="120" height="38" rx="5" fill="#3B1616" stroke="#ef4444" stroke-width="1.6"/>
  <text x="230" y="260" fill="#ef4444" font-size="10" text-anchor="middle">1100011</text>
  <text x="230" y="273" fill="#6D5A8A" font-size="9" text-anchor="middle">branch</text>

  <rect x="350" y="34" width="110" height="32" rx="5" fill="#3B3312" stroke="#eab308" stroke-width="1.6"/>
  <text x="405" y="54" fill="#eab308" font-size="10" text-anchor="middle">funct3 000</text>
  <rect x="350" y="88" width="110" height="32" rx="5" fill="#3B3312" stroke="#eab308" stroke-width="1.6"/>
  <text x="405" y="108" fill="#eab308" font-size="10" text-anchor="middle">funct3 111</text>
  <rect x="350" y="155" width="110" height="32" rx="5" fill="#3B3312" stroke="#eab308" stroke-width="1.6"/>
  <text x="405" y="175" fill="#eab308" font-size="10" text-anchor="middle">funct3 000</text>
  <rect x="350" y="245" width="110" height="32" rx="5" fill="#3B3312" stroke="#eab308" stroke-width="1.6"/>
  <text x="405" y="265" fill="#eab308" font-size="10" text-anchor="middle">funct3 100</text>

  <rect x="530" y="14" width="100" height="30" rx="5" fill="#14331A" stroke="#22c55e" stroke-width="1.8"/>
  <text x="580" y="33" fill="#22c55e" font-size="11" font-weight="bold" text-anchor="middle">ADD</text>
  <rect x="530" y="56" width="100" height="30" rx="5" fill="#14331A" stroke="#22c55e" stroke-width="1.8"/>
  <text x="580" y="75" fill="#22c55e" font-size="11" font-weight="bold" text-anchor="middle">SUB</text>
  <rect x="530" y="89" width="100" height="30" rx="5" fill="#14331A" stroke="#22c55e" stroke-width="1.8"/>
  <text x="580" y="108" fill="#22c55e" font-size="11" font-weight="bold" text-anchor="middle">AND</text>
  <rect x="530" y="156" width="100" height="30" rx="5" fill="#14331A" stroke="#22c55e" stroke-width="1.8"/>
  <text x="580" y="175" fill="#22c55e" font-size="11" font-weight="bold" text-anchor="middle">ADDI</text>
  <rect x="530" y="246" width="100" height="30" rx="5" fill="#14331A" stroke="#22c55e" stroke-width="1.8"/>
  <text x="580" y="265" fill="#22c55e" font-size="11" font-weight="bold" text-anchor="middle">BLT</text>

  <path d="M130 155 L166 75" fill="none" stroke="#4A3060" stroke-width="1.2" marker-end="url(#dec-arr)"/>
  <path d="M130 162 L166 171" fill="none" stroke="#4A3060" stroke-width="1.2" marker-end="url(#dec-arr)"/>
  <path d="M130 172 L166 258" fill="none" stroke="#4A3060" stroke-width="1.2" marker-end="url(#dec-arr)"/>

  <path d="M290 66 L346 52" fill="none" stroke="#4A3060" stroke-width="1.2" marker-end="url(#dec-arr)"/>
  <path d="M290 76 L346 104" fill="none" stroke="#4A3060" stroke-width="1.2" marker-end="url(#dec-arr)"/>
  <path d="M290 171 L346 171" fill="none" stroke="#4A3060" stroke-width="1.2" marker-end="url(#dec-arr)"/>
  <path d="M290 261 L346 261" fill="none" stroke="#4A3060" stroke-width="1.2" marker-end="url(#dec-arr)"/>

  <path d="M460 46 L526 32" fill="none" stroke="#6D5A8A" stroke-width="1.2" marker-end="url(#dec-arr)"/>
  <path d="M460 56 L526 68" fill="none" stroke="#6D5A8A" stroke-width="1.2" marker-end="url(#dec-arr)"/>
  <text x="495" y="24" fill="#6D5A8A" font-size="8" text-anchor="middle">0000000</text>
  <text x="495" y="84" fill="#6D5A8A" font-size="8" text-anchor="middle">0100000</text>

  <path d="M460 104 L526 104" fill="none" stroke="#4A3060" stroke-width="1.2" stroke-dasharray="3,3" marker-end="url(#dec-arr)"/>
  <path d="M460 171 L526 171" fill="none" stroke="#4A3060" stroke-width="1.2" stroke-dasharray="3,3" marker-end="url(#dec-arr)"/>
  <path d="M460 261 L526 261" fill="none" stroke="#4A3060" stroke-width="1.2" stroke-dasharray="3,3" marker-end="url(#dec-arr)"/>

  <text x="370" y="305" fill="#4A3060" font-size="10" text-anchor="middle">dashed = funct3 was already enough, no funct7 needed</text>
</svg>
</div>

The VIZ at the top of this page steps through eight instructions and lights up exactly one control signal for each. Watch how the opcode narrows the field and `funct3` finishes the job.

## The signals the datapath actually needs

Knowing *which* instruction you are holding is not the end of it. The rest of the processor needs a handful of yes-or-no answers, and those are the signals that do the real steering.

**`$rf_wr`, write to a register?** Arithmetic instructions and loads produce a value worth keeping. Stores and branches do not: a store sends its value to memory, and a branch changes the PC. Getting this wrong means a branch quietly overwriting a register it has no business touching.

```
$rf_wr = $is_r_type || $is_i_alu || $is_load;
```

**`$use_imm`, where does the ALU's second input come from?** For `add x1, x1, x2` it is register `rs2`. For `addi x2, x2, 1` it is the immediate. This single bit drives a multiplexer sitting on the ALU's second input, and it is the clearest example in the whole processor of a control signal steering a MUX.

```
$use_imm = $is_i_alu || $is_load || $is_store;
```

Notice that loads and stores use the immediate too, because `lw x6, 0(x1)` means "add 0 to register x1 and use that as the address." The address calculation is an addition like any other.

<div id="mc-decode-demo" class="makerchip-embed-small"></div>

Run the decoder against the real program and watch `$rf_wr` drop low on exactly one instruction: the `blt` at the end. Every other instruction in this program produces a value; the branch does not.

## The full instruction set

Here is every instruction your processor will support, with everything the decoder needs to identify it. Keep this table to hand: you will use it again in Modules 4.4 and 4.5 and in the project.

| Instruction | Meaning | Format | opcode | funct3 | funct7 |
| --- | --- | --- | --- | --- | --- |
| `add rd, rs1, rs2` | rd = rs1 + rs2 | R | `0110011` | `000` | `0000000` |
| `sub rd, rs1, rs2` | rd = rs1 − rs2 | R | `0110011` | `000` | `0100000` |
| `xor rd, rs1, rs2` | rd = rs1 ^ rs2 | R | `0110011` | `100` | `0000000` |
| `or rd, rs1, rs2` | rd = rs1 \| rs2 | R | `0110011` | `110` | `0000000` |
| `and rd, rs1, rs2` | rd = rs1 & rs2 | R | `0110011` | `111` | `0000000` |
| `addi rd, rs1, imm` | rd = rs1 + imm | I | `0010011` | `000` | — |
| `lw rd, imm(rs1)` | rd = mem[rs1 + imm] | I | `0000011` | `010` | — |
| `sw rs2, imm(rs1)` | mem[rs1 + imm] = rs2 | S | `0100011` | `010` | — |
| `beq rs1, rs2, off` | branch if rs1 == rs2 | B | `1100011` | `000` | — |
| `bne rs1, rs2, off` | branch if rs1 != rs2 | B | `1100011` | `001` | — |
| `blt rs1, rs2, off` | branch if rs1 < rs2 | B | `1100011` | `100` | — |

Eleven instructions. That is not many, and it is genuinely enough to compute anything computable: you have arithmetic, logic, memory access and conditional control flow. Real RV32I adds about thirty more, mostly variations on these (different comparison directions, byte and halfword memory access, jumps, shifts). None of them introduce a new *idea*; they are more of the same pattern, which is exactly what makes RISC-V pleasant to implement.

??? note "What about instructions you don't recognise?"

    Our decoder answers "which of these eleven is it?" and quietly says no to
    everything else. Feed it a `mul` instruction and every control signal reads
    zero: nothing executes, nothing is written, the PC moves on.

    Real processors do not shrug like that. They detect an **illegal
    instruction** and raise an exception, handing control to the operating
    system, which usually ends the offending program. That matters because
    silently ignoring instructions is a security and correctness disaster: code
    would behave differently depending on which chip ran it.

    Adding it is not conceptually hard, one more control signal that is high
    when no instruction matched, wired to exception logic. Exceptions are out of
    scope here, but it is worth knowing that the gap exists, and that "does
    nothing" is a teaching simplification rather than how real silicon behaves.

## Watch it break: forgetting funct7

Here is the mistake almost everyone makes when writing their first decoder. This design checks the opcode and `funct3` and stops there:

```
$sloppy_add = $is_r_type && ($funct3 == 3'b000);   // no funct7 check
```

<div id="mc-decode-bug" class="makerchip-embed-small"></div>

The design alternates between `add x1, x1, x2` and `sub x3, x1, x2`. Watch the three signals. `$good_add` and `$good_sub` take turns as they should. `$sloppy_add` **stays high the whole time**, because as far as it can tell, `sub` is an `add`.

Sit with what that does to a running program. There is no crash and no error. The processor cheerfully executes `sub` as `add`, and a number that should have gone down goes up instead. The symptom appears wherever that value is eventually used, which could be hundreds of instructions later. A decoder bug does not announce itself, it just quietly makes your machine compute the wrong thing.

The habit worth building: whenever two instructions share an opcode *and* a `funct3`, something else has to separate them. Go and find out what.

## Debugging tip: Nav-TLV for control signals

A decoder is a wide, flat pile of one-line assignments, and the Waveform shows them as a wall of single-bit rows that all look identical. When one of them is wrong, scanning that wall is miserable.

**Nav-TLV** is much better suited to this. It presents your design as a browsable tree of signals with their logic attached, so you can click straight to `$is_sub` and read the expression that drives it, rather than hunting for its row and then flipping back to the editor to see what feeds it.

The workflow that works well here: use the Waveform to spot *that* a control signal is wrong on some cycle, then jump to Nav-TLV to read the expression and check it against the encoding table. For decoders specifically, the bug is nearly always in the expression rather than in the timing, so getting to the expression fast is what matters.

## Your turn: build the decoder

Four instructions cycle past below: `add`, `sub`, `addi` and `blt`. Identify the instruction kinds from the opcode, then the exact instructions, then work out `$rf_wr`.

<div id="mc-decode-exercise" class="makerchip-embed"></div>

??? tip "Hint"

    The kinds are single comparisons against the opcode values given in the
    comments.

    For the exact instructions, start from the kind and add conditions with
    `&&`. Three of the four need only `funct3` on top of the kind. One of them
    needs more, and the section above explains which and why.

    For `$rf_wr`, ask of each instruction: does it produce a value that belongs
    in a register afterwards? Three of these do. One of them changes the PC
    instead and leaves the registers alone.

??? success "Solution"

    ```
    $is_r_type = $opcode == 7'b0110011;
    $is_i_alu  = $opcode == 7'b0010011;
    $is_branch = $opcode == 7'b1100011;

    $is_add  = $is_r_type && ($funct3 == 3'b000) && ($funct7 == 7'b0000000);
    $is_sub  = $is_r_type && ($funct3 == 3'b000) && ($funct7 == 7'b0100000);
    $is_addi = $is_i_alu  && ($funct3 == 3'b000);
    $is_blt  = $is_branch && ($funct3 == 3'b100);

    $rf_wr = $is_r_type || $is_i_alu;
    ```

    In the waveform, exactly one of the four instruction signals should be high
    at any time. If two are ever high together, you are missing a `funct7`
    check. If none is high, check the opcode constants.

    `$rf_wr` is low only for the branch, which is the whole point: `blt` decides
    where to go next, it does not compute a value to keep.

## Where this fits next

The decoder now tells the rest of the machine what to do. What is missing is a machine to tell.

In Module 4.4 you will wire in the last two pieces from the map: the **register file** holding the 32 registers, and the **ALU** doing the arithmetic. Connect those to the control signals you just built and something remarkable happens. The processor runs. By the end of the next module you will have a CPU that executes real instructions and leaves real answers in real registers.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| Instruction kind | `$opcode == 7'b0110011` | One comparison per opcode |
| Exact instruction | `$is_r_type && $funct3 == ...` | Narrow with funct3 |
| add vs sub | `$funct7 == 7'b0100000` | Only funct7 separates them |
| Register write | `$is_r_type \|\| $is_i_alu \|\| $is_load` | Which instructions keep a result |
| Operand select | `$use_imm` | Register or immediate into the ALU |

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

  if (document.getElementById('mc-decode-viz')) {
    VizOnlyIDE.create('mc-decode-viz', { codeURL: base + 'decode-viz.tlv' });
  }
  if (document.getElementById('mc-decode-demo')) {
    WaveformOnlyIDE.create('mc-decode-demo', { codeURL: base + 'decode-demo.tlv' });
  }
  if (document.getElementById('mc-decode-bug')) {
    WaveformOnlyIDE.create('mc-decode-bug', { codeURL: base + 'decode-bug.tlv' });
  }
  if (document.getElementById('mc-decode-exercise')) {
    EditorWaveformIDE.create('mc-decode-exercise', { codeURL: base + 'decode-exercise.tlv' });
  }
</script>
