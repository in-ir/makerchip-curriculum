\m5_TLV_version 1d: tl-x.org

\SV
   m5_makerchip_module
\TLV
   /mux_viz
      $sel = *cyc_cnt[2];
      $a   = *cyc_cnt[1];
      $b   = *cyc_cnt[0];
      $out = $sel ? $b : $a;

      \viz_js
         box: {strokeWidth: 0, left: -10, top: -10, width: 340, height: 280, fill: "#1e1e2e"},
         init() {
            let ret = {}

            // Title
            ret.title = new fabric.Text("2-to-1 Multiplexer", {
               left: 160, top: 8,
               originX: "center",
               fontSize: 14, fontFamily: "Courier New",
               fill: "#cdd6f4", fontWeight: "bold"
            })

            // Input A box
            ret.box_a = new fabric.Rect({
               left: 20, top: 60, width: 60, height: 36,
               fill: "#313244", stroke: "#89b4fa", strokeWidth: 2, rx: 4, ry: 4
            })
            ret.label_a = new fabric.Text("A", {
               left: 50, top: 66, originX: "center",
               fontSize: 13, fontFamily: "Courier New", fill: "#89b4fa"
            })
            ret.val_a = new fabric.Text("0", {
               left: 68, top: 66, originX: "center",
               fontSize: 13, fontFamily: "Courier New", fill: "#f5c542"
            })

            // Input B box
            ret.box_b = new fabric.Rect({
               left: 20, top: 120, width: 60, height: 36,
               fill: "#313244", stroke: "#89b4fa", strokeWidth: 2, rx: 4, ry: 4
            })
            ret.label_b = new fabric.Text("B", {
               left: 50, top: 126, originX: "center",
               fontSize: 13, fontFamily: "Courier New", fill: "#89b4fa"
            })
            ret.val_b = new fabric.Text("0", {
               left: 68, top: 126, originX: "center",
               fontSize: 13, fontFamily: "Courier New", fill: "#f5c542"
            })

            // SEL box
            ret.box_sel = new fabric.Rect({
               left: 110, top: 185, width: 80, height: 36,
               fill: "#313244", stroke: "#a6e3a1", strokeWidth: 2, rx: 4, ry: 4
            })
            ret.label_sel = new fabric.Text("SEL", {
               left: 150, top: 191, originX: "center",
               fontSize: 13, fontFamily: "Courier New", fill: "#a6e3a1"
            })
            ret.val_sel = new fabric.Text("0", {
               left: 183, top: 191, originX: "center",
               fontSize: 13, fontFamily: "Courier New", fill: "#f5c542"
            })

            // MUX body (trapezoid using polygon)
            ret.mux_body = new fabric.Polygon([
               {x: 140, y: 50},
               {x: 200, y: 70},
               {x: 200, y: 160},
               {x: 140, y: 180}
            ], {
               fill: "#45475a", stroke: "#cdd6f4", strokeWidth: 2
            })

            ret.mux_label = new fabric.Text("MUX", {
               left: 170, top: 108, originX: "center",
               fontSize: 12, fontFamily: "Courier New", fill: "#cdd6f4"
            })

            // Wire A to MUX
            ret.wire_a = new fabric.Line([80, 78, 140, 90], {
               stroke: "#89b4fa", strokeWidth: 2
            })

            // Wire B to MUX
            ret.wire_b = new fabric.Line([80, 138, 140, 140], {
               stroke: "#89b4fa", strokeWidth: 2
            })

            // Wire SEL to MUX
            ret.wire_sel = new fabric.Line([150, 185, 150, 180], {
               stroke: "#a6e3a1", strokeWidth: 2
            })

            // Wire OUT from MUX
            ret.wire_out = new fabric.Line([200, 115, 260, 115], {
               stroke: "#f38ba8", strokeWidth: 2
            })

            // OUT box
            ret.box_out = new fabric.Rect({
               left: 260, top: 97, width: 60, height: 36,
               fill: "#313244", stroke: "#f38ba8", strokeWidth: 2, rx: 4, ry: 4
            })
            ret.label_out = new fabric.Text("OUT", {
               left: 278, top: 103,
               fontSize: 13, fontFamily: "Courier New", fill: "#f38ba8"
            })
            ret.val_out = new fabric.Text("0", {
               left: 310, top: 103, originX: "center",
               fontSize: 13, fontFamily: "Courier New", fill: "#f5c542"
            })

            // Active wire highlight
            ret.active_wire = new fabric.Line([80, 78, 140, 90], {
               stroke: "#f5c542", strokeWidth: 4, opacity: 0
            })

            // SEL description
            ret.sel_desc = new fabric.Text("SEL=0: output follows A", {
               left: 160, top: 248, originX: "center",
               fontSize: 11, fontFamily: "Courier New", fill: "#cdd6f4"
            })

            return ret
         },
         render() {
            let objs = this.obj
            let a   = '$a'.asInt()
            let b   = '$b'.asInt()
            let sel = '$sel'.asInt()
            let out = '$out'.asInt()

            objs.val_a.set({text: a.toString()})
            objs.val_b.set({text: b.toString()})
            objs.val_sel.set({text: sel.toString()})
            objs.val_out.set({text: out.toString()})

            // Highlight active input wire
            if (sel === 0) {
               objs.active_wire.set({x1: 80, y1: 78, x2: 140, y2: 90, opacity: 1})
               objs.sel_desc.set({text: "SEL=0: output follows A"})
            } else {
               objs.active_wire.set({x1: 80, y1: 138, x2: 140, y2: 140, opacity: 1})
               objs.sel_desc.set({text: "SEL=1: output follows B"})
            }

            // Color output wire based on value
            objs.wire_out.set({stroke: out ? "#f5c542" : "#585b70"})
            objs.val_out.set({fill: out ? "#f5c542" : "#6c7086"})
         },
         where: {left: 0, top: 0, width: 10, height: 10}

   *passed = *cyc_cnt > 20;
   *failed = 1'b0;
\SV
   endmodule
