classdef UIView < handle
    %view for the UI
    % Yao Zhao 11/8/2015
    
    properties (Access = protected)
        figure_handle
        imageaxis_handle
        controlpanel_handle
        parampanel_handle
    end
    
    methods (Access = protected)
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
        end
        
        function setValue(obj,tag,stringvalue)
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
        
        function addControlButton(obj,x,y,tag,displayname,callbackfunc)
            pos=obj.getControlPanelPosition(x,y);
            uicontrol('Parent',obj.controlpanel_handle,...
                'Style','pushbutton',...
                'Unit','Pixels','Position',[pos(1) pos(2) 200 60],...
                'String',displayname,'Fontsize',20,...
                'Callback',callbackfunc,'Tag',tag);
        end
        
        function addControlSelector(obj,x,y,tag,displayname,selections,callbackfunc)
            pos=obj.getControlPanelPosition(x,y);
            uicontrol('Parent',obj.controlpanel_handle,'Style','popupmenu',...
                'Unit','Pixels','Position',[pos(1) pos(2) 200 20],'Value',1,...
                'String',selections,'Fontsize',10,...
                'Callback',callbackfunc,'Tag',tag);
            uicontrol('Parent',obj.controlpanel_handle,'Style','text',...
                'Unit','Pixels','Position',[pos(1) pos(2)+20 200 20],...
                'String',displayname,'Fontsize',10);
        end
        
        function addPanelCell(obj,x,y,tag,displayname,callbackfunc)
            pos=obj.getParamPanelPosition(x,y);
            uicontrol('Parent',obj.parampanel_handle,'Unit','Pixels',...
                'Position',[pos(1) pos(2) 200 20],'Style','edit',...
                'String',[],'Tag',tag,...
                'Callback',callbackfunc);
            uicontrol('Parent',obj.parampanel_handle,'Unit','Pixels',...
                'Position',[pos(1) pos(2)+20 200 20],'Style','text','String',...
                displayname);
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
    
end

