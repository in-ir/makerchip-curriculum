\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A taste of the final challenge. Pac-Man travels the maze corridor
   // eating dots as he goes. Each dot he reaches disappears and the score
   // ticks up. This is a grid, guarded movement, and state you keep over
   // time, all things you built earlier in the course.

   $slow[2:0] = *reset ? 3'd0 : (>>1$slow == 3'd3) ? 3'd0 : >>1$slow + 3'd1;
   $step = >>1$slow == 3'd3;

   // Position along the 20-cell corridor loop.
   $pos[4:0] = *reset ? 5'd0 : ($step && >>1$pos == 5'd19) ? 5'd0 : $step ? >>1$pos + 5'd1 : >>1$pos;

   // A dot at each cell is eaten once visited. One bit per cell, sticky.
   // When pos wraps back to 0 the board refills (reset the mask).
   $refill = $step && >>1$pos == 5'd19;
   $eaten[19:0] = *reset ? 20'd0 : $refill ? 20'd0 : ($step ? (>>1$eaten | (20'd1 << $pos)) : >>1$eaten);

   $score[4:0] = *reset ? 5'd0 : $refill ? 5'd0 : ($step ? >>1$score + 5'd1 : >>1$score);

   `BOGUS_USE($eaten $score)

   *passed = *cyc_cnt > 120;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 460, height: 480, fill: "#0D001A"},
      render() {
         let pos = '$pos'.asInt()
         let eaten = '$eaten'.asInt()
         let score = '$score'.asInt()
         let objs = []

         objs.push(new fabric.Text("PAC-MAN", {
            left: 230, top: 22, originX: "center",
            fontSize: 20, fontWeight: "bold", fontFamily: "Courier New", fill: "#eab308"
         }))
         objs.push(new fabric.Text("the final challenge", {
            left: 230, top: 46, originX: "center",
            fontSize: 12, fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let maze = [255, 129, 189, 165, 165, 189, 129, 255]
         let cell = 44
         let ox = 230 - (8 * cell) / 2
         let oy = 74

         for (let r = 0; r < 8; r++) {
            for (let c = 0; c < 8; c++) {
               let isWall = ((maze[r] >> (7 - c)) & 1) === 1
               objs.push(new fabric.Rect({
                  left: ox + c * cell, top: oy + r * cell,
                  width: cell - 2, height: cell - 2, rx: 3, ry: 3,
                  fill: isWall ? "#2A1650" : "#120022",
                  stroke: isWall ? "#7C4DFF" : "#1A0533", strokeWidth: 1
               }))
            }
         }

         let pathR = [1,1,1,1,1,1, 2,3,4,5, 6,6,6,6,6,6, 5,4,3,2]
         let pathC = [1,2,3,4,5,6, 6,6,6,6, 6,5,4,3,2,1, 1,1,1,1]

         for (let i = 0; i < 20; i++) {
            let isEaten = ((eaten >> i) & 1) === 1
            if (!isEaten) {
               let dx = ox + pathC[i] * cell + cell / 2 - 1
               let dy = oy + pathR[i] * cell + cell / 2 - 1
               objs.push(new fabric.Rect({
                  left: dx - 3, top: dy - 3, width: 6, height: 6, rx: 3, ry: 3,
                  fill: "#F5E9C8", stroke: "#F5E9C8", strokeWidth: 0
               }))
            }
         }

         let px = ox + pathC[pos] * cell + cell / 2 - 1
         let py = oy + pathR[pos] * cell + cell / 2 - 1
         objs.push(new fabric.Rect({
            left: px - 14, top: py - 14, width: 28, height: 28, rx: 14, ry: 14,
            fill: "#eab308", stroke: "#ffffff", strokeWidth: 1
         }))

         objs.push(new fabric.Text("score: " + score, {
            left: 230, top: 438, originX: "center",
            fontSize: 15, fontWeight: "bold", fontFamily: "Courier New", fill: "#eab308"
         }))
         objs.push(new fabric.Text("a maze is a grid. dots are memory. eating is a state change.", {
            left: 230, top: 464, originX: "center",
            fontSize: 10, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
