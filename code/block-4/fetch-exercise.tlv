\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Build the fetch stage: a program counter, and the instruction
   // memory it reads from.
   //
   // The program is six instructions long, living at addresses 0 to 20:
   //   word 0: 32'h00000093     word 3: 32'h002080B3
   //   word 1: 32'h00100113     word 4: 32'h00110113
   //   word 2: 32'h00B00193     word 5: 32'hFE314CE3

   // TODO 1: the program counter.
   //   Start at address 0, advance to the next instruction each cycle,
   //   and wrap back to 0 after the last one. Instructions are 4 bytes
   //   apart, so "next" is not +1. Keep it on ONE line.
   $pc[31:0] = 32'd0;

   // TODO 2: turn the byte address into a word index.
   //   Dividing by 4 costs nothing in hardware: you just select the bits
   //   above the bottom two.
   $idx[2:0] = 3'd0;

   // TODO 3: the instruction memory.
   //   Return the instruction word that $idx selects. This is the same
   //   read-MUX shape as the register file in Module 3.1: a chain of
   //   ternaries, with the last word as the fallback.
   $instr[31:0] = 32'd0;

   `BOGUS_USE($instr)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
