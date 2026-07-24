# Module 3.5: Collision Detection

**Block 3 — Memory and Arrays**  
**Estimated time:** 55–70 minutes  
**Prerequisites:** Module 3.4 — Reading and Writing the Grid

<div id="mc-collision-viz" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to detect when a piece would overlap something it shouldn't, using a single AND operation, distinguish wall collisions from pile collisions, guard a move so it only happens when the destination is clear, and detect when a falling piece has landed. Collision detection is the rule that makes the pile solid and the walls real, and it's the final concept before you build the full Tetris game.

## The problem: pieces passing through walls

In Module 3.4 you learned to move pieces around the grid, but nothing stopped them. A piece could slide right off the edge of the board and vanish, or fall straight through the pile as if it weren't there. That's not a game, it's a ghost.

Real Tetris has a rule that we've been ignoring: **two things can't occupy the same cell, and nothing can leave the board.** Before a piece is allowed to move, the game has to look ahead at where it *wants* to go and ask, "is that space actually free?" If it isn't, the move is cancelled. That look-ahead-and-check is called **collision detection**, and it turns out to be one of the most elegant things you'll build in this whole course.

## The core idea: overlap is just AND

Here's the beautiful part. You already have a representation where a piece and the pile are both just sets of bits in a row. Two cells overlap when *both* have a `1` in the same position, and there's a single operator that lights up exactly the positions where two signals both have a `1`: **AND**.

```
$overlap[7:0] = $piece & $pile;
$hit = | $overlap;
```

`$piece & $pile` produces a row that has a `1` only where the piece and the pile collide. If that result is all zeros, there's no overlap and the move is safe. If *any* bit is set, they clash, and the OR-reduction `|` collapses that to a single "collision!" bit. One AND, one reduction, and you know whether a move is legal.

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 720 260" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <text x="360" y="30" fill="#4A3060" font-size="12" text-anchor="middle">does the piece overlap the pile?</text>

  <!-- No collision case -->
  <text x="180" y="62" fill="#22c55e" font-size="12" font-weight="bold" text-anchor="middle">clear move</text>
  <text x="70" y="92" fill="#4A3060" font-size="11" text-anchor="start">piece</text>
  <text x="180" y="92" fill="#eab308" font-size="15" text-anchor="middle" font-family="Courier New">00011000</text>
  <text x="70" y="116" fill="#4A3060" font-size="11" text-anchor="start">pile</text>
  <text x="180" y="116" fill="#7C4DFF" font-size="15" text-anchor="middle" font-family="Courier New">11100000</text>
  <line x1="100" y1="126" x2="270" y2="126" stroke="#4A3060" stroke-width="1"/>
  <text x="55" y="148" fill="#4A3060" font-size="12" text-anchor="start">AND</text>
  <text x="180" y="150" fill="#22c55e" font-size="15" font-weight="bold" text-anchor="middle" font-family="Courier New">00000000</text>
  <text x="180" y="176" fill="#22c55e" font-size="12" text-anchor="middle">all zeros -> move allowed</text>

  <line x1="360" y1="45" x2="360" y2="185" stroke="#2A1A40" stroke-width="1"/>

  <!-- Collision case -->
  <text x="540" y="62" fill="#ef4444" font-size="12" font-weight="bold" text-anchor="middle">blocked move</text>
  <text x="430" y="92" fill="#4A3060" font-size="11" text-anchor="start">piece</text>
  <text x="540" y="92" fill="#eab308" font-size="15" text-anchor="middle" font-family="Courier New">00011000</text>
  <text x="430" y="116" fill="#4A3060" font-size="11" text-anchor="start">pile</text>
  <text x="540" y="116" fill="#7C4DFF" font-size="15" text-anchor="middle" font-family="Courier New">00010000</text>
  <line x1="460" y1="126" x2="630" y2="126" stroke="#4A3060" stroke-width="1"/>
  <text x="415" y="148" fill="#4A3060" font-size="12" text-anchor="start">AND</text>
  <text x="540" y="150" fill="#ef4444" font-size="15" font-weight="bold" text-anchor="middle" font-family="Courier New">00010000</text>
  <text x="540" y="176" fill="#ef4444" font-size="12" text-anchor="middle">a bit is set -> collision!</text>

  <text x="360" y="228" fill="#B39DDB" font-size="12" text-anchor="middle">$hit = | ($piece &amp; $pile)</text>
  <text x="360" y="248" fill="#4A3060" font-size="11" text-anchor="middle">one line decides whether any move is legal</text>
</svg>
</div>

Here's that test running on its own. A single-cell piece slides across a fixed pile, and `$hit` goes high on exactly the cycles where they overlap:

<div id="mc-collision-demo" class="makerchip-embed-small"></div>

## Walls: colliding with the edge

The pile isn't the only thing a piece can hit, there are also the walls. In our bit representation, the walls are the edges of the row: bit 0 on the left, bit 7 on the right. A piece collides with a wall when moving it would push part of it off the end.

