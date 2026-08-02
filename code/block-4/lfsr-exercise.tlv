\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // TODO: Build a 4-bit LFSR that produces a pseudo-random sequence.
   //
   // Step 1: compute the feedback bit as bit 3 XOR bit 2 of the PREVIOUS
   //         value (use >>1$lfsr to reach last cycle's bits).
   // Step 2: shift the previous value left by one and bring the feedback
   //         bit in at the bottom, using concatenation { }. Seed with
   //         0001 on reset so the register does not start stuck at zero.

   $fb = 1'b0;
   $lfsr[3:0] = 4'b0001;

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
