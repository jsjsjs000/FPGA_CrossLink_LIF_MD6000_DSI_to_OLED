//===========================================================================
// Filename: dsi_model.v
// Copyright(c) 2016 Lattice Semiconductor Corporation. All rights reserved. 
//===========================================================================
`timescale 1 ps / 1 ps


module dsi_model#(
   
   // Design parameters
   parameter PD_BUS_WIDTH = 24,
   parameter RX_PEL_PER_CLK = 1,
   parameter dphy_num_lane = 4, //number of dphy data lanes. 
   parameter dphy_clk_period = 1683, //in ps, clock period of DPHY. 
   // Testbench parameters for video data
   parameter num_frames = 1, // number of frames
   parameter num_lines = 1080, //number of video lines
   parameter t_lpx = 68000, //in ps, min of 50ns
   parameter t_clk_prepare = 51000, //in ps, set between 38ns to 95ns
   parameter t_clk_zero = 252503, //in ps, (clk_prepare + clk_zero minimum should be 300ns)
   parameter t_clk_pre = 10098, // in ps, minimum of 8*UI
   parameter t_clk_post = 186225, // in ps, minimum of 60ns+52*UI
   parameter t_clk_trail = 99297, //in ps, minimum of 60ns
   parameter t_hs_prepare = 55000, //in ps, set between 40ns+4*UI to max of 85ns+6*UI
   parameter t_hs_zero = 103543, //in ps, hs_prepare + hs_zero minimum should be 145ns+10*UI
   parameter t_hs_trail = 63366, //in ps, minimum should be 60ns+4*UI, max should be 105ns+12*UI
   parameter t_init = 100000000, //in ps, DPHY initialization requirement, min of 100us
   parameter hsa_payload = 16'h007A, //used for Non-burst sync pulse, HSA 2-byte word count (number of bytes of payload, see MIPI DSI spec v1.1 figure 30)
   parameter bllp_payload = 16'h193A, //used for HS_ONLY mode, BLLP 2-byte word count (number of bytes of payload, see MIPI DSI spec v1.1 figure 30)
   parameter hbp_payload = 16'h01AE, //used for HS_ONLY mode and HS_LP Non-burst sync pulse. HBP 2-byte word count (number of bytes of payload, see MIPI DSI spec v1.1 figure 30)
   parameter hfp_payload = 16'h0100, //used for HS_ONLY mode and HS_LP Non-burst sync pulse. HFP 2-byte word count (number of bytes of payload, see MIPI DSI spec v1.1 figure 30)
   parameter lps_bllp_duration = 9532513, // in ps, used for HS_LP mode, this pertains to the LP-11 state duration for blanking 
   parameter lps_hbp_duration = 800000, // in ps, used for HS_LP Non-burst sync events and burst mode. This pertains to the LP-11 state duration for horizontal back porch
   parameter lps_hfp_duration = 500000, // in ps, used for HS_LP Non-burst sync events and burst mode. This pertains to the LP-11 state duration for horizontal front porch
   parameter vact_payload = 16'h1680, //VACT 2-byte word count (total number of bytes of active pixels in 1 line)
   parameter virtual_channel = 2'h0, //virtual channel ID
   parameter video_data_type = 6'h3E, // video data type DI. example: 6'h3E = RGB888 
   parameter vsa_lines = 5, // number of VSA lines, see MIPI DSI spec v1.1 figure 30
   parameter vbp_lines = 36, // number of VBP lines, see MIPI DSI spec v1.1 figure 30
   parameter vfp_lines = 4, // number of VFP lines, see MIPI DSI spec v1.1 figure 30
   parameter eotp_enable = 1, // to enable/disable EOTP packet 
   parameter trail_glitch_enable = 0, //used to enable/disable transmission of glitches at the end of trail 
   parameter trail_glitch_interval = 1000, //interval in ps, for the trail glitches 
   parameter frame_gap = 100000, //interval in ps, for the trail glitches 
   parameter debug_on = 0 // for enabling/disabling DPHY data debug messages
)(
   input  resetn,
   output reg clk_p_i,
   output reg clk_n_i,
   output reg d0_p_io,
   output reg d0_n_io,
   output reg d1_p_i,
   output reg d1_n_i,
   output reg d2_p_i,
   output reg d2_n_i,
   output reg d3_p_i,
   output reg d3_n_i
);
parameter short_pkt_byte = 4; //4 bytes
parameter hsa_byte = short_pkt_byte + hsa_payload + 2*(short_pkt_byte); // 4 byte DI, 8 byte checksum 
parameter hsa_total_byte = hsa_byte + ((vsa_lines-1)*hsa_byte) + hsa_byte + (vbp_lines*(hsa_byte)) + (num_lines*hsa_byte) + ((vfp_lines-1)*hsa_byte);
parameter hstart_total_byte = ((vsa_lines-1)*short_pkt_byte) + (vbp_lines*short_pkt_byte) + (num_lines*short_pkt_byte) + ((vfp_lines-1)*short_pkt_byte);
parameter hend_total_byte = ((vsa_lines-1)*short_pkt_byte) + short_pkt_byte + (vbp_lines*short_pkt_byte) + short_pkt_byte + (num_lines*short_pkt_byte) + ((vfp_lines-1)*short_pkt_byte);
parameter bllp_byte = short_pkt_byte + bllp_payload + 2*(short_pkt_byte); //4 byte DI, 8 byte checksum
`ifdef BURST_MODE
parameter bllp_total_byte = ((vsa_lines-1)*bllp_byte) + bllp_byte + (vbp_lines*(bllp_byte)) + bllp_byte + ((vfp_lines-1)*bllp_byte) + (num_lines*bllp_byte);
`else
parameter bllp_total_byte = ((vsa_lines-1)*bllp_byte) + bllp_byte + (vbp_lines*(bllp_byte)) + bllp_byte + ((vfp_lines-1)*bllp_byte);
`endif
parameter vstart_total_byte = short_pkt_byte;
parameter vend_total_byte = short_pkt_byte;
parameter hbp_byte = short_pkt_byte + hbp_payload + 2*(short_pkt_byte); // 4 byte DI, 8 byte checksum 
parameter hbp_total_byte = hbp_byte + ((num_lines-1)*hbp_byte);
parameter hfp_byte = short_pkt_byte + hfp_payload + 2*(short_pkt_byte); // 4 byte DI, 8 byte checksum 
parameter hfp_total_byte = num_lines*hfp_byte;
parameter eotp_total_byte = short_pkt_byte;
parameter vact_byte = short_pkt_byte + vact_payload + 2*(short_pkt_byte);
parameter vact_total_byte = num_lines*vact_byte;
`ifdef NON_BURST_SYNC_EVENTS
   `ifdef EOTP_DISABLE
      parameter frame_total_byte = hstart_total_byte + bllp_total_byte + vstart_total_byte + hbp_total_byte + hfp_total_byte + vact_total_byte;
   `else
      parameter frame_total_byte = hstart_total_byte + bllp_total_byte + vstart_total_byte + hbp_total_byte + hfp_total_byte + eotp_total_byte + vact_total_byte;
   `endif
