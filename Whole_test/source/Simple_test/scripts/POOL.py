import numpy as np
import random
import os
import filecmp

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


GBPOOL_dataFile = open("./dump_rtl/POOL/GBPOOL_data"+"_L" +args.layer+"_P"+args.patch+"_F"+args.ftrgrp+".txt", "r")
RM_File_data =   "./dump_rm/POOL/BF_data"+"_L" +args.layer+"_P"+args.patch+"_F"+args.ftrgrp+".txt"
RTL_File_data = "./dump_rtl/POOL/BF_data"+"_L" +args.layer+"_P"+args.patch+"_F"+args.ftrgrp+".txt"

RM_File_flg =   "./dump_rm/POOL/BF_flg_data"+"_L" +args.layer+"_P"+args.patch+"_F"+args.ftrgrp+".txt"
RTL_File_flg = "./dump_rtl/POOL/BF_flg_data"+"_L" +args.layer+"_P"+args.patch+"_F"+args.ftrgrp+".txt"
BF_dataFile = open(RM_File_data, "w")
BF_flgFile = open(RM_File_flg, "w")
Scale_y = 1
Quant_shift = 0
Bias_y = 0


def POOL ( GBPOOL_dataFile, BF_dataFile, BF_flgFile, Scale_y, Quant_shift, Bias_y ):
    PSUM     = [[ 0 for x in range(16) ] for y in range(16*16)]
    POOL_MEM = [[[ 0 for x in range(16) ] for y in range(16)] for z in range(16) ]
    for i in range(14):
        for j in range(14):
            for chn in range(16):
                PSUM[14*i + j][chn] = int(GBPOOL_dataFile.read(12))
            GBPOOL_dataFile.read(1) # \n
    for i in range(7):
        for j in range(7):
            for x in range(2):
                for y in range(2):
                    for chn in range(16):
                        Output_Quant = PSUM[28*i+4*j+2*x+y][chn]*Scale_y/2**Quant_shift + Bias_y
                        if Output_Quant > 0 :
                            ReLU_tmp = '{:032b}'.format(Output_Quant)
                            ReLU = int(ReLU_tmp[25:32], 2) # 7 bits
                        else:
                            ReLU = 0
                        if POOL_MEM[i][j][chn] < ReLU:
                            POOL_MEM[i][j][chn] = ReLU # pooling
    for i in range(7):
        for j in range(7):
            BF_flg = ''
            for chn in range(16):
                if POOL_MEM[i][j][chn] > 0 :
                    BF_dataFile.write("%4d"%POOL_MEM[i][j][chn])
                    BF_dataFile.write("\n")
                    BF_flg = "1" + BF_flg
                else:
                    BF_flg = "0" + BF_flg
            BF_flgFile.write(BF_flg+"\n")
for cntfrm in range(args.num_frame):
    POOL( GBPOOL_dataFile, BF_dataFile, BF_flgFile, Scale_y, Quant_shift, Bias_y )


Compare = filecmp.cmp(RM_File_data, RTL_File_data)
if Compare == False:
    print('<'*4+' FAIL POOL data Compare '+RM_File_data )
else:
    print('<'*4+' PASS POOL data Compare '+RM_File_data )

Compare = filecmp.cmp(RM_File_flg, RTL_File_flg)
if Compare == False:
    print('<'*4+' FAIL POOL flag Compare '+RM_File_flg )
else:
    print('<'*4+' PASS POOL flag Compare '+RM_File_flg )




