\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $sel[1:0] = *cyc_cnt[3:2];
   $x = *cyc_cnt[1];
   $y = *cyc_cnt[0];
   
   $a = $x && $y;
   $b = $x || $y;
   $c = !$x;
   $d = $x ^ $y;
   
   // TODO: replace this with a 4-to-1 MUX selecting between $a, $b, $c, $d
   $out = 1'b0;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
