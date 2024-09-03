//===========================================================================
// Filename: mipi2lvds_tb.v
// Copyright(c) 2019 Lattice Semiconductor Corporation. All rights reserved. 
//===========================================================================

`timescale 1 ns / 1 ps

`include "../source/verilog/synthesis_directives.v"
`include "../testbench/verilog/simulation_directives.v"
`include "../testbench/verilog/tb_include/dsi_model.v"
`include "../testbench/verilog/tb_include/csi2_model.v"
`include "../testbench/verilog/tb_include/vsync_hsync_checker.v"

`ifndef DSI_HSA_PAYLOAD
	`define DSI_HSA_PAYLOAD 16'h007A
`endif

`ifndef DSI_BLLP_PAYLOAD
	`define DSI_BLLP_PAYLOAD 16'h193A
`endif

`ifndef DSI_HBP_PAYLOAD
	`define DSI_HBP_PAYLOAD 16'h01AE
`endif

`ifndef DSI_HFP_PAYLOAD
	`define DSI_HFP_PAYLOAD 16'h0100
`endif

`ifndef DSI_VSA_LINES 
	`define DSI_VSA_LINES 5
`endif

`ifndef DSI_VBP_LINES 
	`define DSI_VBP_LINES 6
`endif

`ifndef DSI_VFP_LINES 
	`define DSI_VFP_LINES 4
`endif

`ifndef DSI_EOTP_ENABLE 
	`define DSI_EOTP_ENABLE 0
`endif


`ifndef DSI_LPS_HBP_DURATION 
	`define DSI_LPS_HBP_DURATION 800000
`endif

`ifndef DSI_LPS_HFP_DURATION 
	`define DSI_LPS_HFP_DURATION 500000
`endif

`ifndef DPHY_LPS_GAP
	`define DPHY_LPS_GAP 5000000
`endif

`ifndef VIRTUAL_CHANNEL 
	`define VIRTUAL_CHANNEL 2'h0
`endif

`ifdef RX_TYPE_DSI
		`ifdef RX_RGB666_LOOSE
				`define VIDEO_DATA_TYPE 6'h2E
		`elsif RX_RGB666
				`define VIDEO_DATA_TYPE 6'h1E
		`elsif RX_RGB888
				`define VIDEO_DATA_TYPE 6'h3E
		`endif
`elsif RX_TYPE_CSI2
		`ifdef RX_RGB888
				`define VIDEO_DATA_TYPE 6'h24
		`elsif RX_RAW8
				`define VIDEO_DATA_TYPE 6'h2A
		`elsif RX_RAW10
				`define VIDEO_DATA_TYPE 6'h2B
		`elsif RX_RAW12
				`define VIDEO_DATA_TYPE 6'h2C
		`elsif RX_YUV_420_8
				`define VIDEO_DATA_TYPE 6'h18
		`elsif RX_YUV_420_8_CSPS
				`define VIDEO_DATA_TYPE 6'h1C
		`elsif RX_LEGACY_YUV_420_8
				`define VIDEO_DATA_TYPE 6'h1A
		`elsif RX_YUV_420_10
				`define VIDEO_DATA_TYPE 6'h19
		`elsif RX_YUV_420_10_CSPS
				`define VIDEO_DATA_TYPE 6'h1D
		`elsif RX_YUV_422_8
				`define VIDEO_DATA_TYPE 6'h1E
		`elsif RX_YUV_422_10
				`define VIDEO_DATA_TYPE 6'h1F
		`endif
`endif

`ifndef FRAME_LPM_DELAY
	`define FRAME_LPM_DELAY 160000000 
`endif

`ifndef READY_DURATION
	`define READY_DURATION 1500000
`endif

module mipi2parallel_MD_tb();
`ifdef RX_DPHY_HARD
		parameter RX_DPHY = "HARD";
`else
		parameter RX_DPHY = "SOFT";
`endif


`ifdef RX_RGB888
		parameter RX_PD_BUS_WIDTH = 24;
		parameter RX_DT = "RGB888";
		parameter vact_payload = `NUM_PIXELS*3;
`elsif RX_RGB666_LOOSE
		parameter RX_PD_BUS_WIDTH = 18;
		parameter RX_DT = "RGB666_LP";
		parameter vact_payload = `NUM_PIXELS*3;
`elsif RX_RGB666
		parameter RX_PD_BUS_WIDTH = 18;
		parameter RX_DT = "RGB666";
		parameter vact_payload = `NUM_PIXELS*18/8;
`elsif RX_RAW8
		parameter RX_PD_BUS_WIDTH = 8;
		parameter RX_DT = "RAW8";
		parameter vact_payload = `NUM_PIXELS;
`elsif RX_RAW10
		parameter RX_PD_BUS_WIDTH = 10;
		parameter RX_DT = "RAW10";
		parameter vact_payload = `NUM_PIXELS*10/8;
`elsif RX_RAW12
		parameter RX_PD_BUS_WIDTH = 12;
		parameter RX_DT = "RAW12";
		parameter vact_payload = `NUM_PIXELS*12/8;
`elsif RX_YUV_420_8
		parameter RX_PD_BUS_WIDTH = 8;
		parameter RX_DT = "YUV_420_8";
		parameter vact_payload = `NUM_PIXELS*8/8;
`elsif RX_YUV_420_8_CSPS
		parameter RX_PD_BUS_WIDTH = 8;
		parameter RX_DT = "YUV_420_8_CSPS";
		parameter vact_payload = `NUM_PIXELS*8/8;
`elsif RX_LEGACY_YUV_420_8
		parameter RX_PD_BUS_WIDTH = 8;
		parameter RX_DT = "LEGACY_YUV_420_8";
		parameter vact_payload = `NUM_PIXELS*8/8;
`elsif RX_YUV_420_10
		parameter RX_PD_BUS_WIDTH = 10;
		parameter RX_DT = "YUV_420_10";
		parameter vact_payload = `NUM_PIXELS*10/8;
