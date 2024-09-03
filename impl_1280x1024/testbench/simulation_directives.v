`define SIM
//----Number of Frames----
`define NUM_FRAMES 1

//----LP Blanking Mode----
`define LP_BLANKING 		// DSI Mode Only

//----Non Burst Sync Events---- 
//`define NON_BURST_SYNC_EVENTS // DSI Mode Only

//----Number of Lines----
`define NUM_LINES 10

//----Number of Pixels----
`define NUM_PIXELS 800

//----DPHY Clock----
//`define DPHY_CLK 12500 // 160 Mbps
//`define DPHY_CLK 8333  // 240 Mbps
//`define DPHY_CLK 8000  // 250 Mbps
//`define DPHY_CLK 6666  // 300 Mbps
//`define DPHY_CLK 6250  // 320 Mbps
//`define DPHY_CLK 5555	 // 360 Mbps
`define DPHY_CLK 5387	// 371.25 Mbps
//`define DPHY_CLK 5000	 // 400 Mbps
//`define DPHY_CLK 4629	// 432 Mbps
//`define DPHY_CLK 4445	 // 450 Mbps
//`define DPHY_CLK 4000  // 500 Mbps
//`define DPHY_CLK 2666  // 750 Mbps
//`define DPHY_CLK 2500  // 800 Mbps
//`define DPHY_CLK 2222	 // 900 Mbps
//`define DPHY_CLK 2083	 // 960 Mbps
//`define DPHY_CLK 1904	 // 1050 Mbps
//`define DPHY_CLK 1666	 // 1200 Mbps
//`define DPHY_CLK 1683	 // 1200 Mbps // c05
//`define DPHY_CLK 1481	 // 1350 Mbps
//`define DPHY_CLK 1333  // 1500 Mbps
//`define DPHY_CLK 1250  // 1600 Mbps
//`define DPHY_CLK 1142  // 1750 Mbps
//`define DPHY_CLK 1111	 // 1800 Mbps
//`define DPHY_CLK 1000	 // 2000 Mbps
//`define DPHY_CLK 952	 // 2100 Mbps
//`define DPHY_CLK 888	 // 2250 Mbps
//`define DPHY_CLK 833	 // 2400 Mbps

//----REF_CLK frequency from the board
`define REF_CLK 37070	// 27 MHz

//----VSYNC/HSYNC Width Checker----
`ifdef NON_BURST_SYNC_EVENTS
`define VSYNC_HSYNC_CHECK
`define VSYNC_WIDTH 5
`define HSYNC_WIDTH 8
`endif
//
//----Debug Mode On----
`define DPHY_DEBUG_ON 
