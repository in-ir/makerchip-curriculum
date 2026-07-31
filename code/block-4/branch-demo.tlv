\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Branches make the PC jump. Until now the PC only ever did +4.
   // A branch can instead add a signed offset, sending execution
   // backwards (a loop) or forwards (skip past something).

   $pc[31:0] = *reset ? 32'd0 : $take ? >>1$pc + $offset : >>1$pc + 32'd4;
   $idx[2:0] = >>1$pc[4:2];

   // A tiny program with a backward branch, forming a loop.
   //   0: addi x1, x1, 1
   //   4: blt  x1, x2, -4   (loop while x1 < 3)
   //   8: (fallthrough)
   $instr[31:0] = ($idx == 3'd0) ? 32'h00108093 : ($idx == 3'd1) ? 32'hFE20CEE3 : 32'h00000013;

   $opcode[6:0] = $instr[6:0];
   $funct3[2:0] = $instr[14:12];
   $is_branch = $opcode == 7'b1100011;

   // The branch offset, sign-extended from the scrambled B-type bits.
   $offset[31:0] = $instr[31] ? {19'h7FFFF, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0} : {19'd0, $instr[31], $instr[7], $instr[30:25], $instr[11:8], 1'b0};

   $x1[31:0] = *reset ? 32'd0 : ($idx == 3'd0) ? >>1$x1 + 32'd1 : >>1$x1;
   $x2[31:0] = *reset ? 32'd3 : 32'd3;

   $take = $is_branch && (>>1$x1 < $x2);

   `BOGUS_USE($x1 $take $offset)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 600, height: 320, fill: "#0D001A"},
      render() {
         let pc = '$pc'.asInt()
         let x1 = '$x1'.asInt()
         let take = '$take'.asBool()
         let objs = []

         let asm = ["addi x1, x1, 1", "blt x1, x2, -4", "(done)"]
         let addr = [0, 4, 8]

         objs.push(new fabric.Text("BRANCH: the PC can jump backwards", {
            left: 300, top: 20, originX: "center",
            fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))
         objs.push(new fabric.Text("x1 = " + x1 + "     looping while x1 < 3", {
            left: 300, top: 44, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#eab308"
         }))

         for (let i = 0; i < 3; i++) {
            let here = (pc === addr[i])
            let y = 78 + i * 46
            objs.push(new fabric.Rect({
               left: 150, top: y, width: 300, height: 38, rx: 5, ry: 5,
               fill: here ? "#3B1D6D" : "#1A0533",
               stroke: here ? "#eab308" : "#2A1A40",
               strokeWidth: here ? 2 : 1
            }))
            objs.push(new fabric.Text("" + addr[i], {
               left: 170, top: y + 19, originX: "center", originY: "center",
               fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
            }))
            objs.push(new fabric.Text(asm[i], {
               left: 210, top: y + 19, originX: "left", originY: "center",
               fontSize: 13, fontFamily: "Courier New", fill: here ? "#EDE7F6" : "#6D5A8A"
            }))
            if (here) {
               objs.push(new fabric.Text("PC", {
                  left: 130, top: y + 19, originX: "center", originY: "center",
                  fontSize: 12, fontWeight: "bold", fontFamily: "Courier New", fill: "#eab308"
               }))
            }
         }

         if (take) {
            objs.push(new fabric.Text("branch taken: jumping back up", {
               left: 300, top: 232, originX: "center",
               fontSize: 12, fontWeight: "bold", fontFamily: "Courier New", fill: "#22c55e"
            }))
         } else {
            objs.push(new fabric.Text("branch not taken: falling through", {
               left: 300, top: 232, originX: "center",
               fontSize: 12, fontFamily: "Courier New", fill: "#4A3060"
            }))
         }

         objs.push(new fabric.Text("a backward jump is a loop. a forward jump skips ahead.", {
            left: 300, top: 268, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
