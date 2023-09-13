%% Code comment 
%{ 
Function: Read all the tags in the interrogation zone.

Step:
1.  Capature the generated response on the oscilloscope.
2.  Analysis the ATQA, and then enter the anti-collision loop.
3.  Decode a single tag's UID and let it become slient.
4.  Use REQA to detect the rest tags.
5.  Repeat the steps 3 and 4 until last tag has been found.
6.  Print all the tags. 

Importance:
1. Due to the MATLAB connection issue, the sent command should be checked
   and confirmed mannually.

Date: 2/8/2023
FYP Name: Pengtao Wu
%}
%% Initialise the oscillscope
inst = InitialiseScope;
%% Waveform capatures
waveform = CaptureDataFromScopeII(inst);
%% Decode ATQA and locate the Anti-collision reponse 
[~,~,ATQA_last_point,high_lim,low_lim,Anti] = digitize_ATQA(waveform);
%% Pre-defined variables
iteration = 1;                      % Max 32
collision_bit = cell(33,33);        % Store collision for each iteraion
halt_collision_bit = cell(33,33);   % Store the collision bit in halt loop
PICC = cell(33,1);                 % Store the decoded tag's UID
BCC = cell(33,1);                  % Store the BCC
NVB_initial = 20;                   % Number of valid bits
SELECT = {'ZXXYZXYZXX';             % '93' Select cascade level
          'ZXYXYXYZXX';             % '95'
          'ZXXXYXYZXY'};            % '97'
CL = 1;                             % CL is set to be '93'
choose = 0;                         % The collision bit is set as 0;
%% Anti-collision process
while iteration < 33
    % Reset the sub-loop
    sub_iteration = 0;  
    same_bits_length = 0;      % Count the same bits' length
    [~,ANTI_bits_num,pre_decoded_bits,collision_bit{iteration,1}] = collision_detection(Anti,low_lim,same_bits_length,iteration,sub_iteration);
    % Single card
    if isempty(collision_bit{iteration,1}) && iteration == 1
        [response,message_frames,UID,BCC] = digitize_ANTI(Anti,high_lim);
        break;
    % Multi-card
    elseif isempty(collision_bit{iteration,1}) && iteration ~= 1
        same_bits = [];
        choose = [];
        [PICC{iteration,1},BCC{iteration,1}] = digitize_PICC(Anti,choose,same_bits);
        break;
    else
        %% Anti-collision loop
        sub_iteration = 1;
        while sub_iteration < 33 && ~isempty(collision_bit{iteration,sub_iteration})
            % Anti-collision Command = [SEL, NVB, UIDcln]
            first_col = collision_bit{iteration,sub_iteration}(1);
            % Calculate the added NVB (XY: X: num of byte, Y: num of bit)
            NVB_added = mod((first_col-1),9) + floor((first_col-1)/9)*10;
            % Define the chosen cascade level
            SEL = SELECT{CL};
            % Translate the NVB from binary to sequence
            [~,NVB] = translate_command(num2str(NVB_initial + NVB_added), SEL(end));
            % Form UIDcln
            if sub_iteration > 1
                % Assign the previous same bits
                pre_same_bits = same_bits;
                % Assign the current same bits 
                same_bits = pre_decoded_bits(2:first_col-1);
                % Check the same bits' length
                length_check = length(same_bits);
                % Form the new same bits
                same_bits = [choose; pre_same_bits;same_bits]; % set choose as '0'
                % Re-check the length
                same_bits = same_bits(1:length_check);
            else
                % Only used for the first sub-iteration
                same_bits = pre_decoded_bits(2:first_col-1);
            end
            % Translate UIDcln from binary to sequence
            UIDcln = translate_uidcln(same_bits,NVB(end));
            % Add the choose's and end's sequence
            if first_col == 2
                switch NVB(end)
                    case 'X'
                        choose_end = 'YZY'; % set choose as '0'
                    case 'Y'
                        choose_end = 'ZZY'; % set choose as '0'
                    case 'Z'
                        choose_end = 'ZZY'; % set choose as '0'
                end
            else 
                switch UIDcln(end)
                    case 'X'
                        choose_end = 'YZY'; % set choose as '0'
                    case 'Y' 
                        choose_end = 'ZZY'; % set choose as '0'
                    case 'Z'
                        choose_end = 'ZZY'; % set choose as '0'
                end
            end
            % form the new anti-collision command
            New_ANTI_Command = [SEL, NVB, UIDcln, choose_end];
            % Send the new anti-collision command
            send_new_ANTI(f, New_ANTI_Command);
            % Capture the waveform
            waveform_PICC = CaptureDataFromScopeII(inst);
            % Search the high limit and low limit of the new waveform
            [new_high_lim,new_low_lim] = limit_searching(waveform_PICC);
            % Measure the length of same bits
            same_bits_length = length(same_bits) + 1;
            % Detect the collision
            [~,ANTI_bits_num,pre_decoded_bits,collision_bit{iteration,sub_iteration+1}] = collision_detection(waveform_PICC, new_low_lim, same_bits_length,iteration,sub_iteration);
            % Increase the iteration
            sub_iteration = sub_iteration + 1;
        end
    end
    %% Decode UID
    [PICC{iteration,1},BCC{iteration,1}] = digitize_PICC(waveform_PICC,choose,same_bits);
    %% Select command
    [select_command_sequence] = select_command(PICC{iteration,1},BCC{iteration,1},SELECT{CL});
    %% Halt command
    halt_command(select_command_sequence,inst,f);
    %% Validate the halt command
    disp("Halt Command Validation")
    [low_lim] = halt_validation(SEL,collision_bit,inst,f,iteration,select_command_sequence,NVB_initial,choose);
    %% Send REQA and ANTI command
    Anti = resend_ANTI(f,inst);
    iteration = iteration + 1;
end
%% Print the results
if iteration > 1
    picc_isEmptyCell = cellfun(@isempty, PICC);
    card_number = length(find(picc_isEmptyCell == 0));
    fprintf('PICC List: %d tags are detected.', card_number);
    fprintf('\n');
    for i = 1:card_number
        fprintf('PICC %d: ', i);
        for j = 1:4
            fprintf('%s', PICC{i,1}(j,:));
            fprintf(' ')
        end
        fprintf('\n');
    end
end
%% Clear the visaOBJ and serialport with Arduino
clear inst
clear f