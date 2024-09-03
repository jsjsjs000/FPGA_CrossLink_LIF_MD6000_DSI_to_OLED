`include "bus_driver.v"
`include "clk_driver.v"

module csi2_model#(
   parameter PD_BUS_WIDTH = 24,
   parameter RX_PEL_PER_CLK = 1,
   parameter vc_mode              = "REPLACE",
   parameter clk_mode             = "HS_ONLY",
   parameter num_frames           = 2,
   parameter num_lines            = 2,
   parameter num_pixels           = 200,
   parameter num_payload           = 200,
   parameter active_dphy_lanes    = 4,
   parameter data_type            = 6'h2b,
   parameter raw_width            = 8,	// 8, 10, or 12
   parameter frame_counter		  = "OFF",
   parameter frame_count_max      = 2,

   parameter dphy_clk_period      = 1683, 
   parameter t_lpx                = 68000,
   parameter t_clk_prepare        = 51000,
   parameter t_clk_zero           = 252503, 
   parameter t_clk_trail          = 62000,
   parameter t_clk_pre            = 30000,
   parameter t_clk_post           = 131000, //based from waveform

   parameter t_hs_prepare         = 55000,
   parameter t_hs_zero            = 103543, 
   parameter t_hs_trail           = 80000,
   parameter lps_gap              = 100000,
   parameter frame_gap            = 100000,
   parameter init_drive_delay     = 1000,
   parameter dphy_ch              = 0,
   parameter dphy_vc              = 0,
   parameter new_vc               = 0,	// added for VC aggregation
   parameter long_even_line_en    = 0,
   parameter ls_le_en             = 0,
   parameter fnum_embed           = "OFF",
   parameter fnum_max             = 3,	// 2 to 65536
   parameter debug                = 0
)(
   input refclk_i,
   input resetn,
//   input pll_lock,

   output clk_p_i,
   output clk_n_i,
   output cont_clk_p_i,
   output cont_clk_n_i,
   output [active_dphy_lanes-1:0] do_p_i,
   output [active_dphy_lanes-1:0] do_n_i
);

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

wire clk_p_w, clk_n_w;
reg cont_clk_p_r, cont_clk_n_r;

reg clk_en, cont_clk_en;
reg [3:0]  vc;
reg [5:0]  dt;
reg [15:0] wc;
reg [7:0]  ecc;
reg [15:0] chksum;
reg [15:0] cur_crc;
reg odd_even_line; 
reg long_even_line;
reg ls_le;
reg [15:0] lnum;

reg [15:0] fnum;
reg [15:0] frm_cnt=1;

reg dphy_start;
reg dphy_active;

integer i,j,k,l,m,n,p;
reg [7:0] data [3:0];

///// for expected data storage /////
reg [11:0] pointer;
reg [3:0] mod_vc;
reg [7:0] exp_data [0:4095];	// store expected data reflecting new VC

//reg [7:0] byte [3:0];
reg [12:0] byte_pointer;
reg [12:0] vd_pointer;
reg [7:0] exp_video_data [0:8191];	// added for MIPI to LVDS check

/// additonal registers for RAW data handling ///
reg [11:0] line_cnt;
reg [raw_width-1:0] top_pd [0:8191];	// added for MIPI to LVDS check
reg [raw_width-1:0] center_pd [0:8191];	// added for MIPI to LVDS check
reg [raw_width-1:0] bottom_pd [0:8191];	// added for MIPI to LVDS check
reg [7:0] exp_r_data [0:8191];	// added for MIPI to LVDS check
reg [7:0] exp_g_data [0:8191];	// added for MIPI to LVDS check
reg [7:0] exp_b_data [0:8191];	// added for MIPI to LVDS check
reg [7:0] exp_ll_r_data [0:8191];	// added for MIPI to LVDS check, last line
reg [7:0] exp_ll_g_data [0:8191];	// added for MIPI to LVDS check, last line
reg [7:0] exp_ll_b_data [0:8191];	// added for MIPI to LVDS check, last line


wire [7:0] data0;
wire [7:0] data1;
wire [7:0] data2;
wire [7:0] data3;

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


clk_driver clk_drv();
bus_driver#(.ch(dphy_ch), .lane(0),.debug(debug) ,.dphy_clk(dphy_clk_period)) bus_drv0(.clk_p_i(clk_p_w));
bus_driver#(.ch(dphy_ch), .lane(1),.debug(debug) ,.dphy_clk(dphy_clk_period)) bus_drv1(.clk_p_i(clk_p_w));
bus_driver#(.ch(dphy_ch), .lane(2),.debug(debug) ,.dphy_clk(dphy_clk_period)) bus_drv2(.clk_p_i(clk_p_w));
bus_driver#(.ch(dphy_ch), .lane(3),.debug(debug) ,.dphy_clk(dphy_clk_period)) bus_drv3(.clk_p_i(clk_p_w));

assign clk_p_i = clk_p_w; 
assign clk_n_i = clk_n_w;
assign cont_clk_p_i = cont_clk_p_r;
assign cont_clk_n_i = cont_clk_n_r;
assign clk_p_w = clk_drv.clk_p_i;
assign clk_n_w = clk_drv.clk_n_i;
assign do_p_i[0] = bus_drv0.do_p_i;
assign do_n_i[0] = bus_drv0.do_n_i;
if (active_dphy_lanes > 1) begin
	assign do_p_i[1] = bus_drv1.do_p_i;
	assign do_n_i[1] = bus_drv1.do_n_i;
