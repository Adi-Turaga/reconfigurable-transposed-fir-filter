function wave = gen_mem(num_samples, varargin)
    Q = 15;

    freqs = cell2mat(varargin);
    wave = zeros(1, num_samples);

    for i = 1:length(freqs)
        wave = wave + gen_sine(freqs(i), num_samples);
    end

    peak = max(abs(wave));
    if peak > 0
        wave = wave / peak;
    end

    scaled = round(wave * 2^Q);
    scaled = min(max(scaled, -2^15), 2^15 - 1);
    wave_scaled = int16(scaled);

    fund_freq = freqs(1);
    for i = 2:length(freqs)
        fund_freq = gcd(fund_freq, freqs(i));
    end

    filename = sprintf("./input_signals/wave_%d_ff=%dHz.txt", randi([0,999]), fund_freq);
    fid = fopen(filename, 'w');

    for k = 1:length(wave_scaled)
        fprintf(fid, "%04X\n", typecast(wave_scaled(k), 'uint16'));
    end

    fclose(fid);

    wave = wave_scaled;
end