//----DPHY Type----
`define RX_TYPE_DSI
//`define RX_TYPE_CSI2

//----Number of RX Lanes----
//`define NUM_RX_LANE_1	// 1, 2, or 4
//`define NUM_RX_LANE_2	// 1, 2, or 4
`define NUM_RX_LANE_4	// 1, 2, or 4

`ifdef NUM_RX_LANE_1
  `define NUM_RX_LANE 1
`elsif NUM_RX_LANE_2
  `define NUM_RX_LANE 2
`elsif NUM_RX_LANE_4
  `define NUM_RX_LANE 4
`endif

//----RX Gear----
`define RX_GEAR_8
//`define RX_GEAR_16

`ifdef RX_GEAR_8
  `define RX_GEAR 8
`elsif RX_GEAR_16
  `define RX_GEAR 16
`endif

//----HSYNC & VSYNC & DE Polarity----
//`define SYNC_POLARITY_NEG	// POS or NEG
`define SYNC_POLARITY_POS	// POS or NEG

//---- Clock Mode----
//`define RX_CLK_MODE_HS_LP     //Non-Continuous
`define RX_CLK_MODE_HS_ONLY //Continuous

//----DPHY IP----
`define RX_DPHY_HARD // Only enable when HARD DPHY is used

//----Video Data Type----
//`define RX_RGB666
//`define RX_RGB666_LOOSE
`define RX_RGB888
//`define RX_RAW8
//`define RX_RAW10
//`define RX_RAW12
//`define RX_YUV_420_8
//`define RX_YUV_420_8_CSPS
//`define RX_LEGACY_YUV_420_8
//`define RX_YUV_420_10
//`define RX_YUV_420_10_CSPS
//`define RX_YUV_422_8
//`define RX_YUV_422_10

//----Number of Pixel Per Clock-----
`define RX_PEL_PER_CLK 1	
//`define RX_PEL_PER_CLK 2	
//`define RX_PEL_PER_CLK 4	

//----Data type declaration----------------------
//----Do not modify unless to extend features----
`ifdef RX_TYPE_DSI
	`ifdef RX_RGB888
		`define REF_DT 6'h3E
		`define BITS_PER_PIX 24
	`elsif RX_RGB666
		`define REF_DT 6'h1E
		`define BITS_PER_PIX 18
	`elsif RX_RGB666_LOOSE
		`define REF_DT 6'h2E
		`define BITS_PER_PIX 18
	`endif
`elsif RX_TYPE_CSI2
	`ifdef RX_RGB888
		`define REF_DT 6'h24
		`define BITS_PER_PIX 24
	`elsif RX_RAW8
		`define REF_DT 6'h2A
		`define BITS_PER_PIX 8
	`elsif RX_RAW10
		`define REF_DT 6'h2B
		`define BITS_PER_PIX 10
	`elsif RX_RAW12
		`define REF_DT 6'h2C
		`define BITS_PER_PIX 12
	`elsif RX_YUV_420_8
		`define REF_DT 6'h18
		`define BITS_PER_PIX 8
	`elsif RX_YUV_420_8_CSPS
		`define REF_DT 6'h1C
		`define BITS_PER_PIX 8
	`elsif RX_LEGACY_YUV_420_8
		`define REF_DT 6'h1A
		`define BITS_PER_PIX 8
	`elsif RX_YUV_420_10
		`define REF_DT 6'h19
		`define BITS_PER_PIX 10
	`elsif RX_YUV_420_10_CSPS
		`define REF_DT 6'h1D
		`define BITS_PER_PIX 10
	`elsif RX_YUV_422_8
		`define REF_DT 6'h1E
		`define BITS_PER_PIX 8
	`elsif RX_YUV_422_10
		`define REF_DT 6'h1F
		`define BITS_PER_PIX 10
	`endif
`endif

`define RX_PD_BUS_WIDTH `BITS_PER_PIX*`RX_PEL_PER_CLK

//`define DPHY_DEBUG_ON 
