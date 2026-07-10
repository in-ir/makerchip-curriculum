# Module 2.2: Counters

**Block 2 — Sequential Logic**  
**Estimated time:** 60–90 minutes  
**Prerequisites:** Block 1 + Module 2.1

<div id="mc-counter-viz" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to build a free-running counter from scratch, add an enable signal to pause counting, make a counter wrap at any value you choose, and combine all three into a single controlled counter that you can reuse anywhere in Block 2.

## From register to counter

In Module 2.1 you saw this line:

```
$count[3:0] = *reset ? 4'b0 : >>1$count + 1;
```

That's already a counter. Every cycle it takes its own previous value and adds one. But as written it does exactly two things: reset to zero, or increment forever. Real counters need more control than that — you need to be able to pause them, restart them, and cap them at a specific value. That's all this module is: taking the register you already understand and adding those three controls.

## Enable: counting only when you want to

The simplest addition is an **enable** signal. When enable is high, count. When it's low, hold.

```
$count[3:0] = *reset  ? 4'b0      :
              $enable  ? >>1$count + 1 :
                         >>1$count;
```

Read the three lines out loud: if reset, go to zero. If enabled, add one. Otherwise, keep holding exactly what was there. That last case is the new part — `>>1$count` with no addition. The register just copies itself forward, frozen in place until enable goes high again.

Here's that counter live. The enable signal here is high for four cycles, then low for four, over and over. Watch `$count` climb while `$enable` is high, then sit perfectly flat on a plateau while it's low, then pick up again from exactly where it stopped:

<div id="mc-counter-demo" class="makerchip-embed-small"></div>

## Wrap: counting to a limit then starting over

A counter that grows forever isn't always what you want. A digital clock counts seconds 0 through 59, then has to snap back to 0 and tick the minutes. A game timer counts down and stops. To cap a counter, you add one more check: before incrementing, ask whether the counter has hit its limit. If it has, force it back to zero instead of adding one.

```
$count[3:0] = *reset         ? 4'b0 :
              >>1$count == 9  ? 4'b0 :
                                >>1$count + 1;
```

When `>>1$count` reaches 9, the next cycle snaps back to zero. Every other cycle counts normally. Notice you're checking `>>1$count`, not `$count` — you're always asking "what did I hold _last_ cycle?" and using that to decide what to become this cycle.

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 860 100" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="wa" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#7C4DFF" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>
  <!-- Count boxes 0-9 then wrap -->
  <!-- Boxes -->
  <rect x="10"  y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="56"  y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="102" y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="148" y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="194" y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="240" y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="286" y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="332" y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="378" y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="424" y="30" width="36" height="36" rx="4" fill="#7C4DFF" stroke="#7C4DFF" stroke-width="1"/>
  <!-- Values -->
  <text x="28"  y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">0</text>
  <text x="74"  y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">1</text>
  <text x="120" y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">2</text>
  <text x="166" y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">3</text>
  <text x="212" y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">4</text>
  <text x="258" y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">5</text>
  <text x="304" y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">6</text>
  <text x="350" y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">7</text>
  <text x="396" y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">8</text>
  <text x="442" y="54" fill="#ffffff" font-size="13" text-anchor="middle" font-weight="bold">9</text>
  <!-- Wrap arrow -->
  <path d="M460 48 L520 48 L520 14 L28 14 L28 30" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-dasharray="5 3" marker-end="url(#wa)"/>
  <text x="490" y="72" fill="#B39DDB" font-size="10" text-anchor="middle">wrap → 0</text>
  <!-- Next cycles -->
  <rect x="540" y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="586" y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <rect x="632" y="30" width="36" height="36" rx="4" fill="#1A0533" stroke="#7C4DFF" stroke-width="1"/>
  <text x="558" y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">0</text>
  <text x="604" y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">1</text>
  <text x="650" y="54" fill="#EDE7F6" font-size="13" text-anchor="middle">2</text>
  <text x="700" y="50" fill="#B39DDB" font-size="18" text-anchor="middle">...</text>