end
if (active_dphy_lanes == 4) begin
	assign do_p_i[2] = bus_drv2.do_p_i;
	assign do_n_i[2] = bus_drv2.do_n_i;
	assign do_p_i[3] = bus_drv3.do_p_i;
	assign do_n_i[3] = bus_drv3.do_n_i;
end

assign data0 = data[0];
assign data1 = data[1];
assign data2 = data[2];
assign data3 = data[3];

initial begin
`ifdef RX_RAW12
	num_bytes = 3;
`elsif RX_RAW10 
        num_bytes = 5;
`elsif RX_RAW8 
        num_bytes = 1;
`elsif RX_RGB888 
        num_bytes = 3;
`elsif RX_YUV_420_8
	num_bytes = 1;
`elsif RX_YUV_420_8_CSPS
	num_bytes = 1;
`elsif RX_LEGACY_YUV_420_8
	num_bytes = 1;
`elsif RX_YUV_420_10
	num_bytes = 5;
`elsif RX_YUV_420_10_CSPS
	num_bytes = 5;
`elsif RX_YUV_422_8
	num_bytes = 1;
`elsif RX_YUV_422_10
	num_bytes = 5;
`endif



	vc = dphy_vc;
	dt = data_type;
	wc = num_payload;
	if (fnum_embed == "ON") begin
		fnum = 1;
	end
	else begin
		fnum = 0;
	end
	chksum = 16'hffff;
	dphy_active = 0;
	cont_clk_p_r = 1;
	cont_clk_n_r = 1;
	long_even_line = long_even_line_en;
	ls_le = ls_le_en;
	data[0]  = 0;
	data[1]  = 0;
	data[2]  = 0;
	data[3]  = 0;

	pointer = 0;
	mod_vc = new_vc;

//      `ifndef RX_CLK_MODE_HS_ONLY
	if (clk_mode != "HS_ONLY") begin
		@(posedge dphy_active);
		$display("%t DPHY CSI-2 model activated\n", $time);
		#(init_drive_delay);
		$display("%t DPHY CSI-2 Initial Drive Delay ends...\n", $time);
	end
//      `endif

	fork
		begin
			drive_cont_clk;
		end
		begin

//            `ifdef RX_CLK_MODE_HS_ONLY
			if (clk_mode == "HS_ONLY") begin
				@(posedge dphy_active);
				$display("%t DPHY CSI-2 model activated\n", $time);

				#(init_drive_delay);
			end
//            `endif 

			repeat (num_frames) begin
				// FS
//            #lps_gap;
				$display("%t DPHY CSI-2 FS begins...\n", $time);
				drive_fs;
      
				odd_even_line = 0;
			   line_cnt = 0;	// added for RAW, MT	
               //Drive data
				repeat (num_lines) begin
					if (ls_le == 1) begin
						#lps_gap;
						drive_ls;
					end
					#lps_gap;
					if (long_even_line == 1) begin
						if (odd_even_line == 0) begin
							wc = num_payload;
						end
						else if (odd_even_line == 1) begin
							wc = num_payload*2;
						end
					end
					drive_data;

					if (ls_le == 1) begin
						#lps_gap;
						drive_le;
					end
					odd_even_line = ~odd_even_line;
			   		line_cnt = line_cnt + 1;	
				end
				//FE
				#lps_gap;
				drive_fe;
				$display("%t DPHY CSI-2 before frame gap\n", $time);
				//#frame_gap;
				#lps_gap;
				$display("%t DPHY CSI-2 after frame gap\n", $time);
            end
      
			#lps_gap;
			dphy_active = 0;
			if (clk_mode != "HS_ONLY") begin
				cont_clk_en = 0;
			end
//            cont_clk_en = 0;
		end
	join
end

initial begin
   clk_en = 0;
   cont_clk_en = 0;
end
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

task drive_cont_clk;
begin
   #1000;
   // HS-RQST
//   $display("%t DPHY CH %0d CLK CONT : Driving HS-CLK-RQST", $time, dphy_ch);
   $display("%t DPHY CLK CONT : Driving HS-CLK-RQST", $time);
   cont_clk_p_r = 0;
   cont_clk_n_r = 1;
   #t_lpx;

   // HS-Prpr
//   $display("%t DPHY CH %0d CLK CONT : Driving HS-Prpr", $time, dphy_ch);
   $display("%t DPHY CLK CONT : Driving HS-Prpr", $time);
   cont_clk_p_r = 0;
   cont_clk_n_r = 0;
   #t_clk_prepare;

   // HS-Go
//   $display("%t DPHY CH %0d CLK CONT : Driving HS-Go", $time, dphy_ch);
   $display("%t DPHY CLK CONT : Driving HS-Go", $time);
   cont_clk_p_r = 0;
   cont_clk_n_r = 1;
   #t_clk_zero;

   cont_clk_en = 1;
//   $display("%t DPHY CH %0d CLK CONT : Driving HS-0/HS-1", $time, dphy_ch);
   $display("%t DPHY CLK CONT : Driving HS-0/HS-1", $time);
   while (cont_clk_en) begin
      @(refclk_i);
      cont_clk_p_r = refclk_i;
      cont_clk_n_r = ~refclk_i;
   end

   // Trail HS-0
