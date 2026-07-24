\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // STAGE 3: the piece now MOVES SIDEWAYS as it falls, steered by an
   // auto-player toward a target column, but blocked by the walls. This
   // is the collision guard from Module 3.5 applied to left/right motion.

   $tick = >>1$timer >= 4'd3;
   $timer[3:0] = *reset ? 4'd0 : $tick ? 4'd0 : >>1$timer + 4'd1;

   // A 2-wide piece. Its horizontal position is $px (its leftmost column).
   $shape[7:0] = 8'b00000011;
   $piece[7:0] = $shape << $px;

   // Falling (given). The piece wraps to the top when it passes the floor.
   $spawn = $tick && (>>1$prow == 4'd9);
   $prow[3:0] = *reset ? 4'd0 : !$tick ? >>1$prow : (>>1$prow == 4'd9) ? 4'd0 : >>1$prow + 4'd1;

   // The auto-player picks a new target column each time a piece spawns.
   $target[2:0] = *reset ? 3'd5 : $spawn ? >>1$target + 3'd2 : >>1$target;

   // Does the piece want to move, and is it allowed to?
   $want_right = >>1$px < $target;
   $want_left  = >>1$px > $target;

   // TODO 1: the wall checks.
   //   The piece is 2 cells wide, so its leftmost column $px can never go
   //   past 6, or the piece would hang off the right edge. And it can
   //   never go below 0 on the left.
   //   Set $can_right to say whether there is room to move right,
   //   and $can_left to say whether there is room to move left.
   $can_right = 1'b0;
   $can_left  = 1'b0;

   // TODO 2: the move guard.
   //   Complete $px so that it:
   //     - starts at column 0 on reset
   //     - only moves on a $tick (it holds between ticks)
   //     - steps one column toward $target, but ONLY if the matching
   //       wall check says there is room
   //     - otherwise holds its position
   //   This is the same "take the move only if it is legal" pattern
   //   you built in Module 3.5, applied sideways.
   $px[2:0] = 3'd0;

   `BOGUS_USE($piece $prow $px $target $want_right $want_left $can_right $can_left)

   *passed = *cyc_cnt > 150;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 340, height: 470, fill: "#0D001A"},
      render() {
         let piece = '$piece'.asInt()
         let prow = '$prow'.asInt()
         let target = '$target'.asInt()
         let objs = []

         objs.push(new fabric.Text("TETRIS - STAGE 3", {
            left: 170, top: 12, originX: "center",
            fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))
         objs.push(new fabric.Text("target column: " + target, {
            left: 170, top: 30, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#eab308"
         }))

         let cell = 34
         let gx = 170 - (8 * cell) / 2
         let gy = 44

         for (let r = 0; r < 10; r++) {
            for (let c = 0; c < 8; c++) {
               let pieceBit = (r === prow) && ((piece >> c) & 1)
               let isTarget = (c === target)
               let fillColor = "#1A0533"
               if (pieceBit) { fillColor = "#eab308" }
               let strokeColor = pieceBit ? "#B39DDB" : (isTarget ? "#4A3060" : "#2A1A40")
               objs.push(new fabric.Rect({
                  left: gx + c * cell,
                  top: gy + r * cell,
                  width: cell - 3,
                  height: cell - 3,
                  rx: 2, ry: 2,
                  fill: fillColor,
                  stroke: strokeColor,
                  strokeWidth: isTarget ? 2 : 1
               }))
            }
         }

         return objs
      }
\SV
   endmodule
