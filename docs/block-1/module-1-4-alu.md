# Module 1.4: The ALU

**Block 1 Combinational Logic**  
**Estimated time:** 60–90 minutes  
**Prerequisites:** Module 1.3 Decoders

## What you'll learn

By the end of this module you'll be able to:

- Explain what an ALU is and why it sits at the heart of every processor
- Implement all eight ALU operations in TL-Verilog
- Understand how addition and subtraction work in binary
- Explain logical and arithmetic shifting
- Connect everything you've built in Block 1 into one complete circuit

## The circuit at the heart of every processor

Every computation your computer performs adding two numbers, comparing values, running a loop, rendering a pixel eventually comes down to one circuit: the **Arithmetic Logic Unit**, or **ALU**.

An ALU is a combinational circuit that takes two inputs and an opcode, and produces one output. The opcode tells it which operation to perform. Everything else the clock, the memory, the registers feeds into and out of the ALU, but the ALU itself is pure combinational logic. No state, no memory, just inputs in and output out.

You've already built a mini version of this in Module 1.2. What you're building now is the real thing.

## The inputs and outputs

A standard ALU has:

- **A** first operand (the data to operate on)
- **B** second operand
- **OP** opcode (selects the operation)
- **OUT** result

In this module you'll work with 8-bit operands and a 3-bit opcode, giving you 8 possible operations.

**Circuit diagram:**

![ALU](../assets/images/alu.jpg)

## The eight operations

Here are the operations your ALU will support:

| OP     | Operation | Description                     |
| ------ | --------- | ------------------------------- |
| 3'b000 | AND       | Bitwise AND of A and B          |
| 3'b001 | OR        | Bitwise OR of A and B           |
| 3'b010 | XOR       | Bitwise XOR of A and B          |
| 3'b011 | NOT       | Bitwise NOT of A (B is ignored) |
| 3'b100 | ADD       | A plus B                        |
| 3'b101 | SUB       | A minus B                       |
| 3'b110 | SHL       | Shift A left by 1 bit           |
| 3'b111 | SHR       | Shift A right by 1 bit          |

## Logic operations

The first four operations are direct extensions of what you learned in Module 1.1. The only difference is that instead of operating on single bits, you're now operating on all 8 bits at once. TL-Verilog handles this automatically when you use multi-bit signals.

```tlv
$and[7:0] = $a[7:0] & $b[7:0];
$or[7:0]  = $a[7:0] | $b[7:0];
$xor[7:0] = $a[7:0] ^ $b[7:0];
$not[7:0] = ~$a[7:0];
```

Notice that bitwise operations use single operators (`&`, `|`, `^`, `~`) rather than the double operators (`&&`, `||`) you used for single-bit logic. The double operators are for boolean conditions. The single operators work bit by bit across the whole signal.

## Addition

Adding two binary numbers works exactly like adding decimal numbers by hand you add each column and carry the overflow into the next.

In Module 1.1 you built a half adder that adds two single bits and produces a sum and a carry. A full 8-bit adder chains eight of these together, passing the carry from each bit position into the next. TL-Verilog handles this automatically with the `+` operator:

```tlv
$add[7:0] = $a[7:0] + $b[7:0];
```

One line. TL-Verilog synthesizes the full carry chain for you.

!!! note "Overflow"
    When the result of an addition doesn't fit in 8 bits, the extra bit is lost. For example, 255 + 1 wraps around to 0. In a real processor the ALU produces a carry-out flag to signal this. We keep things simple here and ignore overflow, but it's worth knowing it exists.

## Subtraction and two's complement

Subtraction is where things get interesting. In hardware, you don't build a separate subtractor circuit. Instead, you reuse the adder with a clever trick called **two's complement**.

To compute A minus B, you instead compute A plus the two's complement of B. The two's complement of a number is obtained by inverting all its bits and adding 1:

```
two's complement of B = ~B + 1
```

So subtraction becomes:

```
A - B = A + (~B + 1) = A + ~B + 1
```

In TL-Verilog:

```tlv
$sub[7:0] = $a[7:0] + (~$b[7:0]) + 8'b1;
```

Or more simply, since TL-Verilog's `-` operator handles this automatically:

```tlv
$sub[7:0] = $a[7:0] - $b[7:0];
```

!!! note "Why two's complement?"
    Two's complement is the standard way computers represent negative numbers. It has a beautiful property: addition and subtraction use exactly the same hardware. Your processor doesn't have a separate subtraction circuit it just feeds the two's complement into the adder. This is one of the most elegant ideas in computer architecture.

