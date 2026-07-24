# Module 3.4: Reading and Writing the Grid

**Block 3 — Memory and Arrays**  
**Estimated time:** 55–70 minutes  
**Prerequisites:** Module 3.3 — The 2D Grid

<div id="mc-gridops-viz" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to change a grid, not just read it, by setting and clearing individual cells, merging a falling piece into the pile, and moving a piece left and right. These four operations, all built from the bit tricks you learned in Block 2, are the complete toolkit for making Tetris pieces fall, slide, and lock into place.

## From reading to writing

Module 3.3 gave you a static board you could inspect: read a cell, check a full row. But a game board that never changes isn't much of a game. Pieces need to fall, slide sideways, and lock into the pile at the bottom. All of that is *writing* to the grid, changing which bits are set.

Here's the wonderful part: every grid-writing operation Tetris needs is just one of the bitwise operators from Block 2, applied to a row signal. You already know all of them. This module is about recognizing which operator does which job.

## Setting a cell

To turn a single cell *on*, you want to flip one specific bit to `1` while leaving the rest of the row untouched. The tool for that is **OR with a mask that has a single `1`** in the right spot.

You build that mask by taking a lone `1` and shifting it to the target column:

```
$set_result[7:0] = $row | (8'b00000001 << $col);
```

`8'b00000001 << $col` is a mask with exactly one bit set, at position `$col`. ORing it into the row forces that column to `1` and leaves every other column exactly as it was (because OR-ing anything with `0` leaves it unchanged). This is how a piece gets *drawn* onto the board.

Here's a single lit cell that slides across a row, built purely by shifting the set-mask to a new column each cycle. Watch `$row` in the waveform (set its radix to binary) and you'll see the single `1` march across:

<div id="mc-gridops-demo" class="makerchip-embed-small"></div>

## Clearing a cell

Clearing is the mirror image: turn one cell *off* while leaving the rest alone. Here you want **AND with a mask that has a single `0`** at the target column and `1`s everywhere else. You build that by shifting a `1` into place and then *inverting* it with `~`:

```
$clear_result[7:0] = $row & ~(8'b00000001 << $col);
```

`~(8'b00000001 << $col)` is all `1`s except a single `0` at position `$col`. ANDing with it forces that one column to `0` (because AND with `0` is always `0`) and leaves the others unchanged (AND with `1` keeps them). This is how a piece gets *erased* from its old position before being redrawn one step down, the essence of animation.

These two operations are mirror images. This diagram shows both acting on column 3 of the same starting row:

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 720 250" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <!-- SET side -->
  <text x="180" y="30" fill="#22c55e" font-size="13" font-weight="bold" text-anchor="middle">SET column 3   (OR)</text>
  <text x="60" y="66" fill="#4A3060" font-size="11" text-anchor="start">row</text>
  <text x="180" y="66" fill="#EDE7F6" font-size="15" text-anchor="middle" font-family="Courier New">00000100</text>
  <text x="60" y="92" fill="#4A3060" font-size="11" text-anchor="start">mask</text>
  <text x="180" y="92" fill="#22c55e" font-size="15" text-anchor="middle" font-family="Courier New">00001000</text>
  <line x1="90" y1="102" x2="270" y2="102" stroke="#4A3060" stroke-width="1"/>
  <text x="40" y="122" fill="#4A3060" font-size="13" text-anchor="start">OR</text>
  <text x="180" y="124" fill="#7C4DFF" font-size="15" font-weight="bold" text-anchor="middle" font-family="Courier New">00001100</text>
  <text x="180" y="150" fill="#4A3060" font-size="10" text-anchor="middle">column 3 now on, rest unchanged</text>

  <!-- divider -->
  <line x1="360" y1="20" x2="360" y2="160" stroke="#2A1A40" stroke-width="1"/>

  <!-- CLEAR side -->
  <text x="540" y="30" fill="#ef4444" font-size="13" font-weight="bold" text-anchor="middle">CLEAR column 3   (AND ~)</text>
  <text x="420" y="66" fill="#4A3060" font-size="11" text-anchor="start">row</text>
  <text x="540" y="66" fill="#EDE7F6" font-size="15" text-anchor="middle" font-family="Courier New">00001100</text>
  <text x="420" y="92" fill="#4A3060" font-size="11" text-anchor="start">~mask</text>
  <text x="540" y="92" fill="#ef4444" font-size="15" text-anchor="middle" font-family="Courier New">11110111</text>
  <line x1="450" y1="102" x2="630" y2="102" stroke="#4A3060" stroke-width="1"/>
  <text x="400" y="122" fill="#4A3060" font-size="13" text-anchor="start">AND</text>
  <text x="540" y="124" fill="#7C4DFF" font-size="15" font-weight="bold" text-anchor="middle" font-family="Courier New">00000100</text>
  <text x="540" y="150" fill="#4A3060" font-size="10" text-anchor="middle">column 3 now off, rest unchanged</text>

  <!-- key insight -->
  <text x="360" y="200" fill="#B39DDB" font-size="12" text-anchor="middle">OR forces a bit ON  ·  AND with ~mask forces a bit OFF</text>
  <text x="360" y="222" fill="#4A3060" font-size="11" text-anchor="middle">both leave every other column exactly as it was</text>
