joy = vrjoystick(1);
%%
while 1
%     display(':')
    x=axis(joy,1);
    y=axis(joy,2);
%     z=axis(joy,3); + - button, should be accelaration
    display(['axis x: ',num2str(x),' y: ',num2str(y),...
        'unknown ',num2str(z)]);
    b=zeros(1,6);
    for ib=1:6
        b(ib)=button(joy,ib);
    end
    % b1 is fire, capture
    % b2 is z down
    % b3 is z up
    % b4 is left
    % b5 is right
    
    display(b);
    pause(.2)
    
end

%%
function [  ] = JoystickControl( obj )
% control the stage with joystick

% read stage position
obj.GetStagePosition;

while obj.joystick_enabled
    if get(obj.priorXYstage,'BytesToOutput')==0
        % get desired position
        obj.pos_movespeed = (exp((-axis(obj.joystick,3)+1)/2)-1)/(exp(1)-1);
        dx=axis(obj.joystick,1);
        dy=-axis(obj.joystick,2);
        dz=0;
        if button(obj.joystick,2);
            dz= -1;
        elseif button(obj.joystick,3);
            dz= 1;
        end
        
        % sens
        sensitivity_threshold = .05;
        moveX = abs(dx)>sensitivity_threshold;
        moveY = abs(dy)>sensitivity_threshold;
        moveZ = abs(dz);
        
        if moveX
            obj.pos_x = obj.pos_x + round(dx*500000*obj.pos_movespeed);
        end
        if moveY
            obj.pos_y = obj.pos_y - round(dy*500000*obj.pos_movespeed);
        end
        if moveZ
        end
        
        % change position
        if abs(dx)>0.05 || abs(dy)>0.05
            fprintf(obj.priorXYstage,'%s\r',...
                ['G,',num2str(obj.pos_x),',',num2str(obj.pos_y)]);
        end
    end
    
    display([num2str(obj.pos_movespeed),' ',...
        num2str(obj.pos_x),num2str(obj.pos_y)]);
    pause(.5);
end

end

