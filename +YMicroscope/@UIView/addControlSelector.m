% add button selector
function addControlSelector(obj,x,y,tag,displayname,device_handle)
% device handle is the name of device str
% tag is the property name
% displayname is the name for display in UI

% get property value
v=(device_handle.(tag));
% get property options
datatype = '';
% logical type
if islogical(v)
    datatype = 'logical';
    if v == true
        v = 'Yes';
    else
        v = 'No';
    end
    options = {'No', 'Yes'};
    % string type
elseif ischar(v)
    datatype = 'string';
    options=device_handle.([tag,'_options']);
else
    throw(MException('UIView:addControlSelector',...
        ['unrecognizable type', v]));
end
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
            if strcmp(datatype, 'string')
                device_handle.(['set',capitalize(tag)])...
                    (device_handle.([tag,'_options']){value});
            elseif strcmp(datatype, 'logical')
                device_handle.(['set',capitalize(tag)])...
                    (value-1);
            end
        catch exception
            set(hobj,'String',device_handle.(tag));
            warning(exception.message);
        end
    end

% update display choice upon change in device value
    function updateDisplay(hobj,device_handle,tag)
        if ishandle(hobj)
            if strcmp(datatype, 'string')
                set(hobj,'Value',...
                    find(strcmp(device_handle.(tag),...
                    device_handle.([tag,'_options']))));
            elseif strcmp(datatype, 'logical')
                set(hobj,'Value',...
                    find(device_handle.(tag) == [false, true]));
            end
        end
    end

% capitalize first letter
    function Name=capitalize(name)
        Name=[upper(name(1)),lower(name(2:end))];
    end

end