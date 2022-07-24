/***************************** Include Files *********************************/
#include <stdio.h>
#include "xscugic.h"
#include "xil_exception.h"
#include "xparameters.h"
#include "xil_io.h"

#include "xsdps.h"      /* SD device driver */
#include "xil_printf.h"
#include "ff.h"
#include "xil_cache.h"
#include "xplatform_info.h"
#include <stdlib.h>

#include "xaxidma.h"
#include "xdebug.h"

#if defined(XPAR_UARTNS550_0_BASEADDR)
#include "xuartns550_l.h"       /* to use uartns550 */
#endif



/************************** Constant Definitions *****************************/
#define TRIGGER_INTR 0x0
#define WAIT_FOR_TRIGGER 0x1
#define INT_CFG0_OFFSET 0x00000C00
#define INT_ID 61 // ????????????????????????

#define INTC_DEVICE_ID XPAR_PS7_SCUGIC_0_DEVICE_ID
#define INT_TYPE_RISING_EDGE 0x03
#define INT_TYPE_HIGHLEVEL 0x01
#define INT_MASK 0x03
#define PS_INTR_ADDRESS 0x43c00000

#define DMA_DEV_ID      XPAR_AXIDMA_0_DEVICE_ID

#ifdef XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR       XPAR_AXI_7SDDR_0_S_AXI_BASEADDR
#elif XPAR_MIG7SERIES_0_BASEADDR
#define DDR_BASE_ADDR   XPAR_MIG7SERIES_0_BASEADDR
#elif XPAR_MIG_0_BASEADDR
#define DDR_BASE_ADDR   XPAR_MIG_0_BASEADDR
#elif XPAR_PSU_DDR_0_S_AXI_BASEADDR
#define DDR_BASE_ADDR   XPAR_PSU_DDR_0_S_AXI_BASEADDR
#endif

#ifndef DDR_BASE_ADDR
#warning CHECK FOR THE VALID DDR ADDRESS IN XPARAMETERS.H, \
         DEFAULT SET TO 0x01000000
#define MEM_BASE_ADDR       0x01000000
#else
#define MEM_BASE_ADDR       (DDR_BASE_ADDR + 0x1000000)
#endif

#define TX_BUFFER_BASE      (MEM_BASE_ADDR + 0x00100000)
#define RX_BUFFER_BASE      (MEM_BASE_ADDR + 0x00300000)
#define RX_BUFFER_HIGH      (MEM_BASE_ADDR + 0x004FFFFF)

#define MAX_PKT_LEN     0x4

#define TEST_START_VALUE    0xC

#define NUMBER_OF_TRANSFERS 10


/************************** Function Prototypes ******************************/
void IntcTypeSetup(XScuGic *InstancePtr, int intId, int intType);
static void WR_intr_Handler(void *param);
static void RD_intr_Handler(void *param);
static int IntcInitFunction(u16 DeviceId);

int Ftf_init();
int FfsSd_Write(u32 write_addr_offset, u32 FileSize);
int FfsSd_Read(u32 read_addr_offset, u32 FileSize);


int XAxiDma_Rx_from_FIFO(u16 DeviceId, u32 data_size, u32 write_addr_offset);
int XAxiDma_Tx_to_FIFO(u16 DeviceId, u8* SD_data);

#if (!defined(DEBUG))
extern void xil_printf(const char *format, ...);
#endif





/************************** Variable Definitions *****************************/
static int Write_SD_Flag;
static int Read_SD_Flag;
static XScuGic INTCInst;
static FIL fil;     /* File object */
static FATFS fatfs;
static u8 *TxBufferPtr;
static u8 *RxBufferPtr;
//==============================================================================
// VC707 :
//==============================================================================
static int Intr_Flag;
static u8 PS_config;
static u32 FileSize;

/*
 * To test logical drive 0, FileName should be "0:/<File name>" or
 * "<file_name>". For logical drive 1, FileName should be "1:/<file_name>"
 */
static char FileName_wr[32] = "Test_wr.bin";
static char FileName_rd[32] = "Test_wr.bin";
static char *SD_File;
u32 Platform;

#ifdef __ICCARM__
#pragma data_alignment = 32
u8 DestinationAddress[10*1024*1024];
u8 SourceAddress[10*1024*1024];
#pragma data_alignment = 4
#else
u8 DestinationAddress[10*1024*1024] __attribute__ ((aligned(32)));
u8 SourceAddress[10*1024*1024] __attribute__ ((aligned(32)));
#endif

