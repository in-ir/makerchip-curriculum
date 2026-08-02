# Module 4.1: Anatomy of a Processor

**Block 4 — Building a Processor**  
**Estimated time:** 65–80 minutes  
**Prerequisites:** Block 3 — Memory and Arrays

<div id="mc-pc-viz" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to describe the fetch, decode, execute cycle that every processor runs, name the parts a processor is built from and say where each one came from, explain why a program counter counts by four instead of one, and build a complete **fetch stage**: a program counter wired to an instruction memory, pulling a real RISC-V program out of storage one instruction per cycle.

## What a processor actually is

Strip away everything you have heard about processors and one sentence is left: **a processor is a machine that reads numbers out of memory and does what they say.**

That is the whole idea. A program is a list of numbers sitting in memory. The processor picks up the first number, works out what it means, does it, then picks up the next one. Over and over, billions of times a second. Nothing in that loop is beyond what you have already built.

The loop has three steps, and they have names you will see everywhere:

**Fetch.** Go to memory and get the next instruction.
**Decode.** Work out what that instruction is asking for.
**Execute.** Do it.

Then repeat. That is called the **fetch-decode-execute cycle**, and it is the heartbeat of every processor ever made, from the chip in a microwave to the one in a data centre.

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 720 260" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="cpu-arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <!-- PC -->
  <rect x="40" y="95" width="110" height="60" rx="8" fill="#1A0533" stroke="#eab308" stroke-width="2"/>
  <text x="95" y="120" fill="#eab308" font-size="13" font-weight="bold" text-anchor="middle">PC</text>
  <text x="95" y="139" fill="#4A3060" font-size="10" text-anchor="middle">which one?</text>

  <!-- IMEM -->
  <rect x="215" y="95" width="130" height="60" rx="8" fill="#1A0533" stroke="#7C4DFF" stroke-width="2"/>
  <text x="280" y="120" fill="#7C4DFF" font-size="13" font-weight="bold" text-anchor="middle">FETCH</text>
  <text x="280" y="139" fill="#4A3060" font-size="10" text-anchor="middle">read instruction</text>

  <!-- DECODE -->
  <rect x="410" y="95" width="130" height="60" rx="8" fill="#1A0533" stroke="#7C4DFF" stroke-width="2"/>
  <text x="475" y="120" fill="#7C4DFF" font-size="13" font-weight="bold" text-anchor="middle">DECODE</text>
  <text x="475" y="139" fill="#4A3060" font-size="10" text-anchor="middle">what does it mean?</text>

  <!-- EXECUTE -->
  <rect x="595" y="95" width="90" height="60" rx="8" fill="#1A0533" stroke="#22c55e" stroke-width="2"/>
  <text x="640" y="120" fill="#22c55e" font-size="13" font-weight="bold" text-anchor="middle">EXECUTE</text>
  <text x="640" y="139" fill="#4A3060" font-size="10" text-anchor="middle">do it</text>

  <!-- arrows across -->
  <line x1="150" y1="125" x2="211" y2="125" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#cpu-arr)"/>
  <line x1="345" y1="125" x2="406" y2="125" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#cpu-arr)"/>
  <line x1="540" y1="125" x2="591" y2="125" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#cpu-arr)"/>

  <!-- feedback loop -->
  <path d="M640 155 L640 215 L95 215 L95 159" fill="none" stroke="#eab308" stroke-width="1.5" stroke-dasharray="5,4" marker-end="url(#cpu-arr)"/>
  <text x="367" y="235" fill="#eab308" font-size="11" text-anchor="middle">then the PC moves on, and the whole thing runs again</text>

  <text x="360" y="45" fill="#4A3060" font-size="12" text-anchor="middle">one trip around this loop = one instruction</text>
</svg>
</div>

## The map of the machine

