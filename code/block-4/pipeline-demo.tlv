\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A PIPELINE. A value enters at stage 1 and is transformed step by step
   // through three stages. Each @ marks a stage. The flip-flops that carry
   // a signal from one stage to the next are added for you automatically:
   // that is the whole point of the pipeline construct.

   |calc
      @1
         $in[7:0] = *cyc_cnt;
         $step1[7:0] = $in + 8'd10;      // stage 1: add 10
      @2
         $step2[7:0] = $step1 << 1;      // stage 2: double it
      @3
         $step3[7:0] = $step2 - 8'd5;    // stage 3: subtract 5

   `BOGUS_USE(|calc$step3)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
