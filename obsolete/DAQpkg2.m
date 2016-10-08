function [ obj ] = DAQpkg2( obj, hobj,event )
% Collects series of images (captures and zstacks) with varying fps

%08/15/15 --> need to work on how to save nicely, and have program loop
%until field of view has had its components photobleached!

%08/17/15

if strcmp(obj.display_size,'2160 x 2560')
    msgbox('error: must select smaller ROI')
else
    t1=clock;
    datepath=fullfile(obj.datasavepath,...
        [num2str(t1(2),'%02d'),'_',num2str(t1(3),'%02d'),'_',num2str(t1(1))]);
    if ~exist(datepath)
        mkdir(datepath);
    end
    
    prompt = {'Enter Sample Name:'}; %field of view name...
    dlg_title = 'Image File Save';
    num_lines = 1;
    sample_name = cell2mat(inputdlg(prompt,dlg_title,num_lines));
    
    %     imgpath = fullfile(obj.datasavepath,...
    %         [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))],sample_name);
    %     if ~exist(imgpath)
    %         mkdir(imgpath);
    %     end
    
    %while image hasn't photobleached
    
    %% Capture to determine average pixel intensity
    %     %Change illumination mode to fluorescence
    %     fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
    %     obj.nidaq2.outputSingleScan([0 0]);
    %
    %     if strcmp(obj.status,'standing')
    %         obj.mm.setExposure(obj.exposure_fluorescent);
    %         axes(obj.imageaxis_handle);
    %         obj.mm.snapImage();
    %         img = obj.mm.getImage();
    %
    %         width = obj.mm.getImageWidth();
    %         height = obj.mm.getImageHeight();
    %
    %         if obj.mm.getBytesPerPixel == 2
    %             pixelType = 'uint16';
    %         else
    %             pixelType = 'uint8';
    %         end
    %         img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
    %         img = reshape(img, [width, height]); % image should be interpreted as a 2D array
    %         img = transpose(img);                % make column-major order for MATLAB
    %         % plot
    %         cla %clear current axis
    %         imagesc(img);colormap gray;axis image;axis off
    %         drawnow;
    %     else
    %         img=getimage(obj.imageaxis_handle);
    %     end
    
    intensity_firstimage = 10;% mean(img(:)); %first image with 'max mean intensity'
    tmpImg = intensity_firstimage; %temporary image first equal to the template
    counter = 1;
    
    while tmpImg >= (0.10)*intensity_firstimage %run while temporary image is
        %geq 10 percent of the template image
        
        %attempt here for stop
        if strcmp(obj.status,'Stopping')
            break;
        end
        
        %% 40 images at 20 ms exposure rate (40 fps)
        
        %Change illumination mode to fluorescence
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
        obj.nidaq2.outputSingleScan([0 0]);
        
        expRate = 20; %exposure rate
        frameRate = 40; %frames per second acquisition
        
        if expRate + 4.4 >= 1000/frameRate
            msgbox('error: exposure is longer than the frame interval')
        elseif strcmp(obj.status,'standing')
            obj.status = '25ms_images';
            set(hobj,'String','25ms Imgs Running')
            pause(.01)
            
            % set scanning parameters
            Nimgs = obj.stepsize.*ones(1,frameRate);
            width = obj.mm.getImageWidth(); % image width
            height = obj.mm.getImageHeight(); % image height
            NframesTot=length(Nimgs);
            
            % initialize ni daq
            rate_multiplier = 2;
            obj.nidaq.Rate = frameRate * rate_multiplier; % set data acquisition rate
            obj.nidaq.IsContinuous=0; % continuous writing
            
            % prepare data to send
            zdata=Nimgs*obj.volts_per_pix+obj.dataoffset; % data to send
            numdata = length(zdata); % length and data
            zdata = reshape(ones(rate_multiplier,1)*zdata,...
                rate_multiplier*numdata,1); % data for z scan at clock rate
            camtrigger = reshape([1;zeros(rate_multiplier-1,1)]*ones(1,numdata),...
                rate_multiplier*numdata,1); % trigger for camera
            obj.nidaq.queueOutputData([zdata,camtrigger])
            
            % log piezo position
            piezopos = zeros(size(zdata));
            counter = 0;
            data_pointer = libpointer('doublePtr',piezopos);
            counter_pointer = libpointer('doublePtr',counter);
            lh = addlistener(obj.nidaq,'DataAvailable',... % remember to delete pointer
                @(src,event)Nidaq_Data_log(src,event,data_pointer,counter_pointer));
            
            % camera setting (take 4 seconds!)
            andorCam = 'Andor sCMOS Camera';
            obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); % set exposure to external
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHECK!!!!!!
            obj.mm.setExposure(expRate); % set exposure time 20 ms
            obj.mm.clearCircularBuffer(); % clear the buffer for image storage
            
            %image type
            if obj.mm.getBytesPerPixel == 2
                pixelType = 'uint16';
            else
                pixelType = 'uint8';
            end
            
            % prepare data acquisition
            obj.mm.initializeCircularBuffer();
            obj.mm.prepareSequenceAcquisition(andorCam);
            
            % start acquisition
            obj.mm.startContinuousSequenceAcquisition(0);
            obj.nidaq.startBackground;
            
            % live in background
            while obj.nidaq.IsRunning
                img = obj.mm.getLastImage();
                img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
                img = reshape(img, [width, height]); % image should be interpreted as a 2D array
                img = transpose(img);                % make column-major order for MATLAB
                axes(obj.imageaxis_handle);cla;
                imagesc(img);colormap gray;axis image;axis off
                drawnow;
            end
            
            % warning for buffer overflow
            if obj.mm.isBufferOverflowed
                warning('camera buffer over flowed, try set larger memory for the camera');
            end
            display(['number of images in buffer: ',...
                num2str(obj.mm.getRemainingImageCount())]);
            
            % ending acquisition
            obj.nidaq.outputSingleScan([obj.dataoffset,0]); % reset starting position
            obj.nidaq.stop;
            delete(lh);
            obj.mm.stopSequenceAcquisition;
            
            set(hobj,'String','Prep Save')
            pause(.01)
            % grab frame (take 0.7 second)
            istack=0;
            img3=uint16(zeros(height,width,NframesTot));
            while obj.mm.getRemainingImageCount()>0
                istack=istack+1;
                imgtmp=obj.mm.popNextImage();
                img = reshape(imgtmp, [width, height]);
                img3(:,:,istack)=img';
            end
            
            %08/18/15 addition
            if counter == 1
                intensity_firstimage = mean(mean(img3(:,:,1)));
                tmpImg = intensity_firstimage;
            else
                tmpImg = mean(mean(img3(:,:,1)));
            end
            
            set(hobj,'String','25ms Imgs Saving')
            pause(.01)
            
            
            % save data
            tic
            
            IllumMode = obj.illumination_mode;
            Exposure = obj.exposure;
            DispSize = obj.display_size;
            FrameRate = obj.framerate;
            NumbStacks = obj.numstacks;
            StepSize = obj.stepsize;
            
            t = clock;
            
            imgpath = fullfile(obj.datasavepath,...
                [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))],sample_name);
            if ~exist(imgpath)
                mkdir(imgpath);
            end
            
            save(fullfile(imgpath,['25ms_',...
                num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
                num2str(round(t(6)),'%02d')])...
                ,'IllumMode','Exposure','DispSize','FrameRate','NumbStacks'...
                ,'StepSize','img3');
            
            fid=fopen([obj.datasavepath2,filesep,'ImgLog.txt'],'a+');
            fprintf(fid, '%10s %15s %20s %20d %20s %20d %20d %20d \r\n',...
                [num2str(t(2),'%02d'),'\',num2str(t(3),'%02d'),'\',num2str(t(1))],...
                [num2str(t(4),'%02d'),':',num2str(t(5),'%02d'),':',...
                num2str(round(t(6)),'%02d')],'25msImg',...
                obj.exposure,obj.display_size,obj.framerate,obj.numstacks,obj.stepsize);
            fclose(fid);
            %     set(hobj,'String','Zstack')
            toc
            
            obj.status = 'standing';
        else
            msgbox(['error: microscope is ',obj.status]);
        end
        
        %% 100 images at 5 ms exposure rate (100 fps)
        
        %Change illumination mode to fluorescence
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
        obj.nidaq2.outputSingleScan([0 0]);
        
        expRate = 5;
        frameRate = 100;
        
        if expRate + 4.4 >= 1000/frameRate
            msgbox('error: exposure is longer than the frame interval')
        elseif strcmp(obj.status,'standing')
            obj.status = '10ms_images';
            set(hobj,'String','10ms Imgs Running')
            pause(.01)
            
            % set scanning parameters
            Nimgs = obj.stepsize.*ones(1,frameRate);
            width = obj.mm.getImageWidth(); % image width
            height = obj.mm.getImageHeight(); % image height
            NframesTot=length(Nimgs);
            
            % initialize ni daq
            rate_multiplier = 2;
            obj.nidaq.Rate=frameRate * rate_multiplier; % set data acquisition rate
            obj.nidaq.IsContinuous=0; % continuous writing
            
            % prepare data to send
            zdata=Nimgs*obj.volts_per_pix+obj.dataoffset; % data to send
            numdata = length(zdata); % length and data
            zdata = reshape(ones(rate_multiplier,1)*zdata,...
                rate_multiplier*numdata,1); % data for z scan at clock rate
            camtrigger = reshape([1;zeros(rate_multiplier-1,1)]*ones(1,numdata),...
                rate_multiplier*numdata,1); % trigger for camera
            obj.nidaq.queueOutputData([zdata,camtrigger])
            
            % log piezo position
            piezopos = zeros(size(zdata));
            counter = 0;
            data_pointer = libpointer('doublePtr',piezopos);
            counter_pointer = libpointer('doublePtr',counter);
            lh = addlistener(obj.nidaq,'DataAvailable',... % remember to delete pointer
                @(src,event)Nidaq_Data_log(src,event,data_pointer,counter_pointer));
            
            % camera setting (take 4 seconds!)
            andorCam = 'Andor sCMOS Camera';
            obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); % set exposure to external
            %%%%%%%%%%%%%%%%%%%%%%%%%%%% CHECK!!!!
            obj.mm.setExposure(expRate); % set exposure time 5 ms
            obj.mm.clearCircularBuffer(); % clear the buffer for image storage
            
            %image type
            if obj.mm.getBytesPerPixel == 2
                pixelType = 'uint16';
            else
                pixelType = 'uint8';
            end
            
            % prepare data acquisition
            obj.mm.initializeCircularBuffer();
            obj.mm.prepareSequenceAcquisition(andorCam);
            
            % start acquisition
            obj.mm.startContinuousSequenceAcquisition(0);
            obj.nidaq.startBackground;
            
            % live in background
            while obj.nidaq.IsRunning
                img=obj.mm.getLastImage();
                img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
                img = reshape(img, [width, height]); % image should be interpreted as a 2D array
                img = transpose(img);                % make column-major order for MATLAB
                axes(obj.imageaxis_handle);cla;
                imagesc(img);colormap gray;axis image;axis off
                drawnow;
            end
            
            % warning for buffer overflow
            if obj.mm.isBufferOverflowed
                warning('camera buffer over flowed, try set larger memory for the camera');
            end
            display(['number of images in buffer: ',...
                num2str(obj.mm.getRemainingImageCount())]);
            
            % ending acquisition
            obj.nidaq.outputSingleScan([obj.dataoffset,0]); % reset starting position
            obj.nidaq.stop;
            delete(lh);
            obj.mm.stopSequenceAcquisition;
            
            set(hobj,'String','Prep Save')
            pause(.01)
            % grab frame (take 0.7 second)
            istack=0;
            img3=uint16(zeros(height,width,NframesTot));
            while obj.mm.getRemainingImageCount()>0
                istack=istack+1;
                imgtmp=obj.mm.popNextImage();
                img = reshape(imgtmp, [width, height]);
                img3(:,:,istack)=img';
            end
            set(hobj,'String','100ms Imgs Saving')
            pause(.01)
            
            
            % save data
            tic
            
            IllumMode = obj.illumination_mode;
            Exposure = obj.exposure;
            DispSize = obj.display_size;
            FrameRate = obj.framerate;
            NumbStacks = obj.numstacks;
            StepSize = obj.stepsize;
            
            t = clock;
            
            imgpath = fullfile(obj.datasavepath,...
                [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))],sample_name);
            if ~exist(imgpath)
                mkdir(imgpath);
            end
            
            save(fullfile(imgpath,['10ms_',...
                num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
                num2str(round(t(6)),'%02d')])...
                ,'IllumMode','Exposure','DispSize','FrameRate','NumbStacks'...
                ,'StepSize','img3');
            
            fid=fopen([obj.datasavepath2,filesep,'ImgLog.txt'],'a+');
            fprintf(fid, '%10s %15s %20s %20d %20s %20d %20d %20d \r\n',...
                [num2str(t(2),'%02d'),'\',num2str(t(3),'%02d'),'\',num2str(t(1))],...
                [num2str(t(4),'%02d'),':',num2str(t(5),'%02d'),':',...
                num2str(round(t(6)),'%02d')],'10msImg',...
                obj.exposure,obj.display_size,obj.framerate,obj.numstacks,obj.stepsize);
            fclose(fid);
            %     set(hobj,'String','Zstack')
            toc
            
            obj.status = 'standing';
        else
            msgbox(['error: microscope is ',obj.status]);
        end
        
        %% 10 images at 95 ms exposure rate (10 fps)
        
        %Change illumination mode to fluorescence
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
        obj.nidaq2.outputSingleScan([0 0]);
        
        expRate = 50;
        frameRate = 10;
        
        if expRate + 4.4 >= 1000/frameRate
            msgbox('error: exposure is longer than the frame interval')
        elseif strcmp(obj.status,'standing')
            obj.status = '100ms_images';
            set(hobj,'String','100ms Imgs Running')
            pause(.01)
            
            % set scanning parameters
            Nimgs = obj.stepsize.*ones(1,frameRate);
            width = obj.mm.getImageWidth(); % image width
            height = obj.mm.getImageHeight(); % image height
            NframesTot=length(Nimgs);
            
            % initialize ni daq
            rate_multiplier = 2;
            obj.nidaq.Rate=frameRate * rate_multiplier; % set data acquisition rate
            obj.nidaq.IsContinuous=0; % continuous writing
            
            % prepare data to send
            zdata=Nimgs*obj.volts_per_pix+obj.dataoffset; % data to send
            numdata = length(zdata); % length and data
            zdata = reshape(ones(rate_multiplier,1)*zdata,...
                rate_multiplier*numdata,1); % data for z scan at clock rate
            camtrigger = reshape([1;zeros(rate_multiplier-1,1)]*ones(1,numdata),...
                rate_multiplier*numdata,1); % trigger for camera
            obj.nidaq.queueOutputData([zdata,camtrigger])
            
            % log piezo position
            piezopos = zeros(size(zdata));
            counter = 0;
            data_pointer = libpointer('doublePtr',piezopos);
            counter_pointer = libpointer('doublePtr',counter);
            lh = addlistener(obj.nidaq,'DataAvailable',... % remember to delete pointer
                @(src,event)Nidaq_Data_log(src,event,data_pointer,counter_pointer));
            
            % camera setting (take 4 seconds!)
            andorCam = 'Andor sCMOS Camera';
            obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); % set exposure to external
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CHECK!!!!!!!!!!!!!!!!!!
            obj.mm.setExposure(expRate); % set exposure time 95 ms
            obj.mm.clearCircularBuffer(); % clear the buffer for image storage
            
            %image type
            if obj.mm.getBytesPerPixel == 2
                pixelType = 'uint16';
            else
                pixelType = 'uint8';
            end
            
            % prepare data acquisition
            obj.mm.initializeCircularBuffer();
            obj.mm.prepareSequenceAcquisition(andorCam);
            
            % start acquisition
            obj.mm.startContinuousSequenceAcquisition(0);
            obj.nidaq.startBackground;
            
            % live in background
            while obj.nidaq.IsRunning
                img=obj.mm.getLastImage();
                img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
                img = reshape(img, [width, height]); % image should be interpreted as a 2D array
                img = transpose(img);                % make column-major order for MATLAB
                axes(obj.imageaxis_handle);cla;
                imagesc(img);colormap gray;axis image;axis off
                drawnow;
            end
            
            % warning for buffer overflow
            if obj.mm.isBufferOverflowed
                warning('camera buffer over flowed, try set larger memory for the camera');
            end
            display(['number of images in buffer: ',...
                num2str(obj.mm.getRemainingImageCount())]);
            
            % ending acquisition
            obj.nidaq.outputSingleScan([obj.dataoffset,0]); % reset starting position
            obj.nidaq.stop;
            delete(lh);
            obj.mm.stopSequenceAcquisition;
            
            set(hobj,'String','Prep Save')
            pause(.01)
            % grab frame (take 0.7 second)
            istack=0;
            img3=uint16(zeros(height,width,NframesTot));
            while obj.mm.getRemainingImageCount()>0
                istack=istack+1;
                imgtmp=obj.mm.popNextImage();
                img = reshape(imgtmp, [width, height]);
                img3(:,:,istack)=img';
            end
            set(hobj,'String','100ms Imgs Saving')
            pause(.01)
            
            
            % save data
            tic
            
            IllumMode = obj.illumination_mode;
            Exposure = obj.exposure;
            DispSize = obj.display_size;
            FrameRate = obj.framerate;
            NumbStacks = obj.numstacks;
            StepSize = obj.stepsize;
            
            t = clock;
            
            imgpath = fullfile(obj.datasavepath,...
                [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))],sample_name);
            if ~exist(imgpath)
                mkdir(imgpath);
            end
            
            save(fullfile(imgpath,['100ms_',...
                num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
                num2str(round(t(6)),'%02d')])...
                ,'IllumMode','Exposure','DispSize','FrameRate','NumbStacks'...
                ,'StepSize','img3');
            
            fid=fopen([obj.datasavepath2,filesep,'ImgLog.txt'],'a+');
            fprintf(fid, '%10s %15s %20s %20d %20s %20d %20d %20d \r\n',...
                [num2str(t(2),'%02d'),'\',num2str(t(3),'%02d'),'\',num2str(t(1))],...
                [num2str(t(4),'%02d'),':',num2str(t(5),'%02d'),':',...
                num2str(round(t(6)),'%02d')],'100msImg',...
                obj.exposure,obj.display_size,obj.framerate,obj.numstacks,obj.stepsize);
            fclose(fid);
            %     set(hobj,'String','Zstack')
            toc
            
            obj.status = 'standing';
        else
            msgbox(['error: microscope is ',obj.status]);
        end
        
        %% Fluorescence z-stack
        
        %Change illumination mode to fluorescence
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
        obj.nidaq2.outputSingleScan([0 0]);
        
        if obj.exposure_fluorescent >= 1000/obj.framerate
            msgbox('error: exposure is longer than the frame interval')
        elseif strcmp(obj.status,'standing')
            obj.status = 'FZScan';
            set(hobj,'String','Z-Stack-Fl')
            pause(.01)
            
            % set scanning parameters
            stacks =(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize; % stack position
            width = obj.mm.getImageWidth(); % image width
            height = obj.mm.getImageHeight(); % image height
            numstacks=length(stacks);
            
            % initialize ni daq
            rate_multiplier = 2;
            obj.nidaq.Rate=obj.framerate * rate_multiplier; % set data acuisition rate
            obj.nidaq.IsContinuous=0; % continuous writing
            
            % prepare data to send
            zdata=stacks*obj.volts_per_pix+obj.dataoffset; % data to send
            numdata = length(zdata); % length and data
            zdata = reshape(ones(rate_multiplier,1)*zdata,...
                rate_multiplier*numdata,1); % data for z scan at clock rate
            camtrigger = reshape([1;zeros(rate_multiplier-1,1)]*ones(1,numdata),...
                rate_multiplier*numdata,1); % trigger for camera
            obj.nidaq.queueOutputData([zdata,camtrigger])
            
            % log piezo position
            piezopos = zeros(size(zdata));
            counter = 0;
            data_pointer = libpointer('doublePtr',piezopos);
            counter_pointer = libpointer('doublePtr',counter);
            lh = addlistener(obj.nidaq,'DataAvailable',... % remember to delete pointer
                @(src,event)Nidaq_Data_log(src,event,data_pointer,counter_pointer));
            
            % camera setting (take 4 seconds!)
            andorCam = 'Andor sCMOS Camera';
            obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); % set exposure to external
            %%%%%%%%%%%%%%% 08/14/15
            obj.mm.setExposure(obj.exposure_fluorescent); % set exposure time, ????? work or not
            %%%%%%%%%%%%%%%
            
            obj.mm.clearCircularBuffer(); % clear the buffer for image storage
            
            %     exposure_fluorescent=100;
            
            %image type
            if obj.mm.getBytesPerPixel == 2
                pixelType = 'uint16';
            else
                pixelType = 'uint8';
            end
            
            % prepare data acquisition
            obj.mm.initializeCircularBuffer();
            obj.mm.prepareSequenceAcquisition(andorCam);
            
            % start acquisition
            obj.mm.startContinuousSequenceAcquisition(0);
            obj.nidaq.startBackground;
            
            % live in background
            while obj.nidaq.IsRunning
                img=obj.mm.getLastImage();
                img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
                img = reshape(img, [width, height]); % image should be interpreted as a 2D array
                img = transpose(img);                % make column-major order for MATLAB
                axes(obj.imageaxis_handle);cla;
                imagesc(img);colormap gray;axis image;axis off
                drawnow;
            end
            
            % warning for buffer overflow
            if obj.mm.isBufferOverflowed
                warning('camera buffer over flowed, try set larger memory for the camera');
            end
            display(['number of images in buffer: ',...
                num2str(obj.mm.getRemainingImageCount())]);
            
            % ending acquisition
            obj.nidaq.outputSingleScan([obj.dataoffset,0]); % reset starting position
            obj.nidaq.stop;
            delete(lh);
            obj.mm.stopSequenceAcquisition;
            
            set(hobj,'String','prepare Saving')
            pause(.01)
            % grab frame (take 0.7 second)
            istack=0;
            img3=uint16(zeros(height,width,numstacks));
            while obj.mm.getRemainingImageCount()>0
                istack=istack+1;
                imgtmp=obj.mm.popNextImage();
                img = reshape(imgtmp, [width, height]);
                img3(:,:,istack)=img';
            end
            set(hobj,'String','FZScan Saving')
            pause(.01)
            
            % save data
            tic
            
            IllumMode = obj.illumination_mode;
            Exposure = obj.exposure;
            DispSize = obj.display_size;
            FrameRate = obj.framerate;
            NumbStacks = obj.numstacks;
            StepSize = obj.stepsize;
            
            t = clock;
            
            imgpath = fullfile(obj.datasavepath,...
                [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))],sample_name);
            if ~exist(imgpath)
                mkdir(imgpath);
            end
            
            save(fullfile(imgpath,['zstack_',...
                num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
                num2str(round(t(6)),'%02d')])...
                ,'IllumMode','Exposure','DispSize','FrameRate','NumbStacks'...
                ,'StepSize','img3');
            
            fid=fopen([obj.datasavepath2,filesep,'ImgLog.txt'],'a+');
            fprintf(fid, '%10s %15s %20s %20d %20s %20d %20d %20d \r\n',...
                [num2str(t(2),'%02d'),'\',num2str(t(3),'%02d'),'\',num2str(t(1))],...
                [num2str(t(4),'%02d'),':',num2str(t(5),'%02d'),':',...
                num2str(round(t(6)),'%02d')],'Fluorescent',...
                obj.exposure,obj.display_size,obj.framerate,obj.numstacks,obj.stepsize);
            fclose(fid);
            %     set(hobj,'String','Zstack')
            toc
            
            obj.status = 'standing';
        else
            msgbox(['error: microscope is ',obj.status]);
        end
        
        %% Brightfield z-stack
        
        %Change illumination mode to be white light for brightfield
        fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7F') hex2dec('50')])); % Disable all channels
        obj.nidaq2.outputSingleScan([1 0]);
        
        if obj.exposure_brightfield >= 1000/obj.framerate
            msgbox('error: exposure is longer than the frame interval')
        elseif strcmp(obj.status,'standing')
            obj.status = 'BZScan';
            set(hobj,'String','Z-stack-Br')
            pause(.01)
            
            % set scanning parameters
            stacks =(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize; % stack position
            width = obj.mm.getImageWidth(); % image width
            height = obj.mm.getImageHeight(); % image height
            numstacks=length(stacks);
            
            % initialize ni daq
            rate_multiplier = 2;
            obj.nidaq.Rate=obj.framerate * rate_multiplier; % set data acquisition rate
            obj.nidaq.IsContinuous=0; % continuous writing
            
            % prepare data to send
            zdata=stacks*obj.volts_per_pix+obj.dataoffset; % data to send
            numdata = length(zdata); % length and data
            zdata = reshape(ones(rate_multiplier,1)*zdata,...
                rate_multiplier*numdata,1); % data for z scan at clock rate
            camtrigger = reshape([1;zeros(rate_multiplier-1,1)]*ones(1,numdata),...
                rate_multiplier*numdata,1); % trigger for camera
            obj.nidaq.queueOutputData([zdata,camtrigger])
            
            % log piezo position
            piezopos = zeros(size(zdata));
            counter = 0;
            data_pointer = libpointer('doublePtr',piezopos);
            counter_pointer = libpointer('doublePtr',counter);
            lh = addlistener(obj.nidaq,'DataAvailable',... % remember to delete pointer
                @(src,event)Nidaq_Data_log(src,event,data_pointer,counter_pointer));
            
            % camera setting (take 4 seconds!)
            andorCam = 'Andor sCMOS Camera';
            obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); % set exposure to external
            %%%%% 08/14/15
            obj.mm.setExposure(obj.exposure_brightfield); % set exposure time, ????? work or not
            %%%%%
            obj.mm.clearCircularBuffer(); % clear the buffer for image storage
            
            %image type
            if obj.mm.getBytesPerPixel == 2
                pixelType = 'uint16';
            else
                pixelType = 'uint8';
            end
            
            % prepare data acquisition
            obj.mm.initializeCircularBuffer();
            obj.mm.prepareSequenceAcquisition(andorCam);
            
            % start acquisition
            obj.mm.startContinuousSequenceAcquisition(0);
            obj.nidaq.startBackground;
            
            % live in background
            while obj.nidaq.IsRunning
                img=obj.mm.getLastImage();
                img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
                img = reshape(img, [width, height]); % image should be interpreted as a 2D array
                img = transpose(img);                % make column-major order for MATLAB
                axes(obj.imageaxis_handle);cla;
                imagesc(img);colormap gray;axis image;axis off
                drawnow;
            end
            
            % warning for buffer overflow
            if obj.mm.isBufferOverflowed
                warning('camera buffer over flowed, try set larger memory for the camera');
            end
            display(['number of images in buffer: ',...
                num2str(obj.mm.getRemainingImageCount())]);
            
            % ending acquisition
            obj.nidaq.outputSingleScan([obj.dataoffset,0]); % reset starting position
            obj.nidaq.stop;
            delete(lh);
            obj.mm.stopSequenceAcquisition;
            
            set(hobj,'String','prepare Saving')
            pause(.01)
            % grab frame (take 0.7 second)
            istack=0;
            img3=uint16(zeros(height,width,numstacks));
            while obj.mm.getRemainingImageCount()>0
                istack=istack+1;
                imgtmp=obj.mm.popNextImage();
                img = reshape(imgtmp, [width, height]);
                img3(:,:,istack)=img';
            end
            set(hobj,'String','BZScan Saving')
            pause(.01)
            
            
            % save data
            tic
            
            IllumMode = obj.illumination_mode;
            Exposure = obj.exposure;
            DispSize = obj.display_size;
            FrameRate = obj.framerate;
            NumbStacks = obj.numstacks;
            StepSize = obj.stepsize;
            
            t = clock;
            
            imgpath = fullfile(obj.datasavepath,...
                [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))],sample_name);
            if ~exist(imgpath)
                mkdir(imgpath);
            end
            
            save(fullfile(imgpath,['zstack_',...
                num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
                num2str(round(t(6)),'%02d')])...
                ,'IllumMode','Exposure','DispSize','FrameRate','NumbStacks'...
                ,'StepSize','img3');
            
            fid=fopen([obj.datasavepath2,filesep,'ImgLog.txt'],'a+');
            fprintf(fid, '%10s %15s %20s %20d %20s %20d %20d %20d \r\n',...
                [num2str(t(2),'%02d'),'\',num2str(t(3),'%02d'),'\',num2str(t(1))],...
                [num2str(t(4),'%02d'),':',num2str(t(5),'%02d'),':',...
                num2str(round(t(6)),'%02d')],'Brightfield - W',...
                obj.exposure,obj.display_size,obj.framerate,obj.numstacks,obj.stepsize);
            fclose(fid);
            set(hobj,'String','ImgSeq')
            toc
            
            obj.status = 'standing';
        else
            msgbox(['error: microscope is ',obj.status]);
        end
        
        %% Check if sample has 'photobleached'
        %end
        %
        %         %Change illumination mode to fluorescence
        %         fprintf(obj.sola,'%s',char([hex2dec('4F') hex2dec('7D') hex2dec('50')])); % Enable all channels
        %         obj.nidaq2.outputSingleScan([0 0]);
        %
        %         if strcmp(obj.status,'standing')
        %             obj.mm.setExposure(obj.exposure_fluorescent);
        %             axes(obj.imageaxis_handle);
        %             obj.mm.snapImage();
        %             img = obj.mm.getImage();
        %
        %             width = obj.mm.getImageWidth();
        %             height = obj.mm.getImageHeight();
        %
        %             if obj.mm.getBytesPerPixel == 2
        %                 pixelType = 'uint16';
        %             else
        %                 pixelType = 'uint8';
        %             end
        %             img = typecast(img, pixelType);      % pixels must be interpreted as unsigned integers
        %             img = reshape(img, [width, height]); % image should be interpreted as a 2D array
        %             img = transpose(img);                % make column-major order for MATLAB
        %             % plot
        %             cla %clear current axis
        %             imagesc(img);colormap gray;axis image;axis off
        %             drawnow;
        %         else
        %             img=getimage(obj.imageaxis_handle);
        %         end
        %
        %         tmpImg = mean(img(:)); %update temporary image to compare with template
        
        
    end
    
    
end
end








