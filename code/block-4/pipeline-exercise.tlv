\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Build a 3-stage pipeline. A value enters, and each stage transforms it:
   //   stage 1: add 3
   //   stage 2: shift left by 1 (double)
   //   stage 3: subtract 2
   //
   // The point of this exercise is the STRUCTURE, not the arithmetic. Put
   // each assignment in the right stage and let TL-Verilog insert the
   // flip-flops between them.

   |work
      @1
         $in[7:0] = *cyc_cnt;
         // TODO 1: stage 1 result. Add 3 to $in.
         $s1[7:0] = 8'd0;

      // TODO 2: open stage 2 with @2, then compute $s2 by shifting $s1
      //   left by 1. Notice you reference $s1 directly: the pipeline
      //   carries it from stage 1 into stage 2 for you.

      // TODO 3: open stage 3 with @3, then compute $s3 = $s2 - 2.

   `BOGUS_USE(|work$s1)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
