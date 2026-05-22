\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $sel = *cyc_cnt[2];
   $a = *cyc_cnt[1];
   $b = *cyc_cnt[0];
   
   $out = $sel ? $b : $a;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
