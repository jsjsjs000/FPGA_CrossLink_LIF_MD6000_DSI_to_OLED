//##################################################################################################################
// File Name : Testbench parameter and simulation file
// Purpose   : When user wants to override default TB parameters like number of bytes, lines, frames, etc.
//             
// Type      : This is a verilog file
// Usage     : This file is read via Aldec simulator or any verilog simulator.
//##################################################################################################################

//##################################################################################################################
// Simulation steps:
// 1. Create new project using Lattice Diamond for Windows
// 2. Modify the testbench parameters if needed. Location: \<project_dir>\<core_instance_name>\<core_name>_eval\testbench\tb_setup_params.v
// 3. Open Active-HDL Lattice Edition GUI tool
// 4. Click Tools -> Execute macro, then select the do file (*_run.do)
// 5. Wait for simulation to finish
// 
//##################################################################################################################

//##################################################################################################################
// Testbench Parameters
// Modify/uncomment the `define according to your preference
//##################################################################################################################

// NUM_FRAMES - Used to set the number of video frames
 `define NUM_FRAMES 1

// NUM_LINES - Used to set the number of lines per frame
 `define NUM_LINES 6 

// VIRTUAL_CHANNEL - Used to set the virtual channel number
 `define VIRTUAL_CHANNEL 2'h0

// DPHY_DEBUG_ON - Used to enable or disable debug messages
//                 0 - debug messages disabled (default if not defined)
//                 1 - debug messages enabled
 `define DPHY_DEBUG_ON 0 

// DPHY_CLK - Used to override the dphy clock period. 
//            By default, the testbench automatically calculates the dphy clock based from
//            the BYTECLK_MHZ and RX_GEAR design parameters
// `define DPHY_CLK 2222

// REF_CLK - Used to override the reference clock (clk_byte_fr_i) period for HS_LP clock mode. 
//           By default, the testbench automatically calculates the period for clk_byte_fr_i based from
//           the BYTECLK_MHZ design parameter
// `define REF_CLK 4444

// FRAME_LPM_DELAY - Used to set the low power mode delay between frames (in ps)
// `define FRAME_LPM_DELAY 5000000

// INIT_DELAY - Used to set the delay before data is transmitted to the design
 `define INIT_DELAY 5000000

// DPHY_LPX - Used to set T-LPX timing timing (in ps)
 `define DPHY_LPX 100000

// DPHY_CLK_PREPARE - Used to set T-CLK-PREPARE timing (in ps)
 `define DPHY_CLK_PREPARE 38000

// DPHY_CLK_ZERO - Used to set T-CLK-ZERO timing (in ps) 
 `define DPHY_CLK_ZERO 262000

// DPHY_CLK_PRE - Used to set T-CLK-PRE timing (in ps) 
// `define DPHY_CLK_PRE 150000

// DPHY_CLK_POST - Used to set T-CLK-POST timing (in ps)
// `define DPHY_CLK_POST 385000

// DPHY_CLK_TRAIL - Used to set T-CLK-TRAIL timing (in ps)
 `define DPHY_CLK_TRAIL 60000

// DPHY_HS_PREPARE - Used to set T-HS-PREPARE timing (in ps)
// `define DPHY_HS_PREPARE 65000

// DPHY_HS_ZERO - Used to set T-HS-ZERO timing (in ps)
// `define DPHY_HS_ZERO 300000

// DPHY_HS_TRAIL - Used to set T-HS-TRAIL timing (in ps)
// `define DPHY_HS_TRAIL 100000

// DPHY_INIT - Used to set the T-INIT timing (in ps)
// `define DPHY_INIT 100000000

//##################################################################################################################
// DSI specific Testbench Parameters below
// Modify/uncomment the `define according to your preference
//##################################################################################################################

// LP_BLANKING - Used to drive low-power blanking. If not defined, the testbench drives HS blanking
// `define LP_BLANKING

// DSI video mode types can be set by defining one of the directives (NON_BURST_SYNC_PULSE, NON_BURST_SYNC_EVENTS, BURST_MODE).
// If not defined, default is NON_BURST_SYNC_PULSE
// `define NON_BURST_SYNC_PULSE
// `define NON_BURST_SYNC_EVENTS
// `define BURST_MODE

/// Null packet
`define NULL_PACKET 0

// DSI data type can be set by defining one of the directives (RGB888, RGB666, RGB666_LOOSE)
// CSI-2 data type can be set by defining one of the directives (RAW8, RAW10, RAW12, YUV420_10, YUV420_10_CSPS, YUV420_8, YUV420_8_CSPS, LEGACY_YUV420_8, YUV422_10, YUV422_8, RGB888)
`define TEST_DATA_TYPE "RGB888"

/// SoT Driving edge positive or negative
`define SOT_DRIVE_EDGE "POS"

// DSI_VACT_PAYLOAD - Number of bytes of active pixels per line
 `define DSI_VACT_PAYLOAD 16'h1680

// DSI_HSA_PAYLOAD - Number of bytes of Horizontal Sync Active Payload (used for Non-burst sync pulse)
 `define DSI_HSA_PAYLOAD 16'h007A

// DSI_BLLP_PAYLOAD - Number of bytes of BLLP Payload (used for HS data blanking)
 `define DSI_BLLP_PAYLOAD 16'h193A

// DSI_HBP_PAYLOAD - Number of bytes of Horizontal Back Porch Payload (used for HS data blanking, and in LP blanking for Non-burst sync pulse mode) 
 `define DSI_HBP_PAYLOAD 16'h01AE

// DSI_HFP_PAYLOAD - Number of bytes of Horizontal Front Porch Payload (used for HS data blanking, and in LP blanking for Non-burst sync pulse mode)
 `define DSI_HFP_PAYLOAD 16'h0100

// DSI_LPS_BLLP_DURATION - Used to set the duration (in ps) for BLLP low-power state (used for LP blanking)
 `define DSI_LPS_BLLP_DURATION 2470000

// DSI_LPS_HBP_DURATION - Used to set the duration (in ps) for Horizontal Back Porch low-power state (used for LP blanking in Non-burst sync events and Burst mode)
 `define DSI_LPS_HBP_DURATION 800000

// DSI_LPS_HFP_DURATION - Used to set the duration (in ps) for Horizontal Front Porch low-power state (used for LP blanking in Non-burst sync events and Burst mode)
 `define DSI_LPS_HFP_DURATION 500000

// DSI_EOTP_ENABLE - Used to enable/disable transmission of EOTP packet
//                   0 - EOTP packet is disabled
//                   1 - EOTP packet is enabled (default if not defined)
 `define DSI_EOTP_ENABLE 1

// DSI_VBP_LINES -  Number of Vertical Back Porch Lines
 `define DSI_VBP_LINES 36

// DSI_VFP_LINES - Number of Vertical Front Porch Lines
 `define DSI_VFP_LINES 4

// DSI_VSA_LINES - Number of Vertical Sync Active Lines
 `define DSI_VSA_LINES 5


//##################################################################################################################
// CSI-2 specific Testbench Parameters below
// Modify/uncomment the `define according to your preference
//##################################################################################################################

// CSI2_LPS_GAP - Used to set low power state delay between HS transactions (in ps)
 `define CSI2_LPS_GAP 5000000

// CSI2_LS_LE_EN - Used to enable/disable DPHY model transmission of line start and line end packets
//                 0 - No Line start and Line end packets (default if not defined)
//                 1 - Line start and Line end packets enable
 `define CSI2_LS_LE_EN 0

// CSI2_NUM_PIXELS - Used to set the number of pixels per line
 `define CSI2_NUM_PIXELS 1000

