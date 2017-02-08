classdef (Abstract) Lightsource < handle & matlab.mixin.Heterogeneous
    %abstract class for light source
    % Yao Zhao 11/7/2015
    
    % When exposure is changed in GUI, no update in figure window unless
    % re-select the illumination mode - why????? 01/25/17 SEP

    properties (SetAccess = protected)
        % label
        label
        % exposure
        exposure = 200;
        % intensity
        intensity = 1;
        % power
        power = 100; % 01/25/17 SEP
        % color
        color
        % status
        ison = 0;
    end
    
    properties (Constant, Abstract)
        color_options
    end
    
    properties (Access = protected)
        com % handle for comp port
    end
    
    methods (Abstract)
        setExposure(obj,exposure_input); % 01/25/17 SEP
        setIntensity(obj,intensity);
        setPower(obj,power); % 01/25/17 SEP
        turnOn(obj);
        turnOff(obj);
        setColor(obj,string);
    end
    
    events
        ExposureDidSet
        IntensityDidSet
        ColorDidSet
        PowerDidSet
        DidTurnOn
        DidTurnOff
    end
    
end

