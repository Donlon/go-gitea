onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /game_judger_tb/clk
add wave -noupdate /game_judger_tb/rst_n
add wave -noupdate -expand -group {New Group2} /game_judger_tb/judger_en
add wave -noupdate -expand -group {New Group2} /game_judger_tb/judger_color
add wave -noupdate -expand -group {New Group2} /game_judger_tb/judger_pos
add wave -noupdate -expand -group {New Group2} /game_judger_tb/judger_result
add wave -noupdate -expand -group {New Group2} /game_judger_tb/judger_done
add wave -noupdate -expand -group {Memory interface} /game_judger_tb/uut/mem_en
add wave -noupdate -expand -group {Memory interface} /game_judger_tb/uut/mem_valid
add wave -noupdate -expand -group {Memory interface} /game_judger_tb/uut/mem_addr
add wave -noupdate -expand -group {Memory interface} /game_judger_tb/uut/mem_data
add wave -noupdate -radixenum symbolic /game_judger_tb/uut/state
add wave -noupdate /game_judger_tb/uut/next_state
add wave -noupdate /game_judger_tb/uut/judge_type
add wave -noupdate /game_judger_tb/uut/next_judge_type
add wave -noupdate /game_judger_tb/uut/inc_x
add wave -noupdate /game_judger_tb/uut/inc_y
add wave -noupdate /game_judger_tb/uut/pos_inc_reach_boarder
add wave -noupdate /game_judger_tb/uut/pos_inc_reach_boarder_last
add wave -noupdate -radix unsigned /game_judger_tb/uut/successive_count
add wave -noupdate /game_judger_tb/uut/judger_win
add wave -noupdate /game_judger_tb/uut/inc_suc_count
add wave -noupdate /game_judger_tb/error_count
add wave -noupdate /game_judger_tb/testcase_index
add wave -noupdate /game_judger_tb/tested_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {60120089 ns} 0} {{Cursor 2} {5940518 ns} 0}
quietly wave cursor active 2
configure wave -namecolwidth 200
configure wave -valuecolwidth 64
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
WaveRestoreZoom {8203884 ns} {8224533 ns}
