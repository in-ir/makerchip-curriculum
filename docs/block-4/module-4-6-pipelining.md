# Module 4.6: Pipelining

**Block 4 — Building a Processor**  
**Estimated time:** 70–85 minutes  
**Prerequisites:** Module 4.5 — Branches and Memory

<div id="mc-pipeline-viz" class="makerchip-embed-small"></div>

## What you'll learn

This is the module where you meet the feature TL-Verilog was invented for. You will learn what a **pipeline** is and why every fast processor is one, write pipeline stages with the `@` notation, and understand the single most important idea in TL-Verilog: that *when* a computation happens can be separated from *what* it computes. By the end you will see why this language exists, and why your mentor and the RISC-V community build processors in it.

## Your CPU works. It is also slow.

The processor you finished in Module 4.5 is correct. Every cycle it fetches an instruction, decodes it, reads registers, runs the ALU, and writes back, all before the next cycle begins.

That is a lot to do in one cycle, and it is the problem. The clock can only tick as fast as the *slowest* path through all of that work. Your fetch logic, decode logic, and ALU are wired in a long chain, and the cycle has to be long enough for a signal to travel the whole chain. Meanwhile, the fetch hardware finishes its job early and then sits idle for the rest of the cycle, waiting, while the ALU is still working.

Real processors refuse to waste that time. The trick is called **pipelining**, and it is exactly like an assembly line.

## The assembly line

Imagine building cars. You could have one worker build an entire car start to finish, then start the next. Or you could line up stations: one attaches wheels, the next installs the engine, the next paints. A car moves from station to station, and crucially, **while station two works on car A, station one is already starting car B.**

At any moment every station is busy. You do not finish cars any faster individually, each still passes through every station, but you *complete* one far more often, because the line never idles.

A pipelined processor does exactly this with instructions:

- **Stage 1 (fetch)** gets an instruction from memory
- **Stage 2 (decode)** works out what it means and reads registers
- **Stage 3 (execute)** runs the ALU and writes back

While instruction A is in execute, instruction B is in decode, and instruction C is being fetched. Three instructions in flight at once, each in a different stage. The VIZ at the top of this page shows this: watch the instructions march diagonally down through the stages, and notice that at any single cycle, all three stages are working.

## The problem pipelining creates for normal HDLs

Here is where it gets hard, and why TL-Verilog exists.

To pipeline a design in ordinary Verilog, you have to manually insert a flip-flop everywhere a signal crosses from one stage to the next, and rename the signal at each stage so you can tell the copies apart. A value used three stages later needs to be explicitly carried through all three, flip-flop by flip-flop, name by name. Miss one and the design breaks in a way that is genuinely hard to find, because the *logic* is right and only the *timing* is wrong.

Worse, if you later decide to move a computation one stage earlier or later, to balance the work, you have to rip out and rewire all of those flip-flops by hand. Retiming a Verilog pipeline is dangerous, tedious surgery. This is a real source of bugs in real chips.

## The TL-Verilog answer

TL-Verilog makes the pipeline a first-class part of the language. You name a pipeline with `|name`, mark stages with `@`, and write each computation in the stage where it belongs:

```
|calc
   @1
      $step1[7:0] = $in + 8'd10;
   @2
      $step2[7:0] = $step1 << 1;
   @3
      $step3[7:0] = $step2 - 8'd5;
```

Look at stage 2. It uses `$step1` from stage 1 directly, by name, with no flip-flop written anywhere. In the `@` notation, TL-Verilog inserts the flip-flops for you wherever a signal crosses a stage boundary.

You have actually been doing the same thing by hand all block, with `>>1`. A pipeline stage is nothing more than a computation whose inputs are delayed by a cycle, and `>>1` is exactly that delay. The two forms below describe the identical hardware:

```
// idiomatic pipeline form            // the explicit form you already know
|calc                                 $step1[7:0] = $in + 8'd10;
   @1                                  $step2[7:0] = >>1$step1 << 1;
      $step1 = $in + 8'd10;            $step3[7:0] = >>1$step2 - 8'd5;
   @2
      $step2 = $step1 << 1;
   @3
      $step3 = $step2 - 8'd5;
```

