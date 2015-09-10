classdef ymicroscope < handle
    %controlling microscope
    properties (Hidden)
        % equipment handles
        nidaq % handle of ni daq, in control of piezo stage
        nidaq2 %handle of ni daq to allow for control of b-field LEDs
        mm % handle of micro manager, in control of zyla camera
        sola % handle of com port 3, in control of sola illuminator
        priorXYstage % handle of com port 5, in control of the priorXYstage
        joystick % handle of the joystick

        % ui handles
        figure_handle
        imageaxis_handle
    end
    
    properties
        % file system
        datasavepath='I:\microscope_pics';
        
        % constants
        % piezo conversion
        um_per_volts=200/10;
        um_per_pix=6.5/100;
        
        % position of the stage
        pos_x = 0
        pos_y = 0
        pos_movespeed
        
        % scanning parameters
        numstacks=61;
        stepsize=1;
        zoffset = 3;
        
        % microscope parameters
        exposure_brightfield=40; %(ms)
        exposure_fluorescent=50; %(ms)
        fluorescent_illumination_intensity=30; %(0-255)
        framerate=10; %(fps )
        illumination_mode='None';
        illumination_mode_options=...
            {'None','Brightfield - W','Brightfield - R','Fluorescent'};
        movie_mode = 'zstack_plain';
        movie_mode_options = {'zstack_plain','zstack_singlefile','zstack_autofocus'};
        movie_interval = 0;
        movie_cycles = 2;
        autofocus_window = 250;
        
        % ROI setting
        display_size = '2160 x 2560';
        display_size_options = {'2160 x 2560','1024 x 1344','512 x 512','256 x 256'};

        % microscope status
        status = 'standing'
        sample_type = 'E.coli'
        sample_type_options = {'E.coli'};
        joystick_enabled = 0;
        
        % experiment name
        experiment_name = 'newexperiment';
    end
    
    properties (Dependent)
        volts_per_pix;
        exposure
        img_width
        img_height = 2160; %image height(number of pixels)
    end
    
    methods
        % contructor
        function obj=ymicroscope()
%           % load java path
%             warning off;
%             dirpath='C:\Program Files\Micro-Manager-1.4\plugins\Micro-Manager';
%             files=dir(fullfile(dirpath,'*.jar'));
%             for ifile=1:length(files)
%                 javaaddpath(fullfile(dirpath,files(ifile).name));
%             end
%             warning on;
            display('finished loading java path');
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
                disp('Camera connected!');
            catch expname
                warning('Turn on the camera!');
            end
            % load ni daq
            try
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
                disp('Piezo output voltage set to zero!')
                disp('Brightfield Illumination OFF!')
            catch expname
                warning('Connect NIDAQ!');
            end
            
            % initialize the illuminator
            try
                obj.sola = serial('COM3');
                fopen(obj.sola);
                fprintf(obj.sola,'%s',char([hex2dec('57') hex2dec('02') hex2dec('FF') hex2dec('50')]));
                fprintf(obj.sola,'%s',char([hex2dec('57') hex2dec('03') hex2dec('AB') hex2dec('50')]));
                obj.SetSolaIntensity;
                disp('Sola connected!')
            catch expname
                warning('Connect Sola illuminator!');
            end
            
            % initialize STAGE
            try
                obj.priorXYstage = serial('COM5');
                fopen(obj.priorXYstage);
                set(obj.priorXYstage,'timeout',0.01);
                fprintf(obj.priorXYstage,'%s\r','PS');
                pos = fscanf(obj.priorXYstage);
                pos = strsplit(pos,',');
                obj.pos_x = str2double(pos{1});
                obj.pos_y = str2double(pos{2});
                disp('prior stage connected!')
            catch expname
                warning('Connect prior XY Stage!');
            end
            
            % initialize joystick
            try 
                obj.joystick =  vrjoystick(1);
                display('joystick connected!');
            catch expname
                warning('Connect joystick!');
            end
        end
        
        % destroyer
        function delete(obj)
            obj.nidaq.outputSingleScan([0 0]);
            obj.nidaq2.outputSingleScan([0 0]);
            fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
            fclose(obj.sola);
            fclose(obj.priorXYstage);
            close(obj.joystick);
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
        
        function value=get.img_width(obj)
            ind=regexp(obj.display_size,' x ');
            value = str2double(obj.display_size(ind+3:end));
        end
        
        function value=get.img_height(obj)
            ind=regexp(obj.display_size,' x ');
            value = str2double(obj.display_size(1:ind-1));
        end
        
        % set z off set
        function set.zoffset(obj,zoffset)
            if zoffset<0
                obj.zoffset=0;
                warning('zoffset goes below zero');
            elseif zoffset>10
                obj.zoffset=10;          
                warning('zoffset goes above ten');
            else
            obj.zoffset=zoffset;
            end
        end
        
        function set.display_size(obj,display_size)
            obj.display_size = display_size;
            if ~isempty(obj.mm)
                if strcmp(display_size,'2160 x 2560')
                    obj.mm.clearROI();
                elseif strcmp(display_size,'1024 x 1344')
                    obj.mm.setROI(608,568,1344,1024)
                elseif strcmp(display_size,'512 x 512')
                    obj.mm.setROI(824,1024,512,512);
                elseif strcmp(display_size,'256 x 256')
                    obj.mm.setROI(952,1152,256,256);
                else
                    warning('ROI not supported');
                end
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
        function [] = Reset(obj)
            obj.status = 'standing';
        end
        img = Capture(obj,varargin);
        [] = Live(obj,varargin);
        [] = SetupUI(obj);
        img3 = Zscan(obj,varargin);
        [] = Movie(obj,varargin);
        [] = Movie_Singlefile(obj,varargin);
        [] = Movie_ZstackPlain(obj,varargin);
        [] = Go(obj);
        [] = GotoZcenter(obj,img_3d);
        [] = SwitchLight( obj, on_or_off );
        tagstruct = GetImageTag( obj, camlabel );
        [] = SetSolaIntensity(obj);
        setting = GetSetting(obj);
        [] = SetSetting(obj,setting);
        [ filename ] = GetFileHeader( obj, option )
        [] = ZFocus(obj,varargin);
        [ ] = JoystickControl( obj );
        
    end
    
end