`elsif BURST_MODE
   `ifdef EOTP_DISABLE
      parameter frame_total_byte = hstart_total_byte + bllp_total_byte + vstart_total_byte + hbp_total_byte + hfp_total_byte + vact_total_byte;
   `else
      parameter frame_total_byte = hstart_total_byte + bllp_total_byte + vstart_total_byte + hbp_total_byte + hfp_total_byte + eotp_total_byte + vact_total_byte;
   `endif
`else //Non-burst Sync Pulse
   `ifdef EOTP_DISABLE
      parameter frame_total_byte = hsa_total_byte + hstart_total_byte + hend_total_byte + bllp_total_byte + vstart_total_byte + vend_total_byte + hbp_total_byte + hfp_total_byte + vact_total_byte;
   `else
      parameter frame_total_byte = hsa_total_byte + hstart_total_byte + hend_total_byte + bllp_total_byte + vstart_total_byte + vend_total_byte + hbp_total_byte + hfp_total_byte + eotp_total_byte + vact_total_byte;
   `endif
`endif

`ifdef NUM_RX_LANE_1
parameter RX_CH =1;
`elsif NUM_RX_LANE_2
parameter RX_CH =2;
`else
parameter RX_CH =4;
`endif

`ifdef RX_GEAR_16
	parameter GEAR = 16;
`else
	parameter GEAR = 8;
`endif
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_0_buf ;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_1_buf ;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_2_buf ;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_3_buf ;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_4_buf ;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_5_buf ;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_6_buf ;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_7_buf ;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_8_buf ;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_9_buf ;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_10_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_11_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_12_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_13_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_14_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_15_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_16_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_17_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_18_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_19_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_20_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_21_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_22_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_23_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_24_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_25_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_26_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_27_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_28_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_29_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_30_buf;
reg [(PD_BUS_WIDTH*RX_PEL_PER_CLK)-1:0] pix_data_31_buf;
reg [7:0] b[0:100];
integer num_bytes_i;
integer num_bytes;
reg pix_data = 1'b0;
integer frame_idx_dummy1;
integer frame_idx_dummy2;

reg dphy_active;
reg [7:0] hsync_start [3:0];
reg [7:0] hsync_end [3:0];
reg [7:0] vsync_start [3:0];
reg [7:0] vsync_end [3:0];
reg [7:0] eotp_packet [3:0];

reg [7:0] dphy_frame[frame_total_byte-1:0];

reg [7:0] av_frame_data[vact_payload*num_lines-1:0];	// one frame of active video data, added by MT
reg [7:0] av_line_data[vact_payload-1:0];	// one line of active video data, added by MT

integer count, frame_total_bits;
integer num_lanes;
integer i, j, k, n, start_pos;
reg [7:0] short_pkt [0:3];

integer blanking_wc, blanking_counter, pixel_wc;
reg [7:0] blanking_di, ecc, blanking_data, pixel_data, data0, data1, data2, data3;

reg trail0, trail1, trail2, trail3, trail0_ongoing, trail1_ongoing, trail2_ongoing, trail3_ongoing, trail0_end, trail1_end, trail2_end, trail3_end;
reg clk_en;
reg [15:0] cur_crc, chksum;
reg dphy_clk_start;

integer frame_num, frame_idx, frame_idx_e;
integer trail_glitch_count, g0, g1, g2, g3;
reg glitch_val0, glitch_val1, glitch_val2, glitch_val3;

