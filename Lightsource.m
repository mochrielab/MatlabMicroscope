classdef (Abstract) Lightsource
    %abstract class for light source
    % Yao Zhao 11/7/2015
    properties (SetAccess = private)
        exposure
        intensity
        com % handle for comp port
    end
    
    methods
        setExposure(obj);
        setIntensity(obj,intensity);
        turnOn(obj);
        turnOff(obj);
    end
    
end

