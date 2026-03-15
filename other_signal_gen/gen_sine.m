function y = gen_sine(freq, num_samples)
    Fs = 48000; % sampling frequency = 48 kHz
    f = freq; % signal frequency = {freq} Hz
    t = (0:num_samples-1)/Fs; % time vector

    y = sin(2 * pi * f * t);
end
