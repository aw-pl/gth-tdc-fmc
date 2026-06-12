#include "tinysh.h"
#include "tinysh_cmd.h"
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "xparameters.h"
#include "xil_printf.h"

#include "xil_io.h"
#include "spi_ctrl.h"
#include "xgpio_l.h"
#include "lmk04828_registers.h"
#include "phase_shift_test.h"
#include "gth_control.h"

tinysh_cmd_t hello_cmd={0,"hello","display hello","<cr>",hello_fnt,0,0,0};
tinysh_cmd_t pll_test={0,"pll_test","pll_test","<cr>",pll_test_fnt,0,0,0};
tinysh_cmd_t dac_test={0,"dac_test","dac_test","<cr>",dac_test_fnt,0,0,0};

tinysh_cmd_t adc_test={0,"adc_test","adc_test","<cr>",adc_test_fnt,0,0,0};
tinysh_cmd_t dac_set={0,"dac_set","dac_set","<cr>",dac_set_value_fnt,0,0,0};

tinysh_cmd_t phase_shifting_test={
    0,
    "phase_shifting_test",       // nazwa komendy w shellu
    "Run phase shifting test for single channel: usage phase_shifting_test <channel> <count_limit>",  // opis
    "<cr>",
    phase_shifting_test_fnt,
    0,0,0
};

tinysh_cmd_t phase_shifting_test_all={
    0,
    "phase_shifting_test_all",   // nazwa komendy w shellu
    "Run phase shifting test for all channels simultaneously: usage phase_shifting_test_all <count_limit>",  // opis
    "<cr>",
    phase_shifting_test_all_fnt,
    0,0,0
};

tinysh_cmd_t phase_shifting_dac_sweep_auto = {
    0,
    "phase_shifting_dac_sweep_auto",   // nazwa komendy w shellu
    "Sweep DAC values on given channel: usage dac_sweep <channel> <points>",  // opis
    "<cr>",
    phase_shifting_dac_sweep_auto_fnt,
    0,0,0
};

tinysh_cmd_t gth_run_cmd = {
    0,
    "run_gth",   // nazwa komendy w shellu
    "Run GTH reset/init sequence", // opis
    "<cr>",
    gth_run_fnt,
    0,0,0
};

tinysh_cmd_t gth_realign_cmd = {
    0,
    "gth_realign",              // nazwa komendy w shellu
    "Re-align GTH RX datapaths",// opis
    "<u32 count_limit>",        // brak argumentów
    gth_realign_fnt,            // funkcja do wywołania
    0,0,0
};
tinysh_cmd_t channels_diff_on_cmd  = {
    0, "channels_diff_on",  "enable channels diff counter",  "<cr>",
    channels_diff_on_fnt, 0, 0, 0
};

tinysh_cmd_t channels_diff_off_cmd = {
    0, "channels_diff_off", "disable channels diff counter", "<cr>",
    channels_diff_off_fnt, 0, 0, 0
};

tinysh_cmd_t measure_realign_hist_cmd = {
    0,
    "measure_realign_hist",             // nazwa w CLI
    "run repeated RX resets and accumulate histograms",  // opis
    "<n_trials>",                       // parametry
    measure_realign_hist_fnt,           // handler
    0,0,0
};
tinysh_cmd_t check_stability_cmd = {
    0,
    "check_stability",              // nazwa komendy w shellu
    "run stability test with count_limit samples", // opis
    "<count_limit>",                // składnia
    check_stability_fnt,            // handler
    0,0,0
};

tinysh_cmd_t find_stability_cmd = {
    0,                                /* parent (root) */
    "find_stability",                 /* name */
    "Find GTH working point by P2 threshold", /* help */
    "<count_limit> [threshold=0.99] [max_retries=100] [pause_ms=1] [reset_mode=0|1|2]", /* usage */
    find_stability_fnt,               /* function */
    0,                                /* next */
    0,                                /* child */
    0                                 /* prev */
};

tinysh_cmd_t phase_sweep_one_cmd = {
    0,
    "phase_sweep_one",
    "Sweep DAC full range and print ONE histogram channel characteristic (human readable)",
    "<hist_ch 0..5> <dac_chn 0..7> <points> [count_limit=1000000]",
    phase_sweep_one_fnt,
    0,0,0
};

