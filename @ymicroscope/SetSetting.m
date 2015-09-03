function [  ] = SetSetting( obj,setting )
%set the setting for the obj from a setting file

    obj.numstacks = setting.numstacks;
    obj.stepsize = setting.stepsize;
    obj.zoffset = setting.zoffset;
    
    obj.illumination_mode = setting.illumination_mode;
    obj.exposure_brightfield = setting.exposure_brightfield;
    obj.exposure_fluorescent = setting.exposure_fluorescent;
    obj.fluorescent_illumination_intensity = ...
        setting.fluorescent_illumination_intensity;
    
    obj.framerate = setting.framerate;
    obj.movie_interval = setting.movie_interval;
    obj.movie_cycles = setting.movie_cycles;
    
%     setting.movie_mode = obj.movie_mode;
    obj.status = setting.status;
    obj.um_per_pix = setting.um_per_pix;

end

