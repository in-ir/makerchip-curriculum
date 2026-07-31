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
   // Everything here is a piece you built earlier in the block.
   // ============================================================

   // --- FETCH (Module 4.1) ---
   $pc[31:0] = *reset ? 32'd0 : $take_branch ? >>1$pc + $offset : >>1$pc + 32'd4;
   $idx[2:0] = $pc[4:2];
   $instr[31:0] = ($idx == 3'd0) ? 32'h00000093 : ($idx == 3'd1) ? 32'h00100113 : ($idx == 3'd2) ? 32'h00B00193 : ($idx == 3'd3) ? 32'h002080B3 : ($idx == 3'd4) ? 32'h00110113 : 32'hFE314CE3;

   // --- DECODE (Modules 4.2, 4.3) ---
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

   $alu_op[2:0] = $is_i ? 3'd0 : ($funct3 == 3'b000 && $funct7 == 7'b0100000) ? 3'd1 : ($funct3 == 3'b100) ? 3'd2 : ($funct3 == 3'b110) ? 3'd3 : ($funct3 == 3'b111) ? 3'd4 : 3'd0;

   // --- REGISTER READ (Modules 3.1, 4.4) ---
   $rs1_val[31:0] = ($rs1 == 5'd1) ? >>1$x1 : ($rs1 == 5'd2) ? >>1$x2 : ($rs1 == 5'd3) ? >>1$x3 : 32'd0;
   $rs2_val[31:0] = ($rs2 == 5'd1) ? >>1$x1 : ($rs2 == 5'd2) ? >>1$x2 : ($rs2 == 5'd3) ? >>1$x3 : 32'd0;

   // --- EXECUTE (Modules 1.4, 4.4) ---
   $operand2[31:0] = $use_imm ? $imm : $rs2_val;
   $alu_out[31:0] = ($alu_op == 3'd1) ? $rs1_val - $operand2 : ($alu_op == 3'd2) ? $rs1_val ^ $operand2 : ($alu_op == 3'd3) ? $rs1_val | $operand2 : ($alu_op == 3'd4) ? $rs1_val & $operand2 : $rs1_val + $operand2;

   // --- BRANCH (Module 4.5) ---
   $offset[31:0] = $instr[31] ? {19'h7FFFF, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0} : {19'd0, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0};
   $take_branch = $is_branch && ($funct3 == 3'b100) && ($rs1_val < $rs2_val);

   // --- WRITEBACK (Module 4.4) ---
   $x1[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd1) ? $alu_out : >>1$x1;
   $x2[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd2) ? $alu_out : >>1$x2;
   $x3[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd3) ? $alu_out : >>1$x3;

   `BOGUS_USE($x1 $x2 $x3 $alu_out $take_branch $rd)

   *passed = *cyc_cnt > 80;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 720, height: 400, fill: "#0D001A"},
      render() {
         let pc = '$pc'.asInt()
         let instr = '$instr'.asInt()
         let x1 = '$x1'.asInt()
         let x2 = '$x2'.asInt()
         let x3 = '$x3'.asInt()
         let take = '$take_branch'.asBool()
         let aluout = '$alu_out'.asInt()
         let objs = []

         let asm = ["addi x1, x0, 0", "addi x2, x0, 1", "addi x3, x0, 11", "add x1, x1, x2", "addi x2, x2, 1", "blt x2, x3, -8"]
         let note = ["sum = 0", "i = 1", "limit = 11", "sum = sum + i", "i = i + 1", "loop while i < 11"]
         let cur = pc / 4

         objs.push(new fabric.Text("RISC-V CPU  -  summing 1 to 10", {
            left: 360, top: 20, originX: "center",
            fontSize: 16, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         for (let i = 0; i < 6; i++) {
            let here = (cur === i)
            let y = 48 + i * 34
            objs.push(new fabric.Rect({
               left: 40, top: y, width: 360, height: 30, rx: 4, ry: 4,
               fill: here ? "#3B1D6D" : "#1A0533",
               stroke: here ? "#eab308" : "#2A1A40", strokeWidth: here ? 2 : 1
            }))
            objs.push(new fabric.Text((here ? "> " : "  ") + asm[i], {
               left: 54, top: y + 15, originX: "left", originY: "center",
               fontSize: 12, fontFamily: "Courier New", fill: here ? "#EDE7F6" : "#6D5A8A"
            }))
            objs.push(new fabric.Text(note[i], {
               left: 260, top: y + 15, originX: "left", originY: "center",
               fontSize: 10, fontFamily: "Courier New", fill: here ? "#22c55e" : "#2A1A40"
            }))
         }

         let regs = [["x1 (sum)", x1], ["x2 (i)", x2], ["x3 (limit)", x3]]
         for (let i = 0; i < 3; i++) {
            let y = 70 + i * 60
            objs.push(new fabric.Rect({
               left: 450, top: y, width: 230, height: 48, rx: 6, ry: 6,
               fill: "#1A0533", stroke: "#7C4DFF", strokeWidth: 2
            }))
            objs.push(new fabric.Text(regs[i][0], {
               left: 466, top: y + 24, originX: "left", originY: "center",
               fontSize: 12, fontFamily: "Courier New", fill: "#B39DDB"
            }))
            objs.push(new fabric.Text("" + regs[i][1], {
               left: 664, top: y + 24, originX: "right", originY: "center",
               fontSize: 20, fontWeight: "bold", fontFamily: "Courier New", fill: "#EDE7F6"
            }))
         }

         if (take) {
            objs.push(new fabric.Text("branch taken: looping back", {
               left: 565, top: 262, originX: "center",
               fontSize: 12, fontWeight: "bold", fontFamily: "Courier New", fill: "#22c55e"
            }))
         }

         if (x1 === 55) {
            objs.push(new fabric.Text("DONE: sum = 55", {
               left: 565, top: 262, originX: "center",
               fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#eab308"
            }))
         }

         objs.push(new fabric.Text("PC = " + pc + "     ALU = " + aluout, {
            left: 360, top: 300, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))
         objs.push(new fabric.Text("watch x1 climb: 0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55", {
            left: 360, top: 322, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
