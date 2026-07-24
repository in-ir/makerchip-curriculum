\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Every field of an instruction is a bit slice. Watch them change as
   // the program steps. Set the Waveform radix on $instr to hex and on
   // the field signals to decimal to read this comfortably.

   $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd20) ? 32'd0 : >>1$pc + 32'd4;
   $idx[2:0] = $pc[4:2];

   $instr[31:0] = ($idx == 3'd0) ? 32'h00000093 : ($idx == 3'd1) ? 32'h00100113 : ($idx == 3'd2) ? 32'h00B00193 : ($idx == 3'd3) ? 32'h002080B3 : ($idx == 3'd4) ? 32'h00110113 : 32'hFE314CE3;

   $opcode[6:0]  = $instr[6:0];
   $rd[4:0]      = $instr[11:7];
   $funct3[2:0]  = $instr[14:12];
   $rs1[4:0]     = $instr[19:15];
   $rs2[4:0]     = $instr[24:20];
   $funct7[6:0]  = $instr[31:25];

   `BOGUS_USE($opcode $rd $funct3 $rs1 $rs2 $funct7)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
