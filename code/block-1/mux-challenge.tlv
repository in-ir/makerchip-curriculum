\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $p = *cyc_cnt[2];
   $q = *cyc_cnt[1];
   $r = *cyc_cnt[0];
   
   // TODO: build a priority selector
   // If $p is 1, output $p
   // Else if $q is 1, output $q
   // Else output $r
   $out = 1'b0;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
