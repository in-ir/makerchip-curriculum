# Module 1.2: The Multiplexer (MUX)

**Block 1 — Combinational Logic**  
**Estimated time:** 45–60 minutes  
**Prerequisites:** Module 1.1 — Logic Gates

## What you'll learn

By the end of this module you will be able to explain what a multiplexer does and why it is useful, read and write a 2-to-1 MUX in TL-Verilog using the ternary operator, scale a 2-to-1 MUX to a 4-to-1 MUX using chained conditions, use a MUX to select between signals in a circuit, and solve a MUX-based design challenge.

## A programmable switch

You now know how logic gates work. Gates are fixed: an AND gate always ANDs, an OR gate always ORs. But what if you want a circuit that can **choose** what it does based on a control signal?

That is what a **multiplexer**, or **MUX**, does.

A MUX is a circuit that selects one of several input signals and forwards it to the output. The selection is controlled by one or more **select lines**. Think of it like a railway switch. Multiple tracks come in, but only one is routed forward, and the switch lever decides which one.

MUXes are everywhere in digital design. Every time a processor chooses between two values or a circuit picks a path, there is almost certainly a MUX doing that work.

## The 2-to-1 MUX

The simplest MUX has two inputs, one select line, and one output.

| SEL | Output |
| --- | ------ |
| 0   | A      |
| 1   | B      |

When SEL is `0`, the output is whatever A is. When SEL is `1`, the output is whatever B is.

**Circuit diagram:**

![2-to-1 MUX](../assets/images/2to1-mux.svg)

**In TL-Verilog:**

```tlv
$out = $sel ? $b : $a;
```

This uses the **ternary operator**, the same `?:` you may know from C or Python. Read it as: if SEL is true, output B, otherwise output A. One line. That is a complete 2-to-1 MUX.

??? note "Why ternary?"

    TL-Verilog uses `?:` for MUX-like selection because it maps directly to hardware. The synthesizer sees `condition ? x : y` and produces exactly a MUX circuit. It is not just shorthand. It is the idiomatic way to describe selection in hardware description languages.

### See the MUX circuit in Makerchip

The embed below shows the 2-to-1 MUX circuit and its waveform. Watch the `$out` signal: it should follow `$a` when `$sel` is `0` and follow `$b` when `$sel` is `1`.

<div id="mc-mux-demo" class="makerchip-embed"></div>

??? note "What are `clk` and `reset`?"

    Makerchip always shows `clk` and `reset` in the waveform. Ignore them for now. Combinational circuits do not use a clock. The output responds instantly to the inputs with no timing involved. You will learn what the clock does when we get to sequential logic in Block 2.

| Cycle | $sel | $a  | $b  | $out |
| ----- | ---- | --- | --- | ---- |
| 1     | 0    | 0   | 1   | 0    |
| 2     | 0    | 1   | 0   | 1    |
| 3     | 1    | 0   | 1   | 1    |
| 4     | 1    | 1   | 0   | 0    |

In cycles 1 and 2, SEL is `0` so the output follows A. In cycles 3 and 4, SEL is `1` so the output follows B. The select line is the lever; A and B are the tracks.

## Match the waveform

Look at the waveform below. Three signals `$a`, `$b`, and `$sel` produce an output `$out`. Study the pattern and determine what the relationship is between `$sel` and `$out`.

<div id="mc-mux-waveform" class="makerchip-embed-small"></div>

| Cycle | $sel | $a  | $b  | $out |
| ----- | ---- | --- | --- | ---- |
| 1     | 0    | 1   | 0   | 1    |
| 2     | 1    | 1   | 0   | 0    |
| 3     | 0    | 0   | 1   | 0    |
| 4     | 1    | 0   | 1   | 1    |

Write the TL-Verilog expression for `$out`, then verify it in the exercise below.

??? hint "How to read the pattern"

    In cycle 1, `$sel` is `0` and `$out` matches `$a` which is `1`. In cycle 2, `$sel` is `1` and `$out` matches `$b` which is `0`. The output always tracks one of the two inputs. Which one depends on `$sel`. Which operator selects between two values based on a condition?

??? solution "Solution"

    ```tlv
    $out = $sel ? $b : $a;
    ```

    When `$sel` is `0` the output follows `$a`. When `$sel` is `1` it follows `$b`. This is exactly the ternary operator mapping to a 2-to-1 MUX.

## Exercise: Code the 2-to-1 MUX

Now write it yourself. Replace `$out = 1'b0` with the correct MUX logic and compile. Check that the waveform matches the table above.

<div id="mc-mux-exercise-basic" class="makerchip-embed"></div>

??? hint "Hint"

    Use the ternary operator: `condition ? value_if_true : value_if_false`. What is the condition here? What are the two values to choose between?

??? solution "Solution"

    ```tlv
    $out = $sel ? $b : $a;
    ```

## Scaling up: the 4-to-1 MUX

What if you have four inputs and want to select between them? You need two select lines, because two bits give you four combinations: 00, 01, 10, and 11.

**Selection table:**

| SEL[1:0] | Output |
| -------- | ------ |
| 00       | A      |
| 01       | B      |
| 10       | C      |
| 11       | D      |

In TL-Verilog, you chain conditions using `==`:

```tlv
$out = $sel == 2'b11 ? $d :
       $sel == 2'b10 ? $c :
       $sel == 2'b01 ? $b :
                       $a;
```

Read it top to bottom: check each value of SEL in order and output the matching signal. The last line is the default. If none of the conditions above matched, output A.