Those three words, fetch, decode, execute, describe what a processor *does*. Here is what it is *made of*, and where each piece comes from. This is the machine you will finish this block having built:

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 720 330" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="dp-arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#B39DDB" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <rect x="24" y="70" width="86" height="56" rx="7" fill="#3B1D6D" stroke="#eab308" stroke-width="2"/>
  <text x="67" y="94" fill="#eab308" font-size="12" font-weight="bold" text-anchor="middle">PC</text>
  <text x="67" y="110" fill="#B39DDB" font-size="9" text-anchor="middle">counter</text>
  <text x="67" y="142" fill="#22c55e" font-size="9" text-anchor="middle">4.1</text>

  <rect x="140" y="70" width="108" height="56" rx="7" fill="#3B1D6D" stroke="#eab308" stroke-width="2"/>
  <text x="194" y="94" fill="#eab308" font-size="12" font-weight="bold" text-anchor="middle">INSTR MEM</text>
  <text x="194" y="110" fill="#B39DDB" font-size="9" text-anchor="middle">the program</text>
  <text x="194" y="142" fill="#22c55e" font-size="9" text-anchor="middle">4.1</text>

  <rect x="278" y="70" width="108" height="56" rx="7" fill="#1A0533" stroke="#7C4DFF" stroke-width="2"/>
  <text x="332" y="94" fill="#7C4DFF" font-size="12" font-weight="bold" text-anchor="middle">DECODER</text>
  <text x="332" y="110" fill="#4A3060" font-size="9" text-anchor="middle">what to do</text>
  <text x="332" y="142" fill="#4A3060" font-size="9" text-anchor="middle">4.3</text>

  <rect x="416" y="70" width="108" height="56" rx="7" fill="#1A0533" stroke="#7C4DFF" stroke-width="2"/>
  <text x="470" y="94" fill="#7C4DFF" font-size="12" font-weight="bold" text-anchor="middle">REG FILE</text>
  <text x="470" y="110" fill="#4A3060" font-size="9" text-anchor="middle">32 registers</text>
  <text x="470" y="142" fill="#4A3060" font-size="9" text-anchor="middle">4.4</text>

  <rect x="554" y="70" width="86" height="56" rx="7" fill="#1A0533" stroke="#7C4DFF" stroke-width="2"/>
  <text x="597" y="94" fill="#7C4DFF" font-size="12" font-weight="bold" text-anchor="middle">ALU</text>
  <text x="597" y="110" fill="#4A3060" font-size="9" text-anchor="middle">the maths</text>
  <text x="597" y="142" fill="#4A3060" font-size="9" text-anchor="middle">4.4</text>

  <rect x="416" y="216" width="108" height="52" rx="7" fill="#1A0533" stroke="#7C4DFF" stroke-width="2"/>
  <text x="470" y="238" fill="#7C4DFF" font-size="12" font-weight="bold" text-anchor="middle">DATA MEM</text>
  <text x="470" y="254" fill="#4A3060" font-size="9" text-anchor="middle">load and store</text>
  <text x="470" y="284" fill="#4A3060" font-size="9" text-anchor="middle">4.5</text>

  <line x1="110" y1="98" x2="136" y2="98" stroke="#eab308" stroke-width="1.6" marker-end="url(#dp-arr)"/>
  <line x1="248" y1="98" x2="274" y2="98" stroke="#B39DDB" stroke-width="1.6" marker-end="url(#dp-arr)"/>
  <line x1="386" y1="98" x2="412" y2="98" stroke="#B39DDB" stroke-width="1.6" marker-end="url(#dp-arr)"/>
  <line x1="524" y1="98" x2="550" y2="98" stroke="#B39DDB" stroke-width="1.6" marker-end="url(#dp-arr)"/>

  <path d="M597 126 L597 180 L470 180 L470 212" fill="none" stroke="#B39DDB" stroke-width="1.3" marker-end="url(#dp-arr)"/>
  <path d="M640 98 L672 98 L672 40 L470 40 L470 66" fill="none" stroke="#B39DDB" stroke-width="1.3" stroke-dasharray="4,3" marker-end="url(#dp-arr)"/>
  <text x="560" y="34" fill="#4A3060" font-size="9" text-anchor="middle">write the result back</text>

  <path d="M597 126 L597 300 L67 300 L67 130" fill="none" stroke="#ef4444" stroke-width="1.3" stroke-dasharray="5,4" marker-end="url(#dp-arr)"/>
  <text x="300" y="316" fill="#ef4444" font-size="9" text-anchor="middle">branches: the ALU decides where the PC goes next  (4.5)</text>

  <text x="360" y="20" fill="#B39DDB" font-size="11" text-anchor="middle">yellow = built in this module</text>
</svg>
</div>

Five boxes and some wires. That is a processor. Two of them, the PC and instruction memory, you will build before you finish this page.


## The program counter

Something has to keep track of *which* instruction is next. That something is the **program counter**, almost always written **PC**. It holds the memory address of the instruction currently being executed, and after each instruction it moves along to the next one.

