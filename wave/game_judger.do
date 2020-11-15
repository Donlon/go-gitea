onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /game_judger_tb/clk
add wave -noupdate /game_judger_tb/rst_n
add wave -noupdate -expand -group {New Group} /game_judger_tb/ram_we
add wave -noupdate -expand -group {New Group} /game_judger_tb/ram_rd_addr
add wave -noupdate -expand -group {New Group} /game_judger_tb/ram_rd_data_out
add wave -noupdate -expand -group {New Group2} /game_judger_tb/judger_en
add wave -noupdate -expand -group {New Group2} /game_judger_tb/judger_color
add wave -noupdate -expand -group {New Group2} /game_judger_tb/judger_pos
add wave -noupdate -expand -group {New Group2} /game_judger_tb/judger_result
add wave -noupdate -expand -group {New Group2} /game_judger_tb/judger_done
add wave -noupdate -radixenum symbolic /game_judger_tb/uut/state
add wave -noupdate /game_judger_tb/uut/next_state
add wave -noupdate /game_judger_tb/uut/judge_type
add wave -noupdate /game_judger_tb/uut/next_judge_type
add wave -noupdate /game_judger_tb/uut/inc_x
add wave -noupdate /game_judger_tb/uut/inc_y
add wave -noupdate /game_judger_tb/uut/pos_inc_reach_boarder
add wave -noupdate /game_judger_tb/uut/pos_inc_reach_boarder_r
add wave -noupdate -radix unsigned /game_judger_tb/uut/successive_count
add wave -noupdate /game_judger_tb/uut/judger_win
add wave -noupdate /game_judger_tb/uut/inc_suc_count
add wave -noupdate /game_judger_tb/error_count
add wave -noupdate /game_judger_tb/tested_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {43677 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 200
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
WaveRestoreZoom {13984 ns} {76372 ns}
