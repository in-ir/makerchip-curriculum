\m5_TLV_version 1d: tl-x.org
\SV
   m5_makerchip_module
\TLV
   $a = *cyc_cnt[1];
   $b = *cyc_cnt[0];
   
   // Replace the line below with the correct logic gate
   $x = 1'b0;
   
   *passed = *cyc_cnt > 10;
   *failed = 1'b0;
\SV
   endmodule
