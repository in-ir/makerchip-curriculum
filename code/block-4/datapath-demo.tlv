\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // The complete datapath running a straight-line program.
   // Set the register signals to decimal and watch them fill in:
   // x1 becomes 5, x2 becomes 3, x3 becomes 8 then 2, x4 becomes 6.

   $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd16) ? 32'd16 : >>1$pc + 32'd4;
   $idx[2:0] = $pc[4:2];
   $instr[31:0] = ($idx == 3'd0) ? 32'h00500093 : ($idx == 3'd1) ? 32'h00300113 : ($idx == 3'd2) ? 32'h002081B3 : ($idx == 3'd3) ? 32'h402081B3 : 32'h0020C233;

   $rd[4:0]     = $instr[11:7];
   $funct3[2:0] = $instr[14:12];
   $rs1[4:0]    = $instr[19:15];
   $rs2[4:0]    = $instr[24:20];
   $funct7[6:0] = $instr[31:25];
   $opcode[6:0] = $instr[6:0];
   $imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:20]} : {20'd0, $instr[31:20]};

   $is_r = $opcode == 7'b0110011;
   $is_i = $opcode == 7'b0010011;
   $rf_wr = $is_r || $is_i;
   $use_imm = $is_i;
   $alu_op[2:0] = ($is_i) ? 3'd0 : ($funct3 == 3'b000 && $funct7 == 7'b0100000) ? 3'd1 : ($funct3 == 3'b100) ? 3'd2 : ($funct3 == 3'b110) ? 3'd3 : ($funct3 == 3'b111) ? 3'd4 : 3'd0;

   $rs1_val[31:0] = ($rs1 == 5'd1) ? >>1$x1 : ($rs1 == 5'd2) ? >>1$x2 : ($rs1 == 5'd3) ? >>1$x3 : ($rs1 == 5'd4) ? >>1$x4 : 32'd0;
   $rs2_val[31:0] = ($rs2 == 5'd1) ? >>1$x1 : ($rs2 == 5'd2) ? >>1$x2 : ($rs2 == 5'd3) ? >>1$x3 : ($rs2 == 5'd4) ? >>1$x4 : 32'd0;
   $operand2[31:0] = $use_imm ? $imm : $rs2_val;
   $alu_out[31:0] = ($alu_op == 3'd1) ? $rs1_val - $operand2 : ($alu_op == 3'd2) ? $rs1_val ^ $operand2 : ($alu_op == 3'd3) ? $rs1_val | $operand2 : ($alu_op == 3'd4) ? $rs1_val & $operand2 : $rs1_val + $operand2;

   $x1[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd1) ? $alu_out : >>1$x1;
   $x2[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd2) ? $alu_out : >>1$x2;
   $x3[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd3) ? $alu_out : >>1$x3;
   $x4[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd4) ? $alu_out : >>1$x4;

   `BOGUS_USE($x1 $x2 $x3 $x4)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
