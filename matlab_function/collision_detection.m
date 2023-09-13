function [ANTI_last_point,bits_number,decoded_bits,collision_record] = collision_detection(Anti, low_lim,same_bits_length,iteration, sub_iteration)
    %% Find the envelope
    time_data = Anti.XData;
    voltage_data = Anti.YData;
    [top,~] = envelope(voltage_data,50,'rms');
    %% Find the first point
    first_point = find(top>low_lim);
    first_time = time_data(first_point(1));
    %% Find the last point
    for i = 1:length(first_point)
        k = i-1;
        last_time = time_data(first_point(end-k));
        time_diff_check = last_time - first_time;
        if time_diff_check < 450*1e-6
            ANTI_last_point = first_point(end-k);
            break;
        end
    end
    %% Define the bit duration 
    fs = 847e3;
    t_bit = 8*(1/fs);
    half_bit_duration = t_bit/2;
    %% Calculate the number of frames based on the bit duration
    time_diff = last_time - first_time;
    bits_number = ceil(time_diff/t_bit);
    %% Start to detect collision
    pre_decoded_bits = zeros(bits_number*2,1);
    decoded_bits = zeros(bits_number,1);
    seqOut = char(bits_number,1);
    collision_record = zeros(bits_number,1);
    for k = 1:bits_number*2
        current_time = first_time + half_bit_duration*k;
        last_time = current_time - half_bit_duration;
        current_index = find_nearest(time_data,current_time);
        last_index = find_nearest(time_data,last_time);
        index_diff = current_index-last_index+1;
        mid_point = round(last_index+index_diff/2);
        temp = top(round(mid_point-index_diff/6):round(mid_point+index_diff/6));
        %% percentage check
        collision_check = length(find(temp > low_lim));
        percentage_check = collision_check*100/length(temp);
        %% Same bit check
        if percentage_check > 0.85
            pre_decoded_bits(k) = 1;
        else 
            pre_decoded_bits(k) = 0;
        end 
    end
    %% Start to decode as message
    for i = 1:bits_number
        later = pre_decoded_bits(2*i);
        formal = pre_decoded_bits(2*i-1);
        if later == 1 && formal == 0
            decoded_bits(i) = 0;
            seqOut(i) = 'E';
        elseif later == 0 && formal == 1
            decoded_bits(i) = 1;
            seqOut(i) = 'D';
        elseif later == 0 && formal == 0  
            decoded_bits(i) = 2;
            seqOut(i) = 'F';
        elseif later == 1 && formal == 1 
            decoded_bits(i) = 3;
            seqOut(i) = 'N';
            collision_record(i) = i; 
        else 
            decoded_bits(i) = 4;
            seqOut(i) = 'C';
        end
    end
    %% Print results
    collision_record(collision_record == 0) = [];
    collision_record = collision_record + same_bits_length;
    fprintf("Collision Detection (Iteration %d, Sub-iteration %d): ", iteration, sub_iteration); 
    if ~isempty(collision_record)
        fprintf("Collision has been detected at bit: ");
        fprintf("%d ", collision_record);
        fprintf("\n");
    else
        fprintf("No collision")
        fprintf("\n");
    end
    fprintf("\n");
end

