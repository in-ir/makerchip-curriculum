\m5_TLV_version 1d: tl-x.org

\SV
   m5_makerchip_module
\TLV
   // ============================================
   // PIXEL ART GENERATOR — Block 1 Project
   // ============================================
   // A 2-bit pattern selector drives an 8x8 grid.
   // Each row is an 8-bit signal. Bit 7 = leftmost pixel.
   // Change the $patternN_rN values to draw your own images.
   // ============================================

   // Auto-cycle through patterns every 16 clock cycles
   $reset = *reset;
   $cnt[5:0] = $reset ? 6'b0 : >>1$cnt + 1;
   $pattern[1:0] = $cnt[5:4];

   // --------------------------------------------
   // PATTERN 0: Smiley Face (provided)
   // --------------------------------------------
   $smiley_r0[7:0] = 8'b00111100;
   $smiley_r1[7:0] = 8'b01000010;
   $smiley_r2[7:0] = 8'b10100101;
   $smiley_r3[7:0] = 8'b10000001;
   $smiley_r4[7:0] = 8'b10100101;
   $smiley_r5[7:0] = 8'b10011001;
   $smiley_r6[7:0] = 8'b01000010;
   $smiley_r7[7:0] = 8'b00111100;

   // --------------------------------------------
   // PATTERN 1: Heart — YOUR CODE HERE
   // Replace each 8'b00000000 with the correct row
   // --------------------------------------------
   $heart_r0[7:0] = 8'b00000000;
   $heart_r1[7:0] = 8'b00000000;
   $heart_r2[7:0] = 8'b00000000;
   $heart_r3[7:0] = 8'b00000000;
   $heart_r4[7:0] = 8'b00000000;
   $heart_r5[7:0] = 8'b00000000;
   $heart_r6[7:0] = 8'b00000000;
   $heart_r7[7:0] = 8'b00000000;

   // --------------------------------------------
   // PATTERN 2: Custom — YOUR DESIGN HERE
   // --------------------------------------------
   $custom_r0[7:0] = 8'b00000000;
   $custom_r1[7:0] = 8'b00000000;
   $custom_r2[7:0] = 8'b00000000;
   $custom_r3[7:0] = 8'b00000000;
   $custom_r4[7:0] = 8'b00000000;
   $custom_r5[7:0] = 8'b00000000;
   $custom_r6[7:0] = 8'b00000000;
   $custom_r7[7:0] = 8'b00000000;

   // --------------------------------------------
   // MUX: select active pattern (Module 1.2 syntax)
   // --------------------------------------------
   $row0[7:0] = $pattern == 2'b10 ? $custom_r0 : $pattern == 2'b01 ? $heart_r0 : $smiley_r0;
   $row1[7:0] = $pattern == 2'b10 ? $custom_r1 : $pattern == 2'b01 ? $heart_r1 : $smiley_r1;
   $row2[7:0] = $pattern == 2'b10 ? $custom_r2 : $pattern == 2'b01 ? $heart_r2 : $smiley_r2;
   $row3[7:0] = $pattern == 2'b10 ? $custom_r3 : $pattern == 2'b01 ? $heart_r3 : $smiley_r3;
   $row4[7:0] = $pattern == 2'b10 ? $custom_r4 : $pattern == 2'b01 ? $heart_r4 : $smiley_r4;
   $row5[7:0] = $pattern == 2'b10 ? $custom_r5 : $pattern == 2'b01 ? $heart_r5 : $smiley_r5;
   $row6[7:0] = $pattern == 2'b10 ? $custom_r6 : $pattern == 2'b01 ? $heart_r6 : $smiley_r6;
   $row7[7:0] = $pattern == 2'b10 ? $custom_r7 : $pattern == 2'b01 ? $heart_r7 : $smiley_r7;

   \viz_js
      box: {strokeWidth: 0, left: -10, top: -30, width: 320, height: 340, fill: "#1e1e2e"},
      init() {
         let ret = {}
         let cell = 34
         let pad  = 10

         // Pattern label
         ret.label = new fabric.Text("Pattern 0: Smiley", {
            left: 150, top: -20,
            originX: "center",
            fontSize: 13, fontFamily: "Courier New",
            fill: "#cdd6f4"
         })

         // Create 64 pixel cells
         for (let r = 0; r < 8; r++) {
            for (let c = 0; c < 8; c++) {
               let key = "px_" + r + "_" + c
               ret[key] = new fabric.Rect({
                  left: pad + c * cell,
                  top:  pad + r * cell,
                  width:  cell - 3,
                  height: cell - 3,
                  fill: "#313244",
                  rx: 3, ry: 3,
                  strokeWidth: 0
               })
            }
         }
         return ret
      },
      render() {
         let objs = this.obj
         let cell = 34

         // Update label
         let pat = '$pattern'.asInt()
         let labels = ["Pattern 0: Smiley", "Pattern 1: Heart", "Pattern 2: Custom", "Pattern 3: Custom"]
         objs.label.set({text: labels[pat] || ("Pattern " + pat)})

         // Row signal names
         let rowSignals = [
            '$row0', '$row1', '$row2', '$row3',
            '$row4', '$row5', '$row6', '$row7'
         ]

         // Update each pixel
         for (let r = 0; r < 8; r++) {
            let rowVal = rowSignals[r].asInt()
            for (let c = 0; c < 8; c++) {
               // Bit 7 = leftmost pixel (column 0)
               let bit = (rowVal >> (7 - c)) & 1
               let key = "px_" + r + "_" + c
               objs[key].set({
                  fill: bit ? "#f5c542" : "#313244"
               })
            }
         }
         return []
      }

   *passed = *cyc_cnt > 80;
   *failed = 1'b0;

\SV
   endmodule
