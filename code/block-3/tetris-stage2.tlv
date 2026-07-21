\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // STAGE 2: the piece now LOCKS when it lands. It falls until the row
   // below is blocked (by the floor or the pile), then merges into the
   // pile and a new piece spawns at the top. Watch the pile grow.

   $tick = >>1$timer == 4'd3;
   $timer[3:0] = *reset ? 4'd0 : $tick ? 4'd0 : >>1$timer + 4'd1;

   // The piece shape, shifted a bit each spawn so the pile builds unevenly.
   $piece[7:0] = 8'b00000111 << >>1$spawn_col[2:0];
   $spawn_col[2:0] = *reset ? 3'd0 : $lock ? >>1$spawn_col + 3'd2 : >>1$spawn_col;

   // The pile: 10 row registers. A row gets the piece OR'd in when the
   // piece locks at that row.
   $pile0[7:0] = *reset ? 8'b0 : ($lock && $prow == 4'd0) ? >>1$pile0 | $piece : >>1$pile0;
   $pile1[7:0] = *reset ? 8'b0 : ($lock && $prow == 4'd1) ? >>1$pile1 | $piece : >>1$pile1;
   $pile2[7:0] = *reset ? 8'b0 : ($lock && $prow == 4'd2) ? >>1$pile2 | $piece : >>1$pile2;
   $pile3[7:0] = *reset ? 8'b0 : ($lock && $prow == 4'd3) ? >>1$pile3 | $piece : >>1$pile3;
   $pile4[7:0] = *reset ? 8'b0 : ($lock && $prow == 4'd4) ? >>1$pile4 | $piece : >>1$pile4;
   $pile5[7:0] = *reset ? 8'b0 : ($lock && $prow == 4'd5) ? >>1$pile5 | $piece : >>1$pile5;
   $pile6[7:0] = *reset ? 8'b0 : ($lock && $prow == 4'd6) ? >>1$pile6 | $piece : >>1$pile6;
   $pile7[7:0] = *reset ? 8'b0 : ($lock && $prow == 4'd7) ? >>1$pile7 | $piece : >>1$pile7;
   $pile8[7:0] = *reset ? 8'b0 : ($lock && $prow == 4'd8) ? >>1$pile8 | $piece : >>1$pile8;
   $pile9[7:0] = *reset ? 8'b0 : ($lock && $prow == 4'd9) ? >>1$pile9 | $piece : >>1$pile9;

   // What's in the row just below the piece?
   $below[7:0] = ($prow == 4'd0) ? $pile1 : ($prow == 4'd1) ? $pile2 : ($prow == 4'd2) ? $pile3 : ($prow == 4'd3) ? $pile4 : ($prow == 4'd4) ? $pile5 : ($prow == 4'd5) ? $pile6 : ($prow == 4'd6) ? $pile7 : ($prow == 4'd7) ? $pile8 : ($prow == 4'd8) ? $pile9 : 8'b0;

   // Landed if at the floor OR the piece would overlap what's below.
   $at_floor = $prow == 4'd9;
   $hit_below = |($piece & $below);
   $landed = $at_floor || $hit_below;

   // Lock happens on a tick when landed. New piece resets row to top.
   $lock = $tick && $landed;
   $prow[3:0] = *reset ? 4'd0 : $lock ? 4'd0 : ($tick && !$landed) ? >>1$prow + 4'd1 : >>1$prow;

   `BOGUS_USE($piece $prow $pile0 $pile1 $pile2 $pile3 $pile4 $pile5 $pile6 $pile7 $pile8 $pile9 $lock $landed)

   *passed = *cyc_cnt > 200;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 340, height: 440, fill: "#0D001A"},
      render() {
         let piece = '$piece'.asInt()
         let prow = '$prow'.asInt()
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

         objs.push(new fabric.Text("TETRIS - STAGE 2", {
            left: 170, top: 14, originX: "center",
            fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let cell = 34
         let gx = 170 - (8 * cell) / 2
         let gy = 36

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
