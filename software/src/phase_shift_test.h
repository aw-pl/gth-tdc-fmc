


void print_shift_results(u8 channel_addr ,u32 count_limit);
void print_shift_results_all(u32 count_limit);
void print_shift_results_csv_all(u32 count_limit,u32 index, u32 dac_code, double dac_vout);
void disable_channels_diff();
void enable_channels_diff();
void check_stability(u32 count_limit, u32 repeat, u32 pause_ms);
void measure_realign_hist(u32 n_trials);
int find_stability(u32 count_limit, double threshold, u32 max_retries, u32 pause_ms, u32 reset_mode);
void print_shift_sweep_onech_human(u8 hist_ch, u8 dac_chn, u32 points, u32 count_limit);
