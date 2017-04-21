classdef StageXYPrior < YMicroscope.Stage
    %Prior XY stage
    
    properties (SetAccess = protected)
        com
% %         xoffset % 04/21/17 SEP
% %         yoffset % 04/21/17 SEP
    end
    
    methods
        % constructor
        function obj=StageXYPrior(com) %,xoffset,yoffset) % modified 04/21/17 SEP
            try
                obj.com = serial(com);
                fopen(obj.com);
                set(obj.com,'Terminator','CR');
                set(obj.com,'timeout',1);
                obj.getPosition;
% %                 obj.setXoffset(xoffset); % 04/21/17 SEP
% %                 obj.setYoffset(yoffset); % 04/21/17 SEP
                disp('prior stage connected!')
            catch exception
                warning(['Prior XY Stage not connected:',...
                    exception.message]);
            end
            
        end
        
        % get current position
        function [ pos ] = getPosition( obj )
            %get the XY position of the prior stage
            try
                availablebytes=obj.com.BytesAvailable;
                if availablebytes>0
                    fread(obj.com, availablebytes)
                end
                
                fprintf(obj.com,'%s\r','PS'); % send new request --> PS is for getting position of stage
                pos = fscanf(obj.com); % read position
                % process position
                pos = strsplit(pos,',');
                x=str2double(pos{1});
                y=str2double(pos{2});
                if ~isnan(x) && ~isnan(y);
                    obj.pos_x = x;
                    obj.pos_y = y;
                    pos=[x,y];
                else
                    warning('read stage position unsuccessful');
                end
            catch error
                warning(['read stage error: ',error.message]);
            end
        end
        
        % MODIFIED BY SEP 04/21/17
        function setPosition( obj, pos )
            warning('not implemented')
% %             if ~isempty(pos)
% %                 obj.setXoffset(pos(1));
% %                 obj.setYoffset(pos(2));
% %             else
% %                 throw(MException('PriorXYStage:XYOffsetSize',...
% %                     [length(pos),' xoffset and yoffset sizes should be non-empty']));
% %             end
% %             notify(obj, 'XPDidSet');
% %             notify(obj, 'YPDidSet');
        end
        
        % set speed of stage
        % VS is stage command that sets stage speed to x, y for X and Y
        % axes in units of u (if units specified?)
        function setSpeed(obj,vs)
            obj.sendCommand(['VS,',num2str(vs(1)),',',num2str(vs(2))]);
            obj.v_x = vs(1);
            obj.v_y = vs(2);
            notify(obj, 'XVDidSet');
            notify(obj, 'YVDidSet');
        end
        
        function vs = getSpeed(obj)
            warning('not implemented');
        end
        
        % ADDED 04/21/17 SEP
% %         function setXoffset(obj,xoffset)
% %             obj.xoffset = xoffset;
% %             obj.sendCommand([',',num2str(vs(1)),',',num2str(vs(2))]);
% %         end
% %         
% %         % ADDED 04/21/17 SEP
% %         function setYoffset(obj,yoffset)
% %             obj.yoffset = yoffset;
% %         end

        function moveLeft(obj,step)
            obj.sendCommand(['B,',num2str(step)]);
        end
        
        function moveRight(obj,step)
            obj.sendCommand(['F,',num2str(step)]);
        end
        
                
        function moveFwd(obj,step)
            obj.sendCommand(['R,',num2str(step)]);
        end
        
                
        function moveBkwd(obj,step)
            obj.sendCommand(['L,',num2str(step)]);
        end
        

        % send command to stage
        function [ out ] = sendCommand( obj, str )
        % send stage command, and get feed back
            fprintf(obj.com,'%s\r',str);
            % wait and load
            out=fscanf(obj.com);
            % load rest
            while get(obj.com,'BytesAvailable')>0
                out=[out,fscanf(obj.com)];
            end
            % display(out);
        end

        % delete object
        function delete(obj)
            fclose(obj.com);
            display('Prior XY stage disconnected');
        end
        
    end
    
end

