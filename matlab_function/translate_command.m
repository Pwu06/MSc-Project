function [binaryOut,seqOut] = translate_command(hexIn,SEL_end)
%     % Prompt the user for input
%     hexIn = input('Please enter a hexadecimal number: ', 's');
    % Check if the input is a string. If not, it is likely not a valid hexadecimal.
    if ~isstring(hexIn) && ~ischar(hexIn)
        error('Input must be a string or char array.')
    end
    binaryOut = hexToBinaryVector(hexIn);
    
    % Calculate the number of binary digits needed
    binaryDigitsNeeded = length(hexIn) * 4;

    % Add leading zeros to the binary output if necessary
    zeros_added = binaryDigitsNeeded - length(binaryOut);
    binaryOut = char(binaryOut + '0');
    binaryOut = [repmat('0', [1, zeros_added]), binaryOut];
    binaryOut = flip(binaryOut);
    % pre-define variables
    if SEL_end == 'Y' || SEL_end == 'Z'
        inZeroSequence = true;
    else
        inZeroSequence = false;
    end
    count = 0;
    seqOut = [];
    for i = 1:length(binaryOut)
        % If the character is '1', add 'X' to the output sequence
        if binaryOut(i) == '1'
            seqOut = [seqOut, 'X'];
            % Since we encountered a '1', we're no longer in a sequence of '0's
            inZeroSequence = false;
            count = count + 1;
        % If the character is '0'
        elseif binaryOut(i) == '0'
            % If we're already in a sequence of '0's, add 'Z' to the output sequence
            if inZeroSequence
                seqOut = [seqOut, 'Z'];
            % If this is the first '0' in a sequence, add 'Y' to the output sequence
            else
                seqOut = [seqOut, 'Y'];
                % We're now in a sequence of '0's
                inZeroSequence = true;
            end
        end
    end
    if mod(count,2) == 1 && seqOut(end) == 'Y'
        seqOut = [seqOut, 'Z'];
        binaryOut = [binaryOut, '0'];
    elseif mod(count,2) == 1 && seqOut(end) == 'Z'
        seqOut = [seqOut, 'Z'];
        binaryOut = [binaryOut, '0'];
    elseif mod(count,2) == 1 && seqOut(end) == 'X'  
        seqOut = [seqOut, 'Y'];
        binaryOut = [binaryOut, '0'];
    elseif mod(count,2) == 0 
        seqOut = [seqOut, 'X'];
        binaryOut = [binaryOut, '1'];
    end
end

