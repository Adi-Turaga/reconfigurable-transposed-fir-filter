function wave = load_wave(filename, type)
    x = readlines(filename);

    if type == "int16"
        wave = uint16(hex2dec(x));
    elseif type == "int32"
        wave = uint32(hex2dec(x));
    else
        error("Unsupported type. Use 'int16' or 'int32'.");
    end

    wave = typecast(wave, type);
    plot(wave);

end