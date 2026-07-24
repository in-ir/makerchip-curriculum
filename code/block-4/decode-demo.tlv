\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // The decoder wired to the fetch stage from Module 4.1.
   // Watch the control signals change as the program runs.

   $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd20) ? 32'd0 : >>1$pc + 32'd4;
   $idx[2:0] = $pc[4:2];
   $instr[31:0] = ($idx == 3'd0) ? 32'h00000093 : ($idx == 3'd1) ? 32'h00100113 : ($idx == 3'd2) ? 32'h00B00193 : ($idx == 3'd3) ? 32'h002080B3 : ($idx == 3'd4) ? 32'h00110113 : 32'hFE314CE3;

   $opcode[6:0] = $instr[6:0];
   $funct3[2:0] = $instr[14:12];
   $funct7[6:0] = $instr[31:25];

   $is_r_type = $opcode == 7'b0110011;
   $is_i_alu  = $opcode == 7'b0010011;
   $is_branch = $opcode == 7'b1100011;

   $is_add  = $is_r_type && ($funct3 == 3'b000) && ($funct7 == 7'b0000000);
   $is_addi = $is_i_alu  && ($funct3 == 3'b000);
   $is_blt  = $is_branch && ($funct3 == 3'b100);

   $rf_wr   = $is_r_type || $is_i_alu;
   $use_imm = $is_i_alu;

   `BOGUS_USE($is_add $is_addi $is_blt $rf_wr $use_imm)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
