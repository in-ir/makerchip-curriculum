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
   //   To set column c: OR in a 1 shifted to position c.
   //   $set_result[7:0] = $start_row | (8'b00000001 << $target_col);
   $set_result[7:0] = $start_row;

   // TODO 2: CLEAR the cell at $target_col (turn it OFF).
   //   To clear column c: AND with a mask that has a 0 at position c.
   //   $clear_result[7:0] = $start_row & ~(8'b00000001 << $target_col);
   $clear_result[7:0] = $start_row;

   `BOGUS_USE($set_result $clear_result)

   *passed = *cyc_cnt > 30;
   *failed = 1'b0;
\SV
   endmodule
