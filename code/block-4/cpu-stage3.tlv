\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // CPU STAGE 3: the real program, with a loop. Everything except the
   // branch is wired. Build the branch decision and the next-PC logic,
   // and the CPU will run the full sum 1..10 and leave 55 in x1.

   $pc[31:0] = *reset ? 32'd0 : $take_branch ? >>1$pc + $offset : >>1$pc + 32'd4;
   $idx[2:0] = $pc[4:2];
   $instr[31:0] = ($idx == 3'd0) ? 32'h00000093 : ($idx == 3'd1) ? 32'h00100113 : ($idx == 3'd2) ? 32'h00B00193 : ($idx == 3'd3) ? 32'h002080B3 : ($idx == 3'd4) ? 32'h00110113 : 32'hFE314CE3;

   $opcode[6:0] = $instr[6:0];
   $rd[4:0]     = $instr[11:7];
   $funct3[2:0] = $instr[14:12];
   $rs1[4:0]    = $instr[19:15];
   $rs2[4:0]    = $instr[24:20];
   $imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:20]} : {20'd0, $instr[31:20]};
   $is_i      = $opcode == 7'b0010011;
   $is_branch = $opcode == 7'b1100011;
   $rf_wr = ($opcode == 7'b0110011) || $is_i;
   $use_imm = $is_i;

   $rs1_val[31:0] = ($rs1 == 5'd1) ? >>1$x1 : ($rs1 == 5'd2) ? >>1$x2 : ($rs1 == 5'd3) ? >>1$x3 : 32'd0;
   $rs2_val[31:0] = ($rs2 == 5'd1) ? >>1$x1 : ($rs2 == 5'd2) ? >>1$x2 : ($rs2 == 5'd3) ? >>1$x3 : 32'd0;
   $operand2[31:0] = $use_imm ? $imm : $rs2_val;
   $alu_out[31:0] = $rs1_val + $operand2;

   $offset[31:0] = $instr[31] ? {19'h7FFFF, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0} : {19'd0, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0};

   // TODO 1: the branch decision. This program uses blt (funct3 100).
   //   $take_branch is high when this is a branch and rs1_val < rs2_val.
   $take_branch = 1'b0;

   // (the next-PC logic at the top already uses $take_branch and $offset,
   //  so once your decision is right, the loop closes itself.)

   $x1[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd1) ? $alu_out : >>1$x1;
   $x2[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd2) ? $alu_out : >>1$x2;
   $x3[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd3) ? $alu_out : >>1$x3;

   `BOGUS_USE($x1 $x2 $x3 $take_branch)

   *passed = *cyc_cnt > 80;
   *failed = 1'b0;
\SV
   endmodule
