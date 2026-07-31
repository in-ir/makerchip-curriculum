\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // CPU STAGE 1: fetch and decode are wired for you. Build the execute
   // path: read the registers, pick the operand, run the ALU. Writeback
   // is provided so you can see your ALU output land in the registers.
   // Program: addi x1,x0,0 ; addi x2,x0,1 ; addi x3,x0,11 (straight line)

   $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd8) ? 32'd8 : >>1$pc + 32'd4;
   $idx[2:0] = $pc[4:2];
   $instr[31:0] = ($idx == 3'd0) ? 32'h00000093 : ($idx == 3'd1) ? 32'h00100113 : 32'h00B00193;

   $opcode[6:0] = $instr[6:0];
   $rd[4:0]     = $instr[11:7];
   $rs1[4:0]    = $instr[19:15];
   $rs2[4:0]    = $instr[24:20];
   $imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:20]} : {20'd0, $instr[31:20]};
   $is_i = $opcode == 7'b0010011;
   $rf_wr = ($opcode == 7'b0110011) || $is_i;
   $use_imm = $is_i;

   // TODO 1: read the two source registers (x0 is 0; x1..x3 below).
   //   Use >>1 to read last cycle's value.
   $rs1_val[31:0] = 32'd0;
   $rs2_val[31:0] = 32'd0;

   // TODO 2: the operand MUX. Immediate when $use_imm, else $rs2_val.
   $operand2[31:0] = 32'd0;

   // TODO 3: the ALU. This stage only needs addition.
   $alu_out[31:0] = 32'd0;

   $x1[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd1) ? $alu_out : >>1$x1;
   $x2[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd2) ? $alu_out : >>1$x2;
   $x3[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd3) ? $alu_out : >>1$x3;

   `BOGUS_USE($x1 $x2 $x3 $rs1_val $rs2_val $operand2)

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
