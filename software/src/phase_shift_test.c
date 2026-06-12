#include "xil_types.h"
#include "xil_io.h"
#include "axi_timer_sleep.h"
#include <stdio.h>   // printf, fflush
#include "gth_control.h"
#include <stdint.h>

#define WriteReg(BaseAddress, RegOffset, Data) \
	    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))

#define ReadReg(BaseAddress, RegOffset) \
		Xil_In32((BaseAddress) + (RegOffset))

#define GPIO_SHIFT_BLOCK_EN_BASEADDR XPAR_AXI_GPIO_DIFFSTAT_BASEADDR
#define ENABLE_SHIFT_BLOCK  1

#define HIST_BLOCK_CH01_BASEADDR XPAR_CHANNEL_HIST_0_BASEADDR
#define CHANNEL_HIST_BLOCK_LENGTH 0x2000

#define CONTROL_REG_OFFSET     0x0
#define COUNTERBASE_REG_OFFSET 0x4
#define STATUS_REG_OFFSET      0x8
#define COUNTER_REG_OFFSET     0xC

#define CH_M8 0x10
#define CH_M7 0x14
#define CH_M6 0x18
#define CH_M5 0x1C
#define CH_M4 0x20
#define CH_M3 0x24
#define CH_M2 0x28
#define CH_M1 0x2C
#define CH_P0 0x30
#define CH_P1 0x34
#define CH_P2 0x38
#define CH_P3 0x3C
#define CH_P4 0x40
#define CH_P5 0x44
#define CH_P6 0x48
#define CH_P7 0x4C

// ============================================================================
// Pojedynczy kanał
// ============================================================================
void enable_channels_diff()
{
	WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ENABLE_SHIFT_BLOCK);
}
void disable_channels_diff()
{
	WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);
}



void print_shift_results(u8 channel_addr ,u32 count_limit)
{

    u32 target = count_limit;
    u32 base_addr = HIST_BLOCK_CH01_BASEADDR + channel_addr*CHANNEL_HIST_BLOCK_LENGTH;
    u32 last_percent = 0;
    u32 shifts[16];

    // start
    WriteReg(base_addr, COUNTERBASE_REG_OFFSET, target);
    WriteReg(base_addr, CONTROL_REG_OFFSET, 1);
    WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ENABLE_SHIFT_BLOCK);

    printf("\nCounting Started:");
    fflush(stdout);

    // progres
    while (!(ReadReg(base_addr, STATUS_REG_OFFSET) == 3)) {
        axi_tsleep(1000);
        u32 current = ReadReg(base_addr, COUNTER_REG_OFFSET);
        u32 percent = (current * 100ULL) / target;
        if (percent >= last_percent + 10) {
            printf("-%u%% ", percent);
            fflush(stdout);
            last_percent = percent;
        }
    }
    printf("\n");

    u32 status = ReadReg(base_addr, STATUS_REG_OFFSET);
    u32 count  = ReadReg(base_addr, COUNTER_REG_OFFSET);

    // histogram
    for (int var = 0; var < 16; var++) {
        shifts[var] = ReadReg(base_addr, CH_M8 + var*4);
    }

    u32 total = 0;
    long long weighted = 0;
    for (int var = 0; var < 16; var++) {
        total    += shifts[var];
        weighted += (long long)(var-8) * (long long)shifts[var];
    }
    float mean = (total > 0) ? (float)weighted / (float)total : 0.0f;

    // print wyników
    printf("COUNT=%u,STATUS=%u,TOTAL=%u,WEIGHTED=%lld,MEAN=%.6f\n",
           count, status, total, weighted, mean);
    fflush(stdout);
    printf("HIST=[");
    for (int var = 0; var < 16; var++) {
        printf("%u", shifts[var]);
        if (var != 15) printf(",");
    }
    printf("]\n");
    fflush(stdout);

    // stop
    WriteReg(base_addr, CONTROL_REG_OFFSET, 0);
    WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);
}

