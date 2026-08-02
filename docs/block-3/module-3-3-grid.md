# Module 3.3: The 2D Grid

**Block 3 — Memory and Arrays**  
**Estimated time:** 60–75 minutes  
**Prerequisites:** Module 3.2 — Memory (RAM)

<div id="mc-grid-viz" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to represent a 2D grid, like a game board, using hardware signals, explain the "one row per signal, one bit per column" convention, read any single cell by its row and column, check whether a whole row is full, and use the Viz tab as your main tool for seeing and debugging a grid. This representation is the foundation the entire Tetris game is built on.

## Memory is a list; a game board is a grid

The RAM you built in Module 3.2 is a *list*: address 0, 1, 2, 3, and so on, in a single line. That's perfect for many things, but a Tetris board isn't a line. It's a **grid**, with rows going down and columns going across. You need a way to talk about "row 2, column 5," not just "location 21."

The good news is that a grid is just a stack of rows, and each row is just a list of cells. So if you can represent one row, you can represent the whole board by stacking several of them.

## Why not just one signal per cell?

Before settling on a representation, it's worth seeing why we pick the one we do. You could give every single cell its own 1-bit signal, `$cell_0_0`, `$cell_0_1`, and so on, but a real Tetris board is 10 columns by 20 rows, that's 200 separate signals to name and manage. Miserable.

You could reach for a true 2D array, but as you'll see, packing each row into one number lets you use all the bit tricks from Block 2, shifting, masking, whole-row tests, directly on the board. That turns out to be exactly what makes moving pieces and clearing lines easy. So the representation we'll use is a middle ground that's both compact and powerful: one signal per row, one bit per column.

## One row per signal, one bit per column

Here's the representation, and it's beautifully simple: **each row of the grid is a single multi-bit signal, and each bit of that signal is one column.** A `1` means the cell is filled; a `0` means it's empty.

So an 8-column row is an 8-bit signal:

```
$row1[7:0] = 8'b00000111;
```

**Bit `c` is column `c`.** Bit 0 is the leftmost column, bit 1 the next one over, and so on across to bit 7 at the right edge. So the row above has its three leftmost columns filled and the rest empty.

Look at that literal again, though, because there is a trap in it worth meeting right now rather than discovering later. The three `1`s appear at the *right* end of the number, but they fill the *left* end of the board. That is not a mistake. When you write a binary literal, the highest bit goes first, so the digits march right-to-left compared to the board. The number is not a picture of the row; it is a list of the row's columns, written backwards.

What you gain in exchange is worth the small awkwardness: because a row is now a single number, every bit trick from Block 2, shifting, masking, XOR, reductions, operates on the playfield directly. Moving a piece sideways becomes one shift. Testing a whole row becomes one operator. That is the payoff, and it is what the rest of this block is built on.

