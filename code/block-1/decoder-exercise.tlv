\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $in[2:0] = *cyc_cnt[2:0];
   
   // TODO: build a 3-to-8 decoder
   // When $in == 0, $y[0] should be 1, all others 0
   // When $in == 1, $y[1] should be 1, all others 0
   // ... and so on up to $in == 7
   $y[7:0] = 8'b0;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
