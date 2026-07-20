# Module 3.1: Register Files

**Block 3 — Memory and Arrays**  
**Estimated time:** 50–65 minutes  
**Prerequisites:** Block 2 — Sequential Logic

<div id="mc-regfile-viz" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to explain what a register file is and why you'd want one, build a small register file from a decoder and a MUX (parts you already know), write to a chosen register by its address, read from a chosen register by its address, and use the Nav-TLV panel in Makerchip to inspect what's stored inside.

## From one register to many

In Block 2 you built registers that each held a single value. That's fine when you have one or two things to remember. But imagine you need to store sixteen values, or thirty-two, the way a real processor holds its working numbers. Writing out thirty-two separately named registers and hand-wiring each one would be miserable, and you'd still need a way to say "give me register number 19" without naming it directly.

What you want is a **register file**: a group of registers you can talk to _by number_ instead of by name. You hand it an address like "register 2," and it either stores a new value there or hands you back what's already there. It's the first real form of addressable memory, and it's the foundation for everything else in this block, including the Tetris grid.

Here's the good news: you already have every piece you need to build one.

## A register file is a decoder plus a MUX

Think about what "write to register number 2" actually requires. You need something that takes the address `2` and activates _only_ register 2's write path, leaving the others untouched. That's exactly what a **decoder** does (Block 1): turn a number into a one-hot selection.

And "read register number 2" means picking register 2's value out of all of them and passing it along. That's exactly what a **MUX** does (Block 1): choose one input out of many based on a select signal.

So a register file is nothing new. It's a decoder steering writes into a bank of Block 2 registers, and a MUX steering one of them back out as the read result.

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 720 260" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="rf-arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <!-- Write address -> decoder -->

<text x="70" y="55" fill="#4A3060" font-size="11" text-anchor="middle">wr_addr</text>
<rect x="30" y="65" width="90" height="46" rx="6" fill="#1A0533" stroke="#22c55e" stroke-width="2"/>
<text x="75" y="84" fill="#22c55e" font-size="12" font-weight="bold" text-anchor="middle">Decoder</text>
<text x="75" y="100" fill="#4A3060" font-size="9" text-anchor="middle">picks write</text>

  <!-- Registers stack -->
  <rect x="270" y="30" width="150" height="34" rx="6" fill="#1A0533" stroke="#B39DDB" stroke-width="1.5"/>
  <text x="345" y="51" fill="#EDE7F6" font-size="12" text-anchor="middle">register 0</text>
  <rect x="270" y="74" width="150" height="34" rx="6" fill="#1A0533" stroke="#B39DDB" stroke-width="1.5"/>
  <text x="345" y="95" fill="#EDE7F6" font-size="12" text-anchor="middle">register 1</text>
  <rect x="270" y="118" width="150" height="34" rx="6" fill="#1A0533" stroke="#B39DDB" stroke-width="1.5"/>
  <text x="345" y="139" fill="#EDE7F6" font-size="12" text-anchor="middle">register 2</text>
  <rect x="270" y="162" width="150" height="34" rx="6" fill="#1A0533" stroke="#B39DDB" stroke-width="1.5"/>
  <text x="345" y="183" fill="#EDE7F6" font-size="12" text-anchor="middle">register 3</text>

  <!-- decoder to registers -->
  <path d="M120 88 L266 47" fill="none" stroke="#22c55e" stroke-width="1.2" opacity="0.5" marker-end="url(#rf-arr)"/>
  <path d="M120 88 L266 91" fill="none" stroke="#22c55e" stroke-width="1.2" opacity="0.5" marker-end="url(#rf-arr)"/>
  <path d="M120 90 L266 135" fill="none" stroke="#22c55e" stroke-width="1.2" opacity="0.5" marker-end="url(#rf-arr)"/>
  <path d="M120 90 L266 179" fill="none" stroke="#22c55e" stroke-width="1.2" opacity="0.5" marker-end="url(#rf-arr)"/>

  <!-- MUX -->
  <rect x="560" y="65" width="90" height="46" rx="6" fill="#1A0533" stroke="#eab308" stroke-width="2"/>
  <text x="605" y="84" fill="#eab308" font-size="12" font-weight="bold" text-anchor="middle">MUX</text>
  <text x="605" y="100" fill="#4A3060" font-size="9" text-anchor="middle">picks read</text>

  <!-- registers to MUX -->
  <path d="M420 47 L556 82" fill="none" stroke="#eab308" stroke-width="1.2" opacity="0.5" marker-end="url(#rf-arr)"/>
  <path d="M420 91 L556 86" fill="none" stroke="#eab308" stroke-width="1.2" opacity="0.5" marker-end="url(#rf-arr)"/>
  <path d="M420 135 L556 90" fill="none" stroke="#eab308" stroke-width="1.2" opacity="0.5" marker-end="url(#rf-arr)"/>
  <path d="M420 179 L556 94" fill="none" stroke="#eab308" stroke-width="1.2" opacity="0.5" marker-end="url(#rf-arr)"/>

  <!-- read out -->

