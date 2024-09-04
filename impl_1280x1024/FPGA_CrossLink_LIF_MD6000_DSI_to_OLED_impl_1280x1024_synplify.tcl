#-- Lattice Semiconductor Corporation Ltd.
#-- Synplify OEM project file

#device options
set_option -technology LIFMD
set_option -part LIF_MD6000
set_option -package KMG80I
set_option -speed_grade -6

#compilation/mapping options
set_option -symbolic_fsm_compiler true
set_option -resource_sharing true

#use verilog 2001 standard option
set_option -vlog_std v2001

#map options
set_option -frequency 200
set_option -maxfan 1000
set_option -auto_constrain_io 0
set_option -disable_io_insertion false
set_option -retiming false; set_option -pipe true
set_option -force_gsr false
set_option -compiler_compatible 0
set_option -dup false

set_option -default_enum_encoding default

#simulation options


#timing analysis options



#automatic place and route (vendor) options
set_option -write_apr_constraint 1

#synplifyPro options
set_option -fix_gated_and_generated_clocks 1
set_option -update_models_cp 0
set_option -resolve_multiple_driver 0


set_option -seqshift_no_replicate 0

#-- add_file options
set_option -hdl_define -set SBP_SYNTHESIS
set_option -include_path {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/source/include}
set_option -include_path {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/source/synthesis_directives.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/b2p/b2p.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/b2p/b2p_byte2pixel_bb.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/int_pll/int_pll.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/rx_dphy/rx_dphy.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/rx_dphy/rx_dphy_dphy_rx.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/rx_dphy/rx_dphy_dphy_wrapper.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/rx_dphy/rx_dphy_capture_ctrl_bb.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/rx_dphy/rx_dphy_dphy_rx_wrap_bb.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/rx_dphy/rx_dphy_rx_global_ctrl_bb.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/rx_dphy/rx_dphy_soft_dphy_rx_bb.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/ip_cores/ip_cores/ip_cores.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/source/mipi2parallel.v}
add_file -verilog -vlog_std v2001 {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/source/mipi2parallel_top.v}

#-- top module name
set_option -top_module mipi2parallel_top

#-- set result format/file last
project -result_file {C:/Users/p2119/Desktop/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED/impl_1280x1024/FPGA_CrossLink_LIF_MD6000_DSI_to_OLED_impl_1280x1024.edi}

#-- error message log file
project -log_file {FPGA_CrossLink_LIF_MD6000_DSI_to_OLED_impl_1280x1024.srf}

#-- set any command lines input by customer


#-- run Synplify with 'arrange HDL file'
project -run -clean
