\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // ============================================================
   //  WHACK-A-MOLE  —  STAGE 3 of 4:  Keeping Score (Registers)
   // ============================================================
   //  The mole now pops up and a "robot player" tries to whack it.
   //  A HIT happens if the robot reacts before the mole escapes.
   //  Your job: add the SCORE and ROUNDS registers (Module 2.1).
   // ============================================================

   //  MOLE_TIME = 6,  NUM_ROUNDS = 10

   // LFSR (complete):
   $lfsr_fb = >>1$lfsr[3] ^ >>1$lfsr[2];
   $lfsr[3:0] = *reset ? 4'b0001 : {>>1$lfsr[2:0], $lfsr_fb};

   // Robot hit/miss detection (complete):
   //   $escaped: the mole's time ran out (a miss)
   //   $whacked: the robot reacted in time (a hit)
   $escaped = ! *reset && (>>1$timer >= 4'd6);
   $whacked = ! *reset && (>>1$timer == >>1$react) && ! $escaped;
   $resolved = $whacked || $escaped;

   $new_mole = *reset ? 1'b0 : $resolved;

   // Hole, reaction time, timer (complete):
   $hole[2:0]  = *reset ? 3'd0 : $new_mole ? >>1$lfsr[2:0]          : >>1$hole;
   $react[3:0] = *reset ? 4'd3 : $new_mole ? (4'd2 + {1'b0, >>1$lfsr[2:0]}) : >>1$react;
   $timer[3:0] = *reset ? 4'd0 : $new_mole ? 4'd0 : >>1$timer + 4'd1;

   // ---- TODO 1: the SCORE register ----
   //   Start at 0. Add 1 only when $whacked is high. Otherwise hold.
   //   $score[3:0] = *reset   ? 4'd0 :
   //                 $whacked ? >>1$score + 4'd1 :
   //                            >>1$score;
   $score[3:0] = 4'd0;

   // ---- TODO 2: the ROUNDS counter ----
   //   Start at 10. Subtract 1 each time a mole is $resolved. Otherwise hold.
   //   $rounds_left[3:0] = *reset    ? 4'd10 :
   //                       $resolved ? >>1$rounds_left - 4'd1 :
   //                                   >>1$rounds_left;
   $rounds_left[3:0] = 4'd10;

   `BOGUS_USE($hole $score $rounds_left $timer)

   *passed = *cyc_cnt > 80;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 560, height: 340, fill: "#0D001A"},
      render() {
         let hole = '$hole'.asInt()
         let score = '$score'.asInt()
         let rounds = '$rounds_left'.asInt()
         let whacked = '$whacked'.asBool()
         let escaped = '$escaped'.asBool()
         let objs = []

         objs.push(new fabric.Text("STAGE 3: keeping score", {
            left: 280, top: 18, originX: "center",
            fontSize: 14, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         for (let i = 0; i < 8; i++) {
            let col = i % 4, row = Math.floor(i / 4)
            let cx = 110 + col * 115
            let cy = 80 + row * 100
            let active = (hole === i)
            objs.push(new fabric.Ellipse({
               left: cx, top: cy + 26, rx: 42, ry: 15,
               originX: "center", originY: "center",
               fill: "#2A1A10", stroke: "#3A2A18", strokeWidth: 2
            }))
            if (active) {
               objs.push(new fabric.Circle({
                  left: cx, top: cy, radius: 26,
                  originX: "center", originY: "center",
                  fill: "#8B5A2B", stroke: "#B39DDB", strokeWidth: 3
               }))
            }
         }

         if (whacked) {
            objs.push(new fabric.Text("HIT!", {
               left: 280, top: 278, originX: "center",
               fontSize: 18, fontWeight: "bold", fontFamily: "Courier New", fill: "#22c55e"
            }))
         } else if (escaped) {
            objs.push(new fabric.Text("MISS", {
               left: 280, top: 278, originX: "center",
               fontSize: 18, fontWeight: "bold", fontFamily: "Courier New", fill: "#ef4444"
            }))
         }

         objs.push(new fabric.Text("SCORE: " + score, {
            left: 90, top: 312, originX: "left",
            fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#B39DDB"
         }))
         objs.push(new fabric.Text("ROUNDS LEFT: " + rounds, {
            left: 470, top: 312, originX: "right",
            fontSize: 15, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
