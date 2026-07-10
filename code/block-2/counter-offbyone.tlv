\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // GOAL: count 0 through 9 (ten values), then wrap.
   // BUG:  this wraps when the count REACHES 10, so it actually
   //       shows 0,1,2,...,9,10 — eleven values — before wrapping.
   $count[3:0] = *reset          ? 4'b0 :
                 >>1$count == 10 ? 4'b0 :
                                   >>1$count + 1;

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
