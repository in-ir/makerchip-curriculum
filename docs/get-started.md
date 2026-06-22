# Get Started with Makerchip

If you are new to digital logic, start with Block 1. You will learn Makerchip naturally as you work through the material. If you already have a solid foundation in digital logic and just want to get up to speed with Makerchip and TL-Verilog, this page is the right starting point. Read through it, play with the sandbox, and then jump to whichever block interests you.

## What is Makerchip?

Makerchip is a browser-based IDE for designing and simulating digital circuits. You write TL-Verilog, a modern and significantly cleaner dialect of Verilog, and Makerchip compiles it instantly, generates a circuit diagram, and runs a simulation you can inspect in the waveform viewer. There is nothing to install and no toolchain to configure. You open a browser and start designing chips.

## The interface

The Makerchip IDE is organized into four panes. You do not need all of them at once, and throughout this curriculum each exercise only shows the panes that are relevant to what you are doing.

The **Editor** is where you write your TL-Verilog code. Every time you compile, Makerchip rebuilds the circuit from scratch and updates the other panes.

The **Diagram** is an auto-generated schematic of your circuit. Every signal you assign becomes a node in the graph. As your designs grow, the diagram grows with them and becomes one of the most useful debugging tools you have.

The **Waveform** shows signal values over simulation time. Each row is a signal and each column is a clock cycle. Reading waveforms is the primary way hardware engineers verify that a circuit does what it is supposed to do.

**Nav-TLV** gives you a structured, navigable view of your code. It becomes particularly useful once your designs span multiple modules and pipelines.

The embed below shows all four panes. Use the `«` arrows to collapse any pane you do not need.

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

### Logic operators

| Operation   | Operator | Notes                      |
| ----------- | -------- | -------------------------- |
| Boolean AND | `&&`     | Single-bit only            |
| Boolean OR  | `\|\|`   | Single-bit only            |
| Bitwise AND | `&`      | Works on multi-bit signals |
| Bitwise OR  | `\|`     | Works on multi-bit signals |
| Bitwise XOR | `^`      | Works on multi-bit signals |
| Bitwise NOT | `~`      | Works on multi-bit signals |
| Invert      | `!`      | Single-bit only            |

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

### File structure

A minimal TL-Verilog file looks like this:

```tlv
\m5_TLV_version 1d: tl-x.org
\m5
\SV
   `include "sqrt32.v";
\TLV
   // Your circuit here
   $out = $a && $b;
\SV
   endmodule
```

Your logic lives in the `\TLV` section. Everything outside it is boilerplate that Makerchip handles for you when you use the sandbox.

!!! tip "Coming from Verilog?"

    The most important thing to unlearn is the `always @(*)` block. In TL-Verilog you simply assign signals directly and the compiler handles the rest. For sequential logic in Block 2, you reference previous cycle values with `>>1$signal` instead of `always @(posedge clk)`. Everything else follows naturally from there.

## Try it yourself

The sandbox below has a working circuit ready to go. Change the logic, hit compile, and watch the diagram and waveform update in real time.

<div id="mc-sandbox" class="makerchip-embed"></div>

A few things worth trying: swap `&&` for `||` and recompile to see the waveform change, add a new signal like `$c[7:0] = $a[7:0] + $b[7:0]` and find it in the waveform, or deliberately introduce a syntax error and read what the compiler tells you. Getting comfortable with compiler errors early will save you a lot of time later.

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
    new FullIDE('mc-intro', {
      codeURL: base + 'half-adder.tlv'
    });
  }

  // Sandbox — editor + waveform for free exploration
  if (document.getElementById('mc-sandbox')) {
    new EditorWaveformIDE('mc-sandbox', {
      codeURL: base + 'half-adder.tlv'
    });
  }
</script>
