`include "synthesis_directives.v"

module mipi2parallel_top (
	// Reset and clocks		
	input								reset_n_i				,		// Async reset
	input								ref_clk_i				,		// Assumed 27MHz oscillator
	
	// DPHY data and clk pins				
	inout								clk_p_io				, 
	inout								clk_n_io				,
	inout	[`NUM_RX_LANE-1:0]			d_p_io					, 
	inout	[`NUM_RX_LANE-1:0]			d_n_io					,
	
	// B2P outputs. Clocked by clk_pixel			
	output	[`RX_PD_BUS_WIDTH-1:0]		pd_o					,		// Pixel data
	//output	[1:0]						p_odd_o					,		// Modulo 4 of pixel count. Can be used to indicate valid pixels in case of PPC > 1
	output								clk_pixel_o				,		// Pixel clock. Read clock for B2P
	`ifdef	RX_TYPE_DSI
	output								vsync_o					,		// Only for DSI
	output								hsync_o					,		// Only for DSI
	output								de_o							// Only for DSI
	`elsif RX_TYPE_CSI2
	output								fv_o					,		// Only for CSI-2
	output								lv_o							// Only for CSI-2
	`endif
			
	// Debug signals. Clocked on clk_byte_fr domain.
	`ifdef DPHY_DEBUG_ON
	,
	output	[`NUM_RX_LANE*`RX_GEAR-1:0]	payload_o				,		// Output from RX DPHY before B2P
	output								payload_en_o			,		// RX DPHY Payload enable flag. OR'ed with multiple flags.
	output								lp_av_en_o				,		// RX DPHY Active video long packet flag.
	output	[15:0]						wc_o					,		// RX DPHY Word Count.
	output								clk_byte_hs_o			,		// RX DPHY output byte clock, geared down DPHY clock
	output								clk_byte_fr_o					// Free running byte clock. Write clock for B2P
	`endif
);

wire [1:0] p_odd_o;

//-----------------------------------------------------------------------------//
//-------------------------- WIRE and REG Definition --------------------------//
//-----------------------------------------------------------------------------//

wire 			clk_byte_fr_w;			// used for non-continuous clock to drive clk_byte_fr_i. Source from external or PLL.
wire			clk_lp_ctrl_w;			// used for non-continuous clock to drive clk_lp_ctrl_i. Source from external or PLL.
wire 			pll_lock_w;				// used for non-continuous clock to indicate pll lock for clk_byte_fr. Source from external or PLL.
wire 			clk_byte_hs_w;
wire 			clk_pixel_w;

reg 			ref_clk_rst_n_meta_r,	// Reset synchronization to ref_clk
				ref_clk_rst_n_sync_r;	// Reset synchronization to ref_clk

//-----------------------------------------------------------------------------//
//----------------------------- Signal Assignments ----------------------------//
//-----------------------------------------------------------------------------//

assign clk_pixel_o		= clk_pixel_w;

`ifdef DPHY_DEBUG_ON
	assign clk_byte_hs_o	= clk_byte_hs_w;
	`ifdef RX_CLK_MODE_HS_ONLY
		assign clk_byte_fr_o	= clk_byte_hs_w;
	`elsif RX_CLK_MODE_HS_LP
		assign clk_byte_fr_o	= clk_byte_fr_w;
	`endif
`endif


//-----------------------------------------------------------------------------//
//--------------------------- Reset Synchronization ---------------------------//
//-----------------------------------------------------------------------------//

always @(posedge ref_clk_i or negedge reset_n_i) begin: ref_clk_rst_sync_ff
	if(~reset_n_i) begin
		ref_clk_rst_n_meta_r	<= 1'b0;
		ref_clk_rst_n_sync_r	<= 1'b0;
	end
	else begin
		ref_clk_rst_n_meta_r	<= reset_n_i;
		ref_clk_rst_n_sync_r	<= ref_clk_rst_n_meta_r;
	end
end

