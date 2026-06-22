\m5_TLV_version 1d: tl-x.org
\m5
\SV
   `include "sqrt32.v";
\TLV
   // ──────────────────────────────────────────────
   // PIXEL ART GENERATOR
   // Block 1 Project — Combinational Logic
   //
   // A 2-bit pattern selector drives an 8x8 pixel grid.
   // Each pixel is a single bit: 1 = ON, 0 = OFF.
   // The pattern is selected combinationally using the
   // chained condition syntax from Module 1.2.
   // ──────────────────────────────────────────────

   // Auto-cycling pattern selector (cycles through 0,1,2,3 every 16 cycles)
   $pattern[1:0] = (*cyc_cnt >> 4) % 4;

   // ──────────────────────────────────────────────
   // PATTERN 0: Smiley Face
   // Read row by row, left to right, MSB = leftmost pixel
   // ──────────────────────────────────────────────
   $smiley_r0[7:0] = 8'b00111100;  //   ####
   $smiley_r1[7:0] = 8'b01000010;  //  #    #
   $smiley_r2[7:0] = 8'b10100101;  // # #  # #
   $smiley_r3[7:0] = 8'b10000001;  // #      #
   $smiley_r4[7:0] = 8'b10100101;  // # #  # #
   $smiley_r5[7:0] = 8'b10011001;  // #  ##  #
   $smiley_r6[7:0] = 8'b01000010;  //  #    #
   $smiley_r7[7:0] = 8'b00111100;  //   ####

   // ──────────────────────────────────────────────
   // PATTERN 1: Heart
   // YOUR CODE HERE — replace each row with the correct 8-bit pattern
   // ──────────────────────────────────────────────
   $heart_r0[7:0] = 8'b00000000;  // replace this
   $heart_r1[7:0] = 8'b00000000;  // replace this
   $heart_r2[7:0] = 8'b00000000;  // replace this
   $heart_r3[7:0] = 8'b00000000;  // replace this
   $heart_r4[7:0] = 8'b00000000;  // replace this
   $heart_r5[7:0] = 8'b00000000;  // replace this
   $heart_r6[7:0] = 8'b00000000;  // replace this
   $heart_r7[7:0] = 8'b00000000;  // replace this

   // ──────────────────────────────────────────────
   // PATTERN 2: YOUR DESIGN — replace with your own pattern
   // ──────────────────────────────────────────────
   $custom_r0[7:0] = 8'b00000000;
   $custom_r1[7:0] = 8'b00000000;
   $custom_r2[7:0] = 8'b00000000;
   $custom_r3[7:0] = 8'b00000000;
   $custom_r4[7:0] = 8'b00000000;
   $custom_r5[7:0] = 8'b00000000;
   $custom_r6[7:0] = 8'b00000000;
   $custom_r7[7:0] = 8'b00000000;

   // ──────────────────────────────────────────────
   // MUX: select the active pattern using the opcode
   // This is the same chained condition syntax from Module 1.2
   // ──────────────────────────────────────────────
   $row0[7:0] = $pattern == 2'b10 ? $custom_r0 :
                $pattern == 2'b01 ? $heart_r0   :
                                    $smiley_r0;
   $row1[7:0] = $pattern == 2'b10 ? $custom_r1 :
                $pattern == 2'b01 ? $heart_r1   :
                                    $smiley_r1;
   $row2[7:0] = $pattern == 2'b10 ? $custom_r2 :
                $pattern == 2'b01 ? $heart_r2   :
                                    $smiley_r2;
   $row3[7:0] = $pattern == 2'b10 ? $custom_r3 :
                $pattern == 2'b01 ? $heart_r3   :
                                    $smiley_r3;
   $row4[7:0] = $pattern == 2'b10 ? $custom_r4 :
                $pattern == 2'b01 ? $heart_r4   :
                                    $smiley_r4;
   $row5[7:0] = $pattern == 2'b10 ? $custom_r5 :
                $pattern == 2'b01 ? $heart_r5   :
                                    $smiley_r5;
   $row6[7:0] = $pattern == 2'b10 ? $custom_r6 :
                $pattern == 2'b01 ? $heart_r6   :
                                    $smiley_r6;
   $row7[7:0] = $pattern == 2'b10 ? $custom_r7 :
                $pattern == 2'b01 ? $heart_r7   :
                                    $smiley_r7;

   *passed = *cyc_cnt > 60;
   *failed = 1'b0;

   // ──────────────────────────────────────────────
   // VIZ: Render the 8x8 pixel grid
   // ──────────────────────────────────────────────
   \viz_js
      initContext: {
         // Canvas setup
         let canvas = document.createElement('canvas');
         canvas.width  = 320;
         canvas.height = 360;
         this.canvas = canvas;
         this.getContext().appendChild(canvas);
      },
      renderContext: {
         let ctx = this.canvas.getContext('2d');
         let cell = 36;
         let pad  = 8;

         // Background
         ctx.fillStyle = '#1e1e2e';
         ctx.fillRect(0, 0, 320, 360);

         // Pattern label
         let pattern = '$pattern'.asInt();
         let labels = ['Pattern 0: Smiley', 'Pattern 1: Heart', 'Pattern 2: Custom', 'Pattern 3: Custom'];
         ctx.fillStyle = '#cdd6f4';
         ctx.font = 'bold 13px JetBrains Mono, monospace';
         ctx.textAlign = 'center';
         ctx.fillText(labels[pattern] || 'Pattern ' + pattern, 160, 22);

         // Row signals
         let rows = [
            '$row0'.asInt(),
            '$row1'.asInt(),
            '$row2'.asInt(),
            '$row3'.asInt(),
            '$row4'.asInt(),
            '$row5'.asInt(),
            '$row6'.asInt(),
            '$row7'.asInt(),
         ];

         // Draw grid
         for (let r = 0; r < 8; r++) {
            for (let c = 0; c < 8; c++) {
               // MSB = leftmost pixel: bit (7 - c) of row r
               let bit = (rows[r] >> (7 - c)) & 1;
               let x = pad + c * cell;
               let y = pad + 28 + r * cell;

               if (bit) {
                  // ON pixel: bright purple/gold
                  ctx.fillStyle = '#f5c542';
                  ctx.shadowColor = '#f5c542';
                  ctx.shadowBlur = 8;
               } else {
                  // OFF pixel: dark
                  ctx.fillStyle = '#313244';
                  ctx.shadowBlur = 0;
               }
               // Rounded pixel
               ctx.beginPath();
               ctx.roundRect(x + 2, y + 2, cell - 4, cell - 4, 4);
               ctx.fill();
               ctx.shadowBlur = 0;
            }
         }
      }
