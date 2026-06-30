# Module 2.1: Registers

**Block 2 — Sequential Logic**
**Estimated time:** 45–60 minutes
**Prerequisites:** Block 1 — Combinational Logic

## What you'll learn

By the end of this module you will be able to explain why combinational logic alone cannot remember anything, describe what a flip-flop does on a clock tick, read and write a register in TL-Verilog using the `>>1` operator, trace a register's value across a few cycles by hand, avoid the two most common beginner mistakes with sequential logic, and use a register to track a value over time, not just count.

## The wall you're about to hit

Everything you built in Block 1 shares one property: the output depends only on the inputs *right now*. An AND gate doesn't remember what its inputs were a moment ago, it just reacts. Change the input, the output changes with it, instantly, with nothing in between.

So try this one in your head: build a circuit that counts how many times a button has been pressed. Where would the running total live? You don't have anywhere to put it, every signal you wrote in Block 1 is computed fresh, from scratch, every single moment, with no memory of what came before. To count, score, or remember anything at all, a circuit needs a way to hold onto a value across time. That's the entire problem this module solves, and it's a bigger deal than it sounds. Almost nothing you'd call "computing" exists without it.

## The flip-flop: a photo taken once per tick

The piece of hardware that solves this is called a **flip-flop**. Here's the whole idea: a flip-flop watches its input, and at one precise instant called the **clock edge**, it captures whatever value the input has right then and holds onto it, completely ignoring the input until the next clock edge comes around.

Picture a camera rigged to take exactly one photo per second, no matter what's happening in front of it. Between clicks, you can wave your arms, change your shirt, do whatever you want, none of it touches the photo currently sitting on the camera's screen. The displayed image only updates the instant the shutter fires. That click is the clock edge. What's on screen between clicks is the flip-flop's stored value.

A **register** is just several flip-flops working in lockstep to hold a multi-bit value, a 4-bit number instead of a single bit, say. Same idea, more cameras clicking together.

## `>>1`: reaching one cycle into the past

```
$count[3:0] = >>1$count + 1;
```

Read `>>1$count` as "the value `$count` held one clock cycle ago." So this whole line says: take last cycle's count, add one, that becomes this cycle's count. One adder and one register, feeding into each other.

??? note "Why don't I write `clk` myself?"

    Raw Verilog spells out `always @(posedge clk)` every time you want a register. TL-Verilog skips the boilerplate, the moment you write `>>1$signal`, the tool already knows you mean "register this on the clock edge." That's all the timing control you need for this entire block.

Let's actually trace this by hand before trusting the tool to do it for us. Say reset forces `$count` to `0` in cycle 0. In cycle 1, `>>1$count` looks back at cycle 0's value, `0`, so `$count` becomes `0 + 1 = 1`. In cycle 2, `>>1$count` looks back at cycle 1's value, `1`, so `$count` becomes `1 + 1 = 2`. Notice the pattern: at every cycle, `>>1$count` is just whatever `$count` equaled one cycle earlier. It's not simultaneous, it's a strict, predictable one-cycle delay, every time.

Now check yourself against the real thing. Hover a couple of consecutive cycles below and confirm the math.

<div id="mc-register-demo" class="makerchip-embed-small"></div>

## Watch it break: no reset

What happens if a register never gets told where to start? Run this one and look closely at `$count` in cycle 0.

<div id="mc-register-no-reset" class="makerchip-embed-small"></div>

In simulation it happens to land near zero, which can trick you into thinking reset doesn't matter. On a real chip it absolutely does. A physical flip-flop, the instant power turns on, holds whatever electrical noise happened to be sitting in its circuitry, could be a `1`, could be a `0`, no guarantees either way. That's why `*reset` exists, a signal Makerchip pulses high for the first few cycles specifically so you can force a known starting value before relying on anything:

```
$count[3:0] = *reset ? 4'b0 : >>1$count + 1;
```

## Watch it break: `$x` instead of `>>1$x`

```
$count[3:0] = *reset ? 4'b0 : $count + 1;
```

This says "this cycle's count depends on this cycle's count." There's no notion of time in that at all, just a circular definition, the hardware equivalent of writing `x = x + 1` in ordinary math and expecting it to mean something. The tool will reject this outright. Anywhere you mean "my value from before," it has to be `>>1$count`, never bare `$count`. That `>>1` is the only thing that turns a meaningless circle into an actual register.

## Beyond counting: holding any value

A register doesn't have to add one each cycle, it can hold a score, a flag, the biggest number seen so far, anything at all. The recipe never changes: check `>>1`'s value, decide the new value, let the register carry it forward.

```
$max_so_far[3:0] = *reset ? 4'b0 :
                   ($in > >>1$max_so_far) ? $in : >>1$max_so_far;
```

Read it out loud: every cycle, compare the new input against whatever's currently held. Bigger wins and gets stored. Otherwise, just keep holding what was already there.

## Match the waveform

A register is toggling and counting below. Predict each signal's behavior before pressing play, then check yourself.

<div id="mc-register-waveform" class="makerchip-embed-small"></div>

## Your turn: track the maximum

This circuit feeds a pseudo-random 4-bit value into `$in` every cycle. Complete `$max_so_far` using the exact reasoning from above. Hints are in the editor comments.

<div id="mc-register-exercise" class="makerchip-embed"></div>

## Where this fits next

You can now give a circuit memory: hold a value, reset it to something known, update it based on its own past, and trace that update by hand closely enough to predict it.

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