//-----------------------------------------------------------------------------//
//---------------------------- IP Instantiation -------------------------------//
//-----------------------------------------------------------------------------//

int_pll int_pll_inst (
	.CLKI		(ref_clk_i),					// 27 MHz Ref clock
	.RST		(~reset_n_i),			
	.CLKOP		(clk_lp_ctrl_w),				// 54 MHz LP CTRL clock, used only in of non-continuous clock mode
	.CLKOS		(clk_byte_fr_w),				// Byte clock fr, used only in of non-continuous clock mode
	.CLKOS2		(clk_pixel_w),					// Pixel clock
	.LOCK		(pll_lock_w)
);

mipi2parallel mipi2parallel_inst(		
	// Reset and clocks		
	.reset_n_i				(reset_n_i),				// Async reset
	.pd_dphy_i				(~reset_n_i),				// Hard DPHY reset. Now just assign the inver of reset_n_i
	`ifdef RX_CLK_MODE_HS_ONLY		
	.clk_byte_fr_i			(clk_byte_hs_w),				// Free running byte clock. Write clock for B2P. For continuous mode drive it from clk_byte_hs
	.pll_lock_clk_byte_fr_i	(1'b1),							// clk_byte_fr pll lock signal. Fix to 1'b1 since using the same byte clock
	.clk_lp_ctrl_i			(),								// Only need to drive for non-continuous mode
	`elsif	RX_CLK_MODE_HS_LP
	.clk_byte_fr_i			(clk_byte_fr_w),				// Free running byte clock. Write clock for B2P. For non continuous, drive it from external source
	.pll_lock_clk_byte_fr_i	(pll_lock_w),					// clk_byte_fr pll lock signal
	.clk_lp_ctrl_i			(clk_lp_ctrl_w),				// Only need to drive for non-continuous mode
	`endif

	.clk_pixel_i			(clk_pixel_w),					// Pixel clock. Read clock for B2P
			
	.clk_byte_o				(),								// RX DPHY output byte clock, geared down DPHY clock
	.clk_byte_hs_o			(clk_byte_hs_w),				// RX DPHY output byte clock, geared down DPHY clock
					
	// DPHY data and clk pins				
	.clk_p_io				(clk_p_io), 
	.clk_n_io				(clk_n_io),
	.d_p_io					(d_p_io), 
	.d_n_io					(d_n_io),
				
	// B2P outputs. Clocked by clk_pixel			
	.pd_o					(pd_o),			// Pixel data
	.p_odd_o				(p_odd_o),		// Modulo 4 of pixel count. Can be used to indicate valid pixels in case of PPC > 1
	`ifdef	RX_TYPE_DSI
	.vsync_o				(vsync_o),		// Only for DSI
	.hsync_o				(hsync_o),		// Only for DSI
	.de_o					(de_o),			// Only for DSI
	`elsif RX_TYPE_CSI2
	.fv_o					(fv_o),			// Only for CSI-2
	.lv_o					(lv_o),			// Only for CSI-2
	`endif

	`ifdef DPHY_DEBUG_ON
	// Debug signals. Clocked on clk_byte_fr domain.		
	.payload_o				(payload_o),		// Output from RX DPHY before B2P
	.payload_en_o			(payload_en_o),		// RX DPHY Payload enable flag. OR'ed with multiple flags.
	.lp_av_en_o				(lp_av_en_o),		// RX DPHY Active video long packet flag.
	.wc_o					(wc_o)				// RX DPHY Word Count.
	`else //if not define, then no connect to anything
	.payload_o				(),					// Output from RX DPHY before B2P
	.payload_en_o			(),					// RX DPHY Payload enable flag. OR'ed with multiple flags.
	.lp_av_en_o				(),					// RX DPHY Active video long packet flag.
	.wc_o					()					// RX DPHY Word Count.
	`endif
);

GSR     GSR_INST (.GSR (1'b1));
PUR		PUR_INST (.PUR (1'b1));
endmodule