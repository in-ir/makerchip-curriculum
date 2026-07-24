\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // SIGN EXTENSION. An I-type immediate is only 12 bits, but the ALU
   // works in 32. Widening a POSITIVE number means padding with zeros.
   // Widening a NEGATIVE number means padding with ONES, or the value
   // changes meaning entirely.

   // Step through a few 12-bit immediates, some positive, some negative.
   $sel[1:0] = *reset ? 2'd0 : >>1$sel + 2'd1;
   $imm12[11:0] = ($sel == 2'd0) ? 12'h001 : ($sel == 2'd1) ? 12'h7FF : ($sel == 2'd2) ? 12'hFFF : 12'h800;

   // Correct: copy the top bit into all the new upper bits.
   $imm_ok[31:0] = $imm12[11] ? {20'hFFFFF, $imm12} : {20'd0, $imm12};

   // Wrong: always pad with zeros. Positive values survive, negative
   // values turn into huge positive numbers.
   $imm_bad[31:0] = {20'd0, $imm12};

   `BOGUS_USE($imm_ok $imm_bad)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
