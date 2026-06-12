
#include "axi_timer_sleep.h"
#include <stdint.h>
#include <xparameters.h>

#define TIMER_BASEADDR     XPAR_AXI_TIMER_0_BASEADDR  // <- ustaw adres bazowy Twojego AXI Timer IP
#define AXI_TIMER_TCR   (*(volatile uint32_t *)(TIMER_BASEADDR + TIMER_TCR_OFFSET))
//************************
#define TCSR0_OFFSET       0x00        // Timer 0 Control/Status
#define TLR0_OFFSET        0x04        // Timer 0 Load
#define TCR0_OFFSET        0x08        // Timer 0 Counter
#define AXI_TIMER_TCR   (*(volatile uint32_t *)(TIMER_BASEADDR + TCR0_OFFSET))
#define TCSR0   (*(volatile uint32_t *)(TIMER_BASEADDR + TCSR0_OFFSET))
#define TLR0    (*(volatile uint32_t *)(TIMER_BASEADDR + TLR0_OFFSET))

// Bit definitiony (ze specyfikacji AXI Timer IP)
#define TCSR_MDT   (1 << 0)  // Mode: 0 = generate mode, 1 = capture mode
#define TCSR_UDT   (1 << 1)  // Up/Down count: 0 = up, 1 = down
#define TCSR_GENT  (1 << 2)  // External generate
#define TCSR_CAPT  (1 << 3)  // Capture mode
#define TCSR_ARHT  (1 << 4)  // Auto reload
#define TCSR_LOAD  (1 << 5)  // Load timer with TLR
#define TCSR_ENIT  (1 << 6)  // Enable interrupt
#define TCSR_ENT   (1 << 7)  // Enable timer
#define TCSR_TINT  (1 << 8)  // Interrupt occurred (status)

void axi_timer_init(void)
{
    // 1. Disable timer
    TCSR0 &= ~TCSR_ENT;

    // 2. Optional: reset counter by loading 0
    TLR0 = 0;
    TCSR0 |= TCSR_LOAD;     // załaduj TLR do TCR
    TCSR0 &= ~TCSR_LOAD;    // wyłącz load (jednorazowy)

    // 3. Setup: up-counting, no auto-reload, no interrupt
    TCSR0 &= ~(TCSR_UDT | TCSR_ARHT | TCSR_ENIT);  // up count, no auto reload, no IRQ

    // 4. Start timer
    TCSR0 |= TCSR_ENT;
}







//************************
void axi_tsleep(uint32_t delay_ms)
{
    // Restart licznika od 0
    TCSR0 &= ~TCSR_ENT;   // zatrzymaj licznik
    TLR0 = 0;             // wpisz 0 do load
    TCSR0 |= TCSR_LOAD;   // załaduj do TCR0
    TCSR0 &= ~TCSR_LOAD;  // wyłącz load
    TCSR0 |= TCSR_ENT;    // start licznika

    // policz ile ticków odpowiada delay_ms
    // @100 MHz: 1 ms = 100 000 ticków
    uint32_t ticks = delay_ms * 100000;
    uint32_t start = AXI_TIMER_TCR;

    // busy wait do momentu przekroczenia targetu
    uint64_t safety = 0;
    while ((uint64_t)(AXI_TIMER_TCR - start) < ticks) {
        if (++safety > 1000000000ULL) break; // awaryjne wyjście
    }
}

