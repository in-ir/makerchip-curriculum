\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // BUG DEMO: this register file forgot that x0 is hardwired to zero.
   // The program tries "addi x0, x0, 5". In real RISC-V, x0 ignores all
   // writes and stays 0 forever. Here $x0_bad happily becomes 5, and any
   // later instruction that reads x0 expecting zero gets garbage.

   $wr = 1'b1;
   $rd[4:0] = 5'd0;
   $val[31:0] = 32'd5;

   // Wrong: x0 is a normal writable register.
   $x0_bad[31:0] = *reset ? 32'd0 : ($wr && $rd == 5'd0) ? $val : >>1$x0_bad;

   // Right: x0 can never be written. It is always zero.
   $x0_ok[31:0] = 32'd0;

   `BOGUS_USE($x0_bad $x0_ok)

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
