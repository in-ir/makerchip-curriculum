\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $a = *cyc_cnt[2];
   $b = *cyc_cnt[1];
   $c = *cyc_cnt[0];
   
   $x = 1'b0;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
