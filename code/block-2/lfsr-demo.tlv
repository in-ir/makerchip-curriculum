\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // 4-bit LFSR. Feedback = bit3 XOR bit2, shifted into the bottom.
   // Seeded with 0001. Cycles through all 15 non-zero values.
   $fb = >>1$lfsr[3] ^ >>1$lfsr[2];
   $lfsr[3:0] = *reset ? 4'b0001 : {>>1$lfsr[2:0], $fb};

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
