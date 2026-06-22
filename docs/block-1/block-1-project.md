# Block 1 Project: Pixel Art Generator

**Block 1 — Combinational Logic**  
**Estimated time:** 60–90 minutes  
**Prerequisites:** Modules 1.1 through 1.4

## What you are building

You have spent Block 1 learning the individual building blocks of combinational logic: gates, multiplexers, decoders, and the ALU. This project puts all of them to work in something you can actually show people.

You are going to build a **pixel art generator** — a circuit that renders images on an 8x8 pixel grid entirely through combinational logic. No memory, no clock, no processor. Just gate logic deciding whether each of the 64 pixels is on or off, and a MUX selecting between different images based on a 2-bit pattern code.

When you are done, your circuit will display a smiley face, a heart, and a design of your own choosing — switchable in real time by changing a single 2-bit input.

## How the grid works

The display is an 8x8 grid of pixels. Each pixel is a single bit: `1` means the pixel is on (lit up) and `0` means it is off.

You represent each row of the grid as an 8-bit signal. The leftmost pixel in a row is the most significant bit (bit 7) and the rightmost is the least significant bit (bit 0).

For example, this row:

```
# # . . . . # #   →   11000011   →   8'b11000011
```

has pixels on at positions 7, 6, 1, and 0. Writing it out as a binary literal makes the pattern immediately readable — you can see the image just by looking at the code.

Eight rows of 8 bits each gives you 64 pixels total: a complete 8x8 image.

## The starter code

Open the circuit below. You will see the Viz pane rendering the display on the right, and the Editor on the left where you will write your logic.

<div id="mc-pixel-art" class="makerchip-embed"></div>

The starter code already has Pattern 0 (a smiley face) fully working. Take a moment to look at how it is structured:

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

Each row is defined as a constant 8-bit value. The comments show the pixel pattern in ASCII art so you can read the image directly in the code.

The pattern selector at the bottom uses the MUX syntax from Module 1.2 to choose between images:

```tlv
$row0[7:0] = $pattern == 2'b01 ? $heart_r0 : $smiley_r0;
```

When `$pattern` is `01`, the output is the heart row. Otherwise it is the smiley.

!!! note "How the cycling works"

    The `$pattern` signal auto-cycles every 16 clock cycles so you can see all your patterns animate in the Viz pane without needing to manually change inputs. When you add your own patterns, they will appear automatically in the rotation.

## Exercise: Draw the heart

Pattern 1 is currently all zeros — a blank screen. Your task is to fill in the 8 heart rows with the correct pixel values.

Here is the heart pattern you are aiming for:

```
. # # . . # # .   →   01100110   →   8'b01100110
# # # # # # # #   →   11111111   →   8'b11111111
# # # # # # # #   →   11111111   →   8'b11111111
# # # # # # # #   →   11111111   →   8'b11111111
. # # # # # # .   →   01111110   →   8'b01111110
. . # # # # . .   →   00111100   →   8'b00111100
. . . # # . . .   →   00011000   →   8'b00011000
. . . . . . . .   →   00000000   →   8'b00000000
```

Replace the placeholder rows in the `$heart_r0` through `$heart_r7` assignments with the correct values. Compile and watch the heart appear in the Viz pane when the pattern cycles to `01`.

??? hint "Hint"

    Write out the pixel pattern row by row on paper first — mark each cell as `#` (on) or `.` (off). Then convert each row to binary from left to right, where `#` is `1` and `.` is `0`. The comment next to each assignment is a great place to keep your ASCII art so you can read the image in the code.

??? solution "Solution"

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

Pattern 2 is reserved for your own design. Fill in `$custom_r0` through `$custom_r7` with whatever you want to draw.

Some ideas: your initials, a spaceship, a star, an arrow, a house, a Tetris piece. The constraint of 8x8 pixels is part of the fun — you have to think carefully about what fits and what reads clearly at low resolution.

Once your pattern is working, take a screenshot of the Viz pane. You have just designed hardware that renders an image.

## Challenge: Add a fourth pattern

The `$pattern` signal is 2 bits, which gives you four possible values: `00`, `01`, `10`, and `11`. The starter code only uses three of them. Add a fourth pattern using `$pattern == 2'b11` and extend the MUX to include it.

??? hint "Hint"

    Add a set of `$pattern3_rN` signals for your new image, then extend each row MUX from a 3-way to a 4-way selection. The structure is exactly the same as the 4-to-1 MUX from Module 1.2 — one condition per pattern, a default at the bottom.

## What you just built

Take a moment to look at the full circuit and recognize every piece of it.

The **row signals** (`$smiley_r0` through `$custom_r7`) are constant combinational assignments — the simplest form of gate logic. Each one is a fixed binary value that defines a row of pixels.

The **pattern MUX** is the 4-to-1 MUX from Module 1.2, applied 8 times (once per row). The `$pattern` input is the select line. The row signals are the inputs. The `$rowN` outputs are what the Viz pane reads.

The **Viz pane** is reading those 8 output signals and drawing pixels based on their bit values. The hardware is the circuit. The visualization is just making it visible.

This is how real display hardware works. The pixels on your screen right now are being driven by circuits that are not fundamentally different from what you just built.

## Where this fits next

In Block 2 you will add **state** to your circuits. Instead of constant patterns, you will be able to make things move — a pixel that shifts position every clock cycle, a counter that drives an animation. The same 8x8 grid, but now alive.

<style>
.makerchip-embed { position: relative; width: 100%; height: 600px; }
</style>

<script type="module">
  import IdePlugin from 'https://beta.makerchip.com/dist/makerchip-plugin.js';

  const base = 'https://raw.githubusercontent.com/in-ir/makerchip-curriculum/main/code/block-1/';

  // EDITOR + VIZ — students write pixel patterns and see them rendered live
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
    new EditorVizIDE('mc-pixel-art', {
      codeURL: base + 'pixel-art.tlv'
    });
  }
</script>
