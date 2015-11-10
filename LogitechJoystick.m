classdef LogitechJoystick < handle
    % class for logic joystick control
    % 11/8/2015
    %
    %     % rescale XY
    %     velocityX = round(velocityX*speed*3000);
    %     velocityY = round(velocityY*speed*3000);
    %         if abs(dz)>0
    %         obj.zoffset = obj.zoffset + dz*speed*obj.volts_per_pix*looprate*3;
    %         obj.Go('Z');
    %     end
    %
    properties (Access = private)
        joystick
        sensitivity_threshold=.1;
        capture_state = 0
        togglelight_state = 0
        togglelightselection_state = 0
        zoomin_state=0;
        zoomout_state=0;
    end
    
    methods
        function obj =  LogitechJoystick()
            % initialize joystick
            obj.joystick=vrjoystick(1);
            display('joystick connected!');
        end
        
        function emitMotionEvents(obj)
            % emit change event
            speed=obj.getSpeed;
            velocityX= (axis(obj.joystick,1));
            velocityY= (axis(obj.joystick,2));
            dz=0;
            if button(obj.joystick,2);
                dz= -1;
            elseif button(obj.joystick,3);
                dz= 1;
            end
            
            % sensitivity of the joystick
            if abs(velocityX)<obj.sensitivity_threshold
                velocityX=0;
            end
            if abs(velocityY)<obj.sensitivity_threshold;
                velocityY=0;
            end
            % rescale XY
            velocityX = velocityX*speed;
            velocityY = velocityY*speed;
            velocityZ = dz * speed;
            
            % move xy
            if (velocityX~=0 || velocityY~=0 )
                eventdata = ...
                    JoystickEventData(velocityX,velocityY,0);
                notify(obj,'MoveXYStage',eventdata);
            end
            
            % move z
            if (velocityZ~=0)
                eventdata = ...
                    JoystickEventData(0,0,velocityZ);
                notify(obj,'MoveZStage',eventdata);
            end
        end
        
        function emitActionEvents(obj)
            % capture a image
            new_capture_button = button(obj.joystick,1);
            if new_capture_button ==1 && obj.capture_state == 0
                notify(obj,'Capture');
            end
            obj.capture_state = new_capture_button;
            
            % toggle light selection 
            newselection_button = button(obj.joystick,4);
            if newselection_button == 1 && obj.togglelightselection_state == 0
                notify(obj,'ToggleLightSelection');
            end
            obj.togglelightselection_state = newselection_button;
            
            % toggle light on off selection
            newonoff_button = button(obj.joystick,5);
            if newonoff_button == 1 && obj.togglelight_state == 0
                notify(obj,'ToggleLight');
            end
            obj.togglelight_state = newonoff_button;
            
            % zoom in 
            new_zoom_in = button(obj.joystick,9);
            if new_zoom_in == 1 && obj.zoomin_state == 0
                notify(obj,'ZoomIn');
            end
            obj.zoomin_state = new_zoom_in ;
                      
            % zoom out
            new_zoom_out = button(obj.joystick,9);
            if new_zoom_out == 1 && obj.zoomout_state == 0
                notify(obj,'ZoomOut');
            end
            obj.zoomout_state = new_zoom_out ;    
        end
        
        
        function speed=getSpeed(obj)
            speed = (exp((-axis(obj.joystick,3)+1)/2)-1)/(exp(1)-1);
        end
    end
    
    
    events
        MoveXYStage
        MoveZStage
        ToggleLightSelection
        ToggleLight
        Capture
        ZoomIn
        ZoomOut
        
    end
    
end