## Shifting

A **shift** moves all the bits in a signal left or right by a number of positions. Bits that shift out of range are lost, and the empty positions are filled with zeros.

**Shift left by 1** (`SHL`): every bit moves one position to the left. The leftmost bit is lost, and a `0` comes in from the right.

```
Before: 0 1 1 0 1 0 1 0
After:  1 1 0 1 0 1 0 0
```

**Shift right by 1** (`SHR`): every bit moves one position to the right. The rightmost bit is lost, and a `0` comes in from the left.

```
Before: 0 1 1 0 1 0 1 0
After:  0 0 1 1 0 1 0 1
```

Notice that shifting left by 1 is equivalent to multiplying by 2, and shifting right by 1 is equivalent to dividing by 2 (ignoring remainders). Processors use shifts constantly for fast multiplication and division.

In TL-Verilog:

```tlv
$shl[7:0] = $a[7:0] << 1;
$shr[7:0] = $a[7:0] >> 1;
```

!!! tip "Other types of shifts"
    The shifts above are called **logical shifts** empty positions always fill with zero. There are two other variants worth knowing about. An **arithmetic right shift** fills the empty position with the sign bit (the leftmost bit) instead of zero, which preserves the sign of a negative number in two's complement. A **circular shift** (also called a rotate) wraps the bit that falls off one end back in on the other end, so no bits are ever lost. Both are common in real processors and cryptographic hardware.

## Putting it all together

Now that you have all eight results, you select the right one using the opcode exactly the MUX pattern from Module 1.2:

```tlv
$out[7:0] = $op[2:0] == 3'b111 ? $shr :
             $op[2:0] == 3'b110 ? $shl :
             $op[2:0] == 3'b101 ? $sub :
             $op[2:0] == 3'b100 ? $add :
             $op[2:0] == 3'b011 ? $not :
             $op[2:0] == 3'b010 ? $xor :
             $op[2:0] == 3'b001 ? $or  :
                                  $and;
```

The full ALU in TL-Verilog:

```tlv
$and[7:0] = $a[7:0] & $b[7:0];
$or[7:0]  = $a[7:0] | $b[7:0];
$xor[7:0] = $a[7:0] ^ $b[7:0];
$not[7:0] = ~$a[7:0];
$add[7:0] = $a[7:0] + $b[7:0];
$sub[7:0] = $a[7:0] - $b[7:0];
$shl[7:0] = $a[7:0] << 1;
$shr[7:0] = $a[7:0] >> 1;

$out[7:0] = $op[2:0] == 3'b111 ? $shr :
             $op[2:0] == 3'b110 ? $shl :
             $op[2:0] == 3'b101 ? $sub :
             $op[2:0] == 3'b100 ? $add :
             $op[2:0] == 3'b011 ? $not :
             $op[2:0] == 3'b010 ? $xor :
             $op[2:0] == 3'b001 ? $or  :
                                  $and;
```

Ten lines. That's a complete ALU.

### See it running in Makerchip

<iframe src="https://www.makerchip.com/sandbox?code_url=https:%2F%2Fraw.githubusercontent.com%2Fin-ir%2Fmakerchip-curriculum%2Fmain%2Fcode%2Fblock-1%2Falu.tlv" style="width:100%; height:500px; border:none;"></iframe>

Open the waveform and try different values of `$op`. Watch `$out` change as the ALU switches between operations. Try inputs where the results are clearly different for example, `$a = 8'b10101010` and `$b = 8'b11001100` and verify each operation by hand against what the waveform shows.

## Exercise: Extend the ALU

**Add a ninth operation to the ALU: XNOR.**

XNOR is the inverse of XOR the output is `1` when both inputs are the same. Extend the opcode to 4 bits and add XNOR as operation `4'b1000`.

<iframe src="https://www.makerchip.com/sandbox?code_url=https:%2F%2Fraw.githubusercontent.com%2Fin-ir%2Fmakerchip-curriculum%2Fmain%2Fcode%2Fblock-1%2Falu-exercise.tlv" style="width:100%; height:500px; border:none;"></iframe>


??? hint "Hint"
    XNOR is just XOR with the output inverted. Compute it as an intermediate signal first, then add it as the first case in your opcode chain with `$op[3:0] == 4'b1000`.

