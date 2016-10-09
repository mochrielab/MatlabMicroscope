% add button selector
function addControlSelector(obj,x,y,tag,displayname,device_handle)
% device handle is the name of device str
% tag is the property name
% displayname is the name for display in UI

% get property handle
v=(device_handle.(tag));
% get property options
options=device_handle.([tag,'_options']);
% get control position
pos=obj.getControlPanelPosition(x,y);

% setup ui control
uic=uicontrol('Parent',obj.controlpanel_handle,'Style','popupmenu',...
    'Unit','Pixels','Position',[pos(1) pos(2) 200 20],...
    'Value',find(strcmp(v,options)),...
    'String',options,'Fontsize',10,...
    'Callback',@(hobj,eventdata)callbackFunc...
    (hobj,eventdata,device_handle,tag),'Tag',tag);
uicontrol('Parent',obj.controlpanel_handle,'Style','text',...
    'Unit','Pixels','Position',[pos(1) pos(2)+20 200 20],...
    'String',displayname,'Fontsize',10);

% add listener, to listen for change in value
numlh=length(obj.listeners);
obj.listeners(numlh+1)=...
    addlistener(device_handle,[capitalize(tag),'DidSet'],...
    @(hobj,eventdata)updateDisplay(uic,hobj,tag));

% call back actions
% set device value given UI change
    function callbackFunc(hobj,eventdata,device_handle,tag)
        try
            value=(hobj.get('Value'));
            device_handle.(['set',capitalize(tag)])...
                (device_handle.([tag,'_options']){value});
        catch exception
            set(hobj,'String',device_handle.(tag));
            warning(exception.message);
        end
    end

% update display choice upon change in device value
    function updateDisplay(hobj,device_handle,tag)
        if ishandle(hobj)
            set(hobj,'Value',...
                find(strcmp(device_handle.(tag),...
                device_handle.([tag,'_options']))))
        end
    end

% capitalize first letter
    function Name=capitalize(name)
        Name=[upper(name(1)),lower(name(2:end))];
    end

end