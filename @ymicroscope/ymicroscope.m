classdef ymicroscope < handle
    %controlling microscope
    
    properties
        % equipment handles
        nidaq % handle of ni daq, in control of piezo stage
        nidaq2 %handle of ni daq to allow for control of b-field LEDs
        mm % handle of micro manager, in control of zyla camera
        sola % handle of com port 3, in control of sola illuminator
        
        % file system
        datasavepath='C:\microscope_pics';
        datasavepath2 = 'C:\microscope_log';
        
        % text file headers
        header1 = 'Date';
        header2 = 'Time';
        header3 = 'Illum. Mode';
        header4 = 'Exposure (ms)';
        header5 = 'Display Size';
        header6 = 'Frame Rate (Hz)';
        header7 = 'No. of Stacks';
        header8 = 'Z Step Size (px)';
        
        % constants
        % piezo conversion
        um_per_volts=200/10;
        um_per_pix=6.5/100;
        
        % scanning parameters
        numstacks=61;
        stepsize=1;
        dataoffset = 1;
        
        % ui handles
        figure_handle
        imageaxis_handle
        
        % microscope parameters
        exposure_brightfield=40; %(ms)
        exposure_fluorescent=100; %(ms)
        framerate=10; %(fps )
        
        % ROI setting
        img_width = 2560; %image width (number of pixels)
        img_height = 2160; %image height(number of pixels)
        display_size = '2160 x 2560';

        % microscope status
        is_live_running=0
        is_zstack_runnning=0
        is_movie_running=0
        is_focusing = 0
        illumination_mode='brightfield';

    end
    
    properties (Dependent)
        volts_per_pix;
        exposure
        ROIwidth %region of interest width
        ROIheight %region of interest height
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
                exposure=[];
                warning('Exposure N/A');
            end
        end
        
        function ROIwidth=get.ROIwidth(obj)
            if sum(strcmp(obj.display_size,{'2160 x 2560','1024 x 1344',...
                    '512 x 512','256 x 256'})) > 0
                ROIwidth=obj.img_width;    
            else
                ROIwidth=[];
                warning('Image Width N/A');
            end
        end
        
        function ROIheight=get.ROIheight(obj)
            if sum(strcmp(obj.display_size,{'2160 x 2560','1024 x 1344',...
                    '512 x 512','256 x 256'})) > 0
                ROIheight=obj.img_height;
            else
                ROIheight=[];
                warning('Image Height N/A');
            end
        end
        
        function value=get.volts_per_pix(obj)
            value=obj.um_per_pix/obj.um_per_volts;
        end
        
        function set.dataoffset(obj,dataoffset)
            if dataoffset<=0
                obj.dataoffset=0;
                warning('dataoffset goes below zero');
            elseif dataoffset>=10
                obj.dataoffset=10;          
                warning('dataoffset goes above ten');
            else
            obj.dataoffset=dataoffset;
            end
        end
        
        % functions
        obj = Capture(obj,hobj,event);
        obj = Live(obj,hobj,event);
        obj = SetupUI(obj);
        obj = Zscan(obj,hobj,event);
        obj = Movie(obj,hobj,event);
    end
    
end

