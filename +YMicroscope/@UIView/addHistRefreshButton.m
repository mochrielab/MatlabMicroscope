% add control button to refresh histogram lower/upper bound & image display
function addHistRefreshButton(obj,x,y)

% set up ui control
pos = [80+x*225, 355-y*75];

uicontrol('Parent',obj.controlpanel_handle,...
    'Style','pushbutton',...
    'Unit','Pixels','Position',[pos(1) pos(2) 125 45],...
    'String','Refresh','Fontsize',16,...
    'Callback',@(hobj,event)callbackFunc(hobj,event,obj));

% call back action to refresh histogram and display limits during live (?)
% may need to add restrictions to this?? - 02/13/17
    function callbackFunc(hobj,event,obj)
       obj.microscope_handle.setHistIdx(1);
    end
end