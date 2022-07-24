#!/use/bin/env python
'''
Function: Generate reference model for 16x3 PEC -> 1 patch conv with 1 ftrgrp 
Input: flag data addrwei; current number of ftrgrp/patch;
Output: 16x3 PSUMGB_data each of which contains 14xblockxframe lines
'''

import numpy as np
import random
import os
import sys
import filecmp
sys.path.append("/workspace/home/zhoucc/Share/Chip_test/Simple_test/scripts")
import PEC
# import DISWEI
# import DISACT

# ******************************************************************************
# Parameters
# ******************************************************************************
DATA_WIDTH  = 8
BLOCK_DEPTH = 32
KERNEL_SIZE = 9  # NumWei = 27
NUM_PEB     = 16 # NUM_PEB = 1
NUM_PEC     = 3  #NUM_PEC = 3
LENROW      = 16
PORT_WIDTH  = 128

# ******************************************************************************
# args
# ******************************************************************************
import argparse
parser = argparse.ArgumentParser(description='manual to this script')
parser.add_argument("--layer", type=str, default="00")
parser.add_argument("--patch", type=str, default="00")
parser.add_argument("--ftrgrp", type=str, default="00")
parser.add_argument("--num_frame", type=int, default=4)
args = parser.parse_args()
# print(args.layer)
# print(args.patch)
# print(args.ftrgrp)
# print(args.num_frame)

# ******************************************************************************
# read files
# ******************************************************************************
FlagWeiFileName = '/workspace/home/zhoucc/Share/Chip_test/Simple_test/data_test/flagwei/flagwei_L'+args.layer+'_F'+args.ftrgrp+'.txt'
WeiAddrFileName = '/workspace/home/zhoucc/Share/Chip_test/Simple_test/data_test/addrwei/addrwei_L'+args.layer+'_F'+args.ftrgrp+'.txt' 
WeiFileName     = '/workspace/home/zhoucc/Share/Chip_test/Simple_test/data_test/datawei/datawei_L'+args.layer+'_F'+args.ftrgrp+'.txt'
FlagActFileName = '/workspace/home/zhoucc/Share/Chip_test/Simple_test/data_test/flagact/flagact_L'+args.layer+'_P'+args.patch +'.txt'
ActFileName     = '/workspace/home/zhoucc/Share/Chip_test/Simple_test/data_test/dataact/dataact_L'+args.layer+'_P'+args.patch +'.txt'
FlagActFile = open (FlagActFileName,'r')
ActFile     = open (ActFileName,    'r')
FlagWeiFile = open(FlagWeiFileName, 'r')
WeiAddrFile = open(WeiAddrFileName, 'r')
WeiFile     = open(WeiFileName, 'r')



# ******************************************************************************
# Config 
# ******************************************************************************
POOL_ValIFM = 0

# 1 patch conv with 1 ftrgrp
NumLay      = 1
NumPat      = 1 
NumFtrGrp   = 1
NumFrm      = args.num_frame
NumBlk      = 2
MAX_DEPTH   = BLOCK_DEPTH*NumBlk

Stride      = 2

# ******************************************************************************
# write files
# ******************************************************************************
AddrBlockWeiFile = open("./dump_rm/PEL/AddrBlockWei_L"+args.layer+'_F'+args.ftrgrp+".txt",'w')
WeiDFile         = open("./dump_rm/PEL/WeiDFile_L"+args.layer+'_F'+args.ftrgrp+".txt",'w')
ActDFile         = open("./dump_rm/PEL/ActDFile.txt",'w')
WeiAddrDFile     = open("./dump_rm/PEL/WeiAddrDFile_L"+args.layer+'_F'+args.ftrgrp+".txt",'w')
FullFile         = open("./dump_rm/PEL/FullFile_L"+args.layer+'_P'+args.patch +'.txt','w')
# ******************************************************************************
# Initial
# ******************************************************************************
for cntPEB in range(NUM_PEB):
    for cntPEC in range(NUM_PEC):
        path = "./dump_rm/PEL/PEB"+str("%02d"%cntPEB)+"/PSUMGB_data"+str(cntPEC)+"_L"+args.layer+"_P"+args.patch+"_F"+args.ftrgrp+".txt" 
        if os.path.exists(path): 
            os.remove(path) 

# ******************************************************************************
# READ_BACK
# ******************************************************************************
def READ_BACK( File, DFile,NumCol, NumChar, Signed, cnt_rd, temp, EnWr, WrWidth=4 ):
    remainder = cnt_rd % (NumCol/NumChar)
    if remainder == 0:
        temp = File.readline().rstrip('\n').rstrip('\r')
    data = int(temp[NumChar*(NumCol/NumChar-remainder-1) : NumChar*(NumCol/NumChar - remainder)], 2) # signed
    if Signed and data > 127:
        data = data - 256
    cnt_rd += 1

    # write decimal file
    if EnWr:
        DFile.write(("%"+str(WrWidth)+"d")%data)
        if cnt_rd % (NumCol/NumChar) == 0:
            DFile.write("\n")
    return data, cnt_rd, temp

