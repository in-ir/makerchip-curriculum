\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // STAGE 3: the piece now MOVES SIDEWAYS as it falls, steered by an
   // auto-player toward a target column, but blocked by the walls. This
   // is the collision guard from Module 3.5 applied to left/right motion.

   $tick = >>1$timer == 4'd3;
   $timer[3:0] = *reset ? 4'd0 : $tick ? 4'd0 : >>1$timer + 4'd1;

   // A 2-wide piece. Its horizontal position is $px (leftmost column).
   $shape[7:0] = 8'b00000011;
   $piece[7:0] = $shape << $px;

   // Auto-player target column, cycles across the board on each spawn.
   $target[2:0] = >>1$target;

   // TODO: move the piece toward the target, but NOT through the wall.
   //   Moving right (px+1) is only allowed if the piece isn't already at
   //   the right edge. A 2-wide piece at px can go right while px < 6.
   //   $want_right = $px < $target;
   //   $can_right  = $px < 3'd6;
   //   $px[2:0] = *reset ? 3'd0 :
   //              !$tick ? >>1$px :
   //              ($want_right && $can_right) ? >>1$px + 3'd1 :
   //              >>1$px;
   $px[2:0] = 3'd0;

   // Falling (given).
   $prow[3:0] = *reset ? 4'd0 : !$tick ? >>1$prow : (>>1$prow == 4'd9) ? 4'd0 : >>1$prow + 4'd1;

   `BOGUS_USE($piece $prow $px $target)

   *passed = *cyc_cnt > 150;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 340, height: 440, fill: "#0D001A"},
      render() {
         let piece = '$piece'.asInt()
         let prow = '$prow'.asInt()
         let objs = []

         objs.push(new fabric.Text("TETRIS - STAGE 3", {
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