On the left, the stage boundaries imply the delays. On the right, you write each delay explicitly with `>>1`, the same operator you used for every register since Block 2. The `@` form is what you will see in real TL-Verilog processors like WARP-V and the RISC-V MYTH core, because at the scale of a full CPU the automatic staging saves enormous effort. The explicit form makes the flip-flops visible, which is why the runnable examples in this module use it: you can see the one-cycle delay at every stage in the waveform, rather than having to trust that it is there.

<div id="mc-pipeline-demo" class="makerchip-embed-small"></div>

Run it. A value enters as `$in` and moves through the three stages, each reading the previous stage's result from the cycle before with `>>1`. In the waveform, watch a single value ripple through `$step1`, `$step2`, `$step3` on successive cycles: that one-cycle shift at each stage is the pipeline flip-flop, made visible.

Now here is the part that matters, in the words of the person who designed the language: **staging is a physical attribute with no impact on behavior.** Move a line from `@2` to `@1` and the *what* is unchanged, only the *when* shifts. You can retime the pipeline, balance the stages, make the clock faster, all by moving lines between `@` sections, and the logic cannot break because you never touched the logic. That safety is the entire point. It is what the research paper behind TL-Verilog calls *timing-abstract* design, and it is genuinely one of the most elegant ideas in modern hardware description.

## Pipelining the processor

Your CPU maps naturally onto three stages, because you built it in three conceptual pieces already:

```
@1  fetch:   PC and instruction memory
@2  decode:  fields, control signals, register reads
@3  execute: ALU, writeback
```

Every signal you have written this block belongs to one of these three stages, in the module it came from: the fetch logic from 4.1 in stage 1, the decode from 4.3 in stage 2, the datapath from 4.4 in stage 3. To pipeline the processor, each value that crosses a stage boundary gets a one-cycle delay, a `>>1` in the explicit form, or an automatic flip-flop in the `@` form. The logic itself does not change at all. You are only deciding *when* each part runs.

That is the reveal of this whole block: you did not have to rewrite your processor to pipeline it. The same logic, staged, is a pipelined CPU.

## Watch it break: the branch that arrives too late

Pipelining is not free, and honesty requires showing the catch.

Think about a branch. It is resolved in the execute stage, `@3`, because that is where the comparison happens. But by the time the branch computes whether to jump, the processor has *already fetched the next two instructions* in stages 1 and 2, before it knew the branch was taken. Those two instructions are in the pipeline, and they are the wrong ones.

This is called a **control hazard**, and it is the fundamental tension of pipelining: the speed comes from starting instructions before the previous ones finish, but sometimes an earlier instruction changes which instruction *should* come next. In the RISC-V MYTH workshop your mentor teaches, the pipelined core deliberately keeps a three-cycle delay on branches for exactly this reason: the branch target is not ready until execute, so the two instructions behind it have to be discarded or accounted for.

The same happens with loads: the value arrives from memory a cycle late, so the instruction right behind a load cannot use its result yet. That is the **load-use hazard** the note in Module 4.5 mentioned.

Real pipelines solve these with forwarding, stalls, and branch prediction, which are a course in themselves. The point for you is to understand the trade honestly: **a pipeline goes faster by overlapping instructions, and the price is that overlap sometimes fights the program's own control flow.** Recognising a hazard when you see one in a waveform, an instruction executing that should have been skipped, is a real and valuable skill.

## Your turn: build a pipeline

Take three transformations and stage them. The arithmetic is trivial on purpose: the whole exercise is about carrying each stage's result forward by one cycle, which is what turns a chain of expressions into a pipeline.

<div id="mc-pipeline-exercise" class="makerchip-embed"></div>

??? tip "Hint"

    Stage 1 is done for you. For each later stage, read the *previous* stage's
    result from last cycle with `>>1`. Stage 2 doubles `>>1$s1` with a left
    shift; stage 3 subtracts 2 from `>>1$s2`. The `>>1` is the point: it is the
    flip-flop that carries the value from one stage into the next, exactly what
    the `@` notation inserts automatically.