</svg>
</div>

## Moving a piece: set, then clear

Put those two together and you can move a piece. The pattern for animating movement is always the same two-step: **clear the piece from where it is, then set it where it's going.** If you only set the new position without clearing the old one, you leave a trail behind, the piece smears across the board instead of moving.

Walk through sliding a single-cell piece from column 2 to column 3 in a row. Start with the piece drawn at column 2:

```
row = 00000100        (piece at column 2)
```

First clear column 2, then set column 3:

```
after clear col 2:  00000000
after set col 3:    00001000        (piece now at column 3)
```

The piece moved cleanly, no trail, because you erased the old cell before drawing the new one. That clear-then-set pair is the heartbeat of every moving thing on the board.

Moving sideways can also be done by shifting the piece's bits directly, since a whole piece is just a set of bits in a row signal:

```
$moved_right[7:0] = $piece << 1;   // toward higher bits
$moved_left[7:0]  = $piece >> 1;   // toward lower bits
```

??? note "Wait, `<< 1` moves it *right*?"

    Yes, and this catches everyone. Remember our convention: bit 0 is the *leftmost* column. Shifting left (`<<`) moves bits toward *higher* positions, which are the columns further *right* on the board. So `<< 1` slides the piece right, and `>> 1` slides it left. If your piece moves the opposite way from what you expected, this is why. As always, the Viz tab shows you the truth at a glance.

## Merging a piece into the pile

When a piece can't fall any further, it *locks*: it becomes a permanent part of the pile. Locking is just an OR, the same operation as setting a cell, but applied to the whole row at once. You OR the piece's bits into the pile row, and now those cells are part of the stack:

```
$pile_row[7:0] = $locking ? (>>1$pile_row | $piece) : >>1$pile_row;
```

When `$locking` is true, the piece merges into the pile and stays there (the register holds it). Otherwise the pile row just keeps whatever it already had. The VIZ at the top of this page shows this in action, a yellow piece falls, and when it reaches the bottom it turns purple as it locks into the growing pile.

## Making a piece fall

Falling is the motion Tetris runs most, and it's worth seeing spelled out, because a piece falling is really about *which row* holds it. If you track the piece's row position in a counter, then a given row shows the piece only when the counter points at it:

```
$piece_row[2:0] = *reset ? 3'd0 : >>1$piece_row + 3'd1;   // fall one row per step

$row0[7:0] = (>>1$piece_row == 3'd0) ? $piece_shape : 8'b0;
$row1[7:0] = (>>1$piece_row == 3'd1) ? $piece_shape : 8'b0;
$row2[7:0] = (>>1$piece_row == 3'd2) ? $piece_shape : 8'b0;
```

Each row asks "is the piece on me right now?" If yes, it shows the piece's shape; if no, it's empty. As `$piece_row` counts up, the piece appears to march downward, one row lighting up as the previous one goes dark. That automatic "clear the old row" behavior falls out for free here, because a row that no longer matches `$piece_row` simply returns to `8'b0`. This is exactly the falling logic you saw in the Module 3.3 grid VIZ, now you know how it's built.

## Watch it break: the smear

