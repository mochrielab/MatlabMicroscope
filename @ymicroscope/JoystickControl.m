function [  ] = JoystickControl( obj )
% control the stage with joystick

% read stage position
fscanf(obj.priorXYstage);
fprintf(obj.priorXYstage,'%s\r','PS');
pos = fscanf(obj.priorXYstage);
pos = strsplit(pos,',');
x=str2double(pos{1});
y=str2double(pos{2});
if ~isnan(x)
    obj.pos_x = x;
end
if ~isnan(y);
    obj.pos_y = y;
end

while obj.joystick_enabled
    
    % get desired position
    obj.pos_movespeed = (exp((-axis(obj.joystick,3)+1)/2)-1)/(exp(1)-1);
    dx=axis(obj.joystick,1);
    dy=axis(obj.joystick,2);
    if abs(dx)>0.05
    obj.pos_x = obj.pos_x + round(dx*100000*obj.pos_movespeed);
    end
    if abs(dy)>0.05
    obj.pos_y = obj.pos_y - round(dy*100000*obj.pos_movespeed);
    end
    
    % change position
    if abs(dx)>0.05 || abs(dy)>0.05
    fprintf(obj.priorXYstage,'%s\r',...
        ['G,',num2str(obj.pos_x),',',num2str(obj.pos_y)]);
    end
    
    display([num2str(obj.pos_movespeed),' ',...
        num2str(obj.pos_x),num2str(obj.pos_y)]);
    pause(.5);
end

end

