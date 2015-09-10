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
