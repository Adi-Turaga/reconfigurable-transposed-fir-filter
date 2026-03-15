function y = band_gen(N, freq1, freq2, type)
    %N = 127; % filter order
    Fs = 48e3; % sampling frequency = 48 kHz
    Fp = [freq1 freq2]; % passband edge frequency
    
    trans = 500;
    f = [0, Fp(1)-trans, Fp(1), Fp(2), Fp(2)+trans, Fs/2] / (Fs/2);
    
    if(type == "BP") % bandpass
        a = [0, 0, 1, 1, 0, 0]; 
    elseif(type == "BS") % bandstop
        a = [1, 1, 0, 0, 1, 1];
    else
        error('Invalid filter type specified. Please use "pass" or "stop".');
    end
    
    NUM = firpm(N, f, a);
    
    %{
    peak = max(abs(NUM));
    target_scale = 0.99 / peak;
    NUM_scaled = NUM * target_scale;
    %}

    Q = 15; % Q scaling factor
    scaled_coeffs = round(NUM * 2^Q); % conversion of coeffs to fixed point
    scaled_coeffs = int16(scaled_coeffs); % turning result into int16
    
    NUM_TAPS = N + 1;
    
    coeffs_file = sprintf("./coeffs/%s_coeffs_%dHz_%dHz_%dtaps.txt", type, Fp(1), Fp(2), NUM_TAPS);
    fid = fopen(coeffs_file, 'w'); % Open the file for writing
    
    for k = 1:length(scaled_coeffs)
        fprintf(fid, "%04X\n", typecast(scaled_coeffs(k), 'uint16'));
    end

    y = NUM;
    
    fclose(fid);
end