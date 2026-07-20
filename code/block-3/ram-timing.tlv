\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Every cycle we WRITE the cycle count to address 2,
   // and READ address 2 at the same time.
   // Watch: $rd_data comes back one step behind $wr_data.
   $wr_en        = 1'b1;
   $wr_addr[2:0] = 3'd2;
   $wr_data[3:0] = *cyc_cnt[3:0];

   $m2[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd2) ? $wr_data : >>1$m2;

   $rd_addr[2:0] = 3'd2;
   $rd_data[3:0] = $m2;

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
