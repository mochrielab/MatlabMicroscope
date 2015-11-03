classdef Microscope < handle
    %class for microscope
    %   Yao Zhao 11/3/2015
    
    % microscope states
    enumeration 
            idle(0)
            stopping(1) 
            live(2)
            zstack(3)
            movie(4)
    end
    
    % handles to devices
    properties (SetAccess = private)
        nidaq % handle of ni daq
        mm % handle of micro manager
        camera % camera
        lightsources % light sources
        xystage % xy stage
        zstage % z stage
    end
    
    % current status of the microscope
    properties
        status % current status
        lightsource % current light source
    end    
    
    methods
        % constructor
        function obj=Microscope()
            % load micro manager
            import mmcorej.*;
            obj.mm=CMMCore();
            % create nidaq session
            obj.nidaq=daq.createSession('ni');
            obj.status=Microscope.idle;
        end
        function delete(obj)
        end
    end
    
end
