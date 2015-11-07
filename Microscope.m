classdef Microscope < handle
    %class for microscope
    %   Yao Zhao 11/3/2015
    
    % microscope states
    properties (Constant)
       status_options = {'idle','stopping','live','zstack','movie'};
       lightsource_options = {};
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
            % add camera
            obj.camera = Camera (obj.mm);
            % create nidaq session
            obj.nidaq=daq.createSession('ni');
            % add light sources
            
            % set status
            obj.setStatus('idle');
        end
        
        function setStatus (obj, status_in)
           for ii=1:length(obj.status_options)
                if strcmp(obj.status_options{ii},status_in)
                    obj.status = status_in;
                    return;
                end
           end
           warning('invalid status input');
        end
        
        function delete(obj)
        end
    end
    
end