The cleanest way to handle walls is to treat them as an always-present border. You can imagine a permanent "wall mask" with the edge columns marked, and check the piece against it the same way you check the pile, an AND. Or, more simply, you check before shifting: if the piece already has a bit in the last column and you're about to move it further that way, the move is illegal. Either way, a wall collision is the same kind of test as a pile collision: would this move put a piece bit where it isn't allowed?

## The move guard: check before you move

Detecting a collision is only useful if you *act* on it. The pattern is a guard around the move: compute where the piece *wants* to go, test that destination for a collision, and only actually move if it's clear.

```
$desired[7:0] = >>1$piece << 1;              // where it wants to go
$collision = | ($desired & $pile);           // is that spot blocked?
$piece[7:0] = *reset     ? 8'b00000100 :
              $collision ? >>1$piece :        // blocked: stay put
                           $desired;          // clear: move
```

Read the last assignment as the whole rule of legal movement: on reset, start at a known spot; if the desired move would collide, hold your current position; otherwise, take the move. This single guarded assignment is what makes walls solid and pieces stack instead of merge. Every legal move in Tetris flows through a guard shaped exactly like this.

## Landing: collision below means lock

There's one more use of collision, and it's the one that makes pieces pile up. A piece **lands** when it can't fall any further, that is, when the cell directly below it is blocked, either by the pile or by the floor. That's the same overlap test, aimed downward:

```
$below_blocked = | ($piece & $row_beneath);
$landed = $at_floor || $below_blocked;
```

When `$landed` is true, the piece stops falling and locks into the pile (the merge you built in Module 3.4). The VIZ at the top of this page shows exactly this: the yellow piece falls until the cell below it is occupied, then stops dead on top of the pile instead of sinking through it. That "stop on contact" is collision detection and locking working together.

## Watch it break: the ghost piece

To appreciate what collision detection buys you, picture leaving it out. Without the guard, a falling piece just decrements its row every cycle with nothing checking the pile, so it slides straight through the stack and out the bottom, a ghost. Everything you've built in this block, the grid, the reads, the writes, only becomes a *game* once this one check is in place. Collision is the rule that gives the world substance.

## Debugging tip: trace the collision signal in Nav-TLV

Collision bugs are sneaky, a piece stops one cell too early, or slips one cell too far, and staring at the Viz alone won't always tell you why. This is where **Nav-TLV** earns its keep. Click your `$collision` (or `$hit`) signal and trace back through the signals that feed it: the `$desired` position, the `$pile` it's tested against, the AND between them. Following that chain almost always reveals the culprit, usually an off-by-one in the desired position or a piece shape that's shifted from where you think it is. Viz shows you *that* the piece stopped wrong; Nav-TLV shows you *why*.

## Your turn: guard the move

Below, a piece tries to slide right across a pile that has blocks on both ends. Complete two things: the collision test between `$desired` and `$pile`, and the move guard that stops the piece when it would hit the pile. Work out the collision test first; the guard depends on it.

<div id="mc-collision-exercise" class="makerchip-embed"></div>

??? tip "Hint"

    For the collision test: overlapping cells are the ones where *both* the
    piece and the pile hold a `1`, and you want to collapse that whole row
    down to a single bit. For the guard: it is a three-way ternary, and the
    "blocked" branch should hand back the piece's *previous* position.

??? success "Solution"

    ```
    $collision = | ($desired & $pile);
    $piece[7:0] = *reset     ? 8'b00000100 :
                  $collision ? >>1$piece :
                               $desired;
    ```

    Run it and watch the piece slide right from column 2 and then stop dead at
    column 5, because moving any further would collide with the pile's right
    hand block. It holds there for the rest of the simulation.


## Where this fits next

That's the last concept. You now have everything a grid-based game needs: addressable storage, a 2D playfield, the operations to draw and move pieces, and the collision rule that makes it all solid. In the **Tetris project** you'll assemble these into a complete, playing game, built in stages, exactly the way you built Whack-a-Mole at the end of Block 2.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| Overlap test | `$piece & $pile` | 1s only where both overlap |
| Collision flag | `\| ($piece & $pile)` | 1 if any overlap at all |
| Move guard | `$collision ? >>1$piece : $desired` | Move only when clear |
| Landing | `\| ($piece & $row_below)` | Blocked below means lock |

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

  if (document.getElementById('mc-collision-viz')) {
    VizOnlyIDE.create('mc-collision-viz', { codeURL: base + 'collision-viz.tlv' });
  }
  if (document.getElementById('mc-collision-demo')) {
    WaveformOnlyIDE.create('mc-collision-demo', { codeURL: base + 'collision-demo.tlv' });
  }
  if (document.getElementById('mc-collision-exercise')) {
    EditorWaveformIDE.create('mc-collision-exercise', { codeURL: base + 'collision-exercise.tlv' });
  }
</script>