def READ_BACK_HEX( File, DFile,NumCol, NumChar, Signed, cnt_rd, temp, EnWr, WrWidth=4 ):
    remainder = cnt_rd % (NumCol/NumChar)
    if remainder == 0:
        temp = File.readline().rstrip('\n').rstrip('\r')
    data = int(temp[NumChar*(NumCol/NumChar-remainder-1) : NumChar*(NumCol/NumChar - remainder)], 16) # signed
    if Signed and data > 127:
        data = data - 256
    cnt_rd += 1

    # write decimal file
    if EnWr:
        DFile.write(("%"+str(WrWidth)+"d")%data)
        if cnt_rd % (NumCol/NumChar) == 0:
            DFile.write("\n")
    return data, cnt_rd, temp
# ******************************************************************************
# WEI
# ******************************************************************************
cnt_rd_flgwei = 0
cnt_rd_wei    = 0
REGWEI      = [[[[ 0 for x in range (0,MAX_DEPTH)] for y in range(0, KERNEL_SIZE*3+1) ] \
                      for m in range(NUM_PEB   ) ] for o in range(NumFtrGrp )]

REGFLGWEI   = [[[[ 0 for x in range (0,MAX_DEPTH)] for y in range(0, KERNEL_SIZE*3 + 1) ] \
                      for m in range(NUM_PEB   ) ] for o in range(NumFtrGrp )]
temp_flgwei = ''
for cntFtrGrp in range(NumFtrGrp):
    for cntBlk in range(NumBlk):
        for cntPEB in range(NUM_PEB):
            for cntwei in range(KERNEL_SIZE*3 + 1): # 28
                for cntchn in range(BLOCK_DEPTH):
                    REGFLGWEI[cntFtrGrp][cntPEB][cntwei][cntchn + BLOCK_DEPTH*cntBlk], cnt_rd_flgwei, temp_flgwei = \
                    READ_BACK( FlagWeiFile, FullFile,PORT_WIDTH, 1, 0, cnt_rd_flgwei, temp_flgwei, 0)

NumValWei = [[[ 0 for x in range(KERNEL_SIZE*3)] for y in range(NUM_PEB) ] for z in range(NumFtrGrp)]
for cntFtrGrp in range(NumFtrGrp):
    for cntPEB in range(NUM_PEB):
        for cntwei in range(KERNEL_SIZE*3):
            for cntchn in range(BLOCK_DEPTH*NumBlk):
                if REGFLGWEI[cntFtrGrp][cntPEB][cntwei][cntchn] :
                    NumValWei[cntFtrGrp][cntPEB][cntwei] += 1
            if NumValWei[cntFtrGrp][cntPEB][cntwei] % 16 != 0:
                NumValWei[cntFtrGrp][cntPEB][cntwei] = NumValWei[cntFtrGrp][cntPEB][cntwei] \
                + (16-NumValWei[cntFtrGrp][cntPEB][cntwei] % 16)
temp_wei = ''
for cntFtrGrp in range(NumFtrGrp):
    for cntPEB in range(NUM_PEB):
        for cntwei in range(KERNEL_SIZE*3):
            for addrwei in range(NumValWei[cntFtrGrp][cntPEB][cntwei]):
            # addr_wr_wei = 0
            # all channels
            # for cntBlk in range(NumBlk):
            #     for cntchn in range(BLOCK_DEPTH):
            #         if REGFLGWEI[cntFtrGrp][cntPEB][cntwei][cntchn + BLOCK_DEPTH*cntBlk]:
                        
                        REGWEI[cntFtrGrp][cntPEB][cntwei][addrwei], cnt_rd_wei, temp_wei = \
                        READ_BACK_HEX( WeiFile, WeiDFile,PORT_WIDTH/4, DATA_WIDTH/4, 1, cnt_rd_wei, temp_wei, 1)
                        # addr_wr_wei += 1

# ******************************************************************************
# ACT
# ******************************************************************************
REGACT      = [[ 0 for x in range (0,BLOCK_DEPTH*LENROW*LENROW*NumBlk*NumFrm)] for o in range (NumPat)] 
REGFLGACT   = [[[ 0 for x in range (0,BLOCK_DEPTH*LENROW*LENROW*NumBlk)] for n in range (NumFrm)] 
                    for o in range (NumPat)]    