This diagram shows the mapping explicitly. Each bit of the row signal drives exactly one cell on the board, with bit 0 on the left where column 0 is:

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 720 250" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <text x="360" y="34" fill="#4A3060" font-size="12" text-anchor="middle">the row signal, drawn bit 0 first</text>
    <rect x="120" y="50" width="56" height="44" rx="4" fill="#3B1D6D" stroke="#7C4DFF" stroke-width="2"/>
    <text x="148" y="70" fill="#ffffff" font-size="16" font-weight="bold" text-anchor="middle">1</text>
    <text x="148" y="86" fill="#7C4DFF" font-size="9" text-anchor="middle">bit 0</text>
    <rect x="120" y="160" width="56" height="40" rx="3" fill="#7C4DFF" stroke="#B39DDB" stroke-width="2"/>
    <text x="148" y="184" fill="#ffffff" font-size="10" text-anchor="middle">c0</text>
    <rect x="180" y="50" width="56" height="44" rx="4" fill="#3B1D6D" stroke="#7C4DFF" stroke-width="2"/>
    <text x="208" y="70" fill="#ffffff" font-size="16" font-weight="bold" text-anchor="middle">1</text>
    <text x="208" y="86" fill="#7C4DFF" font-size="9" text-anchor="middle">bit 1</text>
    <rect x="180" y="160" width="56" height="40" rx="3" fill="#7C4DFF" stroke="#B39DDB" stroke-width="2"/>
    <text x="208" y="184" fill="#ffffff" font-size="10" text-anchor="middle">c1</text>
    <rect x="240" y="50" width="56" height="44" rx="4" fill="#3B1D6D" stroke="#7C4DFF" stroke-width="2"/>
    <text x="268" y="70" fill="#ffffff" font-size="16" font-weight="bold" text-anchor="middle">1</text>
    <text x="268" y="86" fill="#7C4DFF" font-size="9" text-anchor="middle">bit 2</text>
    <rect x="240" y="160" width="56" height="40" rx="3" fill="#7C4DFF" stroke="#B39DDB" stroke-width="2"/>
    <text x="268" y="184" fill="#ffffff" font-size="10" text-anchor="middle">c2</text>
    <rect x="300" y="50" width="56" height="44" rx="4" fill="#1A0533" stroke="#2A1A40" stroke-width="1.5"/>
    <text x="328" y="70" fill="#EDE7F6" font-size="16" font-weight="bold" text-anchor="middle">0</text>
    <text x="328" y="86" fill="#4A3060" font-size="9" text-anchor="middle">bit 3</text>
    <rect x="300" y="160" width="56" height="40" rx="3" fill="#1A0533" stroke="#2A1A40" stroke-width="1"/>
    <text x="328" y="184" fill="#4A3060" font-size="10" text-anchor="middle">c3</text>
    <rect x="360" y="50" width="56" height="44" rx="4" fill="#1A0533" stroke="#2A1A40" stroke-width="1.5"/>
    <text x="388" y="70" fill="#EDE7F6" font-size="16" font-weight="bold" text-anchor="middle">0</text>
    <text x="388" y="86" fill="#4A3060" font-size="9" text-anchor="middle">bit 4</text>
    <rect x="360" y="160" width="56" height="40" rx="3" fill="#1A0533" stroke="#2A1A40" stroke-width="1"/>
    <text x="388" y="184" fill="#4A3060" font-size="10" text-anchor="middle">c4</text>
    <rect x="420" y="50" width="56" height="44" rx="4" fill="#1A0533" stroke="#2A1A40" stroke-width="1.5"/>
    <text x="448" y="70" fill="#EDE7F6" font-size="16" font-weight="bold" text-anchor="middle">0</text>
    <text x="448" y="86" fill="#4A3060" font-size="9" text-anchor="middle">bit 5</text>
    <rect x="420" y="160" width="56" height="40" rx="3" fill="#1A0533" stroke="#2A1A40" stroke-width="1"/>
    <text x="448" y="184" fill="#4A3060" font-size="10" text-anchor="middle">c5</text>
    <rect x="480" y="50" width="56" height="44" rx="4" fill="#1A0533" stroke="#2A1A40" stroke-width="1.5"/>
    <text x="508" y="70" fill="#EDE7F6" font-size="16" font-weight="bold" text-anchor="middle">0</text>
    <text x="508" y="86" fill="#4A3060" font-size="9" text-anchor="middle">bit 6</text>
    <rect x="480" y="160" width="56" height="40" rx="3" fill="#1A0533" stroke="#2A1A40" stroke-width="1"/>
    <text x="508" y="184" fill="#4A3060" font-size="10" text-anchor="middle">c6</text>
    <rect x="540" y="50" width="56" height="44" rx="4" fill="#1A0533" stroke="#2A1A40" stroke-width="1.5"/>
    <text x="568" y="70" fill="#EDE7F6" font-size="16" font-weight="bold" text-anchor="middle">0</text>
    <text x="568" y="86" fill="#4A3060" font-size="9" text-anchor="middle">bit 7</text>
    <rect x="540" y="160" width="56" height="40" rx="3" fill="#1A0533" stroke="#2A1A40" stroke-width="1"/>
    <text x="568" y="184" fill="#4A3060" font-size="10" text-anchor="middle">c7</text>
  <text x="360" y="146" fill="#4A3060" font-size="12" text-anchor="middle">the board row, column 0 on the left</text>
  <text x="360" y="228" fill="#B39DDB" font-size="12" text-anchor="middle">written as a literal this row is 8'b00000111</text>
  <text x="360" y="246" fill="#4A3060" font-size="11" text-anchor="middle">the digits run right-to-left compared to the board above</text>
