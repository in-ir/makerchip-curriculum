\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A six-instruction program lives at addresses 0, 4, 8, 12, 16 and 20.

   // TODO: build the program counter.
   //   On reset it should start at address 0.
   //   Every cycle after that it should advance to the next instruction.
   //   When it runs past the last instruction it should wrap back to 0.
   //   Remember that instructions are 4 bytes apart, so "next" is not +1.
   //   Keep the whole assignment on ONE line.
   $pc[31:0] = 32'd0;

   $idx[2:0] = $pc[4:2];

   `BOGUS_USE($idx)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
