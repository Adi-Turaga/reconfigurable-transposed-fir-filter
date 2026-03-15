function y = lhpass_gen(N, freq, type)
    Fs = 48e3; % sampling frequency = 48 kHz
    Fp = freq; % passband edge frequency
    Ap = 0.01; % passband ripple
    Ast = 80; % stopband attenuation in dB
    
    Rp = (10^(Ap/20) - 1)/(10^(Ap/20) + 1); 
    Rst = 10^(-Ast/20);

    if type == "LP"
        flt_arg = "passedge";
    elseif type == "HP"
        flt_arg = "high";
    else
        error('Invalid filter type. Use "LP" for low-pass or "HP" for high-pass.');
    end
    
    NUM = firceqrip(N, Fp/(Fs/2), [Rp Rst], flt_arg);
    
    Q = 15; % Q scaling factor
    scaled_coeffs = round(NUM * 2^Q); % conversion of NUM matrix to fixed point
    scaled_coeffs = int16(scaled_coeffs); % turning result into int16
    
    NUM_TAPS = N + 1;
    
    coeffs_file = sprintf("./coeffs/%s_coeffs_%dHz_%dtaps.txt", type, Fp, NUM_TAPS);
    fid = fopen(coeffs_file, 'w'); % Open the file for writing
    
    for k = 1:length(scaled_coeffs)
        fprintf(fid, "%04X\n", typecast(scaled_coeffs(k), 'uint16'));
    end

    y = NUM;
    
    fclose(fid);

end