??? success "Solution"

    ```
    $s2[7:0] = >>1$s1 << 1;
    $s3[7:0] = >>1$s2 - 8'd2;
    ```

    In the waveform, watch a value enter as `$in` and emerge at `$s3` two cycles
    later, delayed one cycle at each stage. In the idiomatic `@` form this same
    design would place `$s1`, `$s2` and `$s3` in stages `@1`, `@2` and `@3`, and
    the delays you wrote with `>>1` would be inserted for you. Same hardware,
    written two ways.

## What you have built

Step back and look at the whole block. You started with a program counter and finished with a pipelined RISC-V processor. Along the way you built, or rather assembled from parts you already had, a fetch stage, an instruction decoder, a register file, an ALU, branch logic, and a memory interface, and then wrapped the whole thing in a pipeline using the feature that makes TL-Verilog worth learning.

That is a genuine accomplishment. A pipelined CPU is the canonical hard project in a computer architecture course, and you built one from gates up, understanding every piece, because you built every piece yourself across four blocks.

## Check yourself

Try these from memory.

??? question "In one sentence, why is a pipelined processor faster?"

    Because it overlaps instructions, while one instruction executes, the next
    is being decoded and a third fetched, so every stage of the hardware stays
    busy every cycle instead of sitting idle.

??? question "What does it mean that staging is *timing-abstract*?"

    That moving a line from one `@` stage to another changes *when* it runs but
    not *what* it computes. You can retime the pipeline without breaking the
    logic, because you never touched the logic.

??? question "What is a control hazard?"

    A branch is resolved late in the pipeline, after the next instructions have
    already been fetched. If the branch is taken, those fetched instructions are
    the wrong ones. That conflict between overlapping instructions and the
    program's own control flow is a control hazard.

## Where this fits next

There is nothing left to teach. What remains is to *do it*: the project assembles the complete processor and runs a real program on it, the sum from 1 to 10, and watches the answer appear.

After that, the curriculum opens up. The Pac-Man challenge is waiting, unguided this time, and everything you would need to build it, state machines, memory, grids, collision, hierarchy for multiple ghosts, you now have. You are no longer following a lab. You are a hardware designer with a toolbox.

## Quick reference

| Concept | TL-Verilog | Description |
| --- | --- | --- |
| Pipeline | `\|name` | Names a pipeline |
| Stage | `@1`, `@2`, `@3` | Marks which stage logic runs in |
| Cross-stage signal | `>>1$sig`, or `$sig` in a later `@` stage | A one-cycle delay carries it forward |
| Timing-abstract | staging has no behavioural effect | Retime safely by moving lines |
| Control hazard | branch resolves late | The price of overlapping instructions |

<style>
.makerchip-embed       { position: relative; width: 100%; height: 500px; }
.makerchip-embed-small { position: relative; width: 100%; height: 400px; }
</style>

<script type="module">
  import IdePlugin from 'https://beta.makerchip.com/dist/makerchip-plugin.js';

  const base = 'https://raw.githubusercontent.com/in-ir/makerchip-curriculum/main/code/block-4/';

  class VizOnlyIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({ panes: ['Viz'], activePane: 'Viz' });
      await this.compile();
    }
  }

  class WaveformOnlyIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({ panes: ['Waveform'], activePane: 'Waveform' });
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

  if (document.getElementById('mc-pipeline-viz')) {
    VizOnlyIDE.create('mc-pipeline-viz', { codeURL: base + 'pipeline-viz.tlv' });
  }
  if (document.getElementById('mc-pipeline-demo')) {
    WaveformOnlyIDE.create('mc-pipeline-demo', { codeURL: base + 'pipeline-demo.tlv' });
  }
  if (document.getElementById('mc-pipeline-exercise')) {
    EditorWaveformIDE.create('mc-pipeline-exercise', { codeURL: base + 'pipeline-exercise.tlv' });
  }
</script>
