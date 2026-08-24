# Digital Design with Makerchip & TL-Verilog

Welcome. This curriculum teaches digital design from the ground up using **TL-Verilog** and the **Makerchip** browser-based IDE.

No installation required. No prior hardware experience needed. Just a laptop and a browser.

---

## Meet your instructor

<div class="instructor-widget">
  <div class="instructor-bubble">Ready to build some computers?</div>
  <div class="instructor-stage">
    <img src="assets/images/instructor.png" alt="Ines waving hello next to her Siamese cat">
  </div>
</div>

Hey, I'm Ines. I'm a computer science and math student who got completely obsessed with computer architecture and decided to build a course about it.

My love for the field started with a professor who completely changed the way I see computing. Something clicked in that class that had never clicked before: the idea that everything running on a device, every app, every game, every message sent, comes down to ones and zeros moving through circuits that someone designed. I remember thinking I want to be someone who builds those things. And more than that, I want other people to see it the way I do.

So when I got the chance to build this curriculum through Google Summer of Code, I took it without hesitating.

I came into this project having never touched TL-Verilog. I learned Makerchip the same way you are about to: by figuring things out, getting confused, and eventually getting it to click. When I built my first 8-bit RISC CPU, the hardest part was never the logic. It was the gap between what I was drawing on paper and what was actually happening inside the circuit. Waveforms are just colored lines until you have a mental model of what "correct" looks like. That gap is where a lot of students lose confidence and walk away from hardware. I almost did too.

Every module here is my attempt to close that gap, to give you the mental model before the confusion sets in.

If something is unclear, it is a bug, not a you problem. Open a discussion on the [course repo](https://github.com/in-ir/makerchip-curriculum/discussions) and I'll get back to you.

Now let's build something.

---

## What you'll build

Every block ends with a real, working game you build yourself, not a toy exercise. In the two blocks available now, you'll design and simulate:

- A **pixel art generator** drawn entirely with combinational logic
- A **Whack-a-Mole arcade machine** driven by registers, timers, and a state machine

And this is just the foundation. **Tetris** and a working **RISC-V processor** are on the way as the course grows. See [What's Next](whats-next.md) for where this is headed.

---

## How it works

Each module combines:

- **Concept explanations** with circuit diagrams
- **TL-Verilog code** you run directly in Makerchip, embedded right in the page
- **Hands-on exercises** with starter code, hints, and worked solutions
- **"Watch it break" demos** that show you real bugs so you learn to recognize them

---

## Curriculum structure

| Block | Topic                | Project      | Status         |
| ----- | -------------------- | ------------ | -------------- |
| 1     | Combinational Logic  | Pixel Art    | Available now  |
| 2     | Sequential Logic     | Whack-a-Mole | Available now  |
| 3     | Memory and Arrays    | Tetris       | Coming soon    |
| 4     | Building a Processor | RISC-V CPU   | In development |

New to digital logic? Start at Block 1 and work straight through Blocks 1 and 2. Already comfortable with gates and flip-flops and just want to learn the tooling? [Get Started](get-started.md) covers Makerchip and TL-Verilog on its own.

---

[Start here → Module 1.1: Logic Gates](block-1/module-1-1-logic-gates.md){ .md-button .md-button--primary }
