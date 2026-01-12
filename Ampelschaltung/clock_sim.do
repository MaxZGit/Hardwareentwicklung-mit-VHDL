vlib work
vmap work work

vcom -work work std_package.vhd
vcom -work work clock.vhd
vcom -work work clock_tb.vhd

vsim work.clock_tb

add wave -r -color {Orange} -label {SECONDS} -rad {uns} /clock_tb/seconds_tb
add wave -r -color {Yellow} -label {MINUTES} -rad {uns} /clock_tb/minutes_tb
add wave -r -color {Cyan} -label {HOURS} -rad {uns} /clock_tb/hours_tb

add wave -r *

WaveRestoreZoom {0 ns} {900000 ms}

run 900000 ms