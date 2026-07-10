# Module 2.1: Registers

**Block 2 — Sequential Logic**  
**Estimated time:** 60–90 minutes  
**Prerequisites:** Block 1

<div id="mc-register-teaser" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to explain why combinational logic alone cannot remember anything, describe what a flip-flop does on a clock tick, read and write a register in TL-Verilog using the `>>1` operator, trace a register's value across a few cycles by hand, avoid the two most common beginner mistakes with sequential logic, and use a register to track a value over time, not just count.

## The wall you're about to hit

Everything you built in Block 1 shares one property: the output depends only on the inputs _right now_. An AND gate doesn't remember what its inputs were a moment ago, it just reacts. Change the input, the output changes with it instantly, with nothing in between.

So try this one in your head: build a circuit that counts how many times a button has been pressed. Where would the running total live? You don't have anywhere to put it. Every signal you wrote in Block 1 is computed fresh from scratch every single moment, with no memory of what came before. To count, score, or remember anything at all, a circuit needs a way to hold onto a value across time. That's the entire problem this module solves.

## The flip-flop: a photo taken once per tick

The piece of hardware that solves this is called a **flip-flop**. Here's the whole idea: a flip-flop watches its input, and at one precise instant called the **clock edge**, it captures whatever value the input has right then and holds onto it, completely ignoring the input until the next clock edge comes around.

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 860 180" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="arr" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#7C4DFF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
    <marker id="arr2" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <!-- Clock waveform on left -->

<text x="30" y="30" fill="#B39DDB" font-size="11" text-anchor="middle">clock</text>
<polyline points="10,80 10,50 40,50 40,80 70,80 70,50 100,50 100,80 130,80 130,50 160,50 160,80" fill="none" stroke="#7C4DFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>

  <!-- Edge markers -->
  <line x1="40" y1="45" x2="40" y2="90" stroke="#7C4DFF" stroke-width="1" stroke-dasharray="3 3" opacity="0.5"/>
  <line x1="100" y1="45" x2="100" y2="90" stroke="#7C4DFF" stroke-width="1" stroke-dasharray="3 3" opacity="0.5"/>
  <line x1="160" y1="45" x2="160" y2="90" stroke="#7C4DFF" stroke-width="1" stroke-dasharray="3 3" opacity="0.5"/>
  <text x="40" y="105" fill="#7C4DFF" font-size="10" text-anchor="middle">↑ edge</text>
  <text x="100" y="105" fill="#7C4DFF" font-size="10" text-anchor="middle">↑ edge</text>
  <text x="160" y="105" fill="#7C4DFF" font-size="10" text-anchor="middle">↑ edge</text>

  <!-- Arrow into flip-flop -->
  <line x1="175" y1="65" x2="245" y2="65" stroke="#7C4DFF" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="210" y="55" fill="#B39DDB" font-size="11" text-anchor="middle">D (input)</text>

  <!-- Flip-flop box -->
  <rect x="248" y="30" width="160" height="70" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1.5"/>
  <text x="328" y="60" fill="#EDE7F6" font-size="13" font-weight="600" text-anchor="middle">Flip-flop</text>
  <text x="328" y="78" fill="#B39DDB" font-size="10" text-anchor="middle">captures on ↑ edge</text>
  <!-- Clock input to FF -->
  <line x1="328" y1="150" x2="328" y2="100" stroke="#7C4DFF" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#arr)"/>
  <text x="328" y="165" fill="#7C4DFF" font-size="10" text-anchor="middle">clk</text>

  <!-- Arrow out of flip-flop -->
  <line x1="408" y1="65" x2="478" y2="65" stroke="#7C4DFF" stroke-width="1.5" marker-end="url(#arr)"/>
  <text x="443" y="55" fill="#B39DDB" font-size="11" text-anchor="middle">Q (output)</text>

  <!-- Output signal - shows held values -->

<text x="540" y="30" fill="#B39DDB" font-size="11" text-anchor="middle">Q holds steady</text>
<polyline points="480,80 520,80 520,50 600,50 600,80 680,80 680,50 760,50 760,80 830,80" fill="none" stroke="#7C4DFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
<text x="500" y="130" fill="#EDE7F6" font-size="10" text-anchor="middle">0</text>
<text x="560" y="130" fill="#EDE7F6" font-size="10" text-anchor="middle">1</text>
<text x="630" y="130" fill="#EDE7F6" font-size="10" text-anchor="middle">0</text>
<text x="710" y="130" fill="#EDE7F6" font-size="10" text-anchor="middle">1</text>
<text x="795" y="130" fill="#EDE7F6" font-size="10" text-anchor="middle">...</text>
<text x="640" y="155" fill="#B39DDB" font-size="10" text-anchor="middle">value captured at each ↑ edge, held until next</text>
</svg>

