\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Writing is only allowed on EVEN cycles this time.
   $wr_en        = *cyc_cnt[0] == 1'b0;
   $wr_addr[2:0] = *cyc_cnt[2:0];
   $wr_data[3:0] = *cyc_cnt[3:0];

   // TODO: complete cell m3 so it:
   //   - resets to 0
   //   - stores $wr_data only when writes are enabled AND the address is 3
   //   - otherwise holds its value
   //
   //   $m3[3:0] = *reset ? 4'd0 :
   //              ($wr_en && $wr_addr == 3'd3) ? $wr_data :
   //                                             >>1$m3;

   $m3[3:0] = 4'd0;

   // The other cells are done for you.
   $m0[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd0) ? $wr_data : >>1$m0;
   $m1[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd1) ? $wr_data : >>1$m1;
   $m2[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd2) ? $wr_data : >>1$m2;

   `BOGUS_USE($m0 $m1 $m2 $m3)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