reg [15:0] adjusted_vact_payload;
initial begin
   if(video_data_type == 6'h1E || video_data_type == 6'h1D) begin
      if(vact_payload%9 > 0) begin
         adjusted_vact_payload = vact_payload - (vact_payload % 9);
         if(video_data_type == 6'h1E) 
            $display("%0t Data type is RGB-666 and vact_payload #%0d is not divisible by 9. Adjusted vact_payload value is %0d \n",$realtime,vact_payload,adjusted_vact_payload);
         else
            $display("%0t Data type is Packed Pixel Stream 36-bits RGB and vact_payload #%0d is not divisible by 9. Adjusted vact_payload value is %0d \n",$realtime,vact_payload,adjusted_vact_payload);

      end
      else begin
         adjusted_vact_payload = vact_payload;
         if(video_data_type == 6'h1E)
            $display("%0t Data type is RGB-666 and vact_payload #%0d , is divisible by 9\n",$realtime,vact_payload);
         else
            $display("%0t Data type is Packed Pixel Stream 36-bits RGB and vact_payload #%0d , is divisible by 9 \n",$realtime,vact_payload);
      end
   end
   else if(video_data_type == 6'h0D) begin //limitation: vact_payload should be divisible by 15 bytes 
      if(vact_payload%15 > 0) begin
         adjusted_vact_payload = vact_payload - (vact_payload % 15);
         $display("%0t Data type is Packed Pixel Stream 30-bits RGB and vact_payload #%0d is not divisible by 15. Adjusted vact_payload value is %0d \n",$realtime,vact_payload,adjusted_vact_payload);
      end
      else begin
         adjusted_vact_payload = vact_payload;
         $display("%0t Data type is Packed Pixel Stream 30-bits RGB and vact_payload #%0d, is divisible by 15 \n",$realtime,vact_payload);
      end
   end
   else if(video_data_type == 6'h0C || video_data_type == 6'h1C) begin
      if(vact_payload%6 > 0) begin
         adjusted_vact_payload = vact_payload - (vact_payload % 6);
         if(video_data_type == 6'h0C)
            $display("%0t Data type is Loosely Packed Pixel Stream 20-bit YCbCr 4:2:2 and vact_payload #%0d is not divisible by 6. Adjusted vact_payload value is %0d \n",$realtime,vact_payload,adjusted_vact_payload);
         else
            $display("%0t Data type is Packed Pixel Stream 24-bit YCbCr 4:2:2 and vact_payload #%0d is not divisible by 6. Adjusted vact_payload value is %0d \n",$realtime,vact_payload,adjusted_vact_payload);
      end
      else begin
         adjusted_vact_payload = vact_payload;
         if(video_data_type == 6'h0C)
            $display("%0t Data type is Loosely Packed Pixel Stream 20-bit YCbCr 4:2:2 and vact_payload #%0d , is divisible by 6\n",$realtime,vact_payload);
         else
            $display("%0t Data type is Packed Pixel Stream 24-bit YCbCr 4:2:2 and vact_payload #%0d , is divisible by 6\n",$realtime,vact_payload);
      end      
   end
   else if(video_data_type == 6'h2C) begin
      if(vact_payload%4 > 0) begin
         adjusted_vact_payload = vact_payload - (vact_payload % 4);
         $display("%0t Data type is Packed Pixel Stream 16-bits YCbCr 4:2:2 and vact_payload #%0d is not divisible by 4. Adjusted vact_payload value is %0d \n",$realtime,vact_payload,adjusted_vact_payload);
      end
      else begin
         adjusted_vact_payload = vact_payload;
         $display("%0t Data type is Packed Pixel Stream 16-bits YCbCr 4:2:2 and vact_payload #%0d , is divisible by 4\n",$realtime,vact_payload);
      end
   end
   else if(video_data_type == 6'h3D || video_data_type == 6'h2E || video_data_type == 6'h3E) begin
      if(vact_payload%3 > 0) begin
         adjusted_vact_payload = vact_payload - (vact_payload % 3);
         if(video_data_type == 6'h3D)
            $display("%0t Data type is Packed Pixel Stream 12-bits YCbCr 4:2:0 and vact_payload #%0d is not divisible by 3. Adjusted vact_payload value is %0d \n",$realtime,vact_payload,adjusted_vact_payload);
         else if(video_data_type == 6'h2E)
            $display("%0t Data type is Loosely Packed Pixel Stream 18-bits RGB and vact_payload #%0d is not divisible by 3. Adjusted vact_payload value is %0d \n",$realtime,vact_payload,adjusted_vact_payload);
         else if(video_data_type == 6'h3E)
            $display("%0t Data type is Packed Pixel Stream RGB-888 and vact_payload #%0d is not divisible by 3. Adjusted vact_payload value is %0d \n",$realtime,vact_payload,adjusted_vact_payload);
      end
      else begin
         adjusted_vact_payload = vact_payload;
         if(video_data_type == 6'h3D)
            $display("%0t Data type is Packed Pixel Stream 12-bits YCbCr 4:2:0 and vact_payload #%0d , is divisible by 3\n",$realtime,vact_payload);
         else if(video_data_type == 6'h2E)
            $display("%0t Data type is Loosely Packed Pixel Stream 18-bits RGB and vact_payload #%0d , is divisible by 3\n",$realtime,vact_payload);
         else if(video_data_type == 6'h3E)
            $display("%0t Data type is Packed Pixel Stream RGB-888 and vact_payload #%0d , is divisible by 3\n",$realtime,vact_payload);
      end
   end
   else if(video_data_type == 6'h0E) begin
      if(vact_payload%2 > 0) begin
         adjusted_vact_payload = vact_payload - (vact_payload % 2);
         $display("%0t Data type is Packed Pixel Stream 16-bits RGB-565 and vact_payload #%0d is not divisible by 2. Adjusted vact_payload value is %0d \n",$realtime,vact_payload,adjusted_vact_payload);
      end
      else begin
         adjusted_vact_payload = vact_payload;
         $display("%0t Data type is Packed Pixel Stream 16-bits RGB-565 and vact_payload #%0d , is divisible by 2\n",$realtime,vact_payload);
      end
   end
   else begin
      adjusted_vact_payload = vact_payload;
      $display("%0t Video Data type is Unknown and vact_payload #%0d \n",$realtime,vact_payload);
   end
end


initial begin
	`ifdef RX_RGB666
		num_bytes = 9;
        `elsif RX_RGB666_LP 
	        num_bytes = 3;
        `elsif RX_RGB888 
	        num_bytes = 3;
  	`endif

	pix_data_0_buf = 'h0;
	pix_data_1_buf = 'h0;
	pix_data_2_buf = 'h0;
	pix_data_3_buf = 'h0;
	pix_data_4_buf = 'h0;
	pix_data_5_buf = 'h0;
	pix_data_6_buf = 'h0;
	pix_data_7_buf = 'h0;
	pix_data_8_buf = 'h0;
	pix_data_9_buf = 'h0;
	pix_data_10_buf = 'h0;
	pix_data_11_buf = 'h0;
	pix_data_12_buf = 'h0;
	pix_data_13_buf = 'h0;
	pix_data_14_buf = 'h0;
	pix_data_15_buf = 'h0;
	pix_data_16_buf = 'h0;
	pix_data_17_buf = 'h0;
	pix_data_18_buf = 'h0;
	pix_data_19_buf = 'h0;
	pix_data_20_buf = 'h0;
	pix_data_21_buf = 'h0;
	pix_data_22_buf = 'h0;
	pix_data_23_buf = 'h0;
	pix_data_24_buf = 'h0;
	pix_data_25_buf = 'h0;
	pix_data_26_buf = 'h0;
	pix_data_27_buf = 'h0;
	pix_data_28_buf = 'h0;
	pix_data_29_buf = 'h0;
	pix_data_30_buf = 'h0;
	pix_data_31_buf = 'h0;
   frame_total_bits = frame_total_byte*8;
   dphy_active = 0;
   clk_p_i = 0;
   clk_n_i = 1;
   d0_p_io = 0;
   d0_n_io = 1;
   d1_p_i = 0;
   d1_n_i = 1;
   d2_p_i = 0;
   d2_n_i = 1;
   d3_p_i = 0;
   d3_n_i = 1;
   dphy_clk_start = 0;
   data0 = 0;
   data1 = 0;
   data2 = 0;
   data3 = 0;

   @(posedge resetn);
   $display("%0t After reset, start driving LP-11\n",$realtime);
   #181007;
   drive_clk_LP(1,1);
   drive_data_LP(1,1);
   #t_init; //T-INIT requirement
   `ifdef RX_CLK_MODE_HS_ONLY //start driving DPHY clock
      drive_hs_clk_req;
      dphy_clk_start = 1;
      if(!dphy_active) begin
         $display("%0t Waiting for dphy active...\n",$realtime);
         @(posedge dphy_active);
         $display("%0t dphy active ASSERTED...\n",$realtime);
      end
      for(frame_num=0; frame_num<num_frames;frame_num=frame_num+1) begin
         $display("%0t FRAME #%0d started...\n",$realtime,frame_num+1);
         frame_idx = 0;
        `ifdef LP_BLANKING
           `ifdef NON_BURST_SYNC_EVENTS
               drive_hs_lp_sync_evt_or_burst_mode;
           `elsif BURST_MODE
               drive_hs_lp_sync_evt_or_burst_mode;
           `else
               drive_hs_lp_sync_pulse;
           `endif
        `else //HS blanking
           drive_hs_only;
        `endif
        // #frame_gap;
         $display("%0t FRAME #%0d ended...\n",$realtime,frame_num+1);
      end
   `else //RX_CLK_MODE_HS_LP
      if(!dphy_active) begin
         $display("%0t Waiting for dphy active...\n",$realtime);
         @(posedge dphy_active);
         $display("%0t dphy active ASSERTED...\n",$realtime);
      end
      for(frame_num=0; frame_num<num_frames;frame_num=frame_num+1) begin
         $display("%0t FRAME #%0d started...\n",$realtime,frame_num+1);
         frame_idx = 0;
        `ifdef LP_BLANKING
           `ifdef NON_BURST_SYNC_EVENTS
              drive_hs_lp_sync_evt_or_burst_mode;
           `elsif BURST_MODE
              drive_hs_lp_sync_evt_or_burst_mode;
           `else
              drive_hs_lp_sync_pulse;
           `endif
         `else //HS blanking
            drive_hs_only;
         `endif
        // #frame_gap;
         $display("%0t FRAME #%0d ended...\n",$realtime,frame_num+1);
      end
   `endif
   dphy_active = 0;
end

`ifdef RX_CLK_MODE_HS_ONLY
initial begin
   @(posedge dphy_clk_start);
   forever begin
      clk_p_i =~ clk_p_i;
      clk_n_i =~ clk_n_i;
      #(dphy_clk_period/2);
   end
end
`endif

initial begin
clk_en = 0;
trail0_end = 0;
trail1_end = 0;
trail2_end = 0;
trail3_end = 0;
blanking_di = 8'h19;
hsync_start [0] = 8'h21;
hsync_start [1] = 8'h00;
hsync_start [2] = 8'h00;
hsync_start [3] = 8'h12;
hsync_end [0] = 8'h31;
hsync_end [1] = 8'h00;
hsync_end [2] = 8'h00;
hsync_end [3] = 8'h01;
vsync_start [0] = 8'h01;
vsync_start [1] = 8'h00;
vsync_start [2] = 8'h00;
vsync_start [3] = 8'h07;
vsync_end [0] = 8'h11;
vsync_end [1] = 8'h00;
vsync_end [2] = 8'h00;
vsync_end [3] = 8'h14;
eotp_packet [0] = 8'h08;
eotp_packet [1] = 8'h0F;
eotp_packet [2] = 8'h0F;
eotp_packet [3] = 8'h01;
end

task drive_clk_LP(input p, input n);
begin
   clk_p_i = p;
   clk_n_i = n;
end
endtask

task drive_data_LP(input p, input n);
begin
   d0_p_io = p;
   d0_n_io = n;
   if(dphy_num_lane >= 2) begin
      d1_p_i = p;
      d1_n_i = n;
   end
   if(dphy_num_lane >= 3) begin
      d2_p_i = p;
      d2_n_i = n;
   end
   if(dphy_num_lane >= 4) begin
      d3_p_i = p;
      d3_n_i = n;
   end
end
endtask

task drive_hs_clk_req();
begin
   drive_clk_LP(0,1);
   #t_lpx;
   drive_clk_LP(0,0);
   #t_clk_prepare;
   drive_clk_LP(0,1);
   #t_clk_zero;
end
endtask

task drive_hs_data_req();
begin
   drive_data_LP(0,1);
   #t_lpx;
   drive_data_LP(0,0);
   #t_hs_prepare;
   drive_data_LP(0,1);
   #t_hs_zero;
end
endtask

task drive_data_lane0(input dp);
begin
   d0_p_io = dp;
   d0_n_io =~ dp;
end
endtask

task drive_data_lane1(input dp);
begin
   d1_p_i = dp;
   d1_n_i =~ dp;
end
endtask

task drive_data_lane2(input dp);
begin
   d2_p_i = dp;
   d2_n_i =~ dp;
end
endtask

task drive_data_lane3(input dp);
begin
   d3_p_i = dp;
   d3_n_i =~ dp;
end
endtask

task drive_sot();
begin
   $display("%0t SoT started...\n",$realtime);
   @(posedge clk_p_i);
   #(dphy_clk_period/4);
   drive_data_LP(1,0);
   @(posedge clk_p_i);
   @(negedge clk_p_i);
   #(dphy_clk_period/4); 
   drive_data_LP(0,1);
   @(posedge clk_p_i);
   #(dphy_clk_period/4); 
   drive_data_LP(1,0);
   @(negedge clk_p_i);
   #(dphy_clk_period/4); 
   $display("%0t SoT ended...\n",$realtime);
end
endtask

task gen_short_packet(input [7:0] pkt_type);
begin
   case(pkt_type)
      8'h01 :  begin
         for(k=0; k < 4; k=k+1) begin
            dphy_frame[frame_idx] = vsync_start[k];
            frame_idx=frame_idx+1;
         end
      end
      8'h08 :  begin
         for(k=0; k < 4; k=k+1) begin
            dphy_frame[frame_idx] = eotp_packet[k];
            frame_idx=frame_idx+1;
         end
      end
      8'h11 : begin
         for(k=0; k < 4; k=k+1) begin
            dphy_frame[frame_idx] = vsync_end[k];
            frame_idx=frame_idx+1;
         end
      end
      8'h21 :  begin
         for(k=0; k < 4; k=k+1) begin
            dphy_frame[frame_idx] = hsync_start[k];
            frame_idx=frame_idx+1;
         end
      end
      8'h31 :  begin
         for(k=0; k < 4; k=k+1) begin
            dphy_frame[frame_idx] = hsync_end[k];
            frame_idx=frame_idx+1;
         end
      end
   endcase
end      
endtask

task drive_hs_only();
begin

   `ifdef NON_BURST_SYNC_EVENTS
      drive_non_burst_sync_events;
   `elsif BURST_MODE
      drive_burst_mode;
   `else //Non-burst sync pulse
      drive_non_burst_sync_pulse;
   `endif

   `ifdef RX_CLK_MODE_HS_ONLY
      #t_clk_pre;
      drive_hs_data_req;
      drive_sot;
      drive_dphy_packet;
      drive_hs_trail;
   `else //RX_CLK_MODE_HS_LP
      fork
         begin
            drive_hs_lp_clk;
         end
         begin
            @(posedge clk_en);
            #t_clk_pre;
            drive_hs_data_req;
            drive_sot;
            drive_dphy_packet;
            drive_hs_trail;
         end
      join

   `endif
end
endtask

task drive_non_burst_sync_pulse();
begin
   gen_short_packet(8'h01);
   gen_blanking_packet(hsa_payload);
   repeat(vsa_lines-1) begin
      gen_short_packet(8'h31);
      gen_blanking_packet(bllp_payload);
      gen_short_packet(8'h21);
      gen_blanking_packet(hsa_payload);
   end
   gen_short_packet(8'h31);
   gen_blanking_packet(bllp_payload);
   gen_short_packet(8'h11);
   gen_blanking_packet(hsa_payload);

   repeat(vbp_lines) begin
      gen_short_packet(8'h31);
      gen_blanking_packet(bllp_payload);
      gen_short_packet(8'h21);
      gen_blanking_packet(hsa_payload);
   end

   gen_short_packet(8'h31);
   gen_blanking_packet(hbp_payload);

   $display("%0t Total number of bytes of active pixels per line = %0d\n",$realtime,adjusted_vact_payload);
   $display("%0t Total number of active lines = %0d\n",$realtime,num_lines);
   for(j=0; j < num_lines; j=j+1) begin
//      if(debug_on)
         $display("Generate data for line %0d\n",j);
      gen_active_line;
	copy_active_data(j);
      gen_blanking_packet(hfp_payload);
      gen_short_packet(8'h21);
      gen_blanking_packet(hsa_payload);
      gen_short_packet(8'h31);
      if(j == num_lines-1) begin
         gen_blanking_packet(bllp_payload);
      end
      else begin
         gen_blanking_packet(hbp_payload);
      end
   end
   repeat(vfp_lines-1) begin
      gen_short_packet(8'h21);
      gen_blanking_packet(hsa_payload);
      gen_short_packet(8'h31);
      gen_blanking_packet(bllp_payload);
   end
   if(eotp_enable) 
      gen_short_packet(8'h08);
end
endtask

task drive_non_burst_sync_events();
begin
   gen_short_packet(8'h01);
   repeat(vsa_lines-1) begin
      gen_blanking_packet(bllp_payload);
      gen_short_packet(8'h21);
   end
   gen_blanking_packet(bllp_payload);
   gen_short_packet(8'h21);

   repeat(vbp_lines) begin
      gen_blanking_packet(bllp_payload);
      gen_short_packet(8'h21);
   end

   gen_blanking_packet(hbp_payload);

   $display("%0t Total number of bytes of active pixels per line = %0d\n",$realtime,adjusted_vact_payload);
   $display("%0t Total number of active lines = %0d\n",$realtime,num_lines);
   for(j=0; j < num_lines; j=j+1) begin
//      if(debug_on)
         $display("Generate data for line in DRIVE_NON_BURST %0d\n",j);
	 pix_data=1;
      gen_active_line;
      pix_data=0;
	copy_active_data(j);
      gen_blanking_packet(hfp_payload);
      gen_short_packet(8'h21);
      if(j == num_lines-1) begin
         gen_blanking_packet(bllp_payload);
      end
      else begin
         gen_blanking_packet(hbp_payload);
      end
   end
   repeat(vfp_lines-1) begin
      gen_short_packet(8'h21);
      gen_blanking_packet(bllp_payload);
   end
   if(eotp_enable) 
      gen_short_packet(8'h08);
end
endtask

task drive_hs_lp_clk();
begin
   drive_hs_clk_req;
   clk_en = 1;
   while (clk_en) begin
      clk_p_i = ~clk_p_i;
      clk_n_i = ~clk_n_i;
      #(dphy_clk_period/2);
   end

   // Trail HS-0
   clk_p_i = 0;
   clk_n_i = 1;
   #t_clk_trail;

   // Clk-Stop
   clk_p_i = 1;
   clk_n_i = 1;
end
endtask

task drive_burst_mode();
begin
   gen_short_packet(8'h01);
   repeat(vsa_lines-1) begin
      gen_blanking_packet(bllp_payload);
      gen_short_packet(8'h21);
   end
   gen_blanking_packet(bllp_payload);
   gen_short_packet(8'h21);

   repeat(vbp_lines) begin
      gen_blanking_packet(bllp_payload);
      gen_short_packet(8'h21);
   end

   gen_blanking_packet(hbp_payload);

   $display("%0t Total number of bytes of active pixels per line = %0d\n",$realtime,adjusted_vact_payload);
   $display("%0t Total number of active lines = %0d\n",$realtime,num_lines);
   for(j=0; j < num_lines; j=j+1) begin
//      if(debug_on)
         $display("Generate data for line %0d\n",j);
      gen_active_line;
	copy_active_data(j);
      gen_blanking_packet(bllp_payload);
      gen_blanking_packet(hfp_payload);
      gen_short_packet(8'h21);
      if(j == num_lines-1) begin
         gen_blanking_packet(bllp_payload);
      end
      else begin
         gen_blanking_packet(hbp_payload);
      end
   end
   repeat(vfp_lines-1) begin
      gen_short_packet(8'h21);
      gen_blanking_packet(bllp_payload);
   end
   if(eotp_enable) 
      gen_short_packet(8'h08);
end
endtask

task drive_hs_lp_sync(input [7:0] pkt);
begin
   frame_idx = 0;
   fork
      begin
        `ifdef RX_CLK_MODE_HS_LP
           drive_hs_lp_clk;
        `endif
      end
      begin
        `ifdef RX_CLK_MODE_HS_LP
            @(posedge clk_en);
        `endif
         #t_clk_pre;
         drive_hs_data_req;
         drive_sot;
         case(pkt)
           8'h01 : gen_short_packet(8'h01);
           8'h11 : gen_short_packet(8'h11);
           8'h21 : gen_short_packet(8'h21);
         endcase

         `ifdef NON_BURST_SYNC_EVENTS
         `elsif BURST_MODE
         `else //non-burst sync pulse
            gen_blanking_packet(hsa_payload);
            gen_short_packet(8'h31);
         `endif

         if(eotp_enable)
            gen_short_packet(8'h08);
         drive_dphy_packet;
         drive_hs_trail;
      end
   join
end
endtask

task drive_hs_lp_sync_pulse();
begin
   drive_hs_lp_sync(8'h01);
   #lps_bllp_duration;
   repeat(vsa_lines-1) begin
      drive_hs_lp_sync(8'h21);
      #lps_bllp_duration;
   end
   drive_hs_lp_sync(8'h11);
   #lps_bllp_duration;

   repeat(vbp_lines-1) begin
      drive_hs_lp_sync(8'h21);
      #lps_bllp_duration;
   end

   $display("%0t Total number of bytes of active pixels per line = %0d\n",$realtime,vact_payload);
   $display("%0t Total number of active lines = %0d\n",$realtime,num_lines);
   frame_idx = 0;
   gen_short_packet(8'h21);
   gen_blanking_packet(hsa_payload);
   gen_short_packet(8'h31);
   gen_blanking_packet(hbp_payload);
   for(j=0; j < num_lines; j=j+1) begin
//      if(debug_on)
         $display("Generate data for line %0d\n",j);
      gen_active_line;
	copy_active_data(j);
      gen_blanking_packet(hfp_payload);
      gen_short_packet(8'h21);
      gen_blanking_packet(hsa_payload);
      gen_short_packet(8'h31);
      if(j == num_lines-1) begin
         gen_short_packet(8'h08);         
      end
      else begin
         gen_blanking_packet(hbp_payload);
      end
   end
   //drive active lines
   fork
      begin
       `ifdef RX_CLK_MODE_HS_LP
         drive_hs_lp_clk;
       `endif
      end
      begin
        `ifdef RX_CLK_MODE_HS_LP
           @(posedge clk_en);
        `endif
         #t_clk_pre;
         drive_hs_data_req;
         drive_sot;
         drive_dphy_packet;
         drive_hs_trail;
      end
   join
   #lps_bllp_duration;
   
   repeat(vfp_lines-1) begin
      drive_hs_lp_sync(8'h21);
      #lps_bllp_duration;
   end
end
endtask


task drive_hs_lp_sync_evt_or_burst_mode();
begin
   drive_hs_lp_sync(8'h01);
   #lps_bllp_duration;
   repeat(vsa_lines-1) begin
      drive_hs_lp_sync(8'h21);
      #lps_bllp_duration;
   end

   `ifdef NON_BURST_SYNC_EVENTS
      drive_hs_lp_sync(8'h21);
   `elsif BURST_MODE
      drive_hs_lp_sync(8'h21);
   `else
      drive_hs_lp_sync(8'h11);
   `endif

   #lps_bllp_duration;

   repeat(vbp_lines-1) begin
      drive_hs_lp_sync(8'h21);
      #lps_bllp_duration;
   end

   $display("%0t Total number of bytes of active pixels per line = %0d\n",$realtime,adjusted_vact_payload);
   $display("%0t Total number of active lines = %0d\n",$realtime,num_lines);

   drive_hs_lp_sync(8'h21);

   #lps_hbp_duration;

   for(j=0; j < num_lines; j=j+1) begin
//      if(debug_on)
         $display("Generate data for line %0d\n",j);
      frame_idx = 0;
      gen_active_line;
      copy_active_data(j);
      //drive active lines
      fork
         begin
           `ifdef RX_CLK_MODE_HS_LP
              drive_hs_lp_clk;
           `endif
         end
         begin
           `ifdef RX_CLK_MODE_HS_LP
              @(posedge clk_en);
           `endif
            #t_clk_pre;
            drive_hs_data_req;
            drive_sot;
            drive_dphy_packet;
            drive_hs_trail;
         end
      join

      #lps_hfp_duration;
      
      drive_hs_lp_sync(8'h21);
      if(j == num_lines-1) begin
         #lps_bllp_duration;
      end
      else begin
         #lps_hbp_duration;
      end
   end
   
   repeat(vfp_lines-1) begin
      drive_hs_lp_sync(8'h21);
      #lps_bllp_duration;
   end
end
endtask

task get_ecc (input [23:0] d, output [5:0] ecc_val);
begin
  ecc_val[0] = d[0]^d[1]^d[2]^d[4]^d[5]^d[7]^d[10]^d[11]^d[13]^d[16]^d[20]^d[21]^d[22]^d[23];
  ecc_val[1] = d[0]^d[1]^d[3]^d[4]^d[6]^d[8]^d[10]^d[12]^d[14]^d[17]^d[20]^d[21]^d[22]^d[23];
  ecc_val[2] = d[0]^d[2]^d[3]^d[5]^d[6]^d[9]^d[11]^d[12]^d[15]^d[18]^d[20]^d[21]^d[22];
  ecc_val[3] = d[1]^d[2]^d[3]^d[7]^d[8]^d[9]^d[13]^d[14]^d[15]^d[19]^d[20]^d[21]^d[23];
  ecc_val[4] = d[4]^d[5]^d[6]^d[7]^d[8]^d[9]^d[16]^d[17]^d[18]^d[19]^d[20]^d[22]^d[23];
  ecc_val[5] = d[10]^d[11]^d[12]^d[13]^d[14]^d[15]^d[16]^d[17]^d[18]^d[19]^d[21]^d[22]^d[23];
end
endtask

task compute_crc16(input [7:0] data_tmp);
begin
   for (n = 0; n < 8; n = n + 1) begin
     cur_crc = chksum;
     cur_crc[15] = data_tmp[n]^cur_crc[0];
     cur_crc[10] = cur_crc[11]^cur_crc[15];
     cur_crc[3]  = cur_crc[4]^cur_crc[15]; 
     chksum = chksum >> 1;
     chksum[15] = cur_crc[15];
     chksum[10] = cur_crc[10];
     chksum[3] = cur_crc[3];
   end
end
endtask

task gen_blanking_packet(input [31:0] blanking_payload);
begin
   blanking_data = 8'h55;
   blanking_wc = blanking_payload;
   blanking_counter = 0;
   ecc = 8'h00;

   get_ecc({blanking_payload[15:8], blanking_payload[7:0], blanking_di},ecc);

   dphy_frame[frame_idx] = blanking_di;
   frame_idx = frame_idx + 1;
   dphy_frame[frame_idx] = blanking_payload[7:0];
   frame_idx = frame_idx + 1;
   dphy_frame[frame_idx] = blanking_payload[15:8];
   frame_idx = frame_idx + 1;
   dphy_frame[frame_idx] = ecc;
   frame_idx = frame_idx + 1;

   chksum = 16'hFFFF;
   for(i = 1; i < blanking_wc+1; i=i+1) begin
      dphy_frame[frame_idx] = blanking_data;
      frame_idx = frame_idx + 1;
      compute_crc16(blanking_data); 
      blanking_counter = blanking_counter + 1;
      if(blanking_counter == 256) begin
         blanking_data = blanking_data+1;
         blanking_counter = 0;
      end
   end
   
   //write checksum 
   dphy_frame[frame_idx] = chksum[7:0];
   frame_idx = frame_idx + 1;
   dphy_frame[frame_idx] = chksum[15:8];
   frame_idx = frame_idx + 1;
end
endtask

//`include "dsi_tasks.vh"
task gen_active_line();
begin
    ecc = 8'h00;
    frame_idx_dummy1 = frame_idx;
    get_ecc({adjusted_vact_payload[15:8], adjusted_vact_payload[7:0], virtual_channel,  video_data_type},ecc);
    dphy_frame[frame_idx] = {virtual_channel, video_data_type};  
    frame_idx = frame_idx + 1;
    dphy_frame[frame_idx] = adjusted_vact_payload[7:0];  
    frame_idx = frame_idx + 1;
    dphy_frame[frame_idx] = adjusted_vact_payload[15:8];  
    frame_idx = frame_idx + 1;
    dphy_frame[frame_idx] = ecc;  
    frame_idx = frame_idx + 1;

    pixel_wc = adjusted_vact_payload; 
    chksum = 16'hFFFF; 
    //for(i = 0; i < pixel_wc; i=i+1) begin 
    //for(i = 0; i < pixel_wc) begin 
    i = 0;
    while (i < pixel_wc) begin 
       pixel_data = $random;

	//for(num_bytes_i=0;num_bytes_i<num_bytes*RX_CH*GEAR/8;num_bytes_i=num_bytes_i+1)begin
                   //b[num_bytes_i] = $random;
                   b[i] = $random;
       dphy_frame[frame_idx] = pixel_data;
       //dphy_frame[frame_idx] = b[num_bytes_i];
       //dphy_frame[frame_idx] = b[i];
       frame_idx = frame_idx + 1;
       compute_crc16(pixel_data);
       //compute_crc16(b[num_bytes_i]);
       //compute_crc16(b[i]);
		av_line_data[i] = pixel_data;	// added by MT 
		//av_line_data[i] = b[num_bytes_i];	// added by MT 
		//av_line_data[i] = b[i];	// added by MT 
		i=i+1;
        //end
  //     `ifdef RX_RGB666
  //        gen_dsi_rgb666_pixel_data;
  //      `elsif RX_RGB666_LP 
  //        gen_dsi_rgb666_lp_pixel_data;
  //      `elsif RX_RGB888 
  //        gen_dsi_rgb888_pixel_data;
  //	`endif

    end

    //write checksum
    dphy_frame[frame_idx] = chksum[7:0];
    frame_idx = frame_idx + 1;
    dphy_frame[frame_idx] = chksum[15:8];
    frame_idx = frame_idx + 1;
    frame_idx_dummy2 = frame_idx;
end
endtask

task write_to_file ( input [1024*4-1:0]str_in,input [(PD_BUS_WIDTH)-1:0]data);
     integer filedesc;
   begin
    //if(enable_write_log == 1) begin
     filedesc = $fopen(str_in,"a");
     $fwrite(filedesc, "%h\n", data);
     $fclose(filedesc);
    //end
   end
endtask

task drive_hs_trail();
begin
 trail_glitch_count = 35/trail_glitch_interval;
 fork
  begin
    if(trail0 == 0) 
      drive_hs_trail0; 
  end
  begin
    if(trail1 == 0 && dphy_num_lane >= 2) 
      drive_hs_trail1; 
  end
  begin
    if(trail2 == 0 && dphy_num_lane >= 3) 
      drive_hs_trail2; 
  end
  begin
    if(trail3 == 0 && dphy_num_lane >= 4) 
      drive_hs_trail3;
  end
 join 
end
endtask

task drive_hs_trail0();
begin
  if(!trail0_ongoing) begin
     $display("%0t HS trail data lane0 started...",$realtime);
     trail0_ongoing = 1;
     drive_data_lane0(~d0_p_io); 
     #t_hs_trail;
     if(trail_glitch_enable == 1) begin
        drive_trail_glitch0;
     end
     d0_p_io = 1;
     d0_n_io = 1;
     $display("%0t HS trail data lane0 ended...",$realtime);
     trail0_end = 1;
  end
end
endtask

task drive_hs_trail1();
begin
  if(!trail1_ongoing) begin
     $display("%0t HS trail data lane1 started...",$realtime);
     trail1_ongoing = 1;
     drive_data_lane1(~d1_p_i); 
     #t_hs_trail;
     if(trail_glitch_enable == 1) begin
        drive_trail_glitch1;
     end
     d1_p_i = 1;
     d1_n_i = 1;
     $display("%0t HS trail data lane1 ended...",$realtime);
     trail1_end = 1;
  end
end
endtask

task drive_hs_trail2();
begin
  if(!trail2_ongoing) begin
     $display("%0t HS trail data lane2 started...",$realtime);
     trail2_ongoing = 1;
     drive_data_lane2(~d2_p_i); 
     #t_hs_trail;
     if(trail_glitch_enable == 1) begin
        drive_trail_glitch2;
     end
     d2_p_i = 1;
     d2_n_i = 1;
     $display("%0t HS trail data lane2 ended...",$realtime);
     trail2_end = 1;
  end
end
endtask

task drive_hs_trail3();
begin
  if(!trail3_ongoing) begin
     $display("%0t HS trail data lane3 started...",$realtime);
     trail3_ongoing = 1;
     drive_data_lane3(~d3_p_i); 
     #t_hs_trail;
     if(trail_glitch_enable == 1) begin
        drive_trail_glitch3;
     end
     d3_p_i = 1;
     d3_n_i = 1;
     $display("%0t HS trail data lane3 ended...",$realtime);
     trail3_end = 1;
  end
end
endtask

task drive_trail_glitch0();
begin
   $display("%0t Driving Trail glitches for Data Lane 0 started...",$realtime);
   for(g0 = 0; g0 < trail_glitch_count; g0=g0+1) begin
      glitch_val0 = $random;
      d0_p_io = glitch_val0;
      d0_n_io = ~glitch_val0;
      #trail_glitch_interval;
   end  
   $display("%0t Driving Trail glitches for Data Lane 0 ended...",$realtime);
end
endtask

task drive_trail_glitch1();
begin
   $display("%0t Driving Trail glitches for Data Lane 1 started...",$realtime);
   for(g1 = 0; g1 < trail_glitch_count; g1=g1+1) begin
      glitch_val1 = $random;
      d1_p_i = glitch_val1;
      d1_n_i = ~glitch_val1;
      #trail_glitch_interval;
   end  
   $display("%0t Driving Trail glitches for Data Lane 1 ended...",$realtime);
end
endtask

task drive_trail_glitch2();
begin
   $display("%0t Driving Trail glitches for Data Lane 2 started...",$realtime);
   for(g2 = 0; g2 < trail_glitch_count; g2=g2+1) begin
      glitch_val2 = $random;
      d2_p_i = glitch_val2;
      d2_n_i = ~glitch_val2;
      #trail_glitch_interval;
   end  
   $display("%0t Driving Trail glitches for Data Lane 2 ended...",$realtime);
end
endtask

task drive_trail_glitch3();
begin
   $display("%0t Driving Trail glitches for Data Lane 3 started...",$realtime);
   for(g3 = 0; g3 < trail_glitch_count; g3=g3+1) begin
      glitch_val3 = $random;
      d3_p_i = glitch_val3;
      d3_n_i = ~glitch_val3;
      #trail_glitch_interval;
   end  
   $display("%0t Driving Trail glitches for Data Lane 3 ended...",$realtime);
end
endtask


task drive_dphy_packet();
begin
   trail0 = 0;
   trail1 = 0;
   trail2 = 0;
   trail3 = 0;
   trail0_ongoing = 0;
   trail1_ongoing = 0;
   trail2_ongoing = 0;
   trail3_ongoing = 0;
   start_pos = 0;
   $display("##### %0t Transmit DPHY packets ongoing... #####",$realtime);
   while(start_pos < frame_idx) begin
      if(start_pos < frame_idx) begin
         data0 = dphy_frame[start_pos];
         //if(debug_on & (start_pos <= frame_idx_dummy2) & (start_pos >= frame_idx_dummy1) ) begin
	 if(debug_on) begin 
            $display("##### %0t DPHY DATA #####",$realtime);
            $display("data lane0: %h",data0);
         end
      end
      else begin
         trail0 = 1;
      end
      start_pos = start_pos+1;
      if(dphy_num_lane >= 2) begin
         if(start_pos < frame_idx) begin
            data1 = dphy_frame[start_pos];
            if(debug_on) 
               $display("data lane1: %h",data1);
         end
         else begin
            trail1 = 1;
         end
         start_pos = start_pos+1;
      end
      if(dphy_num_lane >= 3) begin
         if(start_pos < frame_idx) begin
            data2 = dphy_frame[start_pos];
            if(debug_on)
               $display("data lane2: %h ",data2);
         end
         else begin
            trail2 = 1;
         end
         start_pos = start_pos+1;
      end
      if(dphy_num_lane >= 4) begin
         if(start_pos < frame_idx) begin
            data3 = dphy_frame[start_pos];
            if(debug_on)
               $display("data lane3: %h",data3);
         end
         else begin
            trail3 = 1;
         end
         start_pos = start_pos+1;
      end
      for(i = 0; i < 8; i=i+1) begin
         if(trail0 == 0)
            drive_data_lane0(data0[i]);  
         if(trail1 == 0 && dphy_num_lane >= 2)
            drive_data_lane1(data1[i]);     
         if(trail2 == 0 && dphy_num_lane >= 3)
            drive_data_lane2(data2[i]);    
         if(trail3 == 0 && dphy_num_lane >= 4)
            drive_data_lane3(data3[i]);  
         if(!trail0 || !trail1 || !trail2 || !trail3)
            #(dphy_clk_period/2);
      end
   end
   $display("##### %0t Transmit DPHY packets DONE! #####",$realtime);
   
end
endtask

///// added task by MT /////
task copy_active_data (input [10:0] line_cnt);
begin
	for (i=0; i<vact_payload; i=i+1) begin
		if (video_data_type == 6'h2E) begin
		av_frame_data[vact_payload*line_cnt+i] = av_line_data[i][7:2];
		//$display("\n LINE DATA %8h \n",av_line_data[i]);
		write_to_file_6_bits("expected_data_byte.log",av_line_data[i][7:2]);
		end
		else begin
		av_frame_data[vact_payload*line_cnt+i] = av_line_data[i];
		//$display("\n LINE DATA %8h \n",av_line_data[i]);
		write_to_file_byte("expected_data_byte.log",av_line_data[i]);
	        end
		//if ( (((i+1)%8) == 0) & ((RX_CH == 4 & GEAR == 16) ) )
		//write_to_file_byte("expected_data_byte.log",{av_line_data[i],av_line_data[i-1],av_line_data[i-2],av_line_data[i -3],av_line_data[i-4],av_line_data[i-5],av_line_data[i -6],av_line_data[i -7]});
		//if ( (((i+1)%4) == 0) & ((RX_CH == 4 & GEAR == 8) | (RX_CH == 2 & GEAR == 16) ) )
		//write_to_file_byte("expected_data_byte.log",{av_line_data[i],av_line_data[i-1],av_line_data[i-2],av_line_data[i -3]});
		//if ( (((i+1)%2) == 0) & ((RX_CH == 2 & GEAR == 8) | (RX_CH == 1 & GEAR == 16) ) )
		//write_to_file_byte("expected_data_byte.log",{av_line_data[i],av_line_data[i-1]});
		//if (RX_CH == 1 & GEAR == 8) 
		//write_to_file_byte("expected_data_byte.log",av_line_data[i]);
	end
end
endtask
	
task write_to_file_byte ( input [1024*4-1:0]str_in, input [7:0] data);
     integer filedesc;
 begin
  //  if(enable_write_log == 1) begin
     filedesc = $fopen(str_in,"a");
     $fwrite(filedesc, "%h\n", data);
     $fclose(filedesc);
  //  end
 end
endtask
task write_to_file_6_bits ( input [1024*4-1:0]str_in, input [5:0] data);
     integer filedesc;
 begin
  //  if(enable_write_log == 1) begin
     filedesc = $fopen(str_in,"a");
     $fwrite(filedesc, "%h\n", data);
     $fclose(filedesc);
  //  end
 end
endtask


always @(posedge trail0) 
   drive_hs_trail0;

always @(posedge trail1) 
   drive_hs_trail1;


always @(posedge trail2) 
   drive_hs_trail2;

always @(posedge trail3)
   drive_hs_trail3;

//`ifdef RX_CLK_MODE_HS_LP
`ifdef NUM_RX_LANE_4
always @(posedge (trail0_end && trail1_end && trail2_end && trail3_end)) begin
`elsif NUM_RX_LANE_3
always @(posedge (trail0_end && trail1_end && trail2_end)) begin
`elsif NUM_RX_LANE_2
always @(posedge (trail0_end && trail1_end)) begin
`else
always @(posedge (trail0_end)) begin
`endif
   #t_clk_post;
   clk_en = 0;
   trail0_end = 0;
   trail1_end = 0;
   trail2_end = 0;
   trail3_end = 0;
end
//`endif

endmodule