If that sounds like a counter, that is because it is one. You built counters in Module 2.2. The PC is the same circuit with a more important job:

```
$pc[31:0] = *reset ? 32'd0 : >>1$pc + 32'd4;
```

On reset it points at address 0, the top of the program. Every cycle after that it advances. That is the entire program counter.

## Why four, not one?

Look at that `+ 32'd4` again, because it is the detail that trips up everyone meeting this for the first time.

Memory is addressed in **bytes**. Address 0 is one byte, address 1 is the next byte, and so on. But a RISC-V instruction is not one byte, it is **32 bits, which is four bytes**. So an instruction sitting at address 0 occupies addresses 0, 1, 2 and 3. The next instruction starts at address 4.

That is why the PC steps by 4. It is not counting instructions, it is counting *bytes*, and each instruction is four of them.

```
address 0  ->  instruction 0
address 4  ->  instruction 1
address 8  ->  instruction 2
address 12 ->  instruction 3
```

Since instructions are always 4 bytes apart, the bottom two bits of the PC are always zero. If you want the instruction *number* rather than its address, you divide by 4, and dividing by 4 in hardware is free: you just ignore the bottom two bits.

```
$idx[2:0] = $pc[4:2];   // pc / 4, by taking the bits above the bottom two
```

That slice is the whole division. No divider, no arithmetic, just picking different wires.

Watch the PC run below. Set its radix to decimal in the waveform and follow it: 0, 4, 8, 12, 16, 20, then back to the start.

<div id="mc-pc-demo" class="makerchip-embed-small"></div>

## Instruction memory

A program counter on its own points at nothing. The other half of fetch is the **instruction memory**: the place the program actually lives.

And here is the good news. You have built this already. An instruction memory takes an index and returns the word stored there, which is precisely the read port of the register file from Module 3.1: a chain of ternaries selecting one stored value out of many.

```
$instr[31:0] = ($idx == 3'd0) ? 32'h00000093 :
               ($idx == 3'd1) ? 32'h00100113 :
               ...
                                32'hFE314CE3;
```

The only difference from a register file is what the words *mean*. These are not data, they are instructions, and each one completely specifies an operation. `0x00100113` says "put the value 1 into register x2." You will learn to read those numbers in Module 4.2 and build the hardware that unpacks them in 4.3.

Wire the PC to that memory and you have a complete fetch stage:

<div id="mc-fetch-demo" class="makerchip-embed-small"></div>

Watch `$instr` change each cycle as the PC advances. The design also pulls out `$opcode`, the bottom seven bits, which is the field that says what *kind* of instruction this is. Notice it takes three distinct values across the program: `0010011` for the four `addi` instructions, `0110011` for the `add`, and `1100011` for the branch at the end. Your first glimpse of decoding, and it is just a bit slice.

The VIZ at the top of this page is that same fetch stage, drawn as a program listing with the `PC >` marker stepping down it.

### The idea underneath

Something here is worth sitting with, because it is one of the genuinely profound ideas in computing.

**The program is just data in memory.** There is no special "program" storage, no separate mechanism. The instructions are numbers, exactly like any other numbers, sitting in a memory built the same way as the one holding your Tetris grid. The only thing that makes them a program is that the PC is pointing at them.

That is the **stored-program computer**, and it is why a single piece of hardware can run software it has never seen. Change the numbers in memory and the same silicon does something completely different. Every general-purpose computer that has ever existed rests on that one idea.

## Watch it break: stepping by one

To feel why the 4 matters, here is a PC that steps by 1 instead:

<div id="mc-pc-bug" class="makerchip-embed-small"></div>

Watch `$idx` in the waveform. Instead of advancing every cycle, **the same instruction gets fetched four times in a row**, then the index jumps. The processor is crawling through memory one byte at a time, landing in the middle of instructions, seeing three-quarters of one instruction glued to a quarter of the next.

On a real processor this is fatal, and it is exactly what happens if a program jumps to a misaligned address. The machine starts interpreting the middle of an instruction as if it were the start of one, and executes nonsense. Being able to recognise "my PC is off by a factor of four" from a waveform is a genuinely useful debugging instinct.

## Debugging tip: step one cycle at a time

Up to now you have mostly let simulations run and looked at the result. A processor is different: it does exactly one meaningful thing per cycle, so the interesting question is almost always *"what happened on cycle 7?"*

