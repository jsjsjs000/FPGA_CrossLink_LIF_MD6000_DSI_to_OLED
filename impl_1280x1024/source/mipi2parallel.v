`include "synthesis_directives.v"

module mipi2parallel (		
	// Reset and clocks		
	input								reset_n_i				,		// Async reset
	input								pd_dphy_i				,		// Hard DPHY reset
	input								clk_byte_fr_i			,		// Free running byte clock. Write clock for B2P
	input								pll_lock_clk_byte_fr_i	,		// clk_byte_fr pll lock signal
	input								clk_lp_ctrl_i			,		// Only need to drive for non-continuous mode
	input								clk_pixel_i				,		// Pixel clock. Read clock for B2P
	
	output								clk_byte_o				,		// RX DPHY output byte clock, geared down DPHY clock
	output								clk_byte_hs_o			,		// RX DPHY output byte clock, geared down DPHY clock
					
	// DPHY data and clk pins				
	inout								clk_p_io				, 
	inout								clk_n_io				,
	inout	[`NUM_RX_LANE-1:0]			d_p_io					, 
	inout	[`NUM_RX_LANE-1:0]			d_n_io					,
				
	// B2P outputs. Clocked by clk_pixel			
	output	[`RX_PD_BUS_WIDTH-1:0]		pd_o					,		// Pixel data
	output	[1:0]						p_odd_o					,		// Modulo 4 of pixel count. Can be used to indicate valid pixels in case of PPC > 1
	`ifdef	RX_TYPE_DSI
	output								vsync_o					,		// Only for DSI
	output								hsync_o					,		// Only for DSI
	output								de_o					,		// Only for DSI
	`elsif RX_TYPE_CSI2
	output								fv_o					,		// Only for CSI-2
	output								lv_o					,		// Only for CSI-2
	`endif
			
	// Debug signals. Clocked on clk_byte_fr domain.		
	output	[`NUM_RX_LANE*`RX_GEAR-1:0]	payload_o				,		// Output from RX DPHY before B2P
	output								payload_en_o			,		// RX DPHY Payload enable flag. OR'ed with multiple flags.
	output								lp_av_en_o				,		// RX DPHY Active video long packet flag.
	output	[15:0]						wc_o							// RX DPHY Word Count.
);

//-----------------------------------------------------------------------------//
//-------------------------- WIRE and REG Definition --------------------------//
//-----------------------------------------------------------------------------//

// Reset double sync signals
reg 	rx_reset_byte_fr_n_meta_r, rx_reset_byte_fr_n_sync_r;	// clk_byte_fr domain
reg 	rx_reset_byte_n_meta_r, rx_reset_byte_n_sync_r;			// clk_byte_o domain
reg 	rx_reset_lp_n_meta_r, rx_reset_lp_n_sync_r;				// clk_lp_ctrl domain
reg 	b2p_reset_pixel_n_meta_r, b2p_reset_pixel_n_sync_r;

// RX DPHY signals for B2P.
wire								sp_en_w, sp2_en_w;
wire 								lp_en_w, lp2_en_w;
wire								lp_av_en_w, lp2_av_en_w;
wire 	[5:0]						dt_w, dt2_w;
wire 	[15:0]						wc_w, wc2_w;
wire								payload_en_w;
wire 	[`NUM_RX_LANE*`RX_GEAR-1:0]	payload_w;

// RX DPHY signals, but unused for this RD. Can be used for reveal or extend this RD.
wire	[1:0]				vc_w, vc2_w;	// Virtual channel from the packet.
wire	[7:0]				ecc_w, ecc2_w;	// ECC will not be checked/corrected!
wire	[`NUM_RX_LANE*8-1:0]	bd_w;		// byte data. Should only be valid for gear8

wire 						hs_d_en_w;
wire 						hs_sync_w;
wire 						term_clk_en_w;
wire	[1:0]				lp_hs_state_clk_w;
wire	[1:0]				lp_hs_state_d_w;
			
