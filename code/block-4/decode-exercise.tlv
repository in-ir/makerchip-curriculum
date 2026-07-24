\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Build the decoder. Four instructions cycle past; your control
   // signals should identify each one.
   //   0x002080B3  add  x1, x1, x2
   //   0x402081B3  sub  x3, x1, x2
   //   0x00B00193  addi x3, x0, 11
   //   0xFE314CE3  blt  x2, x3, -8

   $slow[2:0] = *reset ? 3'd0 : (>>1$slow == 3'd4) ? 3'd0 : >>1$slow + 3'd1;
   $step = >>1$slow == 3'd4;
   $sel[1:0] = *reset ? 2'd0 : $step ? >>1$sel + 2'd1 : >>1$sel;

   $instr[31:0] = ($sel == 2'd0) ? 32'h002080B3 : ($sel == 2'd1) ? 32'h402081B3 : ($sel == 2'd2) ? 32'h00B00193 : 32'hFE314CE3;

   $opcode[6:0] = $instr[6:0];
   $funct3[2:0] = $instr[14:12];
   $funct7[6:0] = $instr[31:25];

   // TODO 1: identify the instruction KIND from the opcode alone.
   //   R-type arithmetic uses opcode 0110011.
   //   I-type arithmetic uses opcode 0010011.
   //   Branches use opcode 1100011.
   $is_r_type = 1'b0;
   $is_i_alu  = 1'b0;
   $is_branch = 1'b0;

   // TODO 2: identify the exact instructions.
   //   Start from the kind, then narrow with funct3, and for one of these
   //   four you will need funct7 as well. Work out which, and why.
   //     add  is R-type, funct3 000, funct7 0000000
   //     sub  is R-type, funct3 000, funct7 0100000
   //     addi is I-type, funct3 000
   //     blt  is a branch, funct3 100
   $is_add  = 1'b0;
   $is_sub  = 1'b0;
   $is_addi = 1'b0;
   $is_blt  = 1'b0;

   // TODO 3: the datapath control signal $rf_wr.
   //   It should be high when this instruction writes a result into a
   //   register. Think about which of these four produce a value worth
   //   keeping, and which one does not.
   $rf_wr = 1'b0;

   `BOGUS_USE($is_add $is_sub $is_addi $is_blt $rf_wr)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
