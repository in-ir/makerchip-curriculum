\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $a = *cyc_cnt[1];
   $b = *cyc_cnt[0];
   
   $x = $a ^ $b;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
