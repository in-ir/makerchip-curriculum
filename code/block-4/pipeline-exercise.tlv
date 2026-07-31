\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Build a 3-stage pipeline. A value enters, and each stage transforms it:
   //   stage 1: add 3
   //   stage 2: double it (shift left by 1)
   //   stage 3: subtract 2
   //
   // The point is the STRUCTURE: each stage reads the PREVIOUS stage's
   // result from last cycle with >>1, which is the flip-flop that carries
   // a value from one pipeline stage to the next.

   $in[7:0] = *cyc_cnt;

   // Stage 1 is done for you.
   $s1[7:0] = $in + 8'd3;

   // TODO 1: stage 2. Double the stage-1 result, but read it from LAST
   //   cycle with >>1$s1. That one-cycle delay is what makes this a
   //   pipeline stage rather than a single combded expression.
   $s2[7:0] = 8'd0;

   // TODO 2: stage 3. Subtract 2 from last cycle's stage-2 result.
   $s3[7:0] = 8'd0;

   `BOGUS_USE($s1 $s2 $s3)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
