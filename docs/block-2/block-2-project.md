# Project Lab: Whack-a-Mole

**Block 2 — Sequential Logic**  
**Estimated time:** 90–120 minutes  
**Prerequisites:** Modules 2.1 through 2.4

## What you're building

This is the capstone of Block 2: a complete Whack-a-Mole arcade machine that plays *itself*. You won't learn any new syntax here. Instead you'll assemble the four things you already know into a working system, and watch it come alive stage by stage.

A quick note on how it works: a Makerchip simulation runs on the clock with no live mouse, so instead of you clicking moles, the machine has a built-in "robot player" that reacts and whacks automatically. Think of it like a self-playing arcade demo, the kind that runs on the screen while no one's at the cabinet. Your job is to build the machine and then tune how it behaves. Every subsystem is fully visible, so you can watch exactly how the game thinks.

Here's the finished machine you're working toward. Moles pop from random holes, the robot player whacks them, the score climbs, and the rounds count down to game over.

<div id="mc-whack-final" class="makerchip-embed"></div>

The lab has four stages, one per Block 2 concept. Each stage gives you a starter with the previous stages already working, so you're always building on solid ground. Fill in the blanks marked `TODO`, run it, and check it against the checkpoint before moving on.

## The plan

You'll build the game in the same order the pieces fire during play:

1. **The mole picker** — an LFSR chooses a random hole *(Module 2.3)*
2. **The mole clock** — a timer controls how long the mole stays up *(Module 2.2)*
3. **Keeping score** — registers track score and rounds *(Module 2.1)*
4. **The game brain** — an FSM ties it all together *(Module 2.4)*

---

## Stage 1 — The mole picker

**Concept:** LFSR (Module 2.3)

A mole is no fun if it always pops from the same hole. You need randomness, and you already know how to make it: an LFSR. Here you'll complete a 4-bit LFSR and use three of its bits to pick which of the eight holes (0–7) the mole appears in.

There are two blanks: the feedback bit (the XOR of two taps) and the shift itself. Fill them in using exactly the pattern from Module 2.3.

<div id="mc-lab-stage1" class="makerchip-embed"></div>

**Checkpoint:** when you run it, a mole should appear in a hole and jump to a *different, unpredictable* hole every few cycles. If it never moves, or sits on hole 0 forever, your LFSR isn't shifting yet — check the feedback and the seed.

---

## Stage 2 — The mole clock

**Concept:** Counter / timer (Module 2.2)

Right now the mole teleports on a fixed schedule. A real game gives you a moment to react, then the mole ducks back down. That's a timer: a counter that starts at zero when a mole appears and counts up while it's showing. When it reaches the mole's time limit, the round ends and a new mole pops up.

The LFSR is done for you now. Your one blank is the timer itself — the reset / restart / count-up counter you built in Module 2.2.

<div id="mc-lab-stage2" class="makerchip-embed"></div>

**Checkpoint:** a mole should appear, the green bar should drain steadily, and when it empties a new mole should appear in a new hole. If the bar never moves, your timer isn't counting.

---

## Stage 3 — Keeping score

**Concept:** Registers (Module 2.1)

Now for the point of the game: tracking how well the player does. A "robot player" is wired up for you — it reacts after a varying delay (also pulled from the LFSR), so sometimes it whacks the mole in time (`$whacked`) and sometimes the mole escapes (`$escaped`). Your job is the two registers that record all this: the **score**, which climbs on a hit, and the **rounds** counter, which ticks down every time a mole is resolved.

Both are the exact "hold a value, update it conditionally" pattern from Module 2.1.

<div id="mc-lab-stage3" class="makerchip-embed"></div>

**Checkpoint:** watch HIT and MISS flash as moles resolve. SCORE should go up only on hits, and ROUNDS LEFT should count down from 10 on every mole. If score climbs on misses too, re-check which signal each register is watching.

---

## Stage 4 — The game brain

**Concept:** Finite State Machine (Module 2.4)

You have all the parts. The last piece is the conductor: a state machine that moves the game through its phases and decides when everything happens. It's the same shape as the traffic light from Module 2.4, with four states:

