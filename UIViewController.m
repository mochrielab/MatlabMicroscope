classdef UIViewController < UIView
    %UIView Controller to control the UIView
    % Yao Zhao, 11/9/2015
    
    properties
        microscope_handle
        uilooprunning 
        uilooprate =10;
        live
        
    end
    
    methods
        function obj = UIViewController(microscope_handle)
            obj@UIView();
%             obj.figure_handle.set('CloseRequestFcn',@(src,callbackdata)obj.delete);
            obj.microscope_handle=microscope_handle;
            obj.live=MicroscopeActionLive(obj.microscope_handle,obj.imageaxis_handle);
            % add controls
            obj.addControlButton(0,0,'live','Live',...
                @(hobj,eventdata)obj.callbackActions(hobj,eventdata));
            obj.addControlButton(1,0,'capture','Capture',[]);
            obj.addControlButton(2,0,'zstack','Zstack',[]);
            obj.addControlButton(3,0,'movie','Movie',[]);
            obj.addControlButton(0,1,'light','Light',[]);
            obj.addControlButton(1,1,'joystick','JoysTick',[]);
            obj.addControlButton(2,1,'zfocus','ZFocus',[]);
            % add selectors
            
            % add parameters
            obj.addPanelCell(0,0,'brightfield exposure',...
                'brightfield exposure(ms)',...
                @(hobj,eventdata)obj.callbackSetParam(hobj,eventdata))
            obj.addPanelCell(0,1,'brightfield intensity',...
                'brightfield itensity(1-10)',...
                @(hobj,eventdata)obj.callbackSetParam(hobj,eventdata))
            obj.addPanelCell(0,2,'fluorescent exposure',...
                'fluorescent exposure(ms)',...
                @(hobj,eventdata)obj.callbackSetParam(hobj,eventdata))
            obj.addPanelCell(0,3,'fluorescent intensity',...
                'fluorescent itensity(0-255)',...
                @(hobj,eventdata)obj.callbackSetParam(hobj,eventdata))
            obj.refreshParam;
        end
        
        function callbackSetParam(obj, hobj,eventdata)
            tag=hobj.get('Tag');
            value=hobj.get('String');
            valuen=str2double(value);
            if ~isnan(valuen)
                value=valuen;
            end
            if ~obj.microscope_handle.setProperty(tag,value)
                value=obj.microscope_handle.getProperty(tag);
                hobj.set('String',num2str(value));
                obj.popWarning;
            end
        end
        
        function callbackActions(obj,hobj,eventdata)
            tag=get(hobj,'Tag');
            if ~isprop(obj,tag)
                throw(MException('UIController:InvalidAction',...
                    'action not supported'))
            end
%             try
                if obj.(tag).isrunning
                    addlistener(obj.(tag),'DidFinish',...
                        @(hobj1,eventdata)callbackDidFinish(hobj));
                    obj.(tag).stopAction;
                else
                    addlistener(obj.(tag),'DidStart',...
                        @(hobj1,eventdata)callbackDidStart(hobj));
                    obj.(tag).startAction;
                end
%             catch exception
%                 warning(exception.message);
%             end
            function callbackDidStart(hobj)
                str=get(hobj,'String');
                set(hobj,'String',['Stop ',str]);
            end
            function callbackDidFinish(hobj)
                str=get(hobj,'String');
                set(hobj,'String',str(6:end));
            end
        end
        
        function refreshParam(obj)
            handles=obj.parampanel_handle.get('Children');
            for i=1:length(handles)
                tag=handles(i).get('Tag');
                if ~isempty(tag)
                    value=obj.microscope_handle.getProperty(tag);
                    handles(i).set('String',num2str(value));
                end
            end
        end
        
        % pop out windows for warnings
        function popWarning(obj)
            msgbox(lastwarn);
        end
        
        function delete(obj)
        end
    end
    
    events
        UILoopDidStop
    end
    
end

