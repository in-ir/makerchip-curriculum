# Module 2.3: Shift Registers

**Block 2 — Sequential Logic**  
**Estimated time:** 60–90 minutes  
**Prerequisites:** Module 2.2

<div id="mc-shift-teaser" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to build a shift register that moves bits sideways through a chain of flip-flops, understand what the concatenation `{}` syntax does, and combine a shift register with a single XOR gate to build an LFSR — a circuit that generates numbers that look completely random using nothing but pure logic. That LFSR is exactly what the Whack-a-Mole project uses to pick which hole a mole pops out of.

## A different kind of register

A counter takes its previous value and does arithmetic on it: add one. A shift register does something simpler and, it turns out, far more useful in disguise. It takes its previous value and slides every bit over by one position.

Picture four flip-flops in a row, each holding one bit. On every clock edge, each flip-flop hands its value to its neighbor. The bit in position 3 moves to position 2, position 2 moves to position 1, and so on. A brand-new bit enters at one end, and the bit at the far end falls off and disappears. It's a conveyor belt for bits.

<div id="mc-shift-demo" class="makerchip-embed-small"></div>

Watch the single `1` above march through the register one position per cycle. Nothing is being computed — the bits are just being passed along the chain.

## The concatenation syntax

To describe "slide everything over and bring in a new bit," TL-Verilog gives you the concatenation operator: curly braces `{}`. It glues signals together into one wider value.

```
$sr[3:0] = *reset ? 4'b0 : {$shift_in, >>1$sr[3:1]};
```

Read the right-hand side carefully. `>>1$sr[3:1]` takes the _top three bits_ of last cycle's register — positions 3, 2, and 1. `$shift_in` is the new bit coming in. The braces stack them: the new bit goes on top, the old top-three slide down into positions 2, 1, and 0. The bit that used to be in position 0 isn't mentioned anywhere, so it simply falls off the end.

That single line is the whole shift register. No arithmetic, just rearranging which bit sits where.

??? note "Which direction is this shifting?"

    This example shifts toward the *lower* bit positions (3→2→1→0), with new bits entering at the top. You could just as easily shift the other way by writing `{>>1$sr[2:0], $shift_in}` instead, sliding bits up and bringing new ones in at the bottom. Neither is more correct — it depends on which end you want your data to enter.

## The trick: feed the output back to the input

Here's where shift registers get interesting. What if, instead of feeding in new bits from outside, you take a bit from the register itself and feed it back into the input? Now the register's contents cycle around endlessly, a closed loop.

That alone just makes the same pattern rotate forever, which isn't very useful. But now add one small twist: instead of feeding back a single bit directly, feed back the **XOR of two bits**. This tiny change transforms a boring rotation into something remarkable.

## The LFSR: randomness from a single XOR gate

A **Linear Feedback Shift Register**, or LFSR, is a shift register whose input bit is the XOR of a couple of its own bits. That's the entire idea. You take two specific bits (called "taps"), XOR them together, and shift the result back in.

```
$fb = >>1$lfsr[3] ^ >>1$lfsr[2];
$lfsr[3:0] = *reset ? 4'b0001 : {>>1$lfsr[2:0], $fb};
```

The first line computes the feedback bit: bit 3 XORed with bit 2 of the previous value. The second line is just the shift register you already know, with `$fb` as the new bit coming in.

Watch what this produces:

<div id="mc-lfsr-demo" class="makerchip-embed-small"></div>

Look at the sequence of values: 1, 2, 4, 9, 3, 6, 13, 10, 5... It jumps around with no obvious pattern. It hits every number from 1 to 15 exactly once before it repeats, in a scrambled order that _looks_ random even though it is completely deterministic. Reset it and you get the exact same sequence every time. There is no randomness hardware anywhere in here — just a shift register and one XOR gate.

This is why LFSRs are everywhere: they're the cheapest possible way to generate numbers that behave randomly enough for games, tests, and simple simulations. In the Whack-a-Mole project, you'll read a few bits off an LFSR each round to decide which of the eight holes the mole appears in. The player can't predict it, but your circuit is doing nothing more mysterious than shifting and XORing.

??? note "Why does it never produce zero, and why 0001 as the seed?"

    If an LFSR ever reached all-zeros, the XOR of two zero bits is zero, so it would shift in zeros forever and get stuck. All-zeros is a dead state. That's why you seed it with a non-zero value like `0001` — and why a well-chosen 4-bit LFSR cycles through exactly 15 values (every number except zero) before repeating.

## Your turn: build the LFSR

Complete the LFSR below so it produces the pseudo-random sequence. You need to fill in the feedback tap and the shift. Read the comments in the editor for the exact expressions.

<div id="mc-lfsr-exercise" class="makerchip-embed"></div>

## Where this fits next

You now have all three sequential building blocks: registers that hold, counters that increment, and shift registers that slide — including the LFSR that manufactures randomness from a single gate. In Module 2.4 you'll learn the **finite state machine**, the tool that ties everything together by letting a circuit behave differently depending on which "mode" it's in. That's the last piece before the Whack-a-Mole project.

## Quick reference

| Concept            | TL-Verilog                     | Description                              |
| ------------------ | ------------------------------ | ---------------------------------------- |
| Concatenation      | `{$a, $b}`                     | Glues signals into one wider value       |
| Shift toward bit 0 | `{$new, >>1$sr[3:1]}`          | New bit enters top, bottom bit falls off |
| Shift toward bit 3 | `{>>1$sr[2:0], $new}`          | New bit enters bottom, top bit falls off |
| LFSR feedback      | `$fb = >>1$sr[3] ^ >>1$sr[2];` | XOR of two taps                          |
| LFSR               | `{>>1$sr[2:0], $fb}`           | Shift register with XOR feedback         |

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

  if (document.getElementById('mc-shift-teaser')) {
    VizOnlyIDE.create('mc-shift-teaser', {
      codeURL: base + 'lfsr-viz.tlv'
    });
  }

  if (document.getElementById('mc-shift-demo')) {
    VizOnlyIDE.create('mc-shift-demo', {
      codeURL: base + 'shift-viz.tlv'
    });
  }

  if (document.getElementById('mc-lfsr-demo')) {
    WaveformOnlyIDE.create('mc-lfsr-demo', {
      codeURL: base + 'lfsr-demo.tlv'
    });
  }

  if (document.getElementById('mc-lfsr-exercise')) {
    EditorWaveformIDE.create('mc-lfsr-exercise', {
      codeURL: base + 'lfsr-exercise.tlv'
    });
  }
</script>