/**
 * @brief Włącza licznik różnicowy kanałów (diff counter) poprzez GPIO.
 *
 * Komenda tinysh: "channels_diff_on"
 *
 * @param argc  Liczba argumentów (nieużywane).
 * @param argv  Tablica argumentów (nieużywane).
 */
void channels_diff_on_fnt(int argc, char **argv)
{
    (void)argc; (void)argv;
    enable_channels_diff();
    xil_printf("channels_diff: ENABLED\r\n");
}

/**
 * @brief Wyłącza licznik różnicowy kanałów (diff counter) poprzez GPIO.
 *
 * Komenda tinysh: "channels_diff_off"
 *
 * @param argc  Liczba argumentów (nieużywane).
 * @param argv  Tablica argumentów (nieużywane).
 */
void channels_diff_off_fnt(int argc, char **argv)
{
    (void)argc; (void)argv;
    disable_channels_diff();
    xil_printf("channels_diff: DISABLED\r\n");
}

/**
 * @brief Rejestruje wszystkie komendy tinysh zdefiniowane w tym module.
 *
 * Funkcja powinna być wywołana w fazie inicjalizacji systemu,
 * aby komendy były dostępne w CLI.
 *
 * @param brak argumentów.
 */
void registerCommands()
{
	tinysh_add_command(&hello_cmd);
	tinysh_add_command(&pll_test);
	tinysh_add_command(&dac_test);
	tinysh_add_command(&adc_test);
	tinysh_add_command(&dac_set);
	tinysh_add_command(&phase_shifting_test);
	tinysh_add_command(&phase_shifting_test_all);
	tinysh_add_command(&phase_shifting_dac_sweep_auto);
	tinysh_add_command(&gth_run_cmd);
	tinysh_add_command(&gth_realign_cmd);
	tinysh_add_command(&channels_diff_off_cmd);
	tinysh_add_command(&channels_diff_on_cmd);
	tinysh_add_command(&measure_realign_hist_cmd);
	tinysh_add_command(&check_stability_cmd);
	tinysh_add_command(&find_stability_cmd);
	tinysh_add_command(&phase_sweep_one_cmd);
}

/**
 * @brief Prosta komenda testowa wypisująca "hello world".
 *
 * Komenda tinysh: "hello"
 *
 * @param argc  Liczba argumentów (ignorowane).
 * @param argv  Tablica argumentów (ignorowane).
 */
void hello_fnt(int argc, char **argv)
{
    printf("hello world\n");
}

/**
 * @brief Test komunikacji SPI z PLL (LMK04828 lub podobny).
 *
 * Komenda tinysh: "pll_test"
 *
 * Odczytuje wybrane rejestry ID z układu PLL i wypisuje je na stdout.
 *
 * @param argc  Liczba argumentów (ignorowane).
 * @param argv  Tablica argumentów (ignorowane).
 */
void pll_test_fnt(int argc, char **argv)
{
	printf("PLL: TEST Start\n");
	u32 id_device_type_read_cmd = 0x8003FF;
	u32 id_prod_msb_read_cmd = 0x8004FF;
	u32 id_prod_lsb_read_cmd = 0x8005FF;
	u32 result =0;

	result = SpiPllTransfer(XPAR_AXI_QUAD_PLL_DAC_BASEADDR, id_device_type_read_cmd );
	printf("PLL ID_DEV: SPI response = 0x%06lX\n", (unsigned long)result);

	result = SpiPllTransfer(XPAR_AXI_QUAD_PLL_DAC_BASEADDR, id_prod_msb_read_cmd);
	printf("PLL ID_PRODH: SPI response = 0x%06lX\n", (unsigned long)result);

	result = SpiPllTransfer(XPAR_AXI_QUAD_PLL_DAC_BASEADDR, id_prod_lsb_read_cmd);
	printf("PLL ID_PRODL: SPI response = 0x%06lX\n", (unsigned long)result);

}

