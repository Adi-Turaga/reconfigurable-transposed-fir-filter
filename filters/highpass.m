N = 127; % filter order
Fs = 48e3; % sampling frequency = 48 kHz
Fp = 8e3; % passband edge frequency
Ap = 0.01; % passband ripple
Ast = 80; % stopband attenuation in dB

Rp = (10^(Ap/20) - 1)/(10^(Ap/20) + 1); 
Rst = 10^(-Ast/20);

NUM = firceqrip(N, Fp/(Fs/2), [Rp Rst], "high");

%hFiltAnalyzer = filterAnalyzer(NUM,SampleRates=Fs,FilterNames="Num_120");

fvtool(NUM, 1);
freqz(NUM, 1, 2048, Fs);
length(NUM);

b = NUM;
Q = 15;
bQ = round(b * 2^Q);
bq16 = int16(bQ);

LP_FIR = dsp.FIRFilter(Numerator=NUM);
SA_FIR = spectrumAnalyzer(SampleRate=Fs,PlotAsTwoSidedSpectrum=false);
tic
while toc < 10
    %x = randn(300, 1)/10;
    %x = int16(round(x * 2^Q));
    %x = load_wave("wave_904_ff=8000Hz.txt", "int16");
    %x = gen_sine(9000, 300);
    x = gen_sine(5000, 300);
    y = LP_FIR(x(:));
    step(SA_FIR, y);
end
release(SA_FIR);
plot(x); hold on; plot(y);

%{
out_file = fopen("input.txt", 'w');

y_int = int(y);
for k = 1:length(x)
    fprintf(out_file, "%04X\n", typecast(x(k), 'uint16')); % prints signed hex
end



file = fopen('coeffs.txt', 'w');

b = NUM;
Q = 15;
bQ = round(b * 2^Q);
bq16 = int16(bQ);
for k = 1:length(bq16)
    fprintf(file, "%04X\n", typecast(bq16(k), 'uint16')); % prints signed hex
end
%}