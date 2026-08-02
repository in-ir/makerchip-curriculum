# Block 1 Project: Pixel Art Generator

**Block 1 — Combinational Logic**  
**Estimated time:** 60–90 minutes  
**Prerequisites:** Modules 1.1 through 1.4

## What you are building

You have spent Block 1 learning the individual building blocks of combinational logic: gates, multiplexers, decoders, and the ALU. This project puts all of them to work in something you can actually show people.

You are going to build a **pixel art generator**: a circuit that renders images on an 8x8 pixel grid entirely through combinational logic. No memory, no clock, no processor. Just gate logic deciding whether each of the 64 pixels is on or off, and a MUX selecting between different images based on a 2-bit pattern code.

When you are done, your circuit will display a smiley face, a heart, and a design of your own choosing, all switchable in real time by changing a single 2-bit input.

## How the grid works

The display is an 8x8 grid of pixels. Each pixel is a single bit: `1` means the pixel is on and `0` means it is off.

You represent each row of the grid as an 8-bit signal. The leftmost pixel in a row is the most significant bit (bit 7) and the rightmost is the least significant bit (bit 0).

For example, this row:

```
# # . . . . # #   →   11000011   →   8'b11000011
```

has pixels on at positions 7, 6, 1, and 0. Writing it out as a binary literal makes the pattern immediately readable. You can see the image just by looking at the code. Eight rows of 8 bits each gives you 64 pixels total: a complete 8x8 image.

## The starter code

Open the circuit below. The Viz pane on the right renders the display and updates live every time you compile. The Editor on the left is where you write your logic.

<div id="mc-pixel-art" class="makerchip-embed"></div>

The starter code already has Pattern 0 (a smiley face) fully working. Take a moment to read how it is structured:

```tlv
$smiley_r0[7:0] = 8'b00111100;  //   ####
$smiley_r1[7:0] = 8'b01000010;  //  #    #
$smiley_r2[7:0] = 8'b10100101;  // # #  # #
$smiley_r3[7:0] = 8'b10000001;  // #      #
$smiley_r4[7:0] = 8'b10100101;  // # #  # #
$smiley_r5[7:0] = 8'b10011001;  // #  ##  #
$smiley_r6[7:0] = 8'b01000010;  //  #    #
$smiley_r7[7:0] = 8'b00111100;  //   ####
```

Each row is a constant 8-bit value. The comment next to each line shows the pixel pattern in ASCII art so you can read the image directly in the code.

The pattern selector uses the MUX syntax from Module 1.2 to choose between images:

```tlv
$row0[7:0] = $pattern == 2'b10 ? $custom_r0 :
             $pattern == 2'b01 ? $heart_r0   :
                                 $smiley_r0;
```

When `$pattern` is `01`, the output is the heart row. When it is `10`, the custom row. Otherwise it defaults to the smiley.

!!! note "Navigating the Viz pane"

    Use the play button at the bottom of the Viz pane to run the simulation and watch the patterns cycle automatically. You can also use the `<<` and `>>` buttons to step through one frame at a time. If you want to inspect a specific pattern, pause the simulation and step to the frame you want.

!!! note "Using the LOG"

    For the custom pattern exercise, you will be writing 8 rows of binary values. If you make a mistake and a pixel appears in the wrong place, use the **LOG** tab in Makerchip to see compiler warnings and signal values that can help you track down which row is wrong.

## Exercise: Draw the heart

Pattern 1 is currently all zeros, which means a blank screen. Your task is to fill in the 8 heart rows with the correct pixel values.

Here is the heart pattern to aim for:

```
. # # . . # # .
# # # # # # # #
# # # # # # # #
# # # # # # # #
. # # # # # # .
. . # # # # . .
. . . # # . . .
. . . . . . . .
```

Replace the placeholder rows in `$heart_r0` through `$heart_r7` with the correct values. Each row reads left to right where `#` is `1` and `.` is `0`. Compile and watch the heart appear in the Viz pane when the pattern cycles to `01`.

??? success "Solution"

    ```tlv
    $heart_r0[7:0] = 8'b01100110;  //  ##  ##
    $heart_r1[7:0] = 8'b11111111;  // ########
    $heart_r2[7:0] = 8'b11111111;  // ########
    $heart_r3[7:0] = 8'b11111111;  // ########
    $heart_r4[7:0] = 8'b01111110;  //  ######
    $heart_r5[7:0] = 8'b00111100;  //   ####
    $heart_r6[7:0] = 8'b00011000;  //    ##
    $heart_r7[7:0] = 8'b00000000;  //
    ```

    Once you compile, the Viz pane should show the heart when `$pattern` cycles to `01`. If a pixel is in the wrong place, go back to the row that looks wrong and check which bit position needs to flip.

## Challenge: Design your own pattern

Pattern 2 is reserved for your own design. Fill in `$custom_r0` through `$custom_r7` with whatever you want to draw. Your initials, a spaceship, a star, an arrow, a Tetris piece. The 8x8 constraint is part of the fun.

Once your pattern is working, take a screenshot of the Viz pane.

## Challenge: Add a fourth pattern

The `$pattern` signal is 2 bits, which gives you four possible values: `00`, `01`, `10`, and `11`. The starter code only uses three. Add a fourth pattern using `$pattern == 2'b11` and extend the MUX to include it.

??? tip "Hint"

    Add a set of `$pattern3_rN` signals for your new image, then extend each row MUX from a 3-way to a 4-way selection. The structure is exactly the same as the 4-to-1 MUX from Module 1.2: one condition per pattern, a default at the bottom.

## What you just built

Take a moment to look at the full circuit and recognize every piece from Block 1.

The **row signals** are constant combinational assignments: the simplest form of gate logic. Each one is a fixed binary value that defines a row of pixels.

The **pattern MUX** is the 4-to-1 MUX from Module 1.2, applied 8 times, once per row. The `$pattern` input is the select line, the row signals are the inputs, and the `$rowN` outputs are what the Viz pane reads.

The **Viz pane** reads those 8 output signals and draws pixels based on their bit values. The hardware is the circuit. The visualization is just making it visible.

## Where this fits next

In Block 2 you will add **state** to your circuits. Instead of constant patterns, you will be able to make things move: a pixel that shifts position over time, a counter that drives an animation. The same 8x8 grid, but now alive.

<style>
.makerchip-embed { position: relative; width: 100%; height: 600px; }
</style>

<script type="module">
  import IdePlugin from 'https://beta.makerchip.com/dist/makerchip-plugin.js';

  const base = 'https://raw.githubusercontent.com/in-ir/makerchip-curriculum/main/code/block-1/';

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

  if (document.getElementById('mc-pixel-art')) {
    EditorVizIDE.create('mc-pixel-art', {
      codeURL: base + 'pixel-art.tlv'
    });
  }
</script>
