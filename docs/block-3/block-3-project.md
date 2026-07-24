# Project Lab: Tetris

**Block 3 — Memory and Arrays**  
**Estimated time:** 120–150 minutes  
**Prerequisites:** Modules 3.1 through 3.5

## What you're building

This is the capstone of Block 3, and of the whole course so far: a complete, self-playing Tetris machine. Pieces fall down a grid, land and lock into a growing pile, and whenever a row fills completely it clears and the score climbs, faster and faster as you go. You won't learn any new syntax here. Every single piece is something you already built in Modules 3.1 through 3.5. Your job is to assemble them into a working game, one stage at a time.

A quick note on how it plays. A Makerchip simulation runs on the clock with no live keyboard, so instead of you steering pieces, the machine has a built-in auto-player that positions each piece for you, the way a demo screen plays itself on an arcade cabinet while no one's at the controls. Everything is fully visible, so you can watch exactly how the game thinks: the falling, the collision, the locking, the line clears.

Here's the finished machine you're working toward, a piece falls, locks into the pile, and completed rows vanish as the line counter ticks up:

<div id="mc-tetris-final" class="makerchip-embed"></div>

The lab has four stages, one for each big idea from the block. Each stage hands you a starter with the earlier stages already working, so you're always building on solid ground. Fill in the blanks marked `TODO`, run it, and check it against the checkpoint before moving on.

## The plan

You'll build the game in the same order the pieces fire during play:

1. **The falling piece** — a piece drops down the grid on a difficulty timer *(Modules 3.3, 3.4)*
2. **Collision and locking** — the piece stops on the pile and merges in *(Modules 3.4, 3.5)*
3. **Sideways movement** — the piece slides across, blocked by the walls *(Module 3.5)*
4. **Line clear and scoring** — full rows vanish and the stack drops *(Module 3.3)*

A note on pieces: real Tetris has seven rotating shapes, and rotation in this bit-per-row representation is a genuine challenge beyond this course. So we use single-row pieces of different widths. Everything important, falling, collision, locking, line-clearing, works exactly the same, and you'll finish with a real, playing game rather than a half-built one. If you later want to add multi-row pieces or rotation, you'll have every tool you need.

---

## Stage 1 — The falling piece

**Concepts:** the grid (Module 3.3), making a piece fall (Module 3.4)

Everything starts with a piece that falls. You have a piece sitting in a row signal, and a difficulty timer that "ticks" at a set speed. On each tick, the piece should drop one row, and when it reaches the bottom it wraps back to the top so you can watch it loop.

Your one blank is the falling logic: on each tick, move `$prow` down by one, wrapping from the last row (9) back to 0. It's the counter pattern from Block 2, gated by the tick.

<div id="mc-tetris-stage1" class="makerchip-embed"></div>

??? tip "Hint"

    This is the wrapping counter from Module 2.2 with one extra condition on
    the front: it must hold its value whenever `$tick` is low, and only then
    consider counting or wrapping. Remember to keep the whole assignment on a
    single line.

??? success "Solution"

    ```
    $prow[3:0] = *reset ? 4'd0 : !$tick ? >>1$prow : (>>1$prow == 4'd9) ? 4'd0 : >>1$prow + 4'd1;
    ```

    Read the four cases in order: reset to the top, hold between ticks, wrap
    at the floor, otherwise fall one row.

**Checkpoint:** the yellow piece should march steadily down the board, one row at a time, then reappear at the top. If it sits still, your fall logic isn't advancing; if it moves every cycle instead of every few, check that it only moves on `$tick`.

---

## Stage 2 — Collision and locking

**Concepts:** merging (Module 3.4), collision detection (Module 3.5)

Now the piece needs to *stop*. Instead of wrapping, it should fall until the cell below it is blocked, either by the floor or by the pile, then lock in place and let a new piece spawn at the top. This is the collision-below test from Module 3.5 driving the merge from Module 3.4.

The collision and pile logic are wired for you. Watch how each pile row ORs the piece in when the piece locks at that row, and how `$below` looks one row down to decide when the piece has landed. Run it and watch the pile build up, one piece at a time.

<div id="mc-tetris-stage2" class="makerchip-embed"></div>

**Checkpoint:** pieces should fall, stop on top of each other, and build a growing stack instead of passing through. If pieces sink to the bottom and overwrite each other, the collision check isn't catching the pile; if nothing stacks, the lock isn't merging into the pile rows.

---

## Stage 3 — Sideways movement

**Concept:** the collision guard applied to left/right motion (Module 3.5)

A piece that only falls straight down can't fill a board evenly. Here the piece slides sideways as it falls, steered by the auto-player toward a target column, but it must respect the walls: a piece can't move past the edge of the grid.

You have two blanks here. First the wall checks: work out how far the piece's left edge can travel in each direction before part of it would hang off the board. Then the move guard itself: step one column toward the target, but only when the matching wall check says there is room, and hold position otherwise. This is exactly the guarded-move pattern from Module 3.5, "take the move only if it's legal", applied to horizontal motion.

The visualization outlines the target column so you can watch the piece walk toward it.

<div id="mc-tetris-stage3" class="makerchip-embed"></div>

??? tip "Hint"

    The piece is 2 cells wide, so if its left edge `$px` sat at 7 the piece
    would hang off the board. That tells you the largest legal value of `$px`.
    For the guard itself, combine each "wants to move" signal with its
    matching "has room" signal, and fall through to holding position when
    neither move is legal.

??? success "Solution"

    ```
    $can_right = >>1$px < 3'd6;
    $can_left  = >>1$px > 3'd0;
    $px[2:0] = *reset ? 3'd0 : !$tick ? >>1$px : ($want_right && $can_right) ? >>1$px + 3'd1 : ($want_left && $can_left) ? >>1$px - 3'd1 : >>1$px;
    ```

    Watch the outlined target column in the visualization. The piece walks
    toward it one step per tick and then sits still once it arrives. When the
    target sits past column 6, the piece stops flush against the right wall
    instead of sliding off it, which is the guard doing its job.

