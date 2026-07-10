\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Counter that wraps at 10 (counts 0-9)
   $count[3:0] = *reset          ? 4'b0 :
                 >>1$count == 9  ? 4'b0 :
                                   >>1$count + 1;
   
   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