To feel why the clear step matters, here's what happens when you forget it. This design sets a new cell each cycle but never clears the old one, it just keeps OR-ing new positions into the same row:

```
$buggy_row[7:0] = >>1$buggy_row | (8'b00000001 << $pos);   // no clear!
```

Run it and watch:

<div id="mc-gridops-smear" class="makerchip-embed-small"></div>

Instead of one cell moving across, the row fills up with a solid trail, every cell it ever touched stays lit. This is the single most common grid-animation bug. The fix is always the same: to *move* something, clear where it was before you set where it's going, or, as in the falling example above, rebuild each row from scratch every cycle so stale cells can't survive.

??? note "Another edge trap: shifting off the wall"

    Watch what happens if you shift a piece that's already against the right wall. A piece at column 7 (`8'b10000000`) shifted left with `<< 1` moves toward bit 8, but the row is only 8 bits wide, so that bit is truncated away and the piece simply vanishes off the edge. In Tetris you prevent this by *checking* whether a move is legal before making it, which is exactly what collision detection, the next module, is for.

## Debugging tip: watch the Diagram tab

You've now written logic where a single line like `$row | (1 << $col)` stands in for a shifter feeding an OR gate feeding a register. Makerchip's **Diagram** tab (near Nav-TLV) draws the actual hardware your code generates, the boxes and wires behind the bit operations. When you're wondering "is my set-mask really doing what I think?", the Diagram shows the shifter and the OR gate wired up, which can make an abstract bit operation feel concrete. It's a great way to connect the one-line shorthand back to the real circuit underneath.

## Your turn: set and clear

Below is a row with some cells filled and a `$target_col` that walks across the columns. Complete two operations: set the cell at `$target_col`, and clear the cell at `$target_col`. Both need a mask built the same way, so once you have the first, the second is a small variation on it.

<div id="mc-gridops-exercise" class="makerchip-embed"></div>

??? tip "Hint"

    Both start the same way: shift a lone `1` up to position `$target_col` to
    build a mask. The difference is what you do with it. To turn a bit on you
    want the operator that forces a `1`. To turn a bit off you first invert
    the mask with `~`, then use the operator that forces a `0`.

??? success "Solution"

    ```
    $set_result[7:0]   = $start_row | (8'b00000001 << $target_col);
    $clear_result[7:0] = $start_row & ~(8'b00000001 << $target_col);
    ```

    Watch both results in the waveform as `$target_col` walks across. The set
    version lights one extra cell; the clear version darkens one. Every other
    column is untouched in both, which is the whole point of masking.


## Where this fits next

You can now draw, erase, move, and lock pieces on the grid, everything needed to make a piece fall and build up a pile. But there's a rule we've been ignoring: pieces aren't allowed to pass *through* each other or through the walls. Before a piece moves, the game has to check whether the destination is clear. In Module 3.5 you'll build **collision detection**, the check that makes the pile solid and the walls real, and the last concept before the full Tetris game.

## Quick reference

| Operation | TL-Verilog | What it does |
| --- | --- | --- |
| Set a cell | `$row \| (1 << $col)` | Turn column `$col` on |
| Clear a cell | `$row & ~(1 << $col)` | Turn column `$col` off |
| Move piece right | `$piece << 1` | Shift toward higher bits |
| Move piece left | `$piece >> 1` | Shift toward lower bits |
| Lock into pile | `>>1$pile \| $piece` | Merge the piece permanently |

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

  if (document.getElementById('mc-gridops-viz')) {
    VizOnlyIDE.create('mc-gridops-viz', { codeURL: base + 'gridops-viz.tlv' });
  }
  if (document.getElementById('mc-gridops-demo')) {
    WaveformOnlyIDE.create('mc-gridops-demo', { codeURL: base + 'gridops-demo.tlv' });
  }
  if (document.getElementById('mc-gridops-smear')) {
    WaveformOnlyIDE.create('mc-gridops-smear', { codeURL: base + 'gridops-smear.tlv' });
  }
  if (document.getElementById('mc-gridops-exercise')) {
    EditorWaveformIDE.create('mc-gridops-exercise', { codeURL: base + 'gridops-exercise.tlv' });
  }
</script>
