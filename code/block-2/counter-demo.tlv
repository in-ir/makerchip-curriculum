\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Counter with enable: counts for 4 cycles, holds for 4, repeating.
   // $enable is high while cyc_cnt[2] is 0.
   $enable = *cyc_cnt[2] == 1'b0;
   $count[3:0] = *reset  ? 4'b0 :
                 $enable ? >>1$count + 1 :
                           >>1$count;

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
