\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $in[3:0] = *cyc_cnt[3:0];
   
   $reg[3:0] = >>1$reg[3:0] + 1;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
