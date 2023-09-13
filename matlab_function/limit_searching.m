function [threshold,low_lim] = limit_searching(waveform)
    %% find the envelope
    voltage_data = waveform.YData;
    [top,~] = envelope(voltage_data,50,'rms');
    %% find the first point
    [a,~] = sort(top,'descend');
    tsum = 0;
    test_num = 5500;
    for i = 1:test_num
        tsum = tsum + a(i);
    end
    % threshold control
    threshold = tsum/test_num;
    % calculate the lower limit for the collision happen
    low_lim = a(0.75*length(a))*1.15;
end

