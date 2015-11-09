classdef (Abstract) Lightsource < handle & matlab.mixin.Heterogeneous
    %abstract class for light source
    % Yao Zhao 11/7/2015
    
    properties (SetAccess = protected)
        label
        exposure = 200;
        intensity = 1;
        com % handle for comp port
        color
        ison
    end
    
    methods %(Abstract)
        setExposure(obj);
        setIntensity(obj,intensity);
        turnOn(obj);
        turnOff(obj);
        setColor(obj,string);
    end
    
    events
        ExposureDidSet
        IntensityDidSet
        ColorDidSet
    end
    
end

