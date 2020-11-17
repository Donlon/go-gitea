onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /mem_reset_tb/uut/clk
add wave -noupdate /mem_reset_tb/uut/rst_n
add wave -noupdate /mem_reset_tb/uut/en
add wave -noupdate /mem_reset_tb/uut/done
add wave -noupdate -expand -group {Memory Interface} /mem_reset_tb/uut/mem_en
add wave -noupdate -expand -group {Memory Interface} /mem_reset_tb/uut/mem_valid
add wave -noupdate -expand -group {Memory Interface} /mem_reset_tb/uut/mem_addr
add wave -noupdate -expand -group {Memory Interface} /mem_reset_tb/uut/mem_data
add wave -noupdate /mem_reset_tb/uut/state
add wave -noupdate /mem_reset_tb/uut/next_state
add wave -noupdate /mem_reset_tb/mem_wr_data
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {698437 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {755475 ns}
