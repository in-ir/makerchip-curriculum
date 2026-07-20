\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $wr_en        = 1'b1;
   $wr_addr[1:0] = *cyc_cnt[1:0];
   $wr_data[3:0] = *cyc_cnt[3:0];

   $r0[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd0) ? $wr_data : >>1$r0;
   $r1[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd1) ? $wr_data : >>1$r1;
   $r2[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd2) ? $wr_data : >>1$r2;
   $r3[3:0] = *reset ? 4'd0 : ($wr_en && $wr_addr == 2'd3) ? $wr_data : >>1$r3;

   $rd_addr[1:0] = >>1$wr_addr;
   $rd_data[3:0] = ($rd_addr == 2'd0) ? $r0 :
                   ($rd_addr == 2'd1) ? $r1 :
                   ($rd_addr == 2'd2) ? $r2 :
                                        $r3;

   `BOGUS_USE($rd_data)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 500, height: 300, fill: "#0D001A"},
      render() {
         let vals = ['$r0'.asInt(), '$r1'.asInt(), '$r2'.asInt(), '$r3'.asInt()]
         let wrAddr = '$wr_addr'.asInt()
         let wrEn = '$wr_en'.asBool()
         let rdAddr = '$rd_addr'.asInt()
         let objs = []

         objs.push(new fabric.Text("REGISTER FILE", {
            left: 250, top: 18, originX: "center",
            fontSize: 16, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         for (let i = 0; i < 4; i++) {
            let y = 55 + i * 52
            let writing = wrEn && (wrAddr === i)
            let reading = (rdAddr === i)

            // register box
            objs.push(new fabric.Rect({
               left: 150, top: y, width: 200, height: 42, rx: 6, ry: 6,
               fill: writing ? "#3B6D11" : "#1A0533",
               stroke: reading ? "#eab308" : (writing ? "#22c55e" : "#2A1A40"),
               strokeWidth: (reading || writing) ? 3 : 1.5
            }))
            // register name
            objs.push(new fabric.Text("r" + i, {
               left: 170, top: y + 21, originX: "center", originY: "center",
               fontSize: 16, fontFamily: "Courier New", fill: "#B39DDB"
            }))
            // value
            objs.push(new fabric.Text(vals[i].toString().padStart(2, "0"), {
               left: 260, top: y + 21, originX: "center", originY: "center",
               fontSize: 22, fontWeight: "bold", fontFamily: "Courier New", fill: "#EDE7F6"
            }))
            // tags
            if (writing) {
               objs.push(new fabric.Text("<- WRITE", {
                  left: 358, top: y + 21, originX: "left", originY: "center",
                  fontSize: 12, fontFamily: "Courier New", fill: "#22c55e"
               }))
            } else if (reading) {
               objs.push(new fabric.Text("<- READ", {
                  left: 358, top: y + 21, originX: "left", originY: "center",
                  fontSize: 12, fontFamily: "Courier New", fill: "#eab308"
               }))
            }
         }

         objs.push(new fabric.Text("green = being written   ·   yellow = being read", {
            left: 250, top: 278, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
