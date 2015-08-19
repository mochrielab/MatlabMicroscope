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