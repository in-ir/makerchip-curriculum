\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Build the branch decision and the next-PC logic.
   // The program counts x1 up and loops while x1 < 3, using blt.
   //   0: addi x1, x1, 1
   //   4: blt  x1, x2, -4
   //   8: (done)
   $idx[2:0] = >>1$pc[4:2];
   $instr[31:0] = ($idx == 3'd0) ? 32'h00108093 : ($idx == 3'd1) ? 32'hFE20CEE3 : 32'h00000013;

   $opcode[6:0] = $instr[6:0];
   $funct3[2:0] = $instr[14:12];
   $is_branch = $opcode == 7'b1100011;

   $x1[31:0] = *reset ? 32'd0 : ($idx == 3'd0) ? >>1$x1 + 32'd1 : >>1$x1;
   $x2[31:0] = 32'd3;

   $offset[31:0] = $instr[31] ? {19'h7FFFF, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0} : {19'd0, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0};

   // TODO 1: the branch decision.
   //   $take should be high only when this is a branch AND the branch
   //   condition holds. This program uses blt (funct3 100), which is
   //   "less than". Compare last cycle's x1 against x2.
   $take = 1'b0;

   // TODO 2: the next PC.
   //   If the branch is taken, the PC moves by the signed $offset.
   //   Otherwise it advances to the next instruction as usual.
   //   Keep it on ONE line.
   $pc[31:0] = 32'd0;

   `BOGUS_USE($x1 $x2 $take $pc $is_branch $funct3)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
