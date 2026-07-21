\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // STAGE 1: a single piece falls down an 8-wide, 10-tall board.
   // No collision yet, it just falls and wraps back to the top.
   // A difficulty timer controls how fast it falls: it drops one row
   // each time the timer ticks.

   // The fall timer: counts up, and "ticks" when it reaches the speed limit.
   $fall_speed[3:0] = 4'd4;
   $tick = >>1$timer == $fall_speed;
   $timer[3:0] = *reset ? 4'd0 : $tick ? 4'd0 : >>1$timer + 4'd1;

   // The piece: a 3-wide block sitting in columns 2,3,4.
   $piece[7:0] = 8'b00011100;

   // TODO: make the piece fall. On each $tick, move it down one row.
   //   When it passes the bottom (row 9), wrap back to row 0.
   //   $prow[3:0] = *reset ? 4'd0 :
   //                !$tick ? >>1$prow :
   //                (>>1$prow == 4'd9) ? 4'd0 :
   //                >>1$prow + 4'd1;
   $prow[3:0] = 4'd0;

   `BOGUS_USE($piece $prow $tick)

   *passed = *cyc_cnt > 100;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 340, height: 440, fill: "#0D001A"},
      render() {
         let piece = '$piece'.asInt()
         let prow = '$prow'.asInt()
         let objs = []

         objs.push(new fabric.Text("TETRIS - STAGE 1", {
            left: 170, top: 14, originX: "center",
            fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let cell = 34
         let gx = 170 - (8 * cell) / 2
         let gy = 36

         for (let r = 0; r < 10; r++) {
            for (let c = 0; c < 8; c++) {
               let pieceBit = (r === prow) && ((piece >> c) & 1)
               let fillColor = pieceBit ? "#eab308" : "#1A0533"
               let strokeColor = pieceBit ? "#B39DDB" : "#2A1A40"
               objs.push(new fabric.Rect({
                  left: gx + c * cell,
                  top: gy + r * cell,
                  width: cell - 3,
                  height: cell - 3,
                  rx: 2, ry: 2,
                  fill: fillColor,
                  stroke: strokeColor,
                  strokeWidth: 1
               }))
            }
         }

         return objs
      }
\SV
   endmodule
