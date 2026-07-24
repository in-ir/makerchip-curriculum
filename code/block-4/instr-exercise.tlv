\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A single instruction to take apart: 0x00B00193
   // (it happens to be "addi x3, x0, 11", but work it out from the bits)
   $instr[31:0] = 32'h00B00193;

   // TODO 1: pull out the six fields. Each one is a plain bit slice,
   //   no arithmetic. The bit ranges are fixed by the RISC-V spec:
   //     opcode  bits 6 down to 0
   //     rd      bits 11 down to 7
   //     funct3  bits 14 down to 12
   //     rs1     bits 19 down to 15
   //     rs2     bits 24 down to 20
   //     funct7  bits 31 down to 25
   $opcode[6:0] = 7'd0;
   $rd[4:0]     = 5'd0;
   $funct3[2:0] = 3'd0;
   $rs1[4:0]    = 5'd0;
   $rs2[4:0]    = 5'd0;
   $funct7[6:0] = 7'd0;

   // TODO 2: build the 32-bit sign-extended I-type immediate.
   //   The raw 12-bit immediate sits in bits 31 down to 20.
   //   If its top bit is 1 the number is negative and the upper 20 bits
   //   must be filled with ones; otherwise fill them with zeros.
   //   Concatenate with { } braces.
   $imm[31:0] = 32'd0;

   `BOGUS_USE($opcode $rd $funct3 $rs1 $rs2 $funct7 $imm)

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
