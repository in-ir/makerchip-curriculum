\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // ============================================================
   // A COMPLETE RISC-V PROCESSOR
   // Runs a real program: sum the numbers 1 through 10.
   // The answer, 55, comes to rest in register x1.
   //   0:  addi x1, x0, 0     sum = 0
   //   4:  addi x2, x0, 1     i = 1
   //   8:  addi x3, x0, 11    limit = 11
   //   12: add  x1, x1, x2    sum = sum + i
   //   16: addi x2, x2, 1     i = i + 1
   //   20: blt  x2, x3, -8    loop while i < 11
   // Every part here is something you built earlier in the block.
   // ============================================================

   // --- FETCH ---  (idx reads >>1$pc to break the fetch/branch loop)
   $pc[31:0] = *reset ? 32'd0 : $take ? >>1$pc + $offset : >>1$pc + 32'd4;
   $idx[2:0] = >>1$pc[4:2];
   $instr[31:0] = ($idx == 3'd0) ? 32'h00000093 : ($idx == 3'd1) ? 32'h00100113 : ($idx == 3'd2) ? 32'h00B00193 : ($idx == 3'd3) ? 32'h002080B3 : ($idx == 3'd4) ? 32'h00110113 : 32'hFE314CE3;

   // --- DECODE ---
   $opcode[6:0] = $instr[6:0];
   $rd[4:0]     = $instr[11:7];
   $funct3[2:0] = $instr[14:12];
   $rs1[4:0]    = $instr[19:15];
   $rs2[4:0]    = $instr[24:20];
   $funct7[6:0] = $instr[31:25];
   $imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:20]} : {20'd0, $instr[31:20]};
   $is_r      = $opcode == 7'b0110011;
   $is_i      = $opcode == 7'b0010011;
   $is_branch = $opcode == 7'b1100011;
   $rf_wr   = $is_r || $is_i;
   $use_imm = $is_i;
   $alu_sub = $is_r && ($funct3 == 3'b000) && ($funct7 == 7'b0100000);

   // --- REGISTER READ ---  (>>1 reads: last cycle's register values)
   $rs1_val[31:0] = ($rs1 == 5'd1) ? >>1$x1 : ($rs1 == 5'd2) ? >>1$x2 : ($rs1 == 5'd3) ? >>1$x3 : 32'd0;
   $rs2_val[31:0] = ($rs2 == 5'd1) ? >>1$x1 : ($rs2 == 5'd2) ? >>1$x2 : ($rs2 == 5'd3) ? >>1$x3 : 32'd0;

   // --- EXECUTE ---
   $operand2[31:0] = $use_imm ? $imm : $rs2_val;
   $alu_out[31:0] = $alu_sub ? $rs1_val - $operand2 : $rs1_val + $operand2;

   // --- BRANCH ---
   $offset[31:0] = $instr[31] ? {19'h7FFFF, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0} : {19'd0, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0};
   $take = $is_branch && ($funct3 == 3'b100) && ($rs1_val < $rs2_val);

   // --- WRITEBACK ---
   $x1[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd1) ? $alu_out : >>1$x1;
   $x2[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd2) ? $alu_out : >>1$x2;
   $x3[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd3) ? $alu_out : >>1$x3;

   `BOGUS_USE($x1 $x2 $x3 $take $offset $alu_out)

   *passed = *cyc_cnt > 80;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 600, height: 320, fill: "#0D001A"},
      render() {
         let x1 = '$x1'.asInt()
         let x2 = '$x2'.asInt()
         let x3 = '$x3'.asInt()
         let take = '$take'.asBool()
         let objs = []

         objs.push(new fabric.Text("RISC-V CPU: summing 1 to 10", {
            left: 300, top: 24, originX: "center",
            fontSize: 16, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         objs.push(new fabric.Text("sum", {
            left: 300, top: 66, originX: "center",
            fontSize: 13, fontFamily: "Courier New", fill: "#B39DDB"
         }))
         objs.push(new fabric.Text("" + x1, {
            left: 300, top: 108, originX: "center",
            fontSize: 48, fontWeight: "bold", fontFamily: "Courier New", fill: "#eab308"
         }))

         objs.push(new fabric.Text("i = " + x2, {
            left: 200, top: 176, originX: "center",
            fontSize: 15, fontFamily: "Courier New", fill: "#EDE7F6"
         }))
         objs.push(new fabric.Text("limit = " + x3, {
            left: 400, top: 176, originX: "center",
            fontSize: 15, fontFamily: "Courier New", fill: "#EDE7F6"
         }))

         let msg = "running..."
         let col = "#4A3060"
         if (take) {
            msg = "looping back: i is still below the limit"
            col = "#22c55e"
         }
         if (x1 == 55) {
            msg = "DONE: 1+2+...+10 = 55"
            col = "#eab308"
         }
         objs.push(new fabric.Text(msg, {
            left: 300, top: 224, originX: "center",
            fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: col
         }))

         objs.push(new fabric.Text("watch the sum climb: 0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55", {
            left: 300, top: 270, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
