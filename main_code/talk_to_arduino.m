close all 
clear 
clc
%% Define the serial port and baud rate
port = "COM3"; % port = "/dev/tty.usbmodem143101" for Macbook;
baudrate = 9600;
%% Commands pre-defined
No_information = repmat('Y',[1,50]);
Wait_information = repmat('Y',[1,75]);
WUPA = 'AZZXYZXYXYY';
REQA = 'AZZXXYZXYZY';
ANTI = 'ZXXYZXYZXXYZZZZXYZZZY';
HALT = 'ZZZZZXYXYXYZZZZZZZXXXXYXYXYZXYXXYZXXYZY';
%% create a serialport object
f = serialport(port, baudrate);
configureTerminator(f,'LF');
pause(2)
%% Command starts here
%% Field on
writeline(f,['AYY','\n'])
%% REQA
% writeline(f,[REQA,'\n'])
%% WUPA
% writeline(f,WUPA,'\n')
%% REQA and Anti
writeline(f,[REQA,No_information,ANTI,'\n']);
%% Check the sent command
% response = [];
% tic;
%     while true
%         % Read character(s) from the serial port
%         data = readline(f);
%         
%         % Display the received character(s)
%         if ~isempty(data)
%             response = [response; data];
%             fprintf('%s\n', data);
%         end
%         p = toc;
%         if p > 10
%             break;
%         end
%     end