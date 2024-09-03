lappend auto_path "D:/LatticeDiamond/diamond/3.13/data/script"
package require simulation_generation
set ::bali::simulation::Para(DEVICEFAMILYNAME) {LIFMD}
set ::bali::simulation::Para(PROJECT) {simulation}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI}
set ::bali::simulation::Para(FILELIST) {"C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/dphy_rx_eval/rx_dphy/src/beh_rtl/capture_ctrl_beh.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/rx_dphy_capture_ctrl.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/dphy_rx_eval/rx_dphy/src/beh_rtl/rx_global_ctrl_beh.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/rx_dphy_rx_global_ctrl.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/dphy_rx_eval/rx_dphy/src/beh_rtl/soft_dphy_rx_beh.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/rx_dphy_soft_dphy_rx.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/rx_dphy_dphy_wrapper.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/dphy_rx_eval/rx_dphy/src/beh_rtl/dphy_rx_wrap_beh.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/rx_dphy_dphy_rx_wrap.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/rx_dphy_dphy_rx.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/rx_dphy/rx_dphy.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/int_pll/int_pll.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/i2c_s/i2c_s.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/b2p/b2p_byte2pixel.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/b2p/b2p.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/ipk.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/testbench/verilog/mipi2parallel_MD_tb.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/source/verilog/i2c_target_top.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/source/verilog/mipi2parallel.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/source/verilog/mipi2parallel_top.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/source/verilog/synthesis_directives.v" "C:/Users/jarsul/Desktop/CrossLink-MIPI-DSICSI-2-to-Parallel_DSI/ipk/b2p/byte2pixel_eval/b2p/src/beh_rtl/byte2pixel_beh.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(LANGSTDLIST) {"Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_lifmd}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {mipi2parallel_MD_tb}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(INSTALLATIONPATH) {D:/LatticeDiamond/diamond/3.13}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(HDLPARAMETERS) {}
set ::bali::simulation::Para(POJO2LIBREFRESH)    {}
set ::bali::simulation::Para(POJO2MODELSIMLIB)   {}
::bali::simulation::ModelSim_Run
