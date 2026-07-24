\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A fixed 4-row x 8-column grid. Each row is 8 bits; bit c = column c.
   $row0[7:0] = 8'b00000000;
   $row1[7:0] = 8'b00011000;
   $row2[7:0] = 8'b01111110;
   $row3[7:0] = 8'b11111111;

   // TODO 1: read a single cell.
   //   Set $cell to the value of column 4 in row 2.
   //   Hint: a column is just a bit position, so you can index the row
   //   signal directly by the column number.
   $cell = 1'b0;

   // TODO 2: check whether row 3 is completely full.
   //   A row is full when ALL its bits are 1. Use the AND-reduction
   //   operator, a single & written in front of a signal, ANDs all of
   //   its bits together into one result.
   $row3_full = 1'b0;

   `BOGUS_USE($row0 $row1 $cell $row3_full)

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