// LTC2666 DAC
//
//+----+----+----+----+---------------------------------------------+
//| C3 | C2 | C1 | C0 | Command                                     |
//+----+----+----+----+---------------------------------------------+
//| 0  | 0  | 0  | 0  | Write Code to n                             |
//| 1  | 0  | 0  | 0  | Write Code to All                           |
//| 0  | 1  | 0  | 0  | Write Span to n                             |
//| 1  | 1  | 0  | 0  | Write Span to All                           |
//| 0  | 0  | 1  | 0  | Update n (Power Up)                         |
//| 1  | 0  | 1  | 0  | Update All (Power Up)                       |
//| 0  | 0  | 0  | 1  | Write Code to n, Update n (Power Up)        |
//| 1  | 0  | 0  | 1  | Write Code to n, Update All (Power Up)      |
//| 0  | 1  | 0  | 1  | Write Code to All, Update n (Power Up)      |
//| 1  | 1  | 0  | 1  | Write Code to All, Update All (Power Up)    |
//| 0  | 0  | 1  | 1  | Power Down n                                |
//| 1  | 0  | 1  | 1  | Power Down Chip (All DACs, Mux and Ref.)    |
//| 0  | 1  | 1  | 0  | Analog Mux                                  |
//| 1  | 1  | 1  | 0  | Toggle Select                               |
//| 0  | 1  | 1  | 1  | Global Toggle                               |
//| 1  | 1  | 1  | 1  | Config                                      |
//| 1  | 1  | 1  | 1  | No Operation                                |
//+----+----+----+----+---------------------------------------------+
//
//+----+----+----+----+--------+
//| A3 | A2 | A1 | A0 |  DAC   |
//+----+----+----+----+--------+
//| 0  | 0  | 0  | 0  | DAC 0  |
//| 0  | 0  | 0  | 1  | DAC 1  |
//| 0  | 0  | 1  | 0  | DAC 2  |
//| 0  | 0  | 1  | 1  | DAC 3  |
//| 0  | 1  | 0  | 0  | DAC 4  |
//| 0  | 1  | 0  | 1  | DAC 5  |
//| 0  | 1  | 1  | 0  | DAC 6  |
//| 0  | 1  | 1  | 1  | DAC 7  |
//+----+----+----+----+--------+
//MSB                                                                             LSB
//+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
//| C3 | C2 | C1 | C0 | A3 | A2 | A1 | A0 | D15 | D14 | D13 | D12 | D11 | D10 | D9  | D8  | D7  | D6  | D5  | D4  | D3  | D2  | D1  | D0  |
//+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
//  |      Command      |     Address      |                Data Word (D15...D0)                                     |
//Bit23 22  21  20  19  18  17  16  15    14   13   12   11   10    9    8    7    6    5    4    3    2    1    0
//
//SDI ->---->---->---->---->---->---->---->---->---->---->---->---->---->---->---->---->---->---->---->---->---->---->--->

/**
 * @brief Testuje DAC LTC2666, ustawiając wzorzec kodów na wszystkich 8 kanałach.
 *
 * Komenda tinysh: "dac_test"
 *
 * @param argc  Liczba argumentów. Oczekiwany co najmniej 1 argument (argv[1] – wartość dzielnika).
 * @param argv  argv[1] – parametr używany w prostym wzorcu (val) do generacji kodów DAC.
 */
void dac_test_fnt(int argc, char **argv)
{
	u32 ch[8];
	u8 val = strtol(argv[1],NULL,10);
	for (int var = 0; var < 8; var++) {
		ch[var] = (u32)(3<<20) + (u32)(var<<16) + (u32)((var%val)*0xFFFF);
		SpiDacTransfer(XPAR_AXI_QUAD_PLL_DAC_BASEADDR, ch[var]);
	}
//
	for (int var = 0; var < 8; var++) {
		printf("CH[%d]:0x%x\n", var,ch[var]);
	}
}

/**
 * @brief Testuje komunikację SPI z układem ADC.
 *
 * Komenda tinysh: "adc_test"
 *
 * Odczytuje kilka rejestrów identyfikacyjnych z ADC i wypisuje je na stdout.
 *
 * @param argc  Liczba argumentów (ignorowane).
 * @param argv  Tablica argumentów (ignorowane).
 */
