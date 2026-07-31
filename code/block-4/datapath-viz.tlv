\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // THE FIRST WORKING CPU. Fetch, decode, execute, writeback, all wired
   // together. It runs a straight-line program and leaves real answers
   // in the registers. Eight registers, shown stepping slowly.

   $slow[2:0] = *reset ? 3'd0 : (>>1$slow == 3'd4) ? 3'd0 : >>1$slow + 3'd1;
   $step = >>1$slow == 3'd4;
   $pc[31:0] = *reset ? 32'd0 : ($step && >>1$pc == 32'd16) ? 32'd0 : $step ? >>1$pc + 32'd4 : >>1$pc;
   $idx[2:0] = $pc[4:2];

   $instr[31:0] = ($idx == 3'd0) ? 32'h00500093 : ($idx == 3'd1) ? 32'h00300113 : ($idx == 3'd2) ? 32'h002081B3 : ($idx == 3'd3) ? 32'h402081B3 : 32'h0020C233;

   $rd[4:0]     = $instr[11:7];
   $funct3[2:0] = $instr[14:12];
   $rs1[4:0]    = $instr[19:15];
   $rs2[4:0]    = $instr[24:20];
   $funct7[6:0] = $instr[31:25];
   $opcode[6:0] = $instr[6:0];
   $imm[31:0] = $instr[31] ? {20'hFFFFF, $instr[31:20]} : {20'd0, $instr[31:20]};

   $is_r = $opcode == 7'b0110011;
   $is_i = $opcode == 7'b0010011;
   $rf_wr = ($is_r || $is_i) && $step;
   $use_imm = $is_i;

   $alu_op[2:0] = ($is_i) ? 3'd0 : ($funct3 == 3'b000 && $funct7 == 7'b0100000) ? 3'd1 : ($funct3 == 3'b100) ? 3'd2 : ($funct3 == 3'b110) ? 3'd3 : ($funct3 == 3'b111) ? 3'd4 : 3'd0;

   $rs1_val[31:0] = ($rs1 == 5'd1) ? >>1$x1 : ($rs1 == 5'd2) ? >>1$x2 : ($rs1 == 5'd3) ? >>1$x3 : ($rs1 == 5'd4) ? >>1$x4 : 32'd0;
   $rs2_val[31:0] = ($rs2 == 5'd1) ? >>1$x1 : ($rs2 == 5'd2) ? >>1$x2 : ($rs2 == 5'd3) ? >>1$x3 : ($rs2 == 5'd4) ? >>1$x4 : 32'd0;

   $operand2[31:0] = $use_imm ? $imm : $rs2_val;

   $alu_out[31:0] = ($alu_op == 3'd1) ? $rs1_val - $operand2 : ($alu_op == 3'd2) ? $rs1_val ^ $operand2 : ($alu_op == 3'd3) ? $rs1_val | $operand2 : ($alu_op == 3'd4) ? $rs1_val & $operand2 : $rs1_val + $operand2;

   $x1[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd1) ? $alu_out : >>1$x1;
   $x2[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd2) ? $alu_out : >>1$x2;
   $x3[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd3) ? $alu_out : >>1$x3;
   $x4[31:0] = *reset ? 32'd0 : ($rf_wr && $rd == 5'd4) ? $alu_out : >>1$x4;

   `BOGUS_USE($x1 $x2 $x3 $x4 $alu_out $operand2)

   *passed = *cyc_cnt > 60;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 720, height: 360, fill: "#0D001A"},
      render() {
         let instr = '$instr'.asInt()
         let rs1 = '$rs1'.asInt()
         let rs2 = '$rs2'.asInt()
         let rd = '$rd'.asInt()
         let s1v = '$rs1_val'.asInt()
         let op2 = '$operand2'.asInt()
         let out = '$alu_out'.asInt()
         let useimm = '$use_imm'.asBool()
         let aluop = '$alu_op'.asInt()
         let x1 = '$x1'.asInt()
         let x2 = '$x2'.asInt()
         let x3 = '$x3'.asInt()
         let x4 = '$x4'.asInt()
         let wr = '$rf_wr'.asBool()
         let objs = []

         let opname = ["+", "-", "^", "|", "&"][aluop]
         let h = instr.toString(16).toUpperCase()
         while (h.length < 8) { h = "0" + h }
         let asm = ["addi x1,x0,5","addi x2,x0,3","add x3,x1,x2","sub x3,x1,x2","xor x4,x1,x2"]
         let pc = '$pc'.asInt()
         objs.push(new fabric.Text("0x" + h + "     " + asm[pc / 4], {
            left: 360, top: 18, originX: "center",
            fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#EDE7F6"
         }))

         objs.push(new fabric.Text("REGISTERS", {
            left: 80, top: 52, originX: "center",
            fontSize: 11, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))
         let regs = [0, x1, x2, x3, x4]
         for (let i = 0; i < 5; i++) {
            let y = 72 + i * 34
            let isReadA = (i === rs1)
            let isReadB = (i === rs2)
            let isWrite = (wr && i === rd)
            let col = isWrite ? "#3B6D11" : (isReadA || isReadB) ? "#2A1650" : "#1A0533"
            let stroke = isWrite ? "#22c55e" : (isReadA || isReadB) ? "#7C4DFF" : "#2A1A40"
            objs.push(new fabric.Rect({
               left: 20, top: y, width: 120, height: 28, rx: 4, ry: 4,
               fill: col, stroke: stroke, strokeWidth: (isWrite || isReadA || isReadB) ? 2 : 1
            }))
            objs.push(new fabric.Text("x" + i + " = " + regs[i], {
               left: 30, top: y + 14, originX: "left", originY: "center",
               fontSize: 12, fontFamily: "Courier New", fill: (isWrite || isReadA || isReadB) ? "#ffffff" : "#6D5A8A"
            }))
         }

         objs.push(new fabric.Rect({
            left: 210, top: 120, width: 130, height: 70, rx: 6, ry: 6,
            fill: "#1A0533", stroke: "#eab308", strokeWidth: 2
         }))
         objs.push(new fabric.Text("operand MUX", {
            left: 275, top: 138, originX: "center", fontSize: 10, fontFamily: "Courier New", fill: "#eab308"
         }))
         objs.push(new fabric.Text(useimm ? "use: IMM" : "use: rs2", {
            left: 275, top: 158, originX: "center", fontSize: 11, fontWeight: "bold", fontFamily: "Courier New", fill: "#ffffff"
         }))
         objs.push(new fabric.Text("= " + op2, {
            left: 275, top: 176, originX: "center", fontSize: 11, fontFamily: "Courier New", fill: "#B39DDB"
         }))

         objs.push(new fabric.Rect({
            left: 410, top: 110, width: 150, height: 90, rx: 8, ry: 8,
            fill: "#1A0533", stroke: "#7C4DFF", strokeWidth: 2
         }))
         objs.push(new fabric.Text("ALU", {
            left: 485, top: 130, originX: "center", fontSize: 13, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))
         objs.push(new fabric.Text(s1v + " " + opname + " " + op2, {
            left: 485, top: 154, originX: "center", fontSize: 12, fontFamily: "Courier New", fill: "#EDE7F6"
         }))
         objs.push(new fabric.Text("= " + out, {
            left: 485, top: 176, originX: "center", fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: "#22c55e"
         }))

         objs.push(new fabric.Rect({
            left: 610, top: 120, width: 90, height: 70, rx: 6, ry: 6,
            fill: wr ? "#3B6D11" : "#1A0533", stroke: wr ? "#22c55e" : "#2A1A40", strokeWidth: 2
         }))
         objs.push(new fabric.Text("writeback", {
            left: 655, top: 138, originX: "center", fontSize: 10, fontFamily: "Courier New", fill: wr ? "#22c55e" : "#4A3060"
         }))
         objs.push(new fabric.Text(wr ? ("-> x" + rd) : "(none)", {
            left: 655, top: 162, originX: "center", fontSize: 12, fontWeight: "bold", fontFamily: "Courier New", fill: wr ? "#ffffff" : "#4A3060"
         }))

         objs.push(new fabric.Text(">", { left: 175, top: 155, originX: "center", fontSize: 18, fill: "#4A3060" }))
         objs.push(new fabric.Text(">", { left: 375, top: 155, originX: "center", fontSize: 18, fill: "#4A3060" }))
         objs.push(new fabric.Text(">", { left: 585, top: 155, originX: "center", fontSize: 18, fill: "#4A3060" }))

         objs.push(new fabric.Text("read registers  ->  pick 2nd operand  ->  compute  ->  write result back", {
            left: 360, top: 250, originX: "center", fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))
         objs.push(new fabric.Text("green register = being written this step    purple = being read", {
            left: 360, top: 274, originX: "center", fontSize: 10, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
