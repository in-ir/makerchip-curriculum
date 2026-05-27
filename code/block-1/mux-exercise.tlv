\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $sel[1:0] = *cyc_cnt[3:2];
   $x = *cyc_cnt[1];
   $y = *cyc_cnt[0];
   
   // TODO: replace $out = 1'b0 with a 4-to-1 MUX
   // sel=00: $x AND $y
   // sel=01: $x OR $y
   // sel=10: NOT $x
   // sel=11: $x XOR $y
   $out = 1'b0;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
