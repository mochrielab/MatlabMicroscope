classdef Zylacamera < handle
    % class of the andor zyla camera
    % 11/3/2015
    
    properties (SetAccess = private, Hidden = true)
        mm % handle for micromanager
    end
    
    properties (Constant)
        roi_options = ...
            {'2160 x 2560','1024 x 1344','512 x 512','256 x 256'};
    end
    
    properties (SetAccess = private)
        exposure = 200;
        roi =  '2160 x 2560';
    end
    
    methods
        % constructor
        function obj =  Zylacamera()
            % load micro manager
            import mmcorej.*;
            obj.mm=CMMCore();
            try
                % set buffer size for image storage: 16 GB
                obj.mm.setCircularBufferMemoryFootprint(16000);
                % set dynamic range of the camera to 16 bit
                obj.mm.setProperty('Andor sCMOS Camera',...
                    'Sensitivity/DynamicRange',...
                    '16-bit (low noise & high well capacity)')
                obj.mm.setProperty('Andor sCMOS Camera',...
                    'ElectronicShutteringMode','Global');
                %obj.mm.setProperty('Andor sCMOS Camera','ElectronicShutteringMode','Rolling');
                disp('Camera successfully connected!');
            catch exp
                warning(['Camera not connected:',exp.message]);
            end
        end
        
        function printCameraProperties(obj)
            properties = obj.mm.getDevicePropertyNames('Andor sCMOS Camera');
            for i=1:properties.size
                property_name = properties.get(i-1);
                display(['property name: ',char(property_name)]);
                value = obj.mm.getAllowedPropertyValues('Andor sCMOS Camera', property_name);
                for ii=0:value.size-1
                    display(['value ',num2str(ii),': ',char(value.get(ii))])
                end
                if value.size == 0
                    display('empty')
                end
                disp(['current value is: ',...
                    char(obj.mm.getProperty('Andor sCMOS Camera',property_name))]);
                fprintf('\n\n')
            end
        end
        
        % set exposure
        function setExposure(obj,exposure_input)
            if exposure_input < 0
               warning('negative exposure')
            else
                obj.exposure = exposure_input;
                obj.mm.setExposure(obj.exposure);
            end
        end
        
        function setRoi(obj,roi_input)
            for i=1:length(obj.roi_options)
                if strcmp(roi_input, obj.roi_options{i})
                    obj.roi=roi_input;
                    return;
                end
            end
            warnning('roi input not valid');
        end
        
        % capture a single image
        function img = capture (obj)
            andorCam = 'Andor sCMOS Camera';
            % set exposure to external
            obj.mm.setProperty(andorCam, ...
                'TriggerMode', 'Software (Recommended for Live Mode)'); 
            obj.mm.snapImage();
            img = obj.mm.getImage();
            width = obj.mm.getImageWidth();
            height = obj.mm.getImageHeight();
            img = reshape(img, [width, height]);
        end
        
        % start a image stack
        function img3 = zstack(obj)
        end
        
    end
    
end

