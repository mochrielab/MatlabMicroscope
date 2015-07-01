% Sola connection:
Sola = serial('COM3');
fopen(Sola);
%% initialize
fprintf(Sola,'%s',char([hex2dec('57') hex2dec('02') hex2dec('FF') hex2dec('50')]));
fprintf(Sola,'%s',char([hex2dec('57') hex2dec('03') hex2dec('AB') hex2dec('50')]));
disp('Sola connected!!!')
%%
% Source enables/disable:
fprintf(Sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
fprintf(Sola,'%s',char([hex2dec('4F') hex2dec('7B') hex2dec('50')])); % Enable red channels

fprintf(Sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels

fprintf(Sola,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') hex2dec('08') hex2dec('F0') hex2dec('00') hex2dec('50')])); % Set the intensity to 0x00(maximum)

% Set intensity:
fprintf(Sola,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') hex2dec('04') hex2dec('F0') hex2dec('00') hex2dec('50')])); % Set the intensity to 0x00(maximum)
fprintf(Sola,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') hex2dec('04') hex2dec('FF') hex2dec('F0') hex2dec('50')])); % Set the intensity to 0xFF(minimum)
fprintf(Sola,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') hex2dec('04') hex2dec('FA') hex2dec('A0') hex2dec('50')])); % Set the intensity to 0xAA(170/255; 66%)

% susan this command will turn on the blue fluorescent channel for the GFP
% dye or any other green dyes
fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
% susan this command will turn off the blue fluorescent channel for the GFP
% dye or any other green dyes
fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
