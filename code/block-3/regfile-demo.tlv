\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A 4-register file, built from parts you already know:
   //   a DECODER (Block 1) picks which register to write,
   //   four REGISTERS (Block 2) each hold a value,
   //   a MUX (Block 1) picks which register to read.

   // Write controls: cycle through addresses, writing cyc_cnt as data.
   $wr_en        = 1'b1;
   $wr_addr[1:0] = *cyc_cnt[1:0];
   $wr_data[3:0] = *cyc_cnt[3:0];

   // Each register updates only when the write address matches it.
   $r0[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd0) ? $wr_data : >>1$r0;
   $r1[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd1) ? $wr_data : >>1$r1;
   $r2[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd2) ? $wr_data : >>1$r2;
   $r3[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd3) ? $wr_data : >>1$r3;

   // Read: a MUX selects one register based on the read address.
   $rd_addr[1:0] = >>1$wr_addr;
   $rd_data[3:0] = ($rd_addr == 2'd0) ? $r0 :
                   ($rd_addr == 2'd1) ? $r1 :
                   ($rd_addr == 2'd2) ? $r2 :
                                        $r3;

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
