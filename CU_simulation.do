#Compile Desing
do compile.do
#Start Simulation
vsim work.TB_FSM_ControlUnit(TEST) -voptargs=+acc
#set waveforms
do waveform_settings.do
#Run simulation
run 73 ns

#vsim work.tb_fsm_controlunit -voptargs=+acc
