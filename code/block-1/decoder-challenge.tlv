\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $digit[2:0] = *cyc_cnt[2:0];
   
   // TODO: build a 7-segment display driver
   // $seg[6:0] = {A, B, C, D, E, F, G}
   // Bit 6 is segment A (top), bit 0 is segment G (middle)
   // Output the correct segment pattern for each digit 0-7
   $seg[6:0] = 7'b0;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