<text x="690" y="92" fill="#4A3060" font-size="11" text-anchor="middle">rd_data</text>
<line x1="650" y1="88" x2="672" y2="88" stroke="#eab308" stroke-width="1.5" marker-end="url(#rf-arr)"/>
</svg>

</div>

## Writing by address

Each register in the file gets a small guard on its write path: "only update me if the write address points at me." That guard is a comparison against the register's own number.

```
$r2[3:0] = *reset ? 4'd0 :
           ($wr_en && $wr_addr == 2'd2) ? $wr_data :
                                          >>1$r2;
```

Read it as: on reset, clear to zero. If writes are enabled _and_ the address is 2, take the new data. Otherwise hold, exactly the "conditional hold" register from Module 2.1. Every register in the file has this same shape, differing only in the number it checks against.

## Reading by address

Reading is a plain 4-to-1 MUX, the same one from Block 1, selecting on the read address:

```
$rd_data[3:0] = ($rd_addr == 2'd0) ? $r0 :
                ($rd_addr == 2'd1) ? $r1 :
                ($rd_addr == 2'd2) ? $r2 :
                                     $r3;
```

Hand it an address, get back that register's contents. That's the whole read side.

Watch it run: the VIZ at the top of this page cycles through addresses, flashing green on the register being written and yellow on the one being read.

## Debugging tip: the Nav-TLV panel

As your designs grow from a couple of signals to a whole bank of registers, the Waveform can get crowded. Makerchip's **Nav-TLV** tab (next to the Editor) shows your compiled design as a browsable tree of every signal, laid out the way your code is structured. When you're chasing a bug like "why didn't register 2 update?", Nav-TLV lets you click straight to that signal and see its logic, instead of hunting through the waveform. Open it now and find `$r2`, then trace back to the condition that feeds it. Getting comfortable moving between the Editor, Nav-TLV, and Waveform is the core loop of debugging any real design.

## Your turn: complete the read port

The four registers and all the write logic are done for you below. Complete `$rd_data` so it reads back the register selected by `$rd_addr`, using the same 4-to-1 MUX pattern from Block 1.

<div id="mc-regfile-exercise" class="makerchip-embed"></div>

## Where this fits next

A register file lets you store a handful of values and reach any of them by number. But a real playfield, or a real memory, might have hundreds or thousands of locations, far too many to write out by hand. In Module 3.2 you'll meet **RAM**: the same address-in, data-out idea, but scaled up with array syntax so you can build large memories without naming every cell.

## Quick reference

| Concept          | TL-Verilog                            | Description                        |
| ---------------- | ------------------------------------- | ---------------------------------- |
| Write by address | `($wr_addr == N) ? $wr_data : >>1$rN` | Update only the addressed register |
| Read by address  | `($rd_addr == N) ? $rN : ...`         | MUX selects the addressed register |
| Register file    | decoder + registers + MUX             | Addressable bank of registers      |

<style>
.makerchip-embed       { position: relative; width: 100%; height: 500px; }
.makerchip-embed-small { position: relative; width: 100%; height: 333px; }
</style>

<script type="module">
  import IdePlugin from 'https://beta.makerchip.com/dist/makerchip-plugin.js';

  const base = 'https://raw.githubusercontent.com/in-ir/makerchip-curriculum/main/code/block-3/';

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

  if (document.getElementById('mc-regfile-viz')) {
    VizOnlyIDE.create('mc-regfile-viz', { codeURL: base + 'regfile-viz.tlv' });
  }
  if (document.getElementById('mc-regfile-exercise')) {
    EditorWaveformIDE.create('mc-regfile-exercise', { codeURL: base + 'regfile-exercise.tlv' });
  }
</script>