cnt_rd_flgact = 0
cnt_rd_act    = 0
temp_flgact = ''
temp_act = ''
for cntPat in range(NumPat):# 
    addr_wr_act    = 0
    for cntfrm in range(NumFrm):
        addr_wr_flgact = 0
        for cntBlk in range (NumBlk ):
            #Fetch a block activation
            for actrow in range(LENROW) :
                for actcol in range(LENROW):
                    for cntchn in range(BLOCK_DEPTH):
                        # get REGACT[cntPat][cntfrm][blk*row*col*chn]
                        # get REGFLGACT[cntPat][cntfrm][]
                        REGFLGACT[cntPat][cntfrm][addr_wr_flgact], cnt_rd_flgact, temp_flgact = \
                        READ_BACK( FlagActFile, FullFile,PORT_WIDTH, 1, 0, cnt_rd_flgact, temp_flgact, 0)
                        addr_wr_flgact += 1
                        if REGFLGACT[cntPat][cntfrm][(cnt_rd_flgact-1)%(BLOCK_DEPTH*LENROW*LENROW*NumBlk)] :                     
                            REGACT[cntPat][addr_wr_act], cnt_rd_act, temp_act = \
                            READ_BACK_HEX( ActFile, ActDFile,PORT_WIDTH/4, DATA_WIDTH/4, 1, cnt_rd_act, temp_act, 1)
                            addr_wr_act += 1

# ******************************************************************************
# COMPUTE
# ******************************************************************************
AddrBlockWei_all = [[[[ 0 for x in range(KERNEL_SIZE)] for y in range(NUM_PEC)] for z in range(NUM_PEB) ] for m in range(NumFtrGrp+1)]
AddrBlockWei_tmp = [[[ 0 for x in range(KERNEL_SIZE)] for y in range(NUM_PEC)] for z in range(NUM_PEB) ]

AddrBlockAct_all = [[ 0 for x in range((NumBlk+ 1)*NumFrm)]  for z in range(NumPat)]

PSUMGB_data = [[[[[[ [ 0 for x in range (0,LENROW)] for y in range(0, LENROW) ]for z in range(0, NUM_PEC)] for m in range(0,NUM_PEB)] 
                       for p in range(NumFrm)] for q in range(NumPat)] for r in range(NumFtrGrp)]

temp_block_base = [ [ 0 for x in range (0,LENROW)] for y in range(0, LENROW) ]
# SRAM3
GBPOOL_data = [[[[[ [ 0 for x in range (0,LENROW)] for y in range(0, LENROW) ] for m in range(0,NUM_PEB)] 
                       for p in range(NumFrm)] for q in range(NumPat)] for r in range(NumFtrGrp)]

for cntFtrGrp in range( NumFtrGrp): # 4 FtrGrp 
    for cntPat in range(NumPat):# 1 patch
        for cntfrm in range(NumFrm):

            for cntPEB in range(NUM_PEB):
                for cntPEC in range(NUM_PEC):
                    for cntwei in range(KERNEL_SIZE):
                        # every weight's addrbase in every block
                        # reset this ftrgrp's all weights
                        AddrBlockWei_tmp[cntPEB][cntPEC][cntwei] = AddrBlockWei_all[cntFtrGrp][cntPEB][cntPEC][cntwei] 
            
            for cntBlk in range (NumBlk ):

                for cntPEB in range(NUM_PEB):
                    for cntPEC in range (NUM_PEC):
                        AddrBlockAct_tmp = AddrBlockAct_all[cntPat][cntBlk + NumBlk*cntfrm]
                        # get PSUMGB_data, PSUM1, PSUM2.
                        # get 14 x 3 actrow*wei
                        if cntBlk == 0: # initial
                            if cntPEC == 0 or cntfrm == 0:
                                temp_block_base = [ [ 0 for x in range (0,LENROW)] for y in range(0, LENROW) ]
                            else: # accum across frame
                                temp_block_base = PSUMGB_data[cntFtrGrp][cntPat][cntfrm -1][cntPEB][cntPEC-1]
                        else: # accum across block
                            temp_block_base = PSUMGB_data[cntFtrGrp][cntPat][cntfrm][cntPEB][cntPEC]

                        PSUMGB_data[cntFtrGrp][cntPat][cntfrm][cntPEB][cntPEC],  AddrBlockAct_tmp, AddrBlockWei_tmp[cntPEB][cntPEC] = \
                        PEC.PEC(REGFLGWEI[cntFtrGrp][cntPEB], REGWEI[cntFtrGrp][cntPEB], REGFLGACT[cntPat][cntfrm], REGACT[cntPat],
                                    temp_block_base,  AddrBlockAct_tmp, AddrBlockWei_tmp[cntPEB][cntPEC],
                                    LENROW, KERNEL_SIZE, BLOCK_DEPTH, cntBlk, cntPEC)
                        RM_File = "./dump_rm/PEL/PEB"+str("%02d"%cntPEB)+"/PSUMGB_data"+str(cntPEC)+"_L"+args.layer+"_P"+args.patch+"_F"+args.ftrgrp+".txt"
                        # RTL_File = "./dump_rtl/PEL/PEB"+str("%02d"%cntPEB)+"/PSUMGB_data"+str(cntPEC)+"_L"+args.layer+"_P"+args.patch+"_F"+args.ftrgrp+".txt"
                        with open (RM_File,'a+') as PSUMGB_data_File:
                            for actrow in range(1, LENROW -1): # dump 14 rows
                                for actcol in range(LENROW): # dump 16 cols
                                    PSUMGB_data_File.write(str("%12d" % PSUMGB_data[cntFtrGrp][cntPat][cntfrm][cntPEB][cntPEC][actrow][actcol]))  # 32b -> 12d
                                PSUMGB_data_File.write('\n')  # 32b -> 12d
                        # exit()

                AddrBlockAct_all[cntPat][cntBlk + 1 + NumBlk*cntfrm] = AddrBlockAct_tmp #update

                for cntPEB in range(NUM_PEB):
                    for cntPEC in range(NUM_PEC):
                        for cntwei in range(KERNEL_SIZE):
                            AddrBlockWeiFile.write(str("%4d"%AddrBlockWei_tmp[cntPEB][cntPEC][cntwei]))
                AddrBlockWeiFile.write('\n')

            for cntPEB in range(NUM_PEB):
                for cntPEC in range(NUM_PEC):
                    for cntwei in range(9):
                        # update next block's addrwei
                        AddrBlockWei_all[cntFtrGrp+1][cntPEB][cntPEC][cntwei] = AddrBlockWei_tmp[cntPEB][cntPEC][cntwei] #reset this ftrgrp's all weights
            # SRAM3 = SRAM3 + SRAM2
            for cntPEB in range(NUM_PEB):
                for actrow in range(LENROW):
                    for actcol in range(LENROW):
                        GBPOOL_data[cntFtrGrp][cntPat][cntfrm][cntPEB][actrow][actcol] += PSUMGB_data[cntFtrGrp][cntPat][cntfrm][cntPEB][2][actrow][actcol]
