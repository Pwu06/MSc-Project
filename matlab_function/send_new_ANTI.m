function send_new_ANTI(f, New_ANTI)   
    %% Commands pre-defined
    No_information = repmat('Y',[1,50]);
    REQA = 'AZZXXYZXYZY';
    ANTI = 'ZXXYZXYZXXYZZZZXYZZZY';
    %% WUPA and ANTI
    writeline(f,[REQA,No_information,ANTI,'\n']);
    pause(1.5)
    writeline(f,['A',New_ANTI,'\n'])
    pause(1.5)
    %% Resend Check
    resend_flag = 1;
    while resend_flag
        answer = questdlg("Sending new Anti-collision command again?", ...
        'Response-Existence Check', ...
        'Yes','No','Cancel','Cancel');
        % Handle response
        switch answer
            case 'Yes'
                writeline(f,[REQA,No_information,ANTI,'\n']);
                pause(1.5)
                writeline(f,['A',New_ANTI,'\n'])
                pause(1.5)
                resend_flag = 1;
            case 'No'
                resend_flag = 0;
            case 'Cancel'
                break;
        end
    end
    pause(1)
end

