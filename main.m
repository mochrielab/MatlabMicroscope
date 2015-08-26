 % load java package
dirpath='C:\Program Files\Micro-Manager-1.4\plugins\Micro-Manager';
files=dir(fullfile(dirpath,'*.jar'));
for ifile=1:length(files)
    javaaddpath(fullfile(dirpath,files(ifile).name));
end
display('finished loading java path');
% start program
obj=ymicroscope();
% run
obj.SetupUI;
%%  
% Set intensity:
fprintf(obj.sola,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') hex2dec('04') hex2dec('F0') hex2dec('00') hex2dec('50')])); % Set the intensity to 0x00(maximum)
fprintf(obj.sola,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') hex2dec('04') hex2dec('FF') hex2dec('F0') hex2dec('50')])); % Set the intensity to 0xFF(minimum)
fprintf(obj.sola,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') hex2dec('04') hex2dec('FA') hex2dec('A0') hex2dec('50')])); % Set the intensity to 0xAA(170/255; 66%)

fprintf(obj.sola,'%s',char([hex2dec('53') hex2dec('18') hex2dec('03') hex2dec('04') hex2dec('FF') hex2dec('D0') hex2dec('50')])); % Set the intensity to 0xFF(minimum)