wire						lp_d0_tx_en_w;	//------------------------------------------------------------------------------------------------------------------//
wire 						lp_d0_tx_p_w;	//--- These are DSI specific pins to enable driving from lane0 feature. Drive these to constants for this design ---//
wire 						lp_d0_tx_n_w;	//------------------------------------------------------------------------------------------------------------------//
				
wire 						cd_d0_w;		// Contention detection.
wire 	[`NUM_RX_LANE-1:0]	lp_d_rx_p_w;	// LP data from RX.
wire 	[`NUM_RX_LANE-1:0]	lp_d_rx_n_w;	// LP data from RX.

//-----------------------------------------------------------------------------//
//-------------------------------- Assignments --------------------------------//
//-----------------------------------------------------------------------------//
assign wc_o 		= wc_w;
assign payload_o	= payload_w;
assign payload_en_o	= payload_en_w;
assign lp_av_en_o	= lp_av_en_w;

assign lp_d0_tx_en_w	= 1'b0;	
assign lp_d0_tx_p_w		= 1'b1;	
assign lp_d0_tx_n_w		= 1'b1;	

//-----------------------------------------------------------------------------//
//--------------------------- Reset synchronizers -----------------------------//
//-----------------------------------------------------------------------------//

always @(posedge clk_byte_fr_i or negedge reset_n_i) begin: rst_byte_fr_ff_sync
	if (~reset_n_i) begin
		rx_reset_byte_fr_n_meta_r	<= 1'b0;
		rx_reset_byte_fr_n_sync_r	<= 1'b0;
	end
	else begin
		rx_reset_byte_fr_n_meta_r	<= reset_n_i;
		rx_reset_byte_fr_n_sync_r	<= rx_reset_byte_fr_n_meta_r;	
	end
end

always @(posedge clk_byte_o or negedge reset_n_i) begin: rst_byte_ff_sync
	if (~reset_n_i) begin
		rx_reset_byte_n_meta_r	<= 1'b0;
		rx_reset_byte_n_sync_r	<= 1'b0;
	end
	else begin
		rx_reset_byte_n_meta_r	<= reset_n_i;
		rx_reset_byte_n_sync_r	<= rx_reset_byte_n_meta_r;	
	end
end


always @(posedge clk_pixel_i or negedge reset_n_i) begin: rst_pixel_ff_sync
	if (~reset_n_i) begin
		b2p_reset_pixel_n_meta_r	<= 1'b0;
		b2p_reset_pixel_n_sync_r	<= 1'b0;
	end
	else begin
		b2p_reset_pixel_n_meta_r	<= reset_n_i;
		b2p_reset_pixel_n_sync_r	<= b2p_reset_pixel_n_meta_r;	
	end
end

always @(posedge clk_lp_ctrl_i or negedge reset_n_i) begin: rst_lp_ff_sync
	if (~reset_n_i) begin
		rx_reset_lp_n_meta_r	<= 1'b0;
		rx_reset_lp_n_sync_r	<= 1'b0;
	end
	else begin
		rx_reset_lp_n_meta_r	<= reset_n_i;
		rx_reset_lp_n_sync_r	<= rx_reset_lp_n_meta_r;	
	end
end

//-----------------------------------------------------------------------------//
//---------------------------- IP Instantiation -------------------------------//
//-----------------------------------------------------------------------------//