void adc_test_fnt(int argc, char **argv)
{
	printf("ADC: TEST Start\n");
	u32 id_chip_type_read_cmd 		= 0x800300;
	u32 vendor_ida_read_cmd 		= 0x800C00;
	u32 vendor_idb_read_cmd 		= 0x800D00;
	u32 result =0;

	result = SpiAdcTransfer(XPAR_AXI_QUAD_ADC_BASEADDR, id_chip_type_read_cmd);
	printf("ADC CHIP_TYPE: SPI response = 0x%06lX\n", (unsigned long)result);

	result = SpiAdcTransfer(XPAR_AXI_QUAD_ADC_BASEADDR, vendor_ida_read_cmd);
	printf("ADC VENDOR_ID_LSB: SPI response = 0x%06lX\n", (unsigned long)result);

	result = SpiAdcTransfer(XPAR_AXI_QUAD_ADC_BASEADDR, vendor_idb_read_cmd);
	printf("ADC VENDOR_ID_MSB: SPI response = 0x%06lX\n", (unsigned long)result);

}

/**
 * @brief Ustawia wartość DAC na wybranym kanale.
 *
 * Komenda tinysh: "dac_set"
 *
 * @param argc  Liczba argumentów. Oczekiwane: 3
 *              - argv[1] – numer kanału DAC (0..7),
 *              - argv[2] – wartość (interpretacja zależy od przyjętej skali, aktualnie mnożona przez 0xFFFF).
 * @param argv  Tablica argumentów ciągu znaków.
 */
void dac_set_value_fnt(int argc, char **argv)
{
	u16 val = strtol(argv[2],NULL,10);
	u8	chn = strtol(argv[1],NULL,10);
	u32 frame = (u32)(3<<20) + (u32)(chn<<16) + (u32)(val*0xFFFF);
	SpiDacTransfer(XPAR_AXI_QUAD_PLL_DAC_BASEADDR, frame);
	printf("Set DAC with value:%d on Chn:%d\n",val,chn);

}

/**
 * @brief Uruchamia test przesuwania fazy (phase shifting) dla pojedynczego kanału.
 *
 * Komenda tinysh: "phase_shifting_test"
 *
 * @param argc  Liczba argumentów:
 *              - brak lub 1–2 argumenty:
 *                argv[1] – numer kanału (0–5),
 *                argv[2] – limit próbek (count_limit, hex lub dec).
 *              W razie braku argumentów używane są wartości domyślne.
 * @param argv  Tablica argumentów.
 */
void phase_shifting_test_fnt(int argc, char **argv)
{
    u8 channel_addr = 0;               // domyślnie kanał 0
    u32 count_limit = 0x4000000;      // domyślnie 1G samples

    if (argc >= 2) {
        // argv[1] = numer kanału (0–5)
        channel_addr = (u8)strtoul(argv[1], NULL, 0);
    }
    if (argc >= 3) {
        // argv[2] = limit próbek (hex lub dec)
        count_limit = (u32)strtoul(argv[2], NULL, 0);
    }

    xil_printf("Running phase shifting test: CH=%u, COUNT_LIMIT=0x%08X\n",
               channel_addr, count_limit);

    print_shift_results(channel_addr, count_limit);
}

/**
 * @brief Uruchamia test przesuwania fazy na wszystkich kanałach jednocześnie.
 *
 * Komenda tinysh: "phase_shifting_test_all"
 *
 * @param argc  Liczba argumentów:
 *              - opcjonalnie argv[1] – count_limit (hex lub dec),
 *                w przypadku braku argumentu używana jest wartość domyślna.
 * @param argv  Tablica argumentów.
 */
void phase_shifting_test_all_fnt(int argc, char **argv)
{
    u32 count_limit = 0x4000000;  // domyślny limit

    if (argc >= 2) {
        // argv[1] = count_limit (hex albo dec)
        count_limit = (u32)strtoul(argv[1], NULL, 0);
    }

    xil_printf("Running phase shifting test for ALL channels: COUNT_LIMIT=0x%08X\n",
               count_limit);

    print_shift_results_all(count_limit);
}

/**
 * @brief Automatyczny sweep kodu DAC na wskazanym kanale i logowanie histogramów w formacie CSV.
 *
 * Komenda tinysh: "phase_shifting_dac_sweep_auto"
 *
 * @param argc  Liczba argumentów. Oczekiwane co najmniej 3:
 *              - argv[1] – numer kanału DAC (0..7),
 *              - argv[2] – liczba punktów sweepu (points >= 2).
 * @param argv  Tablica argumentów.
 */
