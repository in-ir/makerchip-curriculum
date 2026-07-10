\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A toggling bit and a counting register.
   // Predict each before pressing play.
   $toggle = *reset ? 1'b0 : ! >>1$toggle;
   $count[2:0] = *reset ? 3'b0 : >>1$count + 1'b1;

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
