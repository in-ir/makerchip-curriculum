\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // Input changes every cycle. Register only captures every 3rd cycle,
   // holding its value in between — the defining behavior of a register.
   $in[3:0] = (*cyc_cnt[3:0] * 4'd5 + 4'd3);
   $capture = *cyc_cnt % 3 == 0;
   $stored[3:0] = *reset    ? 4'b0 :
                  $capture  ? $in :
                              >>1$stored;

   `BOGUS_USE($stored)

   *passed = *cyc_cnt > 60;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 500, height: 240, fill: "#0D001A"},
      render() {
         let inp = '$in'.asInt()
         let stored = '$stored'.asInt()
         let capture = '$capture'.asBool()
         let objs = []

         // INPUT box (left) — changes every cycle
         objs.push(new fabric.Text("input", {
            left: 130, top: 30, originX: "center",
            fontSize: 13, fontFamily: "Courier New", fill: "#4A3060"
         }))
         objs.push(new fabric.Rect({
            left: 55, top: 55, width: 150, height: 110,
            rx: 8, ry: 8, fill: "#1A0533",
            stroke: "#4A3060", strokeWidth: 1
         }))
         objs.push(new fabric.Text(inp.toString(), {
            left: 130, top: 78, originX: "center",
            fontSize: 60, fontWeight: "bold", fontFamily: "Courier New", fill: "#B39DDB"
         }))
         objs.push(new fabric.Text("changes every cycle", {
            left: 130, top: 178, originX: "center",
            fontSize: 10, fontFamily: "Courier New", fill: "#4A3060"
         }))

         // Arrow between them — lights up on capture
         objs.push(new fabric.Text("\u2192", {
            left: 250, top: 88, originX: "center",
            fontSize: 40, fontFamily: "Courier New",
            fill: capture ? "#7C4DFF" : "#2A1A40"
         }))
         objs.push(new fabric.Text(capture ? "capture!" : "hold", {
            left: 250, top: 140, originX: "center",
            fontSize: 12, fontFamily: "Courier New",
            fill: capture ? "#7C4DFF" : "#4A3060"
         }))

         // REGISTER box (right) — only updates on capture
         objs.push(new fabric.Text("register", {
            left: 370, top: 30, originX: "center",
            fontSize: 13, fontFamily: "Courier New", fill: "#B39DDB"
         }))
         objs.push(new fabric.Rect({
            left: 295, top: 55, width: 150, height: 110,
            rx: 8, ry: 8, fill: "#1A0533",
            stroke: capture ? "#7C4DFF" : "#7C4DFF",
            strokeWidth: capture ? 3 : 1.5
         }))
         objs.push(new fabric.Text(stored.toString(), {
            left: 370, top: 78, originX: "center",
            fontSize: 60, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))
         objs.push(new fabric.Text("holds until captured", {
            left: 370, top: 178, originX: "center",
            fontSize: 10, fontFamily: "Courier New", fill: "#4A3060"
         }))

         // Cycle
         objs.push(new fabric.Text("cycle " + '$cyc_cnt'.asInt(), {
            left: 250, top: 212, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
