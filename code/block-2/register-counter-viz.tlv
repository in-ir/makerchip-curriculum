\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $count[7:0] = *reset ? 8'b0 : >>1$count + 8'b1;

   `BOGUS_USE($count)

   *passed = *cyc_cnt > 60;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 500, height: 260, fill: "#0D001A"},
      render() {
         let count = '$count'.asInt()
         let cyc = '$cyc_cnt'.asInt()
         let bin = count.toString(2).padStart(8, "0")
         let objs = []

         objs.push(new fabric.Text("$count", {
            left: 250, top: 24, originX: "center",
            fontSize: 14, fontFamily: "Courier New", fill: "#B39DDB"
         }))

         objs.push(new fabric.Text(count.toString().padStart(3, "0"), {
            left: 250, top: 60, originX: "center",
            fontSize: 90, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         objs.push(new fabric.Text(bin, {
            left: 250, top: 185, originX: "center",
            fontSize: 22, fontFamily: "Courier New", fill: "#B39DDB", charSpacing: 200
         }))

         objs.push(new fabric.Text("cycle " + cyc, {
            left: 250, top: 225, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
