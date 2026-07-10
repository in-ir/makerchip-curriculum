\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A single 1 enters at the left and shifts right one position each cycle.
   // New bit in from the left is 1 only on the first cycle after reset.
   $shift_in = *cyc_cnt == 1;
   $sr[3:0] = *reset ? 4'b0 : {$shift_in, >>1$sr[3:1]};

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
