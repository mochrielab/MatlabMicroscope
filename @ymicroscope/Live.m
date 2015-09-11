function [  ] = Live( obj,varargin )
%show live image

if nargin == 1
    update_button = 0;
elseif nargin == 3
    update_button = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end

if strcmp(obj.status,'live_running')
    if update_button
        set(hobj,'String','Start Live');
    end
    obj.status = 'standing';
    obj.SwitchLight('off');
elseif strcmp(obj.status,'standing')
    
    if update_button
        set(hobj,'String','Stop Live');
    end
    obj.status = 'live_running';
    obj.SwitchLight('on');
    
    % set camera to be triggered by the computer
    obj.nidaq.outputSingleScan([obj.zoffset, 0]);
    andorCam = 'Andor sCMOS Camera';
    obj.mm.setProperty(andorCam, 'TriggerMode', 'Software (Recommended for Live Mode)'); % set exposure to external
    
    % initialize joystick
    velocityX=0;
    velocityY=0;
    directionX=1;
    directionY=1;
    looprate=10;
    obj.GetStagePosition;
    capture_button = 0;
    
    while strcmp(obj.status,'live_running')
        try
            % image section
            obj.mm.setExposure(obj.exposure);
            obj.mm.snapImage();
            img = obj.mm.getImage();
            width = obj.mm.getImageWidth();
            height = obj.mm.getImageHeight();
            
            img = reshape(img, [width, height]); % image should be interpreted as a 2D array
            % plot
            axes(obj.imageaxis_handle);
            cla
            imagesc(img);colormap gray;axis image;axis off
            drawnow;
            
            % get speed of x,y movement
            speed = (exp((-axis(obj.joystick,3)+1)/2)-1)/(exp(1)-1);
            obj.pos_movespeed =speed;
            velocityX= (axis(obj.joystick,1));
            velocityY= (axis(obj.joystick,2));
            dz=0;
            if button(obj.joystick,2);
                dz= -1;
            elseif button(obj.joystick,3);
                dz= 1;
            end
            
            new_capture_button = button(obj.joystick,1);
            % capture a image
            if new_capture_button ==1 && capture_button == 0
                obj.Capture;
            end
            capture_button = new_capture_button;
            
            % sensitivity
            sensitivity_threshold = .1;
            if abs(velocityX)<sensitivity_threshold
                velocityX=0;
            end
            if abs(velocityY)<sensitivity_threshold;
                velocityY=0;
            end
            
            % rescale XY
            velocityX = round(velocityX*speed*3000);
            velocityY = round(velocityY*speed*3000);
            
            % update direction
            if sign(velocityX) * directionX <0
                directionX = - sign(velocityX);
                obj.StageCommand(['XD,',num2str(directionX)]);
            end
            if sign(velocityY) * directionY <0
                directionY = - sign(velocityY);
                obj.StageCommand(['XD,',num2str(directionY)]);
            end
            
            % change speed
            obj.StageCommand(['VS,',num2str(velocityX),',',num2str(velocityY)]);
            
            % change z position
            if abs(dz)>0
                obj.zoffset = obj.zoffset + dz*speed*obj.volts_per_pix*looprate*3;
                obj.Go('Z');
            end
            
            % read stage position
            obj.GetStagePosition;

        catch error
            axes(obj.imageaxis_handle);
            cla
            imagesc(0);colormap gray;axis image;axis off
            drawnow;
            warning(['error in live: ',error.identifier]);
        end
    end
else
    msgbox(['error: microscope is ',obj.status]);
end



end


