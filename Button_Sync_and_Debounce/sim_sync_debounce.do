vlib work
vmap work work

vcom -work work input_debounce.vhd
vcom -work work input_synchronizer.vhd
vcom -work work sync_debounce.vhd
vcom -work work sync_debounce_tb.vhd

vsim work.sync_debounce_tb


# Create a group for your named signals
add wave -group CONTROL -label {CLOCK} /sync_debounce_tb/sys_clk_tb
add wave -group CONTROL -label {RESET} /sync_debounce_tb/sys_rst_tb
add wave -group CONTROL -label {BUTTON_IN} /sync_debounce_tb/button_tb

add wave -group SYNCHRONIZATION -label {SYNC_REGISTERS} /sync_debounce_tb/input_debounce_comp/synchronizer/sync_values
add wave -group SYNCHRONIZATION -label {SYNC_BTN}    /sync_debounce_tb/input_debounce_comp/synchronizer/output_o
add wave -group DEBOUNCE -label {PREV_BTN}    /sync_debounce_tb/input_debounce_comp/debouncer/prev_input
add wave -group DEBOUNCE -label {RISING_EDGE} /sync_debounce_tb/input_debounce_comp/debouncer/rising_edge_detected
add wave -group DEBOUNCE -label {FALLING_EDGE} /sync_debounce_tb/input_debounce_comp/debouncer/falling_edge_detected
add wave -group DEBOUNCE -label {FSM_STATE} /sync_debounce_tb/input_debounce_comp/debouncer/fsm_state
add wave -group DEBOUNCE -label {SYNC_DB_BTN} /sync_debounce_tb/input_debounce_comp/debouncer/output_o

# Put all the "other" signals into a separate group
add wave -group OTHERS -r *

WaveRestoreZoom {0 ns} {100 ms}

run 100 ms