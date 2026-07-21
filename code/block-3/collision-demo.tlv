\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // The collision test in isolation. A piece slides across a fixed pile;
   // $hit goes high on exactly the cycles where the piece overlaps it.
   $pile[7:0] = 8'b00110000;

   // A single-cell piece that moves right one column per cycle.
   $piece[7:0] = (8'b00000001 << *cyc_cnt[2:0]);

   // Overlap test: AND the two, then OR-reduce. Nonzero means collision.
   $overlap[7:0] = $piece & $pile;
   $hit = | $overlap;

   `BOGUS_USE($piece $pile $overlap $hit)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
