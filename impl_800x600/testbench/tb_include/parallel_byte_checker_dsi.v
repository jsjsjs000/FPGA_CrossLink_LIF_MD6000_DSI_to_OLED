// =========================================================================
// Filename: byte_monitor.v
// Copyright(c) 2017 Lattice Semiconductor Corporation. All rights reserved.
// =========================================================================

reg vsync_w_d, hsync_w_d, de_w_d;
reg tx0_de_rdy;
reg [3:0] frm_cnt;
reg [10:0] active_line_cnt;
integer bytes_per_frame ;




always @(posedge clk_pixel_w or negedge resetn) begin
	if (~resetn) begin
		vsync_w_d <= (SYNC_POL == "POSITIVE") ? 0 : 1;
		hsync_w_d <= (SYNC_POL == "POSITIVE") ? 0 : 1;
		de_w_d <= (DE_POL == "POSITIVE") ? 0 : 1;
	end
	else begin
		vsync_w_d <= vsync_w;
		hsync_w_d <= hsync_w;
		de_w_d <= de_w;
	end
end

always @(posedge clk_pixel_w or negedge resetn) begin
	if (~resetn) begin
		frm_cnt <= 0;
		bytes_per_frame <= 0;
	end
	else if (vsync_w_d^vsync_w) begin
		if (vsync_w == (SYNC_POL == "POSITIVE")) begin
			$display ("##### VSYNC assertion #####");
			frm_cnt <= frm_cnt + 1;
			bytes_per_frame <= 0;
		end
		else begin
			$display ("##### VSYNC de-assertion #####");
		end
	end
end
always @(posedge clk_pixel_w) begin
	if (hsync_w_d^hsync_w) begin
		if (hsync_w == (SYNC_POL == "POSITIVE")) begin
			$display ("##### HSYNC assertion #####");
		end
		else begin
			$display ("##### HSYNC de-assertion #####");
		end
	end
end
always @(posedge clk_pixel_w) begin
	if (((vsync_w == (SYNC_POL == "POSITIVE")) || (hsync_w == (SYNC_POL == "POSITIVE")))
			&& (de_w == (DE_POL == "POSITIVE"))) begin
		$display ("Control Signal Error, DE is asserted while VSYNC or HSYNC is active!!!");
    		$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
		#500_000;
		$stop;
	end
end
always @(posedge clk_pixel_w or negedge resetn) begin
	if (~resetn) begin
		active_line_cnt <= 0;
	end
	else if (vsync_w == (SYNC_POL == "POSITIVE")) begin
		active_line_cnt <= 0;
	end
	else if (hsync_w == (SYNC_POL == "POSITIVE")) begin
	end
	else begin
		if (de_w_d^de_w) begin
			if (de_w == (DE_POL == "POSITIVE")) begin
					$display ("##### DE assertion #####");
			end
			else begin
				$display ("##### DE de-assertion #####");
				active_line_cnt <= active_line_cnt + 1;
			end
		end
	end
end


reg [3:0] local_pix_count = 0;
reg [7:0] b[0:100];
reg [RX_PD_BUS_WIDTH-1:0] data,data1,data2,data3;

generate
    if (RX_TYPE == "DSI") 
        initial dsi_data.detect_pixel_data_in_dsi;
    else
        initial csi_data.detect_pixel_data_in_csi2;
endgenerate

    always @(posedge vsync_i) begin
      write_vsync_hsync("sync_data_in.log",1);
    end
    
    always @(posedge hsync_i) begin
      #1;
      write_vsync_hsync("sync_data_in.log",0);
    end

