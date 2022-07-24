#stop -condition { flag_finish == 1'b1 }
dumptcf -scope top.ASIC_U -output tcf_ASIC.dump -overwrite
run 10000000ns
dumptcf -end
exit
