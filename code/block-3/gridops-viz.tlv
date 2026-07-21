\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   // A 2-wide piece falls from the top and LOCKS into the pile at the
   // bottom row, then a new piece drops in a shifted column. Watch the
   // pile build up. This uses SET (via shift) and MERGE (via OR).

   // The falling piece: a 2-wide block, shifted by the drop count so
   // each new piece lands in a different place. (times 2 = shift left 1)
   $piece[7:0] = (8'b00000011 << {>>1$drop_count[1:0], 1'b0});

   // Is the piece at the bottom row this cycle?
   $locking = >>1$piece_row == 3'd5;

   // Advance the piece down; reset to top when it locks.
   $piece_row[2:0] = *reset   ? 3'd0 :
                     $locking ? 3'd0 :
                                >>1$piece_row + 3'd1;

   // Count drops so each new piece shifts over.
   $drop_count[2:0] = *reset   ? 3'd0 :
                      $locking ? >>1$drop_count + 3'd1 :
                                 >>1$drop_count;

   // The pile: each row locks in the piece when the piece reaches it.
   $pile5[7:0] = *reset ? 8'b0 : ($locking) ? >>1$pile5 | $piece : >>1$pile5;
   $pile4[7:0] = *reset ? 8'b0 : >>1$pile4;
   $pile3[7:0] = *reset ? 8'b0 : >>1$pile3;
   $pile2[7:0] = *reset ? 8'b0 : >>1$pile2;
   $pile1[7:0] = *reset ? 8'b0 : >>1$pile1;
   $pile0[7:0] = *reset ? 8'b0 : >>1$pile0;

   `BOGUS_USE($piece $piece_row $pile0 $pile1 $pile2 $pile3 $pile4 $pile5)

   *passed = *cyc_cnt > 60;
   *failed = 1'b0;

   \viz_js
      box: {strokeWidth: 0, left: 0, top: 0, width: 400, height: 340, fill: "#0D001A"},
      render() {
         let piece = '$piece'.asInt()
         let pieceRow = '$piece_row'.asInt()
         let p0 = '$pile0'.asInt()
         let p1 = '$pile1'.asInt()
         let p2 = '$pile2'.asInt()
         let p3 = '$pile3'.asInt()
         let p4 = '$pile4'.asInt()
         let p5 = '$pile5'.asInt()
         let pile = [p0, p1, p2, p3, p4, p5]
         let objs = []

         objs.push(new fabric.Text("FALL AND LOCK", {
            left: 200, top: 18, originX: "center",
            fontSize: 16, fontWeight: "bold", fontFamily: "Courier New", fill: "#7C4DFF"
         }))

         let cell = 34
         let gx = 200 - (8 * cell) / 2
         let gy = 45

         for (let r = 0; r < 6; r++) {
            let rowBits = pile[r]
            if (r === pieceRow) {
               rowBits = rowBits | piece
            }
            for (let c = 0; c < 8; c++) {
               let filled = (rowBits >> c) & 1
               let isPiece = (r === pieceRow) && ((piece >> c) & 1)
               objs.push(new fabric.Rect({
                  left: gx + c * cell,
                  top: gy + r * cell,
                  width: cell - 3,
                  height: cell - 3,
                  rx: 3, ry: 3,
                  fill: isPiece ? "#eab308" : (filled ? "#7C4DFF" : "#1A0533"),
                  stroke: filled ? "#B39DDB" : "#2A1A40",
                  strokeWidth: 1
               }))
            }
         }

         objs.push(new fabric.Text("yellow = falling piece   ·   purple = locked pile", {
            left: 200, top: 258, originX: "center",
            fontSize: 11, fontFamily: "Courier New", fill: "#4A3060"
         }))

         return objs
      }
\SV
   endmodule
