\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Instructions flowing through a 3-stage pipeline. At any moment three
   // different instructions are in flight, each in a different stage.
   // This is why a pipeline is faster: the hardware is never idle.

   $t[3:0] = *reset ? 4'd0 : (>>1$t == 4'd9) ? 4'd0 : >>1$t + 4'd1;

   `BOGUS_USE($t)

   *passed = *cyc_cnt > 60;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 640, height: 340, fill: "#0D001A"},
      render() {
         let t = '$t'.asInt()
         let objs = []

         objs.push(new fabric.Text("PIPELINE: three instructions in flight at once", {
            left: 320, top: 20, originX: "center",
            fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))
         objs.push(new fabric.Text("cycle " + t, {
            left: 320, top: 44, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#eab308"
         }))

         let stages = ["FETCH", "DECODE", "EXECUTE"]
         let scol = ["#eab308", "#7C4DFF", "#22c55e"]

         for (let s = 0; s < 3; s++) {
            let y = 80 + s * 70
            objs.push(new fabric.Rect({
               left: 40, top: y, width: 110, height: 50, rx: 6, ry: 6,
               fill: "#1A0533", stroke: scol[s], strokeWidth: 2
            }))
            objs.push(new fabric.Text(stages[s], {
               left: 95, top: y + 25, originX: "center", originY: "center",
               fontSize: 12, fontWeight: "bold", fontFamily: "Courier New", fill: scol[s]
            }))

            let instrNum = t - s
            if (instrNum >= 0) {
               let slot = instrNum % 6
               objs.push(new fabric.Rect({
                  left: 180 + slot * 70, top: y + 8, width: 60, height: 34, rx: 5, ry: 5,
                  fill: scol[s], stroke: "#ffffff", strokeWidth: 1
               }))
               objs.push(new fabric.Text("i" + instrNum, {
                  left: 210 + slot * 70, top: y + 25, originX: "center", originY: "center",
                  fontSize: 12, fontWeight: "bold", fontFamily: "Courier New", fill: "#0D001A"
               }))
            }
         }

         objs.push(new fabric.Text("each instruction moves down one stage per cycle", {
            left: 320, top: 300, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))
         objs.push(new fabric.Text("look at any single cycle: all three stages are busy", {
            left: 320, top: 320, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
