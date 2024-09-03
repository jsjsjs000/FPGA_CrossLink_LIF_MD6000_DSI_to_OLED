onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/reset_n_i
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/ref_clk_i
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/clk_p_io
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/clk_n_io
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/d_p_io
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/d_n_io
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/pd_o
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/p_odd_o
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/clk_pixel_o
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/fv_o
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/lv_o
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/scl_io
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/sda_io
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/clk_byte_fr_w
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/clk_lp_ctrl_w
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/pll_lock_w
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/sw_reset_n
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/clk_byte_hs_w
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/clk_pixel_w
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/m2p_reset_n_w
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/i2c_reg_0_w
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/ref_clk_rst_n_meta_r
add wave -noupdate /mipi2parallel_MD_tb/mipi2parallel_top_inst/ref_clk_rst_n_sync_r
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {373830945680 fs} 0} {{Cursor 2} {601942353410 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 357
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 fs} {804825361200 fs}
