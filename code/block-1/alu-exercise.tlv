\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $op[3:0]  = *cyc_cnt[5:2];
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
   
   // TODO: add XNOR as operation 4'b1000
   // $xnor[7:0] = ?
   
   $out[7:0] = $op[3:0] == 4'b0111 ? $shr :
               $op[3:0] == 4'b0110 ? $shl :
               $op[3:0] == 4'b0101 ? $sub :
               $op[3:0] == 4'b0100 ? $add :
               $op[3:0] == 4'b0011 ? $not :
               $op[3:0] == 4'b0010 ? $xor :
               $op[3:0] == 4'b0001 ? $or  :
                                     $and;
   
   *passed = *cyc_cnt > 60;
   *failed = 1'b0;
\SV
   endmodule
