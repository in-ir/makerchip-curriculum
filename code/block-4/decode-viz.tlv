\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // The decoder in action. Eight different instructions cycle past and
   // the control signals light up one at a time.

   $slow[2:0] = *reset ? 3'd0 : (>>1$slow == 3'd5) ? 3'd0 : >>1$slow + 3'd1;
   $step = >>1$slow == 3'd5;
   $sel[2:0] = *reset ? 3'd0 : ($step && >>1$sel == 3'd7) ? 3'd0 : $step ? >>1$sel + 3'd1 : >>1$sel;

   $instr[31:0] = ($sel == 3'd0) ? 32'h00B00193 : ($sel == 3'd1) ? 32'h002080B3 : ($sel == 3'd2) ? 32'h402081B3 : ($sel == 3'd3) ? 32'h0020F2B3 : ($sel == 3'd4) ? 32'h0020C2B3 : ($sel == 3'd5) ? 32'h0000A303 : ($sel == 3'd6) ? 32'h0020A023 : 32'hFE314CE3;

   $opcode[6:0] = $instr[6:0];
   $funct3[2:0] = $instr[14:12];
   $funct7[6:0] = $instr[31:25];

   // What KIND of instruction is this? One comparison per opcode.
   $is_r_type = $opcode == 7'b0110011;
   $is_i_alu  = $opcode == 7'b0010011;
   $is_load   = $opcode == 7'b0000011;
   $is_store  = $opcode == 7'b0100011;
   $is_branch = $opcode == 7'b1100011;

   // Which exact instruction? Opcode narrows it down, funct3 and funct7
   // finish the job.
   $is_add  = $is_r_type && ($funct3 == 3'b000) && ($funct7 == 7'b0000000);
   $is_sub  = $is_r_type && ($funct3 == 3'b000) && ($funct7 == 7'b0100000);
   $is_xor  = $is_r_type && ($funct3 == 3'b100);
   $is_or   = $is_r_type && ($funct3 == 3'b110);
   $is_and  = $is_r_type && ($funct3 == 3'b111);
   $is_addi = $is_i_alu  && ($funct3 == 3'b000);
   $is_lw   = $is_load   && ($funct3 == 3'b010);
   $is_sw   = $is_store  && ($funct3 == 3'b010);
   $is_beq  = $is_branch && ($funct3 == 3'b000);
   $is_bne  = $is_branch && ($funct3 == 3'b001);
   $is_blt  = $is_branch && ($funct3 == 3'b100);

   // The two signals that steer the datapath.
   $rf_wr   = $is_r_type || $is_i_alu || $is_load;
   $use_imm = $is_i_alu || $is_load || $is_store;

   // Bundled for the visualization only. The individual signals above are
   // what the datapath actually uses.
   $onehot[10:0] = {$is_blt, $is_bne, $is_beq, $is_sw, $is_lw, $is_addi, $is_and, $is_or, $is_xor, $is_sub, $is_add};

   `BOGUS_USE($onehot $rf_wr $use_imm)

   *passed = *cyc_cnt > 200;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 700, height: 340, fill: "#0D001A"},
      render() {
         let instr = '$instr'.asInt()
         let sel = '$sel'.asInt()
         let onehot = '$onehot'.asInt()
         let rfwr = '$rf_wr'.asBool()
         let useimm = '$use_imm'.asBool()
         let objs = []

         let asm = ["addi x3, x0, 11", "add x1, x1, x2", "sub x3, x1, x2", "and x5, x1, x2", "xor x5, x1, x2", "lw x6, 0(x1)", "sw x2, 0(x1)", "blt x2, x3, -8"]

         let h = instr.toString(16).toUpperCase()
         while (h.length < 8) { h = "0" + h }

         objs.push(new fabric.Text("0x" + h + "     " + asm[sel], {
            left: 350, top: 22, originX: "center",
            fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#EDE7F6"
         }))

         let op = instr & 0x7F
         let f3 = (instr >>> 12) & 7
         let f7 = (instr >>> 25) & 0x7F
         let ob = op.toString(2); while (ob.length < 7) { ob = "0" + ob }
         let f3b = f3.toString(2); while (f3b.length < 3) { f3b = "0" + f3b }
         let f7b = f7.toString(2); while (f7b.length < 7) { f7b = "0" + f7b }

         objs.push(new fabric.Text("opcode " + ob + "     funct3 " + f3b + "     funct7 " + f7b, {
            left: 350, top: 50, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#4A3060"
         }))

         objs.push(new fabric.Text("CONTROL SIGNALS", {
            left: 350, top: 82, originX: "center",
            fontSize: 12, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let names = ["is_add", "is_sub", "is_xor", "is_or", "is_and", "is_addi", "is_lw", "is_sw", "is_beq", "is_bne", "is_blt"]
         for (let i = 0; i < 11; i++) {
            let on = (onehot >>> i) & 1
            let col = i % 6
            let row = (i - col) / 6
            let x = 60 + col * 100
            let y = 106 + row * 46
            objs.push(new fabric.Rect({
               left: x, top: y, width: 88, height: 34, rx: 5, ry: 5,
               fill: on ? "#3B6D11" : "#1A0533",
               stroke: on ? "#22c55e" : "#2A1A40",
               strokeWidth: on ? 2 : 1
            }))
            objs.push(new fabric.Text(names[i], {
               left: x + 44, top: y + 17, originX: "center", originY: "center",
               fontSize: 11, fontWeight: on ? "bold" : "normal", fontFamily: "Courier New",
               fill: on ? "#ffffff" : "#4A3060"
            }))
         }

         objs.push(new fabric.Text("DATAPATH CONTROL", {
            left: 350, top: 218, originX: "center",
            fontSize: 12, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let dn = ["rf_wr", "use_imm"]
         let dv = [rfwr, useimm]
         let dd = ["write a register?", "second operand is a constant?"]
         for (let i = 0; i < 2; i++) {
            let y = 242 + i * 40
            objs.push(new fabric.Rect({
               left: 140, top: y, width: 110, height: 30, rx: 5, ry: 5,
               fill: dv[i] ? "#3B3312" : "#1A0533",
               stroke: dv[i] ? "#eab308" : "#2A1A40",
               strokeWidth: dv[i] ? 2 : 1
            }))
            objs.push(new fabric.Text(dn[i] + " = " + (dv[i] ? "1" : "0"), {
               left: 195, top: y + 15, originX: "center", originY: "center",
               fontSize: 11, fontFamily: "Courier New", fill: dv[i] ? "#eab308" : "#4A3060"
            }))
            objs.push(new fabric.Text(dd[i], {
               left: 268, top: y + 15, originX: "left", originY: "center",
               fontSize: 10, fontFamily: "Courier New", fill: "#4A3060"
            }))
         }

         return objs
      }
\SV
   endmodule