#define TEST 7

XAxiDma AxiDma;

void IntcTypeSetup(XScuGic *InstancePtr, int intId, int intType){
    int mask;
    intType &= INT_MASK;
    mask = XScuGic_DistReadReg(InstancePtr, INT_CFG0_OFFSET + (intId/16)*4);
    mask &= ~(INT_MASK << (intId%16)*2);
    mask |= intType << ((intId%16)*2);
    XScuGic_DistWriteReg(InstancePtr, INT_CFG0_OFFSET + (intId/16)*4, mask);
}

static void Intr_Config_Handler(void *param){
    PS_config = Xil_In32(PS_INTR_ADDRESS) & 0x0f; // 4-bit config
    xil_printf("<<<<< Config interrupt :%d\n\r", PS_config);
    Intr_Flag = 1;
}

int IntcInitFunction(u16 DeviceId){
    XScuGic_Config *IntcConfig;
    int status;
    // Interrupt controller initialization
    IntcConfig = XScuGic_LookupConfig(DeviceId);
    status = XScuGic_CfgInitialize(&INTCInst, IntcConfig, IntcConfig->CpuBaseAddress);
    if(status != XST_SUCCESS) return XST_FAILURE;
    // Call to interrupt setup
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &INTCInst);
    Xil_ExceptionEnable();
    // Connect SW1~SW3 interrupt to handler
    status = XScuGic_Connect(&INTCInst, INT_ID, (Xil_ExceptionHandler)Intr_Config_Handler, &INTCInst);
    if(status != XST_SUCCESS) return XST_FAILURE;
    // Set interrupt type of SW1~SW3 to rising edge
    XScuGic_SetPriorityTriggerType(&INTCInst, INT_ID, 0xa0, 0x3);
    // Enable SW1~SW3 interrupts in the controller
    XScuGic_Enable(&INTCInst, INT_ID);
    return XST_SUCCESS;
}

int Ftf_init(){
    FRESULT Res;

    /*
     * To test logical drive 0, Path should be "0:/"
     * For logical drive 1, Path should be "1:/"
     */
    TCHAR *Path = "0:/";

    /*
     * Register volume work area, initialize device
     */
    Res = f_mount(&fatfs, Path, 0);
    if (Res) {
        return XST_FAILURE;
    }
    return XST_SUCCESS;
}

int FfsSd_Read(u32 read_addr_offset, u32 FileSize)
{
    FRESULT Res;
    UINT NumBytesRead;
    // u32 FileSize = (4);

    Platform = XGetPlatform_Info();
    if (Platform == XPLAT_ZYNQ_ULTRA_MP) {
        /*
         * Since 8MB in Emulation Platform taking long time, reduced
         * file size to 8KB.
         */
        FileSize = 8*1024;
    }

    /*
     * Open file with required permissions.
     * Here - Creating new file with read/write permissions. .
     * To open file with write permissions, file system should not
     * be in Read Only mode.
     */
    SD_File = (char *)FileName_rd;

    Res = f_open(&fil, SD_File, FA_READ);
    if (Res) {
        return XST_FAILURE;
    }

    /*
     * Pointer to beginning of file .
     */
    Res = f_lseek(&fil, read_addr_offset * 4);//8 * u8
    if (Res) {
        return XST_FAILURE;
    }

    /*
     * Read data from file.
     */
    Res = f_read(&fil, (void*)DestinationAddress, FileSize,
            &NumBytesRead);
    if (Res) {
        return XST_FAILURE;
    }

    for(int BuffCnt = 0; BuffCnt < FileSize; BuffCnt++){
        // DestinationAddress[BuffCnt] = *(RxBufferPtr + 4 * read_addr_offset + BuffCnt);
        xil_printf("%x\r\n", DestinationAddress[BuffCnt]);
    }

    /*
     * Close file.
     */
    Res = f_close(&fil);
    if (Res) {
        return XST_FAILURE;
    }
    // return DestinationAddress;
    return XST_SUCCESS;
}

