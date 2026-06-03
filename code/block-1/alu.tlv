\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $op[2:0]  = *cyc_cnt[4:2];
   $a[7:0]   = *cyc_cnt[7:0];
   $b[7:0]   = 8'b10101010;
   
   $and[7:0] = $a[7:0] & $b[7:0];
   $or[7:0]  = $a[7:0] | $b[7:0];
   $xor[7:0] = $a[7:0] ^ $b[7:0];
   $not[7:0] = ~$a[7:0];
   $add[7:0] = $a[7:0] + $b[7:0];
   $sub[7:0] = $a[7:0] - $b[7:0];
   $shl[7:0] = $a[7:0] << 1;
   $shr[7:0] = $a[7:0] >> 1;
   
   $out[7:0] = $op[2:0] == 3'b111 ? $shr :
               $op[2:0] == 3'b110 ? $shl :
               $op[2:0] == 3'b101 ? $sub :
               $op[2:0] == 3'b100 ? $add :
               $op[2:0] == 3'b011 ? $not :
               $op[2:0] == 3'b010 ? $xor :
               $op[2:0] == 3'b001 ? $or  :
                                    $and;
   
   *passed = *cyc_cnt > 60;
   *failed = 1'b0;
\SV
   endmodule