rx_dphy rx_dphy_inst(
	.clk_lp_ctrl_i				(clk_lp_ctrl_i),					// clock to LP HS Controller on CLK lane
	.clk_byte_fr_i				(clk_byte_fr_i),					// continuous byte clock, could be clk_byte_o/clk_byte_hs/refclk
	
	.reset_n_i					(reset_n_i),						// Reset, active low
	.reset_lp_n_i				(rx_reset_lp_n_sync_r),				// Reset to FFs using clk_lp_ctrl_i, active low
	.reset_byte_n_i				(rx_reset_byte_n_sync_r),			// Reset to FFs using clk_byte, active low
	.reset_byte_fr_n_i			(rx_reset_byte_fr_n_sync_r),		// Reset to FFs using clk_byte_fr_i, active low
	`ifdef RX_DPHY_HARD
	.pd_dphy_i					(pd_dphy_i),						// Power down for MIXEL DPHY
	`endif				
	.pll_lock_i					(pll_lock_clk_byte_fr_i),			// PLL lock indicator, active high; set to 1 if PLL is not in use
	
	///// MIPI I/F
	.clk_p_i					(clk_p_io),			// DPHY clock (p)
	.clk_n_i					(clk_n_io),			// DPHY clock (n)
	`ifdef RX_TYPE_DSI
	.d0_p_io					(d_p_io[0]),		// DPHY D0 (p) in DSI
	.d0_n_io					(d_n_io[0]),		// DPHY D0 (n) in DSI
	`elsif RX_TYPE_CSI2
	.d0_p_i						(d_p_io[0]),		// DPHY D0 (p) in CSI-2
	.d0_n_i						(d_n_io[0]),		// DPHY D0 (n) in CSI-2
	`endif
	`ifndef NUM_RX_LANE_1
	.d1_p_i						(d_p_io[1]),		// DPHY D1 (p)
	.d1_n_i						(d_n_io[1]),		// DPHY D1 (n)
	`ifndef NUM_RX_LANE_2
	.d2_p_i						(d_p_io[2]),		// DPHY D2 (p)
	.d2_n_i						(d_n_io[2]),		// DPHY D2 (n)
	`ifndef NUM_RX_LANE_3
	.d3_p_i						(d_p_io[3]),		// DPHY D3 (p)
	.d3_n_i						(d_n_io[3]),		// DPHY D3 (n)
	`endif
	`endif
	`endif
	
	`ifdef RX_TYPE_DSI
	// from fabric. Not used in this design!
	.lp_d0_tx_en_i				(lp_d0_tx_en_w),	// LP Tx Data Enable on D0, active high
	.lp_d0_tx_p_i				(lp_d0_tx_p_w),		// LP Tx Data on D0 (p)
	.lp_d0_tx_n_i				(lp_d0_tx_n_w),		// LP Tx Data on D0 (n)
	`endif
	
	// output clocks	
	.clk_byte_o					(clk_byte_o),		// toggling only when DPHY data is in HS mode
	.clk_byte_hs_o				(clk_byte_hs_o),	// toggling when DPHY clk is in HS mode 
																
	///// outputs to fabric. for low power signalling
	// Not used in this design!
	.lp_d0_rx_p_o				(lp_d_rx_p_w[0]),		// LP Rx Data on D0 (p)
	.lp_d0_rx_n_o				(lp_d_rx_n_w[0]),		// LP Rx Data on D0 (n)
	`ifndef NUM_RX_LANE_1
	.lp_d1_rx_p_o				(lp_d_rx_p_w[1]),		// LP Rx Data on D1 (p)
	.lp_d1_rx_n_o				(lp_d_rx_n_w[1]),		// LP Rx Data on D1 (n)
	`ifndef NUM_RX_LANE_2
	.lp_d2_rx_p_o				(lp_d_rx_p_w[2]),		// LP Rx Data on D2 (p)
	.lp_d2_rx_n_o				(lp_d_rx_n_w[2]),		// LP Rx Data on D2 (n)
	`ifndef NUM_RX_LANE_3
	.lp_d3_rx_p_o				(lp_d_rx_p_w[3]),		// LP Rx Data on D3 (p)
	.lp_d3_rx_n_o				(lp_d_rx_n_w[3]),		// LP Rx Data on D3 (n)
	`endif
	`endif
	`endif
	.cd_d0_o					(cd_d0_w),				// Contenion Detection on D0
	
	///// outputs when PARSER is enabled
	.sp_en_o					(sp_en_w),		// Short Packet Enable, active high
	.lp_en_o					(lp_en_w),		// Long Packet Enable, active high
	.lp_av_en_o					(lp_av_en_w),	// Active Video Long Packet Enable, active high
	.dt_o						(dt_w),			// Data Type    
	.vc_o						(vc_w),			// Virtual Channel. Not used in this design
	.wc_o						(wc_w),			// Byte count
	.bd_o						(bd_w),			// DPHY Byte Data (Gear8 only). Not used in this design
	.ecc_o						(ecc_w),		// ECC. Not checked/corrected in this design!
	
	`ifdef NUM_RX_LANE_4
	`ifdef RX_GEAR_16
	// 2nd set of header. in cases where data width (rx_gear*num_rx_lane) is 64 
	.sp2_en_o					(sp2_en_w),		// Short Packet Enable, active high
	.lp2_en_o					(lp2_en_w),		// Long Packet Enable, active high
	.lp2_av_en_o				(lp2_av_en_w),	// Active Video Long Packet Enable, active high
	.dt2_o						(dt2_w),		// Data Type    
	.vc2_o						(vc2_w),		// Virtual Channel
	.wc2_o						(wc2_w),		// Byte count
	.ecc2_o						(ecc2_w),		// ECC #2 (only for 4lane Gear16)
	`endif
	`endif
	.ref_dt_i					(`REF_DT),

	// data & valid
	.payload_en_o				(payload_en_w),		// Payload Enable, active high
	.payload_o					(payload_w),
	
	///// Debug only outputs (or potential customer use)
	.term_clk_en_o				(term_clk_en_w),		// Termination Enable on CLK, active high
	.hs_d_en_o					(hs_d_en_w),			// HS mode Enable on D0, active high
	.lp_hs_state_clk_o			(lp_hs_state_clk_w),	// LP HS Controller (CLK) state machine
	.lp_hs_state_d_o			(lp_hs_state_d_w),		// LP HS Controller (D0) state machine
	.hs_sync_o					(hs_sync_w)				// HS Sync, active high
);

