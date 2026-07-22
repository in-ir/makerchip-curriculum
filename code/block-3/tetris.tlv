\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // ============================================================
   // TETRIS - the complete self-playing game, 8 wide x 10 tall.
   // An LFSR (Block 2) picks a piece width and placement, so every
   // drop is different. Any full row clears, not just the bottom one,
   // and if the stack reaches the top the board resets for a new game.
   // Every detection signal reads the PREVIOUS cycle's board, which
   // keeps the design free of combinational loops.
   // ============================================================

   // --- Difficulty: pieces fall faster as more lines are cleared. ---
   $fall_limit[3:0] = (>>1$score >= 8'd6) ? 4'd1 : (>>1$score >= 8'd3) ? 4'd2 : 4'd3;
   $tick = >>1$timer >= $fall_limit;
   $timer[3:0] = *reset ? 4'd0 : $tick ? 4'd0 : >>1$timer + 4'd1;

   // --- Randomness: a 4-bit LFSR, taps 3 and 2 (Module 2.3). ---
   $lfsr_fb = >>1$lfsr[3] ^ >>1$lfsr[2];
   $lfsr[3:0] = (*reset || $new_game) ? 4'd1 : $lock ? {>>1$lfsr[2:0], $lfsr_fb} : >>1$lfsr;

   // --- The auto-player picks a width (2, 3 or 4 cells) ... ---
   $wmask[7:0] = (>>1$lfsr[1:0] == 2'd0) ? 8'b00000011 : (>>1$lfsr[1:0] == 2'd1) ? 8'b00000111 : (>>1$lfsr[1:0] == 2'd2) ? 8'b00001111 : 8'b00000111;

   // --- ... and a column: usually the leftmost gap in the bottom row,
   //     sometimes a random one, so the stack builds unevenly. ---
   $gap[2:0] = !>>1$pile9[0] ? 3'd0 : !>>1$pile9[1] ? 3'd1 : !>>1$pile9[2] ? 3'd2 : !>>1$pile9[3] ? 3'd3 : !>>1$pile9[4] ? 3'd4 : !>>1$pile9[5] ? 3'd5 : !>>1$pile9[6] ? 3'd6 : 3'd7;
   $aim = !>>1$lfsr[3];
   $col[2:0] = $aim ? $gap : >>1$lfsr[2:0];
   $piece[7:0] = $wmask << $col;

   // --- Collision: what sits below the piece, and has it landed? ---
   $below[7:0] = (>>1$prow == 4'd0) ? >>1$pile1 : (>>1$prow == 4'd1) ? >>1$pile2 : (>>1$prow == 4'd2) ? >>1$pile3 : (>>1$prow == 4'd3) ? >>1$pile4 : (>>1$prow == 4'd4) ? >>1$pile5 : (>>1$prow == 4'd5) ? >>1$pile6 : (>>1$prow == 4'd6) ? >>1$pile7 : (>>1$prow == 4'd7) ? >>1$pile8 : (>>1$prow == 4'd8) ? >>1$pile9 : 8'b0;
   $at_floor = >>1$prow == 4'd9;
   $hit_below = |($piece & $below);
   $landed = $at_floor || $hit_below;

   // --- Line clear: any full row, and we clear the lowest one first. ---
   $clear = (&>>1$pile9) || (&>>1$pile8) || (&>>1$pile7) || (&>>1$pile6) || (&>>1$pile5) || (&>>1$pile4) || (&>>1$pile3) || (&>>1$pile2) || (&>>1$pile1) || (&>>1$pile0);
   $clear_row[3:0] = (&>>1$pile9) ? 4'd9 : (&>>1$pile8) ? 4'd8 : (&>>1$pile7) ? 4'd7 : (&>>1$pile6) ? 4'd6 : (&>>1$pile5) ? 4'd5 : (&>>1$pile4) ? 4'd4 : (&>>1$pile3) ? 4'd3 : (&>>1$pile2) ? 4'd2 : (&>>1$pile1) ? 4'd1 : 4'd0;

   // --- Game over: the stack reached the top row. Start a fresh board. ---
   $new_game = |>>1$pile0;

   $lock = $tick && $landed && !$clear && !$new_game;

   $prow[3:0] = (*reset || $new_game) ? 4'd0 : $clear ? >>1$prow : $lock ? 4'd0 : ($tick && !$landed) ? >>1$prow + 4'd1 : >>1$prow;

   // --- The pile. On a clear, every row at or above the cleared row
   //     takes the value of the row above it. ---
   $pile0[7:0] = (*reset || $new_game) ? 8'b0 : ($clear && $clear_row >= 4'd0) ? 8'b0 : ($lock && >>1$prow == 4'd0) ? >>1$pile0 | $piece : >>1$pile0;
   $pile1[7:0] = (*reset || $new_game) ? 8'b0 : ($clear && $clear_row >= 4'd1) ? >>1$pile0 : ($lock && >>1$prow == 4'd1) ? >>1$pile1 | $piece : >>1$pile1;
   $pile2[7:0] = (*reset || $new_game) ? 8'b0 : ($clear && $clear_row >= 4'd2) ? >>1$pile1 : ($lock && >>1$prow == 4'd2) ? >>1$pile2 | $piece : >>1$pile2;
   $pile3[7:0] = (*reset || $new_game) ? 8'b0 : ($clear && $clear_row >= 4'd3) ? >>1$pile2 : ($lock && >>1$prow == 4'd3) ? >>1$pile3 | $piece : >>1$pile3;
   $pile4[7:0] = (*reset || $new_game) ? 8'b0 : ($clear && $clear_row >= 4'd4) ? >>1$pile3 : ($lock && >>1$prow == 4'd4) ? >>1$pile4 | $piece : >>1$pile4;
   $pile5[7:0] = (*reset || $new_game) ? 8'b0 : ($clear && $clear_row >= 4'd5) ? >>1$pile4 : ($lock && >>1$prow == 4'd5) ? >>1$pile5 | $piece : >>1$pile5;
   $pile6[7:0] = (*reset || $new_game) ? 8'b0 : ($clear && $clear_row >= 4'd6) ? >>1$pile5 : ($lock && >>1$prow == 4'd6) ? >>1$pile6 | $piece : >>1$pile6;
   $pile7[7:0] = (*reset || $new_game) ? 8'b0 : ($clear && $clear_row >= 4'd7) ? >>1$pile6 : ($lock && >>1$prow == 4'd7) ? >>1$pile7 | $piece : >>1$pile7;
   $pile8[7:0] = (*reset || $new_game) ? 8'b0 : ($clear && $clear_row >= 4'd8) ? >>1$pile7 : ($lock && >>1$prow == 4'd8) ? >>1$pile8 | $piece : >>1$pile8;
   $pile9[7:0] = (*reset || $new_game) ? 8'b0 : ($clear && $clear_row >= 4'd9) ? >>1$pile8 : ($lock && >>1$prow == 4'd9) ? >>1$pile9 | $piece : >>1$pile9;

   // --- Score: one point per cleared line, reset on a new game. ---
   $score[7:0] = (*reset || $new_game) ? 8'd0 : $clear ? >>1$score + 8'd1 : >>1$score;

   `BOGUS_USE($piece $prow $pile0 $pile1 $pile2 $pile3 $pile4 $pile5 $pile6 $pile7 $pile8 $pile9 $lock $clear $clear_row $score $new_game $tick)

   *passed = *cyc_cnt > 800;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 360, height: 500, fill: "#0D001A"},
      render() {
         let piece = '$piece'.asInt()
         let prow = '$prow'.asInt()
         let score = '$score'.asInt()
         let clear = '$clear'.asBool()
         let over = '$new_game'.asBool()
         let clearRow = '$clear_row'.asInt()
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

         let banner = "lines cleared: " + score
         let bannerColor = "#eab308"
         if (over) { banner = "STACK TOPPED OUT - NEW GAME" }
         if (over) { bannerColor = "#ef4444" }
         objs.push(new fabric.Text(banner, {
            left: 180, top: 34, originX: "center",
            fontSize: 13, fontFamily: "Courier New", fill: bannerColor
         }))

         let cell = 36
         let gx = 180 - (8 * cell) / 2
         let gy = 50

         for (let r = 0; r < 10; r++) {
            for (let c = 0; c < 8; c++) {
               let pileBit = (pile[r] >> c) & 1
               let pieceBit = (r === prow) && ((piece >> c) & 1)
               let flashing = clear && (r === clearRow)
               let fillColor = "#1A0533"
               if (flashing) { fillColor = "#ffffff" }
               else if (pieceBit) { fillColor = "#eab308" }
               else if (pileBit) { fillColor = "#7C4DFF" }
               let strokeColor = (pileBit || pieceBit || flashing) ? "#B39DDB" : "#2A1A40"
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
