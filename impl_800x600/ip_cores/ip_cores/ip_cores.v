/* synthesis translate_off*/
`define SBP_SIMULATION
/* synthesis translate_on*/
`ifndef SBP_SIMULATION
`define SBP_SYNTHESIS
`endif

//
// Verific Verilog Description of module ip_cores
//
module ip_cores (b2p_dt_i, b2p_p_odd_o, b2p_payload_i, b2p_pd_o, b2p_wc_i, 
            rx_dphy_bd_o, rx_dphy_dt_o, rx_dphy_ecc_o, rx_dphy_lp_hs_state_clk_o, 
            rx_dphy_lp_hs_state_d_o, rx_dphy_payload_o, rx_dphy_ref_dt_i, 
            rx_dphy_vc_o, rx_dphy_wc_o, b2p_clk_byte_i, b2p_clk_pixel_i, 
            b2p_de_o, b2p_hsync_o, b2p_lp_av_en_i, b2p_payload_en_i, 
            b2p_reset_byte_n_i, b2p_reset_pixel_n_i, b2p_sp_en_i, b2p_vsync_o, 
            int_pll_CLKI, int_pll_CLKOP, int_pll_CLKOS, int_pll_CLKOS2, 
            int_pll_LOCK, int_pll_RST, rx_dphy_cd_d0_o, rx_dphy_clk_byte_fr_i, 
            rx_dphy_clk_byte_hs_o, rx_dphy_clk_byte_o, rx_dphy_clk_lp_ctrl_i, 
            rx_dphy_clk_n_i, rx_dphy_clk_p_i, rx_dphy_d0_n_io, rx_dphy_d0_p_io, 
            rx_dphy_d1_n_i, rx_dphy_d1_p_i, rx_dphy_d2_n_i, rx_dphy_d2_p_i, 
            rx_dphy_d3_n_i, rx_dphy_d3_p_i, rx_dphy_hs_d_en_o, rx_dphy_hs_sync_o, 
            rx_dphy_lp_av_en_o, rx_dphy_lp_d0_rx_n_o, rx_dphy_lp_d0_rx_p_o, 
            rx_dphy_lp_d0_tx_en_i, rx_dphy_lp_d0_tx_n_i, rx_dphy_lp_d0_tx_p_i, 
            rx_dphy_lp_d1_rx_n_o, rx_dphy_lp_d1_rx_p_o, rx_dphy_lp_d2_rx_n_o, 
            rx_dphy_lp_d2_rx_p_o, rx_dphy_lp_d3_rx_n_o, rx_dphy_lp_d3_rx_p_o, 
            rx_dphy_lp_en_o, rx_dphy_payload_en_o, rx_dphy_pd_dphy_i, 
            rx_dphy_pll_lock_i, rx_dphy_reset_byte_fr_n_i, rx_dphy_reset_byte_n_i, 
            rx_dphy_reset_lp_n_i, rx_dphy_reset_n_i, rx_dphy_sp_en_o, 
            rx_dphy_term_clk_en_o) /* synthesis sbp_module=true */ ;
    input [5:0]b2p_dt_i;
    output [1:0]b2p_p_odd_o;
    input [31:0]b2p_payload_i;
    output [23:0]b2p_pd_o;
    input [15:0]b2p_wc_i;
    output [31:0]rx_dphy_bd_o;
    output [5:0]rx_dphy_dt_o;
    output [7:0]rx_dphy_ecc_o;
    output [1:0]rx_dphy_lp_hs_state_clk_o;
    output [1:0]rx_dphy_lp_hs_state_d_o;
    output [31:0]rx_dphy_payload_o;
    input [5:0]rx_dphy_ref_dt_i;
    output [1:0]rx_dphy_vc_o;
    output [15:0]rx_dphy_wc_o;
    input b2p_clk_byte_i;
    input b2p_clk_pixel_i;
    output b2p_de_o;
    output b2p_hsync_o;
    input b2p_lp_av_en_i;
    input b2p_payload_en_i;
    input b2p_reset_byte_n_i;
    input b2p_reset_pixel_n_i;
    input b2p_sp_en_i;
    output b2p_vsync_o;
    input int_pll_CLKI;
    output int_pll_CLKOP;
    output int_pll_CLKOS;
    output int_pll_CLKOS2;
    output int_pll_LOCK;
    input int_pll_RST;
    output rx_dphy_cd_d0_o;
    input rx_dphy_clk_byte_fr_i;
    output rx_dphy_clk_byte_hs_o;
    output rx_dphy_clk_byte_o;
    input rx_dphy_clk_lp_ctrl_i;
    inout rx_dphy_clk_n_i;
    inout rx_dphy_clk_p_i;
    inout rx_dphy_d0_n_io;
    inout rx_dphy_d0_p_io;
    inout rx_dphy_d1_n_i;
    inout rx_dphy_d1_p_i;
    inout rx_dphy_d2_n_i;
    inout rx_dphy_d2_p_i;
    inout rx_dphy_d3_n_i;
    inout rx_dphy_d3_p_i;
    output rx_dphy_hs_d_en_o;
    output rx_dphy_hs_sync_o;
    output rx_dphy_lp_av_en_o;
    output rx_dphy_lp_d0_rx_n_o;
    output rx_dphy_lp_d0_rx_p_o;
    input rx_dphy_lp_d0_tx_en_i;
    input rx_dphy_lp_d0_tx_n_i;
    input rx_dphy_lp_d0_tx_p_i;
    output rx_dphy_lp_d1_rx_n_o;
    output rx_dphy_lp_d1_rx_p_o;
    output rx_dphy_lp_d2_rx_n_o;
    output rx_dphy_lp_d2_rx_p_o;
    output rx_dphy_lp_d3_rx_n_o;
    output rx_dphy_lp_d3_rx_p_o;
    output rx_dphy_lp_en_o;
    output rx_dphy_payload_en_o;
    input rx_dphy_pd_dphy_i;
    input rx_dphy_pll_lock_i;
    input rx_dphy_reset_byte_fr_n_i;
    input rx_dphy_reset_byte_n_i;
    input rx_dphy_reset_lp_n_i;
    input rx_dphy_reset_n_i;
    output rx_dphy_sp_en_o;
    output rx_dphy_term_clk_en_o;
    
    
    b2p b2p_inst (.dt_i({b2p_dt_i}), .p_odd_o({b2p_p_odd_o}), .payload_i({b2p_payload_i}), 
        .pd_o({b2p_pd_o}), .wc_i({b2p_wc_i}), .clk_byte_i(b2p_clk_byte_i), 
        .clk_pixel_i(b2p_clk_pixel_i), .de_o(b2p_de_o), .hsync_o(b2p_hsync_o), 
        .lp_av_en_i(b2p_lp_av_en_i), .payload_en_i(b2p_payload_en_i), .reset_byte_n_i(b2p_reset_byte_n_i), 
        .reset_pixel_n_i(b2p_reset_pixel_n_i), .sp_en_i(b2p_sp_en_i), .vsync_o(b2p_vsync_o));
    int_pll int_pll_inst (.CLKI(int_pll_CLKI), .CLKOP(int_pll_CLKOP), .CLKOS(int_pll_CLKOS), 
            .CLKOS2(int_pll_CLKOS2), .LOCK(int_pll_LOCK), .RST(int_pll_RST));
    rx_dphy rx_dphy_inst (.bd_o({rx_dphy_bd_o}), .dt_o({rx_dphy_dt_o}), 
            .ecc_o({rx_dphy_ecc_o}), .lp_hs_state_clk_o({rx_dphy_lp_hs_state_clk_o}), 
            .lp_hs_state_d_o({rx_dphy_lp_hs_state_d_o}), .payload_o({rx_dphy_payload_o}), 
            .ref_dt_i({rx_dphy_ref_dt_i}), .vc_o({rx_dphy_vc_o}), .wc_o({rx_dphy_wc_o}), 
            .cd_d0_o(rx_dphy_cd_d0_o), .clk_byte_fr_i(rx_dphy_clk_byte_fr_i), 
            .clk_byte_hs_o(rx_dphy_clk_byte_hs_o), .clk_byte_o(rx_dphy_clk_byte_o), 
            .clk_lp_ctrl_i(rx_dphy_clk_lp_ctrl_i), .clk_n_i(rx_dphy_clk_n_i), 
            .clk_p_i(rx_dphy_clk_p_i), .d0_n_io(rx_dphy_d0_n_io), .d0_p_io(rx_dphy_d0_p_io), 
            .d1_n_i(rx_dphy_d1_n_i), .d1_p_i(rx_dphy_d1_p_i), .d2_n_i(rx_dphy_d2_n_i), 
            .d2_p_i(rx_dphy_d2_p_i), .d3_n_i(rx_dphy_d3_n_i), .d3_p_i(rx_dphy_d3_p_i), 
            .hs_d_en_o(rx_dphy_hs_d_en_o), .hs_sync_o(rx_dphy_hs_sync_o), 
            .lp_av_en_o(rx_dphy_lp_av_en_o), .lp_d0_rx_n_o(rx_dphy_lp_d0_rx_n_o), 
            .lp_d0_rx_p_o(rx_dphy_lp_d0_rx_p_o), .lp_d0_tx_en_i(rx_dphy_lp_d0_tx_en_i), 
            .lp_d0_tx_n_i(rx_dphy_lp_d0_tx_n_i), .lp_d0_tx_p_i(rx_dphy_lp_d0_tx_p_i), 
            .lp_d1_rx_n_o(rx_dphy_lp_d1_rx_n_o), .lp_d1_rx_p_o(rx_dphy_lp_d1_rx_p_o), 
            .lp_d2_rx_n_o(rx_dphy_lp_d2_rx_n_o), .lp_d2_rx_p_o(rx_dphy_lp_d2_rx_p_o), 
            .lp_d3_rx_n_o(rx_dphy_lp_d3_rx_n_o), .lp_d3_rx_p_o(rx_dphy_lp_d3_rx_p_o), 
            .lp_en_o(rx_dphy_lp_en_o), .payload_en_o(rx_dphy_payload_en_o), 
            .pd_dphy_i(rx_dphy_pd_dphy_i), .pll_lock_i(rx_dphy_pll_lock_i), 
            .reset_byte_fr_n_i(rx_dphy_reset_byte_fr_n_i), .reset_byte_n_i(rx_dphy_reset_byte_n_i), 
            .reset_lp_n_i(rx_dphy_reset_lp_n_i), .reset_n_i(rx_dphy_reset_n_i), 
            .sp_en_o(rx_dphy_sp_en_o), .term_clk_en_o(rx_dphy_term_clk_en_o));
    
endmodule

