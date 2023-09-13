function [halt_new_low_lim] = halt_validation(SEL,collision_bit,inst,f,iteration,select_command_sequence,NVB_initial,choose)
    num_limt = 1;
    while num_limt < 4
        %% Validate the halt command
        halt_iteration = 1;
        % Send REQA and ANTI command first
        halt_waveform_PICC = resend_ANTI(f,inst);
        % Search the high limit and low limit of the new waveform
        [~,halt_new_low_lim] = limit_searching(halt_waveform_PICC);
        % Measure the length of same bits
        halt_same_bits_length = 0;
        % Detect the collision
        [~,~,halt_pre_decoded_bits,halt_collision_bit{iteration,halt_iteration}] = collision_detection(halt_waveform_PICC, halt_new_low_lim, halt_same_bits_length,iteration,halt_iteration);
        while halt_iteration < 33 && ~isempty(halt_collision_bit{iteration,halt_iteration})
            % Anti-collision Command = [SEL, NVB, UIDcln]
            halt_first_col = halt_collision_bit{iteration,halt_iteration}(1);
            % Calculate the added NVB (XY: X: num of byte, Y: num of bit)
            halt_NVB_added = mod((halt_first_col-1),9) + floor((halt_first_col-1)/9)*10;
            % Translate the NVB from binary to sequence
            [~,halt_NVB] = translate_command(num2str(NVB_initial + halt_NVB_added), SEL(end));
            % Form UIDcln
            if halt_iteration > 1
                % Assign the previous same bits
                halt_pre_same_bits = halt_same_bits;
                % Assign the current same bits 
                halt_same_bits = halt_pre_decoded_bits(2:halt_first_col-1);
                % Check the same bits' length
                halt_length_check = length(halt_same_bits);
                % Form the new same bits
                halt_same_bits = [choose; halt_pre_same_bits;halt_same_bits]; % set choose as '0'
                % Re-check the length
                halt_same_bits = halt_same_bits(1:halt_length_check);
            else
                % Only used for the first sub-iteration
                halt_same_bits = halt_pre_decoded_bits(2:halt_first_col-1);
            end
            % Translate UIDcln from binary to sequence
            halt_UIDcln = translate_uidcln(halt_same_bits,halt_NVB(end));
            % Add the choose's and end's sequence
            if halt_first_col == 2
                switch halt_NVB(end)
                    case 'X'
                        halt_choose_end = 'YZY'; % set choose as '0'
                    case 'Y'
                        halt_choose_end = 'ZZY'; % set choose as '0'
                    case 'Z'
                        halt_choose_end = 'ZZY'; % set choose as '0'
                end
            else 
                switch halt_UIDcln(end)
                    case 'X'
                        halt_choose_end = 'YZY'; % set choose as '0'
                    case 'Y' 
                        halt_choose_end = 'ZZY'; % set choose as '0'
                    case 'Z'
                        halt_choose_end = 'ZZY'; % set choose as '0'
                end
            end
            % form the new anti-collision command
            halt_New_ANTI_Command = [SEL, halt_NVB, halt_UIDcln, halt_choose_end];
            % Send the new anti-collision command
            send_new_ANTI(f, halt_New_ANTI_Command);
            % Capture the waveform
            halt_waveform_PICC = CaptureDataFromScopeII(inst);
            % Search the high limit and low limit of the new waveform
            [~,halt_new_low_lim] = limit_searching(halt_waveform_PICC);
            % Measure the length of same bits
            halt_same_bits_length = length(halt_same_bits) + 1;
            % Detect the collision
            [~,~,halt_pre_decoded_bits,halt_collision_bit{iteration,halt_iteration+1}] = collision_detection(halt_waveform_PICC, halt_new_low_lim, halt_same_bits_length,iteration,halt_iteration);
            halt_iteration = halt_iteration + 1;
        end
        % Check whether the halt collision bit is same with collision bit is
        % the anti-collision loop
        anti_isEmptyCell = cellfun(@isempty, collision_bit);
        anti_isEmptyCell = anti_isEmptyCell(iteration:end,:);
        anti_numNonEmptyElements = sum(sum(~anti_isEmptyCell));
        halt_isEmptyCell = cellfun(@isempty, halt_collision_bit);
        halt_numNonEmptyElements = sum(sum(~halt_isEmptyCell));
        if anti_numNonEmptyElements == halt_numNonEmptyElements && halt_collision_bit{iteration,1}(1) == collision_bit{iteration,1}(1)
            % Re-send the halt command
            disp('The current silent command fails and the command will be retransmitted.')
            halt_command(select_command_sequence,inst,f);
            num_limt = num_limt + 1;
        elseif num_limt == 4
            disp('The halt command failed.')
        else
            disp('One tag has been silent successfully.')
            break;
        end
    end
end