void phase_shifting_dac_sweep_auto_fnt(int argc, char **argv)
{
    if (argc < 3) {
        printf("Usage: dac_sweep <channel> <points>\n");
        return;
    }

    u8  chn    = (u8) strtol(argv[1], NULL, 10);
    u32 points = (u32)strtol(argv[2], NULL, 10);

    if (points < 2) {
        printf("Points must be >= 2\n");
        return;
    }

    u32 count_limit = 0x10000; // 64kB(64*1024) zboczy
    u32 step = 65535 / (points - 1);

    printf("\n#COUNT=%u,DAC_SWEEP,CH=%u,POINTS=%u,RANGE=0..65535,STEP=%u (~%.3f mV)\n",
    		count_limit,chn, points, step, (double)step * 10.0 / 65535.0 * 1000.0);

    // nagłówek CSV
    printf("INDEX,DAC_CODE,DAC_VOLT,CH,COUNT,TOTAL,WEIGHTED,MEAN");
    for (int h=0; h<16; h++) {
        printf(",HIST%d", h);
    }
    printf("\n");

    for (u32 i = 0; i < points; i++) {
        u32 val = i * step;
        double vout = (double)val * 10.0 / 65535.0; // wolt na wyjściu DAC

        // ramka DAC
        u32 frame = (u32)(3 << 20) | ((u32)chn << 16) | (u32)val;
        SpiDacTransfer(XPAR_AXI_QUAD_PLL_DAC_BASEADDR, frame);
        msleep(1); // stabilizacja 1 ms

        // wywołaj wersję CSV (z indexem + dac info)
        print_shift_results_csv_all(count_limit, i, val, vout);
    }

    printf("# DAC sweep finished.\n");
}

/**
 * @brief Uruchamia pełną sekwencję reset/init dla GTH.
 *
 * Komenda tinysh: "run_gth"
 *
 * @param argc  Liczba argumentów (ignorowane).
 * @param argv  Tablica argumentów (ignorowane).
 */
void gth_run_fnt(int argc, char **argv)
{
    xil_printf("Starting GTH run sequence...\n");
    run_gth();
    xil_printf("GTH run sequence finished.\n");
}

/**
 * @brief Uruchamia procedurę realignowania ścieżek RX GTH.
 *
 * Komenda tinysh: "gth_realign"
 *
 * @param argc  Liczba argumentów:
 *              - opcjonalnie argv[1] – count_limit (hex lub dec, obecnie nieużywany w implementacji).
 * @param argv  Tablica argumentów.
 */
void gth_realign_fnt(int argc, char **argv)
{
    u32 count_limit = 0x4000000;  // domyślny limit

    if (argc >= 2) {
        // argv[1] = count_limit (hex albo dec)
        count_limit = (u32)strtoul(argv[1], NULL, 0);
    }
    xil_printf(">> GTH channel re-align start...\r\n");
    gth_realign_channels();

}

/**
 * @brief Wykonuje wielokrotne realigny RX i akumuluje histogramy dla analizy stabilności.
 *
 * Komenda tinysh: "measure_realign_hist"
 *
 * @param argc  Liczba argumentów. Oczekiwane co najmniej 2:
 *              - argv[1] – liczba powtórzeń (n_trials).
 * @param argv  Tablica argumentów.
 */
void measure_realign_hist_fnt(int argc, char **argv)
{
    if (argc < 2) {
        xil_printf("Usage: measure_realign_hist <n_trials>\r\n");
        return;
    }

    u32 n_trials = atoi(argv[1]);
    xil_printf("Starting measure_realign_hist with %u trials...\r\n", n_trials);
    measure_realign_hist(n_trials);
    xil_printf("measure_realign_hist done.\r\n");
}

/**
 * @brief Test stabilności na podstawie histogramów dla wszystkich kanałów.
 *
 * Komenda tinysh: "check_stability"
 *
 * Dwa tryby:
 *  - check_stability <count_limit>
 *      pojedynczy, długi run (repeat = 1),
 *  - check_stability <count_limit> <repeat> <pause_ms>
 *      wiele krótszych runów, z przerwą między nimi.
 *
 * @param argc  Liczba argumentów: 2 lub 4.
 * @param argv  argv[1] – count_limit (hex lub dec),
 *              argv[2] – repeat (liczba powtórzeń, opcjonalne),
 *              argv[3] – pause_ms (czas przerwy w ms, opcjonalne).
 */
