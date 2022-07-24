#stop -condition { flag_finish == 1'b1 }
dumptcf -scope top.ASIC_U -output tcf_ASIC.dump -overwrite
run 100ns
dumptcf -end
exit
