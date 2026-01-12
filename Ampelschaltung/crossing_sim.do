vlib work
vmap work work

vcom -work work std_package.vhd
vcom -work work clock.vhd
vcom -work work traffic_light.vhd
vcom -work work crossing.vhd
vcom -work work crossing_tb.vhd

vsim work.crossing_tb

add wave -r *

WaveRestoreZoom {0 ns} {2000 us}

run 9000 us