classdef UIView < handle
    %view for the UI
    % Yao Zhao 11/8/2015
    
    properties (Access = protected)
        figure_handle
        imageaxis_handle
        hist_handle % 01/29/17 - SEP
        controlpanel_handle
        parampanel_handle
        listeners
%         listenersHist % 02/09/17 SEP
        
        moviecycles
        movieinterval
    end

    methods
        % set up ui view
        function obj=UIView()
            obj.figure_handle=figure('Position',[0 50 1920 950]);
%             obj.figure_handle.set('WindowKeyPressFcn',...
%                 'fprintf(''You pressed the key %c.\n'', get(gcf, ''CurrentCharacter''))'); % TEST 04/19/17 SEP
%             obj.figure_handle.set('WindowKeyPressFcn','charout = get(gcf,''CurrentKey'')'); % TEST 04/19/17 SEP            
%             obj.figure_handle.set('WindowKeyPressFcn',@(src,eventdata)keyfun(src,obj));
            obj.figure_handle.set('CloseRequestFcn',...
                @(src,eventdata)callbackFunc(src,obj));
            
%             % 04/20/17
%             function keyfun(src,obj)
%                 switch get(gcf,'CurrentKey')
%                     case 'leftarrow'
%                        disp('move left')
%                     case 'rightarrow'
%                        disp('move right')
%                     case 'uparrow'
%                         disp('move up')
%                     case 'downarrow'
%                         disp('move down')
%                     case 'j'
% %                         disp('move in')
% %                         obj.microscope_handle.zstage.setZoffset(obj.microscope_handle.zstage.zoffset+0.01);    
%                     case 'k'
%                         disp('move out')
%                 end
%             end
            
            function callbackFunc (hobj,obj)
                delete(hobj);
                delete(obj);
            end
            % image axes
            obj.imageaxis_handle=axes('Parent',obj.figure_handle,...
                'Unit','Pixels','Position',[20 20 910 910],...
                'Box','on','BoxStyle','full',...
                'xtick',[],'ytick',[]);
            imagesc(0); colormap gray;axis image;axis off
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
            % histogram axes 01/29/17 - SEP
            obj.hist_handle=axes('Parent',obj.controlpanel_handle,...
                'Unit','Pixels','Position',[465 80 250 150],'Box','on',...
                'BoxStyle','full','xtick',[],'ytick',[]);
            histogram(0); set(gca,'yticklabel',[]); xlim([0 150000]);
            obj.listeners=event.listener.empty;
%             obj.listenersHist = event.listener.empty; % 02/09/17 SEP
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
        setValue(obj, tag, stringvalue)
        
        % add control buttons for microscope actions
        addControlButton(obj, x, y, microscope_action)
        
        % add histogram refresh button
        addHistRefreshButton(obj, x, y)
        
        % add button selector
        addControlSelector(obj, x, y, tag, displayname, device_handle)
        
        % add listener and setter for specific attribute tag in device
        addParamCell(obj, x, y, tag, displayname, device_handle)
        
        % add listener and setter for exposure
        addParamCellWithExposure(obj, x, y, tag, displayname,...
            device_handle, camera_handle, microscope_handle)
        
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

