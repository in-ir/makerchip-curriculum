# Module 1.3: Decoders

**Block 1 Combinational Logic**  
**Estimated time:** 45–60 minutes  
**Prerequisites:** Module 1.2 The Multiplexer

## What you'll learn

By the end of this module you'll be able to:

- Explain what a decoder does and where it shows up in real hardware
- Read and write a 2-to-4 decoder in TL-Verilog
- Understand the relationship between decoders and MUXes
- Build a 3-to-8 decoder from scratch
- Apply decoder logic to drive a 7-segment display

## One input, many outputs

So far every circuit you've built has taken multiple inputs and produced one output. A decoder flips that around.

A **decoder** takes an n-bit binary input and activates exactly one of 2^n outputs the one that corresponds to the input value. Everything else stays at `0`.

Think of it like a postal sorting machine. A package comes in with a zip code (your input), and the machine routes it to exactly one delivery chute (your output). All the other chutes stay closed.

Decoders show up everywhere in real hardware. Every time a processor needs to figure out which instruction to execute, which memory address to access, or which register to write to, there's a decoder doing that routing work.

## The 2-to-4 decoder

The simplest useful decoder: **2 input bits, 4 output lines**.

With 2 bits you can represent 4 different values 00, 01, 10, 11. The decoder takes that 2-bit input and raises exactly one of four output lines high.

**Truth table:**

| IN[1] | IN[0] | Y[3] | Y[2] | Y[1] | Y[0] |
| ----- | ----- | ---- | ---- | ---- | ---- |
| 0     | 0     | 0    | 0    | 0    | 1    |
| 0     | 1     | 0    | 0    | 1    | 0    |
| 1     | 0     | 0    | 1    | 0    | 0    |
| 1     | 1     | 1    | 0    | 0    | 0    |

Read it row by row: when the input is `00`, only Y[0] is `1`. When the input is `01`, only Y[1] is `1`. And so on.

**Circuit diagram:**

![2-to-4 decoder](../assets/images/decoder-2to4.jpg)

**In TL-Verilog:**

```tlv
$y[3:0] = $in[1:0] == 2'b11 ? 4'b1000 :
           $in[1:0] == 2'b10 ? 4'b0100 :
           $in[1:0] == 2'b01 ? 4'b0010 :
                               4'b0001;
```

You already know this pattern it's the same chained condition syntax from Module 1.2. The difference is that instead of selecting a single-bit signal, you're outputting a 4-bit one-hot value (exactly one bit set to `1`).

!!! note "One-hot encoding"
    The output pattern of a decoder exactly one bit high at a time is called **one-hot encoding**. It's used throughout digital design when you need to represent mutually exclusive states. FSMs, instruction decoders, and memory address logic all use this idea.

### See it running in Makerchip

<iframe src="http://www.makerchip.com/sandbox?code_url=https:%2F%2Fraw.githubusercontent.com%2Fin-ir%2Fmakerchip-curriculum%2Fmain%2Fcode%2Fblock-1%2F2to4-decoder.tlv" style="width:100%; height:500px; border:none;"></iframe>

Watch the `$y` signal in the waveform. As `$in` cycles through 00, 01, 10, 11, you should see the active bit shift from the right to the left one bit moving across four outputs like a spotlight scanning across a stage.

## The decoder as an inverse MUX

It helps to think of decoders and MUXes as opposites:

- A **MUX** takes many inputs and routes one to the output, based on a select signal
- A **decoder** takes one input (the select) and routes it to one of many outputs

In fact, you can build a MUX out of a decoder and some AND gates. That's not something you need to do right now, but it shows how these building blocks compose understanding one deepens your understanding of the other.

## Exercise: 3-to-8 decoder

**Build a 3-to-8 decoder.**

You have a 3-bit input `$in[2:0]`. Your output `$y[7:0]` should have exactly one bit set to `1` the bit corresponding to the value of `$in`.

For example, when `$in = 3'b101` (which is 5 in decimal), `$y[5]` should be `1` and all others should be `0`.

<iframe src="http://www.makerchip.com/sandbox?code_url=https:%2F%2Fraw.githubusercontent.com%2Fin-ir%2Fmakerchip-curriculum%2Fmain%2Fcode%2Fblock-1%2Fdecoder-exercise.tlv" style="width:100%; height:500px; border:none;"></iframe>

The starter code has `$y[7:0] = 8'b0` as a placeholder. Replace it with the correct decoder logic.


??? hint "Hint"
    Same pattern as the 2-to-4 decoder, just with 8 cases instead of 4. Work through each value of `$in` from `3'b111` down to the default, and for each one output an 8-bit value with exactly one `1` in the right position.

