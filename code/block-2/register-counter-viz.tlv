\m5_TLV_version 1d: tl-x.org
\m5
\SV
   m5_makerchip_module
\TLV
   $count[7:0] = *reset ? 8'b0 : >>1$count + 8'b1;
   
   `BOGUS_USE($count)
   
   *passed = *cyc_cnt > 60;
   *failed = 1'b0;
\SV
   always @(posedge clk) begin
   end
   endmodule
\TLV
\viz_js
   const count = '$count'.asInt(0);
   
   // Background
   svgContext.rect(0, 0, 500, 260).fill('#0D001A');
   
   // Title label
   svgContext.text('$count', 250, 40)
     .font('JetBrains Mono, monospace', 14)
     .fill('#B39DDB')
     .attr('text-anchor', 'middle');
   
   // Big counter number
   svgContext.text(count.toString().padStart(3, '0'), 250, 160)
     .font('JetBrains Mono, monospace', 96)
     .fill('#7C4DFF')
     .attr('text-anchor', 'middle')
     .attr('font-weight', '700');
   
   // Binary representation
   const binary = count.toString(2).padStart(8, '0');
   svgContext.text(binary, 250, 210)
     .font('JetBrains Mono, monospace', 22)
     .fill('#B39DDB')
     .attr('text-anchor', 'middle')
     .attr('letter-spacing', '6');
   
   // Cycle label
   svgContext.text('cycle ' + '$cyc_cnt'.asInt(0), 250, 245)
     .font('JetBrains Mono, monospace', 11)
     .fill('#4A3060')
     .attr('text-anchor', 'middle');