Cnt_Cmp_Fail = 0
for cntPEB in range(NUM_PEB):
    for cntPEC in range(NUM_PEC):
        RM_File = "./dump_rm/PEL/PEB"+str("%02d"%cntPEB)+"/PSUMGB_data"+str(cntPEC)+"_L"+args.layer+"_P"+args.patch+"_F"+args.ftrgrp+".txt"
        RTL_File = "./dump_rtl/PEL/PEB"+str("%02d"%cntPEB)+"/PSUMGB_data"+str(cntPEC)+"_L"+args.layer+"_P"+args.patch+"_F"+args.ftrgrp+".txt"
        Compare = filecmp.cmp(RM_File, RTL_File)
        if Compare == False:
            # print('<'*8+' Compare '+RTL_File +"\n")
            print('<'*4+' FAIL TS3D Compare '+RTL_File )
            Cnt_Cmp_Fail += 1
if Cnt_Cmp_Fail == 0:
    print('<'*4+' PASS TS3D Compare '+ "_L"+args.layer+"_P"+args.patch+"_F"+args.ftrgrp )
# ******************************************************************************
# WEI_ADDR
# ******************************************************************************
cnt_rd_weiaddr = 0
temp_weiaddr = ''
WeiAddr = [[[ 0 for x in range(KERNEL_SIZE*3)] for y in range(NUM_PEB)] for z in range(NumFtrGrp)]
for cntFtrGrp in range(NumFtrGrp):
    for cntPEB in range(NUM_PEB):
        for cntwei in range(KERNEL_SIZE*3):
            WeiAddr[cntFtrGrp][cntPEB][cntwei], cnt_rd_weiaddr, temp_weiaddr = \
            READ_BACK_HEX( WeiAddrFile, WeiAddrDFile,PORT_WIDTH/4, 16/4, 0, cnt_rd_weiaddr, temp_weiaddr, 1, 6)


# ******************************************************************************
# POOLING
# ******************************************************************************
            # cnt_ACT = 0
            # cnt_Flag = 0 # continously save one frame by one frame
            # GBFFLGOFM_DatRd = ""
            # GBFOFM_DatRd = ""
            # FRMPOOL, DELTA, cnt_ACT, cnt_Flag, GBFOFM_DatRd, GBFFLGOFM_DatRd = \
            #     POOL.POOL(  PSUMGB_data,fl,POOL_ValIFM,
            #                 FRMPOOL, DELTA, cnt_ACT, cnt_Flag, GBFOFM_DatRd, GBFFLGOFM_DatRd,
            #                 POOL_SPRS_MEMFile, GBFOFM_DatRdFile, POOL_FLAG_MEMFile, GBFFLGOFM_DatRdFile,
            #                 LENROW, Stride, NumBlk, NUM_PEB, NUM_PEC, PORT_WIDTH, cntfrm )