</svg>
</div>

Run this one and watch the wrap happen:

<div id="mc-counter-wrap" class="makerchip-embed-small"></div>

## Watch it break: the off-by-one wrap

This is the single most common counter bug, and it's worth seeing before you write your own. Say you want a counter that cycles through ten values, 0 through 9. It's tempting to write the wrap check as "reset when the count reaches 10":

```
$count[3:0] = *reset          ? 4'b0 :
              >>1$count == 10 ? 4'b0 :
                                >>1$count + 1;  ← counts 0 to 10, not 0 to 9
```

Run it and count the distinct values before it wraps:

<div id="mc-counter-offbyone" class="makerchip-embed-small"></div>

You'll see 0, 1, 2, all the way up to **10** before it snaps back — that's eleven values, not ten. The counter has to actually reach 10 for the `== 10` check to fire, which means 10 gets displayed for a full cycle first. If you want the values 0 through 9, you wrap when the previous value was 9. The rule of thumb: **to count N values, wrap when `>>1$count == N-1`.**

## Putting it all together

Enable and wrap aren't mutually exclusive — most real counters need both. Here's the full pattern, combining reset, enable, and wrap in one expression:

```
$count[3:0] = *reset          ? 4'b0 :
              >>1$count == MAX ? 4'b0 :
              $enable          ? >>1$count + 1 :
                                 >>1$count;
```

The priority order matters here: reset wins over everything, then the wrap check, then enable, then hold. Read it top to bottom and the logic tells its own story.

??? note "Why check >>1$count for the wrap, not $count?"

    You're checking what the counter held *last* cycle to decide what it becomes *this* cycle. If you wrote `$count == MAX`, you'd be asking "is this cycle's value equal to MAX?" — but this cycle's value is exactly what you're currently computing. That's the circular definition from Module 2.1 all over again. You always look back one cycle with `>>1` when making decisions based on your own state.

## Your turn: build a controlled counter

Complete `$count` below so it counts upward when `$enable` is high, holds when it's low, and wraps back to zero when it hits 12. Hints are in the editor comments.

<div id="mc-counter-exercise" class="makerchip-embed"></div>

## Where this fits next

You can now build a counter with full control: reset it, pause it, wrap it. In Module 2.3 you'll meet the **shift register**, which instead of adding one each cycle, moves bits sideways through a chain of flip-flops — the key ingredient for both animation and randomness in the Whack-a-Mole project.

## Quick reference

| Concept              | TL-Verilog                     | Description                        |
| -------------------- | ------------------------------ | ---------------------------------- |
| Free-running counter | `$c = *reset ? 0 : >>1$c + 1;` | Increments every cycle             |
| Enable               | `$enable ? >>1$c + 1 : >>1$c`  | Only counts when enable is high    |
| Wrap at N            | `>>1$c == N ? 0 : >>1$c + 1`   | Resets to 0 when limit is reached  |
| Full counter         | reset → wrap → enable → hold   | Priority order for chained ternary |

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

  if (document.getElementById('mc-counter-viz')) {
    VizOnlyIDE.create('mc-counter-viz', {
      codeURL: base + 'counter-viz.tlv'
    });
  }

  if (document.getElementById('mc-counter-demo')) {
    WaveformOnlyIDE.create('mc-counter-demo', {
      codeURL: base + 'counter-demo.tlv'
    });
  }

  if (document.getElementById('mc-counter-wrap')) {
    WaveformOnlyIDE.create('mc-counter-wrap', {
      codeURL: base + 'counter-wrap.tlv'
    });
  }

  if (document.getElementById('mc-counter-offbyone')) {
    WaveformOnlyIDE.create('mc-counter-offbyone', {
      codeURL: base + 'counter-offbyone.tlv'
    });
  }

  if (document.getElementById('mc-counter-exercise')) {
    EditorWaveformIDE.create('mc-counter-exercise', {
      codeURL: base + 'counter-exercise.tlv'
    });
  }
</script>