</div>

A **register** is just several flip-flops working in lockstep to hold a multi-bit value — a 4-bit number instead of a single bit.

## `>>1`: reaching one cycle into the past

```
$count[3:0] = >>1$count + 1;
```

Read `>>1$count` as "the value `$count` held one clock cycle ago." So this whole line says: take last cycle's count, add one, that becomes this cycle's count. One adder and one register, feeding into each other. Here's what that loop actually looks like as a circuit:

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 860 160" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="a1" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#7C4DFF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
    <marker id="a2" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <!-- Adder box -->
  <rect x="60" y="45" width="150" height="60" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1.5"/>
  <text x="135" y="72" fill="#EDE7F6" font-size="13" font-weight="600" text-anchor="middle">Adder</text>
  <text x="135" y="90" fill="#B39DDB" font-size="10" text-anchor="middle">>>1$count + 1</text>

  <!-- Arrow adder → flip-flop -->
  <line x1="210" y1="75" x2="295" y2="75" stroke="#7C4DFF" stroke-width="1.5" marker-end="url(#a1)"/>
  <text x="252" y="65" fill="#B39DDB" font-size="10" text-anchor="middle">D (next value)</text>

  <!-- Flip-flop box -->
  <rect x="297" y="35" width="160" height="80" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1.5"/>
  <text x="377" y="68" fill="#EDE7F6" font-size="13" font-weight="600" text-anchor="middle">Flip-flop</text>
  <text x="377" y="85" fill="#B39DDB" font-size="10" text-anchor="middle">captured on</text>
  <text x="377" y="100" fill="#7C4DFF" font-size="10" text-anchor="middle">clock edge</text>

  <!-- Arrow flip-flop → output -->
  <line x1="457" y1="75" x2="560" y2="75" stroke="#7C4DFF" stroke-width="1.5" marker-end="url(#a1)"/>
  <text x="508" y="65" fill="#B39DDB" font-size="10" text-anchor="middle">Q = $count</text>

  <!-- Output box -->
  <rect x="562" y="52" width="130" height="46" rx="4" fill="#0D001A" stroke="#B39DDB" stroke-width="1"/>
  <text x="627" y="72" fill="#EDE7F6" font-size="12" font-weight="600" text-anchor="middle">$count</text>
  <text x="627" y="88" fill="#7C4DFF" font-size="10" text-anchor="middle">this cycle's value</text>

  <!-- Feedback path -->
  <path d="M627 98 L627 135 L135 135 L135 105" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-dasharray="5 3" marker-end="url(#a2)"/>
  <text x="390" y="152" fill="#B39DDB" font-size="10" text-anchor="middle">one cycle later → becomes >>1$count</text>
</svg>
</div>

??? note "Why don't I write `clk` myself?"

    Raw Verilog spells out `always @(posedge clk)` every time you want a register. TL-Verilog skips the boilerplate — the moment you write `>>1$signal`, the tool already knows you mean "register this on the clock edge."

Let's trace this by hand, cycle by cycle, before trusting the tool:

<div style="margin: 2rem 0; overflow-x: auto;">
<table style="font-family: 'JetBrains Mono', monospace; font-size: 0.85em; border-collapse: collapse; width: 100%;">
  <thead>
    <tr>
      <th style="background: rgba(124, 77, 255, 0.3); padding: 10px 16px; text-align: left; border: 1px solid rgba(124, 77, 255, 0.3);">Cycle</th>
      <th style="background: rgba(124, 77, 255, 0.3); padding: 10px 16px; text-align: left; border: 1px solid rgba(124, 77, 255, 0.3);"><code>>>1$count</code> (last cycle)</th>
      <th style="background: rgba(124, 77, 255, 0.3); padding: 10px 16px; text-align: left; border: 1px solid rgba(124, 77, 255, 0.3);"><code>$count</code> (this cycle)</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #B39DDB;">0</td>
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #B39DDB;">— (reset active)</td>
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #7C4DFF; font-weight: 600;">0</td>
    </tr>
    <tr style="background: rgba(124, 77, 255, 0.05);">
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #B39DDB;">1</td>
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #B39DDB;">0</td>
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #7C4DFF; font-weight: 600;">0 + 1 = 1</td>
    </tr>
    <tr>
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #B39DDB;">2</td>
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #B39DDB;">1</td>
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #7C4DFF; font-weight: 600;">1 + 1 = 2</td>
    </tr>
    <tr style="background: rgba(124, 77, 255, 0.05);">
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #B39DDB;">3</td>
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #B39DDB;">2</td>
      <td style="padding: 10px 16px; border: 1px solid rgba(124, 77, 255, 0.2); color: #7C4DFF; font-weight: 600;">2 + 1 = 3</td>
    </tr>
  </tbody>