b2p b2p_inst(
	.reset_byte_n_i		(rx_reset_byte_fr_n_sync_r),
	.clk_byte_i			(clk_byte_fr_i),
	.sp_en_i			(sp_en_w),		// Short Packet Enable
	.dt_i				(dt_w),			// Data Type
	.lp_av_en_i			(lp_av_en_w),	// Long Packet of Active Video Enable
	.wc_i				(wc_w),			// payload byte count
	`ifdef NUM_RX_LANE_4
	`ifdef RX_GEAR_16
	.sp2_en_i			(sp2_en_w),			// Short Packet Enable #2
	.dt2_i				(dt2_w),			// Data Type #2
	.lp2_av_en_i		(lp2_av_en_w),		// Long Packet of Active Video Enable #2
	.wc2_i				(wc2_w),			// payload byte count #2
	`endif
	`endif
	.payload_en_i		(payload_en_w),			// paload enable
	.payload_i			(payload_w),			// payload
						
	.reset_pixel_n_i	(b2p_reset_pixel_n_sync_r),
	.clk_pixel_i		(clk_pixel_i),
	`ifdef RX_TYPE_DSI
	.de_o				(de_o),			// picture data enable
	.vsync_o			(vsync_o),		// Vsync in clk_pixel domain
	.hsync_o			(hsync_o),		// Hsync in clk_pixel domain
	`elsif RX_TYPE_CSI2
	.fv_o				(fv_o),			// Frame Valid in clk_pixel domain
	.lv_o				(lv_o),			// Line Valid in clk_pixel domain
	`endif
	.pd_o				(pd_o),			// picture data
	.p_odd_o			(p_odd_o)		// odd pixel indicator
);

endmodule 
