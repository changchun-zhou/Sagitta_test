#stop -condition { flag_finish == 1'b1 }
run 56us
dumptcf -scope top.ASIC_U -output tcf_ASIC.dump -overwrite
run 3us
dumptcf -end
exit
