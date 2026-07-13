\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Traffic light FSM.
   // States: 0 = GREEN, 1 = YELLOW, 2 = RED
   // A timer holds each state for a set number of cycles, then advances.
   //   GREEN  lasts 4 cycles
   //   YELLOW lasts 2 cycles
   //   RED    lasts 4 cycles

   // How long the current state should last:
   $duration[2:0] = (>>1$state == 2'd0) ? 3'd3 :   // GREEN:  4 cycles (0..3)
                    (>>1$state == 2'd1) ? 3'd1 :   // YELLOW: 2 cycles (0..1)
                                          3'd3;     // RED:    4 cycles (0..3)

   // Timer counts within the current state, resets when the state changes.
   $expired = >>1$timer == $duration;
   $timer[2:0] = *reset    ? 3'd0 :
                 $expired  ? 3'd0 :
                             >>1$timer + 3'd1;

   // Next-state logic: advance only when the timer expires.
   $state[1:0] = *reset     ? 2'd0 :
                 ! $expired ? >>1$state :
                 (>>1$state == 2'd0) ? 2'd1 :   // GREEN  -> YELLOW
                 (>>1$state == 2'd1) ? 2'd2 :   // YELLOW -> RED
                                       2'd0;     // RED    -> GREEN

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
