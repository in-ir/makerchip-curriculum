\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // All six gates responding to the same two inputs at once. The inputs
   // cycle through every combination so you can watch each gate's rule.

   $step[1:0] = *reset ? 2'd0 : (>>1$slow == 3'd3) ? >>1$step + 2'd1 : >>1$step;
   $slow[2:0] = *reset ? 3'd0 : (>>1$slow == 3'd3) ? 3'd0 : >>1$slow + 3'd1;

   $a = $step[1];
   $b = $step[0];

   $o_and  = $a && $b;
   $o_or   = $a || $b;
   $o_xor  = $a ^ $b;
   $o_nand = !($a && $b);
   $o_nor  = !($a || $b);
   $o_not  = !$a;

   `BOGUS_USE($o_and $o_or $o_xor $o_nand $o_nor $o_not)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 640, height: 380, fill: "#0D001A"},
      render() {
         let a = '$a'.asInt()
         let b = '$b'.asInt()
         let oand = '$o_and'.asInt()
         let oor = '$o_or'.asInt()
         let oxor = '$o_xor'.asInt()
         let onand = '$o_nand'.asInt()
         let onor = '$o_nor'.asInt()
         let onot = '$o_not'.asInt()
         let objs = []

         objs.push(new fabric.Text("LOGIC GATES", {
            left: 320, top: 22, originX: "center",
            fontSize: 17, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         objs.push(new fabric.Text("inputs", {
            left: 320, top: 54, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#4A3060"
         }))
         objs.push(new fabric.Rect({
            left: 250, top: 70, width: 74, height: 40, rx: 6, ry: 6,
            fill: a ? "#3B6D11" : "#1A0533", stroke: a ? "#22c55e" : "#2A1A40", strokeWidth: 2
         }))
         objs.push(new fabric.Text("A = " + a, {
            left: 287, top: 90, originX: "center", originY: "center",
            fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: a ? "#ffffff" : "#6D5A8A"
         }))
         objs.push(new fabric.Rect({
            left: 332, top: 70, width: 74, height: 40, rx: 6, ry: 6,
            fill: b ? "#3B6D11" : "#1A0533", stroke: b ? "#22c55e" : "#2A1A40", strokeWidth: 2
         }))
         objs.push(new fabric.Text("B = " + b, {
            left: 369, top: 90, originX: "center", originY: "center",
            fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: b ? "#ffffff" : "#6D5A8A"
         }))

         let name = ["AND", "OR", "XOR", "NAND", "NOR", "NOT"]
         let val  = [oand, oor, oxor, onand, onor, onot]
         let rule = ["A and B", "A or B", "A differs B", "not(A and B)", "not(A or B)", "not A"]

         for (let i = 0; i < 6; i++) {
            let col = i % 3
            let row = (i - col) / 3
            let x = 40 + col * 200
            let y = 150 + row * 100
            let on = val[i]
            objs.push(new fabric.Rect({
               left: x, top: y, width: 176, height: 78, rx: 8, ry: 8,
               fill: "#1A0533", stroke: on ? "#eab308" : "#3B2A55", strokeWidth: 2
            }))
            objs.push(new fabric.Text(name[i], {
               left: x + 20, top: y + 26, originX: "left", originY: "center",
               fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#B39DDB"
            }))
            objs.push(new fabric.Text(rule[i], {
               left: x + 20, top: y + 52, originX: "left", originY: "center",
               fontSize: 10, fontFamily: "Courier New", fill: "#4A3060"
            }))
            objs.push(new fabric.Rect({
               left: x + 118, top: y + 20, width: 40, height: 40, rx: 20, ry: 20,
               fill: on ? "#eab308" : "#0D001A", stroke: on ? "#eab308" : "#3B2A55", strokeWidth: 2
            }))
            objs.push(new fabric.Text("" + on, {
               left: x + 138, top: y + 40, originX: "center", originY: "center",
               fontSize: 18, fontWeight: "bold", fontFamily: "Courier New", fill: on ? "#0D001A" : "#4A3060"
            }))
         }

         objs.push(new fabric.Text("a lit output is 1. watch which gates fire for each A, B pair.", {
            left: 320, top: 366, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
