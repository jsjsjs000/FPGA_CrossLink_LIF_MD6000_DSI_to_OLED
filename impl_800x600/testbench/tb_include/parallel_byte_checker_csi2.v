// =========================================================================
// Filename: byte_monitor.v
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved.
// =========================================================================

reg [3:0] local_pix_count = 0;
reg [7:0] b[0:100];
reg [RX_PD_BUS_WIDTH -1:0] data,data1,data2,data3;

reg fv_w_d, lv_w_d;
reg [3:0] frm_cnt;
reg [10:0] active_line_cnt;
integer bytes_per_frame ;

// to avoid defining similar data type multiple times
`ifdef RX_TYPE_CSI2
		`ifdef RX_RGB888
				`define RX_24BPP
		`elsif RX_RAW8
				`define RX_8BPP
		`elsif RX_RAW10
				`define RX_10BPP
		`elsif RX_RAW12
				`define RX_12BPP
		`elsif RX_YUV_420_8
				`define RX_8BPP
		`elsif RX_YUV_420_8_CSPS
				`define RX_8BPP
		`elsif RX_LEGACY_YUV_420_8
				`define RX_8BPP
		`elsif RX_YUV_420_10
				`define RX_10BPP
		`elsif RX_YUV_420_10_CSPS
				`define RX_10BPP
		`elsif RX_YUV_422_8
				`define RX_8BPP
		`elsif RX_YUV_422_10
				`define RX_10BPP
		`endif
