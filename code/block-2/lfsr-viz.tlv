\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $fb = >>1$lfsr[3] ^ >>1$lfsr[2];
   $lfsr[3:0] = *reset ? 4'b0001 : {>>1$lfsr[2:0], $fb};

   `BOGUS_USE($lfsr)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 500, height: 240, fill: "#0D001A"},
      render() {
         let lfsr = '$lfsr'.asInt()
         let fb = '$fb'.asBool()
         let objs = []

         objs.push(new fabric.Text("LFSR — random from pure logic", {
            left: 250, top: 20, originX: "center",
            fontSize: 13, fontFamily: "Courier New", fill: "#4A3060"
         }))

         // Four bit cells
         let cellW = 62, gap = 12, startX = 250 - (4*cellW + 3*gap)/2
         for (let i = 0; i < 4; i++) {
            let bit = (lfsr >> (3 - i)) & 1
            objs.push(new fabric.Rect({
               left: startX + i * (cellW + gap), top: 50,
               width: cellW, height: 66, rx: 6, ry: 6,
               fill: bit ? "#7C4DFF" : "#1A0533",
               stroke: bit ? "#B39DDB" : "#2A1A40", strokeWidth: 2
            }))
            objs.push(new fabric.Text(bit.toString(), {
               left: startX + i * (cellW + gap) + cellW/2, top: 66,
               originX: "center",
               fontSize: 34, fontWeight: "bold", fontFamily: "Courier New",
               fill: bit ? "#ffffff" : "#4A3060"
            }))
         }

         // Feedback indicator
         objs.push(new fabric.Text("feedback bit = bit3 XOR bit2 = " + (fb ? "1" : "0"), {
            left: 250, top: 132, originX: "center",
            fontSize: 12, fontFamily: "Courier New",
            fill: fb ? "#7C4DFF" : "#4A3060"
         }))

         // Big decimal output — the "random" number
         objs.push(new fabric.Text("value: " + lfsr.toString(), {
            left: 250, top: 160, originX: "center",
            fontSize: 32, fontWeight: "bold", fontFamily: "Courier New", fill: "#B39DDB"
         }))

         objs.push(new fabric.Text("fully deterministic, yet looks random", {
            left: 250, top: 210, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
