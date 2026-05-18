# Module 1.1: Logic Gates

**Block 1 — Combinational Logic**  
**Estimated time:** 45–60 minutes  
**Prerequisites:** None  

---

## What you'll learn

By the end of this module you'll be able to:

- Explain what a logic gate does and why it matters
- Read and write truth tables for NOT, AND, OR, XOR, NAND, and NOR
- Express gate logic in TL-Verilog
- Run a combinational circuit in Makerchip and read its output
- Combine gates to build a simple function

---

## The one idea behind all of digital logic

Every circuit on every chip on every device you own is doing exactly one thing: manipulating **ones and zeros**.

That's it. A processor running a video game, a memory controller reading your files, the Wi-Fi chip sending your messages — all of it, at the lowest level, is ones and zeros being operated on by logic gates.

A **logic gate** is a circuit that takes one or more binary inputs and produces a binary output based on a fixed logical rule. Gates are the atoms of digital design. Everything else is built by combining them.

!!! note "Why ones and zeros?"
    In hardware, a `1` represents a high voltage (typically ~3.3V or 1.8V depending on the technology) and a `0` represents a low voltage (close to 0V). The circuit doesn't care about the exact voltage — just whether it's "high" or "low". This binary representation is what makes digital circuits so reliable and noise-resistant.

---

## The NOT gate

The simplest gate. One input, one output. It **inverts** the signal.

If the input is `1`, the output is `0`.  
If the input is `0`, the output is `1`.

**Truth table:**

| A (input) | X (output) |
|-----------|------------|
| 0         | 1          |
| 1         | 0          |

**Circuit symbol:**

> *(Insert Quartus screenshot: NOT gate)*

**In TL-Verilog:**

```tlv
$x = !$a;
```

That's it. One line. The `!` operator inverts the bit.

---

## The AND gate

Two inputs, one output. The output is `1` **only when both inputs are `1`**.  
Think of it exactly like the English word "and" — both things have to be true.

**Truth table:**

| A | B | X |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

**Circuit symbol:**

> *(Insert Quartus screenshot: AND gate)*

**In TL-Verilog:**

```tlv
$x = $a && $b;
```

---

## The OR gate

Two inputs, one output. The output is `1` when **at least one input is `1`**.

**Truth table:**

| A | B | X |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 1 |

**Circuit symbol:**

> *(Insert Quartus screenshot: OR gate)*

**In TL-Verilog:**

```tlv
$x = $a || $b;
```

---

## The XOR gate

XOR stands for **exclusive OR**. The output is `1` when the inputs are **different** from each other.

**Truth table:**

| A | B | X |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

Notice the difference from OR: when both inputs are `1`, XOR gives `0`, but OR gives `1`. That's the "exclusive" part.

**Circuit symbol:**

> *(Insert Quartus screenshot: XOR gate)*

**In TL-Verilog:**

```tlv
$x = $a ^ $b;
```

---

## NAND and NOR

NAND and NOR are simply AND and OR with the output **inverted** (the N stands for NOT).

**NAND truth table:**

| A | B | X |
|---|---|---|
| 0 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

**NOR truth table:**

| A | B | X |
|---|---|---|
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 0 |

**In TL-Verilog:**

```tlv
$x_nand = !($a && $b);
$x_nor  = !($a || $b);
```

!!! tip "NAND is universal"
    You can build every other gate — AND, OR, NOT, XOR — out of NAND gates alone. This is why NAND is sometimes called a **universal gate**. In practice, chip designers sometimes implement entire logic functions using only NAND gates because it simplifies the physical layout.

---

## Putting gates together

A single gate does one small thing. The real power comes from **combining gates** into more complex functions.

Here's an example: a **half adder**. It takes two single-bit inputs A and B and produces:
- **S (sum):** the lower bit of A + B
- **C (carry):** the upper bit of A + B

For example: `1 + 1 = 10` in binary. So S = 0, C = 1.

**Truth table:**

| A | B | S | C |
|---|---|---|---|
| 0 | 0 | 0 | 0 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 1 |

If you look at S: it's `1` only when A and B are *different* — that's XOR.  
If you look at C: it's `1` only when A and B are *both* `1` — that's AND.

**Circuit diagram:**

