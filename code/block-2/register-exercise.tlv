\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $in[3:0] = $rand[3:0];
   $rand[3:0] = *cyc_cnt[5:2] ^ *cyc_cnt[3:0];
   
   // TODO: Build a register called $max_so_far that holds the
   // largest value of $in seen since reset.
   //
   // Hint: compare $in against the PREVIOUS cycle's $max_so_far
   // using >>1$max_so_far, and keep whichever is bigger.
   //
   // $max_so_far[3:0] = *reset ? 4'b0 :
   //                    ($in > >>1$max_so_far) ? $in : >>1$max_so_far;
   
   $max_so_far[3:0] = 4'b0;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
