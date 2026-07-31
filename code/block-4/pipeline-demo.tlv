\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A PIPELINE. A value enters and is transformed step by step through
   // three stages. Each stage's result is carried to the next with >>1,
   // which is the flip-flop a pipeline places between stages. Watch a
   // single value ripple through step1, step2, step3 on successive cycles.

   $in[7:0] = *cyc_cnt;

   $step1[7:0] = $in + 8'd10;
   $step2[7:0] = >>1$step1 << 1;
   $step3[7:0] = >>1$step2 - 8'd5;

   `BOGUS_USE($step1 $step2 $step3)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
