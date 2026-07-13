\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // ============================================================
   //  WHACK-A-MOLE  —  STAGE 2 of 4:  The Mole Clock (Timer)
   // ============================================================
   //  The LFSR from Stage 1 is now done for you. Your job: add a
   //  TIMER (a counter, from Module 2.2) that controls how long
   //  each mole stays up. When the timer runs out, a new mole
   //  appears in a new hole.
   // ============================================================

   //  MOLE_TIME = 6 cycles

   // LFSR (from Stage 1, complete):
   $lfsr_fb = >>1$lfsr[3] ^ >>1$lfsr[2];
   $lfsr[3:0] = *reset ? 4'b0001 : {>>1$lfsr[2:0], $lfsr_fb};

   // A new mole appears when the timer has run out.
   $new_mole = *reset ? 1'b0 : >>1$timer >= 4'd6;

   // ---- TODO: complete the timer ----
   //   - On reset, start at 0.
   //   - When a new mole appears ($new_mole), restart at 0.
   //   - Otherwise, count up by 1 each cycle.
   //
   //   $timer[3:0] = *reset    ? 4'd0 :
   //                 $new_mole ? 4'd0 :
   //                             >>1$timer + 4'd1;
   $timer[3:0] = 4'd0;

   // Hole selection (complete):
   $hole[2:0] = *reset    ? 3'd0 :
                $new_mole ? >>1$lfsr[2:0] :
                            >>1$hole;

   `BOGUS_USE($hole $timer)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 560, height: 320, fill: "#0D001A"},
      render() {
         let hole = '$hole'.asInt()
         let timer = '$timer'.asInt()
         let MOLE_TIME = 6
         let objs = []

         objs.push(new fabric.Text("STAGE 2: the mole clock", {
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

         // Countdown bar
         objs.push(new fabric.Rect({
            left: 110, top: 288, width: 340, height: 16,
            rx: 4, ry: 4, fill: "#1A0533", strokeWidth: 0
         }))
         let frac = Math.max(0, 1 - (timer / MOLE_TIME))
         objs.push(new fabric.Rect({
            left: 110, top: 288, width: Math.round(340 * frac), height: 16,
            rx: 4, ry: 4, fill: "#22c55e", strokeWidth: 0
         }))
         objs.push(new fabric.Text("time left", {
            left: 470, top: 296, originX: "left",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