`elsif RX_YUV_420_10_CSPS
		parameter RX_PD_BUS_WIDTH = 10;
		parameter RX_DT = "YUV_420_10_CSPS";
		parameter vact_payload = `NUM_PIXELS*10/8;
`elsif RX_YUV_422_8
		parameter RX_PD_BUS_WIDTH = 8;
		parameter RX_DT = "YUV_422_8";
		parameter vact_payload = `NUM_PIXELS*8/8;
`elsif RX_YUV_422_10
		parameter RX_PD_BUS_WIDTH = 10;
		parameter RX_DT = "YUV_422_10";
		parameter vact_payload = `NUM_PIXELS*10/8;
`endif

`ifdef RX_CLK_MODE_HS_LP
		parameter RX_CLK_MODE = "HS_LP";
`else
		parameter RX_CLK_MODE = "HS_ONLY";
`endif

`ifdef SYNC_POLARITY_NEG
		parameter SYNC_POL = "NEGATIVE";
`else
		parameter SYNC_POL = "POSITIVE";
`endif
parameter DE_POL = "POSITIVE";
`ifdef RX_TYPE_CSI2
		parameter RX_TYPE = "CSI2";
`else
		parameter RX_TYPE = "DSI";
`endif

`ifdef NUM_RX_LANE_1
	`define DPHY_LANE 1
`elsif NUM_RX_LANE_2
	`define DPHY_LANE 2
`else
	`define DPHY_LANE 4 
`endif
`ifdef DPHY_DEBUG_ON
  `define DPHY_DEBUG_ON_VALUE 1
`else 
  `define DPHY_DEBUG_ON_VALUE 0
`endif
	// Design parameters
	parameter dphy_num_lane = `DPHY_LANE; //number of dphy data lanes. currently, design only supports 4 lanes
	parameter integer dphy_clk_period = `DPHY_CLK; //in ps, clock period of DPHY. 

	// Testbench parameters for video data
	parameter num_frames = `NUM_FRAMES; // number of frames
	parameter num_lines = `NUM_LINES; //number of video lines
	`ifndef DPHY_LPX
	  parameter t_lpx = 74000; 
	`else
	  parameter t_lpx = `DPHY_LPX; //in ps, min of 74ns
	`endif

	`ifndef DPHY_CLK_PREPARE
	  //parameter t_clk_prepare = 38000; //in ps, set between 38 to 95 ns
	  parameter t_clk_prepare = 51000; //in ps, set between 38 to 95 ns
	`else
	  parameter t_clk_prepare = `DPHY_CLK_PREPARE; //in ps, set between 38 to 95 ns
	`endif
	`ifndef DPHY_CLK_ZERO
	  parameter t_clk_zero = 262000; //in ps, (clk_prepare + clk_zero minimum should be 300ns)
	`else
	  parameter t_clk_zero = `DPHY_CLK_ZERO; //in ps, (clk_prepare + clk_zero minimum should be 300ns)
	`endif
	`ifndef DPHY_CLK_PRE
	  parameter t_clk_pre = 8*(dphy_clk_period/2); // in ps, minimum of 8*UI
	`else
	  parameter t_clk_pre = `DPHY_CLK_PRE;
	`endif
	`ifndef DPHY_CLK_POST
	  parameter t_clk_post = (60000 + (52*dphy_clk_period/2)); // in ps, minimum of 60ns+52*UI
	`else
	  parameter t_clk_post = `DPHY_CLK_POST; // in ps, minimum of 60ns+52*UI
	`endif
	`ifndef DPHY_CLK_TRAIL
	  parameter t_clk_trail = 60000; //in ps, minimum of 60ns
	`else
	  parameter t_clk_trail = `DPHY_CLK_TRAIL; //in ps, minimum of 60ns
	`endif
	`ifndef DPHY_HS_PREPARE
	  //parameter t_hs_prepare = (40000 + (4*dphy_clk_period/2)); //in ps, set between 40ns+4*UI to max of 85ns+6*UI
	  parameter t_hs_prepare = 51000; //in ps, set between 40ns+4*UI to max of 85ns+6*UI
	`else
	  parameter t_hs_prepare = `DPHY_HS_PREPARE; //in ps, set between 40ns+4*UI to max of 85ns+6*UI
	`endif
	`ifndef DPHY_HS_ZERO
	  parameter t_hs_zero = ((145000 + (10*dphy_clk_period/2)) - t_hs_prepare); //in ps, hs_prepare + hs_zero minimum should be 145ns+10*UI
	`else
	  parameter t_hs_zero = `DPHY_HS_ZERO; //in ps, hs_prepare + hs_zero minimum should be 145ns+10*UI
	`endif
	`ifndef DPHY_HS_TRAIL
	  parameter t_hs_trail = ((60000 + (4*dphy_clk_period/2)) + (105000 + (12*dphy_clk_period/2)))/2; //in ps, minimum should be 60ns+4*UI, max should be 105ns+12*UI
	`else
	  parameter t_hs_trail = `DPHY_HS_TRAIL; //in ps, minimum should be 60ns+4*UI, max should be 105ns+12*UI
	`endif
  
	`ifndef DPHY_INIT
	  parameter t_init = 100000000; //in ps
	`else
	  parameter t_init = `DPHY_INIT;
	`endif

`ifndef DPHY_LPS_GAP 
	parameter lps_gap = 5000000;
`else
	parameter lps_gap = `DPHY_LPS_GAP;
`endif

`ifndef DPHY_INIT_DRIVE_DELAY
	`ifdef EXT_REF_CLK
	parameter init_drive_delay = 100000;
	`else
	parameter init_drive_delay = 80000000;
	`endif
`else
	parameter init_drive_delay = `DPHY_INIT_DRIVE_DELAY;
`endif 


`ifndef LS_LE_EN
		parameter ls_le_en = 0;
