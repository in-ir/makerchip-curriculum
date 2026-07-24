\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // BUG DEMO: a decoder that checks opcode and funct3 but forgets funct7.
   // ADD and SUB share an opcode AND a funct3. Only funct7 separates them.
   // Watch $sloppy_add stay high for BOTH instructions.

   $slow[2:0] = *reset ? 3'd0 : (>>1$slow == 3'd4) ? 3'd0 : >>1$slow + 3'd1;
   $step = >>1$slow == 3'd4;
   $pick = *reset ? 1'b0 : $step ? !>>1$pick : >>1$pick;

   // Alternate between "add x1,x1,x2" and "sub x3,x1,x2".
   $instr[31:0] = $pick ? 32'h402081B3 : 32'h002080B3;

   $opcode[6:0] = $instr[6:0];
   $funct3[2:0] = $instr[14:12];
   $funct7[6:0] = $instr[31:25];
   $is_r_type = $opcode == 7'b0110011;

   // Correct: funct7 tells add and sub apart.
   $good_add = $is_r_type && ($funct3 == 3'b000) && ($funct7 == 7'b0000000);
   $good_sub = $is_r_type && ($funct3 == 3'b000) && ($funct7 == 7'b0100000);

   // Sloppy: no funct7 check. This fires for BOTH.
   $sloppy_add = $is_r_type && ($funct3 == 3'b000);

   `BOGUS_USE($good_add $good_sub $sloppy_add)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
