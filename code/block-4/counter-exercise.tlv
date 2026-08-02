\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // $enable is high for 2 cycles, low for 2, repeating.
   $enable = *cyc_cnt[1] == 1'b0;

   // TODO: Build a counter $count that:
   //   - resets to 0 on *reset
   //   - wraps back to 0 when it reaches 12
   //   - counts up by 1 only when $enable is high
   //   - otherwise holds its value
   // Priority order matters: reset, then wrap, then enable, then hold.
   // Read your own state with >>1$count when deciding.

   $count[3:0] = 4'b0;

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