int FfsSd_Write(u32 write_addr_offset, u32 FileSize)
{
    FRESULT Res;
    UINT NumBytesWritten;
    u32 BuffCnt;
    // u32 FileSize = (1);

    Platform = XGetPlatform_Info();
    if (Platform == XPLAT_ZYNQ_ULTRA_MP) {
        /*
         * Since 8MB in Emulation Platform taking long time, reduced
         * file size to 8KB.
         */
        FileSize = 8*1024;
    }

    for(BuffCnt = 0; BuffCnt < FileSize * 4; BuffCnt++){
        SourceAddress[BuffCnt] = *(RxBufferPtr + 4 * write_addr_offset + BuffCnt);
        xil_printf("%x\r\n", SourceAddress[BuffCnt]);
    }

    /*
     * Open file with required permissions.
     * Here - Creating new file with read/write permissions. .
     * To open file with write permissions, file system should not
     * be in Read Only mode.
     */
    SD_File = (char *)FileName_wr;

    Res = f_open(&fil, SD_File, FA_OPEN_ALWAYS | FA_WRITE);
    if (Res) {
        return XST_FAILURE;
    }

    /*
     * Pointer to beginning of file .
     */
    Res = f_lseek(&fil, write_addr_offset * 4);//write_addr_offset * 4 * u8
    if (Res) {
        return XST_FAILURE;
    }

    /*
     * Write data to file.
     */
    Res = f_write(&fil, (const void*)SourceAddress, FileSize * 4,
         &NumBytesWritten);
    if (Res) {
     return XST_FAILURE;
    }

    /*
     * Close file.
     */
    Res = f_close(&fil);
    if (Res) {
        return XST_FAILURE;
    }
    return XST_SUCCESS;
}

int XAxiDma_Rx_from_FIFO(u16 DeviceId, u32 data_size, u32 write_addr_offset)
{
    XAxiDma_Config *CfgPtr;
    int Status;

    RxBufferPtr = (u32 *)RX_BUFFER_BASE;

    /* Initialize the XAxiDma device.
     */
    CfgPtr = XAxiDma_LookupConfig(DeviceId);
    if (!CfgPtr) {
        xil_printf("No config found for %d\r\n", DeviceId);
        return XST_FAILURE;
    }

    Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
    if (Status != XST_SUCCESS) {
        xil_printf("Initialization failed %d\r\n", Status);
        return XST_FAILURE;
    }

    if(XAxiDma_HasSg(&AxiDma)){
        xil_printf("Device configured as SG mode \r\n");
        return XST_FAILURE;
    }

    /* Disable interrupts, we use polling mode
     */
    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
                        XAXIDMA_DEVICE_TO_DMA);

    /* Flush the SrcBuffer before the DMA transfer, in case the Data Cache
     * is enabled
     */
    Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, data_size * 4);

    Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) (RxBufferPtr + write_addr_offset * 4),
               data_size * 4, XAXIDMA_DEVICE_TO_DMA);
    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    while ((XAxiDma_Busy(&AxiDma,XAXIDMA_DEVICE_TO_DMA))) {
                   /* Wait */
        }

    /* Test finishes successfully
     */
    return XST_SUCCESS;
}

int XAxiDma_Tx_to_FIFO(u16 DeviceId, u8* SD_data)
{
    XAxiDma_Config *CfgPtr;
    int Status;
    int Index;
    u8 *TxBufferPtr;

    TxBufferPtr = (u8 *)TX_BUFFER_BASE;

    /* Initialize the XAxiDma device.
     */
    CfgPtr = XAxiDma_LookupConfig(DeviceId);
    if (!CfgPtr) {
        xil_printf("No config found for %d\r\n", DeviceId);
        return XST_FAILURE;
    }

    Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
    if (Status != XST_SUCCESS) {
        xil_printf("Initialization failed %d\r\n", Status);
        return XST_FAILURE;
    }

    if(XAxiDma_HasSg(&AxiDma)){
        xil_printf("Device configured as SG mode \r\n");
        return XST_FAILURE;
    }

    /* Disable interrupts, we use polling mode
     */
    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,
                        XAXIDMA_DMA_TO_DEVICE);


    for(Index = 0; Index < MAX_PKT_LEN; Index ++) {
            TxBufferPtr[Index] = *(SD_data + Index);
    }
    /* Flush the SrcBuffer before the DMA transfer, in case the Data Cache
     * is enabled
     */
    Xil_DCacheFlushRange((UINTPTR)TxBufferPtr, MAX_PKT_LEN);
