function [PICC,BCC] = digitize_PICC(waveform_PICC1,choose,same_bits)
    %% pre-define variables
    BCC_flag = 0;
    %% find the envelope
    time_data = waveform_PICC1.XData;
    voltage_data = waveform_PICC1.YData;
    [top,~] = envelope(voltage_data,50,'rms');
    %% find the first point
    [a,~] = sort(top,'descend');
    tsum = 0;
    test_num = 6500;
    for i = 1:test_num
        tsum = tsum + a(i);
    end
    % threshold control
    threshold = tsum/test_num;
    first_point = find(top>threshold);
    first_time = time_data(first_point(1));
    %% find the last point
    last_time = time_data(first_point(end));
    %% define the bit duration 
    fs = 847e3;
    t_bit = 8*(1/fs);
    half_bit_duration = t_bit/2;
    %% calculate the number of frames based on the bit duration
    time_diff = last_time - first_time;
    bits_number = ceil(time_diff/t_bit);
    %% start to digitize
    decoded_bits = zeros(bits_number,1);
    for k = 1:bits_number*2
        current_time = first_time + half_bit_duration*k;
        last_time = current_time - half_bit_duration;
        current_index = find_nearest(time_data,current_time);
        last_index = find_nearest(time_data,last_time);
        index_diff = current_index-last_index+1;
        mid_point = round(last_index+index_diff/2);
        temp = top(round(mid_point-index_diff/6):round(mid_point+index_diff/6));
        check = find(temp > threshold);
        if check > 0
            decoded_bits(k) = 1;
        else 
            decoded_bits(k) = 0;
        end
    end
    %% if it passes the parity check, then start to translate as sequence
    response = char(bits_number,1);
    for i = 1:bits_number
        later = decoded_bits(2*i);
        formal = decoded_bits(2*i-1);
        if later == 1 && formal == 0
            response(i) = 'E';
        elseif later == 0 && formal == 1
            response(i) = 'D';
        elseif later == 0 && formal == 0
            response(i) = 'F';
        else 
            response(i) = 'N';
        end
    end
    %% error check
    if response(1) ~= 'D'
        disp('The first sequence is wrong');
    end
    
    for i = 1:bits_number
        if response(i) == 'F'
            disp('No F should occur during the response');
            break;
        end
    end
    %% parity check
    % check the message, create an new array to store the message in logic
    correct_flag = 0;
    message_frames = zeros(bits_number,1);
    for i = 1:bits_number
        switch response(i)
            case 'D'
                message_frames(i) = 1;
            case 'E'
                message_frames(i) = 0;
        end
    end
    % ignore the first bit, because it is used to denote the start of comms
    test_framek = message_frames(2:end);
    test_frame = [same_bits; choose; test_framek];
    test_frame(isnan(test_frame)) = [];
    check_num = floor(bits_number/8);
    % start to check parity
    bo = 1;
    up = 8;
    for i = 1:check_num    
        temp1 = test_frame(bo:up);
        sum_of_ones = sum(temp1 == 1);
        % if the number of ones is odd, P should be 0; 
        % if the number of ones is even, P should be 1;
        if mod(sum_of_ones, 2) == 0
            P = 1;
        else
            P = 0;
        end
        % check the "ninth" bit
        bit_check = test_frame(up+1);
        if bit_check ~= P
            disp("Wrong parity bit, message may be not correct.")
        else
            correct_flag = correct_flag + 1;
        end
        bo = bo + 9;
        up = up + 9;
    end
    %% inverse the message to decode the tag id
    inverse_message = flip(test_frame);
    BCC = binaryVectorToHex(inverse_message(2:9).');
    uid3 = binaryVectorToHex(inverse_message(11:18).');
    uid2 = binaryVectorToHex(inverse_message(20:27).');
    uid1 = binaryVectorToHex(inverse_message(29:36).');
    uid0 = binaryVectorToHex(inverse_message(38:45).');
    PICC_uncheck = [uid0;uid1;uid2;uid3];
    %% BCC check, checksum
    bcc_check = xor(inverse_message(38:45).',inverse_message(29:36).');
    bcc_check = xor(bcc_check,inverse_message(20:27).');
    bcc_check = xor(bcc_check,inverse_message(11:18).');
    bcc_check_hex = binaryVectorToHex(bcc_check);
    if bcc_check_hex == BCC
        BCC_flag = 1;
    end
    %% print the results
    if correct_flag == check_num && BCC_flag == 1
%         fprintf('PICC: ');
%         fprintf('%s', uid0);
%         fprintf(' ')
%         fprintf('%s', uid1);
%         fprintf(' ')
%         fprintf('%s', uid2);
%         fprintf(' ')
%         fprintf('%s', uid3);
%         fprintf('\n');
        PICC = PICC_uncheck;
    end
end