</table>
</div>

At every cycle, `>>1$count` is just whatever `$count` equaled one row above. A strict, predictable one-cycle delay, every time. Now check yourself against the live waveform:

<div id="mc-register-demo" class="makerchip-embed-small"></div>

## Watch it break: no reset

What happens if a register never gets told where to start? Run this and look at `$count` in cycle 0.

<div id="mc-register-no-reset" class="makerchip-embed-small"></div>

In simulation it lands near zero, which can trick you into thinking reset doesn't matter. On real hardware, a flip-flop powers on holding whatever electrical noise happened to be sitting in its circuitry. That's why `*reset` exists — Makerchip pulses it high for the first few cycles so you can force a known starting value:

```
$count[3:0] = *reset ? 4'b0 : >>1$count + 1;
```

## Watch it break: `$x` instead of `>>1$x`

```
$count[3:0] = *reset ? 4'b0 : $count + 1;  ← WRONG
```

This says "this cycle's count depends on this cycle's count." No notion of time — just a circular definition, the hardware equivalent of `x = x + 1` in ordinary math. The tool rejects it. Anywhere you mean "my value from before," it must be `>>1$count`, never bare `$count`.

## Beyond counting: holding any value

A register doesn't have to add one each cycle — it can hold a score, a flag, the biggest number seen so far, anything. The recipe never changes: check `>>1`'s value, decide the new value, let the register carry it forward.

```
$max_so_far[3:0] = *reset ? 4'b0 :
                   ($in > >>1$max_so_far) ? $in : >>1$max_so_far;
```

Every cycle: compare the new input against what's currently held. Bigger wins. Otherwise, keep holding.

## Match the waveform

A register is toggling and counting below. Predict each signal before pressing play.

<div id="mc-register-waveform" class="makerchip-embed-small"></div>

## Your turn: track the maximum

This circuit feeds a pseudo-random 4-bit value into `$in` every cycle. Complete `$max_so_far` using the reasoning above. Hints are in the editor comments.

<div id="mc-register-exercise" class="makerchip-embed"></div>

## Where this fits next

You can now give a circuit memory: hold a value, reset it to something known, update it based on its own past, and trace that update by hand.

In Module 2.2 you'll wire this register-plus-feedback idea into a proper **counter** — with control over when it counts, when it holds, and when it wraps back to zero.

## Quick reference

| Concept          | TL-Verilog                     | Description                                            |
| ---------------- | ------------------------------ | ------------------------------------------------------ |
| Previous value   | `>>1$signal`                   | The value `$signal` held one clock cycle ago           |
| Basic register   | `$x = >>1$x + 1;`              | Holds and updates a value each cycle                   |
| Reset to zero    | `$x = *reset ? 0 : >>1$x + 1;` | Forces a known value when reset is active              |
| Conditional hold | `$x = cond ? new_val : >>1$x;` | Updates only when a condition is true, otherwise holds |

<style>
.makerchip-embed       { position: relative; width: 100%; height: 500px; }
.makerchip-embed-small { position: relative; width: 100%; height: 333px; }
</style>

<script type="module">
  import IdePlugin from 'https://beta.makerchip.com/dist/makerchip-plugin.js';

  const base = 'https://raw.githubusercontent.com/in-ir/makerchip-curriculum/main/code/block-2/';

  class VizOnlyIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({
        panes: ['Viz'],
        activePane: 'Viz'
      });
      await this.compile();
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

  if (document.getElementById('mc-register-teaser')) {
    VizOnlyIDE.create('mc-register-teaser', {
      codeURL: base + 'register-hold-viz.tlv'
    });
  }

  if (document.getElementById('mc-register-demo')) {
    WaveformOnlyIDE.create('mc-register-demo', {
      codeURL: base + 'register-demo.tlv'
    });
  }

  if (document.getElementById('mc-register-no-reset')) {
    WaveformOnlyIDE.create('mc-register-no-reset', {
      codeURL: base + 'register-no-reset.tlv'
    });
  }

  if (document.getElementById('mc-register-waveform')) {
    WaveformOnlyIDE.create('mc-register-waveform', {
      codeURL: base + 'register-waveform.tlv'
    });
  }

  if (document.getElementById('mc-register-exercise')) {
    EditorWaveformIDE.create('mc-register-exercise', {
      codeURL: base + 'register-exercise.tlv'
    });
  }
</script>
