import torch 
import numpy as np 
import os
# import heapq
# from Function_self import Function_self
def WRITE_BACK( File, NumCol, NumChar, data, cnt_wr, temp ):
    if NumChar == 4:
        data = hex(data & 0xffff) # signed
    else:
        data = hex(data & 0xff) # signed
    # data = hex(data) # signed
    temp = str(data).lstrip('0x').rstrip('L').zfill(NumChar) + temp
    cnt_wr += 1

    if cnt_wr % (NumCol/NumChar) == 0:
        File.write(temp + '\n')
        temp = ''
    return cnt_wr, temp

def tensor_to_file_act(extract_dir, dequant_dir, name,tensor, type, mode,scale, theshold):

    print("activation theshold:", name, theshold)
    fp_flag_bin_wr = open(os.path.join(dequant_dir)+'/'+name+'_flag_bin.dat','w')
    fp_float_rd = open(os.path.join(extract_dir)+'/'+name+'_float.dat','r')

    array_shape = (tensor.cpu()).numpy()
    shape = array_shape.shape
    str_row = ''
    cnt_col = 0

    str_flgbyte = ''
    str_flgword = ''
    cnt_flgbit = 0
    cnt_flgbyte = 0
    cnt_sparsity = 0
    cnt_sparsity_delta_all = 0
    cnt_sparsity_delta = 0
    cnt_sparsity_delta_th = 0
    height_array = range(shape[3])
    if type == 'wei':
        height_array = height_array[::-1] # reverse for weight

    ACT_DECfile = open("act_dec.txt",'w')
    for patch in range(16):
        cnt_element = 0
        cnt_element_flag = 0
        cnt_wr_data = 0
        cnt_wr_flag = 0
        temp_data = ''
        temp_flag = ''
        fp_data_wr = open(os.path.join(dequant_dir)+'/'+'dataact_L00_P0'+str(patch)+'.txt','w') # activation for delta
        fp_flag_wr = open(os.path.join(dequant_dir)+'/'+'flagact_L00_P0'+str(patch)+'.txt','w')
        for frame in range(shape[2]):
        # for frame in range(7):
            for block in range(int(shape[1]/32)):
                for H in range(16):
                    for W in range(16):
                        for chn in range(32):
                            tmp = chn % 2 # 010101
                            ACT_DECfile.write(str(tmp))
                            ACT_DECfile.write('\n')
                            if abs(tmp) >= theshold :
                                cnt_element += 1
                                flag = 1
                                cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, tmp, cnt_wr_data, temp_data)
                            else:
                                flag = 0
                            cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
                            cnt_element_flag += 1
        for zero_pad in range( (16*512) - cnt_element%(16*512) ):
            tmp = 0
            cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, tmp, cnt_wr_data, temp_data)
        for zero_pad_flag in range( (128*512) - cnt_element_flag%(128*512) ):
            flag = 0
            cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)

    cnt_element = 0
    cnt_element_flag = 0
    cnt_wr_data = 0
    cnt_wr_flag = 0
    temp_data = ''
    temp_flag = ''
    fp_data_wr = open(os.path.join(dequant_dir)+'/'+'dataact_L00'+'.txt','w') # activation for delta
    fp_flag_wr = open(os.path.join(dequant_dir)+'/'+'flagact_L00'+'.txt','w')           
    for patch in range(4):
        for frame in range(shape[2]):
        # for frame in range(7):
            for block in range(int(shape[1]/32)):
                for H in range(16):
                    for W in range(16):
                        for chn in range(32):
                            tmp = tmp = chn % 2 # 010101
                            if abs(tmp) >= theshold :
                                cnt_element += 1
                                flag = 1
                                cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, tmp, cnt_wr_data, temp_data)
                            else:
                                flag = 0
                            cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
                            cnt_element_flag += 1
    print('Number of SRAM block:', cnt_element/(16*512),'rest:',cnt_element%(16*512))
    for zero_pad in range( (16*512) - cnt_element%(16*512) ):
        tmp = 0
        cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, tmp, cnt_wr_data, temp_data)
    for zero_pad_flag in range( (128*512) - cnt_element_flag%(128*512) ):
        flag = 0
        cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)

