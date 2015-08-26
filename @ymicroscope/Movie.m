function [ obj ] = Movie( obj,hobj,event )
%taking a movie

% do a movie

if strcmp(obj.status,'standing') && strcmp(get(hobj,'String'),'Start Movie')
    set(hobj,'String','Stop Movie')
    
    % movie mod 1
    for itmp=1:double(strcmp(obj.movie_mode,'zstack_plain'))
        obj.status = 'movie_running_zstack_plain';
        pause(.01)
        
        % prepare for save
        istack=0;
        filename=obj.GetFileHeader('movie');
        imgtif=Tiff(filename,'w8');
        tagstruct = obj.GetImageTag('Andor Zyla 5.5');
        
        % set scanning parameters
        stacks =(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize; % stack position
        width = obj.mm.getImageWidth(); % image width
        height = obj.mm.getImageHeight(); % image height
        
        % initialize ni daq
        rate_multiplier = 2;
        obj.nidaq.Rate=obj.framerate * rate_multiplier; % set data acquisition rate
        obj.nidaq.IsContinuous=0; % continuous writing
        
        % prepare data to send
        zdata=stacks*obj.volts_per_pix+obj.zoffset; % data to send
        numdata = length(zdata); % length and data
        zdata = reshape(ones(rate_multiplier,1)*zdata,...
            rate_multiplier*numdata,1); % data for z scan at clock rate
        camtrigger = reshape([0;1+zeros(rate_multiplier-1,1)]*ones(1,numdata),...
            rate_multiplier*numdata,1); % trigger for camera
        
        % camera setting (take 4 seconds!)
        andorCam = 'Andor sCMOS Camera';
        obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); % set exposure to external
        obj.mm.setExposure(obj.exposure); % set exposure time, ????? work or not
        obj.mm.clearCircularBuffer(); % clear the buffer for image storage
        
        for iloop=1:obj.movie_cycles
            set(hobj,'String',['Stop at ',num2str(iloop)]);
            obj.SwitchLight('on');
            pause(.01)
            if strcmp(obj.status,'standing')
                break;
            end
            obj.nidaq.queueOutputData([zdata,camtrigger;obj.zoffset,0])
            
            % prepare data acquisition
            obj.mm.initializeCircularBuffer();
            obj.mm.prepareSequenceAcquisition(andorCam);
            
            % start acquisition
            obj.mm.startContinuousSequenceAcquisition(0);
            obj.nidaq.startBackground;
            
            % live in background
            while obj.nidaq.IsRunning
                img=obj.mm.getLastImage();
                img = reshape(img, [width, height]); % image should be interpreted as a 2D array
                axes(obj.imageaxis_handle);cla;
                imagesc(img);colormap gray;axis image;axis off
                if obj.mm.getRemainingImageCount()>0
                    istack=istack+1;
                    imgtmp=obj.mm.popNextImage();
                    img = reshape(imgtmp, [width, height]);
                    imgtif.setTag(tagstruct);
                    imgtif.write(img);
                    imgtif.writeDirectory;
                end
                drawnow;
            end
            
            % warning for buffer overflow
            if obj.mm.isBufferOverflowed
                warning('camera buffer over flowed, try set larger memory for the camera');
            end

            % ending acquisition
            obj.nidaq.outputSingleScan([obj.zoffset,0]); % reset starting position
            obj.nidaq.stop;
            obj.mm.stopSequenceAcquisition;
            obj.SwitchLight('off');
                     
            % save data
            while obj.mm.getRemainingImageCount()>0
                istack=istack+1;
                imgtmp=obj.mm.popNextImage();
                img = reshape(imgtmp, [width, height]);
                imgtif.setTag(tagstruct);
                imgtif.write(img);
                imgtif.writeDirectory;
            end
            display(['number of images collected: ',...
                num2str(istack)]);
            
            %% Autofocusing section

            %% pause
            for ipause =1:60*obj.movie_interval
                if strcmp(obj.status,'standing')
                    break
                end
                pause(1);
            end
        end
        % close the image saving
        imgtif.close();
                
        %save setting
        setting=obj.GetSetting;
        save([filename(1:end-3),'mat'],'setting');
        
        set(hobj,'String','Start Movie')
        obj.status = 'standing';
    end
    
    % movie mod 2
    for itmp=1:double(strcmp(obj.movie_mode,'zstack_singlefile'))
        %%
        obj.status = 'movie_running_zstack_singlefile';
        set(hobj,'String','Taking Movie');
        pause(.01)
        
        % prepare for save
        istack=0;
        filename=obj.GetFileHeader('movie');
        imgtif=Tiff(filename,'w8');
        tagstruct = obj.GetImageTag('Andor Zyla 5.5');
        
        % set scanning parameters
        stacks =(-(obj.numstacks-1)/2:(obj.numstacks-1)/2)*obj.stepsize; % stack position
        width = obj.mm.getImageWidth(); % image width
        height = obj.mm.getImageHeight(); % image height
        
        % initialize ni daq
        rate_multiplier = 2;
        obj.nidaq.Rate=obj.framerate * rate_multiplier; % set data acquisition rate
        obj.nidaq.IsContinuous=0; % continuous writing
        
        % prepare data to send
        zdata=stacks*obj.volts_per_pix+obj.zoffset; % data to send
        numdata = length(zdata); % length and data
        zdata = reshape(ones(rate_multiplier,1)*zdata,...
            rate_multiplier*numdata,1); % data for z scan at clock rate
        camtrigger = reshape([0;1+zeros(rate_multiplier-1,1)]*ones(1,numdata),...
            rate_multiplier*numdata,1); % trigger for camera
        
        % camera setting (take 4 seconds!)
        andorCam = 'Andor sCMOS Camera';
        obj.mm.setProperty(andorCam, 'TriggerMode', 'External'); % set exposure to external
        obj.mm.setExposure(obj.exposure); % set exposure time, ????? work or not
        obj.mm.clearCircularBuffer(); % clear the buffer for image storage
        
        % prepare data acquisition
        obj.mm.initializeCircularBuffer();
        obj.mm.prepareSequenceAcquisition(andorCam);
        
        % start acquisition
        obj.mm.startContinuousSequenceAcquisition(0);
        % send data
        obj.nidaq.queueOutputData(repmat([zdata,camtrigger;zdata(end),0],obj.movie_cycles,1))
        obj.nidaq.startBackground;
        obj.SwitchLight('on');
        
        for iloop=1:obj.movie_cycles
            if strcmp(obj.status,'standing')
                break;
            end

            % live in background
            while obj.nidaq.IsRunning
                img=obj.mm.getLastImage();
                img = reshape(img, [width, height]); % image should be interpreted as a 2D array
                axes(obj.imageaxis_handle);cla;
                imagesc(img);colormap gray;axis image;axis off
                if obj.mm.getRemainingImageCount()>0
                    istack=istack+1;
                    imgtmp=obj.mm.popNextImage();
                    img = reshape(imgtmp, [width, height]);
                    imgtif.setTag(tagstruct);
                    imgtif.write(img);
                    imgtif.writeDirectory;
                end
                drawnow;
            end         
            %% Autofocusing section
            %% pause
            for ipause =1:60*obj.movie_interval
                if strcmp(obj.status,'standing')
                    break
                end
                pause(1);
            end
        end

        % ending acquisition
        obj.nidaq.stop;
        obj.nidaq.outputSingleScan([obj.zoffset,0]); % reset starting position
        obj.mm.stopSequenceAcquisition;
        obj.SwitchLight('off');
     
        % warning for buffer overflow
        if obj.mm.isBufferOverflowed
            warning('camera buffer over flowed, try set larger memory for the camera');
        end
            
        % save data
        while obj.mm.getRemainingImageCount()>0
            istack=istack+1;
            imgtmp=obj.mm.popNextImage();
            img = reshape(imgtmp, [width, height]);
            imgtif.setTag(tagstruct);
            imgtif.write(img);
            imgtif.writeDirectory;
        end     
        
        display(['number of images collected: ',...
            num2str(istack)]);
        % close tiff file
        imgtif.close();
                
        %save setting
        setting=obj.GetSetting;
        save([filename(1:end-3),'mat'],'setting');
        
        set(hobj,'String','Start Movie')
        obj.status = 'standing';
    end
    
elseif strcmp(obj.status,'movie_running_zstack_plain') || ...
        strcmp(obj.status,'movie_running_zstack_singlefile')
    obj.status = 'standing';
    set(hobj,'String','Stopping')
else
    msgbox(['error: microscope is ',obj.status]);
end

