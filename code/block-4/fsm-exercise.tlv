\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // The timer is done for you. It holds each state for a few cycles
   // and raises $expired when it's time to move to the next state.
   $duration[2:0] = (>>1$state == 2'd0) ? 3'd3 :
                    (>>1$state == 2'd1) ? 3'd1 :
                                          3'd3;
   $expired = >>1$timer == $duration;
   $timer[2:0] = *reset   ? 3'd0 :
                 $expired ? 3'd0 :
                            >>1$timer + 3'd1;

   // TODO: Complete the next-state logic.
   //   - On reset, start in GREEN (state 0).
   //   - While the timer has NOT expired, hold the current state.
   //   - When it expires, advance: GREEN -> YELLOW -> RED -> GREEN.
   // Read the current state with >>1$state when deciding the next one.

   $state[1:0] = 2'd0;

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;
\SV
   endmodule
