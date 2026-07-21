\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A single row where we SET one moving column and watch it slide.
   // The lit column marches left to right by shifting the set-mask.
   $pos[2:0] = *cyc_cnt[2:0];

   // Start from an empty row, then SET the column at $pos.
   // Setting column c: row | (1 << c).
   $row[7:0] = 8'b00000000 | (8'b00000001 << $pos);

   `BOGUS_USE($row)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
