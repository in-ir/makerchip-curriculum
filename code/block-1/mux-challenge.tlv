\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $op[1:0] = *cyc_cnt[3:2];
   $a = *cyc_cnt[1];
   $b = *cyc_cnt[0];
   
   // TODO: build a 2-bit function selector
   // op=00: $a AND $b
   // op=01: $a OR $b
   // op=10: $a XOR $b
   // op=11: NOT $a
   $out = 1'b0;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
