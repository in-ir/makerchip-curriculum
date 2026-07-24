\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // THE COMPLETE FETCH STAGE: a program counter feeding an instruction
   // memory. Together these two pieces read a program out of memory,
   // one instruction per cycle.

   $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd20) ? 32'd0 : >>1$pc + 32'd4;

   // Address to word index: divide by 4 by dropping the bottom two bits.
   $idx[2:0] = $pc[4:2];

   // Instruction memory. This is the same read-MUX you built for the
   // register file in Module 3.1, just holding instructions instead of data.
   $instr[31:0] = ($idx == 3'd0) ? 32'h00000093 : ($idx == 3'd1) ? 32'h00100113 : ($idx == 3'd2) ? 32'h00B00193 : ($idx == 3'd3) ? 32'h002080B3 : ($idx == 3'd4) ? 32'h00110113 : 32'hFE314CE3;

   // A first peek at decoding: the bottom 7 bits are the opcode, the
   // field that says what KIND of instruction this is.
   $opcode[6:0] = $instr[6:0];

   `BOGUS_USE($instr $opcode)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