`else
		parameter ls_le_en = 1;
`endif


	`ifdef RX_TYPE_DSI
	parameter hsa_payload = `DSI_HSA_PAYLOAD; //HSA 2-byte word count (number of bytes of payload, see MIPI DSI spec v1.1 figure 30), used for Non-burst sync pulse
	//parameter bllp_payload = `DSI_BLLP_PAYLOAD; //BLLP 2-byte word count (number of bytes of payload, see MIPI DSI spec v1.1 figure 30), used for HS_ONLY mode
	parameter bllp_payload = `DSI_HFP_PAYLOAD + vact_payload + `DSI_HBP_PAYLOAD; //HFP + RGB_BYTE_DATA + HBP , used for HS_ONLY mode
	parameter hbp_payload = `DSI_HBP_PAYLOAD; //HBP 2-byte word count (number of bytes of payload, see MIPI DSI spec v1.1 figure 30), used for HS_ONLY mode and HS_LP Non-burst sync pulse
	parameter hfp_payload = `DSI_HFP_PAYLOAD; //HFP 2-byte word count (number of bytes of payload, see MIPI DSI spec v1.1 figure 30), used for HS_ONLY mode and HS_LP Non-burst sync pulse
	//parameter lps_bllp_duration = `DSI_LPS_BLLP_DURATION; // in ps, used for HS_LP mode, this pertains to the LP-11 state duration for blanking
	`ifdef NON_BURST_SYNC_EVENTS
	parameter vact_payload_duration = ((dphy_clk_period/2)*(8/`NUM_RX_LANE)*(vact_payload + 6)); // 6 bytes overhead 
	parameter lps_bllp_duration = (`DSI_LPS_HFP_DURATION + vact_payload_duration +`DSI_LPS_HBP_DURATION) + (t_hs_trail + t_clk_post + t_clk_trail + t_lpx + t_clk_prepare + t_clk_zero + t_clk_pre + t_lpx + t_hs_prepare + t_hs_zero); // in ps, used for HS_LP mode, this pertains to the LP-11 state duration for blanking
	`elsif BURST_MODE
	parameter lps_bllp_duration = `DSI_LPS_BLLP_DURATION; // in ps, used for HS_LP mode, this pertains to the LP-11 state duration for blanking
	`else // Non burst sync pulse
	//parameter lps_bllp_duration = ((`DSI_HFP_PAYLOAD + vact_payload + `DSI_HBP_PAYLOAD)*(dphy_clk_period/2)*(8/`NUM_RX_LANE)); // in ps, used for HS_LP mode, this pertains to the LP-11 state duration for blanking
	parameter lps_bllp_duration = ((`DSI_HFP_PAYLOAD + vact_payload + `DSI_HBP_PAYLOAD + 18 )*(dphy_clk_period/2)*(8/`NUM_RX_LANE)) - (t_hs_trail + t_clk_post + t_clk_trail + t_lpx + t_clk_prepare + t_clk_zero + t_clk_pre + t_lpx + t_hs_prepare + t_hs_zero); // in ps, used for HS_LP mode, this pertains to the LP-11 state duration for blanking // 18 bytes overhead of all three payloads
	//parameter lps_bllp_duration = ((`DSI_HFP_PAYLOAD + vact_payload + `DSI_HBP_PAYLOAD + 18 )*(dphy_clk_period/2)*(8/`NUM_RX_LANE)) - (t_hs_trail + t_clk_post + t_clk_trail + 2*(t_lpx + t_clk_prepare + t_clk_zero + t_clk_pre + t_lpx + t_hs_prepare + t_hs_zero)); // in ps, used for HS_LP mode, this pertains to the LP-11 state duration for blanking // 18 bytes overhead of all three payloads
	`endif
	parameter lps_hbp_duration = `DSI_LPS_HBP_DURATION; // in ps, used for HS_LP Non-burst sync events and burst mode, this pertains to the LP-11 state duration for horizontal back porch
	parameter lps_hfp_duration = `DSI_LPS_HFP_DURATION; // in ps, used for HS_LP Non-burst sync events and burst mode, this pertains to the LP-11 state duration for horizontal front porch
	`endif
	parameter virtual_channel = `VIRTUAL_CHANNEL; // virtual channel ID. example: 2'h0 
	parameter video_data_type = `VIDEO_DATA_TYPE; // video data type DI. example: 6'h3E = RGB888 
	parameter vsa_lines = `DSI_VSA_LINES; // number of VSA lines, see MIPI DSI spec v1.1 figure 30
	parameter vbp_lines = `DSI_VBP_LINES; // number of VBP lines, see MIPI DSI spec v1.1 figure 30
	parameter vfp_lines = `DSI_VFP_LINES; // number of VFP lines, see MIPI DSI spec v1.1 figure 30
	parameter eotp_enable = `DSI_EOTP_ENABLE; // to enable/disable EOTP packet
	parameter debug_on = `DPHY_DEBUG_ON_VALUE; // for enabling/disabling DPHY data debug messages
	parameter frame_gap = `FRAME_LPM_DELAY; //delay between frames (in ps)
	parameter ready_duration = `READY_DURATION; //duration of ready_o assertion when miscellaneous signals are disabled (in ps)

`ifdef REF_CLK
	parameter refclk_period = `REF_CLK;
`endif