**Checkpoint:** the piece should drift toward its target column as it falls and stop cleanly at the wall, never disappearing off the edge. If it slides off the board, the wall check isn't holding it back.

---

## Stage 4 — Line clear and scoring

**Concept:** the full-row check and its payoff (Module 3.3)

This is the moment the whole block has been building toward. When a row fills completely, it should vanish, everything above it drops down by one, and the score goes up. The auto-player drops pieces to alternate halves of the board so the bottom row fills and clears.

The shift-down half is wired for you: when `$clear` fires, each pile row takes the value of the row above it and the stack falls to fill the gap. Your blank is the trigger itself. Detect when the bottom row is completely full, using the reduction operator from Module 3.3. It is a short line, and it is the single most important signal in the game.

??? tip "Hint"

    You want one bit that is true only when all eight columns of the bottom
    row hold a 1. Module 3.3 introduced exactly one operator that collapses
    every bit of a signal into a single answer that way. Apply it to the
    previous cycle's value of the bottom pile row.

??? success "Solution"

    ```
    $clear = & >>1$pile9;
    ```

    That is the whole detector. One operator, and the most satisfying mechanic
    in Tetris comes to life.

<div id="mc-tetris-stage4" class="makerchip-embed"></div>

**Checkpoint:** when the bottom row fills completely, it should clear, the stack above should drop by one row, and the line count should increase. If full rows just sit there, the `$clear` detection isn't firing; if the board empties wrongly, check the shift-down.

---

## The complete game

Put all four stages together and you have Tetris. The full machine below adds the finishing touches that turn the mechanism into an actual game:

- **Varied pieces.** An LFSR, the random number generator you built in Module 2.3, picks a fresh piece width for every drop, so no two games play the same.
- **A player with a strategy.** Most of the time the auto-player aims for the leftmost gap in the bottom row; now and then it drops somewhere else entirely, so the stack builds up unevenly the way a real game does.
- **Any row can clear.** Not just the bottom one. Fill a row halfway up the stack and it vanishes, with everything above dropping down to fill the space.
- **Topping out.** If the stack reaches the top row, the game is over, the board clears, and a new game begins.
- **Rising difficulty.** Pieces fall faster as the score climbs, so the game gets harder the better it does.

Watch it for a while. The board builds unevenly, rows light up white as they clear, the stack sometimes recovers and sometimes tops out and starts over.

<div id="mc-tetris-full" class="makerchip-embed"></div>

Take a moment to appreciate what this is. Every part of it is something you built from scratch: the grid is Module 3.3, the falling and locking are Module 3.4, the collision that makes the pile solid is Module 3.5, and the line clear is the full-row check paying off. There's no new magic here, just the pieces of Block 3, assembled.

## Make it your own

The game is fully yours to tune. Because it plays itself, tuning *is* the gameplay, change a value, rerun, and watch how the machine behaves differently. Some things to try:

- **Change the speed.** Adjust `$fall_limit` to make pieces fall faster or slower, or change the score thresholds where the difficulty ramps up.
- **Change the pieces.** `$wmask` picks widths of 2, 3 or 4 cells from the LFSR. Add wider pieces, or weight the choice so one width shows up more often.
- **Change the strategy.** `$aim` decides how often the auto-player targets the leftmost gap versus dropping somewhere random. Make it aim more and the board stays tidy and clears often; make it aim less and the stack grows wild and tops out sooner.
- **Grow the board.** The grid is 8 wide by 10 tall. Widen the rows to 10 bits, or add more pile rows, everything scales the same way.
- **Score differently.** Give more points for clears that happen at high speed, or track the number of pieces dropped alongside the lines cleared.
- **Harder:** aim at the lowest gap in the *stack* rather than in the bottom row, so the player fills holes it has buried.

## Where you've been

That's Block 3 complete, and it's a real milestone. You started the block able to store a single value in a register. You finished it having built addressable memory, a 2D grid, the operations to move things on it, collision detection, and a complete game that uses all of it at once. The same ideas, addressable storage and bit-parallel operations, are exactly what real processors and graphics hardware are built from. You've been writing the real thing all along.

<style>
.makerchip-embed { position: relative; width: 100%; height: 620px; }
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

  class EditorVizIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({
        sides: {
          left:  { panes: ['Editor'], activePane: 'Editor' },
          right: { panes: ['Viz'],    activePane: 'Viz'    }
        },
        splitAt: 0.5
      });
    }
  }

  if (document.getElementById('mc-tetris-final')) {
    VizOnlyIDE.create('mc-tetris-final', { codeURL: base + 'tetris.tlv' });
  }
  if (document.getElementById('mc-tetris-stage1')) {
    EditorVizIDE.create('mc-tetris-stage1', { codeURL: base + 'tetris-stage1.tlv' });
  }
  if (document.getElementById('mc-tetris-stage2')) {
    EditorVizIDE.create('mc-tetris-stage2', { codeURL: base + 'tetris-stage2.tlv' });
  }
  if (document.getElementById('mc-tetris-stage3')) {
    EditorVizIDE.create('mc-tetris-stage3', { codeURL: base + 'tetris-stage3.tlv' });
  }
  if (document.getElementById('mc-tetris-stage4')) {
    EditorVizIDE.create('mc-tetris-stage4', { codeURL: base + 'tetris-stage4.tlv' });
  }
  if (document.getElementById('mc-tetris-full')) {
    VizOnlyIDE.create('mc-tetris-full', { codeURL: base + 'tetris.tlv' });
  }
</script>
