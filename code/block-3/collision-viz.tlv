\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A piece falls down a 6-row grid and STOPS when the cell below it is
   // occupied by the pile. The collision check is a single AND: if the
   // piece would overlap the pile, the move is blocked.

   // Fixed pile sitting at the bottom two rows.
   $pile3[7:0] = 8'b00000000;
   $pile4[7:0] = 8'b00111100;
   $pile5[7:0] = 8'b01111110;

   // The falling piece shape.
   $piece[7:0] = 8'b00011000;

   // What is in the row just below the piece?
   $below[7:0] = (>>1$prow == 3'd2) ? $pile3 :
                 (>>1$prow == 3'd3) ? $pile4 :
                 (>>1$prow == 3'd4) ? $pile5 :
                                      8'b00000000;

   // COLLISION: does the piece overlap whatever is below it?
   $hit = | ($piece & $below);

   // At the floor (row 5) or a hit means the piece has landed.
   $landed = (>>1$prow == 3'd5) || $hit;

   // Advance the piece down until it lands, then restart at the top.
   $prow[2:0] = *reset  ? 3'd0 :
                $landed ? 3'd0 :
                          >>1$prow + 3'd1;

   `BOGUS_USE($piece $prow $pile3 $pile4 $pile5 $hit $landed)

   *passed = *cyc_cnt > 60;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 400, height: 340, fill: "#0D001A"},
      render() {
         let piece = '$piece'.asInt()
         let prow = '$prow'.asInt()
         let p3 = '$pile3'.asInt()
         let p4 = '$pile4'.asInt()
         let p5 = '$pile5'.asInt()
         let hit = '$hit'.asBool()
         let objs = []

         let pile = [0, 0, 0, p3, p4, p5]

         objs.push(new fabric.Text("COLLISION: STOP ON THE PILE", {
            left: 200, top: 18, originX: "center",
            fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let cell = 34
         let gx = 200 - (8 * cell) / 2
         let gy = 45

         for (let r = 0; r < 6; r++) {
            let rowBits = pile[r]
            if (r === prow) {
               rowBits = rowBits | piece
            }
            for (let c = 0; c < 8; c++) {
               let filled = (rowBits >> c) & 1
               let isPiece = (r === prow) && ((piece >> c) & 1)
               objs.push(new fabric.Rect({
                  left: gx + c * cell,
                  top: gy + r * cell,
                  width: cell - 3,
                  height: cell - 3,
                  rx: 3, ry: 3,
                  fill: isPiece ? "#eab308" : (filled ? "#7C4DFF" : "#1A0533"),
                  stroke: filled ? "#B39DDB" : "#2A1A40",
                  strokeWidth: 1
               }))
            }
         }

         let msg = hit ? "HIT! piece stops here" : "falling..."
         objs.push(new fabric.Text(msg, {
            left: 200, top: 262, originX: "center",
            fontSize: 12, fontFamily: "Courier New",
            fill: hit ? "#eab308" : "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
