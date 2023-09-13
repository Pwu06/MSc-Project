function waveform = resend_ANTI(f,inst)
    %% Commands pre-defined
    No_information = repmat('Y',[1,50]);
    Wait_information = repmat('Y',[1,75]); 
    REQA = 'AZZXXYZXYZY';
    ANTI = 'ZXXYZXYZXXYZZZZXYZZZY';    
    writeline(f,['AYY','\n'])
    %% ANTI
    check = 0;
    while(check < 4)
        writeline(f,[REQA,No_information,'\n'])
        pause(2)
        writeline(f,['A',ANTI,Wait_information,'\n'])
        pause(2)
        waveform = CaptureDataFromScopeII(inst);
        response_flag = detect_response(waveform);
        check = check + response_flag;
    end
end

