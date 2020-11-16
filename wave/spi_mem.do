onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /spi_mem_tb/uut/clk
add wave -noupdate /spi_mem_tb/uut/rst_n
add wave -noupdate /spi_mem_tb/uut/en
add wave -noupdate /spi_mem_tb/uut/wr_en
add wave -noupdate /spi_mem_tb/uut/valid
add wave -noupdate /spi_mem_tb/uut/addr
add wave -noupdate /spi_mem_tb/uut/rd_data
add wave -noupdate /spi_mem_tb/uut/wr_data
add wave -noupdate -expand -group {SPI interface} /spi_mem_tb/uut/spi_cs
add wave -noupdate -expand -group {SPI interface} /spi_mem_tb/uut/spi_clk
add wave -noupdate -expand -group {SPI interface} /spi_mem_tb/uut/spi_si
add wave -noupdate -expand -group {SPI interface} /spi_mem_tb/uut/spi_so
add wave -noupdate -radix unsigned /spi_mem_tb/uut/bit_count
add wave -noupdate -radix unsigned /spi_mem_tb/uut/next_bit_count
add wave -noupdate -radix unsigned /spi_mem_tb/uut/byte_count
add wave -noupdate -radix unsigned /spi_mem_tb/uut/next_byte_count
add wave -noupdate /spi_mem_tb/uut/tx_buffer
add wave -noupdate /spi_mem_tb/uut/rx_buffer
add wave -noupdate /spi_mem_tb/uut/state
add wave -noupdate /spi_mem_tb/uut/next_state
add wave -noupdate /spi_mem_tb/uut/spi_tx_byte
add wave -noupdate /spi_mem_tb/uut/spi_load_data
add wave -noupdate -radix unsigned /spi_mem_tb/error_count
add wave -noupdate -radix unsigned /spi_mem_tb/tested_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {24426881 ns} 0}
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
WaveRestoreZoom {24074675 ns} {24115117 ns}
