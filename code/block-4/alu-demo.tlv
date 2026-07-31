\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // The ALU on its own. Five operations selected by $alu_op.
   // Watch $alu_out change as the operation cycles.

   $alu_op[2:0] = *reset ? 3'd0 : (>>1$alu_op == 3'd4) ? 3'd0 : >>1$alu_op + 3'd1;
   $a[31:0] = 32'd12;
   $b[31:0] = 32'd10;

   $alu_out[31:0] = ($alu_op == 3'd1) ? $a - $b : ($alu_op == 3'd2) ? $a ^ $b : ($alu_op == 3'd3) ? $a | $b : ($alu_op == 3'd4) ? $a & $b : $a + $b;

   `BOGUS_USE($alu_out)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
