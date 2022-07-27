#--coding:utf-8--
import torch 
import numpy as np 
import os
import random
import math
from gen_coe import cls_gen_coe

def WRITE_BACK( File, NumCol, NumChar, data, cnt_wr, temp ):
    if NumChar == 4:
        data = hex(data & 0xffff) # signed
    elif NumChar == 2: 
        data = hex(data & 0xff) # signed
    else:
        data = data
    # data = hex(data) # signed
    temp = str(data).lstrip('0x').rstrip('L').zfill(NumChar) + temp
    cnt_wr += 1

    if cnt_wr % (NumCol/NumChar) == 0:
        if NumChar == 1:
            temp = hex(int(temp,2)).lstrip('0x').rstrip("L").zfill(32)
        File.write(temp + '\n')
        temp = ''
    return cnt_wr, temp

def tensor_to_file_act(output_dir, tensor,threshold):

    array_shape = (tensor.cpu()).numpy()
    shape = array_shape.shape

    cnt_element = 0
    cnt_element_flag = 0
    cnt_wr_data = 0
    cnt_wr_flag = 0
    temp_data = ''
    temp_flag = ''
    fp_data_wr = open(os.path.join(output_dir)+'/'+'dataact_L00'+'.txt','w') # activation for delta
    fp_flag_wr = open(os.path.join(output_dir)+'/'+'flagact_L00'+'.txt','w') 
    fp_info = open(os.path.join(output_dir)+'/'+'config'+'.txt','w') 
    # Num_patch =  (math.ceil(shape[3]/16.0))* (math.ceil(shape[4]/16.0))
    Num_patch_H = math.ceil(shape[3]/16.0)
    Num_patch_W = math.ceil(shape[4]/16.0)
    Num_patch = Num_patch_H * Num_patch_W
    Num_frame = shape[2]
    Num_block = math.ceil(shape[1]/32)
    tensor = torch.nn.functional.pad(torch.where(abs(tensor)>=threshold, tensor + 1, torch.zeros(shape).to(tensor.device)), (0, 16*math.ceil(shape[4]/16)-shape[4], 0, 16*math.ceil(shape[3]/16) - shape[3], \
        0, math.ceil(shape[2]/1)-shape[2], 0, 32*math.ceil(shape[1]/32)-shape[1] ) )
    array_shape = (tensor.cpu()).detach().numpy()

    for patch_h in range(Num_patch_H):
        for patch_w in range(Num_patch_W):
            for frame in range(Num_frame):
                for block in range(Num_block):
                    for H in range(16):
                        for W in range(16):
                            for chn in range(32):
                                tmp = array_shape[0][chn + 32*block][frame][H + 16*patch_h][W + 16*patch_w]
                                if abs(tmp) > 1 :
                                    cnt_element += 1
                                    flag = 1
                                    cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, int(tmp), cnt_wr_data, temp_data)
                                else:
                                    flag = 0
                                cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
                                cnt_element_flag += 1
    print("\n Actvation array_shape" + str(tensor.shape) )
    Activation_Sparsity =1 - float(cnt_element)/(Num_patch*Num_frame*Num_block*16*16*32)
    print("\nActivation Sparsity: "+str(Activation_Sparsity))
    fp_info.write("\nActivation Sparsity: "+str(Activation_Sparsity))
    fp_info.write("\nconfig CFGCCU_num_patch = "+str(Num_patch -1))
    fp_info.write("\nconfig CFGCCU_num_frame = "+str(Num_frame -1))
    fp_info.write("\nconfig CFGCCU_num_block = "+str(Num_block -1))
    numblk_flaact = math.ceil(Num_patch*Num_frame*Num_block*16*16*32/(128*512))
    fp_info.write('\nconfig CFGGB_num_alloc/total_flgact = ' + str(numblk_flaact)+'rest:'+str(Num_patch*Num_frame*Num_block*16*16*32%(128*512)))
    numblk_act = math.ceil(cnt_element/(16*512))
    fp_info.write('\nconfig CFGGB_num_alloc/total_act    = '+ str(numblk_act)+'rest:'+str(cnt_element%(16*512)))
    fp_info.write('\nconfig CFGGB_num_loop_wei = '+str(Num_frame))
    for zero_pad in range( (16*512) - cnt_element%(16*512) ):
        cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, 0, cnt_wr_data, temp_data)
    for zero_pad_flag in range( (128*512) - cnt_element_flag%(128*512) ):
        flag = 0
        cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
    return numblk_flaact, numblk_act, Num_patch, Num_frame, Num_block

