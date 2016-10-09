% add button selector
function addControlSelector(obj,x,y,tag,displayname,device_handle)
% uicontrol
v=(device_handle.(tag));
options=device_handle.([tag,'_options']);
pos=obj.getControlPanelPosition(x,y);
uic=uicontrol('Parent',obj.controlpanel_handle,'Style','popupmenu',...
    'Unit','Pixels','Position',[pos(1) pos(2) 200 20],...
    'Value',find(strcmp(v,options)),...
    'String',options,'Fontsize',10,...
    'Callback',@(hobj,eventdata)callbackFunc...
    (hobj,eventdata,device_handle,tag),'Tag',tag);
uicontrol('Parent',obj.controlpanel_handle,'Style','text',...
    'Unit','Pixels','Position',[pos(1) pos(2)+20 200 20],...
    'String',displayname,'Fontsize',10);
% add listener
numlh=length(obj.listeners);
obj.listeners(numlh+1)=...
    addlistener(device_handle,[capitalize(tag),'DidSet'],...
    @(hobj,eventdata)updateDisplay(uic,hobj,tag));
% call back actions
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
    function updateDisplay(hobj,device_handle,tag)
        if ishandle(hobj)
            set(hobj,'Value',...
                find(strcmp(device_handle.(tag),...
                device_handle.([tag,'_options']))))
        end
    end
    function Name=capitalize(name)
        Name=[upper(name(1)),lower(name(2:end))];
    end

end