\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // An 8-entry RAM, each entry 4 bits.
   // Writing steps through addresses 0..7, storing the cycle count.
   $wr_en        = 1'b1;
   $wr_addr[2:0] = *cyc_cnt[2:0];
   $wr_data[3:0] = *cyc_cnt[3:0];

   // Each memory cell: update only when the write address selects it.
   $m0[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd0) ? $wr_data : >>1$m0;
   $m1[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd1) ? $wr_data : >>1$m1;
   $m2[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd2) ? $wr_data : >>1$m2;
   $m3[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd3) ? $wr_data : >>1$m3;
   $m4[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd4) ? $wr_data : >>1$m4;
   $m5[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd5) ? $wr_data : >>1$m5;
   $m6[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd6) ? $wr_data : >>1$m6;
   $m7[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 3'd7) ? $wr_data : >>1$m7;

   // Read port: a MUX selects one cell by the read address.
   $rd_addr[2:0] = >>1$wr_addr;
   $rd_data[3:0] = ($rd_addr == 3'd0) ? $m0 :
                   ($rd_addr == 3'd1) ? $m1 :
                   ($rd_addr == 3'd2) ? $m2 :
                   ($rd_addr == 3'd3) ? $m3 :
                   ($rd_addr == 3'd4) ? $m4 :
                   ($rd_addr == 3'd5) ? $m5 :
                   ($rd_addr == 3'd6) ? $m6 :
                                        $m7;

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
