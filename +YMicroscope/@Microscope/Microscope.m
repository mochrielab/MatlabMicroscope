classdef Microscope < handle
    %class for microscope
    %   Yao Zhao 11/3/2015
    
    % microscope states
    properties (Constant)
       % microscope status
       status_options = {'idle','stopping','live','zstack','movie'};
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
        illumination_options % illumination options
        trigger % trigger for synchronized aquisition
        
        isLightOn % status of the illumination;
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
            import YMicroscope.*
            display('initiallizing...')
            % add camera
            obj.camera = CameraAndorZyla ();
            % add light sources
            obj.lightsources=[LightsourceRGB('com6','brightfield'),...
                LightsourceSola('com3','fluorescent')];
            obj.lightsource = obj.lightsources(1);
            %
            obj.illumination_options={obj.lightsources.label};
            obj.illumination=obj.illumination_options{1};
            obj.camera.setExposure(obj.getLightsource.exposure);
            % add xy stage
            obj.xystage = StageXYPrior('com5');
            % add z stage
            obj.zstage = StageZPrior.finescan;
            % add joystick
            obj.controllers = [ControllerJoystickLogitech()];
            obj.controller = obj.controllers(1);
            % add trigger
            obj.trigger=TriggerNidaq();
            % set status
            obj.setStatus('idle');
            display('done')
        end
        
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
        
        % set light on with option
        setLight(obj, option);
        
        % set property value
        function didset=setProperty(obj,name, value)
            % set properties for the devices and processes
            try
                names=strsplit(name,' ');
                devicename=names{1};
                propname=names{2};
                handle=obj.getDeviceHandle(devicename);
                handle.(['set',captalize(propname)])(value);
            catch exception
                warning(['error setProperty:',exception.message])
                didset=false;
            end
            function Name=captalize(name)
                Name=[upper(name(1)),lower(name(2:end))];
            end
        end
        
        % get property value
        function value=getProperty(obj,tag)
            try
                names=strsplit(tag,' ');
                devicename=names{1};
                propname=names{2};
                handle=obj.getDeviceHandle(devicename);
                value=handle.(propname);
            catch exception
                warning(['error getProperty:',exception.message])
                value=[];
            end
        end
        
        % get device handle with label
        function handle=getDeviceHandle(obj,label)
            props=properties(obj);
            for i=1:length(props)
                for j=1:length(obj.(props{i}))
                if isprop(obj.(props{i})(j),'label')
                    if strcmp(obj.(props{i})(j).label,label)
                        handle=obj.(props{i})(j);
                        return
                    end
                end
                end
            end
            handle=[];
            warning(['cant not find device with label:',label])
        end
        
        % lock the microscope with some action
        function lock(obj,action)
            if strcmp(obj.status,'idle')
                obj.status = action.label;
            else
                exception=MException('Microscope:LockUnable',...
                    ['can''t lock the microscope while ',obj.status]);
                throw(exception);
            end
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
        end
        
        % grab the overall settings of the microscope
        function settings=getSettings(obj)
            settings=[];
            props=properties(obj);
            for i=1:length(props)
                for j=1:length(obj.(props{i}))
                    htmp=obj.(props{i})(j);
                    if isprop(htmp,'label')
                        label=htmp.label;
                        props2=properties(htmp);
                        for k=1:length(props2)
                            if ~strcmp(props2{k},'label')
                                settings.([label,'_',props2{k}])...
                                    =htmp.(props2{k});
                            end
                        end
                    end
                end
            end
        end
        
        % select light source with index
        function setIllumination(obj,str)
            % check if string or numeric
            if ischar(str)
                value=find(strcmp(str,obj.illumination_options));
            elseif isnumeric(str)
                value = str;
            end
            % set value
            if length(value)==1
                obj.illumination=obj.illumination_options{value};
                obj.camera.setExposure(...
                    obj.lightsources(value).exposure);
            else
                throw(MException('Microscope:IlluminationNotSupported',...
                    ['illumination mode not supported for ',str]))
            end
        end
        
        % get current light source
        function ls=getLightsource(obj)
            ls = obj.lightsource;
        end
        
        % select light source with index
         setLightsource(obj,str)

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
%         DidStart
%         DidFinish
    end
end
