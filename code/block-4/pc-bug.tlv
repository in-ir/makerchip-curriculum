\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // BUG DEMO: this program counter steps by 1 instead of 4.
   // Watch $idx in the waveform: instead of advancing every cycle, the
   // same instruction gets fetched four times in a row, because the PC
   // is landing in the middle of instructions instead of on top of them.

   $pc[31:0] = *reset ? 32'd0 : (>>1$pc >= 32'd23) ? 32'd0 : >>1$pc + 32'd1;

   $idx[2:0] = $pc[4:2];

   `BOGUS_USE($idx)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
