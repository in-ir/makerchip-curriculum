\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // STAGE 4: the payoff. When the bottom row fills completely it CLEARS,
   // the rows above drop down, and the line count goes up.
   // All detection reads the PREVIOUS cycle's board, so there are no
   // combinational loops.

   $tick = >>1$timer >= 4'd2;
   $timer[3:0] = *reset ? 4'd0 : $tick ? 4'd0 : >>1$timer + 4'd1;

   $piece[7:0] = >>1$spawn_lo ? 8'b11110000 : 8'b00001111;
   $spawn_lo = *reset ? 1'b0 : $lock ? !>>1$spawn_lo : >>1$spawn_lo;

   $below[7:0] = (>>1$prow == 4'd0) ? >>1$pile1 : (>>1$prow == 4'd1) ? >>1$pile2 : (>>1$prow == 4'd2) ? >>1$pile3 : (>>1$prow == 4'd3) ? >>1$pile4 : (>>1$prow == 4'd4) ? >>1$pile5 : (>>1$prow == 4'd5) ? >>1$pile6 : (>>1$prow == 4'd6) ? >>1$pile7 : (>>1$prow == 4'd7) ? >>1$pile8 : (>>1$prow == 4'd8) ? >>1$pile9 : 8'b0;

   $at_floor = >>1$prow == 4'd9;
   $hit_below = |($piece & $below);
   $landed = $at_floor || $hit_below;

   // A full bottom row triggers the clear.
   $clear = & >>1$pile9;
   $lock = $tick && $landed && !$clear;

   $prow[3:0] = *reset ? 4'd0 : $clear ? >>1$prow : $lock ? 4'd0 : ($tick && !$landed) ? >>1$prow + 4'd1 : >>1$prow;

   // On a clear, every row takes the value of the row above it.
   $pile0[7:0] = *reset ? 8'b0 : $clear ? 8'b0 : ($lock && >>1$prow == 4'd0) ? >>1$pile0 | $piece : >>1$pile0;
   $pile1[7:0] = *reset ? 8'b0 : $clear ? >>1$pile0 : ($lock && >>1$prow == 4'd1) ? >>1$pile1 | $piece : >>1$pile1;
   $pile2[7:0] = *reset ? 8'b0 : $clear ? >>1$pile1 : ($lock && >>1$prow == 4'd2) ? >>1$pile2 | $piece : >>1$pile2;
   $pile3[7:0] = *reset ? 8'b0 : $clear ? >>1$pile2 : ($lock && >>1$prow == 4'd3) ? >>1$pile3 | $piece : >>1$pile3;
   $pile4[7:0] = *reset ? 8'b0 : $clear ? >>1$pile3 : ($lock && >>1$prow == 4'd4) ? >>1$pile4 | $piece : >>1$pile4;
   $pile5[7:0] = *reset ? 8'b0 : $clear ? >>1$pile4 : ($lock && >>1$prow == 4'd5) ? >>1$pile5 | $piece : >>1$pile5;
   $pile6[7:0] = *reset ? 8'b0 : $clear ? >>1$pile5 : ($lock && >>1$prow == 4'd6) ? >>1$pile6 | $piece : >>1$pile6;
   $pile7[7:0] = *reset ? 8'b0 : $clear ? >>1$pile6 : ($lock && >>1$prow == 4'd7) ? >>1$pile7 | $piece : >>1$pile7;
   $pile8[7:0] = *reset ? 8'b0 : $clear ? >>1$pile7 : ($lock && >>1$prow == 4'd8) ? >>1$pile8 | $piece : >>1$pile8;
   $pile9[7:0] = *reset ? 8'b0 : $clear ? >>1$pile8 : ($lock && >>1$prow == 4'd9) ? >>1$pile9 | $piece : >>1$pile9;

   $score[7:0] = *reset ? 8'd0 : $clear ? >>1$score + 8'd1 : >>1$score;

   `BOGUS_USE($piece $prow $pile0 $pile1 $pile2 $pile3 $pile4 $pile5 $pile6 $pile7 $pile8 $pile9 $lock $clear $score)

   *passed = *cyc_cnt > 300;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 340, height: 470, fill: "#0D001A"},
      render() {
         let piece = '$piece'.asInt()
         let prow = '$prow'.asInt()
         let score = '$score'.asInt()
         let q0 = '$pile0'.asInt()
         let q1 = '$pile1'.asInt()
         let q2 = '$pile2'.asInt()
         let q3 = '$pile3'.asInt()
         let q4 = '$pile4'.asInt()
         let q5 = '$pile5'.asInt()
         let q6 = '$pile6'.asInt()
         let q7 = '$pile7'.asInt()
         let q8 = '$pile8'.asInt()
         let q9 = '$pile9'.asInt()
         let pile = [q0, q1, q2, q3, q4, q5, q6, q7, q8, q9]
         let objs = []

         objs.push(new fabric.Text("TETRIS - STAGE 4", {
            left: 170, top: 12, originX: "center",
            fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))
         objs.push(new fabric.Text("lines: " + score, {
            left: 170, top: 30, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#eab308"
         }))

         let cell = 34
         let gx = 170 - (8 * cell) / 2
         let gy = 44

         for (let r = 0; r < 10; r++) {
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
