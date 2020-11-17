onerror {resume}
quietly virtual signal -install /gomoku_main_tb/uut { (context /gomoku_main_tb/uut )&{buzzer_clk , buzzer_clk_2 , led_scan_clk , kb_scan_clk , led_flicker_clk_slow , led_flicker_clk_fast , countdown_clk }} clock
quietly WaveActivateNextPane {} 0
add wave -noupdate /gomoku_main_tb/uut/clk
add wave -noupdate /gomoku_main_tb/uut/rst_n
add wave -noupdate -expand -group Clock /gomoku_main_tb/uut/buzzer_clk
add wave -noupdate -expand -group Clock /gomoku_main_tb/uut/buzzer_clk_2
add wave -noupdate -expand -group Clock /gomoku_main_tb/uut/led_scan_clk
add wave -noupdate -expand -group Clock /gomoku_main_tb/uut/kb_scan_clk
add wave -noupdate -expand -group Clock /gomoku_main_tb/uut/led_flicker_clk_slow
add wave -noupdate -expand -group Clock /gomoku_main_tb/uut/led_flicker_clk_fast
add wave -noupdate -expand -group Clock /gomoku_main_tb/uut/countdown_clk
add wave -noupdate -expand -group {SPI mem} -expand /gomoku_main_tb/uut/spi_mem_emu_inst/cmd
add wave -noupdate -expand -group {SPI mem} /gomoku_main_tb/uut/spi_mem_emu_inst/addr
add wave -noupdate -expand -group {SPI mem} /gomoku_main_tb/uut/spi_mem_emu_inst/rd_data
add wave -noupdate -expand -group {SPI mem} /gomoku_main_tb/uut/spi_mem_emu_inst/wr_data
add wave -noupdate -expand -group {SPI mem} /gomoku_main_tb/uut/spi_mem_emu_inst/en
add wave -noupdate -expand -group {SPI mem} /gomoku_main_tb/uut/spi_mem_emu_inst/valid
add wave -noupdate -expand -group memrst /gomoku_main_tb/uut/memrst_inst/en
add wave -noupdate -expand -group memrst /gomoku_main_tb/uut/memrst_inst/mem_en
add wave -noupdate -expand -group memrst /gomoku_main_tb/uut/memrst_inst/mem_valid
add wave -noupdate -expand -group memrst /gomoku_main_tb/uut/memrst_inst/mem_addr
add wave -noupdate -expand -group memrst /gomoku_main_tb/uut/memrst_inst/mem_data
add wave -noupdate -expand -group memrst /gomoku_main_tb/uut/memrst_inst/done
add wave -noupdate -expand -group memrst /gomoku_main_tb/uut/memrst_inst/state
add wave -noupdate -expand -group memrst /gomoku_main_tb/uut/memrst_inst/next_state
add wave -noupdate -expand -group {mem write} /gomoku_main_tb/uut/mw_mem_en
add wave -noupdate -expand -group {mem write} /gomoku_main_tb/uut/mw_mem_valid
add wave -noupdate -expand -group {mem write} /gomoku_main_tb/uut/mw_mem_addr
add wave -noupdate -expand -group {mem write} /gomoku_main_tb/uut/mw_mem_wr_data
add wave -noupdate -expand -group Scanner /gomoku_main_tb/uut/scanner_inst/flicker_clk
add wave -noupdate -expand -group Scanner -expand -group {Mem if} /gomoku_main_tb/uut/scanner_inst/mem_busy
add wave -noupdate -expand -group Scanner -expand -group {Mem if} /gomoku_main_tb/uut/scanner_inst/mem_en
add wave -noupdate -expand -group Scanner -expand -group {Mem if} /gomoku_main_tb/uut/scanner_inst/mem_valid
add wave -noupdate -expand -group Scanner -expand -group {Mem if} /gomoku_main_tb/uut/scanner_inst/mem_addr
add wave -noupdate -expand -group Scanner -expand -group {Mem if} /gomoku_main_tb/uut/scanner_inst/mem_data
add wave -noupdate -expand -group Scanner -color {Dark Orchid} -itemcolor Magenta -expand -subitemconfig {{/gomoku_main_tb/uut/scanner_inst/led_row[7]} {-color {Dark Orchid} -height 16 -itemcolor Magenta} {/gomoku_main_tb/uut/scanner_inst/led_row[6]} {-color {Dark Orchid} -height 16 -itemcolor Magenta} {/gomoku_main_tb/uut/scanner_inst/led_row[5]} {-color {Dark Orchid} -height 16 -itemcolor Magenta} {/gomoku_main_tb/uut/scanner_inst/led_row[4]} {-color {Dark Orchid} -height 16 -itemcolor Magenta} {/gomoku_main_tb/uut/scanner_inst/led_row[3]} {-color {Dark Orchid} -height 16 -itemcolor Magenta} {/gomoku_main_tb/uut/scanner_inst/led_row[2]} {-color {Dark Orchid} -height 16 -itemcolor Magenta} {/gomoku_main_tb/uut/scanner_inst/led_row[1]} {-color {Dark Orchid} -height 16 -itemcolor Magenta} {/gomoku_main_tb/uut/scanner_inst/led_row[0]} {-color {Dark Orchid} -height 16 -itemcolor Magenta}} /gomoku_main_tb/uut/scanner_inst/led_row
add wave -noupdate -expand -group Scanner -color Red -expand -subitemconfig {{/gomoku_main_tb/uut/scanner_inst/led_col_red[7]} {-color Red -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_red[6]} {-color Red -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_red[5]} {-color Red -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_red[4]} {-color Red -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_red[3]} {-color Red -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_red[2]} {-color Red -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_red[1]} {-color Red -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_red[0]} {-color Red -height 16}} /gomoku_main_tb/uut/scanner_inst/led_col_red
add wave -noupdate -expand -group Scanner -color {Spring Green} -expand -subitemconfig {{/gomoku_main_tb/uut/scanner_inst/led_col_green[7]} {-color {Spring Green} -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_green[6]} {-color {Spring Green} -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_green[5]} {-color {Spring Green} -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_green[4]} {-color {Spring Green} -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_green[3]} {-color {Spring Green} -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_green[2]} {-color {Spring Green} -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_green[1]} {-color {Spring Green} -height 16} {/gomoku_main_tb/uut/scanner_inst/led_col_green[0]} {-color {Spring Green} -height 16}} /gomoku_main_tb/uut/scanner_inst/led_col_green
add wave -noupdate -expand -group Judger /gomoku_main_tb/uut/judger_inst/en
add wave -noupdate -expand -group Judger /gomoku_main_tb/uut/judger_inst/color
add wave -noupdate -expand -group Judger /gomoku_main_tb/uut/judger_inst/pos
add wave -noupdate -expand -group Judger -radix unsigned /gomoku_main_tb/uut/judger_inst/result
add wave -noupdate -expand -group Judger -color Yellow /gomoku_main_tb/uut/judger_inst/done
add wave -noupdate -expand -group Judger -expand -group {Mem if} /gomoku_main_tb/uut/judger_inst/mem_en
add wave -noupdate -expand -group Judger -expand -group {Mem if} /gomoku_main_tb/uut/judger_inst/mem_valid
add wave -noupdate -expand -group Judger -expand -group {Mem if} /gomoku_main_tb/uut/judger_inst/mem_addr
add wave -noupdate -expand -group Judger -expand -group {Mem if} /gomoku_main_tb/uut/judger_inst/mem_data
add wave -noupdate -expand -group Judger -color Orange -radix unsigned /gomoku_main_tb/uut/judger_inst/state
add wave -noupdate -expand -group Judger -color Orange -radix unsigned /gomoku_main_tb/uut/judger_inst/next_state
add wave -noupdate -expand -group Judger -radix unsigned /gomoku_main_tb/uut/judger_inst/judge_type
add wave -noupdate -expand -group Judger -radix unsigned /gomoku_main_tb/uut/judger_inst/next_judge_type
add wave -noupdate -expand -group Keyboard /gomoku_main_tb/uut/kb_inst/scan_clk
add wave -noupdate -expand -group Keyboard -group if /gomoku_main_tb/uut/kb_inst/keyboard_col
add wave -noupdate -expand -group Keyboard -group if /gomoku_main_tb/uut/kb_inst/keyboard_row
add wave -noupdate -expand -group Keyboard /gomoku_main_tb/uut/kb_inst/pressed_index
add wave -noupdate -expand -group Keyboard /gomoku_main_tb/uut/kb_inst/key_valid
add wave -noupdate -expand -group Keyboard /gomoku_main_tb/uut/kb_inst/key_received
add wave -noupdate -expand -group IO /gomoku_main_tb/uut/sw_power
add wave -noupdate -expand -group IO -color White /gomoku_main_tb/uut/btn_ok
add wave -noupdate -expand -group IO /gomoku_main_tb/uut/btn_ok_down
add wave -noupdate -expand -group IO -color Red /gomoku_main_tb/uut/led_red_status
add wave -noupdate -expand -group IO -color {Spring Green} /gomoku_main_tb/uut/led_green_status
add wave -noupdate -expand -group IO -color Maroon /gomoku_main_tb/uut/buzzer_out
add wave -noupdate -expand -group IO /gomoku_main_tb/uut/buzzer_en
add wave -noupdate -expand -group IO -color {Medium Sea Green} /gomoku_main_tb/uut/countdown_en
add wave -noupdate -expand -group IO -color {Dark Green} -radix unsigned /gomoku_main_tb/uut/num_countdown_h
add wave -noupdate -expand -group IO -color {Dark Green} -radix unsigned /gomoku_main_tb/uut/num_countdown_l
add wave -noupdate -color Yellow -itemcolor Yellow -radix unsigned /gomoku_main_tb/uut/state
add wave -noupdate -color Yellow -itemcolor Yellow -radix unsigned /gomoku_main_tb/uut/next_state
add wave -noupdate /gomoku_main_tb/uut/current_active_side
add wave -noupdate -radix unsigned /gomoku_main_tb/uut/x_pos
add wave -noupdate -radix unsigned /gomoku_main_tb/uut/y_pos
add wave -noupdate -color Coral -expand -subitemconfig {{/gomoku_main_tb/uut/presseed_keys[1]} {-color Coral -height 16} {/gomoku_main_tb/uut/presseed_keys[0]} {-color Coral -height 16}} /gomoku_main_tb/uut/presseed_keys
add wave -noupdate -radix unsigned /gomoku_main_tb/uut/piece_count
add wave -noupdate /gomoku_main_tb/uut/game_draw
add wave -noupdate /gomoku_main_tb/uut/timed_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {70528683 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 176
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
WaveRestoreZoom {0 ns} {277213125 ns}
