onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /display_led_scanner_tb/uut/scan_clk
add wave -noupdate /display_led_scanner_tb/uut/clk
add wave -noupdate /display_led_scanner_tb/uut/en
add wave -noupdate /display_led_scanner_tb/uut/rst_n
add wave -noupdate -expand -group {Memory Interface} /display_led_scanner_tb/uut/mem_busy
add wave -noupdate -expand -group {Memory Interface} /display_led_scanner_tb/uut/mem_en
add wave -noupdate -expand -group {Memory Interface} /display_led_scanner_tb/uut/mem_valid
add wave -noupdate -expand -group {Memory Interface} /display_led_scanner_tb/uut/mem_addr
add wave -noupdate -expand -group {Memory Interface} /display_led_scanner_tb/uut/mem_data
add wave -noupdate /display_led_scanner_tb/uut/mem_read_i
add wave -noupdate /display_led_scanner_tb/uut/continue_read
add wave -noupdate /display_led_scanner_tb/uut/continue_read_r
add wave -noupdate /display_led_scanner_tb/uut/continue_read_rr
add wave -noupdate -expand -group Input /display_led_scanner_tb/uut/flicker_clk
add wave -noupdate -expand -group Input /display_led_scanner_tb/uut/screen_flicker_en
add wave -noupdate -expand -group Input /display_led_scanner_tb/uut/point_flicker_en
add wave -noupdate -expand -group Input /display_led_scanner_tb/uut/point_flicker_pos
add wave -noupdate -expand -group Input /display_led_scanner_tb/uut/point_flicker_color
add wave -noupdate -expand -group Input /display_led_scanner_tb/uut/color_flicker_en
add wave -noupdate -expand -group Input /display_led_scanner_tb/uut/color_flicker_color
add wave -noupdate -color {Blue Violet} -expand -subitemconfig {{/display_led_scanner_tb/uut/led_row[7]} {-color {Blue Violet} -height 16} {/display_led_scanner_tb/uut/led_row[6]} {-color {Blue Violet} -height 16} {/display_led_scanner_tb/uut/led_row[5]} {-color {Blue Violet} -height 16} {/display_led_scanner_tb/uut/led_row[4]} {-color {Blue Violet} -height 16} {/display_led_scanner_tb/uut/led_row[3]} {-color {Blue Violet} -height 16} {/display_led_scanner_tb/uut/led_row[2]} {-color {Blue Violet} -height 16} {/display_led_scanner_tb/uut/led_row[1]} {-color {Blue Violet} -height 16} {/display_led_scanner_tb/uut/led_row[0]} {-color {Blue Violet} -height 16}} /display_led_scanner_tb/uut/led_row
add wave -noupdate -color {Orange Red} -expand -subitemconfig {{/display_led_scanner_tb/uut/led_col_red[7]} {-color {Orange Red} -height 16} {/display_led_scanner_tb/uut/led_col_red[6]} {-color {Orange Red} -height 16} {/display_led_scanner_tb/uut/led_col_red[5]} {-color {Orange Red} -height 16} {/display_led_scanner_tb/uut/led_col_red[4]} {-color {Orange Red} -height 16} {/display_led_scanner_tb/uut/led_col_red[3]} {-color {Orange Red} -height 16} {/display_led_scanner_tb/uut/led_col_red[2]} {-color {Orange Red} -height 16} {/display_led_scanner_tb/uut/led_col_red[1]} {-color {Orange Red} -height 16} {/display_led_scanner_tb/uut/led_col_red[0]} {-color {Orange Red} -height 16}} /display_led_scanner_tb/uut/led_col_red
add wave -noupdate -color {Lime Green} -expand -subitemconfig {{/display_led_scanner_tb/uut/led_col_green[7]} {-color {Lime Green} -height 16} {/display_led_scanner_tb/uut/led_col_green[6]} {-color {Lime Green} -height 16} {/display_led_scanner_tb/uut/led_col_green[5]} {-color {Lime Green} -height 16} {/display_led_scanner_tb/uut/led_col_green[4]} {-color {Lime Green} -height 16} {/display_led_scanner_tb/uut/led_col_green[3]} {-color {Lime Green} -height 16} {/display_led_scanner_tb/uut/led_col_green[2]} {-color {Lime Green} -height 16} {/display_led_scanner_tb/uut/led_col_green[1]} {-color {Lime Green} -height 16} {/display_led_scanner_tb/uut/led_col_green[0]} {-color {Lime Green} -height 16}} /display_led_scanner_tb/uut/led_col_green
add wave -noupdate -expand /display_led_scanner_tb/uut/red_line_buffer
add wave -noupdate -expand /display_led_scanner_tb/uut/green_line_buffer
add wave -noupdate /display_led_scanner_tb/uut/patched_mem_data_red
add wave -noupdate /display_led_scanner_tb/uut/patched_mem_data_green
add wave -noupdate -radix unsigned /display_led_scanner_tb/uut/current_scan_row
add wave -noupdate -radix unsigned /display_led_scanner_tb/uut/next_scan_row
add wave -noupdate /display_led_scanner_tb/uut/frame_changed
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {777055 us} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
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
configure wave -timelineunits us
update
WaveRestoreZoom {485694 us} {1368775 us}
