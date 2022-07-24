import numpy as np
import random
import os

def PEC( REGFLGWEI, REGWEI, REGFLGACT, REGACT,  
         PSUMGB_data, AddrAct, AddrBlockWei,
         Len, NumWei_PEC, NumChn, cntBlk, cntPEC):
    # ***************** PEC **********************************************************
    # Input: actBlk PECMAC_Wei Psum0(accum) PECRAM_DatWr_PEL RAMPEC_DatRd_PEL ; File, Len, NumWei_PEC,cntBlk, frm, PEB,PEC,
    acc = [ [ [0 for x in range (NumWei_PEC)] for y in range(Len)] for z in range(Len)]
    cntwei_chn = [ 0 for x in range(9)]
    for actrow in range(0, Len) :
        for actcol in range(0, Len):
            for j in range(NumWei_PEC):
                cntwei_chn[j] = AddrBlockWei[j]
            for m in range (0, NumChn):
                if( REGFLGACT[ NumChn*Len*Len*cntBlk + NumChn*Len*actrow + NumChn*actcol +m]):
                    act = int(REGACT[AddrAct])
                    AddrAct += 1
                else:
                    act = 0
                for j in range(0, NumWei_PEC): # compute all weight
                    if(REGFLGWEI[9*cntPEC+j][m + NumChn*cntBlk]):
                        wei = int(REGWEI[9*cntPEC+j][cntwei_chn[j]])
                        cntwei_chn[j] += 1
                    else:
                        wei = 0
                    acc[actrow][actcol][j] = acc[actrow][actcol][j] + int(wei*act)
    for j in range(NumWei_PEC):
        AddrBlockWei[j] = cntwei_chn[j]
    for actrow in range(Len):
        for actcol in range(Len):
            if (actrow >= 1 and actrow <= Len -2) and (actcol >= 1 and actcol <= Len -2) : # OFM center region
                PSUMGB_data[actrow][actcol] =  PSUMGB_data[actrow][actcol] + \
                                        acc[actrow-1][actcol-1][0] + acc[actrow-1][actcol+0][1] + acc[actrow-1][actcol+1][2] + \
                                        acc[actrow+0][actcol-1][3] + acc[actrow+0][actcol+0][4] + acc[actrow+0][actcol+1][5] + \
                                        acc[actrow+1][actcol-1][6] + acc[actrow+1][actcol+0][7] + acc[actrow+1][actcol+1][8]  
            else:
                PSUMGB_data[actrow][actcol] = 0

    return PSUMGB_data, AddrAct, AddrBlockWei