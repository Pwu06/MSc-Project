function response_flag = detect_response(waveform)
    %% find the envelope
    voltage_data = waveform.YData;
    [top,~] = envelope(voltage_data,50,'rms');
    %% find the first point
    [a,~] = sort(top,'descend');
    % threshold control
    threshold = mean(abs(a));
    Response = find(top>1.2*threshold);
    if length(Response) < 400
        response_flag = 0;
    else 
        response_flag = 1;
    end
end