#ifdef __aarch64__
    Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, MAX_PKT_LEN);
#endif

    Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR) TxBufferPtr,
                MAX_PKT_LEN, XAXIDMA_DMA_TO_DEVICE);

    if (Status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    while ((XAxiDma_Busy(&AxiDma,XAXIDMA_DMA_TO_DEVICE))) {
                            /* Wait */
                    }

    /* Test finishes successfully
     */
    return XST_SUCCESS;
}

int main(void){
    int Status_DDR_wr;
    int Status_SD_wr;

    int Status_DDR_rd;
    int Status_SD_rd;
    Intr_Flag = WAIT_FOR_TRIGGER;
    PS_config = 0;

    u32 write_addr_offset[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    u32 read_addr_offset[16]  = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    u32 data_size = 0;

    xil_printf("PL interrupt test start \n\r");
    IntcInitFunction(INTC_DEVICE_ID);
    Ftf_init();

//==============================================================================
// Processing :
//==============================================================================
    while (1){
        if (Intr_Flag == TRIGGER_INTR){

            if (PS_config == 2 || PS_config == 4){
                //==============================================================================
                // Write from FIFO to SD
                if (PS_config == 2){
                    FileName_wr = "pool_flag.bin";
                } else {
                    FileName_wr = "pool_data.bin";
                }
                data_size = 64 * 4;

                XScuGic_Disable(&INTCInst, INT_ID);

                Status_DDR_wr = XAxiDma_Rx_from_FIFO(DMA_DEV_ID, data_size, write_addr_offset[PS_config]);
                if (Status_DDR_wr != XST_SUCCESS) {
                    xil_printf("XAxiDma_SimplePoll Example Failed\r\n");
                    return XST_FAILURE;
                }
                xil_printf("FIFO data send to DMA successfully! \r\n");

                Status_SD_wr = FfsSd_Write(write_addr_offset[PS_config],data_size );
                if (Status_SD_wr != XST_SUCCESS) {
                    xil_printf("SD Polled File System Example Test failed \r\n");
                    return XST_FAILURE;
                }
                xil_printf("Write data to SD successfully! \r\n");

                write_addr_offset[PS_config] = write_addr_offset[PS_config] + data_size;
                Intr_Flag = WAIT_FOR_TRIGGER;
                PS_config = 0;
                XScuGic_Enable(&INTCInst, INT_ID);

            } else {
                //==============================================================================
                // Read from SD to FIFO
                if (PS_config == 7){
                    FileName_rd = "wei_addr.bin";
                    data_size = 54*4; // *128/32
                } else if (PS_config == 9){
                    FileName_rd = "wei_data.bin";
                    data_size = 512 * 4;
                } else if (PS_config == 11){
                    FileName_rd = "wei_flag.bin";
                    data_size = 512 * 4;
                } else if (PS_config == 13){
                    FileName_rd = "act_data.bin";
                    data_size = 512 * 4;
                } else if (PS_config == 15){
                    FileName_rd = "act_flag.bin";
                    data_size = 512 * 4;
                } else {
                    xil_printf("<<<<<< ERROR : PS_config is illegal ! >>>>>>\r\n");
                    return 0;
                }

                // Disable Interrupt
                XScuGic_Disable(&INTCInst, INT_ID); // RD_INT_ID = ??????? vc707

                Status_SD_rd = FfsSd_Read(read_addr_offset[PS_config], data_size);
                if (Status_SD_rd != XST_SUCCESS) {
                    xil_printf("SD Polled File System Example Test failed \r\n");
                    return XST_FAILURE;
                }
                xil_printf("Read data from SD successfully! \r\n");

                Status_DDR_rd = XAxiDma_Tx_to_FIFO(DMA_DEV_ID, DestinationAddress);
                if (Status_DDR_rd != XST_SUCCESS) {
                    xil_printf("XAxiDma_SimplePoll Example Failed\r\n");
                    return XST_FAILURE;
                }
                xil_printf("Write date to FIFO successfully! \r\n");

                read_addr_offset[PS_config] = read_addr_offset[PS_config] + data_size;
                Intr_Flag = WAIT_FOR_TRIGGER;
                PS_config = 0;
                XScuGic_Enable(&INTCInst, INT_ID);
            }

        }

    };
    return 0;
}
