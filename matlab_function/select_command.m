function [Select_command_sequence] = select_command(PICC,BCC,SEL)
    % Select command
    Select_command_dec = [hex2dec('93'), hex2dec('70'), hex2dec(PICC(1,1:2)), hex2dec(PICC(2,1:2)), hex2dec(PICC(3,1:2)), hex2dec(PICC(4,1:2)), hex2dec(BCC)];
    % Compute CRC A
    CRC_A = compute_crc(Select_command_dec);
    CRC_1 = dec2hex(CRC_A(1));
    CRC_2 = dec2hex(CRC_A(2));
    % add zero (new)
    if length(CRC_1) ~= 2
        CRC_1 = ['0',CRC_1];
    end
    if length(CRC_2) ~= 2
        CRC_2 = ['0',CRC_2];
    end
    % Select command in hex
    Select_command_hex = ['93';'70';PICC(1,1:2);PICC(2,1:2);PICC(3,1:2);PICC(4,1:2);BCC;CRC_1;CRC_2];
    last_senquence = SEL(end);
    Select_command_sequence = SEL;
    for i = 2:length(Select_command_hex)
        [~,b] = translate_command(Select_command_hex(i,1:2),last_senquence);
        last_senquence = b(end);
        Select_command_sequence = [Select_command_sequence,b];
    end
    if Select_command_sequence(end) == 'Y' || Select_command_sequence(end) == 'Z'
        Select_command_sequence = [Select_command_sequence, 'ZY'];
    else
        Select_command_sequence = [Select_command_sequence, 'YY'];
    end
end

