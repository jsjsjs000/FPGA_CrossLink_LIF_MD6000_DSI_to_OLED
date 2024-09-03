
`timescale 1 ps / 1 ps


module vsync_hsync_checker #(
	parameter RX_DT = "RGB666",
	parameter RX_DPHY = "SOFT",
	parameter RX_CLK_MODE = "HS_ONLY",
	parameter NUM_RX_LANE = 1,
	parameter HSYNC_WIDTH = 5,
	parameter VSYNC_WIDTH = 4,
	parameter SIM_STOP = 1,
	parameter RX_GEAR = 8
)
(
	input clk_pixel_i,
	input hsync_i,
	input vsync_i
);

wire hsync_status;
wire vsync_status;
//wire [3:0] vsync_width;
//wire [3:0] hsync_width;
reg [3:0] hsync_width_cntr = 4'h0;
wire [3:0] hsync_width_cntr_c ;
reg [3:0] vsync_width_cntr = 4'h0;
wire [3:0] vsync_width_cntr_c ;

//generate 
//	if ((RX_DT == "RGB666") & (RX_DPHY == "SOFT" ) & (RX_CLK_MODE == "HS_ONLY") & (NUM_RX_LANE == 1) & (RX_GEAR == 8)) begin // config_2
//	assign	vsync_width = 3;
//	assign	hsync_width = 4;
//	end
//	else if ((RX_DT == "RGB666") & (RX_DPHY == "HARD" ) & (RX_CLK_MODE == "HS_LP") & (NUM_RX_LANE == 1) & (RX_GEAR ==16)) begin // config_4
//	assign	vsync_width = 4;
//	assign	hsync_width = 5;
//	end
//	else if ((RX_DT == "RGB666") & (RX_DPHY == "HARD" ) & (RX_CLK_MODE == "HS_ONLY") & (NUM_RX_LANE == 2) & (RX_GEAR == 8)) begin // config_6
//	assign	vsync_width = 5;
//	assign	hsync_width = 6;
//	end
//	else if ((RX_DT == "RGB888") & (RX_DPHY == "HARD" ) & (RX_CLK_MODE == "HS_ONLY") & (NUM_RX_LANE == 2) & (RX_GEAR == 16)) begin // config_8
//	assign	vsync_width = 3;
//	assign	hsync_width = 7;
//	end
//	else if ((RX_DT == "RGB666") & (RX_DPHY == "HARD" ) & (RX_CLK_MODE == "HS_LP") & (NUM_RX_LANE == 2) & (RX_GEAR ==16)) begin //config_11
//	assign	vsync_width = 4;
//	assign	hsync_width = 8;
//	end
//	else if ((RX_DT == "RGB888") & (RX_DPHY == "HARD" ) & (RX_CLK_MODE == "HS_LP") & (NUM_RX_LANE == 4) & (RX_GEAR == 8)) begin //config_13
//	assign	vsync_width = 5;
//	assign	hsync_width = 4;
//	end
//	else if ((RX_DT == "RGB666") & (RX_DPHY == "HARD" ) & (RX_CLK_MODE == "HS_ONLY") & (NUM_RX_LANE == 4) & (RX_GEAR == 8)) begin //config_16
//	assign	vsync_width = 3;
//	assign	hsync_width = 5;
//	end
//	else if ((RX_DT == "RGB888") & (RX_DPHY == "HARD" ) & (RX_CLK_MODE == "HS_ONLY") & (NUM_RX_LANE == 4) & (RX_GEAR == 16)) begin //config_20,21,22,23
//	assign	vsync_width = 5;
//	assign	hsync_width = 7;
//	end
//	else if ((RX_DT == "RGB666") & (RX_DPHY == "HARD" ) & (RX_CLK_MODE == "HS_ONLY") & (NUM_RX_LANE == 4) & (RX_GEAR == 16)) begin // config_24
//	assign	vsync_width = 3;
//	assign	hsync_width = 8;
//	end
//
//endgenerate


always @(posedge clk_pixel_i) begin
	hsync_width_cntr <= hsync_width_cntr_c;
	vsync_width_cntr <= vsync_width_cntr_c;
end


assign hsync_width_cntr_c = hsync_i ? (hsync_width_cntr + 1'b1) : 1'b0 ;

assign hsync_status = ((~(|hsync_width_cntr_c)) & (|hsync_width_cntr)) ? (hsync_width_cntr == HSYNC_WIDTH) : 1'b1 ;

assign vsync_width_cntr_c = vsync_i ? (vsync_width_cntr + (hsync_status & (hsync_width_cntr == HSYNC_WIDTH))) : 1'b0;

assign vsync_status = ((~(|vsync_width_cntr_c)) & (|vsync_width_cntr)) ? (vsync_width_cntr == VSYNC_WIDTH) : 1'b1 ;

initial begin
	forever begin
         @(posedge clk_pixel_i);
		if (!vsync_status) begin
			$display("VSYNC WIDTH not matching with pre-defined value");
			if (SIM_STOP == 1) begin
			$display("-----------------------------------------------------");
			$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			$display("-----------------------------------------------------");
			#500_000;
			$finish;
			end
		end 
		if (!hsync_status) begin
			$display("HSYNC WIDTH not matching with pre-defined value");
			if (SIM_STOP == 1) begin
			$display("-----------------------------------------------------");
			$display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
			$display("-----------------------------------------------------");
			#500_000;
			$finish;
			end
		end 
		//if (hsync_width_cntr == hsync_width) begin
		//	$display("-----------------------------------------------------");
		//	$display("-----------------------------------------------------");
		//	$display("	HSYNC WIDTH matched with pre-defined value     ");
		//	$display("-----------------------------------------------------");
		//	$display("-----------------------------------------------------");
		//end
		//if (vsync_width_cntr == vsync_width) begin
		//	$display("-----------------------------------------------------");
		//	$display("-----------------------------------------------------");
		//	$display("	VSYNC WIDTH matched with pre-defined value     ");
		//	$display("-----------------------------------------------------");
		//	$display("-----------------------------------------------------");
		//end
	end
end
endmodule
