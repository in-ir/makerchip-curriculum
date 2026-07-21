\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A 4-row x 8-column grid. Each row is an 8-bit signal;
   // bit c of a row is column c (1 = filled, 0 = empty).
   // Here we set up a fixed shape so you can read the bits as a picture.
   $row0[7:0] = 8'b00011000;
   $row1[7:0] = 8'b00111100;
   $row2[7:0] = 8'b01111110;
   $row3[7:0] = 8'b11111111;

   // Read one cell: is column 3 of row 1 filled?
   $cell_1_3 = $row1[3];

   // Is row 3 completely full? (all 8 columns set)
   $row3_full = & $row3;

   `BOGUS_USE($row0 $row1 $row2 $row3 $cell_1_3 $row3_full)

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
