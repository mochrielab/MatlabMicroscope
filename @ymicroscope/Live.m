function [  ] = Live( obj,varargin )
%show live image
if nargin == 1
    UI_enabled = 0;
elseif nargin == 3
    UI_enabled = 1;
    hobj = varargin{1};
    event = varargin{2};
else
    warning('wrong number of input variables');
end


if UI_enabled
    zoffset_handle = obj.getUIHandle('Parameters','z offset (Volts)');
    disp_handle = obj.getUIHandle('Control','Display Size');
end

if strcmp(obj.status,'live_running')
    if UI_enabled
        set(hobj,'String','Start Live');
    end
    obj.status = 'standing';
    obj.SwitchLight('off');
elseif strcmp(obj.status,'standing')
    
    if UI_enabled
        set(hobj,'String','Stop Live');
        pause(.01);
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
    brightfield_button = 0;
    fluorescent_button = 0;
    roi_index = find(strcmp(obj.display_size,obj.display_size_options));
    zoom_in = 0;
    zoom_out = 0;
    
    while strcmp(obj.status,'live_running')
        try
            % image section
            obj.mm.setExposure(obj.exposure);
            obj.mm.snapImage();
            img = obj.mm.getImage();
            width = obj.mm.getImageWidth();
            height = obj.mm.getImageHeight();
            
            img = reshape(img, [width, height]); % image should be interpreted as a 2D array
%             img = transpose(img);
            % plot
            axes(obj.imageaxis_handle);
            cla
            imagesc(img);colormap gray;axis image;axis off
            drawnow;
            
            % get speed of x,y movement
            speed = (exp((-axis(obj.joystick,3)+1)/2)-1)/(exp(1)-1);
            obj.pos_movespeed =speed;
            velocityX= (axis(obj.joystick,2));
            velocityY= -(axis(obj.joystick,1));
            dz=0;
            if button(obj.joystick,2);
                dz= -1;
            elseif button(obj.joystick,3);
                dz= 1;
            end
            
            
            % capture a image
            new_capture_button = button(obj.joystick,1);
            if new_capture_button ==1 && capture_button == 0
                obj.Capture;
            end
            capture_button = new_capture_button;
            
            % turn on bright_field
            new_brightfield_button = button(obj.joystick,4);
            if new_brightfield_button == 1 && brightfield_button == 0
                obj.illumination_mode = obj.illumination_mode_options{2};
                obj.SwitchLight('on');
            end
            brightfield_button = new_brightfield_button;
            
            % turn on fluorescent
            new_fluorescent_button = button(obj.joystick,5);
            if new_fluorescent_button == 1 && fluorescent_button == 0
                obj.illumination_mode = obj.illumination_mode_options{4};
                obj.SwitchLight('on');
            end
            fluorescent_button = new_fluorescent_button;
            
            % zoom in or out
            new_zoom_in = button(obj.joystick,9);
            if new_zoom_in == 1 && zoom_in == 0
                if roi_index < length(obj.display_size_options)
                    roi_index = roi_index + 1 ;
                    obj.display_size = obj.display_size_options{roi_index};
                    set(disp_handle,'Value',roi_index);
                end
            end
            zoom_in = new_zoom_in ;
            
            % zoom in or out
            new_zoom_out = button(obj.joystick,8);
            if new_zoom_out == 1 && zoom_out == 0
                if roi_index >1
                    roi_index = roi_index -1 ;
                    obj.display_size = obj.display_size_options{roi_index};
                    set(disp_handle,'Value',roi_index);
                end
            end
            zoom_out = new_zoom_out ;
                        
            % sensitivity
            sensitivity_threshold = .1;
            if abs(velocityX)<sensitivity_threshold
                velocityX=0;
            end
            if abs(velocityY)<sensitivity_threshold
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
            
            % show x,y,z position
            if UI_enabled
                set(zoffset_handle,'String',num2str(obj.zoffset));
            end

        catch error
            axes(obj.imageaxis_handle);
            cla;
            imagesc(0);colormap gray;axis image;axis off;
            drawnow;
            warning(['error in live: ',error.identifier]);
        end
    end
else
    msgbox(['error: microscope is ',obj.status]);
end



end


