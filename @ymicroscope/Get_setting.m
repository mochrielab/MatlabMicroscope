function [ setting ] = Get_setting( obj )
%a function to get a complete setting of the microscope
    setting.numstacks = obj.numstacks;
    setting.stepsize = obj.stepsize;
    setting.zoffset = obj.zoffset;
    setting.framerate = obj.framerate;
    setting.illumination_mode = obj.illumination_mode;
    setting.exposure_brightfield = obj.exposure_brightfield;
    setting.exposure_fluorescent = obj.fluorescent;
    setting.movie_mode = obj.movie_mode;
    setting.movie_interval = obj.movie_interval;
    setting.movie_cycles = obj.movie_cycles;

end

