function [ obj ] = Movie( obj,hobj,event )
%taking a movie

% do a movie

if strcmp(obj.status,'standing') && strcmp(get(hobj,'String'),'Start Movie')
    set(hobj,'String','Stop Movie')
    
    % movie mod 1
    for itmp=1:strcmp(obj.movie_mode,'zstack_plain')
        obj.status = 'movie_running_zstack_plain';
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
        obj.mm.setExposure(obj.exposure); % set exposure time, ????? work or not
        obj.mm.clearCircularBuffer(); % clear the buffer for image storage
        
        %image type
        if obj.mm.getBytesPerPixel == 2
            pixelType = 'uint16';
        else
            pixelType = 'uint8';
        end
        
        for iloop=1:obj.moviecycles
            if strcmp(obj.status,'standing')
                break;
            end
            obj.nidaq.queueOutputData([zdata,camtrigger])
            
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
            
            % grab frame (take 0.7 second)
            istack=0;
            img3=uint16(zeros(height,width,numstacks));
            while obj.mm.getRemainingImageCount()>0
                istack=istack+1;
                imgtmp=obj.mm.popNextImage();
                img = reshape(imgtmp, [width, height]);
                img3(:,:,istack)=img';
            end
            
            % save data
            tic
            t=clock;
            datepath=fullfile(obj.datasavepath,...
                [num2str(t(2),'%02d'),'_',num2str(t(3),'%02d'),'_',num2str(t(1))]);
            if ~exist(datepath)
                mkdir(datepath);
            end
            
            IllumMode = obj.illumination_mode;
            Exposure = obj.exposure;
            DispSize = obj.display_size;
            FrameRate = obj.framerate;
            NumbStacks = obj.numstacks;
            StepSize = obj.stepsize;
            
            save(fullfile(datepath,['movie_',...
                num2str(t(4),'%02d'),'_',num2str(t(5),'%02d'),'_',...
                num2str(round(t(6)),'%02d')])...
                ,'IllumMode','Exposure','DispSize','FrameRate','NumbStacks'...
                ,'StepSize','img3');
            
            fid=fopen([obj.datasavepath2,filesep,'ImgLog.txt'],'a+');
            fprintf(fid, '%10s %15s %20s %20d %20s %20d %20d %20d \r\n',...
                [num2str(t(2),'%02d'),'\',num2str(t(3),'%02d'),'\',num2str(t(1))],...
                [num2str(t(4),'%02d'),':',num2str(t(5),'%02d'),':',...
                num2str(round(t(6)),'%02d')],obj.illumination_mode,...
                obj.exposure,obj.display_size,obj.framerate,obj.numstacks,obj.stepsize);
            fclose(fid);
            toc
            
            %% Autofocusing section
            %             Nframes = size(img3,3);
            %             SumSqGrad = ImgGrad(Nframes,img3); %function that will find the sum
            %             FocusLoc = LorentzPkFit(Nframes,SumSqGrad);
            %             startLoc = round(numstacks/2); %initial starting location
            %             stkDiff = startLoc - FocusLoc; %how many levels apart the in-focus plane is
            %             TotVolts = stkDiff.*obj.volts_per_pix;
            %             obj.dataoffset=obj.dataoffset+TotVolts;
            
            %% pause
            for ipause =1:60*obj.movieinterval
                if strcmp(obj.status,'standing')
                    break
                end
                pause(1);
            end
        end
        set(hobj,'String','Start Movie')
        obj.status = 'standing';
    end
    
%     % movie mod 2
%     for itmp=1:strcmp(obj.movie_mode,'susan_exp1')
%         %%
% 
%         
%         
%         
%     end
elseif strcmp(obj.status,'movie_running_zstack_plain')
    obj.status = 'standing';
    set(hobj,'String','Stopping')
else
    msgbox(['error: microscope is ',obj.status]);
end

