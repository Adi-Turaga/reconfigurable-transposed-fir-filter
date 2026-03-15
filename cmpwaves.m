% 1. Read the file into a cell array of strings
x = readlines('./coeffs/HP_coeffs_8000Hz_128taps.txt'); 
y = readlines('./output_signals/impulse/output_impulse_HP.txt');

% 2. Convert hex strings to unsigned integers (e.g., uint16 or uint32)
% Change 'uint16' to match your data's bit-depth
x = uint16(hex2dec(x));
y = uint32(hex2dec(y));

% 3. Cast to signed integers
x = typecast(x, 'int16');
y = typecast(y, 'int32');

disp(dec2hex(x));
disp("----------------------------------------------");
disp(dec2hex(y));

y = y(2:130);
x = x(1:129);
MAE = mean(abs(y - int32(x)));
relative_error = (MAE / max(y)) * 100;
fprintf("MAE = %.5f\tRelative Error = %.8f\n", MAE, relative_error);
plot(x); hold on; plot(y);

%{
Relative errors for impulse:
    LP: MAE = 0.51163 => relative error = 0.0019 %
    HP: MAE = 0.47287 => relative error = 0.0018 %
    BP: MAE = 0.49612 => relative error = 0.0019 %
    BS: MAE = 1.2016 => relative error = 0.0045 %
%}