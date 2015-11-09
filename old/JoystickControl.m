function [  ] = JoystickControl( obj )
% control the stage with joystick

% read stage position
obj.GetStagePosition;

% initialize
velocityX=0;
velocityY=0;
directionX=1;
directionY=1;
looprate=10;
while obj.joystick_enabled
    
    % get speed of x,y movement
%     speed = (exp((-axis(obj.joystick,3)+1)/2)-1)/(exp(1)-1);
    obj.pos_movespeed =speed;
    velocityX= (axis(obj.joystick,1));
    velocityY= (axis(obj.joystick,2));
    dz=0;
    if button(obj.joystick,2);
        dz= -1;
    elseif button(obj.joystick,3);
        dz= 1;
    end
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
    pause(1/looprate);
    
end

end

