\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Start with a row that has some cells filled.
   $start_row[7:0] = 8'b00111100;

   // $target_col walks across the columns so you can watch your ops.
   $target_col[2:0] = *cyc_cnt[2:0];

   // TODO 1: SET the cell at $target_col in $start_row (turn it ON).
   //   Build a mask holding a single 1 at position $target_col, then
   //   combine it with $start_row using the operator that forces a bit ON.
   $set_result[7:0] = $start_row;

   // TODO 2: CLEAR the cell at $target_col (turn it OFF).
   //   Build the same single-1 mask, then INVERT it with ~ so it is all
   //   1s with one 0, and combine it using the operator that forces a
   //   bit OFF while leaving the others untouched.
   $clear_result[7:0] = $start_row;

   `BOGUS_USE($set_result $clear_result)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
