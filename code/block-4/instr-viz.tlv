\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Pulling a RISC-V instruction apart into its fields.
   // The program steps forward slowly so you can read each one.

   $slow[3:0] = *reset ? 4'd0 : (>>1$slow == 4'd5) ? 4'd0 : >>1$slow + 4'd1;
   $step = >>1$slow == 4'd5;
   $idx[2:0] = *reset ? 3'd0 : ($step && >>1$idx == 3'd5) ? 3'd0 : $step ? >>1$idx + 3'd1 : >>1$idx;

   $instr[31:0] = ($idx == 3'd0) ? 32'h00000093 : ($idx == 3'd1) ? 32'h00100113 : ($idx == 3'd2) ? 32'h00B00193 : ($idx == 3'd3) ? 32'h002080B3 : ($idx == 3'd4) ? 32'h00110113 : 32'hFE314CE3;

   // Every field is a plain bit slice. No logic, just picking wires.
   $opcode[6:0]  = $instr[6:0];
   $rd[4:0]      = $instr[11:7];
   $funct3[2:0]  = $instr[14:12];
   $rs1[4:0]     = $instr[19:15];
   $rs2[4:0]     = $instr[24:20];
   $funct7[6:0]  = $instr[31:25];

   `BOGUS_USE($opcode $rd $funct3 $rs1 $rs2 $funct7)

   *passed = *cyc_cnt > 120;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 700, height: 330, fill: "#0D001A"},
      render() {
         let instr = '$instr'.asInt()
         let idx = '$idx'.asInt()
         let objs = []

         let asm = ["addi x1, x0, 0", "addi x2, x0, 1", "addi x3, x0, 11", "add x1, x1, x2", "addi x2, x2, 1", "blt x2, x3, -8"]
         let kind = ["I-type", "I-type", "I-type", "R-type", "I-type", "B-type"]

         let h = instr.toString(16).toUpperCase()
         while (h.length < 8) { h = "0" + h }

         objs.push(new fabric.Text("0x" + h + "    " + asm[idx] + "    (" + kind[idx] + ")", {
            left: 350, top: 22, originX: "center",
            fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#EDE7F6"
         }))

         let bits = ""
         for (let b = 31; b >= 0; b--) { bits = bits + ((instr >>> b) & 1) }
         objs.push(new fabric.Text(bits, {
            left: 350, top: 52, originX: "center",
            fontSize: 13, fontFamily: "Courier New", fill: "#4A3060"
         }))

         let names = ["funct7", "rs2", "rs1", "funct3", "rd", "opcode"]
         let hi    = [31, 24, 19, 14, 11, 6]
         let lo    = [25, 20, 15, 12, 7, 0]
         let cols  = ["#6D5A8A", "#22c55e", "#22c55e", "#eab308", "#7C4DFF", "#ef4444"]

         let x = 30
         let per = 19
         for (let f = 0; f < 6; f++) {
            let nbits = hi[f] - lo[f] + 1
            let w = nbits * per
            let val = (instr >>> lo[f]) & ((1 << nbits) - 1)

            objs.push(new fabric.Rect({
               left: x, top: 80, width: w - 4, height: 62, rx: 4, ry: 4,
               fill: "#1A0533", stroke: cols[f], strokeWidth: 2
            }))
            objs.push(new fabric.Text(names[f], {
               left: x + w / 2 - 2, top: 96, originX: "center", originY: "center",
               fontSize: 11, fontWeight: "bold", fontFamily: "Courier New", fill: cols[f]
            }))
            objs.push(new fabric.Text("" + val, {
               left: x + w / 2 - 2, top: 118, originX: "center", originY: "center",
               fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#EDE7F6"
            }))
            objs.push(new fabric.Text("[" + hi[f] + ":" + lo[f] + "]", {
               left: x + w / 2 - 2, top: 154, originX: "center", originY: "center",
               fontSize: 9, fontFamily: "Courier New", fill: "#4A3060"
            }))
            x = x + w
         }

         objs.push(new fabric.Text("rs1, rs2 and rd sit in the SAME bits in every format", {
            left: 350, top: 196, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#B39DDB"
         }))
         objs.push(new fabric.Text("so the hardware can start reading registers", {
            left: 350, top: 216, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#B39DDB"
         }))
         objs.push(new fabric.Text("before it even knows what the instruction is", {
            left: 350, top: 236, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#B39DDB"
         }))

         objs.push(new fabric.Text("on a B-type, the rd and funct7 boxes are not really rd and funct7", {
            left: 350, top: 276, originX: "center",
            fontSize: 10, fontFamily: "Courier New", fill: "#4A3060"
         }))
         objs.push(new fabric.Text("those bits are pieces of the branch offset", {
            left: 350, top: 294, originX: "center",
            fontSize: 10, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
