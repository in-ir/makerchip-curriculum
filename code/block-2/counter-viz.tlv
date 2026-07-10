\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $count[3:0] = *reset          ? 4'b0 :
                 >>1$count == 15 ? 4'b0 :
                                   >>1$count + 1;

   `BOGUS_USE($count)

   *passed = *cyc_cnt > 80;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 500, height: 220, fill: "#0D001A"},
      render() {
         let count = '$count'.asInt()
         let cyc = '$cyc_cnt'.asInt()
         let bin = count.toString(2).padStart(4, "0")
         let objs = []

         // Title
         objs.push(new fabric.Text("counter — wraps at 16", {
            left: 250, top: 16, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#4A3060"
         }))

         // Big count
         objs.push(new fabric.Text(count.toString().padStart(2, "0"), {
            left: 250, top: 42, originX: "center",
            fontSize: 78, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         // Progress bar background
         objs.push(new fabric.Rect({
            left: 40, top: 150, width: 420, height: 18,
            rx: 4, ry: 4, fill: "#1A0533", strokeWidth: 0
         }))

         // Progress bar fill
         objs.push(new fabric.Rect({
            left: 40, top: 150, width: Math.round((count / 15) * 420), height: 18,
            rx: 4, ry: 4, fill: "#7C4DFF", strokeWidth: 0
         }))

         // Binary
         objs.push(new fabric.Text(bin, {
            left: 250, top: 180, originX: "center",
            fontSize: 18, fontFamily: "Courier New", fill: "#B39DDB", charSpacing: 200
         }))

         // Cycle
         objs.push(new fabric.Text("cycle " + cyc, {
            left: 250, top: 202, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
