# read column LA_N_9 and LAST_SCK_0

# for i to find LA_N_9 
# LA_N_9 ->LA_N_09 ->LA09_N
# line match
# -*- coding: utf-8 -*- 
import xdrlib ,sys
import xlrd

#根据索引获取Excel表格中的数据   参数:file：Excel文件路径     colnameindex：表头列名所在行的所以  ，by_index：表的索引
def excel_table_byindex(file= 'file.xls',colnameindex=0,by_index=0, xdc_file = 'vc707.xdc'):
    data = open_excel(file)
    table = data.sheets()[by_index]
    nrows = table.nrows #行数
    ncols = table.ncols #列数
    colnames =  table.row_values(colnameindex) #某一行数据 
    list =[]
    for spi_i in range(128):
        for rownum in range(nrows):
            row = table.row_values(rownum)
            if fnmatch(row[1], str(spi_i)):
               FMC_name = row[0]
               FMC_name_sep = FMC_name.split('_')
               FMC_name = 'FMC1_HPC_'+FMC_name_sep[0]+'_'+FMC_name_sep.zfill(2)
               for xdc_line in open():
                    if fnmatch('*get_ports '+FMC_name+'*'+FMC_name_sep[1]+'*', xdc_line)
                        xdc_write = xdc_line.replace(FMC_name+'_'+FMC_name_sep[1], 'IO_IO_spi_data['+str(spi_i)+']')
                        xdc_write = xdc_write.replace(FMC_name+'_'+'CC'+'_'+FMC_name_sep[1], 'IO_IO_spi_data['+str(spi_i)+']')
                        print(xdc_write)

if __name == "__main__":
    excel_table_byindex(xdc_beixin.xlsx)