//   $display("%t DPHY CH %0d CLK CONT : Driving CLK-Trail", $time, dphy_ch);
   $display("%t DPHY CLK CONT : Driving CLK-Trail", $time);
   #t_clk_trail;

   // TX-Stop
//   $display("%t DPHY CH %0d CLK CONT : Driving CLK-Stop", $time, dphy_ch);
   $display("%t DPHY CLK CONT : Driving CLK-Stop", $time);
   clk_drv.drv_clk_st(1, 1);
end
endtask

task drive_clk;
begin 

   #1000;
   // HS-RQST
//   $display("%t DPHY CH %0d CLK : Driving HS-CLK-RQST", $time, dphy_ch);
   $display("%t DPHY CLK : Driving HS-CLK-RQST", $time);
   clk_drv.drv_clk_st(0, 1);
   #t_lpx;

   // HS-Prpr
//   $display("%t DPHY CH %0d CLK : Driving HS-Prpr", $time, dphy_ch);
   $display("%t DPHY CLK : Driving HS-Prpr", $time);
   clk_drv.drv_clk_st(0, 0);
   #t_clk_prepare;

   // HS-Go
//   $display("%t DPHY CH %0d CLK : Driving HS-Go", $time, dphy_ch);
   $display("%t DPHY CLK : Driving HS-Go", $time);
   clk_drv.drv_clk_st(0, 1);
   #t_clk_zero;

   clk_en = 1;
//   $display("%t DPHY CH %0d CLK : Driving HS-0/HS-1", $time, dphy_ch);
   $display("%t DPHY CLK : Driving HS-0/HS-1", $time);
   while (clk_en) begin
      @(refclk_i);
      clk_drv.drv_clk_st(refclk_i, ~refclk_i);
   end

   // Trail HS-0
//   $display("%t DPHY CH %0d CLK : Driving CLK-Trail", $time, dphy_ch);
   $display("%t DPHY CLK : Driving CLK-Trail", $time);
   #t_clk_trail;

   // TX-Stop
//   $display("%t DPHY CH %0d CLK : Driving CLK-Stop", $time, dphy_ch);
   $display("%t DPHY CLK : Driving CLK-Stop", $time);
   clk_drv.drv_clk_st(1, 1);

end
endtask

