\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A taste of the final challenge. Pac-Man moves through a maze while a
   // ghost chases. This is not a full game, it is a glimpse of what you
   // now have the tools to build: a grid maze, guarded movement, and a
   // chasing state machine, all things you built earlier in the course.

   $tick[3:0] = *reset ? 4'd0 : (>>1$tick == 4'd7) ? 4'd0 : >>1$tick + 4'd1;
   $step = >>1$tick == 4'd7;

   // Pac-Man walks a fixed loop around the maze (8 positions).
   $pac[3:0] = *reset ? 4'd0 : ($step && >>1$pac == 4'd7) ? 4'd0 : $step ? >>1$pac + 4'd1 : >>1$pac;

   // The ghost follows one step behind.
   $ghost[3:0] = *reset ? 4'd6 : ($step && >>1$ghost == 4'd7) ? 4'd0 : $step ? >>1$ghost + 4'd1 : >>1$ghost;

   `BOGUS_USE($pac $ghost)

   *passed = *cyc_cnt > 80;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 460, height: 460, fill: "#0D001A"},
      render() {
         let pac = '$pac'.asInt()
         let ghost = '$ghost'.asInt()
         let objs = []

         objs.push(new fabric.Text("PAC-MAN", {
            left: 230, top: 22, originX: "center",
            fontSize: 18, fontWeight: "bold", fontFamily: "Courier New", fill: "#eab308"
         }))
         objs.push(new fabric.Text("the final challenge", {
            left: 230, top: 44, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let maze = [255, 129, 189, 165, 165, 189, 129, 255]

         let cell = 44
         let ox = 230 - (8 * cell) / 2
         let oy = 70

         for (let r = 0; r < 8; r++) {
            for (let c = 0; c < 8; c++) {
               let wall = ((maze[r] >> (7 - c)) & 1) === 1
               objs.push(new fabric.Rect({
                  left: ox + c * cell, top: oy + r * cell,
                  width: cell - 2, height: cell - 2, rx: 2, ry: 2,
                  fill: wall ? "#2A1650" : "#0D001A",
                  stroke: wall ? "#7C4DFF" : "#1A0533", strokeWidth: 1
               }))
            }
         }

         let pathC = [1, 2, 3, 4, 5, 6, 6, 1]
         let pathR = [1, 1, 1, 1, 1, 1, 6, 6]

         let px = ox + pathC[pac] * cell + cell / 2 - 1
         let py = oy + pathR[pac] * cell + cell / 2 - 1
         objs.push(new fabric.Rect({
            left: px - 13, top: py - 13, width: 26, height: 26, rx: 13, ry: 13,
            fill: "#eab308", stroke: "#ffffff", strokeWidth: 1
         }))

         let gx = ox + pathC[ghost] * cell + cell / 2 - 1
         let gy = oy + pathR[ghost] * cell + cell / 2 - 1
         objs.push(new fabric.Rect({
            left: gx - 13, top: gy - 13, width: 26, height: 26, rx: 8, ry: 8,
            fill: "#ef4444", stroke: "#ffffff", strokeWidth: 1
         }))

         objs.push(new fabric.Text("a maze is a grid. a ghost is a state machine.", {
            left: 230, top: 428, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))
         objs.push(new fabric.Text("you have built both.", {
            left: 230, top: 446, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
