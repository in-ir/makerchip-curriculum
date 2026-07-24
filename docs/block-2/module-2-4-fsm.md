# Module 2.4: Finite State Machines

**Block 2 — Sequential Logic**  
**Estimated time:** 45–60 minutes  
**Prerequisites:** Module 2.3 — Shift Registers

<div id="mc-traffic-teaser" class="makerchip-embed-small"></div>

## What you'll learn

By the end of this module you will be able to explain what a state is and why circuits need them, build a finite state machine from a state register and next-state logic, draw and read a state diagram, and understand the exact pattern that drives the Whack-a-Mole game in the Block 2 project.

## What is a "state"?

Everything you've built so far reacts the same way every cycle. A counter always adds one. An adder always adds. But think about a traffic light. When it's green, the next thing it does is turn yellow. When it's yellow, the next thing is red. The light's behavior depends entirely on *which color it currently is* — the same passage of time produces a different result depending on the situation the light is in.

That "situation the circuit is currently in" is called a **state**. A circuit that has a handful of named states, and rules for moving between them, is a **finite state machine**, or FSM. It's the tool you reach for whenever a circuit needs to behave differently at different times, follow a sequence of steps, or remember "where it is" in a process.

You already have everything you need to build one. A state is just a value held in a register. Moving between states is just deciding the register's next value based on its current value — exactly the `>>1` pattern from Module 2.1.

## The anatomy of an FSM

Every FSM has the same two parts:

1. A **state register** that holds which state you're currently in.
2. **Next-state logic** that looks at the current state (and maybe some inputs) and decides which state to move to next.

Here's the simplest possible FSM: two states, IDLE and ACTIVE, that flip back and forth every time a `$go` signal fires.

```
$state = *reset ? 1'b0 :
         $go     ? ! >>1$state :
                   >>1$state;
```

Read it as: on reset, go to IDLE (0). If `$go` is high, flip to the other state. Otherwise, hold. That's a complete, working state machine — the state register and the next-state logic are both right there in one expression.

<div id="mc-fsm-demo" class="makerchip-embed-small"></div>

## State diagrams

FSMs are almost always drawn as a picture before they're written as code, because the picture makes the behavior obvious at a glance. Circles are states, arrows are transitions, and labels on the arrows say what triggers each move.

Here's the traffic light as a state diagram:

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 700 200" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="fsmarr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>

  <!-- GREEN state -->
  <circle cx="110" cy="100" r="48" fill="#0f2f1a" stroke="#22c55e" stroke-width="2.5"/>
  <text x="110" y="96" fill="#22c55e" font-size="15" font-weight="bold" text-anchor="middle">GREEN</text>
  <text x="110" y="116" fill="#4A3060" font-size="11" text-anchor="middle">4 cycles</text>

  <!-- YELLOW state -->
  <circle cx="350" cy="100" r="48" fill="#2f2a0f" stroke="#eab308" stroke-width="2.5"/>
  <text x="350" y="96" fill="#eab308" font-size="14" font-weight="bold" text-anchor="middle">YELLOW</text>
  <text x="350" y="116" fill="#4A3060" font-size="11" text-anchor="middle">2 cycles</text>

  <!-- RED state -->
  <circle cx="590" cy="100" r="48" fill="#2f0f0f" stroke="#ef4444" stroke-width="2.5"/>
  <text x="590" y="96" fill="#ef4444" font-size="15" font-weight="bold" text-anchor="middle">RED</text>
  <text x="590" y="116" fill="#4A3060" font-size="11" text-anchor="middle">4 cycles</text>

  <!-- GREEN -> YELLOW -->
  <path d="M158 100 L302 100" fill="none" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#fsmarr)"/>
  <text x="230" y="88" fill="#B39DDB" font-size="10" text-anchor="middle">timer expires</text>

  <!-- YELLOW -> RED -->
  <path d="M398 100 L542 100" fill="none" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#fsmarr)"/>
  <text x="470" y="88" fill="#B39DDB" font-size="10" text-anchor="middle">timer expires</text>

  <!-- RED -> GREEN (curved arc back) -->
  <path d="M577 148 Q350 250 123 148" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-dasharray="5 3" marker-end="url(#fsmarr)"/>
  <text x="350" y="192" fill="#B39DDB" font-size="10" text-anchor="middle">timer expires → back to GREEN</text>
