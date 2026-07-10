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
      {
         init() {
            // Background
            this.bg = new fabric.Rect({
               left: 0, top: 0,
               width: 500, height: 260,
               fill: '#0D001A',
               selectable: false, evented: false
            });
            this.canvas.add(this.bg);
            
            // "$count" label
            this.label = new fabric.Text('$count', {
               left: 250, top: 24,
               fontSize: 13, fontFamily: 'monospace',
               fill: '#B39DDB',
               originX: 'center', originY: 'top',
               selectable: false, evented: false
            });
            this.canvas.add(this.label);
            
            // Big decimal number
            this.num = new fabric.Text('000', {
               left: 250, top: 55,
               fontSize: 88, fontFamily: 'monospace',
               fontWeight: 'bold',
               fill: '#7C4DFF',
               originX: 'center', originY: 'top',
               selectable: false, evented: false
            });
            this.canvas.add(this.num);
            
            // Binary label
            this.binLabel = new fabric.Text('binary', {
               left: 250, top: 168,
               fontSize: 11, fontFamily: 'monospace',
               fill: '#4A3060',
               originX: 'center', originY: 'top',
               selectable: false, evented: false
            });
            this.canvas.add(this.binLabel);
            
            // Binary value
            this.bin = new fabric.Text('00000000', {
               left: 250, top: 186,
               fontSize: 20, fontFamily: 'monospace',
               fill: '#B39DDB', charSpacing: 120,
               originX: 'center', originY: 'top',
               selectable: false, evented: false
            });
            this.canvas.add(this.bin);
            
            // Cycle counter
            this.cyc = new fabric.Text('cycle 0', {
               left: 250, top: 230,
               fontSize: 11, fontFamily: 'monospace',
               fill: '#4A3060',
               originX: 'center', originY: 'top',
               selectable: false, evented: false
            });
            this.canvas.add(this.cyc);
         },
         
         render() {
            const count = '$count'.asInt(0);
            const cycCnt = '$cyc_cnt'.asInt(0);
            
            this.num.set('text', count.toString().padStart(3, '0'));
            this.bin.set('text', count.toString(2).padStart(8, '0'));
            this.cyc.set('text', 'cycle ' + cycCnt);
            this.canvas.renderAll();
         }
      }
\SV
   endmodule
