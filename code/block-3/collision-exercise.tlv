\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A fixed pile with gaps, and a piece that tries to slide right one
   // column per cycle, but must STOP when it would hit the pile.
   $pile[7:0] = 8'b11000011;

   // Where the piece WANTS to go next: one column right of where it is.
   $desired[7:0] = >>1$piece << 1;

   // TODO 1: detect a collision between $desired and the $pile.
   //   Two cells overlap where both hold a 1, so AND $desired with the
   //   $pile, then OR-reduce that result down to a single yes/no bit.
   $collision = 1'b0;

   // TODO 2: the move guard. Complete $piece so that:
   //   - on reset it starts at column 2 (8'b00000100)
   //   - if there's a collision it holds its position
   //   - otherwise it moves to $desired
   //   This is the guarded move from Module 3.5: take the move only when
   //   the destination is clear, and hold your ground when it is not.
   $piece[7:0] = 8'b00000100;

   `BOGUS_USE($pile $piece $desired $collision)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