// ============================================================================
// Wszystkie kanały
// ============================================================================
void print_shift_results_all(u32 count_limit)
{
	WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);
    u32 target = count_limit;
    u32 base_addr;
    u32 last_percent = 0;

    u32 shifts[6][16];
    u32 status[6];
    u32 count[6];
    u32 total[6];
    long long weighted[6];
    float mean[6];

    // start wszystkich
    for (u8 ch = 0; ch < 6; ch++) {
        base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
        WriteReg(base_addr, COUNTERBASE_REG_OFFSET, target);
        WriteReg(base_addr, CONTROL_REG_OFFSET, 1);
    }
    WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ENABLE_SHIFT_BLOCK);

    printf("\nCounting Started:");
    fflush(stdout);

    // progres (wg CH0)
    int done;
    do {
        done = 0;
        for (u8 ch = 0; ch < 6; ch++) {
            base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
            status[ch] = ReadReg(base_addr, STATUS_REG_OFFSET);
        }
        u32 current = ReadReg(HIST_BLOCK_CH01_BASEADDR, COUNTER_REG_OFFSET);
        u32 percent = (current * 100ULL) / target;
        if (percent >= last_percent + 10) {
            printf("-%u%% ", percent);
            fflush(stdout);
            last_percent = percent;
        }
        if ((status[0] & status[1] & status[2] & status[3] & status[4] & status[5]) == 3) {
            done = 1;
        }
        axi_tsleep(1);
    } while (!done);

    printf("\n");

    // odczyt i print wyników
    for (u8 ch = 0; ch < 6; ch++) {
        base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
        count[ch]  = ReadReg(base_addr, COUNTER_REG_OFFSET);

        total[ch] = 0;
        weighted[ch] = 0;
        for (int var = 0; var < 16; var++) {
            shifts[ch][var] = ReadReg(base_addr, CH_M8 + var*4);
            total[ch]    += shifts[ch][var];
            weighted[ch] += (long long)(var-8) * (long long)shifts[ch][var];
        }
        mean[ch] = (total[ch] > 0) ? (float)weighted[ch] / (float)total[ch] : 0.0f;

        printf("CH=0%u,COUNT=%u,STATUS=%u,TOTAL=%u,WEIGHTED=%lld,MEAN=%.6f\n",
               ch+1, count[ch], status[ch], total[ch], weighted[ch], mean[ch]);
        printf("CH=0%u,HIST=[",ch+1);
        for (int var = 0; var < 16; var++) {
            printf("%u", shifts[ch][var]);
            if (var != 15) printf(",");
        }
        printf("]\n");
        fflush(stdout);

        axi_tsleep(1);
    }

    // stop
    for (u8 ch = 0; ch < 6; ch++) {
        base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
        WriteReg(base_addr, CONTROL_REG_OFFSET, 0);
    }
    WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);
}

void print_shift_results_csv_all(u32 count_limit,u32 index, u32 dac_code, double dac_vout)
{
	WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);
    u32 target = count_limit;
    u32 base_addr;
    u32 last_percent = 0;

    u32 shifts[6][16];
    u32 status[6];
    u32 count[6];
    u32 total[6];
    long long weighted[6];
    float mean[6];

    // start wszystkich
    for (u8 ch = 0; ch < 6; ch++) {
        base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
        WriteReg(base_addr, COUNTERBASE_REG_OFFSET, target);
        WriteReg(base_addr, CONTROL_REG_OFFSET, 1);
    }
    WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ENABLE_SHIFT_BLOCK);


    // progres (wg CH0)
    int done;
    do {
        done = 0;
        for (u8 ch = 0; ch < 6; ch++) {
            base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
            status[ch] = ReadReg(base_addr, STATUS_REG_OFFSET);
        }
        if ((status[0] & status[1] & status[2] & status[3] & status[4] & status[5]) == 3) {
            done = 1;
        }
        msleep(1);
    } while (!done);

    // odczyt i print wyników
    for (u8 ch = 0; ch < 6; ch++) {
        base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
        count[ch]  = ReadReg(base_addr, COUNTER_REG_OFFSET);

        total[ch] = 0;
        weighted[ch] = 0;
        for (int var = 0; var < 16; var++) {
            shifts[ch][var] = ReadReg(base_addr, CH_M8 + var*4);
            total[ch]    += shifts[ch][var];
            weighted[ch] += (long long)(var-8) * (long long)shifts[ch][var];
        }
        mean[ch] = (total[ch] > 0) ? (float)weighted[ch] / (float)total[ch] : 0.0f;

        printf("%u,%u,%.4f,%u,%u,%u,%lld,%.6f",
               index, dac_code, dac_vout,
               ch+1, count[ch], total[ch], weighted[ch], mean[ch]);
        for (int var = 0; var < 16; var++) {
            printf(",%u", shifts[ch][var]);
        }
        printf("\n");
        fflush(stdout);

        msleep(1);
    }

    // stop
    for (u8 ch = 0; ch < 6; ch++) {
        base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
        WriteReg(base_addr, CONTROL_REG_OFFSET, 0);
    }
    WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);
}

