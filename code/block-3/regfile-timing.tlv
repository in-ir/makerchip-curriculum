\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // WRITE and READ the SAME register (r1) every cycle.
   // Watch closely: does $rd_data show the value you just wrote,
   // or the one from the cycle before?
   $wr_addr[1:0] = 2'd1;             // always write r1
   $wr_data[3:0] = *cyc_cnt[3:0];    // write the current cycle count

   $r1[3:0] = *reset ? 4'd0 : ($wr_addr == 2'd1) ? $wr_data : >>1$r1;

   $rd_addr[1:0] = 2'd1;             // always read r1
   $rd_data[3:0] = $r1;

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
