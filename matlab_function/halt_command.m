function halt_command(select_command_sequence,inst,f)
    %% Commands pre-defined 
    No_information = repmat('Y',[1,50]);
    Wait_information = repmat('Y',[1,75]);
    SEL_command = select_command_sequence;
    REQA = 'AZZXXYZXYZY';
    ANTI = 'ZXXYZXYZXXYZZZZXYZZZY';
    HALT = 'ZZZZZXYXYXYZZZZZZZXXXXYXYXYZXYXXYZXXYZY';
    check = 1;
    writeline(f,[REQA,No_information,ANTI,'\n']);
    pause(3);
    while (check)
        writeline(f,['A',Wait_information, SEL_command,'\n']); 
        pause(5);
        waveform = CaptureDataFromScopeII(inst);
        response_flag = detect_response(waveform);
        if response_flag == 1
            check = 0;
        else
            check = 1;
            writeline(f,[REQA,No_information,ANTI,'\n']);
            pause(3);
        end
    end
    writeline(f,['A',Wait_information, HALT,'\n']); 
    pause(5);
    writeline(f,['A',Wait_information, HALT,'\n']); 
    pause(5);
end