static u32 g_check_stability_run_id = 0;

void check_stability(u32 count_limit, u32 repeat, u32 pause_ms)
{
    const int CHANNELS = 6;
    const int BINS  = 16;
    const int PAIRS = BINS - 1;

    u32 run_id = ++g_check_stability_run_id;

    if (repeat == 1) {
        xil_printf("Check Stability Start (run_id=%u)\r\n", run_id);

        // start wszystkich
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);
        for (u8 ch = 0; ch < CHANNELS; ch++) {
            u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
            WriteReg(base_addr, COUNTERBASE_REG_OFFSET, count_limit);
            WriteReg(base_addr, CONTROL_REG_OFFSET, 1);
        }
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ENABLE_SHIFT_BLOCK);

        // czekaj na DONE
        int done;
        u32 status[CHANNELS];
        do {
            done = 1;
            for (u8 ch = 0; ch < CHANNELS; ch++) {
                u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
                status[ch] = ReadReg(base_addr, STATUS_REG_OFFSET);
                if ((status[ch] & 0x3) != 0x3) done = 0;
            }
            axi_tsleep(1);
        } while (!done);
        xil_printf("Data Gathering Done\r\n");

        // odczyt: bins, total, weighted, mean, p2
        u32    bins_arr[CHANNELS][BINS];
        unsigned long long total_arr[CHANNELS];
        long long          weighted_arr[CHANNELS];
        double             mean_arr[CHANNELS];
        double             p2[CHANNELS][PAIRS];

        for (u8 ch = 0; ch < CHANNELS; ch++) {
            u32 base_addr_ch = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;

            unsigned long long total = 0ULL;
            long long weighted = 0LL;

            for (int b = 0; b < BINS; b++) {
                u32 v = ReadReg(base_addr_ch, CH_M8 + b * 4);
                bins_arr[ch][b] = v;
                total   += v;
                weighted += (long long)(b - 8) * (long long)v; // bin -8..+7
            }

            total_arr[ch]    = total;
            weighted_arr[ch] = weighted;
            mean_arr[ch]     = (total > 0ULL) ? (double)weighted / (double)total : 0.0;

            for (int b = 0; b < PAIRS; b++) {
                p2[ch][b] = (total > 0ULL)
                            ? ((double)bins_arr[ch][b] + (double)bins_arr[ch][b+1]) / (double)total
                            : 0.0;
            }
        }

        // log tekstowy: p2, hist, mean/total/weighted
        for (u8 ch = 0; ch < CHANNELS; ch++) {
            printf("CH%u_p2", ch + 1);
            for (int b = 0; b < PAIRS; b++) printf(",%.6f", p2[ch][b]);
            printf("\n");
        }
        for (u8 ch = 0; ch < CHANNELS; ch++) {
            printf("CH%u_hist", ch + 1);
            for (int b = 0; b < BINS; b++) printf(",%u", bins_arr[ch][b]);
            printf("\n");
        }
        for (u8 ch = 0; ch < CHANNELS; ch++) {
            printf("CH%u_mean,%.6f,total,%llu,weighted,%lld\n",
                   ch + 1, mean_arr[ch], total_arr[ch], weighted_arr[ch]);
        }

        // CSV: pełne dane (z run_id)
        printf("CSV_HEADER,run_id,channel,mean,total,weighted");
        for (int b = 0; b < BINS;  b++) printf(",b%d", b);
        printf("\n"); fflush(stdout);

        for (u8 ch = 0; ch < CHANNELS; ch++) {
            printf("CSV,%u,%u,%.6f,%llu,%lld",
                   run_id, ch + 1, mean_arr[ch], total_arr[ch], weighted_arr[ch]);
            for (int b = 0; b < BINS;  b++) printf(",%u", bins_arr[ch][b]);
            printf("\n"); fflush(stdout);
        }

        // stop
        for (u8 ch = 0; ch < CHANNELS; ch++) {
            u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
            WriteReg(base_addr, CONTROL_REG_OFFSET, 0);
        }
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);
        xil_printf("ReAlign & Stability Results Printed (run_id=%u)\r\n", run_id);
        return;
    }

    // ---- repeat > 1 : timeline mean-only ----
    printf("CSV_HEADER,run_id,iter,channel,mean\n"); fflush(stdout);

    for (u32 iter = 0; iter < repeat; iter++) {
        // start wszystkich
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);
        for (u8 ch = 0; ch < CHANNELS; ch++) {
            u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
            WriteReg(base_addr, COUNTERBASE_REG_OFFSET, count_limit);
            WriteReg(base_addr, CONTROL_REG_OFFSET, 1);
        }
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ENABLE_SHIFT_BLOCK);

        // czekaj na DONE
        int done;
        do {
            done = 1;
            for (u8 ch = 0; ch < CHANNELS; ch++) {
                u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
                u32 st = ReadReg(base_addr, STATUS_REG_OFFSET);
                if ((st & 0x3) != 0x3) done = 0;
            }
            axi_tsleep(1);
        } while (!done);

        // średnie per kanał i print CSV
        for (u8 ch = 0; ch < CHANNELS; ch++) {
            u32 base_addr_ch = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;

            unsigned long long total = 0ULL;
            long long          weighted = 0LL;

            for (int b = 0; b < BINS; b++) {
                u32 v = ReadReg(base_addr_ch, CH_M8 + b * 4);
                total   += v;
                weighted += (long long)(b - 8) * (long long)v;
            }

            double mean_val = (total > 0ULL) ? (double)weighted / (double)total : 0.0;

            printf("CSV,%u,%u,%u,%.6f\n", run_id, iter + 1, ch + 1, mean_val);
            fflush(stdout);

            WriteReg(base_addr_ch, CONTROL_REG_OFFSET, 0);
        }
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);

        if (pause_ms > 0) msleep(pause_ms);
    }
}



