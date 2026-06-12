

#include "spi_ctrl.h"
#include "xuartns550_l.h"
#include "xspi_l.h"
#include "xgpio_l.h"

#include "axi_timer_sleep.h"
#include "lmk04828_registers.h"

volatile u32 cnt;

uint8_t SPI_Transfer(uint32_t BASEADDR, uint8_t data) {

    while (!(XSpi_ReadReg(BASEADDR, XSP_SR_OFFSET) & XSP_SR_TX_EMPTY_MASK));
    XSpi_WriteReg(BASEADDR, XSP_DTR_OFFSET, data);
    while (XSpi_ReadReg(BASEADDR, XSP_SR_OFFSET) & XSP_SR_RX_EMPTY_MASK);
    return (uint8_t)XSpi_ReadReg(BASEADDR, XSP_DRR_OFFSET);
}


uint32_t SpiPllTransfer(u32 BASEADDR,u32 Data)
{
	u8 data2=0;
	u8 data1=0;
	u8 data0=0;

	XSpi_WriteReg(BASEADDR,XSP_SSR_OFFSET,3);
	axi_tsleep(1);
	data2 = SPI_Transfer(BASEADDR, (u8)((Data>>16)&0xFF));
	data1 = SPI_Transfer(BASEADDR, (u8)((Data>> 8)&0xFF));
	data0 = SPI_Transfer(BASEADDR, (u8)((Data>> 0)&0xFF));
	XSpi_WriteReg(BASEADDR,XSP_SSR_OFFSET,2);

	return ((u32)(data2)<<16) | ((u32)(data1)<<8) | ((u32)(data0)<<0);
}

void SpiDacTransfer(u32 BASEADDR,u32 Data)
{
	XSpi_WriteReg(BASEADDR,XSP_SSR_OFFSET,0); // maska aktywuje tylko wybranego slave
	axi_tsleep(1);
	SPI_Transfer(BASEADDR, (u8)((Data>>16)&0xFF));
	SPI_Transfer(BASEADDR, (u8)((Data>> 8)&0xFF));
	SPI_Transfer(BASEADDR, (u8)((Data>> 0)&0xFF));
	XSpi_WriteReg(BASEADDR,XSP_SSR_OFFSET,2);
}

uint32_t SpiAdcTransfer(u32 BASEADDR,u32 Data)
{
	u8 data2=0;
	u8 data1=0;
	u8 data0=0;

	XSpi_WriteReg(BASEADDR,XSP_SSR_OFFSET,0);
	axi_tsleep(1);

	data2 = SPI_Transfer(BASEADDR, (u8)((Data>>16)&0xFF));
	data1 = SPI_Transfer(BASEADDR, (u8)((Data>> 8)&0xFF));
	data0 = SPI_Transfer(BASEADDR, (u8)((Data>> 0)&0xFF));

	XSpi_WriteReg(BASEADDR,XSP_SSR_OFFSET,1);

	return ((u32)(data2)<<16) | ((u32)(data1)<<8) | ((u32)(data0)<<0);
}

void SpiInit(u32 BASEADDR)
{
	XSpi_WriteReg(BASEADDR,XSP_CR_OFFSET,XSP_CR_MASTER_MODE_MASK | XSP_CR_ENABLE_MASK | XSP_CR_MANUAL_SS_MASK);
}



void PllConfiguration()
{
	u32 read_data=0;
	xil_printf("PLL Configuration Start\n");
	for (int var = 0; var < (sizeof(config_registers)/sizeof(config_registers[0])); var++)
	{
		SpiPllTransfer(XPAR_AXI_QUAD_PLL_DAC_BASEADDR, config_registers[var]);
	}
	xil_printf("PLL Configuration Done\n");
	xil_printf("PLL Configuration Check\n");
	for (int var = 0; var < (sizeof(config_registers)/sizeof(config_registers[0])); var++)
	{
		read_data = SpiPllTransfer(XPAR_AXI_QUAD_PLL_DAC_BASEADDR, (config_registers[var]|0x8000FF));
		u8 cmp = (read_data == (config_registers[var]|0x800000));
		printf("Read:0x%x Gold:0x%x Compare:%s\n",read_data,(config_registers[var]|0x800000),cmp ? "True":"False");
	}
	xil_printf("PLL Configuration Check Done\n");
}

void DacConfiguartion()
{
	printf("DAC Start-Up Configuartion\r\n");

	u32 ch[8];
	for (int var = 0; var < 8; var++) {
		ch[var] = (u32)(3<<20) + (u32)(var<<16) + (u32)(0xFF00);
		SpiDacTransfer(XPAR_AXI_QUAD_PLL_DAC_BASEADDR, ch[var]);
	}
//
	for (int var = 0; var < 8; var++) {
		printf("CH[%d]:0x%x\n", var,ch[var]);
	}


}

