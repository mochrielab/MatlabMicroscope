% add listener and setter for specific attribute tag in device
function addParamCell(obj,x,y,tag,displayname,device_handle)
% uicontrol
pos=obj.getParamPanelPosition(x,y);
a=num2str(device_handle.(tag));
uic=uicontrol('Parent',obj.parampanel_handle,'Unit','Pixels',...
    'Position',[pos(1) pos(2) 200 20],'Style','edit',...
    'String',a,'Tag',tag,...
    'Callback',@(hobj,eventdata)callbackFunc(hobj,eventdata,...
    device_handle,tag));
uicontrol('Parent',obj.parampanel_handle,'Unit','Pixels',...
    'Position',[pos(1) pos(2)+20 200 20],'Style','text','String',...
    displayname);
% add listener
numlh=length(obj.listeners);
obj.listeners(numlh+1)=...
    addlistener(device_handle,[capitalize(tag),'DidSet'],...
    @(hobj,eventdata)updateDisplay(uic,hobj,tag));
% call back actions
    function callbackFunc(hobj,eventdata,device_handle,tag)
        %         value=str2double(hobj.get('String'));
        if ~ischar(device_handle.(tag)) % 04/18/17 SEP
            value = str2double(hobj.get('String'));
        else
            value = hobj.get('String');
        end
        
        try
            device_handle.(['set',capitalize(tag)])(value);
        catch exception
            set(hobj,'String',device_handle.(tag));
            warning(exception.message);
        end
    end

    function updateDisplay(hobj,device_handle,tag)
        if ~ischar(class(device_handle.(tag)))
            set(hobj,'String',num2str(...
                device_handle.(tag)));
        else
            set(hobj,'String',device_handle.(tag));
        end
        
        % Determine if intensity or power has changed
        if (strcmp(tag,'intensity') == 1) || (strcmp(tag,'power') == 1)
            % set microscope_handle histogram index value to 1
            obj.microscope_handle.setHistIdx(1);
        end
    end
    function Name=capitalize(name)
        Name=[upper(name(1)),lower(name(2:end))];
    end
end