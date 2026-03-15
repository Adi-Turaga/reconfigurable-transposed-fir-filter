x = randn(300, 1)/10;
x = int16(round(x * 2^Q));

filename = sprintf("./input_signals/wave_randn_%d.txt", randi([0, 999]));
fid = fopen(filename, 'w');

for k = 1:length(x)
    fprintf(fid, "%04X\n", typecast(x(k), 'uint16')); % prints signed hex
end

fclose(fid);