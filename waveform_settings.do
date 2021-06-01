onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Control Signals}
add wave -noupdate -label clock /tb_fsm_controlunit/clock
add wave -noupdate -label reset /tb_fsm_controlunit/reset
add wave -noupdate -label {Instruction Encoding} /tb_fsm_controlunit/Instruction
add wave -noupdate -label {present state} /tb_fsm_controlunit/U/present_state
add wave -noupdate -divider {RF Addresses}
add wave -noupdate -label RS1 /tb_fsm_controlunit/RS1
add wave -noupdate -label RS2 /tb_fsm_controlunit/RS2
add wave -noupdate -label RD /tb_fsm_controlunit/RD
add wave -noupdate -divider {Stage1 signals}
add wave -noupdate -label EN1 /tb_fsm_controlunit/EN1
add wave -noupdate -label RF1 /tb_fsm_controlunit/RF1
add wave -noupdate -label RF2 /tb_fsm_controlunit/RF2
add wave -noupdate -label WF1 /tb_fsm_controlunit/WF1
add wave -noupdate -divider {Stage2 signals}
add wave -noupdate -label EN2 /tb_fsm_controlunit/EN2
add wave -noupdate -label S1 /tb_fsm_controlunit/S1
add wave -noupdate -label S2 /tb_fsm_controlunit/S2
add wave -noupdate -label ALU1 /tb_fsm_controlunit/ALU1
add wave -noupdate -label ALU2 /tb_fsm_controlunit/ALU2
add wave -noupdate -divider {Stage3 Signals}
add wave -noupdate -label EN3 /tb_fsm_controlunit/EN3
add wave -noupdate -label RM /tb_fsm_controlunit/RM
add wave -noupdate -label WM /tb_fsm_controlunit/WM
add wave -noupdate -label S3 /tb_fsm_controlunit/S3
add wave -noupdate -divider {Immediate Inputs}
add wave -noupdate -label INP1 /tb_fsm_controlunit/INP1
add wave -noupdate -label INP2 /tb_fsm_controlunit/INP2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 341
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ns} {581 ns}
