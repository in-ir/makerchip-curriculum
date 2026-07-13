\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $duration[2:0] = (>>1$state == 2'd0) ? 3'd3 :
                    (>>1$state == 2'd1) ? 3'd1 :
                                          3'd3;
   $expired = >>1$timer == $duration;
   $timer[2:0] = *reset    ? 3'd0 :
                 $expired  ? 3'd0 :
                             >>1$timer + 3'd1;
   $state[1:0] = *reset     ? 2'd0 :
                 ! $expired ? >>1$state :
                 (>>1$state == 2'd0) ? 2'd1 :
                 (>>1$state == 2'd1) ? 2'd2 :
                                       2'd0;

   `BOGUS_USE($state $timer)

   *passed = *cyc_cnt > 40;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 500, height: 300, fill: "#0D001A"},
      render() {
         let state = '$state'.asInt()
         let timer = '$timer'.asInt()
         let names = ["GREEN", "YELLOW", "RED"]
         let onColors = ["#22c55e", "#eab308", "#ef4444"]
         let offColors = ["#0f2f1a", "#2f2a0f", "#2f0f0f"]
         let objs = []

         objs.push(new fabric.Text("traffic light FSM", {
            left: 250, top: 18, originX: "center",
            fontSize: 13, fontFamily: "Courier New", fill: "#4A3060"
         }))

         // Traffic light housing
         objs.push(new fabric.Rect({
            left: 205, top: 45, width: 90, height: 200,
            rx: 12, ry: 12, fill: "#1A0533", stroke: "#4A3060", strokeWidth: 2
         }))

         // Three lamps
         for (let i = 0; i < 3; i++) {
            let lit = (state === i)
            objs.push(new fabric.Circle({
               left: 250, top: 80 + i * 60, radius: 24,
               originX: "center", originY: "center",
               fill: lit ? onColors[i] : offColors[i],
               stroke: lit ? "#ffffff" : "#2A1A40",
               strokeWidth: lit ? 2 : 1
            }))
         }

         // State name
         objs.push(new fabric.Text(names[state], {
            left: 250, top: 256, originX: "center",
            fontSize: 26, fontWeight: "bold", fontFamily: "Courier New",
            fill: onColors[state]
         }))

         // Timer
         objs.push(new fabric.Text("timer: " + timer, {
            left: 250, top: 285, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
