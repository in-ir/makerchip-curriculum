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
            this.bg = new fabric.Rect({
               left: 0, top: 0, width: 500, height: 260,
               fill: '#0D001A', selectable: false, evented: false
            });
            this.canvas.add(this.bg);
            
            this.label = new fabric.Text('$count', {
               left: 250, top: 20, fontSize: 14,
               fontFamily: 'monospace', fill: '#B39DDB',
               textAlign: 'center', originX: 'center',
               selectable: false, evented: false
            });
            this.canvas.add(this.label);
            
            this.counter = new fabric.Text('000', {
               left: 250, top: 70, fontSize: 96,
               fontFamily: 'monospace', fill: '#7C4DFF',
               fontWeight: 'bold', textAlign: 'center', originX: 'center',
               selectable: false, evented: false
            });
            this.canvas.add(this.counter);
            
            this.binary = new fabric.Text('00000000', {
               left: 250, top: 190, fontSize: 22,
               fontFamily: 'monospace', fill: '#B39DDB',
               textAlign: 'center', originX: 'center', charSpacing: 150,
               selectable: false, evented: false
            });
            this.canvas.add(this.binary);
            
            this.cycleLabel = new fabric.Text('cycle 0', {
               left: 250, top: 228, fontSize: 11,
               fontFamily: 'monospace', fill: '#4A3060',
               textAlign: 'center', originX: 'center',
               selectable: false, evented: false
            });
            this.canvas.add(this.cycleLabel);
         },
         render() {
            const count = '$count'.asInt(0);
            const cyc = '$cyc_cnt'.asInt(0);
            this.counter.set('text', count.toString().padStart(3, '0'));
            this.binary.set('text', count.toString(2).padStart(8, '0'));
            this.cycleLabel.set('text', 'cycle ' + cyc);
            this.canvas.renderAll();
         }
      }
\SV
   endmodule
