## Select the technology library
#
#search path library files
set_attribute lib_search_path { \
/workspace/technology/umc/UMC55SP/G-01-LOGIC_MIXED_MODE55N-SP_LOW_K-DSM/IP_Category/9Track/G-9LD-LOGIC_MIXED_MODE55N-SP_LOW_K_UM055LSCSPMVBBL-LIBRARY_DESIGN_KIT-Ver.A03_P.B/synopsys/ccs \
/workspace/technology/umc/UMC55SP/G-01-LOGIC_MIXED_MODE55N-SP_LOW_K-DSM/IP_Category/9Track/G-9LD-LOGIC_MIXED_MODE55N-SP_LOW_K_UM055LSCSPMVBBR-LIBRARY_DESIGN_KIT-Ver.A02_P.B/synopsys/ccs \
	} ;

#target library
set_attribute library { \
  u055lscspmvbbr_090c125_wc_ccs.lib \
	u055lscspmvbbl_090c125_wc_ccs.lib \
	} ;


#set operating conditions
#find /lib* -operating_condition *
#ls -attribute /libraries/tcbn65gplushpbwpwc_ecsm/operating_conditions/WCCOM

#-----------------------------------------------------------------------
# Physical libraries
#-----------------------------------------------------------------------
# LEF for standard cells and macros

# set tech_lef { \
# 		/workspace/technology/umc/55nm_201908/SC/functional_lib/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055LSCLPMVBDR-LIBRARY_TAPE_OUT_KIT-Ver.B01_P.B/lef/u055lsclpmvbdr.lef \
# 		/workspace/technology/umc/55nm_201908/SC/functional_lib/G-9LT-LOGIC_MIXED_MODE55N-LP_LOW_K_UM055LSCLPMVBDR-LIBRARY_TAPE_OUT_KIT-Ver.B01_P.B/lef/tf/u055lsclpmvbdr_7m0t1f.lef \
# 		/workspace/home/caoxg/pulpino_umc/umc_tech/SHLA55_8192X32X1CM16/SHLA55_8192X32X1CM16.lef \
# 		/workspace/home/caoxg/pulpino_umc/umc_tech/SPLA55_1024X32BM1A0/SPLA55_1024X32BM1A0.lef \
# 		/workspace/home/caoxg/pulpino_umc/umc_tech/IO/lef/u055giolp25mvirfs_7m0t1f.lef \
# 	 }
#cap tables

#set captables "/workspace/technology/tsmc/65nm_GP/Std_cell_lib/tcbn65gplushpbwp/TSMCHOME/digital/Back_End/lef/tcbn65gplushpbwp_140a/techfiles/captable/cln65g+_1p09m+alrdl_rcworst_top2.captable"


#-----------------------------------------------------------------------
# Other variables
#-----------------------------------------------------------------------


