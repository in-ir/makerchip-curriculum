\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $piece[7:0] = 8'b00011000;
   $pile4[7:0] = 8'b00111100;
   $pile5[7:0] = 8'b01111110;

   $below[7:0] = (>>1$prow == 3'd3) ? $pile4 : (>>1$prow == 3'd4) ? $pile5 : 8'b0;
   $hit = |($piece & $below);
   $at_floor = >>1$prow == 3'd5;
   $landed = $at_floor || $hit;
   $resetting = >>1$landed;
   $prow[2:0] = *reset ? 3'd0 : $resetting ? 3'd0 : $landed ? >>1$prow : >>1$prow + 3'd1;

   `BOGUS_USE($piece $prow $pile4 $pile5 $hit $landed $resetting)

   *passed = *cyc_cnt > 60;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 400, height: 340, fill: "#0D001A"},
      render() {
         let piece = '$piece'.asInt()
         let prow = '$prow'.asInt()
         let p4 = '$pile4'.asInt()
         let p5 = '$pile5'.asInt()
         let hit = '$hit'.asBool()
         let pile = [0, 0, 0, 0, p4, p5]
         let objs = []

         objs.push(new fabric.Text("COLLISION: STOP ON THE PILE", {
            left: 200, top: 18, originX: "center",
            fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let cell = 34
         let gx = 200 - (8 * cell) / 2
         let gy = 45

         for (let r = 0; r < 6; r++) {
            for (let c = 0; c < 8; c++) {
               let pileBit = (pile[r] >> c) & 1
               let pieceBit = (r === prow) && ((piece >> c) & 1)
               let fillColor = "#1A0533"
               if (pieceBit) { fillColor = "#eab308" }
               else if (pileBit) { fillColor = "#7C4DFF" }
               let strokeColor = (pileBit || pieceBit) ? "#B39DDB" : "#2A1A40"
               objs.push(new fabric.Rect({
                  left: gx + c * cell,
                  top: gy + r * cell,
                  width: cell - 3,
                  height: cell - 3,
                  rx: 3, ry: 3,
                  fill: fillColor,
                  stroke: strokeColor,
                  strokeWidth: 1
               }))
            }
         }

         let msg = hit ? "HIT! piece stops here" : "falling..."
         let msgColor = hit ? "#eab308" : "#4A3060"
         objs.push(new fabric.Text(msg, {
            left: 200, top: 262, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: msgColor
         }))

         return objs
      }
\SV
   endmodule
