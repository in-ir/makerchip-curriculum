\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // BUG DEMO: moving a cell by SETTING the new spot but forgetting to
   // CLEAR the old one. Watch the row fill up with a trail instead of
   // showing a single moving cell.
   $pos[2:0] = *cyc_cnt[2:0];

   // Wrong: keep OR-ing new positions into the PREVIOUS row.
   // Old cells never get cleared, so they pile up.
   $buggy_row[7:0] = *reset ? 8'b0 : >>1$buggy_row | (8'b00000001 << $pos);

   `BOGUS_USE($buggy_row)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