def tensor_to_file_wei(output_dir,tensor, threshold):

    array_shape = (tensor.cpu()).detach().numpy()
    shape = array_shape.shape

    cnt_element = 0
    cnt_element_flag = 0
    cnt_wr_data = 0
    cnt_wr_flag = 0
    cnt_wr_addrwei = 0
    temp_addrwei = ''
    temp_data = ''
    temp_flag = ''

    cnt_sparsity = 0

    fp_data_wr = open(os.path.join(output_dir)+'/'+'datawei_L00'+'.txt','w') # activation for delta
    fp_flag_wr = open(os.path.join(output_dir)+'/'+'flagwei_L00'+'.txt','w')
    fp_addrwei_wr = open(os.path.join(output_dir)+'/'+'addrwei_L00'+'.txt','w')
    fp_info = open(os.path.join(output_dir)+'/'+'config'+'.txt','a') 

    for patch in range(int(shape[0]/16.0)): # ftrgrp
        addr_element =0
        for weight in range(16): # [73, 67, 17, 4, 83, 25, 52, 126, 37, 41, 68, 127, 123, 49, 49, 36, 120, 13, 44, 90, 30, 42, 42, 42, 63, 5, 5, 28, 28, 21, 21, 114, 54, 54, 75, 23, 19, 16, 110, 87, 91, 12, 70, 53, 58, 69, 31, 31, 31, 8, 38, 34, 85, 92, 105, 100, 32, 39, 39, 39, 80, 20, 111, 97, 15, 35, 64, 27, 46, 26, 26, 2, 14, 43, 43, 71, 0, 3, 3, 57, 33, 106, 106, 24, 81, 82, 78, 47, 59, 103, 65, 65, 10, 10, 10, 74, 56, 56, 56, 60, 122, 101, 1, 94, 6, 66, 93, 9, 48, 29, 7, 22, 115, 112, 109, 108, 96, 40, 119, 51, 124, 62, 55, 11, 11, 18, 77, 61]
            for frame in range(shape[2]):
                for H in range(shape[3]):
                    for W in range(shape[4]):
                        cnt_wr_addrwei, temp_addrwei= WRITE_BACK(fp_addrwei_wr, 32, 4, int(addr_element/16), cnt_wr_addrwei, temp_addrwei)
                        for chn in range(shape[1]):
                            tmp = int(array_shape[weight + 16*patch][chn][frame][H][W])
                            if abs(tmp) > 0:
                                cnt_element += 1
                                cnt_sparsity += 1
                                addr_element += 1
                                flag = 1
                                cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, tmp, cnt_wr_data, temp_data)
                            else:
                                flag = 0
                            cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
                            cnt_element_flag += 1
            for chn in range(shape[1]): # pad to 28 weight flag
                flag = chn % 2
                cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
                cnt_element_flag += 1

        for zero_pad in range( (16*512) - cnt_element%(16*512) ):
            tmp = 0
            cnt_wr_data, temp_data= WRITE_BACK(fp_data_wr, 32, 2, tmp, cnt_wr_data, temp_data)
        cnt_element += (16*512) - cnt_element%(16*512)
        for zero_pad_flag in range( (128*512) - cnt_element_flag%(128*512) ):
            flag = 0
            cnt_wr_flag, temp_flag = WRITE_BACK(fp_flag_wr, 128,1, flag, cnt_wr_flag, temp_flag)
        cnt_element_flag += (128*512) - cnt_element_flag%(128*512)
    print("\n Weight array_shape" + str(array_shape.shape))
    Weight_Sparsity = 1 - float(cnt_sparsity)/(shape[4]*shape[3]*shape[2]*shape[1]*shape[0])
    print("\nWeight Sparsity: "+str(Weight_Sparsity))
    fp_info.write("\nWeight Sparsity: "+str(Weight_Sparsity))
    numblk_weiaddr = int(shape[0]/16.0)
    fp_info.write("\nNumBlk_weiaddr = " + str(numblk_weiaddr))
    fp_info.write("\nconfig CFGCCU_num_ftrgrp = " + str(int(shape[0]/16.0) -1))
    numblk_flgwei = math.ceil(shape[4]*shape[3]*shape[2]*shape[1]*shape[0]/(128*512))
    fp_info.write('\nconfig CFGGB_num_alloc/total_flgwei = '+str(numblk_flgwei)+'rest:'+str(shape[4]*shape[3]*shape[2]*shape[1]*shape[0]%(128*512)))
    numblk_wei = math.ceil(cnt_element/(16*512))
    fp_info.write('\nconfig CFGGB_num_alloc/total_wei = ' + str(numblk_wei)+'rest:'+str(cnt_element%(16*512)))
    fp_info.write('\nconfig CFGGB_num_loop_act = '+ str(int(shape[0]/16.0)))
    return numblk_weiaddr, numblk_flgwei, numblk_wei, int(shape[0]/16.0)

