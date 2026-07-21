\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Watch the row signals change as a block falls.
   // Set each row's Waveform radix to BINARY to see the bits as a picture.
   $drop_row[1:0] = *cyc_cnt[1:0];

   $row0[7:0] = ($drop_row == 2'd0) ? 8'b00011000 : 8'b00000000;
   $row1[7:0] = ($drop_row == 2'd1) ? 8'b00011000 : 8'b00000000;
   $row2[7:0] = 8'b00111100;
   $row3[7:0] = 8'b01111110;

   // Read column 3 of row 0, and check if row 3 is full.
   $col3_row0 = $row0[3];
   $row3_full = & $row3;

   `BOGUS_USE($row0 $row1 $row2 $row3 $col3_row0 $row3_full)

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
