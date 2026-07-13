\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A two-state FSM. State flips between IDLE (0) and ACTIVE (1)
   // each time $go is high.
   $go = *cyc_cnt[1:0] == 2'b00;
   $state = *reset ? 1'b0 :
            $go     ? ! >>1$state :
                      >>1$state;

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
