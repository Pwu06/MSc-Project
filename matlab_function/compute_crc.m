% This function computes the CRC for the provided data 
% based on the ISO/IEC 14443 Type A standard for RFID systems.
%
% Input:
% - data: A vector containing the data for which the CRC needs to be computed.
%
% Output:
% - crc: A two-element vector containing the CRC bytes.
function crc = compute_crc(data)
    % Initialize the CRC value with a standard preset for CRC_A
    crc = uint16(hex2dec('6363')); 
    % Loop through each byte in the provided data
    for i = 1:numel(data)
        ch = uint16(data(i));
        % XOR the data byte with the current CRC value
        ch = bitxor(ch, crc, 'uint16');
        % Process each bit in the data byte
        for j = 1:8
            % If the least significant bit of ch is 1
            if bitget(ch, 1, 'uint16')
                % Right shift the value of ch by 1 bit
                ch = bitshift(ch, -1, 'uint16');
                % XOR ch with a constant value 
                ch = bitxor(ch, uint16(hex2dec('8408')));
            else
                % If the least significant bit is 0, simply right shift 
                % the value of ch by 1 bit
                ch = bitshift(ch, -1, 'uint16');
            end
        end
        % Update the CRC with the processed value of ch
        crc = ch;
    end
    % Split the 16-bit CRC value into two separate bytes
    % First byte is the lower 8 bits, and the second byte is the higher 8 bits of the CRC
    crc = [bitand(crc, uint16(hex2dec('00FF'))), bitshift(crc, -8)];
end