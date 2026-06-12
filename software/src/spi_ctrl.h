
#include "xil_types.h"
#define NO_SLAVE  1<<1
#define PLL_SLAVE 1<<0
#define DAC_SLAVE 1<<1


uint8_t SPI_Transfer(uint32_t BASEADDR, uint8_t data);
uint32_t SpiPllTransfer(u32 BASEADDR,u32 Data);
void SpiDacTransfer(u32 BASEADDR,u32 Data);
void SpiInit(u32 BASEADDR);
uint32_t SpiAdcTransfer(u32 BASEADDR,u32 Data);
void PllConfiguration();
void DacConfiguartion();

