\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // The program counter walking through a real RISC-V program.
   // Six instructions that add up the numbers 1 through 10.

   $pc[31:0] = *reset ? 32'd0 : (>>1$pc == 32'd20) ? 32'd0 : >>1$pc + 32'd4;
   $idx[2:0] = $pc[4:2];

   $instr[31:0] = ($idx == 3'd0) ? 32'h00000093 : ($idx == 3'd1) ? 32'h00100113 : ($idx == 3'd2) ? 32'h00B00193 : ($idx == 3'd3) ? 32'h002080B3 : ($idx == 3'd4) ? 32'h00110113 : 32'hFE314CE3;

   `BOGUS_USE($instr)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 560, height: 300, fill: "#0D001A"},
      render() {
         let pc = '$pc'.asInt()
         let objs = []

         let words = [0x00000093, 0x00100113, 0x00B00193, 0x002080B3, 0x00110113, 0xFE314CE3]
         let asm = ["addi x1, x0, 0", "addi x2, x0, 1", "addi x3, x0, 11", "add  x1, x1, x2", "addi x2, x2, 1", "blt  x2, x3, -8"]
         let note = ["sum = 0", "i = 1", "limit = 11", "sum = sum + i", "i = i + 1", "loop if i < 11"]

         objs.push(new fabric.Text("INSTRUCTION MEMORY", {
            left: 280, top: 16, originX: "center",
            fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         for (let i = 0; i < 6; i++) {
            let here = (pc === i * 4)
            let y = 46 + i * 38

            objs.push(new fabric.Rect({
               left: 40, top: y, width: 480, height: 32, rx: 4, ry: 4,
               fill: here ? "#3B1D6D" : "#1A0533",
               stroke: here ? "#eab308" : "#2A1A40",
               strokeWidth: here ? 2 : 1
            }))
            objs.push(new fabric.Text(here ? "PC >" : "", {
               left: 14, top: y + 16, originX: "left", originY: "center",
               fontSize: 12, fontWeight: "bold", fontFamily: "Courier New", fill: "#eab308"
            }))
            objs.push(new fabric.Text("" + (i * 4), {
               left: 60, top: y + 16, originX: "center", originY: "center",
               fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
            }))

            let h = words[i].toString(16).toUpperCase()
            while (h.length < 8) { h = "0" + h }
            objs.push(new fabric.Text("0x" + h, {
               left: 90, top: y + 16, originX: "left", originY: "center",
               fontSize: 13, fontFamily: "Courier New", fill: here ? "#EDE7F6" : "#6D5A8A"
            })) 
            objs.push(new fabric.Text(asm[i], {
               left: 200, top: y + 16, originX: "left", originY: "center",
               fontSize: 13, fontFamily: "Courier New", fill: here ? "#B39DDB" : "#4A3060"
            }))
            objs.push(new fabric.Text(note[i], {
               left: 360, top: y + 16, originX: "left", originY: "center",
               fontSize: 11, fontFamily: "Courier New", fill: here ? "#22c55e" : "#2A1A40"
            }))
         }

         objs.push(new fabric.Text("PC = " + pc + "    every instruction is 4 bytes, so the PC steps by 4", {
            left: 280, top: 282, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
