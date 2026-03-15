function error_noise(file_ids)
    
    LP_coeffs = double(load_wave("./coeffs/LP_coeffs_8000Hz_128taps.txt", "int16")) / 2^15;
    HP_coeffs = double(load_wave("./coeffs/HP_coeffs_8000Hz_128taps.txt", "int16")) / 2^15;
    BP_coeffs = double(load_wave("./coeffs/BP_coeffs_4000Hz_8000Hz_128taps.txt", "int16")) / 2^15;
    BS_coeffs = double(load_wave("./coeffs/BS_coeffs_4000Hz_8000Hz_128taps.txt", "int16")) / 2^15;

    LP_FIR = dsp.FIRFilter(Numerator=LP_coeffs.');
    HP_FIR = dsp.FIRFilter(Numerator=HP_coeffs.');
    BP_FIR = dsp.FIRFilter(Numerator=BP_coeffs.');
    BS_FIR = dsp.FIRFilter(Numerator=BS_coeffs.');

    idx = 129:298;

    for i = 1:length(file_ids)
        in_file = sprintf("./input_signals/wave_randn_%d.txt", file_ids(i));
        x = load_wave(in_file, "int16");

        file_LP = sprintf("./output_signals/noise/output_randn_%d_LP.txt", file_ids(i));
        file_HP = sprintf("./output_signals/noise/output_randn_%d_HP.txt", file_ids(i));
        file_BP = sprintf("./output_signals/noise/output_randn_%d_BP.txt", file_ids(i));
        file_BS = sprintf("./output_signals/noise/output_randn_%d_BS.txt", file_ids(i));

        output_LP = load_wave(file_LP, "int32");
        output_HP = load_wave(file_HP, "int32");
        output_BP = load_wave(file_BP, "int32");
        output_BS = load_wave(file_BS, "int32");

        reset(LP_FIR);
        reset(HP_FIR);
        reset(BP_FIR);
        reset(BS_FIR);

        y_LP = LP_FIR(x);
        y_HP = HP_FIR(x);
        y_BP = BP_FIR(x);
        y_BS = BS_FIR(x);

        fprintf("PERCENT MEAN ABSOLUTE ERROR FOR %s -> LOWPASS\n", in_file);
        ref_LP = double(int32(y_LP(idx)));
        diff_LP = ref_LP - double(output_LP(idx));
        MAE_LP = mean(abs(diff_LP));
        pct_MAE_LP = 100 * MAE_LP / mean(abs(ref_LP));
        fprintf("MAE = %.5f\n", MAE_LP);
        fprintf("Percent MAE = %.2f%%\n\n", pct_MAE_LP);

        fprintf("PERCENT MEAN ABSOLUTE ERROR FOR %s -> HIGHPASS\n", in_file);
        ref_HP = double(int32(y_HP(idx)));
        diff_HP = ref_HP - double(output_HP(idx));
        MAE_HP = mean(abs(diff_HP));
        pct_MAE_HP = 100 * MAE_HP / mean(abs(ref_HP));
        fprintf("MAE = %.5f\n", MAE_HP);
        fprintf("Percent MAE = %.2f%%\n\n", pct_MAE_HP);
        
        fprintf("PERCENT MEAN ABSOLUTE ERROR FOR %s -> BANDPASS\n", in_file);
        ref_BP = double(int32(y_BP(idx)));
        diff_BP = ref_BP - double(output_BP(idx));
        MAE_BP = mean(abs(diff_BP));
        pct_MAE_BP = 100 * MAE_BP / mean(abs(ref_BP));
        fprintf("MAE = %.5f\n", MAE_BP);
        fprintf("Percent MAE = %.2f%%\n\n", pct_MAE_BP);
        
        fprintf("PERCENT MEAN ABSOLUTE ERROR FOR %s -> BANDSTOP\n", in_file);
        ref_BS = double(int32(y_BS(idx)));
        diff_BS = ref_BS - double(output_BS(idx));
        MAE_BS = mean(abs(diff_BS));
        pct_MAE_BS = 100 * MAE_BS / mean(abs(ref_BS));
        fprintf("MAE = %.5f\n", MAE_BS);
        fprintf("Percent MAE = %.2f%%\n\n", pct_MAE_BS);
    end
end