classdef CameraAndorZyla < YMicroscope.Camera
    % class of the andor zyla camera
    % 11/3/2015
    
    properties (Access = private, Hidden = true)
        mm % handle for micromanager
    end
    
    properties (Constant)
        roi_options = ...
            {'2160 x 2560','1024 x 1344','512 x 512','256 x 256'};
    end
    
    methods
        % constructor
        function obj =  CameraAndorZyla()
            obj.label = 'AndorZyla';
            obj.exposure = 200;
            obj.roi =  '2160 x 2560';
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
            catch exception
                throw(exception);
            end
        end
        
        % print camera properties
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
        
        % get the size of roi
        function size=getSize(obj)
            strs=strsplit(obj.roi,' x ');
            width=str2double(strs{1});
            height=str2double(strs{2});
            size=[width,height];
        end
        
        % set exposure
        function setExposure(obj,exposure_input)
            if exposure_input < 0
                exception=MException('Camera:NegativeExposure','negative exposure');
                throw(exception);
            else
                % if I set obj.exposure to a const. val. here, then if I
                % change the exposure value in the GUI and then change the
                % illumination mode, the exposure time is set to the const.
                % val. irrespective of what was entered in the GUI -
                % 01/26/17 SEP
                obj.exposure = exposure_input;
                % nothing is outputted into the command window if the
                % following has no semicolon at the end. Additionally, if I
                % comment this out, then no updates are made whatsoever to
                % the exposure time (even when switching between
                % illumination modes). 
                obj.mm.setExposure(obj.exposure); 
                notify(obj,'ExposureDidSet');
%                 return;
            end
        end
        
        % set roi
        function setRoi(obj,roi_input)
            if strcmp(roi_input,'2160 x 2560')
                obj.mm.clearROI();
            elseif strcmp(roi_input,'1024 x 1344')
                obj.mm.setROI(608,568,1344,1024)
            elseif strcmp(roi_input,'512 x 512')
                obj.mm.setROI(824,1024,512,512);
            elseif strcmp(roi_input,'256 x 256')
                obj.mm.setROI(952,1152,256,256);
            else
                exception=MException('Camera:UnsupportedROI','ROI not supported');
                throw(exception);
            end
            obj.roi=roi_input;
            notify(obj,'RoiDidSet');
            return;
        end
        
        % capture a single image
        function img = capture (obj)
            obj.mm.snapImage();
            img = obj.mm.getImage();
            width = obj.mm.getImageWidth();
            height = obj.mm.getImageHeight();
            img = reshape(img, [width, height]);
            % there is a bad pixel in zyla camera
            if numel(img) == 5529600
                img(5527206)= 0;
            end
%             disp('CameraAndorZyla.m capture a single image')
        end
        
        % prepare for image snap shot type of image acquisition
        function prepareModeSnapshot (obj)
            andorCam = 'Andor sCMOS Camera';
            % set exposure to external
            obj.mm.setProperty(andorCam, ...
                'TriggerMode', 'Software (Recommended for Live Mode)');
        end
        
        % prepare for sequence type of image acquisition
        function prepareModeSequence (obj)
            andorCam = 'Andor sCMOS Camera';
            obj.mm.setProperty(andorCam,...
                'TriggerMode', 'External Exposure');
            obj.mm.clearCircularBuffer();
            obj.mm.initializeCircularBuffer();
            obj.mm.prepareSequenceAcquisition(andorCam);
        end
        
        % start a image sequnce
        function startSequenceAcquisition(obj)
            obj.mm.startContinuousSequenceAcquisition(0);
        end
        
        % stop a image sequnce
        function stopSequenceAcquisition(obj)
            obj.mm.stopSequenceAcquisition;
        end
        
        % pop out next image on stack
        function img=popNextImage(obj)
            if obj.mm.isBufferOverflowed
                warning('camera buffer over flowed, try set larger memory for the camera');
            end
            if obj.mm.getRemainingImageCount()>0
                imgtmp=obj.mm.popNextImage();
                width = obj.mm.getImageWidth();
                height = obj.mm.getImageHeight();
                img = reshape(imgtmp, [width, height]);
            else
                img=[];
            end
        end
        
        % get most recent image
        function img=getLastImage(obj)
            img=obj.mm.getLastImage();
            % there is a bad pixel in zyla camera
            if numel(img) == 5529600
                img(5527206)= 0;
            end
            width = obj.mm.getImageWidth();
            height = obj.mm.getImageHeight();
            img = reshape(img, [width, height]);
        end
        
        % object destructor
        function delete(obj)
            obj.mm.reset();
            display('Andor Zyla camera disconnected')
        end
        
        % get tiff tag, for saving tiff images
        tagstruct = getTiffTag(obj)

    end
end

