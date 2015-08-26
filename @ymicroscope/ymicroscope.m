classdef ymicroscope < handle
    %controlling microscope
    
    properties
        % equipment handles
        nidaq % handle of ni daq, in control of piezo stage
        nidaq2 %handle of ni daq to allow for control of b-field LEDs
        mm % handle of micro manager, in control of zyla camera
        sola % handle of com port 3, in control of sola illuminator
        
        % file system
        datasavepath='I:\microscope_pics';
%         datasavepath2 = 'C:\microscope_log';
        
        % constants
        % piezo conversion
        um_per_volts=200/10;
        um_per_pix=6.5/100;
        
        % scanning parameters
        numstacks=61;
        stepsize=1;
        zoffset = 1;
        
        % ui handles
        figure_handle
        imageaxis_handle
        
        % microscope parameters
        exposure_brightfield=40; %(ms)
        exposure_fluorescent=50; %(ms)
        fluorescent_illumination_intensity=50; %(0-255)
        framerate=10; %(fps )
        illumination_mode='None';
        movie_mode = 'zstack_plain';
        movie_interval = 0;
        movie_cycles = 2;
        
        % ROI setting
        img_width = 2560; %image width (number of pixels)
        img_height = 2160; %image height(number of pixels)
        display_size = '2160 x 2560';

        % microscope status
        status = 'standing'
    
    end
    
    properties (Dependent)
        volts_per_pix;
        exposure
    end
    
    methods
        % contructor
        function obj=ymicroscope()
%           % load java path
            warning off;
            dirpath='C:\Program Files\Micro-Manager-1.4\plugins\Micro-Manager';
            files=dir(fullfile(dirpath,'*.jar'));
            for ifile=1:length(files)
                javaaddpath(fullfile(dirpath,files(ifile).name));
            end
            warning on;
            display('finished loading java path');
            % load micro manager
            import mmcorej.*;
            obj.mm=CMMCore();
            try
            obj.mm.loadSystemConfiguration (...
                'C:\Program Files\Micro-Manager-1.4\MMConfig_andorzyla.cfg');
            catch expname
                warning('Turn on the camera!');
            end
            % set buffer size for image storage: 16 GB
            obj.mm.setCircularBufferMemoryFootprint(16000); 
            % set dynamic range of the camera to 16 bit
            obj.mm.setProperty('Andor sCMOS Camera',...
                'Sensitivity/DynamicRange',...
                '16-bit (low noise & high well capacity)')
            disp('Camera connected!!!');
            % load ni daq
            % devices = daq.getDevices;
            obj.nidaq=daq.createSession('ni');
            ch11 = obj.nidaq.addAnalogOutputChannel('Dev1',0,'Voltage');
            ch11.Name = 'Z scan (output)';
            ch12 = obj.nidaq.addAnalogInputChannel('Dev1',0,'Voltage');
            ch12.Name = 'Z position (input)';
            ch13 = obj.nidaq.addDigitalChannel('Dev1','Port0/Line0','OutputOnly');
            ch13.Name = 'camera triggering (output)';
            % add session for digital input and output controlling
            % fluorescence
            obj.nidaq2 = daq.createSession('ni');
            ch21=obj.nidaq2.addDigitalChannel('Dev1','Port0/Line1','OutputOnly');
            ch21.Name = 'Illumination White (output)';
            ch22=obj.nidaq2.addDigitalChannel('Dev1','Port0/Line2','OutputOnly');
            ch22.Name = 'Illumination Red (output)';
            % set output voltage zero
            obj.nidaq.outputSingleScan([0 0]);
            obj.nidaq2.outputSingleScan([0 0]);
            
            disp('Piezo output voltage set to zero!!!')
            disp('Brightfield Illumination OFF')
            
            % initialize the illuminator
            obj.sola = serial('COM3');
            fopen(obj.sola);
            fprintf(obj.sola,'%s',char([hex2dec('57') hex2dec('02') hex2dec('FF') hex2dec('50')]));
            fprintf(obj.sola,'%s',char([hex2dec('57') hex2dec('03') hex2dec('AB') hex2dec('50')]));
            disp('Sola connected!!!')
        end
        % destroyer
        function delete(obj)
            obj.nidaq.outputSingleScan([0 0]);
            obj.nidaq2.outputSingleScan([0 0]);
            fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
        end
        
        % override get function
        function exposure=get.exposure(obj)
            if sum(strcmp(obj.illumination_mode,{'Brightfield - W','Brightfield - R','None'}))>0
                exposure=obj.exposure_brightfield;
            elseif strcmp(obj.illumination_mode,'Fluorescent')
                exposure=obj.exposure_fluorescent;
            else
                exposure=0;
            end
        end
        
        function value=get.volts_per_pix(obj)
            value=obj.um_per_pix/obj.um_per_volts;
        end
        
        % set z off set
        function set.zoffset(obj,zoffset)
            if zoffset<=0
                obj.zoffset=0;
                warning('zoffset goes below zero');
            elseif zoffset>=10
                obj.zoffset=10;          
                warning('zoffset goes above ten');
            else
            obj.zoffset=zoffset;
            end
        end
        
        % set sola illuminatin intensity
        function set.fluorescent_illumination_intensity(obj,fluorescent_illumination_intensity)
            if fluorescent_illumination_intensity<0
                obj.fluorescent_illumination_intensity=0;
                warning('zoffset goes below zero');
            elseif fluorescent_illumination_intensity>255
                obj.fluorescent_illumination_intensity=255;          
                warning('zoffset goes above 255');
            else
            obj.fluorescent_illumination_intensity=fluorescent_illumination_intensity;
            end
            obj.SetSolaIntensity;
        end
        
        % main functions
        function obj = Reset(obj)
            obj.status = 'standing';
        end
        img = Capture(obj,hobj,event);
        obj = Live(obj,hobj,event);
        obj = SetupUI(obj);
        img3 = Zscan(obj,hobj,event);
        obj = Movie(obj,hobj,event);
        obj = ZFocus(obj,hobj,event);
        obj = DAQpkg(obj,hobj,event);
        obj = SwitchLight( obj, on_or_off );
        tagstruct = GetImageTag( obj, camlabel );
        obj = SetSolaIntensity(obj);
        setting = GetSetting(obj);
        obj = SetSetting(obj,setting);
        %delete later?
%         obj = ImgSeq(obj,hobj,event);

    end
    
end