!!! tip "MUX trees"

    You can extend this pattern for as many inputs as you need. An 8-to-1 MUX checks 8 conditions with a 3-bit select. The structure stays the same: one condition per input, a default at the bottom.

## Exercise: Build a 4-to-1 MUX with logic output

Build a 4-to-1 MUX where each input is a logic expression. When `$sel == 2'b00`, output `$x AND $y`. When `$sel == 2'b01`, output `$x OR $y`. When `$sel == 2'b10`, output `NOT $x`. When `$sel == 2'b11`, output `$x XOR $y`.

<div id="mc-mux-exercise" class="makerchip-embed"></div>

The starter code has `$out = 1'b0` as a placeholder. Replace it with the correct MUX logic.

??? hint "Hint"

    Break it into two steps. First compute all four expressions as intermediate signals:

    ```tlv
    $and = $x && $y;
    $or  = $x || $y;
    $not = !$x;
    $xor = $x ^ $y;
    ```

    Then chain them into a 4-to-1 MUX using `==` conditions.

??? solution "Solution"

    ```tlv
    $and = $x && $y;
    $or  = $x || $y;
    $not = !$x;
    $xor = $x ^ $y;

    $out = $sel == 2'b11 ? $xor :
           $sel == 2'b10 ? $not :
           $sel == 2'b01 ? $or  :
                           $and;
    ```

    Compute your signals first, then select between them. This keeps the gate logic and the selection logic clean and easy to read.

## Challenge: 2-bit function selector

Build a circuit that applies a different operation depending on a 2-bit opcode. You have two 1-bit inputs `$a` and `$b`, and a 2-bit opcode `$op[1:0]`. Based on the opcode, the output should be:

| $op | Output      |
| --- | ----------- |
| 00  | `$a AND $b` |
| 01  | `$a OR $b`  |
| 10  | `$a XOR $b` |
| 11  | `NOT $a`    |

This is a simplified ALU, a circuit that selects between operations based on a control code. You will build a full one in Module 1.4.

<div id="mc-mux-challenge" class="makerchip-embed"></div>

??? hint "Hint"

    Same pattern as the exercise. Compute all four results first as intermediate signals, then use `$op` as your select to choose between them.

??? solution "Solution"

    ```tlv
    $and = $a && $b;
    $or  = $a || $b;
    $xor = $a ^ $b;
    $not = !$a;

    $out = $op == 2'b11 ? $not :
           $op == 2'b10 ? $xor :
           $op == 2'b01 ? $or  :
                          $and;
    ```

    Notice that NOT only uses `$a`. When `$op == 2'b11`, `$b` is ignored entirely. That is perfectly fine. In a real ALU, some operations do not use all inputs.

## Where this fits next

You now have two of the most important combinational building blocks: gates and MUXes. These two alone can express any combinational logic function.

In Module 1.3 you will meet the **decoder**, a circuit that takes a binary number and activates exactly one output line. It shows up inside ALUs, memory addressing, and instruction decoding in real processors.

## Quick reference

| Circuit    | TL-Verilog                        | What it does                              |
| ---------- | --------------------------------- | ----------------------------------------- |
| 2-to-1 MUX | `$out = $sel ? $b : $a`           | Select A or B based on SEL                |
| 4-to-1 MUX | `$out = $sel == 2'b11 ? $d : ...` | Select between inputs using == conditions |

<style>
.makerchip-embed       { position: relative; width: 100%; height: 500px; }
.makerchip-embed-small { position: relative; width: 100%; height: 333px; }
</style>

<script type="module">
  import IdePlugin from 'https://beta.makerchip.com/dist/makerchip-plugin.js';

  const base = 'https://raw.githubusercontent.com/in-ir/makerchip-curriculum/main/code/block-1/';

  // DIAGRAM + WAVEFORM — for circuit demos
  class DiagramWaveformIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({
        sides: {
          left:  { panes: ['Diagram'],  activePane: 'Diagram'  },
          right: { panes: ['Waveform'], activePane: 'Waveform' }
        },
        splitAt: 0.5
      });
    }
  }

  // WAVEFORM only — for match-the-waveform exercises
  class WaveformOnlyIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({
        panes: ['Waveform'],
        activePane: 'Waveform'
      });
      await this.compile();
    }
  }

  // EDITOR + WAVEFORM — for coding exercises
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

  // MUX demo — DIAGRAM + WAVEFORM
  if (document.getElementById('mc-mux-demo')) {
    new DiagramWaveformIDE('mc-mux-demo', {
      codeURL: base + '2to1-mux.tlv'
    });
  }

  // Match the waveform — WAVEFORM only
  if (document.getElementById('mc-mux-waveform')) {
    new WaveformOnlyIDE('mc-mux-waveform', {
      codeURL: base + '2to1-mux.tlv'
    });
  }

  // Basic MUX coding exercise — EDITOR + WAVEFORM
  if (document.getElementById('mc-mux-exercise-basic')) {
    new EditorWaveformIDE('mc-mux-exercise-basic', {
      codeURL: base + 'mux-exercise.tlv'
    });
  }

  // 4-to-1 MUX exercise — EDITOR + WAVEFORM
  if (document.getElementById('mc-mux-exercise')) {
    new EditorWaveformIDE('mc-mux-exercise', {
      codeURL: base + 'mux-exercise.tlv'
    });
  }

  // Challenge — EDITOR + WAVEFORM
  if (document.getElementById('mc-mux-challenge')) {
    new EditorWaveformIDE('mc-mux-challenge', {
      codeURL: base + 'mux-challenge.tlv'
    });
  }
</script>