void check_stability_fnt(int argc, char **argv)
{
    if (argc < 2) {
        xil_printf("Usage:\r\n");
        xil_printf("  check_stability <count_limit>\r\n");
        xil_printf("  check_stability <count_limit> <repeat> <pause_ms>\r\n");
        return;
    }

    u32 count_limit = (u32)strtoul(argv[1], NULL, 0);
    u32 repeat   = 1;
    u32 pause_ms = 0;

    if (argc == 2) {
        repeat   = 1;  // long-term single run
        pause_ms = 0;
    } else if (argc == 4) {
        repeat   = (u32)strtoul(argv[2], NULL, 0);
        pause_ms = (u32)strtoul(argv[3], NULL, 0);
    } else {
        xil_printf("Error: invalid arguments. You must pass either 1 or 3 parameters.\r\n");
        xil_printf("Usage:\r\n");
        xil_printf("  check_stability <count_limit>\r\n");
        xil_printf("  check_stability <count_limit> <repeat> <pause_ms>\r\n");
        return;
    }

    xil_printf("Running check_stability count_limit=0x%X repeat=%u pause=%u ms\r\n",
               count_limit, repeat, pause_ms);

    check_stability(count_limit, repeat, pause_ms);

    xil_printf("check_stability done.\r\n");
}

/**
 * @brief Szuka punktu pracy GTH na podstawie progu P2 dla wszystkich kanałów.
 *
 * Komenda tinysh: "find_stability"
 *
 * Wywołanie:
 *   find_stability <count_limit> [threshold=0.99] [max_retries=100] [pause_ms=1] [reset_mode=0|1|2]
 *
 * @param argc  Liczba argumentów: co najmniej 2.
 * @param argv  argv[1] – count_limit (hex lub dec),
 *              argv[2] – threshold (double, domyślnie 0.99),
 *              argv[3] – max_retries (liczba prób, domyślnie 100),
 *              argv[4] – pause_ms (czas przerwy między próbami, ms),
 *              argv[5] – reset_mode:
 *                       0 = run_gth() pełny reset,
 *                       1 = gth_rx_pll_only_sequence(),
 *                       2 = brak resetu.
 */
void find_stability_fnt(int argc, char **argv)
{
    if (argc < 2) {
        printf("Usage: find_stability <count_limit> [threshold=0.99] [max_retries=100] [pause_ms=1] [reset_mode=0|1|2]\n");
        printf("  reset_mode: 0=run_gth() full, 1=RX_PLL_DATAPATH-only, 2=no reset\n");
        return;
    }

    u32 count_limit = (u32)strtoul(argv[1], NULL, 0);
    double threshold = (argc >= 3) ? strtod(argv[2], NULL) : 0.99;
    u32 max_retries  = (argc >= 4) ? (u32)strtoul(argv[3], NULL, 0) : 100u;
    u32 pause_ms     = (argc >= 5) ? (u32)strtoul(argv[4], NULL, 0) : 1u;
    u32 reset_mode   = (argc >= 6) ? (u32)strtoul(argv[5], NULL, 0) : 0u;

    printf("find_stability: count_limit=0x%08X (%u), threshold=%.5f, max_retries=%u, pause=%u ms, reset_mode=%u\n",
           count_limit, count_limit, threshold, max_retries, pause_ms, reset_mode);

    (void)find_stability(count_limit, threshold, max_retries, pause_ms, reset_mode);
}





void phase_sweep_one_fnt(int argc, char **argv)
{
    if (argc < 4) {
        printf("Usage: phase_sweep_one <hist_ch 0..5> <dac_chn 0..7> <points> [count_limit]\n");
        printf("Example: phase_sweep_one 0 3 256 1000000\n");
        return;
    }

    u8  hist_ch = (u8) strtoul(argv[1], NULL, 0);
    u8  dac_chn = (u8) strtoul(argv[2], NULL, 0);
    u32 points  = (u32)strtoul(argv[3], NULL, 0);
    u32 count_limit = (argc >= 5) ? (u32)strtoul(argv[4], NULL, 0) : 1000000u;

    printf("\n# phase_sweep_one: CH%02u (idx=%u), DAC=%u, points=%u, count=%u\n",
           hist_ch + 1, hist_ch, dac_chn, (unsigned)points, (unsigned)count_limit);

    print_shift_sweep_onech_human(hist_ch, dac_chn, points, count_limit);
}