<div style="margin: 2rem 0;">
<svg width="100%" viewBox="0 0 720 200" xmlns="http://www.w3.org/2000/svg" style="font-family: 'JetBrains Mono', monospace;">
  <defs>
    <marker id="lab-arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
      <path d="M2 2L8 5L2 8" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
    </marker>
  </defs>
  <circle cx="90" cy="100" r="44" fill="#1A0533" stroke="#B39DDB" stroke-width="2"/>
  <text x="90" y="104" fill="#B39DDB" font-size="13" font-weight="bold" text-anchor="middle">IDLE</text>
  <circle cx="290" cy="100" r="44" fill="#0f2f1a" stroke="#22c55e" stroke-width="2.5"/>
  <text x="290" y="97" fill="#22c55e" font-size="11" font-weight="bold" text-anchor="middle">MOLE</text>
  <text x="290" y="112" fill="#22c55e" font-size="11" font-weight="bold" text-anchor="middle">UP</text>
  <circle cx="490" cy="100" r="44" fill="#2f2a0f" stroke="#eab308" stroke-width="2.5"/>
  <text x="490" y="104" fill="#eab308" font-size="12" font-weight="bold" text-anchor="middle">SCORE</text>
  <circle cx="650" cy="100" r="40" fill="#2f0f0f" stroke="#ef4444" stroke-width="2.5"/>
  <text x="650" y="97" fill="#ef4444" font-size="10" font-weight="bold" text-anchor="middle">GAME</text>
  <text x="650" y="111" fill="#ef4444" font-size="10" font-weight="bold" text-anchor="middle">OVER</text>
  <path d="M134 100 L242 100" fill="none" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#lab-arr)"/>
  <text x="188" y="90" fill="#4A3060" font-size="9" text-anchor="middle">start</text>
  <path d="M334 100 L442 100" fill="none" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#lab-arr)"/>
  <text x="388" y="90" fill="#4A3060" font-size="9" text-anchor="middle">hit or escape</text>
  <path d="M490 144 Q390 196 290 144" fill="none" stroke="#B39DDB" stroke-width="1.5" stroke-dasharray="4 3" marker-end="url(#lab-arr)"/>
  <text x="390" y="188" fill="#4A3060" font-size="9" text-anchor="middle">more rounds → next mole</text>
  <path d="M534 100 L606 100" fill="none" stroke="#B39DDB" stroke-width="1.5" marker-end="url(#lab-arr)"/>
  <text x="570" y="90" fill="#4A3060" font-size="9" text-anchor="middle">last round</text>
</svg>
</div>

Your final blank is `$state`. Each line of it is one arrow in that diagram. Fill it in and the whole game runs.

<div id="mc-lab-stage4" class="makerchip-embed"></div>

**Checkpoint:** the state banner should cycle READY → MOLE UP! → SCORING and back, moles should only show during MOLE UP!, and after 10 rounds it should land on GAME OVER and stop. If it freezes on one state, check that every branch of `$state` eventually leads somewhere.

---

## You built a computer (almost)

Step back and look at what you just made: a system that remembers state, makes decisions, keeps score, generates randomness, and runs a complete game loop — all from registers, counters, shift registers, and a state machine. Nothing else. Every one of those pieces scales up into the guts of a real processor, which is exactly where Block 3 picks up.

## Make it your own

Building the machine is the lab. *Tuning* it is where it gets fun. Since the robot plays automatically, your gameplay is tweaking the logic and watching how the robot's score changes. Try these:

1. **Change the difficulty.** Find `MOLE_TIME` (currently 6) and make it smaller. Moles duck down faster, so the robot misses more and the score drops. Make it bigger and the robot hits nearly everything. Can you find the value where the robot scores about half?
2. **More rounds.** Bump `NUM_ROUNDS` up from 10 for a longer game. (Watch the bit widths, a bigger number may need more than 4 bits.)
3. **A sharper robot.** The reaction delay comes from the LFSR. Narrow its range so the robot reacts more consistently and rarely misses, or widen it to make it streaky and unpredictable.
4. **A speed ramp.** Make `MOLE_TIME` shrink as the rounds count down, so the game speeds up the longer it runs, the classic arcade difficulty curve. This is the hardest tweak and the most satisfying: it's one extra piece of logic on the timer limit.

Each of these is a small change to logic you now fully understand. That's the real reward of building it yourself: you can reach into any part of the machine and change how it behaves.

<style>
.makerchip-embed       { position: relative; width: 100%; height: 540px; }
.makerchip-embed-small { position: relative; width: 100%; height: 333px; }
</style>

<script type="module">
  import IdePlugin from 'https://beta.makerchip.com/dist/makerchip-plugin.js';

  const base = 'https://raw.githubusercontent.com/in-ir/makerchip-curriculum/main/code/block-2/';

  class VizOnlyIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({ panes: ['Viz'], activePane: 'Viz' });
      await this.compile();
    }
  }

  class EditorVizIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({
        sides: {
          left:  { panes: ['Editor'], activePane: 'Editor' },
          right: { panes: ['Viz'],    activePane: 'Viz' }
        },
        splitAt: 0.5
      });
      await this.compile();
    }
  }

  if (document.getElementById('mc-whack-final')) {
    VizOnlyIDE.create('mc-whack-final', { codeURL: base + 'whack-a-mole.tlv' });
  }
  if (document.getElementById('mc-lab-stage1')) {
    EditorVizIDE.create('mc-lab-stage1', { codeURL: base + 'lab-stage1-lfsr.tlv' });
  }
  if (document.getElementById('mc-lab-stage2')) {
    EditorVizIDE.create('mc-lab-stage2', { codeURL: base + 'lab-stage2-timer.tlv' });
  }
  if (document.getElementById('mc-lab-stage3')) {
    EditorVizIDE.create('mc-lab-stage3', { codeURL: base + 'lab-stage3-score.tlv' });
  }
  if (document.getElementById('mc-lab-stage4')) {
    EditorVizIDE.create('mc-lab-stage4', { codeURL: base + 'lab-stage4-fsm.tlv' });
  }
</script>
