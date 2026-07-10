\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A bit enters from the left every 4 cycles and shifts right.
   $shift_in = *cyc_cnt[1:0] == 2'b00;
   $sr[3:0] = *reset ? 4'b0 : {$shift_in, >>1$sr[3:1]};

   `BOGUS_USE($sr)

   *passed = *cyc_cnt > 60;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 500, height: 200, fill: "#0D001A"},
      render() {
         let sr = '$sr'.asInt()
         let objs = []

         objs.push(new fabric.Text("shift register", {
            left: 250, top: 24, originX: "center",
            fontSize: 13, fontFamily: "Courier New", fill: "#4A3060"
         }))

         // Four cells, bit 3 (leftmost) to bit 0 (rightmost)
         let cellW = 80, gap = 16, startX = 250 - (4*cellW + 3*gap)/2
         for (let i = 0; i < 4; i++) {
            let bit = (sr >> (3 - i)) & 1
            objs.push(new fabric.Rect({
               left: startX + i * (cellW + gap), top: 65,
               width: cellW, height: 80, rx: 8, ry: 8,
               fill: bit ? "#7C4DFF" : "#1A0533",
               stroke: bit ? "#B39DDB" : "#2A1A40", strokeWidth: 2
            }))
            objs.push(new fabric.Text(bit.toString(), {
               left: startX + i * (cellW + gap) + cellW/2, top: 88,
               originX: "center",
               fontSize: 40, fontWeight: "bold", fontFamily: "Courier New",
               fill: bit ? "#ffffff" : "#4A3060"
            }))
         }

         objs.push(new fabric.Text("bit enters left  \u2192  shifts right each cycle", {
            left: 250, top: 165, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
