vlib work
vlog -f src_files.list +cover -covercells +define+SIM
vsim -voptargs=+acc work.top  -cover -sv_seed random -l sim.FIFO_log
add wave /top/fifoif/*
run 0
add wave -position insertpoint  \
sim:/top/DUT/wr_ptr \
sim:/top/DUT/rd_ptr \
sim:/top/DUT/count\
add wave -position insertpoint  \
sim:/top/TEST/test_txn.RD_EN_ON_DIST \
sim:/top/TEST/test_txn.WR_EN_ON_DIST
add wave -position insertpoint  \
sim:/FIFO_scoreboard_pkg::data_out_ref
coverage save FIFO.ucdb -onexit -du FIFO
##run -all
##quit -sim
##vcover report FIFO_top.ucdb -details -annotate -all -output Coverage_FIFO_SV.txt
