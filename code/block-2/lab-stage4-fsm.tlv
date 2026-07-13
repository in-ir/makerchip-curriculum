\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // ============================================================
   //  WHACK-A-MOLE  —  STAGE 4 of 4:  The Game Brain (FSM)
   // ============================================================
   //  Everything else is done. The final piece is the STATE
   //  MACHINE (Module 2.4) that runs the game through its phases:
   //    0 IDLE · 1 MOLE_UP · 2 SCORE · 3 GAME_OVER
   //  Complete $state and the game comes alive.
   // ============================================================

   //  MOLE_TIME = 6,  NUM_ROUNDS = 10

   // LFSR (complete):
   $lfsr_fb = >>1$lfsr[3] ^ >>1$lfsr[2];
   $lfsr[3:0] = *reset ? 4'b0001 : {>>1$lfsr[2:0], $lfsr_fb};

   // New mole when leaving IDLE, or leaving SCORE with rounds remaining:
   $new_mole = *reset ? 1'b0 :
               (>>1$state == 2'd0) ? 1'b1 :
               (>>1$state == 2'd2 && >>1$rounds_left != 4'd0) ? 1'b1 :
               1'b0;

   // Hole, reaction, timer (complete):
   $hole[2:0]  = *reset ? 3'd0 : $new_mole ? >>1$lfsr[2:0] : >>1$hole;
   $react[3:0] = *reset ? 4'd3 : $new_mole ? (4'd2 + {1'b0, >>1$lfsr[2:0]}) : >>1$react;
   $timer[3:0] = *reset              ? 4'd0 :
                 $new_mole           ? 4'd0 :
                 (>>1$state == 2'd1) ? >>1$timer + 4'd1 :
                                       4'd0;

   // Hit / miss (complete):
   $escaped = (>>1$state == 2'd1) && (>>1$timer >= 4'd6);
   $whacked = (>>1$state == 2'd1) && (>>1$timer == >>1$react) && ! $escaped;
   $resolved = $whacked || $escaped;

   // Score and rounds (complete):
   $score[3:0] = *reset ? 4'd0 : $whacked ? >>1$score + 4'd1 : >>1$score;
   $rounds_left[3:0] = *reset ? 4'd10 : $resolved ? >>1$rounds_left - 4'd1 : >>1$rounds_left;

   // ---- TODO: complete the state machine ----
   //   IDLE(0)      -> MOLE_UP(1)                    always
   //   MOLE_UP(1)   -> SCORE(2)   when $resolved     (hit or miss)
   //   MOLE_UP(1)   -> MOLE_UP(1) otherwise          (mole still up)
   //   SCORE(2)     -> GAME_OVER(3) when rounds hit 0
   //   SCORE(2)     -> MOLE_UP(1)  otherwise         (next round)
   //   GAME_OVER(3) -> stays
   //
   //   $state[1:0] = *reset ? 2'd0 :
   //                 (>>1$state == 2'd0) ? 2'd1 :
   //                 (>>1$state == 2'd1 && $resolved) ? 2'd2 :
   //                 (>>1$state == 2'd1) ? 2'd1 :
   //                 (>>1$state == 2'd2 && >>1$rounds_left == 4'd0) ? 2'd3 :
   //                 (>>1$state == 2'd2) ? 2'd1 :
   //                                       2'd3;
   $state[1:0] = 2'd0;

   `BOGUS_USE($hole $score $rounds_left $timer $state $whacked $escaped $react)

   *passed = *cyc_cnt > 120;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 560, height: 360, fill: "#0D001A"},
      render() {
         let state = '$state'.asInt()
         let hole = '$hole'.asInt()
         let score = '$score'.asInt()
         let rounds = '$rounds_left'.asInt()
         let whacked = '$whacked'.asBool()
         let escaped = '$escaped'.asBool()
         let stateNames = ["READY", "MOLE UP!", "SCORING", "GAME OVER"]
         let objs = []

         objs.push(new fabric.Text("WHACK-A-MOLE", {
            left: 280, top: 16, originX: "center",
            fontSize: 20, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let moleUp = (state === 1)
         for (let i = 0; i < 8; i++) {
            let col = i % 4, row = Math.floor(i / 4)
            let cx = 110 + col * 115
            let cy = 90 + row * 110
            let active = moleUp && (hole === i)
            objs.push(new fabric.Ellipse({
               left: cx, top: cy + 30, rx: 44, ry: 16,
               originX: "center", originY: "center",
               fill: "#2A1A10", stroke: "#3A2A18", strokeWidth: 2
            }))
            if (active) {
               objs.push(new fabric.Circle({
                  left: cx, top: cy, radius: 28,
                  originX: "center", originY: "center",
                  fill: "#8B5A2B", stroke: "#B39DDB", strokeWidth: 3
               }))
               objs.push(new fabric.Text("^_^", {
                  left: cx, top: cy, originX: "center", originY: "center",
                  fontSize: 16, fontFamily: "Courier New", fill: "#0D001A"
               }))
            }
         }

         let bannerColor = state === 3 ? "#ef4444" : (state === 1 ? "#22c55e" : "#B39DDB")
         objs.push(new fabric.Text(stateNames[state], {
            left: 280, top: 300, originX: "center",
            fontSize: 22, fontWeight: "bold", fontFamily: "Courier New", fill: bannerColor
         }))

         if (whacked) {
            objs.push(new fabric.Text("HIT!", {
               left: 480, top: 300, originX: "center",
               fontSize: 20, fontWeight: "bold", fontFamily: "Courier New", fill: "#22c55e"
            }))
         } else if (escaped) {
            objs.push(new fabric.Text("MISS", {
               left: 480, top: 300, originX: "center",
               fontSize: 20, fontWeight: "bold", fontFamily: "Courier New", fill: "#ef4444"
            }))
         }

         objs.push(new fabric.Text("SCORE: " + score, {
            left: 80, top: 336, originX: "left",
            fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#B39DDB"
         }))
         objs.push(new fabric.Text("ROUNDS LEFT: " + rounds, {
            left: 480, top: 336, originX: "right",
            fontSize: 15, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