void measure_realign_hist(u32 n_trials)
{
    const int CHANNELS = 6;
    const int BINS = 16;
    const u32 COUNT_LIMIT = 1024 * 1024; // 1 Mi (1 048 576 zboczy na trial)

    uint64_t accum[CHANNELS][BINS];
    memset(accum, 0, sizeof(accum));

    u32 next_progress = 0;

    for (u32 trial = 0; trial < n_trials; trial++) {
        // 1. Reset/realign GTH
        run_gth();

        // 2. Start histogramów
        for (u8 ch = 0; ch < CHANNELS; ch++) {
            u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
            WriteReg(base_addr, COUNTERBASE_REG_OFFSET, COUNT_LIMIT);
            WriteReg(base_addr, CONTROL_REG_OFFSET, 1);
        }
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ENABLE_SHIFT_BLOCK);

        // 3. Czekaj na zakończenie
        int done;
        do {
            done = 1;
            for (u8 ch = 0; ch < CHANNELS; ch++) {
                u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
                u32 st = ReadReg(base_addr, STATUS_REG_OFFSET);
                if ((st & 0x3) != 0x3) done = 0;
            }
        } while (!done);

        // 4. Odczytaj histogramy i dodaj do akumulatora
        for (u8 ch = 0; ch < CHANNELS; ch++) {
            u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch*CHANNEL_HIST_BLOCK_LENGTH;
            for (int b = 0; b < BINS; b++) {
                u32 v = ReadReg(base_addr, CH_M8 + b*4);
                accum[ch][b] += (uint64_t)v;
            }
            WriteReg(base_addr, CONTROL_REG_OFFSET, 0);
        }
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);

        // 5. Progres w %
        u32 percent = (trial + 1) * 100 / n_trials;
        if (percent >= next_progress) {
            xil_printf("Progress: %u%% (%u/%u trials)\r\n",
                       percent, trial + 1, n_trials);
            next_progress = percent + 1;
        }
    }

    // 6. Wyniki w CSV
    printf("CSV_HEADER,channel");
    for (int b = 0; b < BINS; b++) printf(",b%d", b);
    printf("\n");
    fflush(stdout);

    for (u8 ch = 0; ch < CHANNELS; ch++) {
        printf("CSV,%u", ch+1);
        for (int b = 0; b < BINS; b++) printf(",%llu", accum[ch][b]);
        printf("\n");
        fflush(stdout);
    }
}