> *(Insert Quartus screenshot: half adder — XOR gate for S, AND gate for C)*

**In TL-Verilog:**

```tlv
$s = $a ^ $b;   // XOR for sum
$c = $a && $b;  // AND for carry
```

Two lines. That's a half adder.

---

## Your first circuit in Makerchip

Now let's run this in Makerchip so you can see it working.

Click the button below to open a starter sandbox with the half adder code pre-loaded:

[![Open in Makerchip](https://img.shields.io/badge/Open%20in-Makerchip-blue)](https://makerchip.com/sandbox?code_url=PLACEHOLDER_URL)

> *(You'll replace PLACEHOLDER_URL with your actual saved Makerchip link)*

Once it's open:

1. Click **Compile** (or press the compile shortcut)
2. Look at the **Diagram** tab — you should see the XOR and AND gates laid out
3. Look at the **Waveform** tab — you'll see `$a`, `$b`, `$s`, and `$c` signals over time
4. Try changing the values of `$a` and `$b` and verify the outputs match the truth table above

!!! note "Reading the auto-generated diagram"
    The diagram Makerchip generates is produced directly from your code. Each signal you assign becomes a node. This is different from drawing gates by hand — the layout is automatic, but the logic is exactly what you wrote. Take a moment to find your XOR gate and your AND gate in the diagram.

---

## Exercise: Three-input AND

**Build a circuit that outputs `1` only when all three inputs A, B, and C are `1`.**

You can't use a three-input AND gate directly — in TL-Verilog you chain two two-input ANDs:

```tlv
// Your code here
$x = ???
```

??? hint "Hint"
    Think about it in English: "A AND B AND C". Now write that as two ANDs:
    first compute A AND B, then AND the result with C.

??? solution "Solution"
    ```tlv
    $x = $a && $b && $c;
    ```
    TL-Verilog lets you chain `&&` directly, which is equivalent to two AND gates in sequence.

[Open starter code in Makerchip](https://makerchip.com/sandbox?code_url=PLACEHOLDER_URL_EXERCISE)

Verify your circuit with all 8 combinations of A, B, C. Only the row where all three are `1` should give an output of `1`.

---

## Match the waveform

Look at the waveform below. Two inputs, A and B, producing an output X.

> *(Insert screenshot: waveform showing A, B, X signals over 4 clock cycles)*
>
> | Cycle | A | B | X |
> |-------|---|---|---|
> | 1     | 0 | 0 | 0 |
> | 2     | 0 | 1 | 1 |
> | 3     | 1 | 0 | 1 |
> | 4     | 1 | 1 | 0 |

**What gate produces this output?**

Write the TL-Verilog expression for X:

```tlv
$x = ???
```

[Open in Makerchip to verify](https://makerchip.com/sandbox?code_url=PLACEHOLDER_URL_PUZZLE)

??? hint "How to read the waveform"
    Look at each row. When does X go high (become 1)? In cycles 2 and 3 — when A and B are *different*. When they're the same (both 0 in cycle 1, both 1 in cycle 4), X is 0.
    
    Which gate gives 1 when inputs are different?

??? solution "Solution"
    ```tlv
    $x = $a ^ $b;  // XOR
    ```
    The pattern — true when inputs differ, false when they match — is the definition of XOR.
    
    Reading waveforms backwards into code is one of the most important debugging skills in hardware design. When something in your circuit is misbehaving, you'll read its waveform and ask: "what logic would produce this pattern?"

---

## Where this fits next

You now know the fundamental building blocks of all combinational logic. Every circuit — no matter how complex — is made of these gates chained together.

In **Module 1.2**, you'll meet the multiplexer (MUX): a gate-level circuit that acts as a programmable switch. It's one of the most useful building blocks in digital design, and you'll use it constantly from here on.

---

## Quick reference

| Gate | TL-Verilog | Output is 1 when... |
|------|-----------|---------------------|
| NOT  | `!$a` | input is 0 |
| AND  | `$a && $b` | both inputs are 1 |
| OR   | `$a \|\| $b` | at least one input is 1 |
| XOR  | `$a ^ $b` | inputs are different |
| NAND | `!($a && $b)` | NOT both inputs are 1 |
| NOR  | `!($a \|\| $b)` | both inputs are 0 |