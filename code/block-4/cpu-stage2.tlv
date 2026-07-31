\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // CPU STAGE 2: now the program uses add and sub, not just addi. Build
   // the ALU operation decoder and the full ALU. Everything else is wired.
   // Program: addi x1,x0,5 ; addi x2,x0,3 ; add x3,x1,x2 ; sub x4,x1,x2

   $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd12) ? 32'd12 : >>1$pc + 32'd4;
   $idx[2:0] = $pc[4:2];
   $instr[31:0] = ($idx == 3'd0) ? 32'h00500093 : ($idx == 3'd1) ? 32'h00300113 : ($idx == 3'd2) ? 32'h002081B3 : 32'h40208233;

   $opcode[6:0] = $instr[6:0];
   $rd[4:0]     = $instr[11:7];
   $funct3[2:0] = $instr[14:12];
   $rs1[4:0]    = $instr[19:15];
   $rs2[4:0]    = $instr[24:20];
   $funct7[6:0] = $instr[31:25];
   $imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:20]} : {20'd0, $instr[31:20]};
   $is_i = $opcode == 7'b0010011;
   $rf_wr = ($opcode == 7'b0110011) || $is_i;
   $use_imm = $is_i;

   $rs1_val[31:0] = ($rs1 == 5'd1) ? >>1$x1 : ($rs1 == 5'd2) ? >>1$x2 : ($rs1 == 5'd3) ? >>1$x3 : 32'd0;
   $rs2_val[31:0] = ($rs2 == 5'd1) ? >>1$x1 : ($rs2 == 5'd2) ? >>1$x2 : ($rs2 == 5'd3) ? >>1$x3 : 32'd0;
   $operand2[31:0] = $use_imm ? $imm : $rs2_val;

   // TODO 1: the ALU operation selector.
   //   addi and add both add (op 0). sub is op 1, distinguished by funct7.
   //   Use funct3 and funct7 as in Module 4.3. (Only add/sub needed here.)
   $alu_op[2:0] = 3'd0;

   // TODO 2: the ALU. Op 1 subtracts, everything else adds (enough here).
   $alu_out[31:0] = 32'd0;

   $x1[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd1) ? $alu_out : >>1$x1;
   $x2[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd2) ? $alu_out : >>1$x2;
   $x3[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd3) ? $alu_out : >>1$x3;
   $x4[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd4) ? $alu_out : >>1$x4;

   `BOGUS_USE($x1 $x2 $x3 $x4 $alu_op)

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