`endif

always @(posedge clk_pixel_w or negedge resetn) begin
	if (~resetn) begin
		fv_w_d <= 0;
		lv_w_d <= 0;
	end
	else begin
		fv_w_d <= fv_w;
		lv_w_d <= lv_w;
	end
end

always @(posedge clk_pixel_w or negedge resetn) begin
	if (~resetn) begin
		frm_cnt <= 0;
		bytes_per_frame <= 0;
	end
	else if (fv_w_d^fv_w) begin
		if (fv_w) begin
			$display ("##### FV assertion #####");
			frm_cnt <= frm_cnt + 1;
			//bytes_per_frame <= 0;
		end
		else begin
			$display ("##### FV de-assertion #####");
		end
	end
end

always @(posedge clk_pixel_w) begin
	if (~fv_w & lv_w) begin
		$display ("Control Signal Error, LV is asserted while FV is inactive!!!");
    		$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
		$stop;
	end
end

always @(posedge clk_pixel_w or negedge resetn) begin
	if (~resetn) begin
		active_line_cnt <= 0;
		bytes_per_frame <= 0;
	end
	else if (~fv_w_d & fv_w) begin
		active_line_cnt <= 0;
	end
	else begin
		if (lv_w_d^lv_w) begin
			if (lv_w) begin
				$display ("##### LV assertion #####");
			end
			else begin
				$display ("##### LV de-assertion #####");
				active_line_cnt <= active_line_cnt + 1;
				bytes_per_frame <= 0;
			end
		end
	end
end


        initial detect_pixel_data_in_csi2;

integer actual_pixel_count = 0;
integer actual_byte_count = 0;
    task detect_pixel_data_in_csi2;
    begin
        forever begin
            @(posedge clk_pixel_w);
            if(lv_i ==1 && fv_i==1 && `RX_PEL_PER_CLK ==1) begin
                data = pd_w[RX_PD_BUS_WIDTH -1:0] ; 
		local_pix_count = local_pix_count + 1;
    `ifdef RX_8BPP
		if (RX_DT == "RAW8" | RX_DT == "YUV_420_8" | RX_DT == "YUV_420_8_CSPS" | RX_DT == "LEGACY_YUV_420_8" | RX_DT == "YUV_422_8") begin : data8bit_monitor_pix_clk_01
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[7:0];
                    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 1;
		          end
		  endcase
	        end
    `elsif RX_10BPP
		if (RX_DT == "RAW10" | RX_DT == "YUV_420_10" | RX_DT == "YUV_420_10_CSPS" | RX_DT == "YUV_422_10" ) begin : data10bit_monitor_pix_clk_01
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[9:2];
		            b[4][1:0] = data[1:0];
		          end
		    4'h2: begin 
		    	    b[1][7:0] = data[9:2];
		    	    b[4][3:2] = data[1:0];
		          end
		    4'h3: begin 
		            b[2][7:0] = data[9:2];
		    	    b[4][5:4] = data[1:0];
		          end
		    4'h4: begin 
		    	    b[3][7:0] = data[9:2];
		    	    b[4][7:6] = data[1:0];
                    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[3]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[3]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[3]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[4]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[4]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[4]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 5;
		          end
		  endcase
		end
    `elsif RX_12BPP
		if (RX_DT == "RAW12") begin : data12bit_monitor_pix_clk_01
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[11:4];
		            b[2][3:0] = data[3:0];
		          end
		    4'h2: begin 
		    	    b[1][7:0] = data[11:4];
		    	    b[2][7:4] = data[3:0];
		    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 3;
		          end
		  endcase
		end
    `elsif RX_24BPP
		if (RX_DT == "RGB888") begin : data24bit_monitor_pix_clk_01
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[7:0];
		            b[1][7:0] = data[15:8];
		            b[2][7:0] = data[23:16];
		    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 3;
		          end
		  endcase
		end
    `endif
                actual_pixel_count = actual_pixel_count + 1;
            end
        
            else if(lv_i ==1 && fv_i==1 && `RX_PEL_PER_CLK ==2) begin
                data = pd_w[RX_PD_BUS_WIDTH-1:0] ; 
                data1 = pd_w[(2*RX_PD_BUS_WIDTH)-1:RX_PD_BUS_WIDTH] ;
		local_pix_count = local_pix_count + 1;
    `ifdef RX_8BPP
		if (RX_DT == "RAW8" | RX_DT == "YUV_420_8" | RX_DT == "YUV_420_8_CSPS" | RX_DT == "LEGACY_YUV_420_8" | RX_DT == "YUV_422_8") begin : data8bit_monitor_pix_clk_02
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[7:0];
		            b[1][7:0] = data1[7:0];
                    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 1;

			    if(p_odd_w != 2'h1) begin
                    	      write_to_file("received_data_byte.log", b[1]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
			      actual_byte_count = actual_byte_count + 1;
		    	    end
		    	    local_pix_count = 4'h0;
		          end
		  endcase
	        end
    `elsif RX_10BPP
		if (RX_DT == "RAW10" | RX_DT == "YUV_420_10" | RX_DT == "YUV_420_10_CSPS" | RX_DT == "YUV_422_10" ) begin : data10bit_monitor_pix_clk_02
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[9:2];
		            b[4][1:0] = data[1:0];
		    	    b[1][7:0] = data1[9:2];
		    	    b[4][3:2] = data1[1:0];
		          end
		    4'h2: begin 
		            b[2][7:0] = data[9:2];
		    	    b[4][5:4] = data[1:0];
		    	    b[3][7:0] = data1[9:2];
		    	    b[4][7:6] = data1[1:0];
                    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[3]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[3]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[3]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[4]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[4]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[4]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 5;
		          end
		    
		  endcase
		end
    `elsif RX_12BPP
		if (RX_DT == "RAW12") begin : data12bit_monitor_pix_clk_02
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[11:4];
		            b[2][3:0] = data[3:0];
		    	    b[1][7:0] = data1[11:4];
		    	    b[2][7:4] = data1[3:0];
		    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 3;
		          end
		  endcase
		end
     `elsif RX_24BPP
		if (RX_DT == "RGB888") begin : data24bit_csi2_monitor_pix_clk_02
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[7:0];
		            b[1][7:0] = data[15:8];
		            b[2][7:0] = data[23:16];
		            b[3][7:0] = data1[7:0];
		            b[4][7:0] = data1[15:8];
		            b[5][7:0] = data1[23:16];
		    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 3;
			    if(p_odd_w != 2'h1) begin
		    	      write_to_file("received_data_byte.log", b[3]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[3]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[3]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
		    	      write_to_file("received_data_byte.log", b[4]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[4]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[4]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
		    	      write_to_file("received_data_byte.log", b[5]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[5]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[5]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
			      actual_byte_count = actual_byte_count + 3;
		    	    end
		    	    local_pix_count = 4'h0;
		          end
		  endcase
		end
     `endif

                //write_to_file("received_data.log", data);
                //write_to_file("received_data.log", data1);
                actual_pixel_count = actual_pixel_count + 2;
            end
            
            else if(lv_i ==1 && fv_i==1 && `RX_PEL_PER_CLK ==4) begin
                data = pd_w[    RX_PD_BUS_WIDTH -1:   	     0] ;
                data1 = pd_w[(2*RX_PD_BUS_WIDTH) -1:  RX_PD_BUS_WIDTH] ;
                data2 = pd_w[(3*RX_PD_BUS_WIDTH) -1:(2*RX_PD_BUS_WIDTH)] ;
                data3 = pd_w[(4*RX_PD_BUS_WIDTH) -1:(3*RX_PD_BUS_WIDTH)] ;
		local_pix_count = local_pix_count + 1;
     `ifdef RX_8BPP
		if (RX_DT == "RAW8" | RX_DT == "YUV_420_8" | RX_DT == "YUV_420_8_CSPS" | RX_DT == "LEGACY_YUV_420_8" | RX_DT == "YUV_422_8") begin : data8bit_monitor_pix_clk_04
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[7:0];
		            b[1][7:0] = data1[7:0];
		            b[2][7:0] = data2[7:0];
		            b[3][7:0] = data3[7:0];
			    if (p_odd_w != 2'h0) begin
			      if(p_odd_w >= 2'h1 ) begin // First Pixel Only is valid
                    	        write_to_file("received_data_byte.log", b[0]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
			        actual_byte_count = actual_byte_count + 1;
			      end
			      if(p_odd_w >= 2'h2 ) begin // Second & First Pixel are valid
                    	        write_to_file("received_data_byte.log", b[1]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
			        actual_byte_count = actual_byte_count + 1;
			      end
			      if(p_odd_w >= 2'h3) begin // Third,Second & First Pixel are valid
                    	        write_to_file("received_data_byte.log", b[2]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
			        actual_byte_count = actual_byte_count + 1;
		    	      end
		    	    end
			    else begin
                    	      write_to_file("received_data_byte.log", b[0]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
                    	      write_to_file("received_data_byte.log", b[1]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
                    	      write_to_file("received_data_byte.log", b[2]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
                    	      write_to_file("received_data_byte.log", b[3]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[3]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[3]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
			      actual_byte_count = actual_byte_count + 4;
		            end
		    	    local_pix_count = 4'h0;
		    end
		  endcase
	        end
     `elsif RX_10BPP
		if (RX_DT == "RAW10" | RX_DT == "YUV_420_10" | RX_DT == "YUV_420_10_CSPS" | RX_DT == "YUV_422_10") begin : data10bit_monitor_pix_clk_04
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[9:2];
		            b[4][1:0] = data[1:0];
		    	    b[1][7:0] = data1[9:2];
		    	    b[4][3:2] = data1[1:0];
		            b[2][7:0] = data2[9:2];
		    	    b[4][5:4] = data2[1:0];
		    	    b[3][7:0] = data3[9:2];
		    	    b[4][7:6] = data3[1:0];
                    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[3]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[3]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[3]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[4]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[4]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[4]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 5;
		          end
		    		  endcase
		end
    `elsif RX_12BPP
		if (RX_DT == "RAW12") begin : data12bit_monitor_pix_clk_04
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0] = data[11:4];
		            b[2][3:0] = data[3:0];
		    	    b[1][7:0] = data1[11:4];
		    	    b[2][7:4] = data1[3:0];
		            b[3][7:0] = data2[11:4];
		            b[5][3:0] = data2[3:0];
		    	    b[4][7:0] = data3[11:4];
		    	    b[5][7:4] = data3[3:0];
		    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 3;
			    if(p_odd_w != 2'h2) begin // Second & First Pixel are valid
		    	      write_to_file("received_data_byte.log", b[3]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[3]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[3]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
		    	      write_to_file("received_data_byte.log", b[4]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[4]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[4]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
		    	      write_to_file("received_data_byte.log", b[5]);
		              if( mipi_rx.exp_video_data[bytes_per_frame] == b[5]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[5]);
    			        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			        $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
			      actual_byte_count = actual_byte_count + 3;
		    	    end
		    	    local_pix_count = 4'h0;
		          end
		  endcase
		end
    `elsif RX_24BPP
		if (RX_DT == "RGB888") begin : data24bit_csi2_monitor_pix_clk_04
		  case (local_pix_count) 
		    4'h1: begin 
		            b[0][7:0]  = data[7:0];
		            b[1][7:0]  = data[15:8];
		            b[2][7:0]  = data[23:16];
		            b[3][7:0]  = data1[7:0];
		            b[4][7:0]  = data1[15:8];
		            b[5][7:0]  = data1[23:16];
		            b[6][7:0]  = data2[7:0];
		            b[7][7:0]  = data2[15:8];
		            b[8][7:0]  = data2[23:16];
		            b[9][7:0]  = data3[7:0];
		            b[10][7:0] = data3[15:8];
		            b[11][7:0] = data3[23:16];
			    if (p_odd_w != 2'h0) begin
			      if(p_odd_w >= 2'h1 ) begin // First Pixel Only is valid
		    	        write_to_file("received_data_byte.log", b[0]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[1]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[2]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 3;
			      end
			      if(p_odd_w >= 2'h2 ) begin // Second & First Pixel are valid
		    	        write_to_file("received_data_byte.log", b[3]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[3]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[3]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[4]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[4]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[4]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[5]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[5]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[5]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 3;
			      end
			      if(p_odd_w >= 2'h3) begin // Third,Second & First Pixel are valid
		    	        write_to_file("received_data_byte.log", b[6]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[6]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[6]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[7]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[7]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[7]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[8]);
		                if( mipi_rx.exp_video_data[bytes_per_frame] == b[8]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[8]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 3;
		    	      end
		    	    end
			    else begin
		    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[3]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[3]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[3]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[4]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[4]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[4]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[5]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[5]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[5]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[6]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[6]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[6]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[7]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[7]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[7]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[8]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[8]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[8]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[9]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[9]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[9]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[10]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[10]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[10]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[11]);
		            if( mipi_rx.exp_video_data[bytes_per_frame] == b[11]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.exp_video_data[bytes_per_frame],b[11]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 12;
			    end
		    	    local_pix_count = 4'h0;
		          end
		  endcase
		end
    `endif
                           actual_pixel_count = actual_pixel_count + 4;
                         end
        end
    end
    endtask
//    task write_to_file ( input [1024*4-1:0]str_in,input [(RX_PD_BUS_WIDTH*NUM_TX_CH)-1:0]data);
task write_to_file ( input [1024*4-1:0]str_in, input [7:0] data);
     integer filedesc;
 begin
    if(enable_write_log == 1) begin
     filedesc = $fopen(str_in,"a");
     $fwrite(filedesc, "%h\n", data);
     $fclose(filedesc);
    end
 end
endtask
task write_to_file_6_bits ( input [1024*4-1:0]str_in, input [5:0] data);
     integer filedesc;
 begin
    if(enable_write_log == 1) begin
     filedesc = $fopen(str_in,"a");
     $fwrite(filedesc, "%h\n", data);
     $fclose(filedesc);
    end
 end
endtask

task write_vsync_hsync ( input [1024*4-1:0]str_in,input vsync_i);
     integer filedesc;
   begin
   if(enable_write_log == 1) begin
     filedesc = $fopen(str_in,"a");
     if(vsync_i == 1) begin
        $fwrite(filedesc, "VSYNC\n");
     end
     else begin
        $fwrite(filedesc, "HSYNC\n");
     end
     $fclose(filedesc);
    end
   end
endtask


