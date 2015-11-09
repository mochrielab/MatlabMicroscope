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

            % add camera
            obj.camera = zylacamera ();
            % 
            %create nidaq session
            obj.nidaq=daq.createSession('ni');
            % add light sources
%             obj.lightsources(1:2)=Lightsource.empty;
%             obj.lightsources(1)=RGBlight('com4','brightfield');
%             obj.lightsources(2)=Solalight('com3','fluorescent');
            obj.lightsources=[RGBlight('com4','brightfield'),Solalight('com3','fluorescent')];
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
    
    events
    end
    
end