??? solution "Solution"
    ```tlv
    $and[7:0]  = $a[7:0] & $b[7:0];
    $or[7:0]   = $a[7:0] | $b[7:0];
    $xor[7:0]  = $a[7:0] ^ $b[7:0];
    $xnor[7:0] = ~($a[7:0] ^ $b[7:0]);
    $not[7:0]  = ~$a[7:0];
    $add[7:0]  = $a[7:0] + $b[7:0];
    $sub[7:0]  = $a[7:0] - $b[7:0];
    $shl[7:0]  = $a[7:0] << 1;
    $shr[7:0]  = $a[7:0] >> 1;

    $out[7:0] = $op[3:0] == 4'b1000 ? $xnor :
               $op[3:0] == 4'b0111 ? $shr  :
               $op[3:0] == 4'b0110 ? $shl  :
               $op[3:0] == 4'b0101 ? $sub  :
               $op[3:0] == 4'b0100 ? $add  :
               $op[3:0] == 4'b0011 ? $not  :
               $op[3:0] == 4'b0010 ? $xor  :
               $op[3:0] == 4'b0001 ? $or   :
                                     $and;
    ```

## Challenge: Flag generation

A real ALU doesn't just produce a result it also produces **flags** that describe properties of the result. These flags are used by the processor to make decisions (like whether to take a branch in an if-statement).

**Add the following flags to your ALU:**

- **Zero flag (`$zero`):** `1` if `$out` is all zeros, `0` otherwise
- **Negative flag (`$neg`):** `1` if the most significant bit of `$out` is `1` (indicating a negative number in two's complement)
- **Carry flag (`$carry`):** `1` if the addition produced a carry out of the 8th bit

<iframe src="https://www.makerchip.com/sandbox?code_url=https:%2F%2Fraw.githubusercontent.com%2Fin-ir%2Fmakerchip-curriculum%2Fmain%2Fcode%2Fblock-1%2Falu-challenge.tlv" style="width:100%; height:500px; border:none;"></iframe>


??? hint "Hint"
    The zero flag is just a NOR of all output bits. If any bit is `1`, the result is not zero. The negative flag is simply `$out[7]`. For the carry flag, compute addition with a 9-bit result and take the extra bit: `$add_with_carry[8:0] = {1'b0, $a} + {1'b0, $b}` then `$carry = $add_with_carry[8]`.

??? solution "Solution"
    ```tlv
    $and[7:0] = $a[7:0] & $b[7:0];
    $or[7:0]  = $a[7:0] | $b[7:0];
    $xor[7:0] = $a[7:0] ^ $b[7:0];
    $not[7:0] = ~$a[7:0];
    $add[7:0] = $a[7:0] + $b[7:0];
    $sub[7:0] = $a[7:0] - $b[7:0];
    $shl[7:0] = $a[7:0] << 1;
    $shr[7:0] = $a[7:0] >> 1;

    $out[7:0] = $op[2:0] == 3'b111 ? $shr :
               $op[2:0] == 3'b110 ? $shl :
               $op[2:0] == 3'b101 ? $sub :
               $op[2:0] == 3'b100 ? $add :
               $op[2:0] == 3'b011 ? $not :
               $op[2:0] == 3'b010 ? $xor :
               $op[2:0] == 3'b001 ? $or  :
                                    $and;

    $zero  = ($out[7:0] == 8'b0);
    $neg   = $out[7];
    $add_with_carry[8:0] = {1'b0, $a[7:0]} + {1'b0, $b[7:0]};
    $carry = $add_with_carry[8];
    ```

    These three flags are exactly what a real processor uses to implement conditional branching. When you write `if (a == b)` in C, the compiler generates a SUB instruction and checks the zero flag. When you write `if (a < 0)`, it checks the negative flag. You just built the hardware that makes those decisions possible.

## Where this fits next

You've now completed Block 1. You can build any combinational circuit from gates, route signals with MUXes, decode binary values, and perform arithmetic and logic operations with a full ALU. These are the building blocks of every digital system ever made.

In **Block 2**, you'll add the missing ingredient: **state**. You'll learn how circuits can remember values across clock cycles, and use that to build counters, registers, and your first finite state machine which will power the penalty kick game.

## Quick reference

| Operation | TL-Verilog | Description                    |
| --------- | ---------- | ------------------------------ |
| AND       | `$a & $b`  | Bitwise AND                    |
| OR        | `$a \| $b` | Bitwise OR                     |
| XOR       | `$a ^ $b`  | Bitwise XOR                    |
| NOT       | `~$a`      | Bitwise NOT                    |
| ADD       | `$a + $b`  | Addition                       |
| SUB       | `$a - $b`  | Subtraction (two's complement) |
| SHL       | `$a << 1`  | Logical shift left             |
| SHR       | `$a >> 1`  | Logical shift right            |
