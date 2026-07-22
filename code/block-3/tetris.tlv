\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // TETRIS - the complete self-playing game, 8 wide x 10 tall.
   // Every detection signal reads the PREVIOUS cycle's board state, which
   // keeps the logic free of combinational loops.

   $fall_limit[3:0] = (>>1$score >= 8'd6) ? 4'd1 : (>>1$score >= 8'd3) ? 4'd2 : 4'd3;
   $tick = >>1$timer >= $fall_limit;
   $timer[3:0] = *reset ? 4'd0 : $tick ? 4'd0 : >>1$timer + 4'd1;

   $piece[7:0] = >>1$spawn_lo ? 8'b11110000 : 8'b00001111;

   $below[7:0] = (>>1$prow == 4'd0) ? >>1$pile1 : (>>1$prow == 4'd1) ? >>1$pile2 : (>>1$prow == 4'd2) ? >>1$pile3 : (>>1$prow == 4'd3) ? >>1$pile4 : (>>1$prow == 4'd4) ? >>1$pile5 : (>>1$prow == 4'd5) ? >>1$pile6 : (>>1$prow == 4'd6) ? >>1$pile7 : (>>1$prow == 4'd7) ? >>1$pile8 : (>>1$prow == 4'd8) ? >>1$pile9 : 8'b0;

   $at_floor = >>1$prow == 4'd9;
   $hit_below = |($piece & $below);
   $landed = $at_floor || $hit_below;
   $clear = & >>1$pile9;
   $lock = $tick && $landed && !$clear;

   $prow[3:0] = *reset ? 4'd0 : $clear ? >>1$prow : $lock ? 4'd0 : ($tick && !$landed) ? >>1$prow + 4'd1 : >>1$prow;

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

   $spawn_lo = *reset ? 1'b0 : $lock ? !>>1$spawn_lo : >>1$spawn_lo;
   $score[7:0] = *reset ? 8'd0 : $clear ? >>1$score + 8'd1 : >>1$score;

   `BOGUS_USE($piece $prow $pile0 $pile1 $pile2 $pile3 $pile4 $pile5 $pile6 $pile7 $pile8 $pile9 $lock $clear $score $tick)

   *passed = *cyc_cnt > 400;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 360, height: 490, fill: "#0D001A"},
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

         objs.push(new fabric.Text("T E T R I S", {
            left: 180, top: 12, originX: "center",
            fontSize: 18, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))
         objs.push(new fabric.Text("lines cleared: " + score, {
            left: 180, top: 34, originX: "center",
            fontSize: 13, fontFamily: "Courier New", fill: "#eab308"
         }))

         let cell = 36
         let gx = 180 - (8 * cell) / 2
         let gy = 50

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