int find_stability(u32 count_limit, double threshold, u32 max_retries, u32 pause_ms, u32 reset_mode)
{
    const int CHANNELS = 6;
    const int BINS     = 16;
    const int PAIRS    = BINS - 1;   /* 15 */

    /* --- CSV header z kompletem P2 --- */
    printf("FIND_HEADER,attempt,channel,pass,max_p2,max_pair");
    for (int l = -8; l <= 6; ++l) printf(",p2_%d", l);  /* p2_-8 .. p2_6 (lewy bin pary) */
    printf("\n");

    for (u32 attempt = 1; attempt <= max_retries; ++attempt) {

        if (reset_mode == 0)      run_gth();
        else if (reset_mode == 1) gth_rx_pll_only_sequence();
        /* reset_mode==2 → bez resetu */

        /* start histogramów */
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);
        for (u8 ch = 0; ch < CHANNELS; ++ch) {
            u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch * CHANNEL_HIST_BLOCK_LENGTH;
            WriteReg(base_addr, COUNTERBASE_REG_OFFSET, count_limit);
            WriteReg(base_addr, CONTROL_REG_OFFSET, 1);
        }
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ENABLE_SHIFT_BLOCK);

        /* czekaj na DONE */
        int done;
        do {
            done = 1;
            for (u8 ch = 0; ch < CHANNELS; ++ch) {
                u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch * CHANNEL_HIST_BLOCK_LENGTH;
                u32 st = ReadReg(base_addr, STATUS_REG_OFFSET);
                if ((st & 0x3u) != 0x3u) done = 0;
            }
            msleep(1);
        } while (!done);

        int all_ok = 1;

        for (u8 ch = 0; ch < CHANNELS; ++ch) {
            u32 base_addr_ch = HIST_BLOCK_CH01_BASEADDR + ch * CHANNEL_HIST_BLOCK_LENGTH;

            unsigned long long total = 0ULL;
            u32 bins[BINS];
            for (int b = 0; b < BINS; ++b) {
                u32 v = ReadReg(base_addr_ch, CH_M8 + (u32)b * 4u); /* 0x10 + 4*b */
                bins[b] = v;
                total  += v;
            }

            double p2[PAIRS];
            double max_p2 = 0.0;
            int    max_idx = -1;

            if (total > 0ULL) {
                for (int p = 0; p < PAIRS; ++p) {
                    double s = (double)bins[p] + (double)bins[p+1];
                    p2[p] = s / (double)total;
                    if (p2[p] > max_p2) { max_p2 = p2[p]; max_idx = p; }
                }
            } else {
                for (int p = 0; p < PAIRS; ++p) p2[p] = 0.0;
            }

            int pass = (max_p2 >= threshold) ? 1 : 0;
            if (!pass) all_ok = 0;

            /* --- pełny print P2: p2_-8 .. p2_6 --- */
            printf("FIND,%u,%u,%d,%.6f,%d", attempt, (unsigned)(ch+1), pass, max_p2, max_idx);
            for (int p = 0; p < PAIRS; ++p) printf(",%.6f", p2[p]);
            printf("\n");
            fflush(stdout);
        }

        /* stop histogramów */
        for (u8 ch = 0; ch < CHANNELS; ++ch) {
            u32 base_addr = HIST_BLOCK_CH01_BASEADDR + ch * CHANNEL_HIST_BLOCK_LENGTH;
            WriteReg(base_addr, CONTROL_REG_OFFSET, 0);
        }
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);

        if (all_ok) {
            printf("find_stability: PASS at attempt %u (threshold=%.5f)\n", attempt, threshold);
            return 0;
        }

        if (pause_ms > 0) msleep(pause_ms);
    }

    printf("find_stability: FAIL after %u attempts (threshold=%.5f)\n", max_retries, threshold);
    return -1;
}

