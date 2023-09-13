function [response,message_frames,ATQA_last_point,threshold,low_lim,Anti] = digitize_ATQA(waveform)
    %% oscillscope parameter used: 
    % 500 mv for the message, 5 V for the trigger signal
    % 200 us for the division scale :: may need to change!
    % 0.0 s delay
    %% function generator parameter used:
    % Frequency 13.56 MHz
    % 5.00 Vpp
    %% find the envelope
    time_data = waveform.XData;
    voltage_data = waveform.YData;
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
    % calculate the lower limit for the collision happen
    low_lim = a(0.75*length(a))*1.15;
    %% find the last point
    % It is required to locate the period of ATQA
    for i = 1:length(first_point)
        k = i-1;
        last_time = time_data(first_point(end-k));
        time_diff_check = last_time - first_time;
        if time_diff_check < 500*1e-6
            ATQA_last_point = first_point(end-k);
            break;
        end
    end
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
        check = length(find(temp > threshold));
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
    test_frame = message_frames(2:end);
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
    %% inverse the message and classify it based on the protocal
    inverse_message = flip(message_frames);
    RFU1 = inverse_message(2:5);
    Proprietary_coding = inverse_message(6:9);
    UID_size = inverse_message(11:12);
    RFU2 = inverse_message(13);
    Bit_frame_anticollision = inverse_message(14:18);

    hex1 = binaryVectorToHex(inverse_message(2:9).');
    hex0 = binaryVectorToHex(inverse_message(11:18).');
    %% check the UID size
    if UID_size(1) == 0 && UID_size(2) == 0
        size_type = 'single';
    elseif UID_size(1) == 0 && UID_size(2) == 1
        size_type = 'double';
    elseif UID_size(1) == 1 && UID_size(2) == 0
        size_type = 'tripple';
    elseif UID_size(1) == 1 && UID_size(2) == 1
        size_type = 'RFU';
    end
    %% print the results 
    if correct_flag == check_num
        fprintf("ATQA: %d bits", bits_number)
        fprintf('\n'); 
        disp("Parity Check: Correct")
        fprintf('Response:       ');
        fprintf('%c ', response);
        fprintf('\n'); 
        fprintf('Message Frames: ');
        fprintf('%d ', message_frames);
        fprintf('\n'); 
        fprintf('RFU1: ');
        fprintf('%d ', RFU1);
        fprintf('\n'); 
        fprintf('Proprietary Coding: ');
        fprintf('%d ', Proprietary_coding);
        fprintf('\n');
        fprintf('UID Size: ');
        fprintf('%d ', UID_size);
        fprintf(', %s ', size_type);
        fprintf('\n');
        fprintf('RFU2: ');   
        fprintf('%d ', RFU2);
        fprintf('\n');
        fprintf('Bit Frame Anticollision: ');
        fprintf('%d ', Bit_frame_anticollision);
        fprintf('\n');
        fprintf('Hexadecimal Presentation: ');
        fprintf('%s ', hex0);
        fprintf('%s ', hex1);
        fprintf('\n');
        fprintf('\n');
    end
    % locate the next response
    Anti.XData = waveform.XData(ATQA_last_point+5000:end);
    Anti.YData = waveform.YData(ATQA_last_point+5000:end);
end