//`ifdef RX_TYPE_DSI   
integer actual_pixel_count = 0;
integer actual_byte_count = 0;
integer b_num = 0;
generate 
if (RX_TYPE == "DSI") begin: dsi_data
    task detect_pixel_data_in_dsi;
    begin
     
        forever begin
         @(posedge clk_pixel_w);
            if(de_i ==1 && `RX_PEL_PER_CLK ==1) begin
                data = pd_w[RX_PD_BUS_WIDTH-1:0] ; 
		local_pix_count = local_pix_count + 1;
        `ifdef RX_RGB666
		if (RX_DT == "RGB666") begin : rgb666_monitor_pix_clk_01
		  case (local_pix_count) 
		    4'h1: begin 
		            b[1][7:4] = data[3:0];
		            b[2][1:0] = data[5:4];
		   	    b[0][7:6] = data[7:6];
			    b[1][3:0] = data[11:8];
			    b[0][5:0] = data[17:12];
		          end
		    4'h2: begin 
			    b[3][7:6]= data[1:0];  
			    b[4][3:0]= data[5:2];  
			    b[3][5:0]= data[11:6];  
			    b[2][7:2]= data[17:12]; 
		          end      
		    4'h3: begin 
			    b[6][5:0]= data[5:0];  
			    b[5][7:2]= data[11:6];  
			    b[4][7:4]= data[15:12];  
			    b[5][1:0]= data[17:16]; 
		          end
		    4'h4: begin 
			    b[8][7:2]= data[5:0];
			    b[7][7:4]= data[9:6];
			    b[8][1:0]= data[11:10];
			    b[6][7:6]= data[13:12];
			    b[7][3:0]= data[17:14];
                    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[3]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[3]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[3]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[4]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[4]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[4]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[5]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[5]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[5]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[6]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[6]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[6]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[7]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[7]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[7]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[8]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[8]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[8]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 9;
		          end
		  endcase
		end
        `elsif RX_RGB888
		if (RX_DT == "RGB888") begin : rgb888_dsi_monitor_pix_clk_01
		  case (local_pix_count) 
		    4'h1: begin 
		            b[2][7:0] = data[7:0];
		            b[1][7:0] = data[15:8];
		            b[0][7:0] = data[23:16];
		    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 3;
		          end
		  endcase
		end
        `elsif RX_RGB666_LOOSE
		if (RX_DT == "RGB666_LP") begin : rgb666_lp_dsi_monitor_pix_clk_01
			case (local_pix_count) 
				4'h1: begin 
					b[2][5:0] = data[5:0];
					b[1][5:0] = data[11:6];
					b[0][5:0] = data[17:12];
					
					for (b_num=0; b_num < 3; b_num = b_num+1) begin
						write_to_file_6_bits("received_data_byte.log", b[b_num][5:0]);
						
						if(mipi_rx.av_frame_data[bytes_per_frame][5:0] == b[b_num][5:0]) begin 
							//$display("DATA MATCHED ");
						end
						else begin
							$display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame][5:0],b[0][5:0]);
							$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
							$stop;
						end
						bytes_per_frame= bytes_per_frame + 1'b1;
					end
					local_pix_count = 4'h0;
					actual_byte_count = actual_byte_count + 3;
				end
			endcase
		end
    `endif        //write_to_file("received_data.log", data);
                actual_pixel_count = actual_pixel_count + 1;
            end
            else if(de_i ==1 && `RX_PEL_PER_CLK==2) begin
                data = pd_w[RX_PD_BUS_WIDTH-1:0] ; 
                data1 = pd_w[(2*RX_PD_BUS_WIDTH)-1:RX_PD_BUS_WIDTH] ;
		local_pix_count = local_pix_count + 1;
        `ifdef RX_RGB666
		if (RX_DT == "RGB666") begin : rgb666_monitor_pix_clk_02
		  case (local_pix_count) 
		    4'h1: begin 
		            b[1][7:4] = data[3:0];
		            b[2][1:0] = data[5:4];
		   	    b[0][7:6] = data[7:6];
			    b[1][3:0] = data[11:8];
			    b[0][5:0] = data[17:12];
			    b[3][7:6] = data1[1:0];  
			    b[4][3:0] = data1[5:2];  
			    b[3][5:0] = data1[11:6];  
			    b[2][7:2] = data1[17:12]; 
		          end
		    4'h2: begin 
			    b[6][5:0]= data[5:0];  
			    b[5][7:2]= data[11:6];  
			    b[4][7:4]= data[15:12];  
			    b[5][1:0]= data[17:16]; 
			    b[8][7:2]= data1[5:0];
			    b[7][7:4]= data1[9:6];
			    b[8][1:0]= data1[11:10];
			    b[6][7:6]= data1[13:12];
			    b[7][3:0]= data1[17:14];
                    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[3]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[3]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[3]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[4]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[4]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[4]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[5]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[5]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[5]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[6]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[6]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[6]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[7]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[7]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[7]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[8]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[8]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[8]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 9;
		          end      
		  endcase
		end
		`elsif RX_RGB666_LOOSE
		if (RX_DT == "RGB666_LP") begin : rgb666_lp_dsi_monitor_pix_clk_02
			case (local_pix_count) 
				4'h1: begin 
					b[2][5:0] = data[5:0];
					b[1][5:0] = data[11:6];
					b[0][5:0] = data[17:12];
					b[5][5:0] = data1[5:0];
					b[4][5:0] = data1[11:6];
					b[3][5:0] = data1[17:12];
					
					for (b_num=0; b_num < 3; b_num = b_num+1) begin
						write_to_file_6_bits("received_data_byte.log", b[b_num][5:0]);
						
						if(mipi_rx.av_frame_data[bytes_per_frame][5:0] == b[b_num][5:0]) begin 
							//$display("DATA MATCHED ");
						end
						else begin
							$display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame][5:0],b[0][5:0]);
							$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
							$stop;
						end
						bytes_per_frame= bytes_per_frame + 1'b1;
					end
					
					actual_byte_count = actual_byte_count + 3;
					if(p_odd_w != 2'h1) begin
						for (b_num=3; b_num < 6; b_num = b_num+1) begin
							write_to_file_6_bits("received_data_byte.log", b[b_num][5:0]);
							
							if(mipi_rx.av_frame_data[bytes_per_frame][5:0] == b[b_num][5:0]) begin 
								//$display("DATA MATCHED ");
							end
							else begin
								$display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame][5:0],b[0][5:0]);
								$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
								$stop;
							end
							bytes_per_frame= bytes_per_frame + 1'b1;
						end
					end
					local_pix_count = 4'h0;
					actual_byte_count = actual_byte_count + 3;
				end
			endcase
		end

        `elsif RX_RGB888
		if (RX_DT == "RGB888") begin : rgb888_dsi_monitor_pix_clk_02
		  case (local_pix_count) 
		    4'h1: begin 
		            b[2][7:0] = data[7:0];
		            b[1][7:0] = data[15:8];
		            b[0][7:0] = data[23:16];
		            b[5][7:0] = data1[7:0];
		            b[4][7:0] = data1[15:8];
		            b[3][7:0] = data1[23:16];
		    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 3;
			    if(p_odd_w != 2'h1) begin
		    	      write_to_file("received_data_byte.log", b[3]);
		              if( mipi_rx.av_frame_data[bytes_per_frame] == b[3]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[3]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
		    	      write_to_file("received_data_byte.log", b[4]);
		              if( mipi_rx.av_frame_data[bytes_per_frame] == b[4]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[4]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			      end
			      bytes_per_frame= bytes_per_frame + 1'b1;
		    	      write_to_file("received_data_byte.log", b[5]);
		              if( mipi_rx.av_frame_data[bytes_per_frame] == b[5]) begin 
			        //$display("DATA MATCHED ");
			      end
			      else begin
			        $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[5]);
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
            else if(de_i ==1 && `RX_PEL_PER_CLK==4) begin
                data = pd_w[    RX_PD_BUS_WIDTH -1:   	     0] ;
                data1 = pd_w[(2*RX_PD_BUS_WIDTH)-1:  RX_PD_BUS_WIDTH] ;
                data2 = pd_w[(3*RX_PD_BUS_WIDTH)-1:2*RX_PD_BUS_WIDTH] ;
                data3 = pd_w[(4*RX_PD_BUS_WIDTH)-1:3*RX_PD_BUS_WIDTH] ;
		local_pix_count = local_pix_count + 1;
        `ifdef RX_RGB666
		if (RX_DT == "RGB666") begin : rgb666_monitor_pix_clk_04
		  case (local_pix_count) 
		    4'h1: begin 
		            b[1][7:4] = data[3:0];
		            b[2][1:0] = data[5:4];
		   	    b[0][7:6] = data[7:6];
			    b[1][3:0] = data[11:8];
			    b[0][5:0] = data[17:12];
			    b[3][7:6] = data1[1:0];  
			    b[4][3:0] = data1[5:2];  
			    b[3][5:0] = data1[11:6];  
			    b[2][7:2] = data1[17:12]; 
			    b[6][5:0] = data2[5:0];  
			    b[5][7:2] = data2[11:6];  
			    b[4][7:4] = data2[15:12];  
			    b[5][1:0] = data2[17:16]; 
			    b[8][7:2] = data3[5:0];
			    b[7][7:4] = data3[9:6];
			    b[8][1:0] = data3[11:10];
			    b[6][7:6] = data3[13:12];
			    b[7][3:0] = data3[17:14];
                    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[3]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[3]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[3]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[4]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[4]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[4]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[5]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[5]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[5]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[6]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[6]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[6]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[7]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[7]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[7]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
                    	    write_to_file("received_data_byte.log", b[8]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[8]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[8]);
    			    $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			    $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    local_pix_count = 4'h0;
			    actual_byte_count = actual_byte_count + 9;
		          end      
		  endcase
		end
		
		`elsif RX_RGB666_LOOSE
		if (RX_DT == "RGB666_LP") begin : rgb666_lp_dsi_monitor_pix_clk_04
			case (local_pix_count) 
				4'h1: begin 
					b[2][5:0] 	= data[5:0];
					b[1][5:0] 	= data[11:6];
					b[0][5:0] 	= data[17:12];
					b[5][5:0] 	= data1[5:0];
					b[4][5:0] 	= data1[11:6];
					b[3][5:0] 	= data1[17:12];
					b[8][5:0] 	= data2[5:0];
					b[7][5:0] 	= data2[11:6];
					b[6][5:0] 	= data2[17:12];
					b[11][5:0] 	= data3[5:0];
					b[10][5:0] 	= data3[11:6];
					b[9][5:0] 	= data3[17:12];
					
					for (b_num=0; b_num < 12; b_num = b_num+1) begin

						if (!(	(p_odd_w == 2'd1 & b_num == 3) | 	// only first pixel is valid
								(p_odd_w == 2'd2 & b_num == 6) | 	// first and second pixels are valid
								(p_odd_w == 2'd3 & b_num == 9))) begin  // // first and second and third pixels are valid
						write_to_file_6_bits("received_data_byte.log", b[b_num][5:0]);
						
							if(mipi_rx.av_frame_data[bytes_per_frame][5:0] == b[b_num][5:0]) begin 
								//$display("DATA MATCHED ");
							end
							else begin
								$display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame][5:0],b[0][5:0]);
								$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
								$stop;
							end
							bytes_per_frame= bytes_per_frame + 1'b1;
							actual_byte_count = actual_byte_count + 1;
						end
					end
					
					local_pix_count = 4'h0;
				end
			endcase
		end
        `elsif RX_RGB888
		if (RX_DT == "RGB888") begin : rgb888_dsi_monitor_pix_clk_04
		  case (local_pix_count) 
		    4'h1: begin 
		            b[2][7:0]  = data[7:0];
		            b[1][7:0]  = data[15:8];
		            b[0][7:0]  = data[23:16];
		            b[5][7:0]  = data1[7:0];
		            b[4][7:0]  = data1[15:8];
		            b[3][7:0]  = data1[23:16];
		            b[8][7:0]  = data2[7:0];
		            b[7][7:0]  = data2[15:8];
		            b[6][7:0]  = data2[23:16];
		            b[11][7:0]  = data3[7:0];
		            b[10][7:0] = data3[15:8];
		            b[9][7:0] = data3[23:16];
			    if (p_odd_w != 2'h0) begin
			      if(p_odd_w >= 2'h1 ) begin // First Pixel Only is valid
		    	        write_to_file("received_data_byte.log", b[0]);
		                if( mipi_rx.av_frame_data[bytes_per_frame] == b[0]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[0]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[1]);
		                if( mipi_rx.av_frame_data[bytes_per_frame] == b[1]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[1]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[2]);
		                if( mipi_rx.av_frame_data[bytes_per_frame] == b[2]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[2]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 3;
			      end
			      if(p_odd_w >= 2'h2 ) begin // Second & First Pixel are valid
		    	        write_to_file("received_data_byte.log", b[3]);
		                if( mipi_rx.av_frame_data[bytes_per_frame] == b[3]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[3]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[4]);
		                if( mipi_rx.av_frame_data[bytes_per_frame] == b[4]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[4]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[5]);
		                if( mipi_rx.av_frame_data[bytes_per_frame] == b[5]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[5]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 3;
			      end
			      if(p_odd_w >= 2'h3) begin // Third,Second & First Pixel are valid
		    	        write_to_file("received_data_byte.log", b[6]);
		                if( mipi_rx.av_frame_data[bytes_per_frame] == b[6]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[6]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[7]);
		                if( mipi_rx.av_frame_data[bytes_per_frame] == b[7]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[7]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
		    	        write_to_file("received_data_byte.log", b[8]);
		                if( mipi_rx.av_frame_data[bytes_per_frame] == b[8]) begin 
			          //$display("DATA MATCHED ");
			        end
			        else begin
			          $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[8]);
    			          $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			          $stop;
			        end
			        bytes_per_frame= bytes_per_frame + 1'b1;
			    actual_byte_count = actual_byte_count + 3;
		    	      end
		    	    end
			    else begin
		    	    write_to_file("received_data_byte.log", b[0]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[0]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[0]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[1]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[1]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[1]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[2]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[2]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[2]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[3]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[3]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[3]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[4]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[4]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[4]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[5]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[5]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[5]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[6]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[6]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[6]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[7]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[7]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[7]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[8]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[8]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[8]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[9]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[9]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[9]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[10]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[10]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[10]);
    			      $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			      $stop;
			    end
			    bytes_per_frame= bytes_per_frame + 1'b1;
		    	    write_to_file("received_data_byte.log", b[11]);
		            if( mipi_rx.av_frame_data[bytes_per_frame] == b[11]) begin 
			      //$display("DATA MATCHED ");
			    end
			    else begin
			      $display($time," Frame-[%h] Line-[%h] DATA MIS-MATCH Occured Expected=[%h] Received=[%h]",frm_cnt,active_line_cnt,mipi_rx.av_frame_data[bytes_per_frame],b[11]);
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
end
endgenerate

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


