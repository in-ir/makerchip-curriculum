# Module 2.1: Registers

**Block 2 — Sequential Logic**
**Estimated time:** 45–60 minutes
**Prerequisites:** Block 1 — Combinational Logic

## What you'll learn

By the end of this module you will be able to explain why combinational logic alone cannot remember anything, describe what a flip-flop does on a clock tick, read and write a register in TL-Verilog using the `>>1` operator, avoid the two most common beginner mistakes with sequential logic, and use a register to track a value over time, not just count.

## The wall you're about to hit

Everything you built in Block 1 shares one property: the output depends only on the inputs *right now*. An AND gate doesn't remember what its inputs were a moment ago, it just reacts.

Try this one in your head: build a circuit that counts how many times a button has been pressed. Where would the running total live? Nothing in Block 1 has a place to put it, because nothing persists from one moment to the next. To count, score, or remember anything at all, a circuit needs memory. That's the entire problem this module solves.

## The flip-flop: a photo taken once per tick

A **flip-flop** is a tiny piece of hardware that watches its input and, at one specific instant called the **clock edge**, captures whatever value is there and holds it. Between edges, the input can do whatever it wants, the flip-flop ignores it completely.

Think of a camera that snaps exactly one photo per second no matter what's happening in front of it. The photo on display only changes the instant the shutter clicks. A **register** is just several flip-flops working together to hold a multi-bit value, like a 4-bit number instead of a single bit.

## `>>1`: reaching one cycle into the past

```
$count[3:0] = >>1$count + 1;
```

`>>1$count` means "the value `$count` had one clock cycle ago." So this line says: take last cycle's count, add one, that's this cycle's count. One adder, one register, feeding into each other.

??? note "Why don't I write `clk` myself?"

    Raw Verilog spells out `always @(posedge clk)` every time. TL-Verilog skips that, `>>1$signal` already tells the tool "register this on the clock edge." That's all you need for this entire block.

Here's that counter live. Hover over a couple of consecutive cycles in the waveform and check: does this cycle's `$count` equal last cycle's value, plus one?

<div id="mc-register-demo" class="makerchip-embed-small"></div>

## Watch it break: no reset

What happens if a register never gets told where to start? Run this one and look at `$count` in cycle 0.

<div id="mc-register-no-reset" class="makerchip-embed-small"></div>

In simulation it happens to start near zero, but on a real chip a flip-flop powers on holding whatever electrical noise was sitting in it, could be anything. That's why `*reset` exists, it's a signal Makerchip pulses high for the first few cycles specifically so you can force a known starting value:

```
$count[3:0] = *reset ? 4'b0 : >>1$count + 1;
```

## Watch it break: `$x` instead of `>>1$x`

```
$count[3:0] = *reset ? 4'b0 : $count + 1;
```

This says "this cycle's count depends on this cycle's count." No notion of time at all, just a circular definition, the hardware equivalent of `x = x + 1` in ordinary math. The tool rejects it. Anywhere you mean "my value from before," it has to be `>>1$count`, never bare `$count`.

## Beyond counting: holding any value

A register doesn't have to add one each cycle. It can hold a score, a flag, the biggest number seen so far, anything. The recipe is always: look at `>>1`'s value, decide the new value, let the register carry it forward.

```
$max_so_far[3:0] = *reset ? 4'b0 :
                   ($in > >>1$max_so_far) ? $in : >>1$max_so_far;
```

Every cycle, compare the new input against what's currently held. Bigger wins, otherwise just keep holding.

## Match the waveform

A register is toggling and counting below. Predict each signal before pressing play.

<div id="mc-register-waveform" class="makerchip-embed-small"></div>

## Your turn: track the maximum

This circuit feeds a pseudo-random 4-bit value into `$in` every cycle. Complete `$max_so_far` using the reasoning above. Hints are in the editor comments.

<div id="mc-register-exercise" class="makerchip-embed"></div>

## Where this fits next

You can now give a circuit memory: hold a value, reset it to something known, update it based on its own past.

In Module 2.2 you'll wire this register-plus-feedback idea into a proper **counter**, with control over when it counts, when it holds, and when it wraps back to zero.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| Previous value | `>>1$signal` | The value `$signal` held one clock cycle ago |
| Basic register | `$x = >>1$x + 1;` | Holds and updates a value each cycle |
| Reset to zero | `$x = *reset ? 0 : >>1$x + 1;` | Forces a known value when reset is active |
| Conditional hold | `$x = cond ? new_val : >>1$x;` | Updates only when a condition is true, otherwise holds |

<style>
.makerchip-embed       { position: relative; width: 100%; height: 500px; }
.makerchip-embed-small { position: relative; width: 100%; height: 333px; }
</style>

<script type="module">
  import IdePlugin from 'https://beta.makerchip.com/dist/makerchip-plugin.js';

  const base = 'https://raw.githubusercontent.com/in-ir/makerchip-curriculum/main/code/block-2/';

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

  class WaveformOnlyIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({
        panes: ['Waveform'],
        activePane: 'Waveform'
      });
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

  if (document.getElementById('mc-register-demo')) {
    new WaveformOnlyIDE('mc-register-demo', {
      codeURL: base + 'register-demo.tlv'
    });
  }

  if (document.getElementById('mc-register-no-reset')) {
    new WaveformOnlyIDE('mc-register-no-reset', {
      codeURL: base + 'register-no-reset.tlv'
    });
  }

  if (document.getElementById('mc-register-waveform')) {
    new WaveformOnlyIDE('mc-register-waveform', {
      codeURL: base + 'register-waveform.tlv'
    });
  }

  if (document.getElementById('mc-register-exercise')) {
    new EditorWaveformIDE('mc-register-exercise', {
      codeURL: base + 'register-exercise.tlv'
    });
  }
</script>
