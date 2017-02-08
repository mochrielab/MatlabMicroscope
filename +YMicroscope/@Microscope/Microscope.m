classdef Microscope < handle
    %class for microscope
    %   Yao Zhao 11/3/2015
    
    % microscope states
    properties (Constant)
        % microscope status
        % change status to dependent later
        status_options = {'idle','stopping','live','zstack','movie','capture'};
        % data path to save captures
        datapath='I:\microscope_pics';
    end
    
    % handles to devices
    properties (SetAccess = protected)
        camera % camera
        
        xystage % xy stage
        zstage % z stage
        
        controllers % all controllers
        controller % current controller
        %         controller_options % all possible controller
        
        status % current status
        
        lightsource
        lightsources % light sources
        
        illumination % current light source
        
        trigger % trigger for synchronized aquisition
        
        islighton % status of the illumination;
    end
    
    properties (SetAccess = protected, Dependent)
        illumination_options % illumination options
    end
    
    properties (Constant)
        % light on options
        % always on: light is on all the time
        % minimal exposure: only light on when exposing
        % off: light is off
        lighton_options = {'always on', 'minimal exposure', 'off'}
    end
    
    % current status of the microscope
    properties
    end
    
    methods
        % constructor
        function obj=Microscope()
            obj.setup();
        end
        
        % initial setup for specific devices
        setup(obj)
        
        % set status of the microscope
        function setStatus (obj, status_in)
            for ii=1:length(obj.status_options)
                if strcmp(obj.status_options{ii},status_in)
                    obj.status = status_in;
                    notify(obj, 'StatusDidSet');
                    return;
                end
            end
            warning('invalid status input, status not set');
        end
        
        % get status of the microscope
        function status = getStatus(obj)
            status = obj.status;
        end
        
        % set light on with option
        setLight(obj, option);
        
        % set property value
        didset=setProperty(obj,name, value)
        
        % get property value
        value=getProperty(obj,tag)
        
        % get device handle with label
        handle=getDeviceHandle(obj,label)
        
        % get illumination options
        function val = get.illumination_options(obj)
            val = [];
            for ls = obj.lightsources
                for color = ls.color_options
                    val = [val, {[ls.label,' - ',color{1}]}];
                end
            end
        end
        
        %set illuminations
        setIllumination(obj, str)
        
        % lock the microscope with some action
        function lock(obj,action)
            if strcmp(obj.status,'idle')
                obj.status = action.label;
            else
                exception=MException('Microscope:LockUnable',...
                    ['can''t lock the microscope while ',obj.status]);
                throw(exception);
            end
            notify(obj, 'DidLock');
        end
        
        % unlock the microscope
        function unlock(obj,action)
            if strcmp(obj.status,action.label)
                obj.status = 'idle';
            else
                exception=MException('Microscope:UnLockUnable',...
                    'can''t unlock the microscope');
                throw(exception);
            end
            notify(obj, 'DidUnlock');
        end
        
        % grab the overall settings of the microscope
        settings=getSettings(obj)
        
        % get current light source
        function ls=getLightsource(obj)
            ls = obj.lightsource;
%             labelidx1 = obj.lightsource.label
        end
        
        % select light source with index
        setLightsource(obj,str)
        
        % reset microscope status
        function reset(obj)
            obj.status = 'idle';
            warning('only use when debugging')
        end
        
        % destructor
        function delete(obj)
            display('closing...');
        end
    end
    
    methods (Static)
        
    end
    
    events
        IlluminationDidSet
        StatusDidSet
        DidLock
        DidUnlock
        %         DidStart
        %         DidFinish
    end
end
