classdef (Abstract) Lightsource
    %abstract class for light source
    % Yao Zhao 11/7/2015
    
    properties (Constant)
        color_options = {''};
    end
    
    properties (SetAccess = private)
        exposure
        intensity
        com % handle for comp port
        color
    end
    
    methods
        setExposure(obj);
        setIntensity(obj,intensity);
        turnOn(obj);
        turnOff(obj);
        setColor(obj,string);
    end
    
end

