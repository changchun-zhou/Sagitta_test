
# NC-Sim Command File
# TOOL:	ncsim(64)	15.10-s002
#
#
# You can restore this configuration with:
#
#      irun -fsmdebug -access +rwc -sv -64bit -f ../sim_TS3D/filelist.f -timescale 1ns/1ps +testcase=0 -define RANDOM -define DUMP_EN -svseed 000 -define DELAY_SRAM -define ZHOU -l ./log/irun.log -input test.tcl
#

set tcl_prompt1 {puts -nonewline "ncsim> "}
set tcl_prompt2 {puts -nonewline "> "}
set vlog_format %h
set vhdl_format %v
set real_precision 6
set display_unit auto
set time_unit module
set heap_garbage_size -200
set heap_garbage_time 0
set assert_report_level note
set assert_stop_level error
set autoscope yes
set assert_1164_warnings yes
set pack_assert_off {}
set severity_pack_assert_off {note warning}
set assert_output_stop_level failed
set tcl_debug_level 0
set relax_path_name 1
set vhdl_vcdmap XX01ZX01X
set intovf_severity_level ERROR
set probe_screen_format 0
set rangecnst_severity_level ERROR
set textio_severity_level ERROR
set vital_timing_checks_on 1
set vlog_code_show_force 0
set assert_count_attempts 1
set tcl_all64 false
set tcl_runerror_exit false
set assert_report_incompletes 0
set show_force 1
set force_reset_by_reinvoke 0
set tcl_relaxed_literal 0
set probe_exclude_patterns {}
set probe_packed_limit 4k
set probe_unpacked_limit 16k
set assert_internal_msg no
set svseed 0
set assert_reporting_mode 0
alias . run
alias iprof profile
alias quit exit
database -open -shm -into waves.shm waves -default
probe -create -database waves top.TS3D_U.inst_PEL.PEB[13].inst_PEB.MAC[21].inst_MAC.ARBMAC_Rst top.TS3D_U.inst_PEL.PEB[13].inst_PEB.inst_ARB.ARBMAC_IDActRow top.TS3D_U.inst_PEL.PEB[13].inst_PEB.inst_ARB.ARBMAC_IDPSUM top.TS3D_U.inst_PEL.PEB[13].inst_PEB.inst_ARB.ARBMAC_IDWei top.TS3D_U.inst_PEL.PEB[13].inst_PEB.IDMAC_push top.TS3D_U.inst_PEL.PEB[7].inst_PEB.inst_ARB.ARBMAC_Switch top.TS3D_U.inst_PEL.PEB[7].inst_PEB.MACARB_ReqHelp top.TS3D_U.inst_PEL.ARBPEB_Fnh top.TS3D_U.inst_PEL.PEB[7].inst_PEB.inst_ARB.arbrow top.TS3D_U.inst_PEL.PEB[7].inst_PEB.inst_SRAM_ACT.datain top.TS3D_U.inst_PEL.PEB[7].inst_PEB.inst_SRAM_ACT.datain_rdy top.TS3D_U.inst_PEL.PEB[7].inst_PEB.inst_SRAM_ACT.datain_val top.TS3D_U.inst_PEL.PEB[7].inst_PEB.inst_SRAM_ACT.dataout_rdy0 top.TS3D_U.inst_PEL.PEB[7].inst_PEB.inst_SRAM_ACT.dataout_val0 top.TS3D_U.inst_PEL.PEB[6].inst_PEB.inst_SRAM_ACT.dataout1 top.TS3D_U.inst_PEL.PEB[6].inst_PEB.inst_SRAM_ACT.dataout_rdy1 top.TS3D_U.inst_PEL.PEB[6].inst_PEB.inst_SRAM_ACT.dataout_val1 top.TS3D_U.inst_PEL.PEB[6].inst_PEB.inst_SRAM_ACT.datain_rdy top.TS3D_U.inst_PEL.PEB[6].inst_PEB.inst_SRAM_ACT.datain_val top.TS3D_U.inst_PEL.PEB[6].inst_PEB.inst_SRAM_ACT.datain top.TS3D_U.inst_PEL.GBACT_Data top.TS3D_U.inst_PEL.GBACT_Val top.TS3D_U.inst_PEL.ACTGB_Rdy top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_SRAM_ACT.fifo_empty top.TS3D_U.inst_PEL.PEB[4].inst_PEB.inst_SRAM_ACT.datain_rdy top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.datain_rdy top.TS3D_U.inst_PEL.PEB[1].inst_PEB.inst_SRAM_ACT.datain_rdy top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_SRAM_ACT.datain_rdy top.TS3D_U.inst_PEL.PEB[1].inst_PEB.inst_SRAM_ACT.datain top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.datain top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.clk top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.dataout_val1 top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.datain_val top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.fifo_Mux.push top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.fifo_Mux.pop top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.dataout_rdy1 top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.dataout1 top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.dataout_rdy0 top.TS3D_U.inst_PEL.PEB[4].inst_PEB.inst_SRAM_ACT.datain top.TS3D_U.inst_PEL.PEB[4].inst_PEB.inst_SRAM_ACT.datain_val
probe -disable 1
probe -create -database waves top.TS3D_U.inst_PEL.PEB[7].inst_PEB.inst_SRAM_ACT.fifo_Mux.wr_pointer top.TS3D_U.inst_PEL.PEB[7].inst_PEB.inst_SRAM_ACT.fifo_Mux.GEN_RD[0].fifo_count top.TS3D_U.inst_PEL.PEB[6].inst_PEB.inst_SRAM_ACT.fifo_Mux.GEN_RD[1].fifo_count top.TS3D_U.inst_PEL.PEB[6].inst_PEB.inst_SRAM_ACT.fifo_Mux.GEN_RD[1].rd_pointer top.TS3D_U.inst_PEL.PEB[6].inst_PEB.inst_SRAM_ACT.fifo_Mux.empty_inter top.TS3D_U.inst_PEL.PEB[6].inst_PEB.inst_SRAM_ACT.fifo_Mux.full_inter top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_SRAM_ACT.fifo_Mux.full_inter top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.fifo_Mux.GEN_RD[1].fifo_count top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.fifo_Mux.empty_inter
probe -disable 2
probe -create -database waves top.TS3D_U.inst_PEL.PEB[2].inst_PEB.inst_SRAM_ACT.fifo_full
probe -disable 3
probe -create -database waves top.TS3D_U.inst_PEL.PEB[15].inst_PEB.inst_ARB.arbrow top.TS3D_U.inst_PEL.PEB[15].inst_PEB.inst_ARB.MAC_ReqHelp top.TS3D_U.inst_PEL.PEB[15].inst_PEB.inst_ARB.flagcompwei_currow
probe -disable 4
probe -create -database waves top.TS3D_U.inst_PEL.PEB[15].inst_PEB.inst_SRAM_FLGACT.dataout_rdy1 top.TS3D_U.inst_PEL.PEB[15].inst_PEB.inst_SRAM_FLGACT.dataout_val1 top.TS3D_U.inst_PEL.PEB[15].inst_PEB.inst_SRAM_FLGACT.fifo_full
probe -disable 5
probe -create -database waves top.TS3D_U.inst_PEL.PEB[15].inst_PEB.inst_SRAM_FLGACT.datain top.TS3D_U.inst_PEL.PEB[15].inst_PEB.inst_SRAM_FLGACT.datain_rdy top.TS3D_U.inst_PEL.PEB[15].inst_PEB.inst_SRAM_FLGACT.datain_val
probe -disable 6
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.next_block top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_ARB.arbrow top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_ARB.MAC_ReqHelp top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_ARB.flagcompwei_currow top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_ARB.ARBPSUM_fnh top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_ARB.PSUMARB_empty top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_ARB.ARBMAC_IDPSUM
probe -disable 7
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.ARBMAC_Rst top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MAC_Sta top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MACMUX_Psum top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MACMUX_Val top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MUXMAC_Rdy
probe -disable 8
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[0].inst_PSUM.state top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[0].inst_PSUM.psumaddr_val
probe -disable 9
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[0].inst_PSUM.datain_val top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[0].inst_PSUM.datain_rdy
probe -disable 10
probe -create -database waves top.TS3D_U.inst_CCU.cnt_block
probe -disable 11
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUMGB_rdy0 top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUMGB_rdy1 top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUMGB_rdy2 top.TS3D_U.inst_PEL.PEB[0].inst_PEB.GBPSUM_val0 top.TS3D_U.inst_PEL.PEB[0].inst_PEB.GBPSUM_val1 top.TS3D_U.inst_PEL.PEB[0].inst_PEB.GBPSUM_val2
probe -disable 12
probe -create -database waves top.TS3D_U.inst_CCU.cnt_frame
probe -disable 13
probe -create -database waves top.TS3D_U.inst_GB_PSUM.PSUMGB_rdy top.TS3D_U.inst_GB_PSUM.GBPSUM_rdy
probe -disable 14
probe -create -database waves top.TS3D_U.inst_GB_PSUM -all -depth all
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MAC_Act top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MAC_Act_Val top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MAC_Wei top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MAC_Wei_Val
probe -disable 16
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].inst_MAC.MAC_AddrWei top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].REGARRAY_WEI.mem top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].REGARRAY_WEI.datain_val top.TS3D_U.inst_PEL.PEB[0].inst_PEB.MAC[0].REGARRAY_WEI.datain_rdy
probe -disable 17
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_SRAM_WEI.datain_rdy top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_SRAM_WEI.datain_val top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_SRAM_WEI.datain top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_SRAM_WEI.state top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_SRAM_WEI.instrout_rdy top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_SRAM_WEI.instrout_val top.TS3D_U.inst_PEL.PEB[0].inst_PEB.inst_SRAM_WEI.instrout
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.reset_wei
probe -disable 19
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.GBPSUM_data0
probe -disable 20
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[0].GBPSUM_rdy top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[1].GBPSUM_rdy top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[2].GBPSUM_rdy
probe -disable 21
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[1].inst_PSUM.state top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[2].inst_PSUM.state
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[0].inst_PSUM.datain
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[0].inst_PSUM.dataout_val top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[0].inst_PSUM.dataout
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[0].inst_PSUM.PSO_PSUM_ARRAY
probe -disable 25
probe -create -database waves top.TS3D_U.inst_PEL.PEB[0].inst_PEB.PSUM[0].inst_PSUM.reset
probe -disable 26
probe -create -database waves top.TS3D_U.inst_CCU.CFGCCU_num_frame
probe -disable 27
probe -create -database waves top.TS3D_U.inst_GB_PSUM -all -depth all
probe -disable 28
probe -create -database waves top.TS3D_U.inst_POOL.POOLGB_fnh top.TS3D_U.inst_POOL.CCUPOOL_En top.TS3D_U.inst_POOL.POOLGB_addr top.TS3D_U.inst_POOL.state
probe -disable 29
probe -create -database waves top.TS3D_U -all -depth all
probe -disable 30
probe -create -database waves top.TS3D_U -all -depth all
probe -create -database waves top.TS3D_U.inst_GB_PSUM.GB_PSUM_BANK_U[0].psum_ram_rcnt top.TS3D_U.inst_GB_PSUM.GB_PSUM_BANK_U[0].psum_ram_wcnt
probe -create -database waves top.TS3D_U.inst_POOL -all -depth all
probe -create -database waves top.TS3D_U.inst_GB_PSUM -all -depth all
probe -create -database waves top.TS3D_U
probe -create -database waves top.TS3D_U.inst_POOL top.TS3D_U.inst_GB_PSUM
probe -create -database waves top.TS3D_U.inst_POOL.BF_rdy top.TS3D_U.inst_POOL.BF_addr top.TS3D_U.inst_POOL.BF_data top.TS3D_U.inst_POOL.SIPOOFM_En top.TS3D_U.inst_POOL.BF_val top.TS3D_U.inst_POOL.BF_flg_rdy top.TS3D_U.inst_POOL.BF_flg_val top.TS3D_U.inst_POOL.POOLGB_rdy top.TS3D_U.inst_POOL.GBPOOL_val top.TS3D_U.inst_POOL.cnt_poolx top.TS3D_U.inst_POOL.FnhPoolRow top.TS3D_U.inst_POOL.cnt_pooly top.TS3D_U.inst_POOL.FnhPoolPat top.TS3D_U.inst_GB_PSUM.GB_PSUM_BANK_U[0].psum_ram_rcnt top.TS3D_U.inst_GB_PSUM.GB_PSUM_BANK_U[0].psum_ram_wcnt top.TS3D_U.inst_POOL.FLAG_MEM top.TS3D_U.inst_POOL.SPRS_Addr

simvision -input test.tcl.svcf
