# Module 3.2: Memory (RAM)

**Block 3 — Memory and Arrays**  
**Estimated time:** 50–65 minutes  
**Prerequisites:** Module 3.1 — Register Files

<div id="mc-ram-viz" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to explain what RAM is and how it differs from a register file, describe the three signals every memory needs (address, data, write-enable), build a small RAM and write to any cell by address, understand why a write takes a cycle to appear on the read port, and use the Waveform's radix controls in Makerchip to read memory contents in whatever number format is clearest.

## From a few registers to real memory

A register file, like the one you built in Module 3.1, is perfect for a handful of values. But step back and think about scale. A screen has thousands of pixels. A game board has dozens of cells. A processor's main memory has millions of locations. You are not going to hand-write a million registers.

**RAM** (Random Access Memory) is the answer. "Random access" just means you can reach *any* location directly by its address, in any order, without stepping through the others. It's the same core idea as the register file, address in, data in or out, but built to scale to as many locations as you need. It's the storage that a game board, and eventually your Tetris playfield, lives in.

## The three signals every memory needs

Every memory, no matter how big, talks to the outside world through the same three signals:

- **Address** — which location you want to talk to.
- **Data** — the value going in (for a write) or coming out (for a read).
- **Write-enable** — a single bit that says "actually store this," versus just looking.

That write-enable bit is the important new idea. A register file wrote every cycle; a real memory needs to *choose* when to write, because most of the time you're just reading. When write-enable is low, the memory holds everything exactly as it is and simply serves up whatever you ask to read.

```
$m3[3:0] = *reset ? 4'd0 :
           ($wr_en && $wr_addr == 3'd3) ? $wr_data :
                                          >>1$m3;
```

This is one memory cell. It stores new data only when writes are enabled *and* the address points at it. Otherwise it holds. Every cell in the memory follows this identical shape, differing only in the address number it answers to.

## Watching a memory fill

The VIZ at the top of this page shows an 8-entry RAM. Each cycle the write address steps forward and stores the cycle count, so you can watch the memory fill up one cell at a time, green marks the cell being written, yellow the cell being read.

Here's the same design in the waveform, where you can see the raw address, data, and write-enable signals driving it:

<div id="mc-ram-waveform" class="makerchip-embed-small"></div>

## Debugging tip: the Waveform radix

When you're staring at a memory in the Waveform, the default display might show values in a format that's awkward for what you're doing. Makerchip lets you **right-click any signal in the Waveform and change its radix**, the number base it's displayed in: binary, hexadecimal, or decimal. When you're checking that address 5 holds the number 12, decimal is clearest. When you're about to work with the Tetris grid, where each bit is a column, binary is the only view that makes sense, you'll want to *see* the individual bits. Get in the habit of switching radix to match the question you're asking; it turns a wall of numbers into something you can actually read.

## Why the read lags the write

Remember the timing trap from Module 3.1? It applies to RAM too, and it matters even more here. When you write to an address, the new value doesn't appear on the read port that same cycle, it lands on the next clock edge, because each cell is a register that updates one cycle later. So if you write 9 to address 4 and read address 4 in the very same cycle, you'll still see the old contents. The 9 shows up next cycle. This "read returns the old value" behavior is something you'll design around constantly once pieces are moving on the Tetris grid.

## A note on array syntax

Writing out eight cells by hand, as we've done here, makes the mechanism crystal clear: a memory is just a bank of register cells plus a read MUX, exactly the register file from 3.1, scaled up. But you can imagine that spelling out 64 or 256 cells this way would be unbearable.

Real designs collapse the whole memory into a single **array**, indexed directly by the address, so one line describes all the cells at once instead of one line per cell. The idea is identical to what you built here, the array index simply stands in for the write-decoder and the read MUX. Seeing it spelled out once, as you have, is what makes the compact version make sense later rather than feeling like magic.

## Your turn: gated writes

In the exercise below, writes are only allowed on even cycles (`$wr_en` is high when the cycle count is even). Complete cell `$m3` so it stores data only when writes are enabled *and* the address points at it, holding its value the rest of the time.

<div id="mc-ram-exercise" class="makerchip-embed"></div>

## Where this fits next

You can now store and retrieve data across many addressable locations, with control over exactly when writes happen. So far, though, memory has been a simple list: address 0, 1, 2, and so on. A game board isn't a list, it's a *grid*, with rows and columns. In Module 3.3 you'll learn how to fold a 2D grid into memory, the representation the entire Tetris game is built on.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| Write-enable | `$wr_en && $wr_addr == N` | Store only when enabled and addressed |
| Memory cell | `... ? $wr_data : >>1$mN` | A register that holds until written |
| Read port | `($rd_addr == N) ? $mN : ...` | MUX selects the addressed cell |
| Read lag | write appears next cycle | The read port shows the stored value |

<style>
.makerchip-embed       { position: relative; width: 100%; height: 500px; }
.makerchip-embed-small { position: relative; width: 100%; height: 360px; }
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

  if (document.getElementById('mc-ram-viz')) {
    VizOnlyIDE.create('mc-ram-viz', { codeURL: base + 'ram-viz.tlv' });
  }
  if (document.getElementById('mc-ram-waveform')) {
    WaveformOnlyIDE.create('mc-ram-waveform', { codeURL: base + 'ram-demo.tlv' });
  }
  if (document.getElementById('mc-ram-exercise')) {
    EditorWaveformIDE.create('mc-ram-exercise', { codeURL: base + 'ram-exercise.tlv' });
  }
</script>
