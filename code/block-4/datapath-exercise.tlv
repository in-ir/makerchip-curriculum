\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Build the execute stage. Fetch and decode are done for you; your job
   // is the register reads, the operand MUX, the ALU, and one writeback.
   // The program: addi x1,x0,5 ; addi x2,x0,3 ; add x3,x1,x2  (x3 -> 8)

   $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd8) ? 32'd8 : >>1$pc + 32'd4;
   $idx[2:0] = $pc[4:2];
   $instr[31:0] = ($idx == 3'd0) ? 32'h00500093 : ($idx == 3'd1) ? 32'h00300113 : 32'h002081B3;

   $rd[4:0]     = $instr[11:7];
   $rs1[4:0]    = $instr[19:15];
   $rs2[4:0]    = $instr[24:20];
   $opcode[6:0] = $instr[6:0];
   $imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:20]} : {20'd0, $instr[31:20]};
   $is_i = $opcode == 7'b0010011;
   $rf_wr = ($opcode == 7'b0110011) || $is_i;
   $use_imm = $is_i;

   // TODO 1: read the two source registers.
   //   Given a register number in $rs1, return that register's value.
   //   x0 is always 0; x1..x3 are the registers below. This is the same
   //   read-MUX shape as the register file in Module 3.1. Use >>1 to read
   //   the value each register held last cycle.
   $rs1_val[31:0] = 32'd0;
   $rs2_val[31:0] = 32'd0;

   // TODO 2: the operand MUX.
   //   The ALU's second input is the immediate when $use_imm is high,
   //   otherwise it is the second register value.
   $operand2[31:0] = 32'd0;

   // TODO 3: the ALU. For this program you only need addition.
   //   (In the full CPU this is a multi-way select on $alu_op.)
   $alu_out[31:0] = 32'd0;

   // TODO 4: writeback for x3.
   //   x3 should take the ALU result when $rf_wr is high and $rd is 3,
   //   otherwise it keeps its previous value. x1 and x2 are done for you.
   $x1[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd1) ? $alu_out : >>1$x1;
   $x2[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd2) ? $alu_out : >>1$x2;
   $x3[31:0] = 32'd0;

   `BOGUS_USE($rs1_val $rs2_val $operand2 $alu_out $x1 $x2 $x3)

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
