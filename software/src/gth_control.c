#include "xil_types.h"
#include "xil_io.h"
#include "xil_printf.h"
#include "axi_timer_sleep.h"
#include "xparameters.h"
#define GTH_RST_CTRL_BASEADDR XPAR_GTH_RST_CONTROLLER_0_BASEADDR

#define REG_RESET 0x00 // R/W
#define GTH_RESET_ALL (1<<0)
#define GTH_RESET_RX_PLL_DATAPATH (1<<1)
#define GTH_RESET_RX_DATAPATH (1<<2)
#define GTH_RESET_USERCLK_RX_RESET (1<<3)
#define GTH_RESET_RX_BUFFERBYPASS (1<<4)
#define GTH_RESET_RX_START_USER (1<<5)


#define REG_CDR_CONTROLS 0x04 // R/W
#define RX_CDR_HOLD (0x7F << 0)
#define RX_CDR_OVRDEN (0x7F << 8)

#define REG_GTH_CONFIGS 0x08 // R/W
#define RX_LPM_EN (0x7F<<00)
#define RX_LPM_HF_OVRDEN (0x7F<<8)
#define RX_LPM_LF_KL_OVRDEN (0x7F<<16)
#define RX_OS_OVRDEN (0x7F<<24)

#define REG_RESET_STATUS 0x0C // Read only
#define GTH_RX_ACTIVE 1<<0
#define GTH_BUFFBYPASS_RX_DONE 1<<1
#define GTH_BUFFBYPASS_RX_ERROR 1<<2
#define GTH_RESET_RX_CDR_STABLE 1<<3
#define GTH_RESET_RX_DONE 1<<4

#define REG_STATUS 0x10 // Read only
#define GTPOWERGOOD_MASK (0x7F << 0)
#define RXPMARESETDONE (0x7F << 8)
#define QPLL_LOCK (0x03 << 16)
#define QPLL_LOST (0x03 << 18)

#define WriteReg(BaseAddress, RegOffset, Data) \
	    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

#define ReadReg(BaseAddress, RegOffset) \
		Xil_In32((BaseAddress) + (RegOffset))



static void print_status(const char *tag)
{
    u32 rst_status = ReadReg(GTH_RST_CTRL_BASEADDR, REG_RESET_STATUS);
    u32 status     = ReadReg(GTH_RST_CTRL_BASEADDR, REG_STATUS);

    xil_printf("---- %s ----\r\n", tag);

    xil_printf("RESET_STATUS = 0x%x\r\n", rst_status);
    xil_printf("  GTH_RX_ACTIVE:            %d\r\n", (rst_status & GTH_RX_ACTIVE) ? 1 : 0);
    xil_printf("  GTH_BUFFBYPASS_RX_DONE:   %d\r\n", (rst_status & GTH_BUFFBYPASS_RX_DONE) ? 1 : 0);
    xil_printf("  GTH_BUFFBYPASS_RX_ERROR:  %d\r\n", (rst_status & GTH_BUFFBYPASS_RX_ERROR) ? 1 : 0);
    xil_printf("  GTH_RESET_RX_CDR_STABLE:  %d\r\n", (rst_status & GTH_RESET_RX_CDR_STABLE) ? 1 : 0);
    xil_printf("  GTH_RESET_RX_DONE:        %d\r\n", (rst_status & GTH_RESET_RX_DONE) ? 1 : 0);

    xil_printf("STATUS = 0x%08x\r\n", status);
    xil_printf("  GTPOWERGOOD_MASK: 0x%02x\r\n", (status & GTPOWERGOOD_MASK) >> 0);
    xil_printf("  RXPMARESETDONE:  0x%02x\r\n", (status & RXPMARESETDONE) >> 8);
    xil_printf("  QPLL_LOCK:       0x%01x\r\n", (status & QPLL_LOCK) >> 16);
    xil_printf("  QPLL_LOST:       0x%01x\r\n", (status & QPLL_LOST) >> 18);

    xil_printf("----------------\r\n");
}

void run_gth()
{
	// 1. Configs, disable CDR, lock to ref clock.
	WriteReg(GTH_RST_CTRL_BASEADDR,REG_GTH_CONFIGS, (RX_LPM_EN | RX_LPM_HF_OVRDEN | RX_LPM_LF_KL_OVRDEN | RX_OS_OVRDEN));
	WriteReg(GTH_RST_CTRL_BASEADDR,REG_CDR_CONTROLS,(RX_CDR_HOLD));
	// 2. Global reset
	WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_ALL);
	msleep(2);
	WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
	// tu poll GTPOWERGOOD & RXPMARESETDONE

	// 3. RX PLL datapath reset
	WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_PLL_DATAPATH);
	msleep(2);
	WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
	// tu poll QPLL_LOCK

	// 4. RX datapath reset
	WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_DATAPATH);
	msleep(2);
	WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
	// tu poll GTH_RESET_RX_DONE

	// 5. Buffer bypass + start user
    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_START_USER);
    msleep(1);
    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
    msleep(1);

    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_BUFFERBYPASS);
    msleep(1);
    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
    msleep(1);

	// tu poll GTH_BUFFBYPASS_RX_DONE

	// 6. Poczekaj chwilę, potem print
    msleep(5);
	print_status("Run GTH Reset Sequence");

}

void gth_realign_channels(void)
{

    // 1. Reset RX datapath
    while (!(ReadReg(GTH_RST_CTRL_BASEADDR, REG_RESET_STATUS) & GTH_RESET_RX_DONE)) {
        WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_PLL_DATAPATH);
        axi_tsleep(2);
        WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
        axi_tsleep(2);
        WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_DATAPATH);
        axi_tsleep(2);
        WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
        axi_tsleep(2);

    }
   // xil_printf("Datapath RST Done\r\n");

    // krok 2: poll BUF_BYPASS_DONE
    while (!(ReadReg(GTH_RST_CTRL_BASEADDR, REG_RESET_STATUS) & GTH_BUFFBYPASS_RX_DONE)) {
        WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_START_USER);
        axi_tsleep(1);
        WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
        axi_tsleep(1);

        // krok 3: RX_BUFFERBYPASS
        WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_BUFFERBYPASS);
        axi_tsleep(2);
        WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
        axi_tsleep(2);
    }

    xil_printf("BUFFERBYPASS & RX_START- RST Done\r\n");

    print_status("GTH realign done.\r\n");
}

void gth_rx_pll_only_sequence(void)
{
    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_PLL_DATAPATH);
    msleep(2);
    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
    msleep(2);

    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_DATAPATH);
    msleep(2);
    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
    msleep(2);

    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_START_USER);
    msleep(1);
    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
    msleep(1);

    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, GTH_RESET_RX_BUFFERBYPASS);
    msleep(1);
    WriteReg(GTH_RST_CTRL_BASEADDR, REG_RESET, 0);
    msleep(1);
}
