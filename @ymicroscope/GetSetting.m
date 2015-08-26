function [ setting ] = GetSetting( obj )
%a function to get a complete setting of the microscope

    setting.numstacks = obj.numstacks;
    setting.stepsize = obj.stepsize;
    setting.zoffset = obj.zoffset;
    
    setting.illumination_mode = obj.illumination_mode;
    setting.exposure_brightfield = obj.exposure_brightfield;
    setting.exposure_fluorescent = obj.exposure_fluorescent;
    setting.fluorescent_illumination_intensity = ...
        obj.fluorescent_illumination_intensity;
    
    setting.framerate = obj.framerate;
    setting.movie_interval = obj.movie_interval;
    setting.movie_cycles = obj.movie_cycles;
    
%     setting.movie_mode = obj.movie_mode;
    setting.status = obj.status;
    setting.um_per_pix = obj.um_per_pix;

end

