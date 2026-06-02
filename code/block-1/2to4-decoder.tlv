\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $in[1:0] = *cyc_cnt[1:0];
   
   $y[3:0] = $in[1:0] == 2'b11 ? 4'b1000 :
              $in[1:0] == 2'b10 ? 4'b0100 :
              $in[1:0] == 2'b01 ? 4'b0010 :
                                  4'b0001;
   
   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
