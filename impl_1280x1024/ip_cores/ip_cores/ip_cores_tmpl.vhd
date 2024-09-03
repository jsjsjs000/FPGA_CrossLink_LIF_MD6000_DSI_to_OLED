--VHDL instantiation template

component ip_cores is
    port (b2p_dt_i: in std_logic_vector(5 downto 0);
        b2p_p_odd_o: out std_logic_vector(1 downto 0);
        b2p_payload_i: in std_logic_vector(31 downto 0);
        b2p_pd_o: out std_logic_vector(23 downto 0);
        b2p_wc_i: in std_logic_vector(15 downto 0);
        rx_dphy_bd_o: out std_logic_vector(31 downto 0);
        rx_dphy_dt_o: out std_logic_vector(5 downto 0);
        rx_dphy_ecc_o: out std_logic_vector(7 downto 0);
        rx_dphy_lp_hs_state_clk_o: out std_logic_vector(1 downto 0);
        rx_dphy_lp_hs_state_d_o: out std_logic_vector(1 downto 0);
        rx_dphy_payload_o: out std_logic_vector(31 downto 0);
        rx_dphy_ref_dt_i: in std_logic_vector(5 downto 0);
        rx_dphy_vc_o: out std_logic_vector(1 downto 0);
        rx_dphy_wc_o: out std_logic_vector(15 downto 0);
        b2p_clk_byte_i: in std_logic;
        b2p_clk_pixel_i: in std_logic;
        b2p_de_o: out std_logic;
        b2p_hsync_o: out std_logic;
        b2p_lp_av_en_i: in std_logic;
        b2p_payload_en_i: in std_logic;
        b2p_reset_byte_n_i: in std_logic;
        b2p_reset_pixel_n_i: in std_logic;
        b2p_sp_en_i: in std_logic;
        b2p_vsync_o: out std_logic;
        int_pll_CLKI: in std_logic;
        int_pll_CLKOP: out std_logic;
        int_pll_CLKOS: out std_logic;
        int_pll_CLKOS2: out std_logic;
        int_pll_LOCK: out std_logic;
        int_pll_RST: in std_logic;
        rx_dphy_cd_d0_o: out std_logic;
        rx_dphy_clk_byte_fr_i: in std_logic;
        rx_dphy_clk_byte_hs_o: out std_logic;
        rx_dphy_clk_byte_o: out std_logic;
        rx_dphy_clk_lp_ctrl_i: in std_logic;
        rx_dphy_clk_n_i: inout std_logic;
        rx_dphy_clk_p_i: inout std_logic;
        rx_dphy_d0_n_io: inout std_logic;
        rx_dphy_d0_p_io: inout std_logic;
        rx_dphy_d1_n_i: inout std_logic;
        rx_dphy_d1_p_i: inout std_logic;
        rx_dphy_d2_n_i: inout std_logic;
        rx_dphy_d2_p_i: inout std_logic;
        rx_dphy_d3_n_i: inout std_logic;
        rx_dphy_d3_p_i: inout std_logic;
        rx_dphy_hs_d_en_o: out std_logic;
        rx_dphy_hs_sync_o: out std_logic;
        rx_dphy_lp_av_en_o: out std_logic;
        rx_dphy_lp_d0_rx_n_o: out std_logic;
        rx_dphy_lp_d0_rx_p_o: out std_logic;
        rx_dphy_lp_d0_tx_en_i: in std_logic;
        rx_dphy_lp_d0_tx_n_i: in std_logic;
        rx_dphy_lp_d0_tx_p_i: in std_logic;
        rx_dphy_lp_d1_rx_n_o: out std_logic;
        rx_dphy_lp_d1_rx_p_o: out std_logic;
        rx_dphy_lp_d2_rx_n_o: out std_logic;
        rx_dphy_lp_d2_rx_p_o: out std_logic;
        rx_dphy_lp_d3_rx_n_o: out std_logic;
        rx_dphy_lp_d3_rx_p_o: out std_logic;
        rx_dphy_lp_en_o: out std_logic;
        rx_dphy_payload_en_o: out std_logic;
        rx_dphy_pd_dphy_i: in std_logic;
        rx_dphy_pll_lock_i: in std_logic;
        rx_dphy_reset_byte_fr_n_i: in std_logic;
        rx_dphy_reset_byte_n_i: in std_logic;
        rx_dphy_reset_lp_n_i: in std_logic;
        rx_dphy_reset_n_i: in std_logic;
        rx_dphy_sp_en_o: out std_logic;
        rx_dphy_term_clk_en_o: out std_logic
    );
    
end component ip_cores; -- sbp_module=true 
_inst: ip_cores port map (rx_dphy_bd_o => __,rx_dphy_dt_o => __,rx_dphy_ecc_o => __,
            rx_dphy_lp_hs_state_clk_o => __,rx_dphy_lp_hs_state_d_o => __,
            rx_dphy_payload_o => __,rx_dphy_ref_dt_i => __,rx_dphy_vc_o => __,
            rx_dphy_wc_o => __,rx_dphy_cd_d0_o => __,rx_dphy_clk_byte_fr_i => __,
            rx_dphy_clk_byte_hs_o => __,rx_dphy_clk_byte_o => __,rx_dphy_clk_lp_ctrl_i => __,
            rx_dphy_clk_n_i => __,rx_dphy_clk_p_i => __,rx_dphy_d0_n_io => __,
            rx_dphy_d0_p_io => __,rx_dphy_d1_n_i => __,rx_dphy_d1_p_i => __,
            rx_dphy_d2_n_i => __,rx_dphy_d2_p_i => __,rx_dphy_d3_n_i => __,
            rx_dphy_d3_p_i => __,rx_dphy_hs_d_en_o => __,rx_dphy_hs_sync_o => __,
            rx_dphy_lp_av_en_o => __,rx_dphy_lp_d0_rx_n_o => __,rx_dphy_lp_d0_rx_p_o => __,
            rx_dphy_lp_d0_tx_en_i => __,rx_dphy_lp_d0_tx_n_i => __,rx_dphy_lp_d0_tx_p_i => __,
            rx_dphy_lp_d1_rx_n_o => __,rx_dphy_lp_d1_rx_p_o => __,rx_dphy_lp_d2_rx_n_o => __,
            rx_dphy_lp_d2_rx_p_o => __,rx_dphy_lp_d3_rx_n_o => __,rx_dphy_lp_d3_rx_p_o => __,
            rx_dphy_lp_en_o => __,rx_dphy_payload_en_o => __,rx_dphy_pd_dphy_i => __,
            rx_dphy_pll_lock_i => __,rx_dphy_reset_byte_fr_n_i => __,rx_dphy_reset_byte_n_i => __,
            rx_dphy_reset_lp_n_i => __,rx_dphy_reset_n_i => __,rx_dphy_sp_en_o => __,
            rx_dphy_term_clk_en_o => __,int_pll_CLKI => __,int_pll_CLKOP => __,
            int_pll_CLKOS => __,int_pll_CLKOS2 => __,int_pll_LOCK => __,int_pll_RST => __,
            b2p_dt_i => __,b2p_p_odd_o => __,b2p_payload_i => __,b2p_pd_o => __,
            b2p_wc_i => __,b2p_clk_byte_i => __,b2p_clk_pixel_i => __,b2p_de_o => __,
            b2p_hsync_o => __,b2p_lp_av_en_i => __,b2p_payload_en_i => __,
            b2p_reset_byte_n_i => __,b2p_reset_pixel_n_i => __,b2p_sp_en_i => __,
            b2p_vsync_o => __);
