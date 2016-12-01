classdef UIView < handle
    %view for the UI
    % Yao Zhao 11/8/2015
    
    properties (Access = protected)
        figure_handle
        imageaxis_handle
        controlpanel_handle
        parampanel_handle
        listeners
        
        moviecycles
        movieinterval
    end
    
    methods
        % set up ui view
        function obj=UIView()
            obj.figure_handle=figure('Position',[0 50 1920 950]);
            obj.figure_handle.set('CloseRequestFcn',...
                @(src,eventdata)callbackFunc(src,obj));
            function callbackFunc (hobj,obj)
                delete(hobj);
                delete(obj);
            end
            % image axes
            obj.imageaxis_handle=axes('Parent',obj.figure_handle,...
                'Unit','Pixels','Position',[20 20 910 910],...
                'Box','on','BoxStyle','full',...
                'xtick',[],'ytick',[]);
            imagesc(0);colormap gray;axis image;axis off
            % control panel
            obj.controlpanel_handle=uipanel('Parent',obj.figure_handle,...
                'Unit','Pixels','Position',[950+20 475+20 970-50 475-30],...
                'Title','Control','Fontsize',14,...
                'BorderType','etchedin','HighlightColor','green');
            % parameter setting panel
            obj.parampanel_handle=uipanel('Parent',obj.figure_handle,...
                'Unit','Pixels','Position',[950+20 20 970-50 475-10],...
                'Title','Parameters','Fontsize',14,...
                'BorderType','etchedin','HighlightColor','blue');
            obj.listeners=event.listener.empty;
        end
        
        function setMoviecycles(moviecycles)
            if moviecycles >=0
                obj.moviecycles=moviecycles;
                notify(obj,'MoviecyclesDidSet');
            else
                throw(MException('UIView:NegativeMovieCycles',...
                    'negative movie cycles'));
            end
        end
        
        function setMovieinterval(movieinterval)
            if movieinterval >=0
                obj.movieinterval=movieinterval;
                notify(obj,'MovieintervalDidSet');
            else
                throw(MException('UIView:NegativeMovieInterval',...
                    'negative movie interval'));
            end
        end
        
        % set the value for specific tag
        setValue(obj,tag,stringvalue)
        
        % add control buttons for microscope actions
        addControlButton(obj,x,y,microscope_action)
        
        % add button selector
        addControlSelector(obj,x,y,tag,displayname,device_handle)
        
        % add listner and setter for specific attribute tag in device
        addParamCell(obj,x,y,tag,displayname,device_handle)
        
        % pop out windows for warnings
        function popWarning(obj)
            msgbox(lastwarn);
        end
        
        function delete(obj)
            if ~ishandle(obj.figure_handle)
                obj.figure_handle=[];
            else
                close(obj.figure_handle);
            end
            obj.deleteListeners;
        end
        
        function deleteListeners(obj)
            display('ui listeners deleted')
            for i = 1:length(obj.listeners)
                delete(obj.listeners(i));
            end
            obj.listeners = [];
        end
        
        function listeners = getListeners(obj)
            listeners = obj.listeners;
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
        MoviecyclesDidSet
        MovieintervalDidSet
    end
end

