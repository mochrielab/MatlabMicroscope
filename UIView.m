classdef UIView < handle
    %view for the UI
    % Yao Zhao 11/8/2015
    
    properties (Access = protected)
        figure_handle
        imageaxis_handle
        controlpanel_handle
        parampanel_handle
        listeners
    end
    
    methods
        function obj=UIView()
            obj.figure_handle=figure('Position',[0 50 1920 950]);
            % image axes
            obj.imageaxis_handle=axes('Parent',obj.figure_handle,...
                'Unit','Pixels','Position',[20 20 910 910],'Box','on','BoxStyle','full',...
                'xtick',[],'ytick',[]);
            imagesc(0);colormap gray;axis image;axis off
            % control panel
            obj.controlpanel_handle=uipanel('Parent',obj.figure_handle,...
                'Unit','Pixels','Position',[950+20 465+20 970-50 475-20],...
                'Title','Control','Fontsize',14,...
                'BorderType','etchedin','HighlightColor','green');
            % parameter setting panel
            obj.parampanel_handle=uipanel('Parent',obj.figure_handle,...
                'Unit','Pixels','Position',[950+20 20 970-50 475-20],...
                'Title','Parameters','Fontsize',14,...
                'BorderType','etchedin','HighlightColor','blue');
            obj.listeners=event.listener.empty;
        end
        
%         set the value for specific tag
        function setValue(obj,tag,stringvalue)
            warning('need to be updated');return
            % set string value for a given tag
            handles=[obj.controlpanel_handle.get('Children'),...
                obj.parampanel_handle.get('Children');];
            display('handle size')
            size(handles)
            for i=1:numel(handles)
                if strcmp(handles(i).get('Tag'),tag)
                    if strcmp(handles(i).get('Style'),'popupmenu')
                        selections=handles(i).get('String');
                        for j=1:length(selections)
                            if strcmp(selections{j},stringvalue)
                                handles(i).set('Value',j);
                                return;
                            end
                        end
                        warning('invalid string value');
                    else
                        handles(i).set('String',stringvalue);
                    end
                    return
                end
            end
        end
       
        % add control buttons for microscope actions
        function addControlButton(obj,x,y,microscope_action)
            
            % set up ui control
            pos=obj.getControlPanelPosition(x,y);
            uic=uicontrol('Parent',obj.controlpanel_handle,...
                'Style','pushbutton',...
                'Unit','Pixels','Position',[pos(1) pos(2) 200 60],...
                'String',microscope_action.getEventDisplay('DidFinish'),...
                'Fontsize',20,...
                'Callback',@(hobj,eventdata)callbackFunc(microscope_action),...
                'Tag',microscope_action.label);
            
            % set up all event listners
            eves=events(microscope_action);
            for i=1:length(eves)
                numlh=length(obj.listeners);
                obj.listeners(numlh+1)=...
                    addlistener(microscope_action,eves{i},...
                    @(hobj,eventdata)updateDisplay(uic,microscope_action...
                    .getEventDisplay(eves{i})));
            end
            % update display
            function updateDisplay(hobj,str)
                if ishandle(hobj)
                    set(hobj,'String',str);
                end
            end
            % call back actions
            function callbackFunc(obj)
                if obj.isRunning
                    obj.stopAction;
                else
                    obj.startAction;
                end
            end
        end
        
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
                @(hobj,eventdata)set(uic,'Value',...
                find(strcmp(device_handle.(tag),...
                device_handle.([tag,'_options'])))));
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
            function Name=capitalize(name)
                Name=[upper(name(1)),lower(name(2:end))];
            end

        end
        
        % add listner and setter for specific attribute tag in device
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
                @(hobj,eventdata)set(uic,'String',num2str(...
                device_handle.(tag))));
            % call back actions
            function callbackFunc(hobj,eventdata,device_handle,tag)
                value=str2double(hobj.get('String'));
                try
                    device_handle.(['set',capitalize(tag)])(value);
                catch exception
                    set(hobj,'String',device_handle.(tag));
                    warning(exception.message);
                end
            end
            function Name=capitalize(name)
                Name=[upper(name(1)),lower(name(2:end))];
            end
        end
        
        % pop out windows for warnings
        function popWarning(obj)
            msgbox(lastwarn);
        end
        
        function delete(obj)
            delete(obj.listeners);
        end
    end
    
    methods (Static, Access=protected)    
        function pos=getControlPanelPosition(x,y)
            pos=[15+x*225,340-y*75];
        end
        
        function pos=getParamPanelPosition(x,y)
            pos=[15+x*225,390-y*50];
        end        
    end
    
    events
    end
end