parameter SLAVE_ADDR = {`I2C_TARGET_ADR_MSB, 2'b10}; // LPG add to support I2C
parameter THSD = 625000;
tri1	scl, sda;
reg		scl_tb, sda_tb;
always @(scl_tb) begin
	if (scl_tb == 1'b1)
		release scl;
	else if (scl_tb == 1'b0)
		force scl = 1'b0;
	else
		release scl;
end

always @(sda_tb) begin
	if (sda_tb == 1'b1)
		release sda;
	else if (sda_tb == 1'b0)
		force sda = 1'b0;
	else
		release sda;
end
`include "../testbench/verilog/tb_include/i2c_tasks.v"

`ifdef RX_TYPE_DSI
integer exp_pixel_count ;
`else
localparam exp_pixel_count = `NUM_FRAMES * `NUM_LINES * `NUM_PIXELS;
`endif
integer actual_pixel_counter;
integer actual_byte_counter;
integer actual_byte_counter_debug;
integer exp_byte_count;

real dphy_clk;
reg dphy_clk_i;
reg rx_clk_byte_fr_i = 0;
//DUT input ports
reg resetn;
reg refclk_i;
wire clk_ch0_p_i;
wire clk_ch0_n_i;
wire d0_ch0_p_i;
wire d0_ch0_n_i;
wire d1_ch0_p_i;
wire d1_ch0_n_i;
wire d2_ch0_p_i;
wire d2_ch0_n_i;
wire d3_ch0_p_i;
wire d3_ch0_n_i;

wire clk_ch0_p_i_w;
wire clk_ch0_n_i_w;
wire d0_ch0_p_i_w;
wire d0_ch0_n_i_w;
wire d1_ch0_p_i_w;
wire d1_ch0_n_i_w;
wire d2_ch0_p_i_w;
wire d2_ch0_n_i_w;
wire d3_ch0_p_i_w;
wire d3_ch0_n_i_w;

assign clk_ch0_p_i_w = clk_ch0_p_i;
assign clk_ch0_n_i_w = clk_ch0_n_i;
assign d0_ch0_p_i_w = d0_ch0_p_i;
assign d0_ch0_n_i_w = d0_ch0_n_i;
assign d1_ch0_p_i_w = d1_ch0_p_i;
assign d1_ch0_n_i_w = d1_ch0_n_i;
assign d2_ch0_p_i_w = d2_ch0_p_i;
assign d2_ch0_n_i_w = d2_ch0_n_i;
assign d3_ch0_p_i_w = d3_ch0_p_i;
assign d3_ch0_n_i_w = d3_ch0_n_i;

//DUT port output
wire clk_pixel_w;
wire vsync_w;
wire hsync_w;
wire de_w;
wire fv_w;
wire lv_w;
wire vsync_i;
wire hsync_i;
wire de_i;
wire fv_i;
wire lv_i;
wire [RX_PD_BUS_WIDTH*`RX_PEL_PER_CLK-1:0] pd_w;
wire [1:0] p_odd_w;
wire lp_av_en_w;  
wire [15:0] wc_w;		  
wire rx_clk_byte_fr_w;
wire payload_en_w;	
wire [`NUM_RX_LANE*`RX_GEAR -1:0] payload_w;	  
reg enable_write_log=1;
integer  filedesc1;
integer  filedesc2;
integer  filedesc3;
integer  filedesc4;
integer  filedesc5;
integer  filedesc6;
integer  filedesc7;
integer  filedesc8;
integer err_i;
integer error_count ;

`ifdef RX_TYPE_DSI
reg [(RX_PD_BUS_WIDTH*`RX_PEL_PER_CLK)-1:0] log_out[`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS:1 ]  ;
reg [(RX_PD_BUS_WIDTH*`RX_PEL_PER_CLK)-1:0] log_in [`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS:1 ]  ;
`else
reg [(RX_PD_BUS_WIDTH*`RX_PEL_PER_CLK)-1:0] log_out [exp_pixel_count:1];
reg [(RX_PD_BUS_WIDTH*`RX_PEL_PER_CLK)-1:0] log_in  [exp_pixel_count:1];
`endif

`ifdef DPHY_DEBUG_ON
	`ifdef RX_RGB666_LOOSE // RGB666 is 24bits per pixel, but only 18 bits of actual data
		reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
		reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
	`else
		reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*RX_PD_BUS_WIDTH/8):1 ]  ;
		reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*RX_PD_BUS_WIDTH/8):1 ]  ;
	`endif
	// `ifdef RX_RGB888
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
	// `elsif RX_RGB666_LOOSE
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
	// `elsif RX_RGB666
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*18/8):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*18/8):1 ]  ;
	// `elsif RX_RAW8
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS):1 ]  ;
	// `elsif RX_RAW10
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*10/8):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*10/8):1 ]  ;
	// `elsif RX_RAW12
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*12/8):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte_debug[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*12/8):1 ]  ;
	// `endif
