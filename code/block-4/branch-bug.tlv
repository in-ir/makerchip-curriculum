\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // BUG DEMO: a branch that jumps by a fixed +8 instead of using the
   // instruction's own offset. It "works" for one specific target and
   // silently jumps to the wrong place for every other branch.

   // Correct offset, sign-extended from the B-type fields.
   $instr[31:0] = 32'hFE20CEE3;
   $good_offset[31:0] = $instr[31] ? {19'h7FFFF, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0} : {19'd0, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0};

   // Wrong: a hardcoded jump distance that ignores the instruction.
   $bad_offset[31:0] = 32'd8;

   `BOGUS_USE($good_offset $bad_offset)

   *passed = *cyc_cnt > 10;
   *failed = 1'b0;
\SV
   endmodule
