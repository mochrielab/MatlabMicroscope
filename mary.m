%% run only FIRST time 

% load java package
dirpath='C:\Program Files\Micro-Manager-1.4\plugins\Micro-Manager';
files=dir(fullfile(dirpath,'*.jar'));
for ifile=1:length(files)
    javaaddpath(fullfile(dirpath,files(ifile).name));
end
display('finished loading java path');
% start program
obj=ymicroscope();

%% a capure

obj.illumination_mode = 'Brightfield - W';
obj.exposure_brightfield = 50 ;% (ms)
img = obj.Capture;
%% capture with automated save
obj.datasavepath='I:\mary';
obj.experiment_name='Maryexperiment';
obj.Capture;

%% visualize a image
SI(img);
%% z scan
obj.illumination_mode = obj.illumination_mode_options{4};
obj.display_size = obj.display_size_options{4};
obj.zoffset = 1;
obj.stepsize = 1;
obj.numstacks = 11; % odd number
obj.framerate = 10;
img3 = obj.Zscan;

%% visualize img3
ImgViewer3D(img3)

%% movies
obj.movie_cycles = 1;
obj.movie_interval =1; %(mins)
% obj.movie_mode
obj.Movie;




