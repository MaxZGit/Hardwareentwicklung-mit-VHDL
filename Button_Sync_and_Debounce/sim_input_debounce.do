vlib work
vmap work work

vcom -work work input_debounce.vhd
vcom -work work input_debounce_tb.vhd

vsim work.input_debounce_tb

add wave -r *

WaveRestoreZoom {0 ns} {100 ms}

run 100 ms