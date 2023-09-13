function inst = InitialiseScope
warning('off','all')
visaAddress = 'USB0::2391::6054::MY52492257::INSTR';
% 'USB0::0x2A8D::0x1766::MY58493131::0::INSTR';
%%
		
% Connect to the instrument and set the buffer size and instrument timeout
inst = visa('keysight', visaAddress);


inst.InputBufferSize = 10000000; % This may need to be adjusted (depth * 2) + 1 should be enough
% Set the timeout value
inst.Timeout = 10;
% Set the Byte order
inst.ByteOrder = 'littleEndian';

fopen(inst);

%Sig_Ch = ['CHAN',num2str(Sig_Ch_Num)];


%fprintf(inst,'*RST; :AUTOSCALE');
% fprintf(inst, '*IDN?')
% fscanf(inst, '%s')



% fprintf(inst,':TIMebase:SCALe 30e-6');
% fprintf(inst,':TIMebase:POSition 180e-6');

fprintf(inst, ':TRIGGER:SOURCE CHAN2'); 
fprintf(inst, ':TRIGGER:EDGE:SLOPE POSITIVE');
fprintf(inst, ':TRIGGER:LEVEL 2.5');
fprintf(inst, ':TRIGGER:SWEEP NORM');

% fprintf(inst,':TIMebase:SCALe 200e-6');  % scale
% fprintf(inst,':TIMebase:POSition 0');    % delay

% atqa
% fprintf(inst,':TIMebase:SCALe 50e-6');     % new
% fprintf(inst,':TIMebase:POSition 76e-6');      % new
% 
% anti
fprintf(inst,':TIMebase:SCALe 100e-6');     % new
fprintf(inst,':TIMebase:POSition 160e-6');      % new

% sak
% fprintf(inst,':TIMebase:SCALe 200e-6');     % new
% fprintf(inst,':TIMebase:POSition 0');      % new

fprintf(inst, ':TRIGGER:LEVEL 2.5');

fprintf(inst,':CHAN1:IMP FIFTy');
fprintf(inst,':CHAN2:IMP ONEMeg');

fprintf(inst,':CHAN1:SCALe 0.5'); 
fprintf(inst,':CHAN2:SCALe 5'); 

% fprintf(inst,':CHAN1:SCALe 20e-3');
% fprintf(inst,':CHAN3:OFFSet 120e-3');

%CPF1
% fprintf(inst,':CHAN3:SCALe 1e-3');
% fprintf(inst,':CHAN3:OFFSet 4e-3');
% 
% 
% fprintf(inst,':CHAN3:SCALe 50e-3');
% fprintf(inst,':CHAN3:OFFSet 0e-3');

% fwrite(inst, '*cls');
% fwrite(inst, ':single');

% Set the initial instrument parameters
% fprintf(inst, '*RST');
% fprintf(inst, ':stop;:cdis');
% fprintf(inst, '*OPC?'); Junk = str2double(fscanf(inst));
% fprintf(inst, [':', Sig_Ch, ':DISPLAY ON']);
% fprintf(inst, '*OPC?'); Junk = str2double(fscanf(inst));
% fprintf(inst, [':acquire:srate ', num2str(Sample_Rate)]);
% fprintf(inst, ':acquire:srate?')
% fscanf(inst, '%s')

% fprintf(inst, ':TRIGGER:EDGE:SLOPE POSITIVE');
% fprintf(inst, [':TRIGGER:LEVEL ', Sig_Ch, ',0.0']);
% fprintf(inst, ':ACQUIRE:MODE RTIME');
% fprintf(inst, [':AUTOSCALE:VERTICAL ', Sig_Ch]);
% fprintf(inst, '*OPC?'); Junk = str2double(fscanf(inst));

fclose(inst);

end