/**
 * Sweep DAC full range in 'points' steps and print ONE channel characteristic.
 *
 * @param hist_ch      0..5  (0=CH01)
 * @param dac_chn      0..7  (LTC2666 channel)
 * @param points       number of sweep points (>=2), e.g. 256
 * @param count_limit  edges per point, e.g. 1000000
 */
void print_shift_sweep_onech_human(u8 hist_ch, u8 dac_chn, u32 points, u32 count_limit)
{
    if (points < 2) {
        printf("ERROR: points must be >= 2\n");
        return;
    }
    if (hist_ch > 5) {
        printf("ERROR: hist_ch must be 0..5 (CH01..CH06)\n");
        return;
    }
    if (dac_chn > 7) {
        printf("ERROR: dac_chn must be 0..7\n");
        return;
    }

    const u32 DAC_MAX = 65535;
    u32 step = DAC_MAX / (points - 1);

    u32 base_addr = HIST_BLOCK_CH01_BASEADDR + hist_ch * CHANNEL_HIST_BLOCK_LENGTH;

    printf("\n=== DAC SWEEP (ONE CHANNEL) ===\n");
    printf("Histogram channel : CH%02u (idx=%u)\n", hist_ch + 1, hist_ch);
    printf("DAC channel       : %u\n", dac_chn);
    printf("Points            : %u\n", (unsigned)points);
    printf("Edges/point       : %u\n", (unsigned)count_limit);
    printf("Range             : 0..65535, step=%u\n", (unsigned)step);
    printf("Output            : mean_bin, mean_UI(~bin/16), peak_bin, peak_pct\n");
    printf("---------------------------------------------------------------\n");
    printf("idx  dac_code  volt[V]   total     mean_bin  mean_UI   peak_bin  peak_pct\n");
    printf("---------------------------------------------------------------\n");

    for (u32 i = 0; i < points; i++) {

        u32 dac_code = i * step;
        if (i == points - 1) dac_code = DAC_MAX; // ensure max at end
        double vout = (double)dac_code * 10.0 / 65535.0;

        /* set DAC */
        u32 frame = (u32)(3u << 20) | ((u32)dac_chn << 16) | (u32)dac_code;
        SpiDacTransfer(XPAR_AXI_QUAD_PLL_DAC_BASEADDR, frame);
        msleep(1);

        /* start measurement for one channel only */
        WriteReg(base_addr, COUNTERBASE_REG_OFFSET, count_limit);
        WriteReg(base_addr, CONTROL_REG_OFFSET, 1);
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ENABLE_SHIFT_BLOCK);

        /* wait done */
        while ((ReadReg(base_addr, STATUS_REG_OFFSET) & 0x3u) != 0x3u) {
            msleep(1);
        }

        /* read histogram + stats */
        unsigned long long total = 0ULL;
        long long weighted = 0LL;

        u32 peak_val = 0;
        int peak_idx = 0;

        for (int b = 0; b < 16; b++) {
            u32 v = ReadReg(base_addr, CH_M8 + (u32)b * 4u);
            total += v;
            weighted += (long long)(b - 8) * (long long)v;
            if (v > peak_val) { peak_val = v; peak_idx = b; }
        }

        /* stop */
        WriteReg(base_addr, CONTROL_REG_OFFSET, 0);
        WriteReg(GPIO_SHIFT_BLOCK_EN_BASEADDR, 0, ~ENABLE_SHIFT_BLOCK);

        double mean_bin = (total > 0ULL) ? (double)weighted / (double)total : 0.0;
        double mean_ui  = mean_bin / 16.0;
        double peak_pct = (total > 0ULL) ? (100.0 * (double)peak_val / (double)total) : 0.0;

        printf("%3u  %7u  %7.3f  %8llu  %+8.3f  %+7.4f  %+8d  %7.2f\n",
               (unsigned)i,
               (unsigned)dac_code,
               vout,
               (unsigned long long)total,
               mean_bin,
               mean_ui,
               (int)(peak_idx - 8),
               peak_pct);

        if (((i + 1) % 16) == 0) {
            printf("...progress %u/%u\n", (unsigned)(i + 1), (unsigned)points);
            fflush(stdout);
        }
    }

    printf("---------------------------------------------------------------\n");
    printf("Sweep done.\n");
}



