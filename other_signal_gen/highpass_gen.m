N = 31; % filter order
Fs = 48e3; % sampling frequency = 48 kHz
Fp = 8e3; % passband edge frequency
Ap = 0.01; % passband ripple
Ast = 80; % stopband attenuation in dB

Rp = (10^(Ap/20) - 1)/(10^(Ap/20) + 1); 
Rst = 10^(-Ast/20);

NUM = firceqrip(N, Fp/(Fs/2), [Rp Rst], "high");

Q = 15; % Q scaling factor
scaled_coeffs = round(NUM * 2^Q); % conversion of NUM matrix to fixed point
scaled_coeffs = int16(scaled_coeffs); % turning result into int16

NUM_q = double(scaled_coeffs) / 2^Q;

NUM_TAPS = N + 1;

coeffs_file = sprintf("./coeffs/HP_coeffs_%dHz_%dtaps.txt", Fp, NUM_TAPS);
fid = fopen(coeffs_file, 'w'); % Open the file for writing

for k = 1:length(scaled_coeffs)
    fprintf(fid, "%04X\n", typecast(scaled_coeffs(k), 'uint16'));
end

fclose(fid);""