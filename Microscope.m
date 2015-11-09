classdef Microscope < handle
    %class for microscope
    %   Yao Zhao 11/3/2015
    
    % microscope states
    properties (Constant)
       status_options = {'idle','stopping','live','zstack','movie'};
       % piezo conversion
        um_per_volts=200/10;
        um_per_pix=6.5/100;
    end
    
    properties (Dependent)
        volts_per_pix
    end
    
    % handles to devices
    properties (SetAccess = public)
        nidaq % handle of ni daq
        camera % camera
        lightsources % light sources
        xystage % xy stage
        zstage % z stage
        joystick % joystick
        status % current status
        currentlightsourceindex % current light source
    end
    
    % current status of the microscope
    properties
    end    
    
    methods
        % constructor
        function obj=Microscope()
            % add camera
            obj.camera = ZylaCamera ();
            %create nidaq session
            obj.nidaq=daq.createSession('ni');
            % add light sources
            obj.lightsources=[RGBlight('com4','brightfield'),...
                Solalight('com3','fluorescent')];
            obj.currentlightsourceindex=1;
            % add xy stage
            obj.xystage = PriorXYStage('com5');
            % add joystick
            obj.joystick = LogitechJoystick();
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
        
        function value=get.volts_per_pix(obj)
            value=obj.um_per_pix/obj.um_per_volts;
        end
        
        function switchLight(obj, on_or_off)
            if strcmp(on_or_off,'off')
                obj.lightsources(obj.currentlightsourceindex).turnOn;
            elseif strcmp(on_or_off,'on')
                obj.lightsources(obj.currentlightsourceindex).turnOff;
            end
            warning('unrecognized switch light command');
        end
        
        % set property value
        function didset=setProperty(obj,name, value)
            % set properties for the devices and processes
            try
                names=strsplit(name,' ');
                devicename=names{1};
                propname=names{2};
                handle=obj.getDeviceHandle(devicename);
                didset=handle.(['set',captalize(propname),'(value)']);
            catch exception
                warning(['error setProperty:',exception.message])
                didset=false;
            end
            function Name=captalize(name)
                Name=[upper(name(1)),lower(name(2:end))];
            end
        end
        
        % get property value
        function value=getProperty(obj,name)
            try
                names=strsplit(name,' ');
                devicename=names{1};
                propname=names{2};
                handle=obj.getDeviceHandle(devicename);
                value=handle.(propname);
            catch exception
                warning(['error getProperty:',exception.message])
                value=[];
            end
        end
        
        % run action
        function didrun=runAction(obj,action)
        end
        
        % get device handle with label
        function handle=getDeviceHandle(obj,label)
            props=properties(obj);
            for i=1:length(props)
                if obj.(props{i}).isprop('label')
                    if strcmp(obj.(props{i}).label,label)
                        handle=obj.(props{i});
                        return
                    end
                end
            end
        end
        
        function delete(obj)
            
        end
    end
    
    methods (Static)

    end
    
    events
    end
    
end