</svg>
</div>

Three states, three transitions, each triggered by the same event: a timer running out. This is the entire logic of a traffic light, and the diagram shows it more clearly than any paragraph could.

## Building the traffic light

Turning that diagram into code needs two pieces working together: a timer (a counter, from Module 2.2) that measures how long you've been in a state, and the next-state logic that advances when the timer expires.

```
$expired = >>1$timer == $duration;

$state[1:0] = *reset     ? 2'd0 :
              ! $expired ? >>1$state :
              (>>1$state == 2'd0) ? 2'd1 :   // GREEN  -> YELLOW
              (>>1$state == 2'd1) ? 2'd2 :   // YELLOW -> RED
                                    2'd0;     // RED    -> GREEN
```

Follow the priority from top to bottom: reset wins first. If the timer hasn't expired, hold the current state (this is the "stay put" case that makes each light last several cycles). Once it expires, the three transition rules pick the next state based on where you are now. Every arrow in the diagram maps to exactly one line here.

<div id="mc-traffic-demo" class="makerchip-embed-small"></div>

Watch the state cycle green → yellow → red → green in the waveform, holding each one for its full duration before advancing.

??? note "Why does the first green last one extra cycle?"

    If you look closely, the very first GREEN runs slightly longer than the later ones. That's a real and normal effect of reset: for one cycle after reset releases, the timer is still catching up before it starts incrementing. Every state after that lasts exactly its set duration. This is honest hardware behavior, not a bug — reset genuinely costs you a cycle.

## Your turn: complete the FSM

The timer is written for you below. Complete the next-state logic so the light cycles green → yellow → red → green, holding each state until the timer expires. The editor comments give you the exact pattern.

<div id="mc-fsm-exercise" class="makerchip-embed"></div>

## How this powers Whack-a-Mole

The traffic light and the game are the same machine wearing different clothes. In the project, the states won't be colors — they'll be phases of a round: waiting for the game to start, a mole popping up, checking whether you hit it, updating the score, and moving on. The transitions won't be a traffic timer — they'll be the mole's time running out, or you whacking the right hole. But the shape is identical: a state register, next-state logic, and a timer deciding when to move on. Once you can build a traffic light, you can build the game.

## Where this fits next

You now have the complete Block 2 toolkit: registers that hold, counters that time, shift registers and LFSRs that shift and randomize, and finite state machines that tie it all together into structured behavior. The **Whack-a-Mole project** is next, and it uses every single one of these pieces at once.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| State register | `$state = *reset ? START : ...` | Holds the current state |
| Hold state | `! $trigger ? >>1$state : ...` | Stay put until something happens |
| Transition | `(>>1$state == A) ? B : ...` | Move from one state to the next |
| Timed FSM | timer + `$expired` + next-state | A counter drives the transitions |

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

  if (document.getElementById('mc-traffic-teaser')) {
    VizOnlyIDE.create('mc-traffic-teaser', {
      codeURL: base + 'traffic-viz.tlv'
    });
  }

  if (document.getElementById('mc-fsm-demo')) {
    WaveformOnlyIDE.create('mc-fsm-demo', {
      codeURL: base + 'fsm-demo.tlv'
    });
  }

  if (document.getElementById('mc-traffic-demo')) {
    WaveformOnlyIDE.create('mc-traffic-demo', {
      codeURL: base + 'traffic-demo.tlv'
    });
  }

  if (document.getElementById('mc-fsm-exercise')) {
    EditorWaveformIDE.create('mc-fsm-exercise', {
      codeURL: base + 'fsm-exercise.tlv'
    });
  }
</script>
