\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $wr_addr[2:0] = *cyc_cnt[2:0];
   $wr_data[3:0] = *cyc_cnt[3:0];

   $m0[3:0] = *reset ? 4'd0 : ($wr_addr == 3'd0) ? $wr_data : >>1$m0;
   $m1[3:0] = *reset ? 4'd0 : ($wr_addr == 3'd1) ? $wr_data : >>1$m1;
   $m2[3:0] = *reset ? 4'd0 : ($wr_addr == 3'd2) ? $wr_data : >>1$m2;
   $m3[3:0] = *reset ? 4'd0 : ($wr_addr == 3'd3) ? $wr_data : >>1$m3;
   $m4[3:0] = *reset ? 4'd0 : ($wr_addr == 3'd4) ? $wr_data : >>1$m4;
   $m5[3:0] = *reset ? 4'd0 : ($wr_addr == 3'd5) ? $wr_data : >>1$m5;
   $m6[3:0] = *reset ? 4'd0 : ($wr_addr == 3'd6) ? $wr_data : >>1$m6;
   $m7[3:0] = *reset ? 4'd0 : ($wr_addr == 3'd7) ? $wr_data : >>1$m7;

   $rd_addr[2:0] = >>1$wr_addr;

   `BOGUS_USE($m0 $m1 $m2 $m3 $m4 $m5 $m6 $m7 $rd_addr)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 500, height: 320, fill: "#0D001A"},
      render() {
         let c0 = '$m0'.asInt()
         let c1 = '$m1'.asInt()
         let c2 = '$m2'.asInt()
         let c3 = '$m3'.asInt()
         let c4 = '$m4'.asInt()
         let c5 = '$m5'.asInt()
         let c6 = '$m6'.asInt()
         let c7 = '$m7'.asInt()
         let cells = [c0, c1, c2, c3, c4, c5, c6, c7]
         let wrAddr = '$wr_addr'.asInt()
         let rdAddr = '$rd_addr'.asInt()
         let objs = []

         objs.push(new fabric.Text("8-ENTRY RAM", {
            left: 250, top: 20, originX: "center",
            fontSize: 16, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         for (let i = 0; i < 8; i++) {
            let y = 55 + i * 30
            let writing = (wrAddr === i)
            let reading = (rdAddr === i)

            objs.push(new fabric.Text("addr " + i, {
               left: 120, top: y + 12, originX: "left", originY: "center",
               fontSize: 12, fontFamily: "Courier New", fill: "#4A3060"
            }))
            objs.push(new fabric.Rect({
               left: 190, top: y, width: 120, height: 24, rx: 4, ry: 4,
               fill: writing ? "#3B6D11" : "#1A0533",
               stroke: reading ? "#eab308" : (writing ? "#22c55e" : "#2A1A40"),
               strokeWidth: (reading || writing) ? 3 : 1
            }))
            objs.push(new fabric.Text((cells[i] < 10 ? "0" + cells[i] : "" + cells[i]), {
               left: 250, top: y + 12, originX: "center", originY: "center",
               fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#EDE7F6"
            }))
            if (writing) {
               objs.push(new fabric.Text("WRITE", {
                  left: 320, top: y + 12, originX: "left", originY: "center",
                  fontSize: 11, fontFamily: "Courier New", fill: "#22c55e"
               }))
            } else if (reading) {
               objs.push(new fabric.Text("READ", {
                  left: 320, top: y + 12, originX: "left", originY: "center",
                  fontSize: 11, fontFamily: "Courier New", fill: "#eab308"
               }))
            }
         }

         return objs
      }
\SV
   endmodule
