\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // ============================================================
   //  WHACK-A-MOLE  —  STAGE 1 of 4:  The Mole Picker (LFSR)
   // ============================================================
   //  GOAL: make a mole appear in a RANDOM hole. We use an LFSR
   //  (from Module 2.3) as our random number generator.
   //
   //  A new mole appears every 4 cycles. Three bits of the LFSR
   //  choose which of the 8 holes (0..7) it pops from.
   // ============================================================

   // A new mole every 4 cycles.
   $new_mole = *cyc_cnt[1:0] == 2'b00;

   // ---- TODO 1: complete the LFSR feedback bit ----
   //   It's the XOR of bit 3 and bit 2 of the PREVIOUS value.
   //   Replace the 1'b0 below.
   //   $lfsr_fb = >>1$lfsr[3] ^ >>1$lfsr[2];
   $lfsr_fb = 1'b0;

   // ---- TODO 2: complete the LFSR shift ----
   //   Shift the previous value left and bring $lfsr_fb in at the
   //   bottom. Seed with 0001 on reset.
   //   $lfsr[3:0] = *reset ? 4'b0001 : {>>1$lfsr[2:0], $lfsr_fb};
   $lfsr[3:0] = 4'b0001;

   // Pick the hole from 3 bits of the LFSR when a new mole appears.
   $hole[2:0] = *reset    ? 3'd0 :
                $new_mole ? >>1$lfsr[2:0] :
                            >>1$hole;

   `BOGUS_USE($hole)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 560, height: 300, fill: "#0D001A"},
      render() {
         let hole = '$hole'.asInt()
         let objs = []

         objs.push(new fabric.Text("STAGE 1: the mole picker", {
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

         objs.push(new fabric.Text("mole in hole: " + hole, {
            left: 280, top: 280, originX: "center",
            fontSize: 14, fontFamily: "Courier New", fill: "#B39DDB"
         }))

         return objs
      }
\SV
   endmodule
