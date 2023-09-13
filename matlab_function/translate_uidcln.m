function [seqOut] = translate_uidcln(binaryIn,NVB_end)
    if NVB_end == 'Z' || NVB_end == 'Y'
        inZeroSequence = true;
    else
        inZeroSequence = false;
    end
    count = 0;
    seqOut = [];
    for i = 1:length(binaryIn)
        % If the num is 1, add 'X' to the output sequence
        if binaryIn(i) == 1
            seqOut = [seqOut, 'X'];
            % Since we encountered a '1', we're no longer in a sequence of '0's
            inZeroSequence = false;
            count = count + 1;
        % If the num is 0
        elseif binaryIn(i) == 0
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
end