??? solution "Solution"
    ```tlv
    $y[7:0] = $in[2:0] == 3'b111 ? 8'b10000000 :
               $in[2:0] == 3'b110 ? 8'b01000000 :
               $in[2:0] == 3'b101 ? 8'b00100000 :
               $in[2:0] == 3'b100 ? 8'b00010000 :
               $in[2:0] == 3'b011 ? 8'b00001000 :
               $in[2:0] == 3'b010 ? 8'b00000100 :
               $in[2:0] == 3'b001 ? 8'b00000010 :
                                    8'b00000001;
    ```

    Check the waveform: as `$in` counts from 0 to 7, the single active bit in `$y` should march from right to left. If it does, your decoder is working correctly.

## Challenge: 7-segment display driver

Every digital clock, calculator, and scoreboard you've ever seen uses a **7-segment display** those rectangular digits made of seven individually-controlled LED segments.

Each segment is labeled A through G:

```
 _
|_|
|_|

Segments: A (top), B (top-right), C (bottom-right),
          D (bottom), E (bottom-left), F (top-left), G (middle)
```

To display a digit, you turn on the right combination of segments. For example:

- **0** → A, B, C, D, E, F on; G off
- **1** → B, C on; everything else off
- **7** → A, B, C on; everything else off

**The task:** Build a circuit that takes a 4-bit BCD input `$digit[2:0]` (representing digits 0–7) and outputs a 7-bit signal `$seg[6:0]` where each bit controls one segment.

Use this mapping for `$seg`: `{A, B, C, D, E, F, G}` where bit 6 is segment A (top) and bit 0 is segment G (middle).

| Digit | A | B | C | D | E | F | G | `$seg` (binary) |
| ----- | - | - | - | - | - | - | - | --------------- |
| 0     | 1 | 1 | 1 | 1 | 1 | 1 | 0 | 1111110         |
| 1     | 0 | 1 | 1 | 0 | 0 | 0 | 0 | 0110000         |
| 2     | 1 | 1 | 0 | 1 | 1 | 0 | 1 | 1101101         |
| 3     | 1 | 1 | 1 | 1 | 0 | 0 | 1 | 1111001         |
| 4     | 0 | 1 | 1 | 0 | 0 | 1 | 1 | 0110011         |
| 5     | 1 | 0 | 1 | 1 | 0 | 1 | 1 | 1011011         |
| 6     | 1 | 0 | 1 | 1 | 1 | 1 | 1 | 1011111         |
| 7     | 1 | 1 | 1 | 0 | 0 | 0 | 0 | 1110000         |

<iframe src="http://www.makerchip.com/sandbox?code_url=https:%2F%2Fraw.githubusercontent.com%2Fin-ir%2Fmakerchip-curriculum%2Fmain%2Fcode%2Fblock-1%2Fdecoder-challenge.tlv" style="width:100%; height:500px; border:none;"></iframe>


??? hint "Hint"
    Same chained condition pattern, one case per digit. For each value of `$digit`, output the 7-bit segment pattern from the table above.

??? solution "Solution"
    ```tlv
    $seg[6:0] = $digit[2:0] == 3'd7 ? 7'b1110000 :
                $digit[2:0] == 3'd6 ? 7'b1011111 :
                $digit[2:0] == 3'd5 ? 7'b1011011 :
                $digit[2:0] == 3'd4 ? 7'b0110011 :
                $digit[2:0] == 3'd3 ? 7'b1111001 :
                $digit[2:0] == 3'd2 ? 7'b1101101 :
                $digit[2:0] == 3'd1 ? 7'b0110000 :
                                      7'b1111110;
    ```

    In real hardware, 7-segment display drivers are one of the first things engineers build when learning FPGAs. You just built one. Every digit on a digital clock works exactly like this.

## Where this fits next

Decoders are the last pure gate-level building block you need before arithmetic. In **Module 1.4**, you'll put everything together into an **ALU** — an Arithmetic Logic Unit — the circuit at the heart of every processor. Gates, MUXes, and decoders are all the ingredients you need.

## Quick reference

| Circuit      | TL-Verilog pattern                              | What it does                        |
| ------------ | ----------------------------------------------- | ----------------------------------- |
| 2-to-4 decoder | `$y[3:0] = $in == 2'b11 ? 4'b1000 : ...`     | One-hot output from 2-bit input     |
| 3-to-8 decoder | `$y[7:0] = $in == 3'b111 ? 8'b10000000 : ...`| One-hot output from 3-bit input     |
| 7-seg driver   | `$seg[6:0] = $digit == 3'd7 ? 7'b1110000 : ...` | Segment pattern from digit value |
