\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // The program counter: a counter that steps by 4, not by 1.
   // Set the $pc radix to decimal in the Waveform and watch it walk
   // 0, 4, 8, 12 ... then wrap back to the top of the program.

   $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd20) ? 32'd0 : >>1$pc + 32'd4;

   // The word index into instruction memory: pc / 4, which is just
   // the pc with its bottom two bits dropped.
   $idx[2:0] = $pc[4:2];

   `BOGUS_USE($idx)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