task drive_fs;
begin
   fork
      begin
         drive_clk;
      end
      begin
         pre_data;

         // FS packet
         data[0] = {vc[1:0], 6'h00};
         data[1] = fnum[7:0];
         data[2] = fnum[15:8];
         get_ecc({vc[3:2], data[2], data[1], data[0]}, data[3]);
         //data[3] = 8'h15;
		 
//         $display("%t DPHY CH %0d DATA : Driving FS", $time, dphy_ch);
         $display("%t DPHY DATA : Driving FS", $time);
         if (active_dphy_lanes == 1) begin
            for (i = 0 ; i < 4 ; i = i + 1) begin
//            	$display("%t DPHY CH %0d DATA : Driving data = %2h", $time, dphy_ch, data[i]);
            	$display("%t DPHY DATA : Driving data = %2h", $time, data[i]);
               bus_drv0.drive_datax(data[i]);
            end
         end else 
         if (active_dphy_lanes == 2) begin
            for (i = 0 ; i < 4 ; i = i + 2) begin
//            $display("%t DPHY CH %0d DATA : Driving data = %2h ", $time, dphy_ch, i, data[i]);
//            $display("%t DPHY [%0d] DATA : Driving data[%0d] = %0x", $time, dphy_ch, i+1, data[i+1]);
//            $display("%t DPHY CH %0d DATA : Driving data = %2h %2h", $time, dphy_ch, data[i], data[i+1]);
            $display("%t DPHY DATA : Driving data = %2h %2h", $time, data[i], data[i+1]);
               fork
                  bus_drv0.drive_datax(data[i]);
                  bus_drv1.drive_datax(data[i+1]);
               join
            end
         end else
         if (active_dphy_lanes == 4) begin
//            $display("%t DPHY CH %0d DATA : Driving data = %2h %2h %2h %2h", $time, dphy_ch, data[0], data[1], data[2], data[3]);
            $display("%t DPHY DATA : Driving data = %2h %2h %2h %2h", $time, data[0], data[1], data[2], data[3]);
            fork
               bus_drv0.drive_datax(data[0]);
               bus_drv1.drive_datax(data[1]);
               bus_drv2.drive_datax(data[2]);
               bus_drv3.drive_datax(data[3]);
            join
         end

		 /// make new FS packet using a new VC and store the result ///
		 if (vc_mode == "REPLACE") begin
			if (frame_counter == "ON") begin
		 		ph_replace(1, 1, {data[2], data[1], data[0]});
			end
			else begin
		 		ph_replace(1, 0, {data[2], data[1], data[0]});
			end
		 end
		 else begin
			if (frame_counter == "ON") begin
		 		ph_replace(0, 1, {data[2], data[1], data[0]});
			end
			else begin
		 		ph_replace(0, 0, {data[2], data[1], data[0]});
			end
		 end

         post_data;

         // reset line number
         lnum = 1;
      end
   join
end
endtask

task drive_ls;
begin
   fork
      begin
         drive_clk;
      end
      begin
         pre_data;

         // LS packet
         data[0] = {vc[1:0], 6'h02};
         data[1] = lnum[7:0];
         data[2] = lnum[15:8];
         get_ecc({vc[3:2], data[2], data[1], data[0]}, data[3]);

//         $display("%t DPHY CH %0d DATA : Driving LS", $time, dphy_ch);
         $display("%t DPHY DATA : Driving LS", $time);
         if (active_dphy_lanes == 1) begin
            for (i = 0 ; i < 4 ; i = i + 1) begin
//               $display("%t DPHY CH %0d DATA : Driving data = %2h", $time, dphy_ch, data[i]);
               $display("%t DPHY DATA : Driving data = %2h", $time, data[i]);
               bus_drv0.drive_datax(data[i]);
            end
         end else
         if (active_dphy_lanes == 2) begin
            for (i = 0 ; i < 4 ; i = i + 2) begin
//            $display("%t DPHY [%0d] DATA : Driving data[%0d] = %0x", $time, dphy_ch, i, data[i]);
//            $display("%t DPHY [%0d] DATA : Driving data[%0d] = %0x", $time, dphy_ch, i+1, data[i+1]);
//            $display("%t DPHY CH %0d DATA : Driving data = %2h %2h", $time, dphy_ch, data[i], data[i+1]);
            $display("%t DPHY DATA : Driving data = %2h %2h", $time, data[i], data[i+1]);
               fork
                  bus_drv0.drive_datax(data[i]);
                  bus_drv1.drive_datax(data[i+1]);
               join
            end
         end else
         if (active_dphy_lanes == 4) begin
//            $display("%t DPHY CH %0d DATA : Driving data = %2h %2h %2h %2h", $time, dphy_ch, data[0], data[1], data[2], data[3]);
            $display("%t DPHY DATA : Driving data = %2h %2h %2h %2h", $time, data[0], data[1], data[2], data[3]);
            fork
               bus_drv0.drive_datax(data[0]);
               bus_drv1.drive_datax(data[1]);
               bus_drv2.drive_datax(data[2]);
               bus_drv3.drive_datax(data[3]);
            join
         end

		 /// make new LS packet using a new VC and store the result ///
		 if (vc_mode == "REPLACE") begin
		 	ph_replace(1, 0, {data[2], data[1], data[0]});
		 end
		 else begin
		 	ph_replace(0, 0, {data[2], data[1], data[0]});
		 end

         post_data;

         // reset line number
         lnum = 1;
      end
   join
end
endtask

task drive_fe;
begin
   fork
      begin
         drive_clk;
      end
      begin
         pre_data;

         // FE packet
         data[0] = {vc[1:0], 6'h01};
         data[1] = fnum[7:0];
         data[2] = fnum[15:8];
         get_ecc({vc[3:2], data[2], data[1], data[0]}, data[3]);

//         $display("%t DPHY CH %0d DATA : Driving FE", $time, dphy_ch);
         $display("%t DPHY DATA : Driving FE", $time);
         if (active_dphy_lanes == 1) begin
            for (i = 0 ; i < 4 ; i = i + 1) begin
               bus_drv0.drive_datax(data[i]);
            end
         end else
         if (active_dphy_lanes == 2) begin
            for (i = 0 ; i < 4 ; i = i + 2) begin
               fork
                  bus_drv0.drive_datax(data[i]);
                  bus_drv1.drive_datax(data[i+1]);
               join
            end
         end else
         if (active_dphy_lanes == 4) begin
            fork
               bus_drv0.drive_datax(data[0]);
               bus_drv1.drive_datax(data[1]);
               bus_drv2.drive_datax(data[2]);
               bus_drv3.drive_datax(data[3]);
            join
         end

		 /// make new FE packet using a new VC and store the result ///
		 if (vc_mode == "REPLACE") begin
			if (frame_counter == "ON") begin
		 		ph_replace(1, 1, {data[2], data[1], data[0]});
			end
			else begin
		 		ph_replace(1, 0, {data[2], data[1], data[0]});
			end
		 end
		 else begin
			if (frame_counter == "ON") begin
		 		ph_replace(0, 1, {data[2], data[1], data[0]});
			end
			else begin
		 		ph_replace(0, 0, {data[2], data[1], data[0]});
			end
		 end

         post_data;
		 if (fnum_embed == "ON") begin
		 	if (fnum == fnum_max) begin
		 		fnum = 1;
		 	end
		 	else begin
         		fnum = fnum+1;
		 	end
		end
//		else begin
//         	fnum = fnum;
//		end

		 if (frame_counter == "ON") begin
		 	if (frm_cnt == frame_count_max) begin
		 		frm_cnt = 1;
		 	end
		 	else begin
         		frm_cnt = frm_cnt+1;
		 	end
		end
//		else begin
//         	frm_cnt = frm_cnt;
//		end



      end
   join

end
endtask

task drive_le;
begin
   fork
      begin
         drive_clk;
      end
      begin
         pre_data;

         // LE packet
         data[0] = {vc[1:0], 6'h03};
         data[1] = lnum[7:0];
         data[2] = lnum[15:0];
         get_ecc({vc[3:2], data[2], data[1], data[0]}, data[3]);

//         $display("%t DPHY CH %0d DATA : Driving LE", $time, dphy_ch);
         $display("%t DPHY DATA : Driving LE", $time);
         if (active_dphy_lanes == 1) begin
            for (i = 0 ; i < 4 ; i = i + 1) begin
               bus_drv0.drive_datax(data[i]);
            end
         end else
         if (active_dphy_lanes == 2) begin
            for (i = 0 ; i < 4 ; i = i + 2) begin
               fork
                  bus_drv0.drive_datax(data[i]);
                  bus_drv1.drive_datax(data[i+1]);
               join
            end
         end else
         if (active_dphy_lanes == 4) begin
            fork
               bus_drv0.drive_datax(data[0]);
               bus_drv1.drive_datax(data[1]);
               bus_drv2.drive_datax(data[2]);
               bus_drv3.drive_datax(data[3]);
            join
         end

		 /// make new LE packet using a new VC and store the result ///
		 if (vc_mode == "REPLACE") begin
		 	ph_replace(1, 0, {data[2], data[1], data[0]});
		 end
		 else begin
		 	ph_replace(0, 0, {data[2], data[1], data[0]});
		 end

         post_data;
         lnum = lnum + 1;
      end
   join

end
endtask
//`include "csi2_tasks.vh"
task drive_data;
begin
   fork
      begin
         drive_clk;
      end
      begin
         pre_data;

         //drive header
         data[0] = {vc[1:0], dt};
         data[1] = {wc[7:0]};
         data[2] = {wc[15:8]};
         get_ecc({vc[3:2], data[2], data[1], data[0]}, data[3]);

//         $display("%t DPHY CH %0d Driving Data header", $time, dphy_ch);
         $display("%t DPHY Driving Data header", $time);
         if (active_dphy_lanes == 1) begin
            for (i = 0 ; i < 4 ; i = i + 1) begin
//         		$display("%t DPHY CH %0d Driving Data header for data = %2h", $time, dphy_ch, data[i]);
         		$display("%t DPHY Driving Data header for data = %2h", $time, data[i]);
               bus_drv0.drive_datax(data[i]);
            end
         end else
         if (active_dphy_lanes == 2) begin
            for (i = 0 ; i < 4 ; i = i + 2) begin
//         $display("%t DPHY [%0d] Driving Data header for data[%0d] = %x", $time, dphy_ch, i, data[i]);
//         $display("%t DPHY [%0d] Driving Data header for data[%0d] = %x", $time, dphy_ch, i+1, data[i+1]);
//         		$display("%t DPHY CH %0d Driving Data header for data = %2h %2h", $time, dphy_ch, data[i], data[i+1]);
         		$display("%t DPHY Driving Data header for data = %2h %2h", $time, data[i], data[i+1]);
               fork
                  bus_drv0.drive_datax(data[i]);
                  bus_drv1.drive_datax(data[i+1]);
               join
            end
         end else
         if (active_dphy_lanes == 4) begin
//         	$display("%t DPHY CH %0d Driving Data header for data = %2h %2h %2h %2h", $time, dphy_ch, data[0], data[1], data[2], data[3]);
         	$display("%t DPHY Driving Data header for data = %2h %2h %2h %2h", $time, data[0], data[1], data[2], data[3]);
            fork
               bus_drv0.drive_datax(data[0]);
               bus_drv1.drive_datax(data[1]);
               bus_drv2.drive_datax(data[2]);
               bus_drv3.drive_datax(data[3]);
            join
         end

		 /// make new long packet using a new VC and store the result ///
		 if (vc_mode == "REPLACE") begin
		 	ph_replace(1, 0, {data[2], data[1], data[0]});
		 end
		 else begin
		 	ph_replace(0, 0, {data[2], data[1], data[0]});
		 end

         // reset crc value
         chksum = 16'hffff;

         // temporary alternating data 8'h0 and 8'hFF
         data[0] = 0;
         data[1] = 0;
         data[2] = 0;
         data[3] = 0;
         // random data packet

		 byte_pointer = 0;	// reset for every line
		 vd_pointer = 0;	// reset for every line

	 num_bytes_i=0;
         repeat (wc/active_dphy_lanes) begin // use variable later
         //for(num_bytes_i=0;num_bytes_i<num_bytes*active_dphy_lanes*GEAR/8;num_bytes_i=num_bytes_i+1)begin
            for (i = 0; i < active_dphy_lanes; i = i + 1) begin
		    data[i] = $random;
		    //data[i] = 8'h5a;
                //if (debug == 0) begin
                //  data[i] = $random;
                //end else
                //begin
                //  data[i] = ~data[i];
                //end
                compute_crc16(data[i]);
		 		/// store the data to be compared later ///
		 			exp_data[pointer] = data[i];
					pointer = (pointer + 1)%4096;
		 			exp_video_data[vd_pointer] = data[i];	// added for MIPI to LVDS check!!!!!
					vd_pointer = vd_pointer + 1;
		 		///////////////////////////////////////////
	    	//if ((i != 0) && (num_bytes_i != 0)) begin			
	    	if (i != 0 ) begin			
	    	num_bytes_i = num_bytes_i + 1;
		//$display(" \n \n inside %2d \n \n ",num_bytes_i);
   	    	end
	    	b[num_bytes_i] = data[i];
		write_to_file_byte("expected_data_byte.log",data[i]);
		//$display(" \n \n inside 222 %2d \n \n ",num_bytes_i);
            end
		//$display(" \n \n inside 2222222 %2d \n \n ",num_bytes_i);
	    //if (num_bytes_i == (num_bytes*active_dphy_lanes*GEAR/8 - 1)) begin 
	    //    `ifdef RX_RGB888
	    //    gen_csi2_rgb888_pixel_data;
	    //    `elsif RX_RAW8
	    //    gen_csi2_raw8_pixel_data;
	    //    `elsif RX_RAW10
	    //    gen_csi2_raw10_pixel_data;
	    //    `elsif RX_RAW12
	    //    gen_csi2_raw12_pixel_data;
	    //    `endif
	    //    num_bytes_i = 0;
	    //end
	    //else begin
	    //    num_bytes_i = num_bytes_i + 1;
	    //end

//            $display("%t DPHY CH %0d Driving Data", $time, dphy_ch);
           // $display("%t DPHY Driving Data", $time);
            if (active_dphy_lanes == 1) begin
         //      for (i = 0 ; i < num_bytes*active_dphy_lanes*GEAR/8 ; i = i + 1) begin
                  bus_drv0.drive_datax(data[0]);
           //    end
            end else
            if (active_dphy_lanes == 2) begin
               //for (i = 0 ; i < num_bytes*active_dphy_lanes*GEAR/8 ; i = i + 2) begin
                  fork
                     bus_drv0.drive_datax(data[0]);
                     bus_drv1.drive_datax(data[1]);
                  join
               //end
            end else
            if (active_dphy_lanes == 4) begin
               //for (i = 0 ; i < num_bytes*active_dphy_lanes*GEAR/8 ; i = i + 4) begin
               fork
                  bus_drv0.drive_datax(data[0]);
                  bus_drv1.drive_datax(data[1]);
                  bus_drv2.drive_datax(data[2]);
                  bus_drv3.drive_datax(data[3]);
               join
               //end
            end
		
         end

		/// need to take care of the residual data if wc is not a multiple of lane count, MT ///
		if ((active_dphy_lanes == 2 && wc%2 != 0) || (active_dphy_lanes == 4 && wc%4 != 0)) begin	// mod = 1, 2, 3
			data[0] = $random;
			compute_crc16(data[0]);
		 	/// store the data to be compared later ///
		 	exp_data[pointer] = data[0];
			pointer = (pointer + 1)%4096;
		 	exp_video_data[vd_pointer] = data[0];	// added for MIPI to LVDS check!!!!!
		        write_to_file_byte("expected_data_byte.log",data[0]);
			vd_pointer = vd_pointer + 1;
		 		///////////////////////////////////////////
			if (active_dphy_lanes == 4 && wc%4 != 1) begin	// mod = 2, 3
				data[1] = $random;
				compute_crc16(data[1]);
		 		/// store the data to be compared later ///
		 		exp_data[pointer] = data[1];
				pointer = (pointer + 1)%4096;
		 		exp_video_data[vd_pointer] = data[1];	// added for MIPI to LVDS check!!!!!
		        	write_to_file_byte("expected_data_byte.log",data[1]);
				vd_pointer = vd_pointer + 1;
		 		///////////////////////////////////////////
				if (active_dphy_lanes == 4 && wc%4 != 2) begin	// mod = 3
					data[2] = $random;
					compute_crc16(data[2]);
		 			/// store the data to be compared later ///
		 			exp_data[pointer] = data[2];
					pointer = (pointer + 1)%4096;
		 			exp_video_data[vd_pointer] = data[2];	// added for MIPI to LVDS check!!!!!
		        		write_to_file_byte("expected_data_byte.log",data[2]);
					vd_pointer = vd_pointer + 1;
		 		///////////////////////////////////////////
				end
			end
		end

		// drive crc data until end of packet
//		$display("%t DPHY CH %0d Driving CRC[15:8] = %0x; CRC[7:0] = %0x", $time, dphy_ch, chksum[15:8], chksum[7:0]);
		$display("%t DPHY Driving CRC[15:8] = %0x; CRC[7:0] = %0x", $time, chksum[15:8], chksum[7:0]);
		/// store the data to be compared later ///
		exp_data[pointer] = chksum[7:0];
		pointer = (pointer + 1)%4096;
		exp_data[pointer] = chksum[15:8];
		pointer = (pointer + 1)%4096;

         if (active_dphy_lanes == 1) begin
            bus_drv0.drive_datax(chksum[7:0]);
            bus_drv0.drive_datax(chksum[15:8]);
            bus_drv0.drv_trail;
         end else
         if (active_dphy_lanes == 2) begin
			if (wc%2 == 0) begin
            	fork
               		bus_drv0.drive_datax(chksum[7:0]);
               		bus_drv1.drive_datax(chksum[15:8]);
            	join
            	fork
               		bus_drv0.drv_trail;
               		bus_drv1.drv_trail;
            	join
			end
			else begin
            	fork
                    bus_drv0.drive_datax(data[0]);
               		bus_drv1.drive_datax(chksum[7:0]);
            	join
            	fork
               		bus_drv0.drive_datax(chksum[15:8]);
               		bus_drv1.drv_trail;
            	join
               	bus_drv0.drv_trail;
			end
		end else
		if (active_dphy_lanes == 4) begin
			if (wc%4 == 0) begin
            	fork
               		bus_drv0.drive_datax(chksum[7:0]);
               		bus_drv1.drive_datax(chksum[15:8]);
               		bus_drv2.drv_trail;
               		bus_drv3.drv_trail;
            	join
            	fork
               		bus_drv0.drv_trail;
               		bus_drv1.drv_trail;
            	join
			end
			else if (wc%4 == 1) begin
            	fork
                    bus_drv0.drive_datax(data[0]);
               		bus_drv1.drive_datax(chksum[7:0]);
               		bus_drv2.drive_datax(chksum[15:8]);
               		bus_drv3.drv_trail;
            	join
            	fork
               		bus_drv0.drv_trail;
               		bus_drv1.drv_trail;
               		bus_drv2.drv_trail;
            	join
			end
			else if (wc%4 == 2) begin
            	fork
                    bus_drv0.drive_datax(data[0]);
                    bus_drv1.drive_datax(data[1]);
               		bus_drv2.drive_datax(chksum[7:0]);
               		bus_drv3.drive_datax(chksum[15:8]);
            	join
            	fork
               		bus_drv0.drv_trail;
               		bus_drv1.drv_trail;
               		bus_drv2.drv_trail;
               		bus_drv3.drv_trail;
            	join
			end
			else if (wc%4 == 3) begin
            	fork
                    bus_drv0.drive_datax(data[0]);
                    bus_drv1.drive_datax(data[1]);
                    bus_drv2.drive_datax(data[2]);
               		bus_drv3.drive_datax(chksum[7:0]);
            	join
            	fork
               		bus_drv0.drive_datax(chksum[15:8]);
                    bus_drv1.drv_trail;
                    bus_drv2.drv_trail;
                    bus_drv3.drv_trail;
            	join
                bus_drv0.drv_trail;
			end
         end 

         //Start HS-trail --- This part is now included in the above to handle
		 //different data residual cases
/*
         fork
            bus_drv0.drv_trail;
            begin
               if (active_dphy_lanes == 2 || active_dphy_lanes == 4) begin
                  bus_drv1.drv_trail;
               end
            end
         join
*/

         #t_hs_trail;

         // HS-Stop
         //@(clk_p_i);
         fork
            bus_drv0.drv_stop;
            begin
               if (active_dphy_lanes == 2) begin
                  bus_drv1.drv_stop;
               end
            end
            begin
               if (active_dphy_lanes == 4) begin
                  fork
                     bus_drv1.drv_stop;
                     bus_drv2.drv_stop;
                     bus_drv3.drv_stop;
                  join
               end
            end
         join

         #t_clk_post;
         clk_en = 0;

      end
   join
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


reg [7:0]	new_ecc;

///// replace the original packet header with new one using new VC /////
task ph_replace(input vc_replace, input fc_replace, input [23:0] original);
	begin
		if ((vc_replace == 1) & (fc_replace == 0)) begin
	        get_ecc({mod_vc[3:2], original[23:8], mod_vc[1:0], original[5:0]}, new_ecc);
			exp_data[pointer] = {mod_vc[1:0], original[5:0]};
			exp_data[(pointer+1)%4096] = original[15:8];
			exp_data[(pointer+2)%4096] = original[23:16];
		end
		else if ((vc_replace == 1) & (fc_replace == 1)) begin
	        get_ecc({mod_vc[3:2], frm_cnt[15:0], mod_vc[1:0], original[5:0]}, new_ecc);
			exp_data[pointer] = {mod_vc[1:0], original[5:0]};
			exp_data[(pointer+1)%4096] = frm_cnt[7:0];
			exp_data[(pointer+2)%4096] = frm_cnt[15:8];
		end
		else if ((vc_replace == 0) & (fc_replace == 1)) begin
	        get_ecc({vc[3:2], frm_cnt[15:0], vc[1:0], original[5:0]}, new_ecc);
			exp_data[pointer] = {vc[1:0], original[5:0]};
			exp_data[(pointer+1)%4096] = frm_cnt[7:0];
			exp_data[(pointer+2)%4096] = frm_cnt[15:8];
		end
		else begin
	        get_ecc({vc[3:2], original[23:8], vc[1:0], original[5:0]}, new_ecc);
			exp_data[pointer] = {vc[1:0], original[5:0]};
			exp_data[(pointer+1)%4096] = original[15:8];
			exp_data[(pointer+2)%4096] = original[23:16];
		end
		exp_data[(pointer+3)%4096] = new_ecc;
		pointer = (pointer + 4)%4096;
	end
endtask



task compute_crc16(input [7:0] data);
begin
   for (n = 0; n < 8; n = n + 1) begin
     cur_crc = chksum;
     cur_crc[15] = data[n]^cur_crc[0];
     cur_crc[10] = cur_crc[11]^cur_crc[15];
     cur_crc[3]  = cur_crc[4]^cur_crc[15]; 
     chksum = chksum >> 1;
     chksum[15] = cur_crc[15];
     chksum[10] = cur_crc[10];
     chksum[3] = cur_crc[3];
   end
end
endtask

task pre_data;
begin
   @(posedge clk_en);

//   repeat (5) begin
//     @(posedge clk_p_i);
//   end

   #t_clk_pre;

   // HS-RQST
//   $display("%t DPHY CH %0d DATA : Driving HS-RQST", $time, dphy_ch);
   $display("%t DPHY DATA : Driving HS-RQST", $time);
    bus_drv0.drv_dat_st(0,1);
    if (active_dphy_lanes == 2) begin
    bus_drv1.drv_dat_st(0,1);
    end else
    if (active_dphy_lanes == 4) begin
    bus_drv1.drv_dat_st(0,1);
    bus_drv2.drv_dat_st(0,1);
    bus_drv3.drv_dat_st(0,1);
    end
   #t_lpx;

   // HS-Prpr
//   $display("%t DPHY CH %0d DATA : Driving HS-Prpr", $time, dphy_ch);
   $display("%t DPHY DATA : Driving HS-Prpr", $time);
    bus_drv0.drv_dat_st(0,0);
    if (active_dphy_lanes == 2) begin
    bus_drv1.drv_dat_st(0,0);
    end else
    if (active_dphy_lanes == 4) begin
    bus_drv1.drv_dat_st(0,0);
    bus_drv2.drv_dat_st(0,0);
    bus_drv3.drv_dat_st(0,0);
    end
   #t_hs_prepare;

   // HS-Go
//   $display("%t DPHY CH %0d CLK : Driving HS-Go", $time, dphy_ch);
   $display("%t DPHY CLK : Driving HS-Go", $time);
    bus_drv0.drv_dat_st(0,1);
    if (active_dphy_lanes == 2) begin
    bus_drv1.drv_dat_st(0,1);
    end else
    if (active_dphy_lanes == 4) begin
    bus_drv1.drv_dat_st(0,1);
    bus_drv2.drv_dat_st(0,1);
    bus_drv3.drv_dat_st(0,1);
    end
   #t_hs_zero;

   //sync with clock
//   @(clk_p_i);
   @(posedge clk_p_i);	// MT, make the 1st bit of B8 be always sampled by clk posedge 
   #1; // MT

   // HS-Sync
   // generate data
   for (i = 0; i < active_dphy_lanes; i = i + 1) begin
       data[i] = 8'hB8;
   end

//   $display("%t DPHY CH %0d CLK : Driving SYNC Data", $time, dphy_ch);
   $display("%t DPHY CLK : Driving SYNC Data", $time);
   if (active_dphy_lanes == 1) begin
       bus_drv0.drive_datax(data[0]);
   end else
   if (active_dphy_lanes == 2) begin
   fork
       bus_drv0.drive_datax(data[0]);
       bus_drv1.drive_datax(data[1]);
   join
   end else
   if (active_dphy_lanes == 4) begin
   fork
       bus_drv0.drive_datax(data[0]);
       bus_drv1.drive_datax(data[1]);
       bus_drv2.drive_datax(data[2]);
       bus_drv3.drive_datax(data[3]);
   join
   end
end
endtask

task post_data;
begin
   // HS-Trail
//   $display("%t DPHY CH %0d DATA : Driving HS-Trail", $time, dphy_ch);
   $display("%t DPHY DATA : Driving HS-Trail", $time);
   fork
         bus_drv0.drv_trail;
         begin
            if (active_dphy_lanes == 2) begin
               bus_drv1.drv_trail;
            end
         end
         begin
            if (active_dphy_lanes == 4) begin
               fork
                   bus_drv1.drv_trail;
                   bus_drv2.drv_trail;
                   bus_drv3.drv_trail;
               join
            end
         end
   join
   #t_hs_trail;

   // HS-Stop
//   $display("%t DPHY CH %0d DATA : Driving HS-Stop", $time, dphy_ch);
   $display("%t DPHY DATA : Driving HS-Stop", $time);
   fork
         bus_drv0.drv_stop;
         begin
             if (active_dphy_lanes == 2) begin
                 bus_drv1.drv_stop;
             end 
         end
         begin
             if (active_dphy_lanes == 4) begin
                fork
                    bus_drv1.drv_stop;
                    bus_drv2.drv_stop;
                    bus_drv3.drv_stop;
                join
             end
         end
   join

         #131000; // based from waveform
         clk_en = 0;
end
endtask

task get_ecc (input [25:0] d, output [7:0] ecc_val);
begin
  ecc_val[0] = d[0]^d[1]^d[2]^d[4]^d[5]^d[7]^d[10]^d[11]^d[13]^d[16]^d[20]^d[21]^d[22]^d[23]^d[24];
  ecc_val[1] = d[0]^d[1]^d[3]^d[4]^d[6]^d[8]^d[10]^d[12]^d[14]^d[17]^d[20]^d[21]^d[22]^d[23]^d[25];
  ecc_val[2] = d[0]^d[2]^d[3]^d[5]^d[6]^d[9]^d[11]^d[12]^d[15]^d[18]^d[20]^d[21]^d[22]^d[24]^d[25];
  ecc_val[3] = d[1]^d[2]^d[3]^d[7]^d[8]^d[9]^d[13]^d[14]^d[15]^d[19]^d[20]^d[21]^d[23]^d[24]^d[25];
  ecc_val[4] = d[4]^d[5]^d[6]^d[7]^d[8]^d[9]^d[16]^d[17]^d[18]^d[19]^d[20]^d[22]^d[23]^d[24]^d[25];
  ecc_val[5] = d[10]^d[11]^d[12]^d[13]^d[14]^d[15]^d[16]^d[17]^d[18]^d[19]^d[21]^d[22]^d[23]^d[24]^d[25];
  ecc_val[6] = d[24];
  ecc_val[7] = d[25];
end
endtask

endmodule

