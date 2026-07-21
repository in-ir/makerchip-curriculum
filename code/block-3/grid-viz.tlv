\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A 4-row x 8-column grid. A block falls down the top rows and
   // lands on a fixed pile at the bottom. Each row is 8 bits; bit c
   // is column c (1 = filled).
   $drop_row[1:0] = *cyc_cnt[1:0];

   $row0[7:0] = ($drop_row == 2'd0) ? 8'b00011000 : 8'b00000000;
   $row1[7:0] = ($drop_row == 2'd1) ? 8'b00011000 : 8'b00000000;
   $row2[7:0] = 8'b00111100;
   $row3[7:0] = 8'b01111110;

   `BOGUS_USE($row0 $row1 $row2 $row3)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 400, height: 300, fill: "#0D001A"},
      render() {
         let r0 = '$row0'.asInt()
         let r1 = '$row1'.asInt()
         let r2 = '$row2'.asInt()
         let r3 = '$row3'.asInt()
         let rows = [r0, r1, r2, r3]
         let objs = []

         objs.push(new fabric.Text("THE GRID", {
            left: 200, top: 18, originX: "center",
            fontSize: 16, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let cell = 30
         let gx = 200 - (8 * cell) / 2
         let gy = 50

         for (let r = 0; r < 4; r++) {
            for (let c = 0; c < 8; c++) {
               let filled = (rows[r] >> c) & 1
               objs.push(new fabric.Rect({
                  left: gx + c * cell,
                  top: gy + r * cell,
                  width: cell - 3,
                  height: cell - 3,
                  rx: 3, ry: 3,
                  fill: filled ? "#7C4DFF" : "#1A0533",
                  stroke: filled ? "#B39DDB" : "#2A1A40",
                  strokeWidth: 1
               }))
            }
         }

         objs.push(new fabric.Text("each row is 8 bits  ·  bit c = column c", {
            left: 200, top: 195, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         let b0 = r0.toString(2)
         while (b0.length < 8) { b0 = "0" + b0 }
         let b1 = r1.toString(2)
         while (b1.length < 8) { b1 = "0" + b1 }
         objs.push(new fabric.Text("row0 = " + b0 + "   row1 = " + b1, {
            left: 200, top: 225, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#B39DDB"
         }))

         return objs
      }
\SV
   endmodule
