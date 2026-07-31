\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Load and store reach the data memory. A store writes a register's
   // value to a memory address; a load reads it back. The address is
   // computed the same way as any add: base register plus immediate.

   // Program:
   //   0: addi x1, x0, 42     put 42 in x1
   //   4: sw   x1, 0(x0)      store x1 to mem[0]
   //   8: lw   x2, 0(x0)      load mem[0] into x2   (x2 should become 42)
   $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd8) ? 32'd8 : >>1$pc + 32'd4;
   $idx[2:0] = $pc[4:2];
   $instr[31:0] = ($idx == 3'd0) ? 32'h02A00093 : ($idx == 3'd1) ? 32'h00102023 : 32'h00002103;

   $opcode[6:0] = $instr[6:0];
   $rd[4:0]     = $instr[11:7];
   $rs1[4:0]    = $instr[19:15];
   $rs2[4:0]    = $instr[24:20];
   $i_imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:20]} : {20'd0, $instr[31:20]};
   $s_imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:25], $instr[11:7]} : {20'd0, $instr[31:25], $instr[11:7]};

   $is_load  = $opcode == 7'b0000011;
   $is_store = $opcode == 7'b0100011;
   $is_addi  = $opcode == 7'b0010011;

   $x1[31:0] = *reset ? 32'd0 : ($is_addi && $rd == 5'd1) ? $i_imm : ($is_load && $rd == 5'd1) ? $mem0 : >>1$x1;
   $x2[31:0] = *reset ? 32'd0 : ($is_load && $rd == 5'd2) ? $mem0 : >>1$x2;

   $rs2_val[31:0] = ($rs2 == 5'd1) ? >>1$x1 : 32'd0;

   // One memory cell at address 0.
   $mem0[31:0] = *reset ? 32'd0 : ($is_store && ($rs2_val != $mem0)) ? $rs2_val : >>1$mem0;

   `BOGUS_USE($x1 $x2 $mem0 $s_imm)

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
