\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $count[3:0] = >>1$count + 1;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