def tensor_to_file_wei(extract_dir,dequant_dir,name,tensor, type, mode,scale, theshold):
    # try:
        print("weight theshold:", name, theshold)
        if mode == 'extract':
            fp_float_wr = open(os.path.join(extract_dir)+'/'+name+'_float.dat','w')
        elif mode == 'dequant':
            # dequant_dir = 'Extract/dequant/prune_quant_sense/dequant'
            # fp_data_wr = open(os.path.join(dequant_dir)+'/'+name+'_data.dat','w') # activation for delta
            #fp_data_delta_wr = open(name+'_data_delta.dat','w')
            # fp_flag_wr = open(os.path.join(dequant_dir)+'/'+name+'_flag.dat','w')
            #fp_flag_delta_wr = open(name+'_flag_delta.dat','w')
            fp_flag_bin_wr = open(os.path.join(dequant_dir)+'/'+name+'_flag_bin.dat','w')
            fp_float_rd = open(os.path.join(extract_dir)+'/'+name+'_float.dat','r')
        
        array_shape = (tensor.cpu()).numpy()
        shape = array_shape.shape
        str_row = ''
        cnt_col = 0

        str_flgbyte = ''
        str_flgword = ''
        cnt_flgbit = 0
        cnt_flgbyte = 0
        cnt_sparsity = 0
        cnt_sparsity_delta_all = 0
        cnt_sparsity_delta = 0
        cnt_sparsity_delta_th = 0
        height_array = range(shape[3])
 
        for patch in range(int(shape[0]/16)): # ftrgrp
            cnt_element = 0
            cnt_element_flag = 0
            cnt_wr_data = 0
            cnt_wr_flag = 0
            cnt_wr_addrwei = 0
            temp_addrwei = ''
            temp_data = ''
            temp_flag = ''
            fp_data_wr = open(os.path.join(dequant_dir)+'/'+'datawei_L00_F0'+str(patch)+'.txt','w') # activation for delta
            fp_flag_wr = open(os.path.join(dequant_dir)+'/'+'flagwei_L00_F0'+str(patch)+'.txt','w')
            fp_addrwei_wr = open(os.path.join(dequant_dir)+'/'+'addrwei_L00_F0'+str(patch)+'.txt','w')
            cnt_wr_addrwei, temp_addrwei= WRITE_BACK(fp_addrwei_wr, 32, 4, int(cnt_element/16), cnt_wr_addrwei, temp_addrwei)
            for weight in range(16):
                for frame in range(shape[2]):
                # for block in range(int(shape[1]/32)):
                    for H in range(shape[4]):
                        for W in range(shape[3]):
                            for chn in range(shape[1]):
                                Sort_index = CntWeiNotZero_FtrGrp_Sort_index[weight + 16*patch]
                                tmp = int(array[Sort_index][chn][frame][H][W])
                                if abs(tmp) >= theshold :
                                    cnt_element += 1
                                    flag = 1
                                    cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, tmp, cnt_wr_data, temp_data)
                                else:
                                    flag = 0
                                cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
                                cnt_element_flag += 1
            cnt_wr_addrwei, temp_addrwei= WRITE_BACK(fp_addrwei_wr, 32, 4, int(cnt_element/16), cnt_wr_addrwei, temp_addrwei)
            for zero_pad in range( (12*512) - cnt_element%(12*512) ):
                tmp = 0
                cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, tmp, cnt_wr_data, temp_data)
            for zero_pad_flag in range( (128*512) - cnt_element_flag%(128*512) ):
                flag = 0
                cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)

        cnt_element = 0
        cnt_element_flag = 0
        cnt_wr_data = 0
        cnt_wr_flag = 0
        cnt_wr_addrwei = 0
        temp_addrwei = ''
        temp_data = ''
        temp_flag = ''

        fp_data_wr = open(os.path.join(dequant_dir)+'/'+'datawei_L00'+'.txt','w') # activation for delta
        fp_flag_wr = open(os.path.join(dequant_dir)+'/'+'flagwei_L00'+'.txt','w')
        fp_addrwei_wr = open(os.path.join(dequant_dir)+'/'+'addrwei_L00'+'.txt','w')
        for patch in range(int(shape[0]/16)): # ftrgrp
            addr_element =0
            # cnt_wr_addrwei, temp_addrwei= WRITE_BACK(fp_addrwei_wr, 32, 4, addr_element, cnt_wr_addrwei, temp_addrwei)
            for weight in range(16): # [73, 67, 17, 4, 83, 25, 52, 126, 37, 41, 68, 127, 123, 49, 49, 36, 120, 13, 44, 90, 30, 42, 42, 42, 63, 5, 5, 28, 28, 21, 21, 114, 54, 54, 75, 23, 19, 16, 110, 87, 91, 12, 70, 53, 58, 69, 31, 31, 31, 8, 38, 34, 85, 92, 105, 100, 32, 39, 39, 39, 80, 20, 111, 97, 15, 35, 64, 27, 46, 26, 26, 2, 14, 43, 43, 71, 0, 3, 3, 57, 33, 106, 106, 24, 81, 82, 78, 47, 59, 103, 65, 65, 10, 10, 10, 74, 56, 56, 56, 60, 122, 101, 1, 94, 6, 66, 93, 9, 48, 29, 7, 22, 115, 112, 109, 108, 96, 40, 119, 51, 124, 62, 55, 11, 11, 18, 77, 61]
                for frame in range(shape[2]):
                # for block in range(int(shape[1]/32)):
                    for H in range(shape[4]):
                        for W in range(shape[3]):
                            cnt_wr_addrwei, temp_addrwei= WRITE_BACK(fp_addrwei_wr, 32, 4, int(addr_element/16), cnt_wr_addrwei, temp_addrwei)
                            for chn in range(shape[1]):
                                Sort_index = weight + 16*patch
                                # Sort_index = CntWeiNotZero_FtrGrp_Sort_index[weight + 16*patch]
                                tmp = chn % 2 # 010101
                                if abs(tmp) >= theshold :
                                    cnt_element += 1
                                    addr_element += 1
                                    flag = 1
                                    cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, tmp, cnt_wr_data, temp_data)
                                else:
                                    flag = 0
                                cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
                                cnt_element_flag += 1
                for chn in range(shape[1]): # 28 weight flag
                    flag = 0
                    cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
                    cnt_element_flag += 1
            print('Number of SRAM block:', cnt_element/(16*512),'rest:',cnt_element%(16*512))
            for zero_pad in range( (16*512) - cnt_element%(16*512) ):
                tmp = 0
                cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, tmp, cnt_wr_data, temp_data)
            cnt_element += (16*512) - cnt_element%(16*512)
            for zero_pad_flag in range( (128*512) - cnt_element_flag%(128*512) ):
                flag = 0
                cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
            cnt_element_flag += (128*512) - cnt_element_flag%(128*512)
        # return
        # return np.array(array_origin)
        if mode == 'dequant':
            print('sparsity:',(1-float(cnt_sparsity)/float(shape[0]*shape[1]*shape[2]*shape[3]*shape[4]))*100)
            print('sparsity_delta_all:',(1-float(cnt_sparsity_delta_all)/float(shape[0]*shape[1]*shape[2]*shape[3]*shape[4]))*100)
            print('sparsity_delta:',(1-float(cnt_sparsity_delta)/float(shape[0]*shape[1]*shape[2]*shape[3]*shape[4]))*100)
            # only delta frame has theshold
            print('sparsity_delta_th:',(1-float(cnt_sparsity_delta_th)/float(shape[0]*shape[1]*shape[2]*shape[3]*shape[4]))*100)
            return

net = 'conv2'
tensor = torch.ones([8,  64, 16,  56,  56])
scale = 1
tensor_to_file_act(extract_dir='', dequant_dir='.', \
        name='Activation_'+str(0)+'_'+net,tensor=tensor,type='act',mode='dequant', scale=scale, theshold=1) # >= theshold


    