`endif
	`ifdef RX_RGB666_LOOSE // RGB666 is 24bits per pixel, but only 18 bits of actual data
		reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
		reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte [(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
	`else
		reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*RX_PD_BUS_WIDTH/8):1 ]  ;
		reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte [(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*RX_PD_BUS_WIDTH/8):1 ]  ;
	`endif
	// `ifdef RX_RGB888
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte [(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
	// `elsif RX_RGB666_LOOSE
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte [(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*3):1 ]  ;
	// `elsif RX_RGB666
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*18/8):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte [(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*18/8):1 ]  ;
	// `elsif RX_RAW8
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte [(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS):1 ]  ;
	// `elsif RX_RAW10
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*10/8):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte [(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*10/8):1 ]  ;
	// `elsif RX_RAW12
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_out_byte[(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*12/8):1 ]  ;
		// reg [(`NUM_RX_LANE*`RX_GEAR)-1:0] log_in_byte [(`NUM_FRAMES * `NUM_LINES * `NUM_PIXELS*12/8):1 ]  ;
	// `endif
`ifdef RX_TYPE_DSI
reg  [32:0] hsync_time_diff;
realtime hsync_time [ 8000: 1];
reg [15:0] hsync_cnt = 0;


always @(posedge hsync_i) begin
	hsync_cnt = hsync_cnt + 1;	
	hsync_time[hsync_cnt] = $realtime;
end

initial begin
  forever begin 
  @(negedge hsync_i);
	hsync_time_diff = (hsync_cnt > 1) ? (hsync_time[hsync_cnt] - hsync_time[hsync_cnt - 1]) : 'b0 ;
	if (hsync_cnt > 1) begin
	  //$display("hsync_cnt\t", hsync_cnt, "\t hsync_time\t", hsync_time[hsync_cnt], "\t hsync_time_diff\t", hsync_time_diff);
	  write_to_file_time("line_length_in_dsi.log",hsync_time_diff);
	end
  end
end

task write_to_file_time ( input [1024*4-1:0]str_in, input [32:0] data);
	 integer filedesc;
 begin
	 filedesc = $fopen(str_in,"a");
	 $fwrite(filedesc, "%d\n", data);
	 $fclose(filedesc);
 end
endtask
`endif

`ifdef RX_TYPE_DSI
  `include "../testbench/verilog/tb_include/parallel_byte_checker_dsi.v"
`elsif RX_TYPE_CSI2
  `include "../testbench/verilog/tb_include/parallel_byte_checker_csi2.v"
`endif


always #(dphy_clk/2) dphy_clk_i = ~dphy_clk_i;
  initial begin
	if(enable_write_log == 1) begin
	 //filedesc1 = $fopen("expected_data_pixel.log","w");
	 //$fclose(filedesc1);
	 filedesc2 = $fopen("expected_data_byte.log","w");
	 $fclose(filedesc2);
	 //filedesc3 = $fopen("received_data_pixel.log","w");
	 //$fclose(filedesc3);
	 //filedesc4 = $fopen("received_data_byte_debug.log","w");
	 //$fclose(filedesc4);
	 //filedesc5 = $fopen("received_data_byte_debug_time.log","w");
	 //$fclose(filedesc5);
	 `ifdef RX_TYPE_DSI
		filedesc6 = $fopen("sync_data_in.log","w");
		$fclose(filedesc6);
		filedesc7 = $fopen("line_length_in_dsi.log","w");
		$fclose(filedesc7);
	 `endif
	 filedesc8 = $fopen("received_data_byte.log","w");
	 $fclose(filedesc8);
	end
	`ifdef RX_TYPE_DSI
	$display("  TIME of LPS_BLLP %h 	 %d",lps_bllp_duration,lps_bllp_duration);	
	$display("lps_bllp", lps_bllp_duration);
	$display("lps_hbp", lps_hbp_duration);
	$display("lps_hfp", lps_hfp_duration);
	`endif
  end

initial begin
  resetn = 0; //reset at start of sim
  refclk_i = 0;
  dphy_clk_i = 0;
  if(dphy_clk_period %2 > 0) begin
		  dphy_clk = dphy_clk_period - 1;
  end
  else begin
		  dphy_clk = dphy_clk_period;
  end

  $display("%0t TEST START\n",$realtime);
//	  #(dphy_clk_period*8*3);
  #(dphy_clk_period*8*23);
  resetn = 1;
  #150_000_000;
  $display("%t Waiting for PLL lock...\n", $time);
  //`ifdef RX_TYPE_DSI
	 if(mipi2parallel_top_inst.pll_lock_w == 0) begin
		@(posedge mipi2parallel_top_inst.pll_lock_w);
	 end
	 $display("%t PLL lock DONE\n", $time);

	// LPG add - use i2c to release software reset.
	if(`SW_RST_N == 1'b0) begin
		#100000;
		$display("%t Releasing SW_RST thru I2C \n", $time);
		if(mipi2parallel_top_inst.sw_reset_n == 1'b1) begin 
			$error("%t sw_reset_n already being asserted", $time);
			$stop;
		end
		I2C_REG_WR_MULTI(4'd1, 8'h00, 128'h1);
		if(mipi2parallel_top_inst.sw_reset_n == 1'b0) 
			@(posedge mipi2parallel_top_inst.sw_reset_n);
	end
	#100000;
	`ifdef RX_TYPE_DSI
		`ifdef RX_CLK_MODE_HS_ONLY
				if (mipi_rx.dphy_clk_start == 0) begin
						@(posedge mipi_rx.dphy_clk_start);
				end
		`endif
	`endif
	$display("%t MIPI D-PHY Clock begins...\n", $time);
	#100000;
	mipi_rx.dphy_active = 1;
	$display("%t Activating DSI/CSI-2 model\n", $time);
	@(negedge mipi_rx.dphy_active);
	#100000;
	
	//actual_pixel_counter = pixel_monitor.actual_pixel_count;
`ifdef RX_TYPE_DSI
	`ifdef RX_RGB666_LOOSE
		exp_pixel_count = mipi_rx.adjusted_vact_payload*`NUM_FRAMES*`NUM_LINES/3;
	`else
		exp_pixel_count = mipi_rx.adjusted_vact_payload*`NUM_FRAMES*`NUM_LINES*8/RX_PD_BUS_WIDTH;
	`endif
// `ifdef RX_RGB888
  // exp_pixel_count = mipi_rx.adjusted_vact_payload*`NUM_FRAMES*`NUM_LINES/3;
// `elsif RX_RGB666_LOOSE
  // exp_pixel_count = mipi_rx.adjusted_vact_payload*`NUM_FRAMES*`NUM_LINES/3;
// `elsif RX_RGB666
  // exp_pixel_count = mipi_rx.adjusted_vact_payload*`NUM_FRAMES*`NUM_LINES*8/18;
// `elsif RX_RAW8
  // exp_pixel_count = mipi_rx.adjusted_vact_payload*`NUM_FRAMES*`NUM_LINES;
// `elsif RX_RAW10
  // exp_pixel_count = mipi_rx.adjusted_vact_payload*`NUM_FRAMES*`NUM_LINES*8/10;
// `elsif RX_RAW12
  // exp_pixel_count = mipi_rx.adjusted_vact_payload*`NUM_FRAMES*`NUM_LINES*8/12;
// `endif
`endif

`ifdef DPHY_DEBUG_ON1
	actual_byte_counter_debug= payload_checker.rx_dphy_payload_checker_inst.total_word_count;
  `ifdef RX_TYPE_DSI
	exp_byte_count = mipi_rx.pixel_wc*`NUM_FRAMES*`NUM_LINES;
  `elsif RX_TYPE_CSI2
	exp_byte_count = mipi_rx.wc*`NUM_FRAMES*`NUM_LINES;
  `endif

if ( exp_byte_count!= actual_byte_counter_debug) begin 
	$display("---------------------------------------------");
	$display("*** E R R O R: Actual and Expected byte counts are not equal***");
	$display("**** I N F O : Actual Byte Count is %0d", actual_byte_counter_debug);
	$display("**** I N F O : Expected Byte Count is %0d", exp_byte_count);
	$display("---------------------------------------------");
	$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
	// $display("********** T E S T	 F A I L E D **********");
	$display("---------------------------------------------");
	$finish;
  end
  else begin
	$readmemh("expected_data_byte.log", log_in_byte_debug);
	$readmemh("received_data_byte_debug.log", log_out_byte_debug);
	if (log_in_byte_debug[1] === {(`NUM_RX_LANE*`RX_GEAR){1'bx}}) begin
	  $display("---------------------------------------------");
	  $display("---------------------------------------------");
	  $display("##### received_data_byte_debug.log FILE IS EMPTY ##### ");
	  $display("---------------------------------------------");
	  $display("---------------------------------------------");
	  $finish;
	end
	else begin
	  $display("---------------------------------------------");
	  $display("---------------------------------------------");
	  $display("##### DATA COMPARING FOR BYTES(WORD COUNT) IS STARTED ##### ");
	  $display("---------------------------------------------");
	  $display("---------------------------------------------");
	end
	err_i = 1;
	error_count = 0;
	repeat (actual_byte_counter_debug) begin
	 if (log_in_byte_debug[err_i] !== log_out_byte_debug[err_i]) begin
		$display("%0dns ERROR : Expected and Received datas (FOR BYTES - WORD COUNT) are not matching. Line%0d",$time, err_i);
		$display("		Expected  %h", log_in_byte_debug  [err_i]);
		$display("		Received  %h", log_out_byte_debug [err_i]);
		error_count = error_count + 1;
	 end  
	 err_i = err_i+1;
	end
	  if (error_count > 0) begin
		$display("---------------------------------------------");
		$display("**** I N F O : Actual Byte Count is %0d", actual_byte_counter_debug);
		$display("**** I N F O : Expected Byte Count is %0d", exp_byte_count);
		$display("**** I N F O : Error Count is %0d", error_count);
		$display("---------------------------------------------");
		$display("**** I N F O : NUM_FRAMES=%0d, NUM_LINES=%0d,WORD_COUNT PER LINE=%0d ", `NUM_FRAMES, `NUM_LINES, exp_byte_count );
		$display("---------------------------------------------");
		$display("-----------------------------------------------------");
		$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
		$display("-----------------------------------------------------");
	  $stop;
	  end
	  else begin
		$display("---------------------------------------------");
		$display("**** I N F O : Byte Count is %0d", actual_byte_counter_debug);
		$display("**** I N F O : NUM_FRAMES=%0d, NUM_LINES=%0d, WORD_COUNT PER LINE=%0d", `NUM_FRAMES, `NUM_LINES, exp_byte_count);
		$display("---------------------------------------------");
		$display("-----------------------------------------------------");
		$display("----------------- NOW PIXEL COMPARISON WILL START -----------------");
		$display("-----------------------------------------------------");
	  end
	  end

`endif

	actual_byte_counter= actual_byte_count;
  `ifdef RX_TYPE_DSI
	exp_byte_count = mipi_rx.pixel_wc*`NUM_FRAMES*`NUM_LINES;
  `elsif RX_TYPE_CSI2
	exp_byte_count = mipi_rx.wc*`NUM_FRAMES*`NUM_LINES;
  `endif
	if ( exp_byte_count!= actual_byte_counter) begin 
	 $display("---------------------------------------------");
	 $display("*** E R R O R: Actual and Expected byte counts are not equal***");
	 $display("**** I N F O : Actual Byte Count is %0d", actual_byte_counter);
	 $display("**** I N F O : Expected Byte Count is %0d", exp_byte_count);
	 $display("---------------------------------------------");
	 $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
	 $display("---------------------------------------------");
	 $finish;
	end
	else begin
		 $display("---------------------------------------------");
		 $display("**** I N F O : Byte Count is %0d", actual_byte_counter);
		 $display("**** I N F O : NUM_FRAMES=%0d, NUM_LINES=%0d, TOTAL BYTES =%0d", `NUM_FRAMES, `NUM_LINES, exp_byte_count);
		 $display("---------------------------------------------");
		 $display("-----------------------------------------------------");
		 $display("----------------- SIMULATION PASSED -----------------");
		 $display("-----------------------------------------------------");
		$display("%0t TEST END\n",$realtime);
		$stop;
		end

end

always #(refclk_period/2) refclk_i =~ refclk_i; 


GSR	 GSR_INST (.GSR (1'b1));
PUR		PUR_INST (.PUR (1'b1));
//GSR GSR_INST (1'b1, 1'b0);
//PUR PUR_INST(resetn);

`ifdef RX_TYPE_DSI
  dsi_model #(
	.PD_BUS_WIDTH	  (RX_PD_BUS_WIDTH  ),
	.RX_PEL_PER_CLK	(`RX_PEL_PER_CLK  ),
	.dphy_num_lane	 (dphy_num_lane	), 
	.dphy_clk_period	(dphy_clk_period  ),
	.num_frames		(num_frames		),
	.num_lines		 (num_lines		),	
	.t_lpx			 (t_lpx			),  
	.t_clk_prepare	 (t_clk_prepare	),  
	.t_clk_zero		(t_clk_zero		),  
	.t_clk_pre		 (t_clk_pre		),  
	.t_clk_post		(t_clk_post		),  
	.t_clk_trail		(t_clk_trail	  ),  
	.t_hs_prepare	  (t_hs_prepare	 ),  
	.t_hs_zero		 (t_hs_zero		),  
	.t_hs_trail		(t_hs_trail		), 
	.t_init			(t_init			), 
	.hsa_payload		(hsa_payload	  ),
	.bllp_payload	  (bllp_payload	 ),
	.hbp_payload		(hbp_payload	  ),
	.hfp_payload		(hfp_payload	  ),
	.lps_bllp_duration (lps_bllp_duration),
	.lps_hfp_duration  (lps_hfp_duration ),
	.lps_hbp_duration  (lps_hbp_duration ),
	.vact_payload	  (vact_payload	 ),
	.virtual_channel	(virtual_channel  ),
	.video_data_type	(video_data_type  ),
	.vsa_lines		 (vsa_lines		),
	.vbp_lines		 (vbp_lines		),
	.vfp_lines		 (vfp_lines		),
	.eotp_enable		(eotp_enable	  ),
	.frame_gap		 (frame_gap		),
	.debug_on		  (debug_on		 )  
  ) mipi_rx (
	  .resetn		 (resetn	 ),
	  .clk_p_i		(clk_ch0_p_i),
	  .clk_n_i		(clk_ch0_n_i),
	  .d0_p_io		(d0_ch0_p_i ),
	  .d0_n_io		(d0_ch0_n_i ),
	  .d1_p_i		 (d1_ch0_p_i ),
	  .d1_n_i		 (d1_ch0_n_i ),
	  .d2_p_i		 (d2_ch0_p_i ),
	  .d2_n_i		 (d2_ch0_n_i ),
	  .d3_p_i		 (d3_ch0_p_i ),
	  .d3_n_i		 (d3_ch0_n_i )
  );
`elsif RX_TYPE_CSI2
  wire [dphy_num_lane-1:0] ch0_do_p_i, ch0_do_n_i;
  assign d0_ch0_p_i = ch0_do_p_i[0];
  assign d0_ch0_n_i = ch0_do_n_i[0];
  `ifndef NUM_RX_LANE_1
  assign d1_ch0_p_i = ch0_do_p_i[1];
  assign d1_ch0_n_i = ch0_do_n_i[1];
  `ifdef NUM_RX_LANE_4
  assign d2_ch0_p_i = ch0_do_p_i[2];
  assign d2_ch0_n_i = ch0_do_n_i[2];
  assign d3_ch0_p_i = ch0_do_p_i[3];
  assign d3_ch0_n_i = ch0_do_n_i[3];
  `endif
  `endif
  csi2_model #(
	.PD_BUS_WIDTH			(RX_PD_BUS_WIDTH	),
	.RX_PEL_PER_CLK		 (`RX_PEL_PER_CLK	),
	.vc_mode				("PASS_THROUGH"	),  
	.clk_mode				(RX_CLK_MODE		),
	.num_lines			  (num_lines		 ),  
	.num_pixels			 (`NUM_PIXELS		),  
	.num_payload			(vact_payload	  ),  
	.num_frames			 (num_frames		),
	.active_dphy_lanes	  (dphy_num_lane	 ),  
	.dphy_clk_period		(dphy_clk_period	),  
	.data_type			  (video_data_type	),
	.frame_counter		  ("OFF"			 ),
	.frame_count_max		(2				 ),
	.t_lpx				  (t_lpx			 ),  
	.t_clk_prepare		  (t_clk_prepare	 ),  
	.t_clk_zero			 (t_clk_zero		),  
	.t_clk_trail			(t_clk_trail		),  
	.t_clk_pre			  (t_clk_pre		 ),
	.t_clk_post			 (t_clk_post		),
	.t_hs_prepare			(t_hs_prepare	  ),  
	.t_hs_zero			  (t_hs_zero		 ),  
	.t_hs_trail			 (t_hs_trail		),  
	.lps_gap				(lps_gap			),  
	.frame_gap			  (frame_gap		 ),
	.init_drive_delay		(init_drive_delay  ),
	.dphy_ch				(0				 ),
	.dphy_vc				(virtual_channel	),
	.new_vc				 (1				 ),
	.long_even_line_en	  (0				 ),
	.ls_le_en				(ls_le_en		  ),
	.fnum_embed			 ("OFF"			 ),
	.fnum_max				(2				 ),
	.debug				  (debug_on		  )
  ) mipi_rx (
	  .refclk_i				(dphy_clk_i		),
	  .resetn				 (resetn			),
  `ifndef RX_CLK_MODE_HS_ONLY				// HS_LP
	  .clk_p_i				(clk_ch0_p_i		),
	  .clk_n_i				(clk_ch0_n_i		),
	  .cont_clk_p_i			(				  ),
	  .cont_clk_n_i			(				  ),
  `else							// HS_ONLY
	  .clk_p_i				(				  ),
	  .clk_n_i				(				  ),
	  .cont_clk_p_i			(clk_ch0_p_i		),
	  .cont_clk_n_i			(clk_ch0_n_i		),
  `endif
	  .do_p_i				 (ch0_do_p_i		),
	  .do_n_i				 (ch0_do_n_i		)
  );
`endif

generate
  if(SYNC_POL == "POSITIVE") begin: PM_positive
	assign vsync_i		= vsync_w;
	assign hsync_i		= hsync_w;
	assign de_i		  = de_w;					
	assign fv_i = fv_w;
	assign lv_i  = lv_w;
  end					  
  else begin: PM_negative						
	assign vsync_i		= ~vsync_w;
	assign hsync_i		= ~hsync_w;
	assign de_i		 = de_w;					
	assign fv_i = ~fv_w;
	assign lv_i = ~lv_w;
  end
endgenerate 

`ifdef VSYNC_HSYNC_CHECK
  vsync_hsync_checker #(
  .RX_DT		(RX_DT						),
  .RX_DPHY	 (RX_DPHY	 				),
  .RX_CLK_MODE (RX_CLK_MODE 				),
  .NUM_RX_LANE (`NUM_RX_LANE				),
  .HSYNC_WIDTH (`HSYNC_WIDTH				),
  .VSYNC_WIDTH (`VSYNC_WIDTH				),
  .SIM_STOP	(`SIM_STOP_AT_HSYNC_VSYNC_WIDTH_FAIL),
  .RX_GEAR	 (`RX_GEAR	) 
  ) 
  vsync_hsync_checker_inst(
	.clk_pixel_i	  (clk_pixel_w),
	.vsync_i		  (vsync_i),
	.hsync_i		  (hsync_i)
  );
`endif

`ifdef DPHY_DEBUG_ON1
  generate 
	if(~(`NUM_RX_LANE == 4 && `RX_GEAR == 16)) begin : payload_checker 
	  rx_dphy_payload_checker #(
		.NUM_RX_LANE (`NUM_RX_LANE),
		.RX_GEAR	 (`RX_GEAR	) 
		) 
		rx_dphy_payload_checker_inst (
		.lp_av_en_i	 (lp_av_en_w	  ),
		.wc_i		 (wc_w		  ),
		.rx_clk_byte_fr_i	 (rx_clk_byte_fr_w),
		.payload_en_i		 (payload_en_w	),
		.payload_i 	 (payload_w	  )
		);
	  end
  endgenerate
`endif

// mipi2parallel mipi2parallel_top_inst
// (
	// `ifdef DPHY_DEBUG_ON
  // .lp_av_en_o(lp_av_en_w),	 
  // .wc_o(wc_w),		 
  // .rx_clk_byte_fr_o(rx_clk_byte_fr_w),
  // .payload_o(payload_w),
  // .payload_en_o(payload_en_w),
	// `endif
  // `ifdef RX_CLK_MODE_HS_LP
  // .ref_clk_i(refclk_i),
  // `endif
  // .reset_n_i(resetn), 
  // // DPHY interface 
  // .clk_p_i(clk_ch0_p_i_w ), 
  // .clk_n_i(clk_ch0_n_i_w ),
  // `ifdef NUM_RX_LANE_1
	 // .d_p_io(d0_ch0_p_i_w), 
	 // .d_n_io(d0_ch0_n_i_w), 
  // `elsif NUM_RX_LANE_2
	 // .d_p_io({d1_ch0_p_i_w,d0_ch0_p_i_w}),
	 // .d_n_io({d1_ch0_n_i_w,d0_ch0_n_i_w}),
  // `else //NUM_RX_LANE_4
	 // .d_p_io({d3_ch0_p_i_w,d2_ch0_p_i_w,d1_ch0_p_i_w,d0_ch0_p_i_w}),
	 // .d_n_io({d3_ch0_n_i_w,d2_ch0_n_i_w,d1_ch0_n_i_w,d0_ch0_n_i_w}),
	// `endif
  // `ifdef RX_TYPE_DSI
	 // .vsync_o(vsync_w),
	 // .hsync_o(hsync_w),
	 // .de_o(de_w),
  // `elsif RX_TYPE_CSI2
	 // .fv_o(fv_w),
	 // .lv_o(lv_w),
  // `endif
	 // .clk_pixel_o(clk_pixel_w),
	 // .p_odd_o(p_odd_w),
	 // .pd_o(pd_w)
// );

mipi2parallel_top mipi2parallel_top_inst(
	// Reset and clocks		
	.reset_n_i				(resetn),		// Async reset
	.ref_clk_i				(refclk_i),		// Assumed 27MHz oscillator
	
	// DPHY data and clk pins				
	.clk_p_io				(clk_ch0_p_i_w), 
	.clk_n_io				(clk_ch0_n_i_w),
	`ifdef NUM_RX_LANE_1
	.d_p_io					(d0_ch0_p_i_w), 
	.d_n_io					(d0_ch0_n_i_w),
	`elsif NUM_RX_LANE_2
	.d_p_io					({d1_ch0_p_i_w, d0_ch0_p_i_w}), 
	.d_n_io					({d1_ch0_n_i_w, d0_ch0_n_i_w}),
	`elsif NUM_RX_LANE_4
	.d_p_io					({d3_ch0_p_i_w, d2_ch0_p_i_w, d1_ch0_p_i_w, d0_ch0_p_i_w}), 
	.d_n_io					({d3_ch0_n_i_w, d2_ch0_n_i_w, d1_ch0_n_i_w, d0_ch0_n_i_w}),
	`endif
	// B2P outputs. Clocked by clk_pixel			
	.pd_o					(pd_w),		// Pixel data
//	.p_odd_o				(p_odd_w),		// Modulo 4 of pixel count. Can be used to indicate valid pixels in case of PPC > 1
	.clk_pixel_o			(clk_pixel_w),		// Pixel clock. Read clock for B2P
	`ifdef	RX_TYPE_DSI
	.vsync_o				(vsync_w),		// Only for DSI
	.hsync_o				(hsync_w),		// Only for DSI
	.de_o					(de_w),		// Only for DSI
	`elsif RX_TYPE_CSI2
	.fv_o					(fv_w),		// Only for CSI-2
	.lv_o					(lv_w),		// Only for CSI-2
	`endif
			
	// Debug signals. Clocked on clk_byte_fr domain.
	`ifdef DPHY_DEBUG_ON
	.payload_o				(payload_w),		// Output from RX DPHY before B2P
	.payload_en_o			(payload_en_w),		// RX DPHY Payload enable flag. OR'ed with multiple flags.
	.lp_av_en_o				(lp_av_en_w),		// RX DPHY Active video long packet flag.
	.wc_o					(wc_w),		// RX DPHY Word Count.
	.clk_byte_hs_o			(),		// RX DPHY output byte clock, geared down DPHY clock
	.clk_byte_fr_o			(rx_clk_byte_fr_w),		// Free running byte clock. Write clock for B2P
	`endif
	
	// I2C Target pins
	.scl_io					(scl),
	.sda_io					(sda)
);

endmodule