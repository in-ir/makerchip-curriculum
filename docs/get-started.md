# Get Started with Makerchip

If you are new to digital logic, start with Block 1. You will learn Makerchip naturally as you work through the material. If you already have a solid foundation in digital logic and just want to get up to speed with Makerchip and TL-Verilog, this page is the right starting point. Read through it, play with the sandbox, and then jump to whichever block interests you.

## What is Makerchip?

Makerchip is a browser-based IDE for designing and simulating digital circuits. You write TL-Verilog, an extension to Verilog that adds a much cleaner way to describe timing and state, and Makerchip compiles it instantly, generates a circuit diagram, and runs a simulation you can inspect in the waveform viewer. There is nothing to install and no toolchain to configure. You open a browser and start designing chips.

## The interface

The Makerchip IDE is organized into five panes. You do not need all of them at once, and throughout this curriculum each exercise only shows the panes that are relevant to what you are doing.

The **Editor** is where you write your TL-Verilog code. Every time you compile, Makerchip rebuilds the circuit from scratch and updates the other panes.

The **Diagram** is an auto-generated schematic of your circuit. Every signal you assign becomes a node in the graph. As your designs grow, the diagram grows with them and becomes one of the most useful debugging tools you have.

The **Waveform** shows signal values over simulation time. Each row is a signal and each column is a clock cycle. Reading waveforms is the primary way hardware engineers verify that a circuit does what it is supposed to do.

**Nav-TLV** gives you a structured, navigable view of your code. It becomes particularly useful once your designs span multiple modules and pipelines.

**Viz** is Makerchip's visualizer, and it is the pane that makes this curriculum work the way it does. The waveform shows a signal as a row of numbers. Viz lets a design *draw itself*: a counter can render as a progress bar, a shift register as a scrolling marquee, a grid of bits as an actual game board. From Block 2 onward most projects here ship with a Viz view, and in the later blocks it becomes your primary debugging tool, because a bug like "my piece is one column too far left" is invisible in a row of binary and obvious the instant you see it drawn.

A design only gets a Viz pane if its code includes a visualization block, which is why the simple example below does not have one. You will meet your first in Block 2.

The embed below shows the Editor, Nav-TLV, Diagram and Waveform together. Use the `«` arrows to collapse any pane you do not need.

<div id="mc-intro" class="makerchip-embed"></div>

## TL-Verilog in five minutes

If you already know Verilog, TL-Verilog will feel immediately familiar but noticeably cleaner. If you come from VHDL or another HDL, the concepts transfer directly and the syntax is more concise than anything you are used to.

### Signals

Every signal starts with `$`. You assign it directly with `=`, with no wire declarations and no always blocks:

```tlv
$x = $a && $b;
```

That is a complete combinational assignment. The compiler infers everything else.

### Bit widths

Square brackets after the signal name declare the width:

```tlv
$out[7:0] = $a[7:0] + $b[7:0];
```

This assigns an 8-bit signal the sum of two other 8-bit signals. TL-Verilog synthesizes the full carry chain automatically.

### Writing constants

When you write a fixed value, you state how many bits it has and which base it is in:

```tlv
$mask[7:0] = 8'b00000111;   // 8 bits, binary
$limit[3:0] = 4'd9;         // 4 bits, decimal, the number 9
$flag = 1'b0;               // a single bit, zero
```

The format is *width* `'` *base* *value*, where the base is `b` for binary, `d` for decimal, or `h` for hexadecimal. Being explicit about width matters in hardware: `4'd9` and `8'd9` are the same number but different amounts of wire. You will see this notation constantly from Block 1 onward, so it is worth getting comfortable with early.

### Logic operators

| Operation   | Operator | Notes                                    |
| ----------- | -------- | ---------------------------------------- |
| Boolean AND | `&&`     | Single-bit only                          |
| Boolean OR  | `\|\|`   | Single-bit only                          |
| Bitwise AND | `&`      | Works on multi-bit signals               |
| Bitwise OR  | `\|`     | Works on multi-bit signals               |
| Bitwise XOR | `^`      | Works on multi-bit signals               |
| Bitwise NOT | `~`      | Works on multi-bit signals               |
| Invert      | `!`      | Single-bit only                          |
| AND-reduce  | `& $x`   | One bit: are **all** bits of `$x` set?   |
| OR-reduce   | `\| $x`  | One bit: is **any** bit of `$x` set?     |

The last two are worth a second look, because they behave differently from the others. Written in front of a single signal rather than between two, `&` and `|` collapse every bit of that signal down to one answer. So `& $row` asks "is this entire signal all ones?" in a single operator. These become important later, when a whole row of a game board lives in one signal and you need to ask questions about all of it at once.

### Selection

The ternary operator `?:` maps directly to a multiplexer in hardware:

```tlv
$out = $sel ? $b : $a;
```

Chain conditions for multi-way selection, which is how you build MUXes, decoders, and ALU operation selectors:

```tlv
$out[7:0] = $op == 2'b11 ? $d :
            $op == 2'b10 ? $c :
            $op == 2'b01 ? $b :
                           $a;
```