</svg>
</div>

Lined up this way the mapping is obvious: bit 0 sits above column 0, bit 7 above column 7, straight across. The only place the order flips is when you *write the number down*, which is exactly what the caption underneath is warning you about.

A full board is just several of these rows:

```
$row0[7:0] = 8'b00011000;
$row1[7:0] = 8'b00111100;
$row2[7:0] = 8'b01111110;
$row3[7:0] = 8'b11111111;
```

Stack those four and you have a little pyramid sitting at the bottom of the board. The VIZ at the top of this page renders exactly this idea, a falling block over a fixed pile, with each cell drawn from one bit of a row signal.

Here's the same falling block in the waveform. Try right-clicking the `$row0` and `$row1` signals and setting their radix to **binary**, then watch the `1`s move as the block falls, the bits changing in the waveform are the block moving on the board:

<div id="mc-grid-waveform" class="makerchip-embed-small"></div>

??? note "Which bit is column 0?"

    We use the convention that **bit `c` is column `c`**, so bit 0 is the leftmost column and higher bits go rightward. This makes reading a cell as simple as indexing: `$row1[3]` is column 3 of row 1. (When you print the raw binary, the leftmost digit is the highest bit, so the printed number can look mirror-imaged compared to the board, that's why the Viz tab, which draws it correctly, is your friend.)

## Reading a single cell

Because a column is just a bit position, reading one cell is a bit-index, no math required:

```
$cell = $row1[3];   // is column 3 of row 1 filled?
```

That returns the single bit for that cell: `1` if filled, `0` if empty. This is the operation Tetris runs constantly, "is the space below my piece already occupied?"

## Building a shape from scratch

Reading is half the story; you also need to *construct* rows. Say you want a horizontal bar filling columns 2, 3, and 4 of a row. Work it out bit by bit: you need `1`s at bit positions 2, 3, and 4, and `0`s everywhere else. Writing the bits from position 7 down to 0:

```
bit:    7 6 5 4 3 2 1 0
value:  0 0 0 1 1 1 0 0    ->   8'b00011100
```

So `$row = 8'b00011100` gives you that bar. The trick is always the same: mark a `1` at each column you want filled, `0` elsewhere, then read the bits off from the high position down to write the literal. Once you're comfortable, you'll read and write these shapes as fluently as you read decimal numbers.

## Sizing a real board

Our examples use a cozy 8-wide grid to keep things readable, but the technique scales to any size. A standard Tetris board is 10 columns wide and 20 rows tall. In this representation that's simply twenty signals, each 10 bits wide:

```
$row0[9:0], $row1[9:0], ... $row19[9:0]
```

Nothing about the approach changes, wider rows just mean more bits per signal, and a taller board means more row signals. Everything you learn on the small grid transfers directly to the full-size game.

## Checking a full row

Clearing full rows is the heart of Tetris scoring, and detecting a full row is delightfully easy in this representation. A row is full when *every* bit is `1`. The **AND-reduction** operator, a single `&` in front of a signal, ANDs all the bits together and gives you one result: `1` only if they were all `1`.

```
$row3_full = & $row3;   // 1 if every column in row 3 is filled
```

If `$row3` is `8'b11111111`, the reduction is `1`. If even one column is empty, it's `0`. One operator, whole-row check.

Why does this one little operator matter so much? Because detecting a full row *is* the core of Tetris scoring. The entire satisfying loop of the game, stack pieces, fill a row completely, watch it vanish, is built on exactly this check. Every cycle, Tetris asks each row "are you full?" using this reduction, and any row that answers yes gets cleared and scored. You've just written the detection half of the most important mechanic in the game; in a later module you'll add the clearing half.

There's a matching operator for the opposite question. The **OR-reduction**, a single `|` in front of a signal, is `1` if *any* bit is set. So `| $row` tells you whether a row has anything in it at all, and `$row == 8'b0` tells you a row is completely empty, useful for knowing where the empty space above the pile begins.

## Watch out: the binary looks mirrored

We flagged this above, but it earns a second look, because it is the single most common source of "why is my piece on the wrong side?" Say you want a block in the two *leftmost* columns, columns 0 and 1. Your instinct might be to write `8'b11000000`, because that *looks* left-heavy. But that's wrong: in `8'b11000000` the two `1`s are in bit positions 7 and 6, which are columns 7 and 6, the *rightmost* columns.

To fill columns 0 and 1, you actually write `8'b00000011`, because bit 0 and bit 1 are the leftmost columns in our convention. The written binary reads right-to-left compared to the board, the lowest bit (rightmost digit) is the leftmost column.

This is exactly why the Viz tab matters so much for grids: when you draw the cells as a picture, this confusion disappears, you just see whether the block is where you wanted it. Whenever a shape looks flipped or offset, this bit-ordering is the first thing to suspect.

## Debugging tip: the Viz tab is your eyes

For everything up to now, the Waveform was the natural place to watch your design. For a grid, that flips. A row shown as `01111110` in the waveform is technically correct but nearly impossible to *see* as a shape. The **Viz tab** is where a grid comes alive, it draws the cells as an actual picture, so a bug like "my piece is one column off" jumps out immediately instead of hiding in a binary number.

From here through the Tetris project, the Viz tab is your primary debugging surface. Build the habit now: when something on the grid looks wrong, open Viz and *look* at it rather than squinting at bits in the waveform. The two tabs work together, Viz shows you *that* something's wrong and roughly where, the waveform and Nav-TLV help you find *why*.

## Your turn: read the grid

The grid below is fixed. Complete two operations: read the single cell at row 2, column 4, and check whether row 3 is completely full. Try both before opening the hint.

<div id="mc-grid-exercise" class="makerchip-embed"></div>

??? tip "Hint"

    For the first one: a column number *is* a bit position, so you can index
    the row signal directly, no arithmetic needed. For the second: you want a
    single yes/no answer about all eight bits at once, which is what a
    reduction operator gives you.

??? success "Solution"

    ```
    $cell = $row2[4];
    $row3_full = & $row3;
    ```

    `$row2` is `8'b01111110`, and bit 4 of that is `1`, so `$cell` is 1.
    `$row3` is `8'b11111111`, so the AND-reduction gives 1: the row is full.


## Check yourself

Try these from memory before moving on.

??? question "In `8'b00000111`, which columns of the board are filled?"

    The three *leftmost* columns, 0, 1 and 2. The bits set are bits 0, 1 and 2,
    and bit `c` maps to column `c`. The digits look right-aligned in the literal
    but fill the left of the board, which is the mirroring trap.

??? question "How do you test whether an entire row is full, in one operation?"

    An AND-reduction: `& $row`. It ANDs all the bits together and gives 1 only
    when every column is set.

??? question "Why is the board stored as one number per row instead of a boolean per cell?"

    Because then every bit trick from Block 2, shifting, masking, XOR,
    reductions, operates on a whole row at once. Moving a piece sideways becomes
    one shift; checking a full row becomes one operator.

## Where this fits next

You can now represent a board, read any cell, and detect a full row, all the static pieces of a grid. But Tetris isn't static: pieces move, land, and stack up. In Module 3.4 you'll learn to *change* the grid, setting and clearing cells so a piece can fall and lock into place.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| A row | `$row[7:0] = 8'b...` | One signal, one bit per column |
| Read a cell | `$row[c]` | Bit `c` = column `c` (1 = filled) |
| Full-row check | `& $row` | AND-reduce: 1 if every column filled |
| Empty-row check | `\| $row` gives 0 | OR-reduce: 0 if every column empty |

<style>
.makerchip-embed       { position: relative; width: 100%; height: 500px; }
.makerchip-embed-small { position: relative; width: 100%; height: 340px; }
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

  if (document.getElementById('mc-grid-viz')) {
    VizOnlyIDE.create('mc-grid-viz', { codeURL: base + 'grid-viz.tlv' });
  }
  if (document.getElementById('mc-grid-waveform')) {
    WaveformOnlyIDE.create('mc-grid-waveform', { codeURL: base + 'grid-waveform.tlv' });
  }
  if (document.getElementById('mc-grid-exercise')) {
    EditorWaveformIDE.create('mc-grid-exercise', { codeURL: base + 'grid-exercise.tlv' });
  }
</script>