Use the **time slider** underneath the Viz pane to step through the simulation one cycle at a time. As you drag it, the visualization redraws for that exact cycle, so you can walk the PC down the program at your own pace and watch each instruction come up. Pair that with the waveform, where the same cycle is one vertical slice, and you have the whole picture: Viz shows you *where the processor is*, the waveform shows you *what every signal was doing when it got there*.

For the rest of this block, "step to the cycle where it goes wrong and look at every signal in that column" is the debugging move you will reach for most.

## Your turn: build the fetch stage

Three blanks, and together they make a processor that reads a program. Build the program counter, convert its address into a word index, and build the instruction memory it reads from. The six instruction words are listed for you in the comments.

<div id="mc-fetch-exercise" class="makerchip-embed"></div>

??? tip "Hint"

    **The PC** is Module 2.2's wrapping counter with a different step size: reset
    to the start, wrap when you are sitting on the last instruction, otherwise
    advance. The section above tells you how far.

    **The index** needs no arithmetic at all. You want the address divided by 4,
    and the bottom two bits of the address are always zero, so the answer is a
    bit slice.

    **The memory** is the register file read port from Module 3.1 wearing a
    different hat: a chain of ternaries on `$idx`, with the last word as the
    fallback for "none of the above."

??? success "Solution"

    ```
    $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd20) ? 32'd0 : >>1$pc + 32'd4;

    $idx[2:0] = $pc[4:2];

    $instr[31:0] = ($idx == 3'd0) ? 32'h00000093 : ($idx == 3'd1) ? 32'h00100113 : ($idx == 3'd2) ? 32'h00B00193 : ($idx == 3'd3) ? 32'h002080B3 : ($idx == 3'd4) ? 32'h00110113 : 32'hFE314CE3;
    ```

    Check it in the waveform: `$instr` should show a different word each cycle,
    cycling through all six and starting over. If it changes only every fourth
    cycle, your PC is stepping by 1. If it never changes, the index is not
    tracking the PC.

## Check yourself

Answer from memory before continuing.

??? question "Why does the program counter step by 4, not by 1?"

    Because memory is addressed in bytes and a RISC-V instruction is 4 bytes
    wide. The instruction at address 0 occupies bytes 0 to 3, so the next one
    starts at address 4.

??? question "What are the three steps of the instruction cycle, in order?"

    Fetch (get the instruction from memory), decode (work out what it means),
    execute (do it). Then the PC advances and it repeats.

??? question "How do you turn a byte address into an instruction index, for free?"

    Drop the bottom two bits: `$pc[4:2]`. Since instructions are 4 bytes apart,
    dividing the address by 4 is just ignoring the two always-zero low bits, no
    arithmetic needed.

## Where this fits next

You now have a processor that can point at instructions. What it cannot do is understand them. Right now `0x00100113` is just a number to your hardware.

In Module 4.2 you will learn how RISC-V packs an entire operation, what to do, which registers to use, and what constant to use, into those 32 bits, and why the layout is designed the way it is. After that, decode turns those bits into control signals, and the machine starts doing real work.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| Program counter | `>>1$pc + 32'd4` | Address of the current instruction |
| Why +4 | instructions are 4 bytes | Memory is byte-addressed |
| Address to index | `$pc[4:2]` | Divide by 4 by dropping 2 bits |
| Instruction memory | `($idx == N) ? word : ...` | Read MUX, same as the register file |
| The cycle | fetch, decode, execute | One trip = one instruction |

<style>
.makerchip-embed       { position: relative; width: 100%; height: 500px; }
.makerchip-embed-small { position: relative; width: 100%; height: 380px; }
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

  if (document.getElementById('mc-pc-viz')) {
    VizOnlyIDE.create('mc-pc-viz', { codeURL: base + 'pc-viz.tlv' });
  }
  if (document.getElementById('mc-pc-demo')) {
    WaveformOnlyIDE.create('mc-pc-demo', { codeURL: base + 'pc-demo.tlv' });
  }
  if (document.getElementById('mc-pc-bug')) {
    WaveformOnlyIDE.create('mc-pc-bug', { codeURL: base + 'pc-bug.tlv' });
  }
  if (document.getElementById('mc-fetch-demo')) {
    WaveformOnlyIDE.create('mc-fetch-demo', { codeURL: base + 'fetch-demo.tlv' });
  }
  if (document.getElementById('mc-fetch-exercise')) {
    EditorWaveformIDE.create('mc-fetch-exercise', { codeURL: base + 'fetch-exercise.tlv' });
  }
</script>
