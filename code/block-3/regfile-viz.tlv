\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $wr_addr[1:0] = *cyc_cnt[1:0];
   $wr_data[3:0] = *cyc_cnt[3:0];

   $r0[3:0] = *reset ? 4'd0 : ($wr_addr == 2'd0) ? $wr_data : >>1$r0;
   $r1[3:0] = *reset ? 4'd0 : ($wr_addr == 2'd1) ? $wr_data : >>1$r1;
   $r2[3:0] = *reset ? 4'd0 : ($wr_addr == 2'd2) ? $wr_data : >>1$r2;
   $r3[3:0] = *reset ? 4'd0 : ($wr_addr == 2'd3) ? $wr_data : >>1$r3;

   $rd_addr[1:0] = >>1$wr_addr;

   `BOGUS_USE($r0 $r1 $r2 $r3 $rd_addr)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 500, height: 300, fill: "#0D001A"},
      render() {
         let v0 = '$r0'.asInt()
         let v1 = '$r1'.asInt()
         let v2 = '$r2'.asInt()
         let v3 = '$r3'.asInt()
         let vals = [v0, v1, v2, v3]
         let wrAddr = '$wr_addr'.asInt()
         let rdAddr = '$rd_addr'.asInt()
         let objs = []

         objs.push(new fabric.Text("REGISTER FILE", {
            left: 250, top: 18, originX: "center",
            fontSize: 16, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         for (let i = 0; i < 4; i++) {
            let y = 55 + i * 52
            let writing = (wrAddr === i)
            let reading = (rdAddr === i)

            objs.push(new fabric.Rect({
               left: 150, top: y, width: 200, height: 42, rx: 6, ry: 6,
               fill: writing ? "#3B6D11" : "#1A0533",
               stroke: reading ? "#eab308" : (writing ? "#22c55e" : "#2A1A40"),
               strokeWidth: (reading || writing) ? 3 : 1.5
            }))
            objs.push(new fabric.Text("r" + i, {
               left: 170, top: y + 21, originX: "center", originY: "center",
               fontSize: 16, fontFamily: "Courier New", fill: "#B39DDB"
            }))
            objs.push(new fabric.Text((vals[i] < 10 ? "0" + vals[i] : "" + vals[i]), {
               left: 260, top: y + 21, originX: "center", originY: "center",
               fontSize: 22, fontWeight: "bold", fontFamily: "Courier New", fill: "#EDE7F6"
            }))
            if (writing) {
               objs.push(new fabric.Text("WRITE", {
                  left: 360, top: y + 21, originX: "left", originY: "center",
                  fontSize: 12, fontFamily: "Courier New", fill: "#22c55e"
               }))
            } else if (reading) {
               objs.push(new fabric.Text("READ", {
                  left: 360, top: y + 21, originX: "left", originY: "center",
                  fontSize: 12, fontFamily: "Courier New", fill: "#eab308"
               }))
            }
         }

         return objs
      }
\SV
   endmodule
