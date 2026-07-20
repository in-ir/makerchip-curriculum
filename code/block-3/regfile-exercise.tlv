\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // The four registers and the write logic are done for you.
   $wr_en        = 1'b1;
   $wr_addr[1:0] = *cyc_cnt[1:0];
   $wr_data[3:0] = *cyc_cnt[3:0] + 4'd1;

   $r0[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd0) ? $wr_data : >>1$r0;
   $r1[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd1) ? $wr_data : >>1$r1;
   $r2[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd2) ? $wr_data : >>1$r2;
   $r3[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd3) ? $wr_data : >>1$r3;

   $rd_addr[1:0] = >>1$wr_addr;

   // TODO: complete the read MUX.
   //   Select the register whose number matches $rd_addr.
   //   This is the same 4-to-1 MUX pattern from Block 1.
   //
   //   $rd_data[3:0] = ($rd_addr == 2'd0) ? $r0 :
   //                   ($rd_addr == 2'd1) ? $r1 :
   //                   ($rd_addr == 2'd2) ? $r2 :
   //                                        $r3;

   $rd_data[3:0] = 4'd0;

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