Read a chain like this top to bottom as a list of questions, with the final value as the "none of the above" fallback. Reading them out loud helps more than you would expect.

### File structure

A minimal TL-Verilog file looks like this:

```tlv
\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Your circuit here
   $out = $a && $b;

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
```

Your logic lives in the `\TLV` section. Everything outside it is boilerplate that Makerchip handles for you. This is the exact skeleton every exercise in this course uses, so it will look familiar the moment you open one.

### The signals Makerchip gives you

Alongside your own `$signals`, every Makerchip design has a few built-in ones that start with `*`. They appear in every file in this course, so it is worth knowing what they are before they start showing up:

| Signal     | What it is                                                                    |
| ---------- | ----------------------------------------------------------------------------- |
| `*clk`     | The clock. You almost never reference it directly in TL-Verilog.               |
| `*reset`   | High for the first few cycles. Use it to force signals to a known start value. |
| `*cyc_cnt` | The current cycle number. Handy for driving test stimulus.                     |
| `*passed`  | Assert this to end the simulation successfully.                               |
| `*failed`  | Assert this to end the simulation with a failure.                             |

Most exercises here end with a line like `*passed = *cyc_cnt > 20;`, which just means "run 20 cycles, then stop." You can ignore it, or raise the number when you want a longer simulation to watch.

You will also see `` `BOGUS_USE($a $b) `` at the bottom of some files. Makerchip warns about signals that are computed but never consumed, since that is usually a real bug worth knowing about. In teaching examples, though, a signal often exists purely so you can look at it in the waveform. `` `BOGUS_USE `` tells the tool "yes, I meant to do that" and silences the warning. It generates no hardware.

!!! tip "Coming from Verilog?"

    The most important thing to unlearn is the `always @(*)` block. In TL-Verilog you simply assign signals directly and the compiler handles the rest. For sequential logic in Block 2, you reference previous cycle values with `>>1$signal` instead of `always @(posedge clk)`. Everything else follows naturally from there.

## Try it yourself

The sandbox below has a working circuit ready to go. Change the logic, recompile, and watch the diagram and waveform update in real time.

<div id="mc-sandbox" class="makerchip-embed"></div>

A few things worth trying: swap `&&` for `||` and recompile to see the waveform change, add a new signal like `$c[7:0] = $a[7:0] + $b[7:0]` and find it in the waveform, or deliberately introduce a syntax error and read what the compiler tells you. Getting comfortable with compiler errors early will save you a lot of time later.

## When something does not compile

You will hit compile errors, everyone does. A few are common enough that recognizing them saves real time:

**"Signal assigned more than once."** Every signal gets exactly one assignment in TL-Verilog. If you write `$count` in two places, even if one looks harmless, the tool cannot decide which is real. Search your file for the signal name and delete the stray one. This is easy to do by accident when editing.

**A signal that depends on itself.** Writing `$count = $count + 1;` asks the circuit to know its own answer before computing it, which no circuit can do. In hardware you reference the *previous* cycle instead: `$count = >>1$count + 1;`. Block 2 covers this properly, and it is worth knowing the error exists before you meet it.

**Width mismatches.** Assigning a 4-bit value to an 8-bit signal, or comparing signals of different widths, will at minimum produce a warning. Being explicit with constants (`4'd9` rather than `9`) heads most of these off.

**Line numbers that do not match your file.** Some errors come from the preprocessor, which expands your code before compiling. The line number it reports refers to that expanded version, not what you typed. Do not count lines; search for the signal or text the message mentions.

When an error message is genuinely opaque, the fastest move is to comment out the section you just added and recompile. If the error disappears, you have found your neighborhood.

## Where to go next

Once you are comfortable with the interface, jump to whichever block fits what you want to learn. If you want to start building something fun right away, head to the Block 1 Project, a pixel art generator built entirely from combinational logic.

<style>
.makerchip-embed { position: relative; width: 100%; height: 500px; }
</style>

<script type="module">
  import IdePlugin from 'https://beta.makerchip.com/dist/makerchip-plugin.js';

  const base = 'https://raw.githubusercontent.com/in-ir/makerchip-curriculum/main/code/block-1/';

  // EDITOR + DIAGRAM + WAVEFORM — full interface overview
  class FullIDE extends IdePlugin {
    async onReady() {
      await this.setLayoutState({
        sides: {
          left:  { panes: ['Editor', 'Nav-TLV'], activePane: 'Editor'   },
          right: { panes: ['Diagram', 'Waveform'], activePane: 'Diagram' }
        },
        splitAt: 0.5
      });
    }
  }

  // EDITOR + WAVEFORM — for the sandbox
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

  // Intro — full IDE so students can see all panes
  if (document.getElementById('mc-intro')) {
    FullIDE.create('mc-intro', {
      codeURL: base + 'half-adder.tlv'
    });
  }

  // Sandbox — editor + waveform for free exploration
  if (document.getElementById('mc-sandbox')) {
    EditorWaveformIDE.create('mc-sandbox', {
      codeURL: base + 'half-adder.tlv'
    });
  }
</script>
