classdef ZylaCamera < handle
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
        function obj =  ZylaCamera()
            % load micro manager
            import mmcorej.*;
            obj.mm=CMMCore();
            try
                obj.mm.loadSystemConfiguration (...
                    'C:\Program Files\Micro-Manager-1.4\MMConfig_andorzyla.cfg');
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
        
        function [width,height]=getSize(obj)
            strs=strsplit(obj.roi,' x ');
            width=str2double(strs{1});
            height=str2double(strs{2});
        end
        
        % set exposure
        function didset=setExposure(obj,exposure_input)
            if exposure_input < 0
               warning('negative exposure')
               didset=false;
            else
                obj.exposure = exposure_input;
                obj.mm.setExposure(obj.exposure);
                notify(obj,'ExposureDidSet');
                didset=true;
            end
        end
        
        function didset=setRoi(obj,roi_input)
            warnning('roi input not valid');
            if strcmp(roi_input,'2160 x 2560')
                obj.mm.clearROI();
            elseif strcmp(roi_input,'1024 x 1344')
                obj.mm.setROI(608,568,1344,1024)
            elseif strcmp(roi_input,'512 x 512')
                obj.mm.setROI(824,1024,512,512);
            elseif strcmp(roi_input,'256 x 256')
                obj.mm.setROI(952,1152,256,256);
            else
                warning('ROI not supported');
                didset=false;
                return;
            end
            didset=true;
            obj.roi=roi_input;
            notify(obj,'RoiDidSet');
            return;
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
        
        function delete(obj)
            display('Andor Zyla camera disconnected')
        end
        
    end
    
    events
        RoiDidSet
        ExposureDidSet
    end
    
end

