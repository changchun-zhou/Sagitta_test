## Select the technology library
#
#search path library files
set_attribute lib_search_path { \
/workspace/technology/umc/55nm_201908/SC/functional_lib/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055LSCLPMVBDR-LIBRARY_TAPE_OUT_KIT-Ver.B01_P.B/synopsys \
/workspace/technology/umc/55nm_201908/SC/functional_lib/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055LSCLPMVBDH-LIBRARY_TAPE_OUT_KIT-Ver.B01_P.B/synopsys \
/workspace/technology/umc/55nm_201908/SC/functional_lib/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055LSCLPMVBDL-LIBRARY_TAPE_OUT_KIT-Ver.A01_PB/synopsys  \
	};

#target library
set_attribute library { \
	u055lsclpmvbdr_108c125_wc.lib \
	u055lsclpmvbdh_108c125_wc.lib \
	u055lsclpmvbdl_108c125_wc.lib \
	/workspace/home/zhoucc/Share/TS3D/zhoucc/source/primitives/Memory/SYLA55_32X128X1CM2/SYLA55_32X128X1CM2_ss1p08v125c.lib \
	/workspace/home/zhoucc/Share/TS3D/zhoucc/source/primitives/Memory/SYLA55_108X128X1CM2/SYLA55_108X128X1CM2_ss1p08v125c.lib \
	/workspace/home/zhoucc/Share/TS3D/zhoucc/source/primitives/Memory/SYLA55_64X32X1CM2/SYLA55_64X32X1CM2_ss1p08v125c.lib \
	/workspace/home/zhoucc/Share/TS3D/zhoucc/source/primitives/Memory/SYLA55_49X8X16CM2/SYLA55_49X8X16CM2_ss1p08v125c.lib \
	/workspace/home/zhoucc/Share/TS3D/zhoucc/source/primitives/Memory/SYLA55_196X8X16CM2/SYLA55_196X8X16CM2_ss1p08v125c.lib \
	/workspace/home/zhoucc/Share/TS3D/liumin/GB_src/SYLA55_512X32X4CM2/SYLA55_512X32X4CM2_ss1p08v125c.lib \
	/workspace/home/zhoucc/Share/TS3D/qiusy/mem/SYLA55_256X32X4CM2/SYLA55_256X32X4CM2_ss1p08v125c.lib \
	/workspace/home/zhoucc/Share/TS3D/qiusy/mem/SYLA55_64X32X4CM2/SYLA55_64X32X4CM2_ss1p08v125c.lib \
	/workspace/home/zhoucc/Share/TS3D/qiusy/mem/SYLA55_256X8X1CM4/SYLA55_256X8X1CM4_ss1p08v125c.lib \
	} ;


#set operating conditions
#find /lib* -operating_condition *
#ls -attribute /libraries/tcbn65gplushpbwpwc_ecsm/operating_conditions/WCCOM

#-----------------------------------------------------------------------
# Physical libraries
#-----------------------------------------------------------------------
# LEF for standard cells and macros

set tech_lef { \
/workspace/technology/umc/55nm_201908/SC/functional_lib/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055LSCLPMVBDR-LIBRARY_TAPE_OUT_KIT-Ver.B01_P.B/lef/u055lsclpmvbdr.lef \
/workspace/technology/umc/55nm_201908/SC/functional_lib/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055LSCLPMVBDH-LIBRARY_TAPE_OUT_KIT-Ver.B01_P.B/lef/u055lsclpmvbdh.lef \
/workspace/technology/umc/55nm_201908/SC/functional_lib/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055LSCLPMVBDL-LIBRARY_TAPE_OUT_KIT-Ver.A01_PB/lef/u055lsclpmvbdl.lef  \
/workspace/technology/umc/55nm_201908/SC/functional_lib/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055LSCLPMVBDR-LIBRARY_TAPE_OUT_KIT-Ver.B01_P.B/lef/tf/u055lsclpmvbdr_7m0t1f.lef \
/workspace/technology/umc/55nm_201908/IO/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055GIOLP25MVIRFS-LIBRARY_TAPE_OUT_KIT-Ver.B06_PB/lef/u055giolp25mvirfs_7m0t1f.lef \
/workspace/home/zhoucc/Share/TS3D/zhoucc/source/primitives/Memory/SYLA55_32X128X1CM2/SYLA55_32X128X1CM2.lef \
/workspace/home/zhoucc/Share/TS3D/zhoucc/source/primitives/Memory/SYLA55_108X128X1CM2/SYLA55_108X128X1CM2.lef \
/workspace/home/zhoucc/Share/TS3D/zhoucc/source/primitives/Memory/SYLA55_64X32X1CM2/SYLA55_64X32X1CM2.lef \
/workspace/home/zhoucc/Share/TS3D/zhoucc/source/primitives/Memory/SYLA55_49X8X16CM2/SYLA55_49X8X16CM2.lef \
/workspace/home/zhoucc/Share/TS3D/zhoucc/source/primitives/Memory/SYLA55_196X8X16CM2/SYLA55_196X8X16CM2.lef \
/workspace/home/zhoucc/Share/TS3D/liumin/GB_src/SYLA55_512X32X4CM2/SYLA55_512X32X4CM2.lef \
/workspace/home/zhoucc/Share/TS3D/qiusy/mem/SYLA55_256X32X4CM2/SYLA55_256X32X4CM2.lef \
/workspace/home/zhoucc/Share/TS3D/qiusy/mem/SYLA55_64X32X4CM2/SYLA55_64X32X4CM2.lef \
/workspace/home/zhoucc/Share/TS3D/qiusy/mem/SYLA55_256X8X1CM4/SYLA55_256X8X1CM4.lef \
	 }
#cap tables

#set captables "/workspace/technology/tsmc/65nm_GP/Std_cell_lib/tcbn65gplushpbwp/TSMCHOME/digital/Back_End/lef/tcbn65gplushpbwp_140a/techfiles/captable/cln65g+_1p09m+alrdl_rcworst_top2.captable"


#-----------------------------------------------------------------------
# Other variables
#-----------------------------------------------------------------------