random.seed(000)


def torch_random_int(mean, std, size):
    return torch.round( torch.from_numpy(np.random.normal(loc =mean , scale= std,size = size)) ).to(torch.float32)

# AlexNet
dict = {
#         'conv1'     :{'activation':torch.abs(torch_random_int(mean =0.0 , std= 1,size = (1, 3, 1, 16, 16))), 'weight': torch_random_int(mean =0.0 , std= 3,size = (96,  3, 3, 3, 3))} # 0.3818
#         'conv2'     :{'activation':torch.abs(torch_random_int(mean =0.0 , std= 1.8,size = (1,  96,  1,  16,  16))), 'weight': torch_random_int(mean =0.0 , std= 0.22,size = (96, 96, 3, 3, 3))} # tmp>1 of act
#         'conv3'     :{'activation':torch.abs(torch_random_int(mean =0.0 , std= 0.7,size = (1, 256,  1,  16,  16))), 'weight': torch_random_int(mean =0.0 , std= 0.21,size = (64,256, 3, 3, 3))} # tmp>1 of act
#         'conv4'     :{'activation':torch.abs(torch_random_int(mean =0.0 , std= 0.7,size = (1, 384,  1,  16,  16))), 'weight': torch_random_int(mean =0.0 , std= 0.23,size = (32,384, 3, 3, 3))} # tmp>1 of act
        'conv5'     :{'activation':torch.abs(torch_random_int(mean =0.0 , std= 0.68,size = (1, 384,  1,  16,  16))), 'weight': torch_random_int(mean =0.0 , std= 0.235,size = (32,384, 3, 3, 3))} # tmp>1 of act

        }


for case, params in dict.items():
    discrete_dir = os.path.join('output', 'alexnet', case, 'discrete')
    if not os.path.exists(discrete_dir):
        os.makedirs(discrete_dir)
    
    # tensor = torch.ones([8,  64, 16,  14,  14])
    # [B, C, T, H, W]
    print("activation shape: {}".format(params['activation'].size()))
    print(params['activation'][0, 0, 0, 10, 0: 10])
    numblk_flgact, numblk_act, Num_patch, Num_frame, Num_block = tensor_to_file_act(output_dir=discrete_dir,tensor=params['activation'], threshold=0) # >= theshold

    # tensor = torch.ones([32, 64, 3, 3, 3 ])
    # [CI, CO, D, R, S]
    print("weight shape: {}".format(params['weight'].size()))
    print(params['activation'][0, 0, 0, 0:3, 0: 3])
    numblk_weiaddr, numblk_flgwei, numblk_wei, num_ftrgrp = tensor_to_file_wei(output_dir=discrete_dir, tensor=params['weight'], threshold=0)
    ROM_dir = os.path.join('output', 'alexnet', case, 'ROM')
    if not os.path.exists(ROM_dir):
        os.makedirs(ROM_dir)
    cls_gen_coe(discrete_dir, ROM_dir).func_gen_coe(numblk_weiaddr, numblk_flgwei, numblk_wei, numblk_flgact, numblk_act, \
        CFGCCU_num_layer = 0, CFGCCU_num_patch = Num_patch-1, CFGCCU_num_ftrgrp= num_ftrgrp-1, CFGCCU_num_frame = Num_frame-1, CFGCCU_num_block = Num_block-1)
    print(numblk_weiaddr, numblk_flgwei, numblk_wei, numblk_flgact, numblk_act)
